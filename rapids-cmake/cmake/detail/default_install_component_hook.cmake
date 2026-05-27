# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

string(TOLOWER ${PROJECT_NAME} project)

get_property(_rapids_install_default_name GLOBAL
             PROPERTY rapids_cmake_default_install_component_names)
get_property(_rapids_install_project_name GLOBAL PROPERTY rapids_cmake_install_component_${project})

if(_rapids_install_project_name)
  set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${_rapids_install_project_name}")
elseif(_rapids_install_default_name)
  set(CMAKE_INSTALL_DEFAULT_COMPONENT_NAME "${project}")
endif()
