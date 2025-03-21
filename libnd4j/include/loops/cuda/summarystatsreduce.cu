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
// @author raver119@gmail.com
//

#include <cuda.h>
#include <cuda_runtime.h>
#include <helpers/DebugHelper.h>

#include <helpers/shape.h>
#include <loops/summarystatsreduce.h>
#include <ops/specials_cuda.h>
#include <system/Environment.h>
#include <system/op_boilerplate.h>
#include <types/float16.h>
#include <types/types.h>


using namespace simdOps;

namespace functions {
namespace summarystats {

template <typename X, typename Z>
void SD_KERNEL summaryStatsReduceT(int op, void const* dx, sd::LongType const* xShapeInfo, sd::LongType xRank, void* extraParams,
                                  void* z, sd::LongType const* zShapeInfo, sd::LongType zRank,
                                  sd::LongType* dimension, long long int dimensionLength, int postProcessOrNot, bool biasCorrected, sd::LongType* allocationBuffer,
                                  void* reductionBuffer, sd::LongType const* tadOnlyShapeInfo,
                                  sd::LongType const* tadOffsets) {
 SummaryStatsReduce<X, Z>::transform(
     op, dx, xShapeInfo, extraParams, z, zShapeInfo, dimension, dimensionLength, biasCorrected, allocationBuffer,
     reductionBuffer, tadOnlyShapeInfo, tadOffsets);
}

/**
*
* @param sPartialsRef
* @param tid
* @param extraParams
*/
template <typename X, typename Z>
template <typename OpType>
SD_DEVICE void SummaryStatsReduce<X, Z>::aggregatePartials(SummaryStatsData<X>* sPartials, sd::LongType tid,
                                                          sd::LongType numElements, void* vextraParams) {
 // start the shared memory loop on the next power of 2 less
 // than the block size.  If block size is not a power of 2,
 // accumulate the intermediate sums in the remainder range.

 auto extraParams = static_cast<Z*>(vextraParams);
 sd::LongType floorPow2 = blockDim.x;

 if (floorPow2 & (floorPow2 - 1)) {
   while (floorPow2 & (floorPow2 - 1)) {
     floorPow2 &= floorPow2 - 1;
   }

   if (tid >= floorPow2) {
     SummaryStatsData<X> prev = sPartials[tid - floorPow2];
     SummaryStatsData<X> curr = sPartials[tid];
     sPartials[tid - floorPow2] = update(prev, curr, extraParams);
   }
   __syncthreads();
 }

 for (sd::LongType activeThreads = floorPow2 >> 1; activeThreads; activeThreads >>= 1) {
   if (tid < activeThreads && tid + activeThreads < numElements) {
     SummaryStatsData<X> curr = sPartials[tid];
     SummaryStatsData<X> next = sPartials[tid + activeThreads];
     sPartials[tid] = update(curr, next, extraParams);
   }
   __syncthreads();
 }
};

/**
* @param n n is the number of
*        elements to loop through
* @param dx the data to operate on
* @param xVectorInfo the meta data for the vector:
*                              0 is the offset
*                              1 is the increment/stride
*                              2 is the real length of the buffer (n and dx.length won't always be the same)
*                              3 is the element wise stride for the buffer
*                              4 is the number of elements it takes to get to the next row/column/tensor
* @param gpuInformation
*                              0 is the block size
*                              1 is the grid size
*                              2 is the shared memory size
* @param problemDefinition
*                          0 is the number of elements per vector
*                          1 is the number of vectors
*/
template <typename X, typename Z>
template <typename OpType>
SD_DEVICE void SummaryStatsReduce<X, Z>::transform(void const* vx, sd::LongType const* xShapeInfo, void* vextraParams,
                                                   void* vz, sd::LongType const* zShapeInfo, sd::LongType* dimension,
                                                   sd::LongType dimensionLength, int postProcessOrNot,
                                                   sd::LongType* allocationBuffer,
                                                   void* vreductionBuffer, sd::LongType const* tadOnlyShapeInfo,
                                                   sd::LongType const* tadOffsets) {
 auto dx = static_cast<X const*>(vx);
 auto z = static_cast<Z*>(vz);
 auto extraParams = static_cast<Z*>(vextraParams);
 auto reductionBuffer = static_cast<Z*>(vreductionBuffer);

 int tid = blockIdx.x * blockDim.x + threadIdx.x;
 __shared__ volatile int resultScalar;

 int numElements = blockDim.x;
 // shared memory space for storing intermediate results
 __shared__ SummaryStatsData<X> sPartials[SD_CUDA_BLOCK_SIZE];

 // Cache shape information for x buffer
 __shared__ sd::LongType xRank;
 __shared__ const sd::LongType* xShapePtr;
 __shared__ const sd::LongType* xStridePtr;

 // Cache shape information for TAD
 __shared__ sd::LongType tadRank;
 __shared__ const sd::LongType* tadShapePtr;
 __shared__ const sd::LongType* tadStridePtr;

 Z startingVal = startingValue(dx);

 SummaryStatsData<X> val;
 val.initWithValue(startingVal);
 val.n = 0;
 sPartials[threadIdx.x] = val;

 // length for the tad
 __shared__ volatile int xLength;
 __shared__ volatile int resultLength;

 SummaryStatsData<X> reduction;
 reduction.initWithValue(0.0);
 reduction.n = 0;

 if (threadIdx.x == 0) {
   if (zShapeInfo != nullptr)
     resultLength = shape::length(zShapeInfo);
   else
     resultLength = 1;

   if (dimensionLength == 1) {
     if (resultLength == 1 && (dimension == nullptr || dimension[0] == SD_MAX_DIMENSION))
       resultScalar = 1;
     else
       resultScalar = 0;
   } else
     resultScalar = 0;

   if (resultLength == 1)
     resultScalar = 1;

   xLength = shape::length(xShapeInfo);

   // Cache x shape information
   xRank = shape::rank(xShapeInfo);
   xShapePtr = shape::shapeOf(xShapeInfo);
   xStridePtr = shape::stride(xShapeInfo);

   // Cache TAD shape information
   if (tadOnlyShapeInfo != nullptr) {
     tadRank = shape::rank(tadOnlyShapeInfo);
     tadShapePtr = shape::shapeOf(tadOnlyShapeInfo);
     tadStridePtr = shape::stride(tadOnlyShapeInfo);
   }
 }
 __syncthreads();

 if (!resultScalar) {
   __shared__ int tadLength;
   __shared__ int numTads;

   if (threadIdx.x == 0) {
     tadLength = shape::length(tadOnlyShapeInfo);
     numTads = shape::length(xShapeInfo) / tadLength;
   }
   __syncthreads();

   for (int r = blockIdx.x; r < numTads; r += gridDim.x) {
     auto tadOffsetForBlock = tadOffsets[r];

     val.initWithValue(startingVal);
     val.n = 0;
     sPartials[threadIdx.x] = val;

     for (int i = threadIdx.x; i < tadLength; i += blockDim.x) {
       sd::LongType xCoords[SD_MAX_RANK];
       sd::LongType xOffset;
       INDEX2COORDS(i, tadRank, tadShapePtr, xCoords);
       COORDS2INDEX(tadRank, tadStridePtr, xCoords, xOffset);
       auto xOffsetFinal = tadOffsetForBlock + xOffset;
       SummaryStatsData<X> indexVal2;
       indexVal2.initWithValue(dx[xOffsetFinal]);

       sPartials[threadIdx.x] = update(sPartials[threadIdx.x], OpType::op(indexVal2, extraParams), extraParams);
     }
     __syncthreads();
     aggregatePartials<OpType>(sPartials, threadIdx.x, sd::math::sd_min<int>(blockDim.x, tadLength), extraParams);

     __syncthreads();
     if (threadIdx.x == 0) {
       z[r] = OpType::getValue(postProcessOrNot, sPartials[threadIdx.x]);
     }
     __syncthreads();
   }
 } else if (resultScalar) {
   __shared__ int n;
   if (threadIdx.x == 0) {
     n = shape::length(xShapeInfo);
   }
   __syncthreads();

   for (sd::LongType i = tid; i < n; i += blockDim.x * gridDim.x) {
     sd::LongType xCoords[SD_MAX_RANK];
     sd::LongType xOffset;
     INDEX2COORDS(i, xRank, xShapePtr, xCoords);
     COORDS2INDEX(xRank, xStridePtr, xCoords, xOffset);
     SummaryStatsData<X> indexVal2;
     indexVal2.initWithValue(dx[xOffset]);
     reduction = update(reduction, indexVal2, extraParams);
   }
   sPartials[threadIdx.x] = reduction;

   __syncthreads();
   aggregatePartials<OpType>(sPartials, threadIdx.x, blockDim.x, extraParams);
   __syncthreads();

   if (gridDim.x > 1) {
     __shared__ bool amLast;
     unsigned int* tc = (unsigned int*)reductionBuffer;
     tid = threadIdx.x;
     if (threadIdx.x == 0) {
       SummaryStatsData<X>* pBuffer = (SummaryStatsData<X>*)reductionBuffer;
       pBuffer[blockIdx.x] = sPartials[0];
     }
     __threadfence();
     __syncthreads();

     if (tid == 0) {
       unsigned int ticket = atomicInc(&tc[16384], gridDim.x);
       amLast = (ticket == gridDim.x - 1);
     }

     __syncthreads();

     if (amLast) {
       tc[16384] = 0;
       SummaryStatsData<X>* pBuffer = (SummaryStatsData<X>*)reductionBuffer;

       Z startingVal = startingValue(dx);

       SummaryStatsData<X> val;
       val.initWithValue(startingVal);
       val.n = 0;
       sPartials[threadIdx.x] = val;

       for (int i = threadIdx.x; i < gridDim.x; i += blockDim.x) {
         sPartials[threadIdx.x] = update(sPartials[threadIdx.x], pBuffer[i], extraParams);
       }

       __syncthreads();
       aggregatePartials<OpType>(sPartials, threadIdx.x, gridDim.x, extraParams);
       __syncthreads();

       if (tid == 0) {
         z[0] = OpType::getValue(postProcessOrNot, sPartials[0]);
       }
     }
   } else {
     if (tid == 0) {
       unsigned int* tc = (unsigned*)reductionBuffer;
       tc[16384] = 0;
       z[0] = OpType::getValue(postProcessOrNot, sPartials[0]);
     }
   }
 }
};

template <typename X, typename Y>
SD_DEVICE void SummaryStatsReduce<X, Y>::transform(const int opNum, void const* dx, sd::LongType const* xShapeInfo,
                                                  void* extraParams, void* z, sd::LongType const* zShapeInfo,
                                                  sd::LongType* dimension, sd::LongType dimensionLength, int postProcessOrNot, sd::LongType* allocationBuffer, void* reductionBuffer,
                                                  sd::LongType const* tadOnlyShapeInfo,
                                                  sd::LongType const* tadOffsets) {
 DISPATCH_BY_OPNUM_TT(transform,
                      PARAMS(dx, xShapeInfo, extraParams, z, zShapeInfo, dimension, dimensionLength, postProcessOrNot,
                             allocationBuffer, reductionBuffer, tadOnlyShapeInfo, tadOffsets),
                      SUMMARY_STATS_OPS);
};

template <typename X, typename Z>
SD_HOST void SummaryStatsReduce<X, Z>::execSummaryStatsReduceScalar(
   dim3& launchDims, cudaStream_t* stream, int opNum, void const* vx, sd::LongType const* xShapeInfo,
   sd::LongType const* hxShapeInfo, void* vextraParams, void* vz, sd::LongType const* zShapeInfo,
   sd::LongType const* hzShapeInfo, sd::LongType const* tadShapeInfo, sd::LongType const* tadOffsets,
   bool biasCorrected, void* reductionBuffer) {
 auto x = static_cast<X const*>(vx);
 auto extraParams = static_cast<Z*>(vextraParams);
 auto z = reinterpret_cast<Z*>(vz);
 auto reductionPointerA = reinterpret_cast<Z*>(reductionBuffer);

 if (sd::Environment::getInstance().isDebugAndVerbose()) printf("D16 opNum:[%i]\n", opNum);

 summaryStatsReduceT<X, Z><<<launchDims.x, launchDims.y, launchDims.z, *stream>>>(
     opNum, x, xShapeInfo, shape::rank(hxShapeInfo), extraParams, z, zShapeInfo, shape::rank(hzShapeInfo), nullptr, 1,
     1, biasCorrected, nullptr, reductionPointerA, tadShapeInfo, tadOffsets);

 // this is blocking method since method should return scalar
 sd::DebugHelper::checkErrorCode(stream, "execSSReduceScalar(...) failed");
}

template <typename X, typename Z>
SD_HOST void SummaryStatsReduce<X, Z>::execSummaryStatsReduce(
   dim3& launchDims, cudaStream_t* stream, int opNum, void const* vx, sd::LongType const* xShapeInfo,
   sd::LongType const* hxShapeInfo, void* vextraParams, void* vz, sd::LongType const* zShapeInfo,
   sd::LongType const* hzShapeInfo, sd::LongType const* tadShapeInfo, sd::LongType const* tadOffsets,
   bool biasCorrected, void* reductionBuffer) {
 auto x = static_cast<X const*>(vx);
 auto z = static_cast<Z*>(vz);
 auto extraParams = static_cast<Z*>(vextraParams);

 if (sd::Environment::getInstance().isDebugAndVerbose()) printf("F17 opNum:[%i]\n", opNum);

 auto reductionPointerA = reinterpret_cast<Z*>(reductionBuffer);

 summaryStatsReduceT<X, Z><<<launchDims.x, launchDims.y, launchDims.z, *stream>>>(
     opNum, x, xShapeInfo, shape::rank(hxShapeInfo), extraParams, z, zShapeInfo, shape::rank(hzShapeInfo), nullptr, 1,
     1, biasCorrected, nullptr, reductionPointerA, tadShapeInfo, tadOffsets);

 DEBUG_KERNEL(stream, opNum);
}

template <typename X, typename Z>
SD_HOST void SummaryStatsReduce<X, Z>::execSummaryStatsReduce(
   dim3& launchDims, cudaStream_t* stream, int opNum, void const* vx, sd::LongType const* xShapeInfo,
   sd::LongType const* hxShapeInfo, void* vextraParams, void* vz, sd::LongType const* zShapeInfo,
   sd::LongType const* hzShapeInfo, sd::LongType* dimension, long long int dimensionLength, sd::LongType const* tadShapeInfo,
   sd::LongType const* tadOffsets, bool biasCorrected, void* reductionBuffer) {
 auto x = static_cast<X const*>(vx);
 auto z = static_cast<Z*>(vz);
 auto extraParams = static_cast<Z*>(vextraParams);

 if (sd::Environment::getInstance().isDebugAndVerbose()) printf("D18 opNum:[%i]\n", opNum);

 summaryStatsReduceT<X, Z><<<launchDims.x, launchDims.y, launchDims.z, *stream>>>(
     opNum, x, xShapeInfo, shape::rank(hxShapeInfo), extraParams, z, zShapeInfo, shape::rank(hzShapeInfo), dimension,
     dimensionLength, 1, biasCorrected, nullptr, reinterpret_cast<Z*>(reductionBuffer), tadShapeInfo, tadOffsets);

 sd::DebugHelper::checkErrorCode(stream, "SummaryStatsReduce execSummaryStatsReduce(...) failed");
}

BUILD_DOUBLE_TEMPLATE(template class SummaryStatsReduce, , SD_COMMON_TYPES, SD_FLOAT_TYPES);
}  // namespace summarystats
}  // namespace functions
