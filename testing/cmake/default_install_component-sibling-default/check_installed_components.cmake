# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

set(a_default_dependency_file
    "${install_dir}/a_default_dependency/dependencies/a_default_dependency.txt")
set(b_default_dependency_file
    "${install_dir}/b_default_dependency/dependencies/b_default_dependency.txt")

if(NOT EXISTS "${a_default_dependency_file}")
  message(FATAL_ERROR "a_default_dependency did not install as component a_default_dependency")
endif()
if(NOT EXISTS "${b_default_dependency_file}")
  message(FATAL_ERROR "b_default_dependency did not install as component b_default_dependency")
endif()
