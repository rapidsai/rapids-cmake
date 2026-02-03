# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

# ##################################################################################################
# VERSION HEADER EXAMPLE
# ##################################################################################################
#
# This example demonstrates rapids_cmake_write_version_file() which generates C++ header files
# containing version information from your CMake project.
#
# WHY THIS IS IMPORTANT: - Runtime version checking: Applications can verify library versions at
# runtime - Version display: Libraries can report their version (e.g., mylib::version()) -
# Compatibility checks: Downstream projects can verify version requirements - Debug information:
# Version info appears in logs, error messages, etc.
#
# USED BY ALL RAPIDS PROJECTS: - RMM: include/rmm/version_config.hpp - cuDF:
# include/cudf/version_config.hpp - cuVS: include/cuvs/version_config.h
#
# WORKFLOW: 1. VERSION file contains project version (YY.MM.PP format) 2. project() command reads
# version from VERSION file 3. rapids_cmake_write_version_file() generates C++ header with version
# macros 4. C++ code includes the header and accesses version information
#
# ##################################################################################################

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

# When running under rapids-cmake testing infrastructure, rapids-cmake-dir is already set
if(NOT DEFINED rapids-cmake-dir)
  if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/main/RAPIDS.cmake
         ${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
  endif()
  set(rapids-cmake-branch main)
  include(${CMAKE_CURRENT_BINARY_DIR}/RAPIDS.cmake)
else()
  # Test mode: Set up CMAKE_MODULE_PATH to use local rapids-cmake
  if(NOT "${rapids-cmake-dir}" IN_LIST CMAKE_MODULE_PATH)
    list(APPEND CMAKE_MODULE_PATH "${rapids-cmake-dir}")
  endif()
endif()

include(rapids-cmake)

# Read VERSION file to get project version
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" _version_contents)
if(_version_contents MATCHES [[^([0-9]+)\.([0-9]+)\.([0-9]+)]])
  set(_VERSION_MAJOR "${CMAKE_MATCH_1}")
  set(_VERSION_MINOR "${CMAKE_MATCH_2}")
  set(_VERSION_PATCH "${CMAKE_MATCH_3}")
  set(_VERSION "${_VERSION_MAJOR}.${_VERSION_MINOR}.${_VERSION_PATCH}")
else()
  message(FATAL_ERROR "Failed to parse VERSION file")
endif()

# STEP 1: Define project with version The VERSION is parsed into PROJECT_VERSION_MAJOR,
# PROJECT_VERSION_MINOR, PROJECT_VERSION_PATCH
project(version_header_example VERSION ${_VERSION} LANGUAGES CXX)

rapids_cmake_build_type(Release)

# Display version information that will be in the generated header
message(STATUS "Project Version: ${PROJECT_VERSION}")
message(STATUS "  Major: ${PROJECT_VERSION_MAJOR}")
message(STATUS "  Minor: ${PROJECT_VERSION_MINOR}")
message(STATUS "  Patch: ${PROJECT_VERSION_PATCH}")

# STEP 2: Generate version header file This creates a C++ header with version macros based on
# project() VERSION
#
# Generated file will contain: #define version_header_example_VERSION_MAJOR 26 #define
# version_header_example_VERSION_MINOR 2 #define version_header_example_VERSION_PATCH 0
#
# MACRO NAMING: Uses lowercase project name with underscores (not uppercase) - Project
# "version_header_example" → "version_header_example_VERSION_MAJOR" - Project "MyLib" →
# "MyLib_VERSION_MAJOR"
#
rapids_cmake_write_version_file(include/version_example/version_config.hpp)

message(STATUS "Generated version header: ${CMAKE_CURRENT_BINARY_DIR}/include/version_example/version_config.hpp"
)

# STEP 3: Create a library that uses the version header
add_library(version_example SHARED lib.cpp)

set_target_properties(version_example
                      PROPERTIES CXX_STANDARD 17
                                 CXX_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON
                                 VERSION ${PROJECT_VERSION}
                                 SOVERSION ${PROJECT_VERSION_MAJOR})

# Include directories for both build and install
target_include_directories(version_example
                           PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                  "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>"
                           INTERFACE "$<INSTALL_INTERFACE:include>")

# STEP 4: Create an executable that prints version information
add_executable(version_example_app main.cpp)
target_link_libraries(version_example_app PRIVATE version_example)

set_target_properties(version_example_app PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)

# STEP 5: Install the library and the generated header
include(GNUInstallDirs)

install(TARGETS version_example LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

# Install public headers
install(DIRECTORY include/version_example DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} FILES_MATCHING
        PATTERN "*.hpp")

# Install the generated version header
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/version_example/version_config.hpp
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/version_example)

# ##################################################################################################
# USAGE NOTES
# ##################################################################################################
#
# The generated header can be used in C++ code:
#
# #include <version_example/version_config.hpp>
#
# int major = version_header_example_VERSION_MAJOR; int minor =
# version_header_example_VERSION_MINOR;
#
# MACRO NAMING CONVENTION: - Macros use the PROJECT NAME as-is (preserves case and underscores) -
# Project "version_header_example" → "version_header_example_VERSION_MAJOR" - Project "MyProject" →
# "MyProject_VERSION_MAJOR" - Macros: <project_name>_VERSION_MAJOR, <project_name>_VERSION_MINOR,
# etc.
#
# BEST PRACTICES: - Always install the generated version header alongside your library - Provide a
# version() function that returns version as a string - Include version in library error messages
# and logs - Use version for compatibility checks in downstream projects
#
# ##################################################################################################
