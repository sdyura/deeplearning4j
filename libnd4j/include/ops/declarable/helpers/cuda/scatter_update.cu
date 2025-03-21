/* ******************************************************************************
 *
 *
 * This program and the accompanying materials are made available under the
 * terms of the Apache License, Version 2.0 which is available at
 * https://www.apache.org/licenses/LICENSE-2.0.
 *
 *  See the NOTICE file distributed with this work for additional
 *  information regarding copyright ownership.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 ******************************************************************************/

//
// @author Yurii Shyrma (iuriish@yahoo.com), created on 20.04.2018
//

#include <array/NDArrayFactory.h>
#include <array/ResultSet.h>
#include <exceptions/cuda_exception.h>
#include <helpers/ConstantTadHelper.h>
#include <helpers/PointersManager.h>
#include <helpers/ShapeUtils.h>

#include <ops/declarable/helpers/transforms.h>

#include <numeric>

#include "execution/cuda/LaunchDims.h"


namespace sd {
namespace ops {
namespace helpers {
///////////////////////////////////////////////////////////////////
template <typename T>
SD_KERNEL static void scatterUpdateCuda(const int opCode, const int numOfInd, void* vx, const LongType* xShapeInfo,
                                        const LongType* xOffsets, void* vy, const LongType* yShapeInfo,
                                        const LongType* yOffsets, const LongType* indexes) {
  // Shared memory caching for shape and pointers
  __shared__ T *x, *y;
  __shared__ LongType arrLenX, arrLenY;
  __shared__ LongType xRank, yRank;
  __shared__ const LongType* xShape;
  __shared__ const LongType* yShape;
  __shared__ const LongType* xStride;
  __shared__ const LongType* yStride;

  // Initialize shared variables
  if (threadIdx.x == 0) {
    xRank = shape::rank(xShapeInfo);
    yRank = shape::rank(yShapeInfo);
    xShape = shape::shapeOf(xShapeInfo);
    yShape = shape::shapeOf(yShapeInfo);
    xStride = shape::stride(xShapeInfo);
    yStride = shape::stride(yShapeInfo);
    arrLenX = shape::length(xShapeInfo);
    arrLenY = shape::length(yShapeInfo);
  }
  __syncthreads();

  // Iterate through the number of indices
  for (int e = 0; e < numOfInd; e++) {
    const auto xIndex = indexes[e];
    const bool isOwner = xIndex < gridDim.x ? blockIdx.x == xIndex : blockIdx.x == xIndex % gridDim.x;

    if (!isOwner) continue;

    // Initialize x and y pointers
    if (threadIdx.x == 0) {
      x = reinterpret_cast<T*>(vx) + xOffsets[xIndex];
      y = reinterpret_cast<T*>(vy) + yOffsets[e];
    }
    __syncthreads();

    // Validate array lengths
    if (arrLenX != arrLenY) return;

    // Process the elements
    for (LongType i = threadIdx.x; i < arrLenX; i += blockDim.x) {
      LongType xCoords[SD_MAX_RANK];
      LongType yCoords[SD_MAX_RANK];
      LongType xOffset, yOffset;

      // Compute coordinates and offsets for x and y
      INDEX2COORDS(i, xRank, xShape, xCoords);
      COORDS2INDEX(xRank, xStride, xCoords, xOffset);
      INDEX2COORDS(i, yRank, yShape, yCoords);
      COORDS2INDEX(yRank, yStride, yCoords, yOffset);

      // Perform the specified operation
      switch (opCode) {
        case 0:
          x[xOffset] += y[yOffset];
          break;
        case 1:
          x[xOffset] -= y[yOffset];
          break;
        case 2:
          x[xOffset] *= y[yOffset];
          break;
        case 3:
          x[xOffset] /= y[yOffset];
          break;
        case 4:
          x[xOffset] = y[yOffset] - x[xOffset];
          break;
        case 5:
          x[xOffset] = y[yOffset] / x[xOffset];
          break;
        case 6:
          x[xOffset] = y[yOffset];
          break;
        default:
          break;
      }
    }
    __syncthreads();
  }
}


template <typename T>
SD_HOST static void scatterUpdateCudaLauncher(const cudaStream_t* stream, const int opCode, const int numOfInd,
                                              void* vx, const LongType* xShapeInfo, const LongType* xOffsets,
                                              void* vy, const LongType* yShapeInfo, const LongType* yOffsets,
                                              const LongType* indexes) {
  dim3 launchDims = getLaunchDims("scatter_update");
  scatterUpdateCuda<T><<<launchDims.y, launchDims.x, SD_MAX_NUM_THREADS, *stream>>>(opCode, numOfInd, vx, xShapeInfo, xOffsets, vy,
                                                                  yShapeInfo, yOffsets, indexes);
  sd::DebugHelper::checkErrorCode(const_cast<cudaStream_t *>(stream), "scatterUpdateCuda failed");

}

//////////////////////////////////////////////////////////////////////////
void scatterUpdate(LaunchContext* context, NDArray& input, NDArray& updates, const std::vector<LongType>* intArgs) {
  const int opCode = (*intArgs)[0];
  const int numOfDims = (*intArgs)[1];
  const int numOfInd = (*intArgs)[2 + numOfDims];

  std::vector<LongType> tadDimensions(numOfDims);
  for (int e = 2; e < 2 + numOfDims; e++) tadDimensions[e - 2] = (*intArgs)[e];

  auto packX = ConstantTadHelper::getInstance().tadForDimensions(input.shapeInfo(), &tadDimensions);
  auto packY = ConstantTadHelper::getInstance().tadForDimensions(updates.shapeInfo(), &tadDimensions);

  std::vector<LongType> shape = {numOfInd};
  NDArray indices(const_cast<LongType*>(intArgs->data()) + numOfDims + 3, 'c', shape, INT32, context);

  PointersManager manager(context, "scatterUpdate");

  NDArray::prepareSpecialUse({&input}, {&input, &updates, &indices});
  BUILD_SINGLE_SELECTOR(input.dataType(), scatterUpdateCudaLauncher,
                        (context->getCudaStream(), opCode, numOfInd, input.specialBuffer(), packX->platformShapeInfo(),
                         packX->platformOffsets(), updates.specialBuffer(), packY->platformShapeInfo(),
                         packY->platformOffsets(), reinterpret_cast<sd::LongType *>(indices.specialBuffer())),
                        SD_COMMON_TYPES);
  NDArray::registerSpecialUse({&input}, {&input, &updates, &indices});

  manager.synchronize();
}
}  // namespace helpers
}  // namespace ops
}  // namespace sd
