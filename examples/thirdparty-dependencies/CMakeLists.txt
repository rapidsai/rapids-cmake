# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

if(NOT DEFINED rapids-cmake-dir)
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/RAPIDS.cmake
         ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
  endif()
  set(rapids-cmake-branch main)
  include(${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
else()
  if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${rapids-cmake-dir}")
  endif()
endif()

include(rapids-cmake)
include(rapids-cpm)
include(rapids-export)

project(third-party_dependencies_example VERSION 1.0 LANGUAGES CXX)

rapids_cmake_build_type(Release)

rapids_cpm_init()

include(cmake/thirdparty/get_fmt.cmake)
include(cmake/thirdparty/get_spdlog.cmake)

add_library(third-party_example SHARED lib.cpp)

set_target_properties(third-party_example
                      PROPERTIES CXX_STANDARD 17
                                 CXX_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON
                                 VERSION ${PROJECT_VERSION}
                                 SOVERSION ${PROJECT_VERSION_MAJOR})

target_link_libraries(third-party_example PUBLIC fmt::fmt PRIVATE spdlog::spdlog)

add_executable(third-party_example_app main.cpp)
target_link_libraries(third-party_example_app PRIVATE third-party_example)

set_target_properties(third-party_example_app PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)

install(TARGETS third-party_example EXPORT third-party_exports
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

set(doc_string
    [=[
Provide targets for the third-party_dependencies_example library.
]=])

rapids_export(INSTALL third-party_dependencies_example
              EXPORT_SET third-party_exports
              GLOBAL_TARGETS third-party_example
              NAMESPACE third-party_example::
              DOCUMENTATION doc_string)

rapids_export(BUILD third-party_dependencies_example EXPORT_SET third-party_exports
              GLOBAL_TARGETS third-party_example NAMESPACE third-party_example::)
