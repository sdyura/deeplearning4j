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
// @author Yurii Shyrma (iuriish@yahoo.com), created on 24.01.2018
//

#include <system/op_boilerplate.h>
#if NOT_EXCLUDED(OP_trace)

#include <ops/declarable/CustomOperations.h>
#include <ops/declarable/helpers/transforms.h>

namespace sd {
namespace ops {

CUSTOM_OP_IMPL(trace, 1, 1, false, 0, 0) {
  auto input = INPUT_VARIABLE(0);
  auto output = OUTPUT_VARIABLE(0);

  REQUIRE_TRUE(input->rankOf() >= 2, 0, "TRACE op: the rank of input array must be >=2, but got %i instead!",
               input->rankOf());

  helpers::trace(block.launchContext(), *input, *output);

  return Status::OK;
}

DECLARE_TYPES(trace) {
  getOpDescriptor()->setAllowedInputTypes(0, {ALL_FLOATS})->setAllowedOutputTypes(0, {ALL_FLOATS});
}

DECLARE_SHAPE_FN(trace) {
  auto inShapeInfo = inputShape->at(0);

  REQUIRE_TRUE(inShapeInfo[0] >= 2, 0, "TRACE op: the rank of input array must be >=2, but got %i instead!",
               inShapeInfo[0]);
  const int rank = inShapeInfo[0] - 2;

  LongType* outShapeInfo(nullptr);
  ALLOCATE(outShapeInfo, block.getWorkspace(), shape::shapeInfoLength(rank), sd::LongType);

  outShapeInfo[0] = rank;
  for (int i = 1; i <= rank; ++i) outShapeInfo[i] = inShapeInfo[i];

  shape::updateStrides(outShapeInfo, shape::order(inShapeInfo), false);
  ArrayOptions::setDataType(outShapeInfo,ArrayOptions::dataType(inShapeInfo));
  auto result = ConstantShapeHelper::getInstance().bufferForShapeInfo(outShapeInfo)->primary();
  RELEASE(outShapeInfo, block.getWorkspace());
  return SHAPELIST(result);
}

}  // namespace ops
}  // namespace sd

#endif
