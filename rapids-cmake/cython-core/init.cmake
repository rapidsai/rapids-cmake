# =============================================================================
# Copyright (c) 2022-2023, NVIDIA CORPORATION.
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

#[=======================================================================[.rst:
rapids_cython_init
------------------

.. versionadded:: v22.06.00

Perform standard initialization of any CMake build using scikit-build to create Python extension modules with Cython.

.. code-block:: cmake

  rapids_cython_init()

.. note::
  Use of the rapids-cython component of rapids-cmake requires scikit-build. The behavior of the functions provided by
  this component is undefined if they are invoked outside of a build managed by scikit-build.

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
      message(WARNING "rapids-cython expects scikit-build to be active before being used. \
          The SKBUILD variable is not currently set, indicating that scikit-build \
          is not active, so builds may behave unexpectedly.")
    else()
      # Access the variable to avoid unused variable warnings."
      message(TRACE "Accessing SKBUILD variable ${SKBUILD}")
    endif()

    find_package(Python COMPONENTS Interpreter Development.Module REQUIRED)

    # TODO: Once we're happy with how this is behaving, start vendoring the file instead to decouple
    # from my repo until it's moved upstream to scikit-build.
    if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/CYTHON_CMAKE.cmake)
      file(DOWNLOAD https://raw.githubusercontent.com/vyasr/cython-cmake/main/CYTHON_CMAKE.cmake
           ${CMAKE_CURRENT_BINARY_DIR}/CYTHON_CMAKE.cmake)
    endif()
    include(${CMAKE_CURRENT_BINARY_DIR}/CYTHON_CMAKE.cmake)

    find_package(cython REQUIRED)

    # Flag
    set(RAPIDS_CYTHON_INITIALIZED TRUE)
  endif()
endmacro()
