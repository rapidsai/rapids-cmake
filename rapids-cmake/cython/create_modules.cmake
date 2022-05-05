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

#[=======================================================================[.rst:
rapids_cython_create_modules
----------------------------

.. versionadded:: v22.06.00

Generate C(++) from Cython and create Python modules.

.. code-block:: cmake

  rapids_cython_create_modules([CXX] [SOURCE_FILES <src1> <src2> ...] [LINKED_LIBRARIES <lib1> <lib2> ... ]  [INSTALL_DIR <install_path> )

Creates a Cython target for a module, then adds a corresponding Python
extension module.

.. note::
  Requires :cmake:command:`rapids_cython_init` to be called before usage.

``CXX``
  Flag indicating that the Cython files need to generate C++ rather than C.

``SOURCE_FILES``
  The list of Cython source files to be built into Python extension modules.
  Note that this function assumes that Cython source files have a one-one
  correspondence with extension modules to build, i.e. for every `<Name>.pyx`
  in SOURCE_FILES we assume that `<Name>.pyx` is a Cython source file for which
  an extension module `<Name>` should be built.

``LINKED_LIBRARIES``
  The list of libraries that need to be linked into all modules. In RAPIDS,
  this list usually contains (at minimum) the corresponding C++ libraries.

``INSTALL_DIR``
  The path relative to the installation prefix so that it can be converted to
  an absolute path in a relocatable way. If not provided, defaults to the path
  to CMAKE_CURRENT_SOURCE_DIR relative to PROJECT_SOURCE_DIR.

#]=======================================================================]
function(rapids_cython_create_modules)
  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/verify_init.cmake)
  rapids_cython_verify_init()

  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cython.create_modules")

  set(_rapids_cython_options CXX)
  set(_rapids_cython_one_value INSTALL_DIR)
  set(_rapids_cython_multi_value SOURCE_FILES LINKED_LIBRARIES)
  cmake_parse_arguments(RAPIDS_CYTHON "${_rapids_cython_options}" "${_rapids_cython_one_value}"
                        "${_rapids_cython_multi_value}" ${ARGN})

  set(language "C")
  if(RAPIDS_CYTHON_CXX)
    set(language "CXX")
  endif()

  foreach(cython_filename IN LISTS RAPIDS_CYTHON_SOURCE_FILES)
    # Generate a reasonable module name.
    cmake_path(GET cython_filename FILENAME cython_module)
    cmake_path(REMOVE_EXTENSION cython_module)

    add_cython_target(${cython_module} "${cython_filename}" ${language} PY3 OUTPUT_VAR
                      cythonized_file)
    add_library(${cython_module} MODULE ${cythonized_file})
    python_extension_module(${cython_module})

    # To avoid libraries being prefixed with "lib".
    set_target_properties(${cython_module} PROPERTIES PREFIX "")
    if(DEFINED RAPIDS_CYTHON_LINKED_LIBRARIES)
      target_link_libraries(${cython_module} ${RAPIDS_CYTHON_LINKED_LIBRARIES})
    endif()

    # Compute the install directory relative to the source and rely on installs being relative to
    # the CMAKE_PREFIX_PATH for e.g. editable installs.
    if(NOT DEFINED RAPIDS_CYTHON_INSTALL_DIR)
      cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY "${PROJECT_SOURCE_DIR}"
                 OUTPUT_VARIABLE RAPIDS_CYTHON_INSTALL_DIR)
    endif()
    install(TARGETS ${cython_module} DESTINATION ${RAPIDS_CYTHON_INSTALL_DIR})
  endforeach()
endfunction()
