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

#[=======================================================================[.rst:
rapids_export_cpm
-----------------

.. versionadded:: v21.06.00

Record a given <PackageName> found by `CPMFindPackage` is required for a
given export set

.. code-block:: cmake

  rapids_export_cpm( (build|install)
                      <PackageName>
                      <ExportSet>
                      CPM_ARGS <standard cpm args>
                      [GLOBAL_TARGETS <targets...>]
                      )


Records a given <PackageName> found by `CPMFindPackage` is required for a
given export set.

This means that when :cmake:command:`rapids_export` or
`:cmake:command:`rapids_export_write_dependencies` is called the `CPMFindPackage`
call will be replicated for consumers.

.. note::
  It is an anti-pattern to use this command with `INSTALL` as most CMake
  based projects should be installed, and :cmake:command:`rapids_export_package(INSTALL` used
  to find it. Only use :cmake:command:`rapids_export_cpm(INSTALL` when the above pattern
  doesn't work for some reason.

#]=======================================================================]
function(rapids_export_cpm type name export_set)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.cpm")

  string(TOLOWER ${type} type)

  set(options "")
  set(one_value EXPORT_SET)
  set(multi_value GLOBAL_TARGETS CPM_ARGS)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})

  #Export out the build-dir incase it has build directory find-package support
  if(type STREQUAL build)
    set(build_dir "${${name}_BINARY_DIR}")
  endif()

  configure_file(
    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/template/cpm.cmake.in"
    "${CMAKE_BINARY_DIR}/rapids-cmake/${export_set}/${type}/${name}.cmake"
    @ONLY)

  if(NOT TARGET rapids_export_${type}_${export_set} )
    add_library(rapids_export_${type}_${export_set} INTERFACE)
  endif()

  #Record that we need CPM injected into the export set
  set_property(TARGET rapids_export_${type}_${export_set}
               PROPERTY "REQUIRES_CPM" TRUE)

  #Need to record the <PackageName> to `rapids_export_${type}_${export_set}`
  set_property(TARGET rapids_export_${type}_${export_set}
               APPEND
               PROPERTY "PACKAGE_NAMES" "${name}")

  if(RAPIDS_GLOBAL_TARGETS)
    #record our targets that need to be marked as global when imported
    target_link_libraries(rapids_export_${type}_${export_set} INTERFACE ${RAPIDS_GLOBAL_TARGETS})
  endif()

endfunction()
