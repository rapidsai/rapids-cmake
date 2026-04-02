# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

# cmake-format: off
# ##################################################################################################
# PROJECT BOOTSTRAP EXAMPLE
# ##################################################################################################
#
# This example demonstrates the standard RAPIDS PROJECT layout used by all RAPIDS projects (RMM,
# cuDF, cuVS, etc.)
#
# KEY FILES:
# - VERSION: Project version in YY.MM.PP format (e.g., 26.02.00)
# - RAPIDS_BRANCH: rapids-cmake branch name (e.g., main or release/26.02)
# - cmake/rapids_config.cmake: Reads VERSION/RAPIDS_BRANCH, sets variables
# - cmake/RAPIDS.cmake: Downloads rapids-cmake via FetchContent
#
# Test with a specific rapids-cmake commit SHA:
#       cmake -S . -B build -Drapids-cmake-sha=abc123def456
#
# Test with a fork of rapids-cmake:
#       cmake -S . -B build -Drapids-cmake-repo=myuser/rapids-cmake
#
# Test with local rapids-cmake (bypass download):
#       cmake -S . -B build -Drapids-cmake-dir=/path/to/rapids-cmake/rapids-cmake
#
# ##################################################################################################
# cmake-format: on
cmake_minimum_required(VERSION 3.30.4 FATAL_ERROR)

# Bootstrap rapids-cmake: This reads VERSION/RAPIDS_BRANCH and downloads rapids-cmake
include(cmake/rapids_config.cmake)

# Include rapids-cmake modules: After bootstrap, all rapids-cmake modules are available
include(rapids-cmake)
include(rapids-cuda)

# Initialize CUDA architectures (must be before project())
rapids_cuda_init_architectures(project_bootstrap_example)

# Define project using VERSION from rapids_config.cmake

# rapids-pre-commit-hooks: disable-next-line[verify-hardcoded-version]
project(project_bootstrap_example VERSION "${RAPIDS_VERSION}" # Set by rapids_config.cmake
        LANGUAGES CXX CUDA)

# Set default build type
rapids_cmake_build_type(Release)

# Display version information
message(STATUS "Project Version: ${PROJECT_VERSION}")
message(STATUS "  RAPIDS_VERSION_MAJOR: ${RAPIDS_VERSION_MAJOR}")
message(STATUS "  RAPIDS_VERSION_MINOR: ${RAPIDS_VERSION_MINOR}")
message(STATUS "  RAPIDS_VERSION_PATCH: ${RAPIDS_VERSION_PATCH}")
message(STATUS "rapids-cmake branch: ${rapids-cmake-branch}")
message(STATUS "rapids-cmake version: ${rapids-cmake-version}")

# Create a simple library to demonstrate the pattern
add_library(bootstrap_lib SHARED lib.cu)

set_target_properties(bootstrap_lib
                      PROPERTIES CXX_STANDARD 20
                                 CXX_STANDARD_REQUIRED ON
                                 CUDA_STANDARD 20
                                 CUDA_STANDARD_REQUIRED ON
                                 POSITION_INDEPENDENT_CODE ON
                                 VERSION ${PROJECT_VERSION}
                                 SOVERSION ${PROJECT_VERSION_MAJOR})

# Create an executable
add_executable(bootstrap_example main.cu)
target_link_libraries(bootstrap_example PRIVATE bootstrap_lib)

set_target_properties(bootstrap_example PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED ON
                                                   CUDA_STANDARD 20 CUDA_STANDARD_REQUIRED ON)
