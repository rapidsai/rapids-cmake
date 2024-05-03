#=============================================================================
# Copyright (c) 2024, NVIDIA CORPORATION.
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

function(verify_generated_pins target_name)
  set(_rapids_options)
  set(_rapids_one_value PIN_FILE)
  set(_rapids_multi_value PROJECTS PROJECTS_NOT_EXIST)
  cmake_parse_arguments(_RAPIDS "${_rapids_options}" "${_rapids_one_value}"
                        "${_rapids_multi_value}" ${ARGN})

  if(NOT DEFINED _RAPIDS_PROJECTS)
    message(FATAL_ERROR "verify_generated_pins must be called with `PROJECTS` to verify")
  endif()
  if(NOT DEFINED _RAPIDS_PIN_FILE)
    set(_RAPIDS_PIN_FILE "${CMAKE_CURRENT_BINARY_DIR}/rapids-cmake/pinned_versions.json")
  endif()

  # only check projects that were downloaded by CPM (ignore those already in the build environment)
  foreach(proj IN LISTS _RAPIDS_PROJECTS)
    if(${proj}_SOURCE_DIR)
      list(APPEND projects-to-verify ${proj})
    endif()
  endforeach()

  add_custom_target(${target_name} ALL
    COMMAND ${CMAKE_COMMAND} -S="${CMAKE_CURRENT_FUNCTION_LIST_DIR}/verify_generated_pins/" -B"${CMAKE_BINARY_DIR}/${target_name}_verify_build"
    -D"rapids-cmake-dir=${rapids-cmake-dir}"
    -D"projects-to-verify=${projects-to-verify}"
    -D"projects-not-in-list=${_RAPIDS_PROJECTS_NOT_EXIST}"
    -D"pinned_versions_file=${_RAPIDS_PIN_FILE}"
  )

endfunction()
