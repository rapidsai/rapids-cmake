#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021-2024, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================

include(${rapids-cmake-dir}/export/write_language.cmake)

add_subdirectory(../C C)

add_library(B STATIC static.cu)
