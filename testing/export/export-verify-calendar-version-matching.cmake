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

project(test LANGUAGES CXX VERSION 21.09.03)

add_library(fakeLib INTERFACE)
install(TARGETS fakeLib EXPORT fake_set)

rapids_export(BUILD test EXPORT_SET fake_set LANGUAGES CXX)

# Verify that build files have correct names
if(NOT EXISTS "${CMAKE_BINARY_DIR}/test-config.cmake")
  message(FATAL_ERROR "rapids_export failed to generate correct config file name")
endif()

set(CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})
find_package(test 21.09.01 REQUIRED)

message(STATUS "TEST_VERSION ${TEST_VERSION}")
message(STATUS "TEST_VERSION_VALUES ${TEST_VERSION_MAJOR}.${TEST_VERSION_MINOR}")

if(NOT TEST_VERSION VERSION_EQUAL 21.09.03)
  message(FATAL_ERROR "rapids_export failed to export version information")
endif()

if(NOT "${TEST_VERSION_MAJOR}.${TEST_VERSION_MINOR}" VERSION_EQUAL 21.09)
  message(FATAL_ERROR "rapids_export failed to export version major/minor information")
endif()
