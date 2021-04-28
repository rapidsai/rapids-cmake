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
rapids_cmake_make_global
-----------------------

.. versionadded:: 0.20

 If a target is imported via `find_package` or `CPM` make it global so
 everything can reference it no-matter where it was imported

.. command:: rapids_cmake_make_global

  .. code-block:: cmake

    rapids_cmake_make_global(target_var)

  ``target_var``
      Holds the variable that lists all targets that should be promoted to
      GLOBAL scope

#]=======================================================================]
function(rapids_cmake_make_global target_var)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.cmake.make_global")
  foreach(target IN LISTS ${target_var})
    if(TARGET ${target})
      get_target_property(aliased_target ${target} ALIASED_TARGET)
      if(aliased_target)
        continue()
      endif()
      get_target_property(is_imported ${target} IMPORTED)
      get_target_property(already_global ${target} IMPORTED_GLOBAL)
      if(is_imported AND NOT already_global)
        set_target_properties(${target} PROPERTIES IMPORTED_GLOBAL TRUE)
      endif()
    endif()
  endforeach()
endfunction()
