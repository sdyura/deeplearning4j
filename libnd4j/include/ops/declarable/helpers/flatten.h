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
//  @author raver119@gmail.com
//

#ifndef DEV_TESTS_FLATTEN_H
#define DEV_TESTS_FLATTEN_H
#include <array/NDArray.h>

#include <vector>

namespace sd {
namespace ops {
namespace helpers {

//////////////////////////////////////////////////////////////////////
SD_LIB_HIDDEN void flatten(LaunchContext *context, std::vector<NDArray *> &inputs, NDArray *output, char order);


}  // namespace helpers
}  // namespace ops
}  // namespace sd

#endif  // DEV_TESTS_FLATTEN_H
