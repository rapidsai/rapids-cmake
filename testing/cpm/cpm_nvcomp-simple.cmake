# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/nvcomp.cmake)

rapids_cpm_init()

if(TARGET nvcomp::nvcomp)
  message(FATAL_ERROR "Expected nvcomp::nvcomp not to exist")
endif()

rapids_cpm_nvcomp(USE_PROPRIETARY_BINARY ON)

if(NOT nvcomp_proprietary_binary)
  message(FATAL_ERROR "Expected nvcomp_proprietary_binary to be set")
endif()

if(NOT TARGET nvcomp::nvcomp)
  message(FATAL_ERROR "Expected nvcomp::nvcomp target to exist")
endif()

# Make sure we can be called multiple times
rapids_cpm_nvcomp(USE_PROPRIETARY_BINARY ON)
