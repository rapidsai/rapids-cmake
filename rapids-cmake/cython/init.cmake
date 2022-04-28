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

#[=======================================================================[.rst:
rapids_cython_init
------------------

.. versionadded:: v22.06.00

Perform standard initialization of any CMake build using scikit-build to create Python extension modules with Cython.

.. code-block:: cmake

  rapids_cython_init()

TODO: Should the cache variable be documented differently from the normal one?

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`RAPIDS_CYTHON_INITIALIZED` will be set to TRUE.
  :cmake:variable:`CYTHON_FLAGS` will be set to a standard set of a flags to pass to the command line cython invocation.

#]=======================================================================]
macro(rapids_cython_init)
  # Verify that we are using scikit-build.
  if (NOT DEFINED SKBUILD)
    message(FATAL_ERROR "rapids-cython must be used with scikit-build")
  endif()

  # TODO: Do we want to use rapids_find_package here? It's a little odd because
  # they aren't independent packages, they are part of scikit-build, so I don't
  # know if tracking them as dependencies for an export set really makes sense.
  find_package(PythonExtensions REQUIRED)
  find_package(Cython REQUIRED)
  
  # Set standard Cython directives that all RAPIDS projects should use in compilation.
  set(CYTHON_FLAGS
      "--directive binding=True,embedsignature=True,always_allow_keywords=True"
      CACHE STRING "The directives for Cython compilation.")

  # Flag
  set(RAPIDS_CYTHON_INITIALIZED TRUE)
endmacro()

#[=======================================================================[.rst:
rapids_cython_verify_init
-------------------------

.. versionadded:: v22.06.00

Simple helper function for rapids-cython components to verify that rapids_cython_init has been called before they proceed.

.. code-block:: cmake

  rapids_cython_verify_init()

#]=======================================================================]
function(rapids_cython_verify_init)
  if (NOT DEFINED RAPIDS_CYTHON_INITIALIZED)
    message(FATAL_ERROR "You must call rapids_cython_init before calling this function")
  endif()
endfunction()
