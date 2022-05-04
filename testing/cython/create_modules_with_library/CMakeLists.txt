#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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

# TODO: For some reason I have to specify the minimum required cmake version
# before including init.cmake below even though none of them execute code.
# Without that ordering, I get an error when I call rapids_cython_init about
# CMP0057 violations, a policy that was introduced in 3.3. Why does it matter
# at include time instead of at run time? I assume it has something to do with
# state saved when the macro in init.cmake is defined because UseCython.cmake
# is only actually loaded when rapids_cython_init is called.

include(${rapids-cmake-dir}/cython/create_modules.cmake)
cmake_minimum_required(VERSION 3.20)
include(${rapids-cmake-dir}/cython/init.cmake)

project(rapids_cython-create_modules LANGUAGES C CXX)

# TODO: Is there any way to handle setting SKBUILD and the CMAKE_MODULE_PATH
# using a general macro defined in testing/cython/CMakeLists.txt to wrap all
# tests?
# Silence warning about running without scikit-build.
set(SKBUILD ON)

# Ensure that scikit-build's CMake files are discoverable. The glob is to
# capture the current git commit hash.
file(GLOB skbuild_resource_dir LIST_DIRECTORIES ON "${CPM_SOURCE_CACHE}/skbuild/*/skbuild/resources/cmake")
LIST(APPEND CMAKE_MODULE_PATH "${skbuild_resource_dir}")

rapids_cython_init()

# TODO: This whole file only exists because we cannot create multiple global
# targets with the same name, so this can't go into ths same test as the other
# create_modules. I don't want to modify the rapids_cython_create_modules
# function to accept a different module name just for testing though. Is there
# another alternative?
# Test that we can specify a (fake) library.
add_library(rapids_cython_test_library test)
rapids_cython_create_modules(
    SOURCE_FILES test.pyx
    LINKED_LIBRARIES rapids_cython_test_library
    )
