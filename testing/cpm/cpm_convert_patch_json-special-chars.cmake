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
  [=[
int function(not_parsed[
N], properly ) {
}]=])

set(file_path "${CMAKE_BINARY_DIR}/bug.txt")
file(WRITE ${file_path} "${bug}" )

rapids_cpm_convert_patch_json(FROM_FILE_TO_JSON json FILE_VAR file_path)

set(expected_output [==[[ "int function(not_parsed[", "N], properly ) {", "}" ]]==])
string(JSON json_content GET "${json}" "content")
if(NOT (expected_output STREQUAL json_content))
  message(FATAL_ERROR "exp: `${expected_output}`\ngot: `${json_content}`")
endif()
