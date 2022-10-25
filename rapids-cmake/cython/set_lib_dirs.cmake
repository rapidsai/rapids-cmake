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
rapids_cython_set_lib_dirs
--------------------------

.. versionadded:: v22.12.00

Set the directories where any dependent libraries will be placed.

.. code-block:: cmake

  rapids_cython_set_lib_dirs(<dir1> <dir2> ...)

The relative path to the provided directories is appended to the rpath of any
library built using rapids_cython_create_modules within the current project.

.. note::
  Requires :cmake:command:`rapids_cython_init` to be called before usage.

Result Variables
^^^^^^^^^^^^^^^^
  :cmake:variable:`RAPIDS_CYTHON_<ProjectName>_LIB_DIRS` will be set to the list of
  directories provided to this function, where ProjectName is the name given to the
  most recent :cmake:command:`project <cmake:command:project>` call.

#]=======================================================================]
function(rapids_cython_set_lib_dirs)
  # Note that this function may be called safely before rapids-cython is initialized.
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cython.set_lib_dirs")

  # Need to convert all paths to absolute so that the later relative path conversions work.
  set(_abs_lib_dirs)
  foreach(_lib_dir IN LISTS ARGV)
    cmake_path(ABSOLUTE_PATH _lib_dir)
    list(APPEND _abs_lib_dirs ${_lib_dir})
  endforeach()
  set(RAPIDS_CYTHON_${PROJECT_NAME}_LIB_DIRS "${_abs_lib_dirs}" PARENT_SCOPE)
endfunction()
