# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)
include(${rapids-cmake-dir}/cpm/libcoro.cmake)

rapids_cpm_init()

if(TARGET libcoro::libcoro)
  message(FATAL_ERROR "Expected libcoro::libcoro not to exist")
endif()

set(BUILD_SHARED_LIBS ON)

rapids_cpm_libcoro()

if(NOT TARGET libcoro::libcoro)
  message(FATAL_ERROR "Expected libcoro::libcoro to exist")
endif()

if(NOT BUILD_SHARED_LIBS)
  message(FATAL_ERROR "BUILD_SHARED_LIBS was corrupted by rapids_cpm_libcoro")
endif()

# Idempotency: second call must not error
rapids_cpm_libcoro()
