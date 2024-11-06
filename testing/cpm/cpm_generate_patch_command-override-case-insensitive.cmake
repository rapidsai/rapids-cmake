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
cmake_minimum_required(VERSION 3.26.4)
project(rapids-cpm_find-patch-command-project LANGUAGES CXX)


# Need to write out an override file
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
  [=[
{
  "packages": {
    "gtest": {
      "patches": [
        {
          "file": "${current_json_dir}/patches/0001-move-git-sha1.patch",
          "issue": "Move git sha1",
          "fixed_in": ""
        }
      ]
    }
  }
}
  ]=])

include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")
rapids_cpm_package_details(GTest version repository tag shallow exclude)

include(${rapids-cmake-dir}/cpm/init.cmake)
rapids_cpm_init(OVERRIDE ${CMAKE_CURRENT_BINARY_DIR}/override.json)

include("${rapids-cmake-dir}/cpm/detail/generate_patch_command.cmake")
rapids_cpm_generate_patch_command(GTest ${version} patch_command)
message(STATUS "patch_command: ${patch_command}")
if(NOT patch_command)
  message(FATAL_ERROR "rapids_cpm_package_override failed to load patch step for `GTest` from package `gtest`")
endif()

# Need to load ${build_dir}/rapids-cmake/patches/GTest/patch.cmake
# and verify that the `files` variable has properly resolved `current_json_dir`
set(patch_script "${CMAKE_BINARY_DIR}/rapids-cmake/patches/GTest/patch.cmake")
include("${patch_script}")
if(files STREQUAL "/patches/0001-move-git-sha1.patch")
  message(FATAL_ERROR "rapids_cpm_package_override failed to properly expand 'current_json_dir'")
endif()
