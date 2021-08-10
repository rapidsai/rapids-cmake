#=============================================================================
# Copyright (c) 2018-2021, NVIDIA CORPORATION.
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

#[=======================================================================[.rst:
rapids_export_write_dependencies
--------------------------------

.. versionadded:: v21.06.00

.. code-block:: cmake

Creates a self-containted file that searches for all dependencies for a given
export set.

  rapids_export_write_dependencies( (BUILD|INSTALL) <export_set> <file_path> )

Generates a self-contained file that will search for all dependencies of
a given export_set for the requested mode.

``BUILD``
  Will generate calls for all build directory export set

``INSTALL``
  Will generate calls for all install directory export set

.. note::
  It is better to use :cmake:command:`rapids_export` as it generates a complete
  CMake config module.

#]=======================================================================]
function(rapids_export_write_dependencies type export_set file_path)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.write_dependencies")

  string(TOLOWER ${type} type)

  if(NOT TARGET rapids_export_${type}_${export_set})
    return()
  endif()

  # Determine if we need have any `FindModules` that we need to package.
  get_property(find_modules TARGET rapids_export_${type}_${export_set}
               PROPERTY "FIND_PACKAGES_TO_INSTALL")
  list(REMOVE_DUPLICATES find_modules)

  # Determine if we need to inject CPM hooks
  get_property(uses_cpm TARGET rapids_export_${type}_${export_set} PROPERTY "REQUIRES_CPM")
  list(REMOVE_DUPLICATES uses_cpm)

  # Collect all `find_dependency` calls. Order is important here As this is the order they are
  # recorded which is the implied valid search order
  get_property(deps TARGET rapids_export_${type}_${export_set} PROPERTY "PACKAGE_NAMES")
  list(REMOVE_DUPLICATES deps)

  # Do we need a Template header?
  set(RAPIDS_EXPORT_CONTENTS)
  if(uses_cpm)
    file(READ "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../cpm/init.cmake" cpm_logic)
    string(APPEND RAPIDS_EXPORT_CONTENTS ${cpm_logic})
    string(APPEND RAPIDS_EXPORT_CONTENTS "rapids_cpm_init()\n\n")

    if(type STREQUAL build)
      string(APPEND
             RAPIDS_EXPORT_CONTENTS
             "# re-use our CPM source cache if not set
if(NOT DEFINED CPM_SOURCE_CACHE)
  set(CPM_SOURCE_CACHE \"@CPM_SOURCE_CACHE@\")
  set(rapids_clear_cpm_cache true)
endif()\n")
    endif()
  endif()

  if(find_modules)
    cmake_path(GET file_path PARENT_PATH find_module_dest)
    file(COPY ${find_modules} DESTINATION "${find_module_dest}")

    string(APPEND RAPIDS_EXPORT_CONTENTS
           [=[list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")]=] "\n")
  endif()

  foreach(dep IN LISTS deps)
    if(EXISTS "${CMAKE_BINARY_DIR}/rapids-cmake/${export_set}/${type}/${dep}.cmake")
      # We need inject the contents of this generated file into the file we are writing out. That
      # way users can re-locate/install the file and it will still work
      file(READ "${CMAKE_BINARY_DIR}/rapids-cmake/${export_set}/${type}/${dep}.cmake" dep_content)
    else()
      set(dep_content "find_dependency(${dep})")
    endif()

    string(APPEND RAPIDS_EXPORT_CONTENTS "${dep_content}\n")
  endforeach()
  string(APPEND RAPIDS_EXPORT_CONTENTS "\n")

  # Handle promotion to global targets
  get_property(global_targets TARGET rapids_export_${type}_${export_set} PROPERTY "GLOBAL_TARGETS")
  list(REMOVE_DUPLICATES global_targets)

  string(APPEND RAPIDS_EXPORT_CONTENTS "set(rapids_global_targets ${global_targets})\n")

  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/dependencies.cmake.in" "${file_path}"
                 @ONLY)
endfunction()
