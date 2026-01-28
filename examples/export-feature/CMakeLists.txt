# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
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
include(rapids-cpm)
include(rapids-cuda)
include(rapids-export)
include(rapids-find)

rapids_cuda_init_architectures(export_example)

project(export_example VERSION 1.0 LANGUAGES CXX CUDA)

rapids_cmake_build_type(Release)

# Find CUDAToolkit and add to export sets
rapids_find_package(CUDAToolkit REQUIRED BUILD_EXPORT_SET export_example_targets
                    INSTALL_EXPORT_SET export_example_targets)

# Initialize CPM for dependency management
rapids_cpm_init()

# Find fmt using CPM and add to export sets
rapids_cpm_find(fmt 10.2.1
                GLOBAL_TARGETS fmt::fmt
                BUILD_EXPORT_SET export_example_targets
                INSTALL_EXPORT_SET export_example_targets
                CPM_ARGS GITHUB_REPOSITORY fmtlib/fmt
                GIT_TAG 10.2.1
                GIT_SHALLOW TRUE)

# Create a CUDA library
add_library(export_example SHARED lib.cu)

set_target_properties(export_example
                      PROPERTIES CXX_STANDARD 17
                                 CXX_STANDARD_REQUIRED ON
                                 CUDA_STANDARD 17
                                 CUDA_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON
                                 VERSION ${PROJECT_VERSION}
                                 SOVERSION ${PROJECT_VERSION_MAJOR})

# Link dependencies
target_link_libraries(export_example PUBLIC CUDA::cudart PRIVATE fmt::fmt)

# Installation rules
include(GNUInstallDirs)
install(TARGETS export_example
        EXPORT export_example_targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# Create and install the build export
rapids_export(BUILD export_example EXPORT_SET export_example_targets GLOBAL_TARGETS export_example
              NAMESPACE export_example::)

# Create and install the install export
set(doc_string [=[Provide targets for the export_example library.]=])

rapids_export(INSTALL export_example
              EXPORT_SET export_example_targets
              GLOBAL_TARGETS export_example
              NAMESPACE export_example::
              DOCUMENTATION doc_string)
