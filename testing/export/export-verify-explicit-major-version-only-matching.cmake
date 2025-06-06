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
include(${rapids-cmake-dir}/export/cpm.cmake)
include(${rapids-cmake-dir}/export/export.cmake)

project(test LANGUAGES CXX VERSION 4.2.1)

add_library(fakeLib INTERFACE)
install(TARGETS fakeLib EXPORT fake_set)

rapids_export(BUILD test VERSION 4 EXPORT_SET fake_set LANGUAGES CXX)

# Verify that build files have correct names
if(NOT EXISTS "${CMAKE_BINARY_DIR}/test-config.cmake")
  message(FATAL_ERROR "rapids_export failed to generate correct config file name")
endif()

# Verify that the version.cmake file exists with an explicit version arg
if(NOT EXISTS "${CMAKE_BINARY_DIR}/test-config-version.cmake")
  message(FATAL_ERROR "rapids_export failed to generate a version file")
endif()

set(CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})
find_package(test 4.0 REQUIRED)

if(NOT TEST_VERSION STREQUAL "4")
  message(FATAL_ERROR "rapids_export failed to export version information")
endif()

if(NOT TEST_VERSION_MAJOR STREQUAL "4")
  message(FATAL_ERROR "rapids_export failed to export major version value")
endif()

if(DEFINED TEST_VERSION_MINOR)
  message(FATAL_ERROR "rapids_export incorrectly generated a minor version value")
endif()

if(DEFINED TEST_VERSION_PATCH)
  message(FATAL_ERROR "rapids_export incorrectly generated a patch version value")
endif()
