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
add_cmake_build_test
--------------------

generate a CMake tests given either a single CMake file or a directory.

.. versionadded:: v21.06.00

.. command:: add_cmake_build_test

  .. code-block:: cmake

    add_cmake_build_test( (config|build|run|install)
                          <SourceOrDir>
                        )

    ``config``
      Generate a CMake project and runs CMake config and generate
      step. Expects the test to raise an error to mark failures

    ``build``
      Generate and build a CMake project. The CMake config and generate
      step is constructed as a setup fixture.
      Expects the test to either raise an error during config, or fail
      to build to mark failures

    ``install``
      - Not implemented

#]=======================================================================]
function(add_cmake_test mode source_or_dir)
  string(TOLOWER ${mode} mode)
  cmake_path(GET source_or_dir STEM test_name)

  # Determine if we are past a relative source file or a directory
  set(have_source_dir FALSE)
  if(IS_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${source_or_dir}")
    set(src_dir "${CMAKE_CURRENT_LIST_DIR}/${source_or_dir}/")
  elseif(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${source_or_dir}")
    set(src_dir "${CMAKE_CURRENT_BINARY_DIR}/${test_name}")
    set(test_cmake_file "${CMAKE_CURRENT_LIST_DIR}/${source_or_dir}")
    configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/project_template.cmake.in"
                   "${src_dir}/CMakeLists.txt" @ONLY)
  else()
    message(FATAL_ERROR "Unable to find a file or directory named: ${source_or_dir}")
  endif()


  set(build_dir "${CMAKE_CURRENT_BINARY_DIR}/${test_name}-build")

  if(mode STREQUAL "config")
    add_test(NAME ${test_name}
             COMMAND ${CMAKE_COMMAND}
             -S ${src_dir} -B ${build_dir}
             -G ${CMAKE_GENERATOR}
             -Drapids-cmake-testing-dir=${PROJECT_SOURCE_DIR}
             -Drapids-cmake-dir=${PROJECT_SOURCE_DIR}/../rapids-cmake)
  elseif(mode STREQUAL "build")
    add_test(NAME ${test_name}_configure
             COMMAND ${CMAKE_COMMAND}
             -S ${src_dir} -B ${build_dir}
             -G ${CMAKE_GENERATOR}
             -Drapids-cmake-testing-dir=${PROJECT_SOURCE_DIR}
             -Drapids-cmake-dir=${PROJECT_SOURCE_DIR}/../rapids-cmake)

    add_test(NAME ${test_name}
             COMMAND ${CMAKE_COMMAND}
             --build ${build_dir} -j3 )

    set_tests_properties(${test_name}_configure PROPERTIES FIXTURES_SETUP ${test_name})
    set_tests_properties(${test_name} PROPERTIES FIXTURES_REQUIRED ${test_name})


  elseif(mode STREQUAL "install")
    message(FATAL_ERROR "install mode not yet implemented by add_cmake_build_test")
  else()
    message(FATAL_ERROR "${mode} mode not one of the valid modes (config|build|install) by add_cmake_build_test")
  endif()

  # Apply a label to the test based on the folder it is in
  get_filename_component(label_name ${CMAKE_CURRENT_LIST_DIR} NAME_WE)
  string(TOLOWER "${label_name}" lower_case_label )
  set_tests_properties(${test_name} PROPERTIES LABELS ${lower_case_label})

endfunction()
