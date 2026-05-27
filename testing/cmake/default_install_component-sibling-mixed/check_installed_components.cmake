# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

set(default_dependency_file "${install_dir}/default_dependency/dependencies/default_dependency.txt")
set(specified_dependency_file "${install_dir}/testing/dependencies/specified_dependency.txt")
set(project_name_unconfigured_file
    "${install_dir}/unconfigured_dependency/dependencies/unconfigured_dependency.txt")

if(NOT EXISTS "${default_dependency_file}")
  message(FATAL_ERROR "DefaultDependency did not install as component defaultdependency")
endif()
if(NOT EXISTS "${specified_dependency_file}")
  message(FATAL_ERROR "SpecifiedDependency did not install as component testing")
endif()
if(EXISTS "${project_name_unconfigured_file}")
  message(FATAL_ERROR "UnconfiguredDependency incorrectly installed as component UnconfiguredDependency"
  )
endif()
