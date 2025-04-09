#=============================================================================
# Copyright (c) 2025, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include(${rapids-cmake-dir}/cpm/detail/convert_patch_json.cmake)

set(bug
  [=[#include "file.h"
int function(not_parsed[
N], properly ) {
}]=])
set(file_path "${CMAKE_BINARY_DIR}/bug.txt")
file(WRITE ${file_path} "${bug}" )

set(expected_output [==[[
"#include \"file.h\"",
"int function(not_parsed[",
"N], properly ) {",
"}"
]]==])

rapids_cpm_convert_patch_json(FROM_FILE_TO_JSON json FILE_VAR file_path)
string(JSON json_content GET "${json}" "content")

string(JSON content_length LENGTH "${json_content}")
math(EXPR content_length "${content_length} - 1")
foreach(index RANGE ${content_length})
  string(JSON computed_line GET "${json_content}" ${index})
  string(JSON expected_line GET "${expected_output}" ${index})
  if(NOT (computed_line STREQUAL expected_line))
  message(FATAL_ERROR "exp: `${expected_line}`\ngot: `${computed_line}`")
endif()
endforeach()
