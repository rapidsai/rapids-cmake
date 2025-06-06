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
include(${rapids-cmake-dir}/cmake/write_version_file.cmake)
include(${rapids-cmake-testing-dir}/utils/check_copyright_header.cmake)

cmake_minimum_required(VERSION 3.30.4)

project(DEMO VERSION 3.2.0 LANGUAGES NONE)
rapids_cmake_write_version_file(demo_version.hpp)

project(NESTED VERSION 3.14.159 LANGUAGES NONE)
rapids_cmake_write_version_file(nested_version.hpp)

enable_language(CXX)
add_executable(write_version main.cpp)
target_include_directories(write_version PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
target_compile_features(write_version PRIVATE cxx_std_14)

check_copyright_header("${CMAKE_CURRENT_BINARY_DIR}/demo_version.hpp")
check_copyright_header("${CMAKE_CURRENT_BINARY_DIR}/nested_version.hpp")
