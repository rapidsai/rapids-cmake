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
include(${rapids-cmake-dir}/find/package.cmake)

# =============================================================================
# Copyright (c) 2021-2025, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
# =============================================================================
include(${rapids-cmake-dir}/find/package.cmake)

rapids_find_package(CUDAToolkit 11 REQUIRED INSTALL_EXPORT_SET test_export_set
                    BUILD_EXPORT_SET test_export_set)

set(to_match_string "find_package(CUDAToolkit 11 QUIET)")

set(path "${CMAKE_BINARY_DIR}/rapids-cmake/test_export_set/build/package_CUDAToolkit.cmake")
file(READ "${path}" contents)
string(FIND "${contents}" "${to_match_string}" is_found)
if(is_found EQUAL -1)
  message(FATAL_ERROR "rapids_find_package(BUILD) failed to preserve version information in exported file"
  )
endif()

set(path "${CMAKE_BINARY_DIR}/rapids-cmake/test_export_set/install/package_CUDAToolkit.cmake")
file(READ "${path}" contents)
string(FIND "${contents}" "${to_match_string}" is_found)
if(is_found EQUAL -1)
  message(FATAL_ERROR "rapids_find_package(INSTALL) failed to preserve version information in exported file"
  )
endif()
