#=============================================================================
# Copyright (c) 2023-2025, NVIDIA CORPORATION.
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
include(${rapids-cmake-dir}/export/export.cmake)

cmake_minimum_required(VERSION 3.20)
project(fake LANGUAGES CXX VERSION 3.1.4)

add_library(fakeLib INTERFACE)
install(TARGETS fakeLib EXPORT fake_set)

add_library(fakeLib_c1 INTERFACE)
install(TARGETS fakeLib_c1 EXPORT fake_set_c1)

add_library(fakeLib_c2 INTERFACE)
install(TARGETS fakeLib_c2 EXPORT fake_set_c2-exports)

rapids_export(BUILD fake
              EXPORT_SET fake_set
              COMPONENTS c1 c2
              COMPONENTS_EXPORT_SET fake_set_c1 fake_set_c2-exports
              NAMESPACE test::)

# Add a custom command that generates a second project that verifies our component targets are
# exported correctly
file(WRITE "${CMAKE_BINARY_DIR}/verify-1/CMakeLists.txt"
     [=[
cmake_minimum_required(VERSION 3.20)
project(verify_build_targets LANGUAGES CXX)

set(components c1 c2)
set(nice_names c1-set c2-set)
foreach(comp nice_name IN ZIP_LISTS components nice_names)
  include("${CMAKE_CURRENT_LIST_DIR}/../fake-${nice_name}-targets.cmake")
  if(NOT TARGET test::fakeLib_${comp})
    message(FATAL_ERROR "rapids_export failed to generate correct component target of test::fakeLib_${comp}")
  endif()
endforeach()
]=])

add_custom_target(verify_target_component_files ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/verify-1/build"
                  COMMAND ${CMAKE_COMMAND} -S="${CMAKE_BINARY_DIR}/verify-1"
                          -B="${CMAKE_BINARY_DIR}/verify-1/build")

# Add a custom command that generates a second project that verifies our component aren't brought in
# with `find_package()`
file(WRITE "${CMAKE_BINARY_DIR}/verify-2/CMakeLists.txt"
     [=[
cmake_minimum_required(VERSION 3.20)
project(verify_build_targets LANGUAGES CXX)

set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../)
find_package(fake REQUIRED)
if(TARGET test::fakeLib_c1 OR TARGET test::fakeLib_c2)
  message(FATAL_ERROR "incorrectly included generated components without COMPONENTS keyword to `find_package`")
endif()
]=])

add_custom_target(verify_target_find_package ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/verify-2/build"
                  COMMAND ${CMAKE_COMMAND} -S="${CMAKE_BINARY_DIR}/verify-2"
                          -B="${CMAKE_BINARY_DIR}/verify-2/build")

# Add a custom command that generates a second project that verifies our component are brought in
# with `find_package(COMPONENTS)`
file(WRITE "${CMAKE_BINARY_DIR}/verify-3/CMakeLists.txt"
     [=[
cmake_minimum_required(VERSION 3.20)
project(verify_build_targets LANGUAGES CXX)

set(CMAKE_PREFIX_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../)
find_package(fake COMPONENTS c1 c2 REQUIRED)
if(NOT (TARGET test::fakeLib_c1 AND TARGET test::fakeLib_c2))
  message(FATAL_ERROR "find_package(COMPONENTS) failed to bring in components")
endif()
]=])

add_custom_target(verify_target_find_components ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/verify-3/build"
                  COMMAND ${CMAKE_COMMAND} -S="${CMAKE_BINARY_DIR}/verify-3"
                          -B="${CMAKE_BINARY_DIR}/verify-3/build")
