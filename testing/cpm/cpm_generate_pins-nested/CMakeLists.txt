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

add_subdirectory(a)
add_subdirectory(b)

# Turn on pin generation after cpm dependencies have been added
# to make sure it is order invariant
include(${rapids-cmake-dir}/cpm/init.cmake)
rapids_cpm_init(GENERATE_PINNED_VERSIONS)

# don't check cuco here as it uses hashes and that breaks our verify script
set(projects-to-verify rmm fmt spdlog CCCL)
add_custom_target(verify_generated_pins ALL
  COMMAND ${CMAKE_COMMAND} -S="${CMAKE_SOURCE_DIR}/verify/" -B"${CMAKE_BINARY_DIR}/verify_build"
  -D"rapids-cmake-dir=${rapids-cmake-dir}"
  -D"projects-to-verify=${projects-to-verify}"
)
