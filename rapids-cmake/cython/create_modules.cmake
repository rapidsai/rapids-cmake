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

include(${CMAKE_CURRENT_LIST_DIR}/detail/verify_init.cmake)

#[=======================================================================[.rst:
rapids_cython_create_modules
---------------------

.. versionadded:: v22.06.00

Generate C(++) from Cython and create Python modules.

.. code-block:: cmake

  rapids_cython_create_modules(<ModuleName...>)

Creates a Cython target for a module, then adds a corresponding Python
extension module.

.. note::
  Requires :cmake:command:`rapids_cython_init` to be called before usage.

``CXX``
  Flag indicating that the Cython files need to generate C++ rather than C.

``EXTENSION_MODULES``
  The list of Python extension modules to build.

``LINKED_LIBRARIES``
  The list of libraries that need to be linked into all modules. In RAPIDS,
  this list usually contains (at minimum) the corresponding C++ libraries.

``INSTALL_ROOT``
  The source directory of the project. This directory is used to compute the
  relative install path, which is necessary to propertly support differently
  configured installations such as installing in place vs. out of place.

#]=======================================================================]
function(rapids_cython_create_modules)
  rapids_cython_verify_init()
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cython.create_modules")

  set(_rapids_cython_options CXX)
  set(_rapids_cython_one_value INSTALL_ROOT)
  set(_rapids_cython_multi_value EXTENSION_MODULES LINKED_LIBRARIES)
  cmake_parse_arguments(RAPIDS_CYTHON "${_rapids_cython_options}" "${_rapids_cython_one_value}"
                        "${_rapids_cython_multi_value}" ${ARGN})

  set(language "C")
  if (RAPIDS_CYTHON_CXX)
    set(language "CXX")
  endif()

  foreach(cython_module IN LISTS RAPIDS_CYTHON_EXTENSION_MODULES)
    add_cython_target(${cython_module} ${language} PY3)
    add_library(${cython_module} MODULE ${cython_module})
    python_extension_module(${cython_module})

    # To avoid libraries being prefixed with "lib".
    set_target_properties(${cython_module} PROPERTIES PREFIX "")
    if(DEFINED ${RAPIDS_CYTHON_LINKED_LIBRARIES})
        target_link_libraries(${cython_module} PUBLIC ${RAPIDS_CYTHON_LINKED_LIBRARIES})
    endif()

    # Compute the install directory relative to the source and rely on installs being relative to
    # the CMAKE_PREFIX_PATH for e.g. editable installs.
    cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${RAPIDS_CYTHON_INSTALL_ROOT}
               OUTPUT_VARIABLE install_dst)
    install(TARGETS ${cython_module} DESTINATION ${install_dst})
  endforeach()
endfunction()
