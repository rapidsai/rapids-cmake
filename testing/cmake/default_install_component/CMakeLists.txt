# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(default_install_component LANGUAGES NONE)

include(${rapids-cmake-dir}/cmake/default_install_component.cmake)

rapids_cmake_default_install_component(DEFAULT_USE_PROJECT_NAME)
rapids_cmake_default_install_component(PROJECT TestingDependency INSTALL_COMPONENT_NAME testing)

add_subdirectory(default_dependency)
add_subdirectory(testing_dependency)

add_custom_target(check ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/install"
                  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --component
                          DefaultDependency --prefix
                          "${CMAKE_BINARY_DIR}/install/default_dependency"
                  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --component testing
                          --prefix "${CMAKE_BINARY_DIR}/install/testing"
                  COMMAND ${CMAKE_COMMAND} -Dinstall_dir="${CMAKE_BINARY_DIR}/install" -P
                          "${CMAKE_CURRENT_SOURCE_DIR}/check_installed_components.cmake")
