# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/check_conda_env.cmake)

# Fails configure when CONDA_PREFIX changes
set(ENV{CONDA_PREFIX} "/opt/conda/prefix-a")
rapids_cmake_check_conda_env()
set(ENV{CONDA_PREFIX} "/opt/conda/prefix-b")
rapids_cmake_check_conda_env()
