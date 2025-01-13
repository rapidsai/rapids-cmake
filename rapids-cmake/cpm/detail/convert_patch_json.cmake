#=============================================================================
# Copyright (c) 2024-2025, NVIDIA CORPORATION.
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
include_guard(GLOBAL)

#[=======================================================================[.rst:
rapids_cpm_convert_patch_json
-------------------------------

.. versionadded:: v25.02.00


.. code-block:: cmake

  rapids_cpm_convert_patch_json( (FROM_JSON_TO_FILE|FROM_FILE_TO_JSON)
                                 <json_var>
                                 FILE_VAR <path>
                                 <PACKAGE_NAME package_name INDEX index> # required for FROM_JSON_TO_FILE
                                )

#]=======================================================================]
function(rapids_cpm_convert_patch_json)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cpm.conver_path_json")

  set(options)
  set(one_value FROM_JSON_TO_FILE FROM_FILE_TO_JSON FILE_VAR PACKAGE_NAME INDEX)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  if(NOT _RAPIDS_FILE_VAR)
    message(FATAL_ERROR "rapids_cpm_convert_patch_json required field of `FILE_VAR` is missing")
  endif()

  if(_RAPIDS_FROM_JSON_TO_FILE)
    set(json "${${_RAPIDS_FROM_JSON_TO_FILE}}")

    string(JSON type GET "${json}" "type")
    string(JSON json_content GET "${json}" "content")

    # Figure out the file path
    set(file
        "${CMAKE_BINARY_DIR}/rapids-cmake/patches/${_RAPIDS_PACKAGE_NAME}/embedded_patch_${_RAPIDS_INDEX}.${type}"
    )

    # Transform from a list of strings to a single file
    string(JSON content_length LENGTH "${json_content}")
    math(EXPR content_length "${content_length} - 1")
    unset(file_content)
    # cmake-lint: disable=E1120
    foreach(index RANGE ${content_length})
      string(JSON line GET "${json_content}" ${index})
      string(APPEND file_content "${line}\n")
    endforeach()
    file(WRITE "${file}" "${file_content}")

    set(${_RAPIDS_FILE_VAR} "${file}" PARENT_SCOPE)
  elseif(_RAPIDS_FROM_FILE_TO_JSON)
    # extract contents from `file`
    file(STRINGS "${${_RAPIDS_FILE_VAR}}" file_content)
    list(LENGTH file_content content_length)

    # Get the file extension
    cmake_path(GET ${_RAPIDS_FILE_VAR} EXTENSION LAST_ONLY patch_ext)
    string(SUBSTRING "${patch_ext}" 1 -1 patch_ext)

    # add each line as a json array element
    set(inline_patch [=[ [ ] ]=])
    foreach(line IN LISTS file_content)
      string(JSON inline_patch SET "${inline_patch}" ${content_length} "\"${line}\"")
    endforeach()

    set(json_content
        [=[{
      "type" : "",
      "content" : []
    }]=])
    string(JSON json_content SET "${json_content}" "type" "\"${patch_ext}\"")
    string(JSON json_content SET "${json_content}" "content" "${inline_patch}")
    set(${_RAPIDS_FROM_FILE_TO_JSON} "${json_content}" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "rapids_cpm_convert_patch_json unsupported mode: ${mode}")
  endif()

endfunction()
