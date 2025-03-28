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
// @author Yurii Shyrma (iuriish@yahoo.com)
// @author Oleh Semeniv (oleg.semeniv@gmail.com)
//
#include <array/NDArray.h>
#include <system/op_boilerplate.h>

namespace sd {
namespace ops {
namespace helpers {

SD_LIB_HIDDEN void adjustHue(LaunchContext* context, NDArray* input, NDArray* deltaScalarArr,
                             NDArray* output, const LongType dimC);

////////////////////////////////////////////////////////////////////////////////
template <typename T>
SD_INLINE SD_HOST_DEVICE void rgbToHsv(const T& r, const T& g, const T& b, T& h, T& s, T& v) {
  // h values are in range [0, 360)
  // s and v values are in range [0, 1]

  const T max = math::sd_max<T>(r, math::sd_max<T>(g, b));
  const T min = math::sd_min<T>(r, math::sd_min<T>(g, b));
  const T c = max - min;
  const T _p6 = (T)1 / (T)6;
  // calculate h
  if (c == 0) {
    h = 0;
  } else if (max == r) {
    h = _p6 * ((g - b) / c) + (g >= b ? (T)0 : (T)1);
  } else if (max == g) {
    h = _p6 * ((b - r) / c + (T)2);
  } else {  // max == b
    h = _p6 * ((r - g) / c + (T)4);
  }

  // calculate s
  s = max == (T)0 ? (T)0 : c / max;

  // calculate v
  v = max;  // / 255.f;
}

////////////////////////////////////////////////////////////////////////////////
template <typename T>
SD_INLINE SD_HOST_DEVICE void hsvToRgb(const T& h, const T& s, const T& v, T& r, T& g, T& b) {
  const float sector = h * 6.f;
  const T c = v * s;

  if (0.f <= sector && sector < 1.f) {
    r = v;
    g = v - c * (1 - sector);
    b = v - c;
  } else if (1.f <= sector && sector < 2.f) {
    r = v - c * (sector - 1);
    g = v;
    b = v - c;
  } else if (2.f <= sector && sector < 3.f) {
    r = v - c;
    g = v;
    b = v - c * (3 - sector);
  } else if (3.f <= sector && sector < 4.f) {
    r = v - c;
    g = v - c * (sector - 3);
    b = v;
  } else if (4.f <= sector && sector < 5.f) {
    r = v - c * (5 - sector);
    g = v - c;
    b = v;
  } else {  // 5.f <= sector < 6.f
    r = v;
    g = v - c;
    b = v - c * (sector - 5);
  }

}

////////////////////////////////////////////////////////////////////////////////
template <typename T>
SD_INLINE SD_HOST_DEVICE void rgbYuv(const T& r, const T& g, const T& b, T& y, T& u, T& v) {
  y = static_cast<T>(0.299) * r + static_cast<T>(0.587) * g + static_cast<T>(0.114) * b;
  u = -static_cast<T>(0.14714119) * r - static_cast<T>(0.2888691) * g + static_cast<T>(0.43601035) * b;
  v = static_cast<T>(0.61497538) * r - static_cast<T>(0.51496512) * g - static_cast<T>(0.10001026) * b;
}

////////////////////////////////////////////////////////////////////////////////
template <typename T>
SD_INLINE SD_HOST_DEVICE void yuvRgb(const T& y, const T& u, const T& v, T& r, T& g, T& b) {
  r = y + static_cast<T>(1.13988303) * v;
  g = y - static_cast<T>(0.394642334) * u - static_cast<T>(0.58062185) * v;
  b = y + static_cast<T>(2.03206185) * u;
}


}  // namespace helpers
}  // namespace ops
}  // namespace sd
