# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

# When running under rapids-cmake testing infrastructure, rapids-cmake-dir is already set and we
# should use the local version instead of downloading RAPIDS.cmake
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
include(rapids-export)
include(rapids-find)

project(find_generate_module_example VERSION 1.0 LANGUAGES CXX)

rapids_cmake_build_type(Release)

# ##################################################################################################
# WHY use rapids_find_generate_module?
# ##################################################################################################
#
# Problem: Your library depends on a third-party package (e.g., "SimpleLib") that: 1. Doesn't
# provide a CMake config file (simplelib-config.cmake) 2. Doesn't have a standard
# FindSimpleLib.cmake module
#
# Solution: Generate a FindSimpleLib.cmake module that: 1. Searches for the package's headers and
# libraries 2. Creates proper CMake targets 3. Is INSTALLED with your package so downstream users
# can find SimpleLib too
#
# why: - Without this, downstream projects can't use find_package(YourPackage) because they can't
# find SimpleLib - The generated FindModule is included in your package's export sets - Downstream
# projects automatically get the FindModule when they find_package(YourPackage)
#
# ##################################################################################################

# For this example, we'll use ZLIB which DOES have a FindModule, but we'll pretend it doesn't to
# demonstrate the pattern.

# STEP 1: Generate the FindModule
# ================================
# This creates FindMyZLIB.cmake and adds it to export sets
rapids_find_generate_module(MyZLIB
                            HEADER_NAMES zlib.h # Required: headers to search for
                            LIBRARY_NAMES z # Optional: libraries to search for
                            INCLUDE_SUFFIXES include # Optional: extra search paths
                            BUILD_EXPORT_SET example_exports # Add to build export
                            INSTALL_EXPORT_SET example_exports # Add to install export
)

# STEP 2: Find the package using the generated module
# ====================================================
# This uses the FindMyZLIB.cmake we just generated
rapids_find_package(MyZLIB REQUIRED BUILD_EXPORT_SET example_exports
                    INSTALL_EXPORT_SET example_exports)

# STEP 3: Create your library that uses the dependency
# =====================================================
add_library(example_lib lib.cpp)

set_target_properties(example_lib
                      PROPERTIES CXX_STANDARD 17
                                 CXX_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON
                                 VERSION ${PROJECT_VERSION}
                                 SOVERSION ${PROJECT_VERSION_MAJOR})

# Link against the found package
target_link_libraries(example_lib PUBLIC MyZLIB::MyZLIB)

# STEP 4: Install the library and headers
# ========================================
include(GNUInstallDirs)

install(TARGETS example_lib EXPORT example_exports LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

# STEP 5: Export the package (FindMyZLIB.cmake is automatically included!)
# =========================================================================
set(doc_string
    [=[
Provide targets for the find_generate_module_example library.

This example demonstrates why rapids_find_generate_module is important:

The example_lib library depends on MyZLIB. When downstream projects call:
  find_package(find_generate_module_example)

They automatically get:
1. The FindMyZLIB.cmake module (installed with this package)
2. Ability to find MyZLIB using the generated module
3. Proper transitive dependencies set up

WITHOUT rapids_find_generate_module:
- Downstream projects would fail to configure
- They couldn't find MyZLIB dependency
- No way to use example_lib

WITH rapids_find_generate_module:
- FindMyZLIB.cmake is installed alongside your package config
- Downstream projects automatically find MyZLIB
- Everything "just works"
]=])

# Create install export (FindMyZLIB.cmake is included in export set)
rapids_export(INSTALL find_generate_module_example
              EXPORT_SET example_exports
              GLOBAL_TARGETS example_lib
              NAMESPACE example::
              DOCUMENTATION doc_string)

# Create build export
rapids_export(BUILD find_generate_module_example EXPORT_SET example_exports
              GLOBAL_TARGETS example_lib NAMESPACE example::)
