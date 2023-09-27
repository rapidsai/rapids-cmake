#=============================================================================
# Copyright (c) 2023, NVIDIA CORPORATION.
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
rapids_export_post_find_package_code
------------------------------------

.. versionadded:: v23.12.00

Record for <PackageName> a set of CMake instructions to be executed after the package
has ben found successfully.

.. code-block:: cmake

  rapids_export_post_find_package_code((BUILD|INSTALL)
                                       <PackageName>
                                       <code>
                                       <ExportSet>
                                        )

When using complicated find modules like `Thrust` you might need to run some code after
execution. Multiple calls to :cmake:command:`rapids_export_post_find_package_code` will append the
instructions to execute in call order.

.. note:
  The code will only be run if the package was found

``BUILD``
  Record code to be executed immediately after `PackageName` has been found
  for our our build directory export set.

``INSTALL``
  Record code to be executed immediately after `PackageName` has been found
  for our our install directory export set.

#]=======================================================================]
function(rapids_export_post_find_package_code type name code export_set)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.export.post_find_package_code")

  string(TOLOWER ${type} type)

  if(NOT TARGET rapids_export_${type}_${export_set})
    add_library(rapids_export_${type}_${export_set} INTERFACE)
  endif()

  # if the code coming in is a list of string we will have `;`, so transform those to "\n" so we
  # have a single string
  string(REPLACE ";" "\n" code "${code}")
  set_property(TARGET rapids_export_${type}_${export_set} APPEND_STRING
               PROPERTY "${name}_POST_FIND_CODE" "${code}\n")
endfunction()
