# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cmake/check_conda_env.cmake)

# Do nothing when not in a conda environment
unset(ENV{CONDA_PREFIX})
unset(rapids_conda_prefix CACHE)
rapids_cmake_check_conda_env()
if(DEFINED rapids_conda_prefix)
  message(FATAL_ERROR "rapids_cmake_check_conda_env should not record a value when CONDA_PREFIX is unset"
  )
endif()

# Records CONDA_PREFIX on the first call from within a conda environment
set(ENV{CONDA_PREFIX} "/opt/conda/prefix-a")
rapids_cmake_check_conda_env()
if(NOT rapids_conda_prefix STREQUAL "/opt/conda/prefix-a")
  message(FATAL_ERROR "rapids_cmake_check_conda_env recorded '${rapids_conda_prefix}', but we expected '/opt/conda/prefix-a'"
  )
endif()

# Do nothing when CONDA_PREFIX is unchanged
rapids_cmake_check_conda_env()
if(NOT rapids_conda_prefix STREQUAL "/opt/conda/prefix-a")
  message(FATAL_ERROR "rapids_cmake_check_conda_env changed the recorded value to '${rapids_conda_prefix}' on an unchanged re-call"
  )
endif()
