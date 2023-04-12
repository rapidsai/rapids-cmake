#=============================================================================
# Copyright (c) 2022-2023, NVIDIA CORPORATION.
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
rapids_test_install_relocatable
-------------------------------

.. versionadded:: v23.04.00

Install the needed `ctest` infrastructure to allow installed tests to be run
by `ctest` in parallel with GPU awareness.

  .. code-block:: cmake

    rapids_test_install_relocatable(INSTALL_COMPONENT_SET <component>
                                    DESTINATION <relative_path>
                                    [INCLUDE_IN_ALL])

Will install all tests created by :cmake:command:`rapids_test_add` that are
part of the provided ``INSTALL_COMPONENT_SET``.

The :cmake:command:`rapids_test_install_relocatable` presumes that all
arguments provided to the tests are machine independent (no absolute paths).

``INSTALL_COMPONENT_SET``
  Record which test component infrastructure to be installed

``DESTINATION``
  Relative path from the `CMAKE_INSTALL_PREFIX` to install the infrastructure.
  This needs to be the same directory as the test executables

``INCLUDE_IN_ALL``
  State that these install rules should be part of the default install set.
  By default tests are not part of the default install set.

#]=======================================================================]
function(rapids_test_install_relocatable)
  list(APPEND CMAKE_MESSAGE_CONTEXT "rapids.test.install_relocatable")

  set(options INCLUDE_IN_ALL)
  set(one_value INSTALL_COMPONENT_SET DESTINATION)
  set(multi_value)
  cmake_parse_arguments(_RAPIDS_TEST "${options}" "${one_value}" "${multi_value}" ${ARGN})

  set(to_exclude EXCLUDE_FROM_ALL)
  if(_RAPIDS_TEST_INCLUDE_IN_ALL)
    set(to_exclude)
  endif()

  set(component ${_RAPIDS_TEST_INSTALL_COMPONENT_SET})
  if(NOT TARGET rapids_test_install_${component})
    message(FATAL_ERROR "No install component set [${component}] can be found")
  endif()

  get_target_property(targets_to_install rapids_test_install_${component} TARGETS_TO_INSTALL)
  get_target_property(tests_to_run rapids_test_install_${component} TESTS_TO_RUN)

  include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/default_names.cmake)
  set(content
      "
  set(CTEST_SCRIPT_DIRECTORY \".\")
  set(CTEST_RESOURCE_SPEC_FILE \"./${rapids_test_json_file_name}\")
  execute_process(COMMAND ./${rapids_test_generate_exe_name} OUTPUT_FILE \"\${CTEST_RESOURCE_SPEC_FILE}\")
  ")

  foreach(test IN LISTS tests_to_run)
    get_test_property(${test} INSTALL_COMMAND command)
    get_test_property(${test} RESOURCE_GROUPS resources)
    get_test_property(${test} LABELS labels)
    string(APPEND content "add_test([=[${test}]=] ${command})\n")
    if(resources)
      string(APPEND content
             "set_tests_properties([=[${test}]=] PROPERTIES RESOURCE_GROUPS ${resources})\n")
    endif()
    if(labels)
      string(APPEND content "set_tests_properties([=[${test}]=] PROPERTIES LABELS ${labels})\n")
    endif()
  endforeach()

  set(test_launcher_file
      "${CMAKE_CURRENT_BINARY_DIR}/rapids-cmake/${_RAPIDS_TEST_INSTALL_COMPONENT_SET}/CTestTestfile.cmake.to_install"
  )
  file(WRITE "${test_launcher_file}" "${content}")
  install(FILES "${test_launcher_file}"
          COMPONENT ${_RAPIDS_TEST_INSTALL_COMPONENT_SET}
          DESTINATION ${_RAPIDS_TEST_DESTINATION}
          RENAME "CTestTestfile.cmake"
          ${to_exclude})

  # We need to install the rapids-test gpu detector, and the json script we also need to write out /
  # install the new CTestTestfile.cmake
  if(EXISTS "${PROJECT_BINARY_DIR}/rapids-cmake/${rapids_test_generate_exe_name}")
    install(PROGRAMS "${PROJECT_BINARY_DIR}/rapids-cmake/${rapids_test_generate_exe_name}"
            COMPONENT ${_RAPIDS_TEST_INSTALL_COMPONENT_SET} DESTINATION ${_RAPIDS_TEST_DESTINATION}
            ${to_exclude})
  endif()
  if(EXISTS "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/run_gpu_test.cmake")
    install(FILES "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/detail/run_gpu_test.cmake"
            COMPONENT ${_RAPIDS_TEST_INSTALL_COMPONENT_SET} DESTINATION ${_RAPIDS_TEST_DESTINATION}
            ${to_exclude})
  endif()
  if(targets_to_install)
    install(TARGETS ${targets_to_install} COMPONENT ${_RAPIDS_TEST_INSTALL_COMPONENT_SET}
            DESTINATION ${_RAPIDS_TEST_DESTINATION} ${to_exclude})
  endif()
endfunction()
