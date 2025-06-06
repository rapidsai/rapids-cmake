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
cmake_minimum_required(VERSION 3.30.4)
project(rapids-cpm_find-build-patch-project LANGUAGES CXX)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/modules)

include(${rapids-cmake-dir}/cpm/init.cmake)
rapids_cpm_init()

include(${rapids-cmake-dir}/cpm/package_override.cmake)
rapids_cpm_package_override(${CMAKE_CURRENT_SOURCE_DIR}/override.json)

include(${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake)
rapids_cpm_generate_patch_command(test_pkg 1.0 patch_command build_patch_only)
if(NOT patch_command)
  message(FATAL_ERROR "rapids_cpm_generate_patch_command() did not return a patch command")
endif()
if(NOT build_patch_only STREQUAL "BUILD_PATCH_ONLY")
  message(FATAL_ERROR "rapids_cpm_generate_patch_command() did not return BUILD_PATCH_ONLY")
endif()

include(${rapids-cmake-dir}/cpm/find.cmake)
rapids_cpm_find(test_pkg 1.0 ${build_patch_only} CPM_ARGS ${patch_command})

if(NOT TARGET test_pkg::lib)
  message(FATAL_ERROR "test_pkg was not found by our find-module")
endif()
