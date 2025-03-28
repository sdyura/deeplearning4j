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
// Created by raver119 on 13.10.2017.
//
#include <ops/declarable/OpDescriptor.h>

namespace sd {
namespace ops {

OpDescriptor::OpDescriptor(const char* opName, bool isLogic) {
  _logic = isLogic;
  _opName = opName;
}

OpDescriptor::OpDescriptor(int numInputs, const char* opName, bool isScalar) {
  _numInputs = numInputs;
  _numOutputs = 1;

  _opName = opName;
  _hash = HashHelper::getInstance().getLongHash(_opName);

  _scalar = isScalar;
}

OpDescriptor::OpDescriptor(int numInputs, std::string opName, bool isScalar) {
  _numInputs = numInputs;
  _numOutputs = 1;

  _opName = opName;
  _hash = HashHelper::getInstance().getLongHash(_opName);

  _scalar = isScalar;
}

void OpDescriptor::allowInplace(bool reallyAllow) { _allowsInplace = reallyAllow; }

bool OpDescriptor::operator==(const OpDescriptor& other) const {
  if (_hash == -1 && other._hash == -1)
    return this->_opNum == other._opNum;
  else
    return this->_hash == other._hash;
}

OpDescriptor::OpDescriptor(int numInputs, int numOutputs, std::string opName, bool allowsInplace)
    : OpDescriptor(numInputs, numOutputs, opName.c_str(), allowsInplace) {
  //
}

void OpDescriptor::setHash(LongType hash) { _hash = hash; }

// default constructor
OpDescriptor::OpDescriptor(int numInputs, int numOutputs, const char* opName, bool allowsInplace) {
  _numInputs = numInputs;
  _numOutputs = numOutputs;

  std::string tmp(opName);
  _opName = tmp;
  _allowsInplace = allowsInplace;
  _hash = HashHelper::getInstance().getLongHash(tmp);
  _divergent = false;

  // just default value
}

// constructor for configurable op
OpDescriptor::OpDescriptor(int numInputs, int numOutputs, const char* opName, bool allowsInplace, int tArgs, int iArgs)
    : OpDescriptor(numInputs, numOutputs, opName, allowsInplace) {
  _tArgs = tArgs;
  _iArgs = iArgs;
}

// constructor for non-configurable divergent op
OpDescriptor::OpDescriptor(int numInputs, int numOutputs, std::string opName, bool allowsInplace, bool divergent)
    : OpDescriptor(numInputs, numOutputs, opName.c_str(), allowsInplace, divergent) {}

// constructor for non-configurable divergent op
OpDescriptor::OpDescriptor(int numInputs, int numOutputs, const char* opName, bool allowsInplace, bool divergent)
    : OpDescriptor(numInputs, numOutputs, opName, allowsInplace) {
  _divergent = divergent;
}

// constructor for configurable divergent op
OpDescriptor::OpDescriptor(int numInputs, int numOutputs, const char* opName, bool allowsInplace, bool divergent,
                           int tArgs, int iArgs)
    : OpDescriptor(numInputs, numOutputs, opName, allowsInplace, tArgs, iArgs) {
  _divergent = divergent;
}


int OpDescriptor::getNumberOfTArgs() { return _tArgs; }

int OpDescriptor::getNumberOfIArgs() { return _iArgs; }

int OpDescriptor::getNumberOfInputs() { return _numInputs; }

LongType OpDescriptor::getHash() { return _hash; }

int OpDescriptor::getNumberOfOutputs() { return _numOutputs; }

std::string* OpDescriptor::getOpName() { return &_opName; }

bool OpDescriptor::isDivergent() { return _divergent; }

void OpDescriptor::setOpNum(int opNum) { _opNum = opNum; }

bool OpDescriptor::allowsInplace() { return _allowsInplace; }

int OpDescriptor::getOpNum() { return _opNum; }

OpDescriptor* OpDescriptor::setInputType(const InputType type) {
  _inputType = type;
  return this;
}

InputType OpDescriptor::inputType() { return _inputType; }

OpDescriptor* OpDescriptor::setAllowedInputTypes(const std::initializer_list<DataType>& dtypes) {
  _allowedIns = dtypes;
  return this;
}

OpDescriptor* OpDescriptor::setAllowedOutputTypes(const std::initializer_list<DataType>& dtypes) {
  _allowedOuts = dtypes;
  return this;
}

OpDescriptor* OpDescriptor::allowOverride(bool allowOverride) {
  _dtypeOverride = allowOverride;
  return this;
}

OpDescriptor* OpDescriptor::setAllowedInputTypes(const DataType dtype) {
  _allowedIns.clear();
  _allowedIns.emplace_back(dtype);
  return this;
}

OpDescriptor* OpDescriptor::setAllowedOutputTypes(const DataType dtype) {
  _allowedOuts.clear();
  _allowedOuts.emplace_back(dtype);
  return this;
}

OpDescriptor* OpDescriptor::setInputType(const int idx, const DataType dtype) {
  _inputTypes[idx] = {dtype};
  return this;
}

OpDescriptor* OpDescriptor::setOutputType(const int idx, const DataType dtype) {
  _outputTypes[idx] = {dtype};
  return this;
}

OpDescriptor* OpDescriptor::setSameMode(const bool reallySame) {
  _sameMode = reallySame;
  return this;
}

OpDescriptor* OpDescriptor::setAllowedInputTypes(int index, const std::vector<DataType>& dtype) {
  _inputTypes[index] = dtype;
  return this;
}

OpDescriptor* OpDescriptor::setAllowedOutputTypes(int index, const std::vector<DataType>& dtype) {
  _outputTypes[index] = dtype;
  return this;
}

OpDescriptor* OpDescriptor::setAllowedInputTypes(int index, DataType dtype) {
  if (_inputTypes.count(index) == 0)
    _inputTypes[index] = {dtype};
  else
    _inputTypes[index].emplace_back(dtype);

  return this;
}

OpDescriptor* OpDescriptor::setAllowedOutputTypes(int index, DataType dtype) {
  if (_outputTypes.count(index) == 0)
    _outputTypes[index] = {dtype};
  else
    _outputTypes[index].emplace_back(dtype);

  return this;
}

bool OpDescriptor::checkDataTypesMatch(DataType needle, std::vector<DataType>& haystack) const {
  // if haystack is empty - INHERIT is occurs - any type is perfect?
  if (haystack.empty()) return true;

  // first we're checking for direct input type match
  if (std::find(haystack.begin(), haystack.end(), needle) == haystack.end()) {
    // if direct input match failed - we're checking for ANY as allowed input
    if (std::find(haystack.begin(), haystack.end(), ANY) == haystack.end())
      return false;
    else
      return true;
  } else {
    return true;
  }
}

bool OpDescriptor::checkInputMatch(int index, DataType dataType) {
  // we check for per-input types first
  if (_inputTypes.empty() || _inputTypes.count(index) == 0) {
    // checking global input types
    return checkDataTypesMatch(dataType, _allowedIns);
  } else {
    // checking data type for specified input
    auto& allowed = _inputTypes[index];
    return checkDataTypesMatch(dataType, allowed);
  }
  return true;
}

bool OpDescriptor::checkOutputMatch(int index, DataType dataType) {
  // we check for per-output types first
  if (_outputTypes.empty() || _outputTypes.count(index) == 0) {
    // checking global output types
    return checkDataTypesMatch(dataType, _allowedOuts);
  } else {
    // checking data type for specified output
    auto allowed = _outputTypes[index];
    return checkDataTypesMatch(dataType, allowed);
  }
  return true;
}

bool OpDescriptor::isSameMode() { return _sameMode; }

bool OpDescriptor::isInherit(int index) {
  if (std::find(_allowedOuts.begin(), _allowedOuts.end(), INHERIT) != _allowedOuts.end()) return true;
  if (_outputTypes.count(index) > 0) {
    auto vec = _outputTypes[index];

    if (std::find(vec.begin(), vec.end(), INHERIT) != vec.end()) return true;
  }

  return false;
}

std::vector<DataType> OpDescriptor::getOutputTypesForOutput(int index) {
  if (_outputTypes.count(index) > 0)
    return _outputTypes.at(index);
  else
    return std::vector<DataType>();
}

std::vector<DataType> OpDescriptor::getInputTypesForInput(int index) {
  if (_inputTypes.count(index) > 0)
    return _inputTypes.at(index);
  else
    return std::vector<DataType>();
}
}  // namespace ops
}  // namespace sd
