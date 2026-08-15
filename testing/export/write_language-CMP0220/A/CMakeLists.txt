# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
include(${rapids-cmake-dir}/export/write_language.cmake)

set(path "${CMAKE_CURRENT_BINARY_DIR}/enable_cuda.cmake")
rapids_export_write_language(BUILD CUDA "${path}")

include(${path})

add_library(A STATIC static.cu)
