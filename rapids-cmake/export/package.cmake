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
rapids_export_package
---------------------

.. versionadded:: v21.06.00

Record a given <PackageName> found by :cmake:command:`find_package` is required for a
given export set

.. code-block:: cmake

  rapids_export_package( (build|install)
                         <PackageName>
                         <ExportSet>
                         [GLOBAL_TARGETS <targets...>]
                        )

Records a given <PackageName> found by :cmake:command:`find_package` is required for a
given export set.

This means that when :cmake:command:`rapids_export` or
`:cmake:command:`rapids_export_write_dependencies` is called a
:cmake:command:`find_dependency` call will be replicated for consumers.

#]=======================================================================]
function(rapids_export_package type name export_set)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.package")

  string(TOLOWER ${type} type)

  set(options "")
  set(one_value EXPORT_SET)
  set(multi_value GLOBAL_TARGETS)
  cmake_parse_arguments(RAPIDS "${options}" "${one_value}" "${multi_value}" ${ARGN})


  if(NOT TARGET rapids_export_${type}_${export_set} )
    add_library(rapids_export_${type}_${export_set} INTERFACE)
  endif()

  # Don't remove duplicates here as that cost should only be paid
  # Once per export set. So that should occur in `write_dependencies`

  #Need to record the <PackageName> to `rapids_export_${type}_${export_set}`
  set_property(TARGET rapids_export_${type}_${export_set}
               APPEND
               PROPERTY "PACKAGE_NAMES" "${name}")

  if(RAPIDS_GLOBAL_TARGETS)
    #record our targets that need to be marked as global when imported
    target_link_libraries(rapids_export_${type}_${export_set} INTERFACE ${RAPIDS_GLOBAL_TARGETS})
  endif()

endfunction()
