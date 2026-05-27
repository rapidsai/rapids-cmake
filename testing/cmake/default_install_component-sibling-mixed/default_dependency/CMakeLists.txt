# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
cmake_minimum_required(VERSION 4.0)

include(${rapids-cmake-dir}/cmake/default_install_component.cmake)

rapids_cmake_default_install_component(DEFAULT_USE_PROJECT_NAME)

project(DefaultDependency LANGUAGES NONE)

install(FILES default_dependency.txt DESTINATION dependencies)
