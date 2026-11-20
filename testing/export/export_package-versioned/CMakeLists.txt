# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(export_package-versioned LANGUAGES NONE)

include(${rapids-cmake-dir}/export/package.cmake)
include(${rapids-cmake-dir}/export/write_dependencies.cmake)
include(CMakePackageConfigHelpers)

foreach(type IN ITEMS BUILD INSTALL)
  foreach(with_components IN ITEMS OFF ON)
    foreach(scenario IN ITEMS matching unversioned incompatible missing missing-component)
      if(scenario STREQUAL missing-component AND NOT with_components)
        continue()
      endif()
      foreach(required IN ITEMS OFF ON)
        foreach(quiet IN ITEMS OFF ON)
          set(case "${type}-${with_components}-${scenario}-${required}-${quiet}")
          set(case_dir "${CMAKE_CURRENT_BINARY_DIR}/${case}")
          set(package_dir "${case_dir}/parent")
          set(dependency_dir "${case_dir}/dependency")
          file(MAKE_DIRECTORY "${package_dir}" "${dependency_dir}")

          set(components)
          if(with_components)
            set(components COMPONENTS first second)
          endif()
          if(type STREQUAL BUILD)
            set(Dependency_DIR "${dependency_dir}")
          endif()
          rapids_export_package(${type} Dependency "${case}" VERSION 1.0 ${components})
          unset(Dependency_DIR)
          rapids_export_write_dependencies(${type} "${case}" "${package_dir}/ParentConfig.cmake")

          if(NOT scenario STREQUAL missing)
            configure_file(dependency.cmake.in "${dependency_dir}/DependencyConfig.cmake" @ONLY)
            if(NOT scenario STREQUAL unversioned)
              set(version 1.0)
              if(scenario STREQUAL incompatible)
                set(version 2.0)
              endif()
              write_basic_package_version_file("${dependency_dir}/DependencyConfigVersion.cmake"
                                               VERSION ${version} COMPATIBILITY ExactVersion)
            endif()
          endif()

          set(prefix_path "${package_dir};${dependency_dir}")
          execute_process(COMMAND ${CMAKE_COMMAND} -S "${CMAKE_CURRENT_SOURCE_DIR}/consumer" -B
                                  "${case_dir}/consumer" "-DCMAKE_PREFIX_PATH=${prefix_path}"
                                  "-Drequired=${required}" "-Dquiet=${quiet}"
                                  "-Dscenario=${scenario}" "-Dwith_components=${with_components}"
                          RESULT_VARIABLE result
                          OUTPUT_VARIABLE output
                          ERROR_VARIABLE error)

          if(required AND scenario MATCHES "^missing")
            if(result EQUAL 0 OR NOT "${output}${error}" MATCHES "Dependency")
              message(FATAL_ERROR "${case}: expected a required dependency failure:\n${output}${error}"
              )
            endif()
          elseif(NOT result EQUAL 0)
            message(FATAL_ERROR "${case}: consumer failed:\n${output}${error}")
          endif()

          set(calls)
          if(EXISTS "${case_dir}/consumer/calls.txt")
            file(STRINGS "${case_dir}/consumer/calls.txt" calls)
          endif()
          set(expected_calls 1)
          if(scenario STREQUAL missing)
            set(expected_calls 0)
          elseif(scenario STREQUAL missing-component)
            set(expected_calls 2)
          endif()
          list(LENGTH calls call_count)
          if(NOT call_count EQUAL expected_calls)
            message(FATAL_ERROR "${case}: expected ${expected_calls} config executions, got ${call_count}"
            )
          endif()
          if(quiet AND "${output}${error}" MATCHES "dependency status message")
            message(FATAL_ERROR "${case}: QUIET was not propagated")
          endif()
        endforeach()
      endforeach()
    endforeach()
  endforeach()
endforeach()
