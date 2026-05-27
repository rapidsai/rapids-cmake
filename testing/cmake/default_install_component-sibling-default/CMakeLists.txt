# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(default_install_component_sibling_default LANGUAGES NONE)

add_subdirectory(a_default_dependency)
add_subdirectory(b_default_dependency)

add_custom_target(check ALL
                  COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_BINARY_DIR}/install"
                  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --component
                          a_default_dependency --prefix
                          "${CMAKE_BINARY_DIR}/install/a_default_dependency"
                  COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --component
                          b_default_dependency --prefix
                          "${CMAKE_BINARY_DIR}/install/b_default_dependency"
                  COMMAND ${CMAKE_COMMAND} -Dinstall_dir="${CMAKE_BINARY_DIR}/install" -P
                          "${CMAKE_CURRENT_SOURCE_DIR}/check_installed_components.cmake")
