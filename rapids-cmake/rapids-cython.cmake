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
include_guard(GLOBAL)

find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)

# TODO: Verify that the scopes of the below variables (CYTHON_FLAGS,
# ignored_variable) are suitable for the way that they're being used.

# Set standard Cython directives that all RAPIDS projects should use in compilation.
set(CYTHON_FLAGS
    "--directive binding=True,embedsignature=True,always_allow_keywords=True"
    CACHE STRING "The directives for Cython compilation.")

# Ignore unused variable warning.
set(ignored_variable "${SKBUILD}" PARENT_SCOPE)

include(${CMAKE_CURRENT_LIST_DIR}/cython/skbuild_patches.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cython/create_cython_modules.cmake)
