# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
#
# RAPIDS detected something use requested a file to be called after `project()`, so chain call them.
if(DEFINED _RAPIDS_PREVIOUS_CMAKE_PROJECT_INCLUDE)
  include("${_RAPIDS_PREVIOUS_CMAKE_PROJECT_INCLUDE}")
endif()
#
# Used by rapids_cuda_init_architectures to allow the `project()` call to invoke the
# rapids_cuda_set_architectures function after compiler detection
#
rapids_cuda_set_architectures(NATIVE)
