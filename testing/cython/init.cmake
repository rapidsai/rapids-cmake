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
include(${rapids-cmake-dir}/cython/init.cmake)

# Ensure that scikit-build's CMake files are discoverable.
file(GLOB skbuild_resource_dir "${CPM_SOURCE_CACHE}/skbuild/*/skbuild/resources/cmake")
LIST(APPEND CMAKE_MODULE_PATH "${skbuild_resource_dir}")

# Test that rapids_cython_init initializes the expected variables.
rapids_cython_init()
if(NOT DEFINED RAPIDS_CYTHON_INITIALIZED)
  message(FATAL_ERROR "rapids_cython_init didn't correctly set RAPIDS_CYTHON_INITIALIZED")
endif()

STRING(REGEX MATCHALL ".*--directives.*" matches "${CYTHON_FLAGS}")
LIST(LENGTH matches num_directives)

if(NOT CYTHON_FLAGS OR NOT num_directives EQUAL 1)
  message(FATAL_ERROR "rapids_cython_init didn't correctly set CYTHON_FLAGS")
endif()

if(NOT COMMAND _set_python_extension_symbol_visibility)
  message(FATAL_ERROR "rapids_cython_init didn't create the _set_python_extension_symbol_visibility command")
endif()

# Test that rapids_cython_init is idempotent.
rapids_cython_init()
STRING(REGEX MATCHALL ".*--directives.*" matches "${CYTHON_FLAGS}")
LIST(LENGTH matches num_directives)

if(NOT num_directives EQUAL 1)
  message(FATAL_ERROR "rapids_cython_init is not idempotent, num_directives = ${num_directives}")
endif()
