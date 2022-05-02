# =============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
# =============================================================================

include_guard(GLOBAL)

# TODO: What is the correct way to get this path inside the macro below? If there isn't one, is
# there a different solution that would be more appropriate?
set(RAPIDS_CYTHON_PATH)
# cmake-lint: disable=E1126
file(REAL_PATH "${CMAKE_CURRENT_LIST_DIR}" RAPIDS_CYTHON_PATH)
# TODO: cmake-lint doesn't like the above line. I think it's because it doesn't recognize the
# REAL_PATH form of `file` and doesn't realize that it selects a specific form of the `file`
# command, but I could be misunderstanding the issue.

#[=======================================================================[.rst:
rapids_cython_init
------------------

.. versionadded:: v22.06.00

Perform standard initialization of any CMake build using scikit-build to create Python extension modules with Cython.

.. code-block:: cmake

  rapids_cython_init()

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`RAPIDS_CYTHON_INITIALIZED` will be set to TRUE.
  :cmake:variable:`CYTHON_FLAGS` will be set to a standard set of a flags to pass to the command line cython invocation.

#]=======================================================================]
macro(rapids_cython_init)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cython.init")
  # Only initialize once.
  if(NOT DEFINED RAPIDS_CYTHON_INITIALIZED)
    # Verify that we are using scikit-build.
    if(NOT DEFINED SKBUILD)
      message(FATAL_ERROR "rapids-cython must be used with scikit-build")
    endif()

    # Incorporate scikit-build patches.
    include("${RAPIDS_CYTHON_PATH}/detail/skbuild_patches.cmake")

    find_package(PythonExtensions REQUIRED)
    find_package(Cython REQUIRED)

    # Set standard Cython directives that all RAPIDS projects should use in compilation.
    if(NOT DEFINED CYTHON_FLAGS)
      set(CYTHON_FLAGS "--directive binding=True,embedsignature=True,always_allow_keywords=True")
    endif()

    # Flag
    set(RAPIDS_CYTHON_INITIALIZED TRUE)
  endif()
endmacro()
