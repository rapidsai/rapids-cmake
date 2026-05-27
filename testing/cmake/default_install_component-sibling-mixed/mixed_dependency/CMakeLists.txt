# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)
project(MixedDependency LANGUAGES NONE)

include(${rapids-cmake-dir}/cmake/default_install_component.cmake)

rapids_cmake_default_install_component(PROJECT SpecifiedDependency INSTALL_COMPONENT_NAME testing)

add_subdirectory(specified_dependency)
add_subdirectory(unconfigured_dependency)
