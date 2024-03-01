#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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
cmake_minimum_required(VERSION 3.23.1)
project(rapids-test-project LANGUAGES CXX)

include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/package_override.cmake)
include(${rapids-cmake-dir}/cpm/detail/package_details.cmake)

rapids_cpm_init()

set(projects rmm fmt spdlog CCCL cuco)
# Get the baseline before the override is added
foreach(proj IN LISTS ${projects})
  rapids_cpm_package_details(${proj} ${proj}_version ${proj}_repository ${proj}_tag ${proj}_shallow ${proj}_exclude)
endforeach()


file(READ "${CMAKE_CURRENT_BINARY_DIR}/../rapids-cmake/pinned_versions.json" json_data)

# Verify that the pinned_versions is valid json by using it
rapids_cpm_package_override("${CMAKE_CURRENT_BINARY_DIR}/../rapids-cmake/pinned_versions.json")

foreach(proj IN LISTS ${projects})
  # Verify that each git_tag is now different.
  rapids_cpm_package_details(${proj} ${proj}_version ${proj}_repository pin_${proj}_tag ${proj}_shallow ${proj}_exclude)
  if(pin_${proj}_tag STREQUAL ${proj}_tag)
    message(FATAL_ERROR "pinned ${proj} tag (${pin_${proj}_tag}) should differ compared to baseline ${${proj}_tag}")
  endif()

  # Everything should have shallow marked as false
  # so that clones by SHA1 work
  if(${proj}_shallow)
    message(FATAL_ERROR "${proj}_shallow} is expected to be false, but got ${${proj}_shallow}")
  endif()
endforeach()
