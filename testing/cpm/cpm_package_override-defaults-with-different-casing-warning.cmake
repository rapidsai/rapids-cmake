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
# rapids-cmake will output as `AUTHOR_WARNING` so we need to hijack
# message to verify we see output we expect
set(rmm_string "RAPIDS-CMake is assuming the override rMm is meant for the rmm package")
set(gtest_string "RAPIDS-CMake is assuming the override gtest is meant for the GTest package")

function(message mode content )
  if(mode STREQUAL "AUTHOR_WARNING")
    if(content MATCHES "${rmm_string}")
      message(STATUS "==rmm warned==")
      set_property(GLOBAL PROPERTY rapids_cmake_rmm_warned TRUE)
    elseif(content MATCHES "${gtest_string}")
      message(STATUS "==gtest warned==")
      set_property(GLOBAL PROPERTY rapids_cmake_gtest_warned TRUE)
    endif()
  else()
    _message(${ARGV})
  endif()
endfunction()

include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/package_override.cmake)

rapids_cpm_init()

# Need to write out an override file
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
  [=[
{
  "packages": {
    "rMm": {
      "git_url": "new_rmm_url",
      "git_shallow": "OFF",
      "exclude_from_all": "ON"
    },
    "gtest": {
      "version": "3.00.A1"
    }
  }
}
  ]=])

rapids_cpm_package_override(${CMAKE_CURRENT_BINARY_DIR}/override.json)
include("${rapids-cmake-dir}/cpm/detail/package_details.cmake")

# Verify that we got our warnings
get_property(rmm_warned GLOBAL PROPERTY rapids_cmake_rmm_warned)
get_property(gtest_warned GLOBAL PROPERTY rapids_cmake_gtest_warned)
if(NOT rmm_warned)
  message(FATAL_ERROR "Failed to warn about improper rmm casing")
endif()
if(NOT gtest_warned)
  message(FATAL_ERROR "Failed to warn about improper gtest casing")
endif()
