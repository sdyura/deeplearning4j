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
// Created by raver119 on 17.10.2017.
//
#include <array/DataTypeUtils.h>
#include <helpers/ConstantTadHelper.h>
#include <helpers/ShapeUtils.h>

#include <ops/declarable/LegacyReduce3Op.h>
#include <ops/declarable/OpRegistrator.h>
#include <legacy/NativeOpExecutioner.h>
namespace sd {
namespace ops {
Status LegacyReduce3Op::validateAndExecute(Context &block) {
  auto x = INPUT_VARIABLE(0);
  auto y = INPUT_VARIABLE(1);
  auto z = OUTPUT_VARIABLE(0);

  NDArray::prepareSpecialUse({z}, {x, y});

  int opNum = block.opNum() < 0 ? this->_opNum : block.opNum();

  sd_debug("Executing LegacyReduce3Op: [%i]\n", opNum);

  ExtraArguments extras(*block.getTArguments());
  PointersManager manager(block.launchContext(), "LegacyReduce3Op");

  if (x->isSameShape(y) && (block.getIArguments()->size() == 0 ||
                            (block.getIArguments()->size() == 1 && INT_ARG(0) == DataTypeUtils::max<int>()))) {
    // reduce3 to scalar
    NativeOpExecutioner::execReduce3Scalar(
        block.launchContext(), opNum, x->buffer(), x->shapeInfo(), x->specialBuffer(), x->specialShapeInfo(),
        extras.argumentsAsT(z->dataType()), y->buffer(), y->shapeInfo(), y->specialBuffer(), y->specialShapeInfo(),
        z->buffer(), z->shapeInfo(), z->specialBuffer(), z->specialShapeInfo());
  } else {
    std::vector<LongType> dims(*block.getAxis());
    for (size_t e = 0; e < dims.size(); e++)
      if (dims[e] < 0) dims[e] += x->rankOf();

    auto packX = ConstantTadHelper::getInstance().tadForDimensions(x->shapeInfo(), &dims);
    auto packZ = ConstantTadHelper::getInstance().tadForDimensions(z->shapeInfo(), &dims);

    REQUIRE_TRUE(dims.size() > 0, 0, "Some dimensions requuired for reduction!");

    auto xTadShape = Environment::getInstance().isCPU()
                         ? packX->primaryShapeInfo()
                         : packX->specialShapeInfo();
    auto xTadOffsets = Environment::getInstance().isCPU()
                           ? packX->primaryOffsets()
                           : packX->specialOffsets();

    auto yTadShape = Environment::getInstance().isCPU()
                         ? packZ->primaryShapeInfo()
                         : packZ->specialOffsets();
    auto yTadOffsets = Environment::getInstance().isCPU()
                           ? packZ->primaryOffsets()
                           : packZ->specialOffsets();

    NativeOpExecutioner::execReduce3(block.launchContext(), opNum, x->buffer(), x->shapeInfo(), x->specialBuffer(),
                                     x->specialShapeInfo(), extras.argumentsAsT(z->dataType()), y->buffer(),
                                     y->shapeInfo(), y->specialBuffer(), y->specialShapeInfo(), z->buffer(),
                                     z->shapeInfo(), z->specialBuffer(), z->specialShapeInfo(), dims.data(),
                                     dims.size(), xTadShape, xTadOffsets, yTadShape, yTadOffsets);
  }

  manager.synchronize();
  STORE_RESULT(*z);
  traceExecIfNeeded(block);
  return Status::OK;
}


LegacyReduce3Op::LegacyReduce3Op() : LegacyOp(2) {
  //
}

LegacyReduce3Op::LegacyReduce3Op(int opNum) : LegacyOp(2, opNum) {
  //
}

LegacyOp *LegacyReduce3Op::clone() { return new LegacyReduce3Op(this->_opNum); }

/**
 *   For all reductions rules are simple: either you return scalar, or you return reduced NDArray.
 *   It solely depends on input shape, and requested dimensions
 */
ShapeList *LegacyReduce3Op::calculateOutputShape(ShapeList *inputShape, Context &block) {
  auto xShape = inputShape->at(0);
  auto yShape = inputShape->at(1);

  LongType *zShape = nullptr;

  if (shape::equalsSoft(xShape, yShape) &&
      (block.getIArguments()->size() == 0 ||
       (block.getIArguments()->size() == 1 && INT_ARG(0) == DataTypeUtils::max<int>()))) {
    // reduce3 to scalar case
    ALLOCATE(zShape, block.getWorkspace(), shape::shapeInfoLength(2), sd::LongType);
    zShape[0] = 2;
    zShape[1] = 1;
    zShape[2] = 1;
    zShape[3] = 1;
    zShape[4] = 1;
    zShape[5] = 0;
    zShape[6] = 1;
    zShape[7] = 99;
  } else {
    sd::LongType *xShape2 = ShapeUtils::evalReduceShapeInfo('c', block.getIArguments(), xShape, false, true);
    return SHAPELIST(xShape2);
  }

  return SHAPELIST(zShape);
}
}  // namespace ops
}  // namespace sd
