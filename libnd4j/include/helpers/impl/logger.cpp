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
// Created by raver119 on 31.10.2017.
//
#include <helpers/logger.h>

namespace sd {

SD_HOST void Logger::info(const char *format, ...) {
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  va_end(args);
  fflush(stdout);
}

SD_HOST void Logger::infoEmpty(const char *format) {
 if(format != nullptr)
  printf("%s",format);
}


SD_HOST void Logger::printv(const char *format, const std::vector<int> &vec) {
  printf("%s: {", format);
  for (size_t e = 0; e < vec.size(); e++) {
    auto v = vec[e];
    printf("%i", v);
    if (e < vec.size() - 1) printf(", ");
  }
  printf("}\n");
  fflush(stdout);
}

SD_HOST void Logger::printv(const char *format, const std::vector<LongType> &vec) {
  printf("%s: {", format);
  for (size_t e = 0; e < vec.size(); e++) {
    auto v = vec[e];
    printf("%lld", (long long)v);
    if (e < vec.size() - 1) printf(", ");
  }
  printf("}\n");
  fflush(stdout);
}

SD_HOST_DEVICE Status Logger::logStatusMsg(Status code, const char *msg) {
  if (msg != nullptr) sd_printf("%s\n", msg);
  return code;
}

SD_HOST_DEVICE Status Logger::logKernelFailureMsg(const char *msg) { return logStatusMsg(Status::KERNEL_FAILURE, msg); }
}  // namespace sd
