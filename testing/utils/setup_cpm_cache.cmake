#=============================================================================
# Copyright (c) 2021-2025, NVIDIA CORPORATION.
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

function(setup_cpm_cache)
  set(CPM_SOURCE_CACHE "${CMAKE_BINARY_DIR}")
  cmake_path(APPEND_STRING CPM_SOURCE_CACHE "/cache")

  set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/CPM.cmake")

  set(src_dir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/fill_cache/")
  set(build_dir "${CPM_SOURCE_CACHE}")

  # download all pre-configured rapids-cmake packages
  execute_process(COMMAND ${CMAKE_COMMAND} -Drapids-cmake-dir=${PROJECT_SOURCE_DIR}/../rapids-cmake
                          -S ${src_dir} -B ${build_dir} -DCPM_SOURCE_CACHE=${CPM_SOURCE_CACHE}
                          -DCPM_DOWNLOAD_LOCATION=${CPM_DOWNLOAD_LOCATION}
                  WORKING_DIRECTORY ${src_dir}
                  OUTPUT_VARIABLE out_var)
  # Find the line in out_var that contains "CPM packages in cache
  set(packages)
  foreach(line IN LISTS out_var)
    if("${line}" MATCHES "CPM packages in cache: {(.*)}")
      string(REPLACE ", " ";" packages "${CMAKE_MATCH_1}")
    endif()
  endforeach()

  set(PACKAGES_IN_CPM_CACHE ${packages} PARENT_SCOPE)
  set(CPM_SOURCE_CACHE "${CPM_SOURCE_CACHE}" PARENT_SCOPE)
  set(CPM_DOWNLOAD_LOCATION "${CPM_DOWNLOAD_LOCATION}" PARENT_SCOPE)
endfunction()
