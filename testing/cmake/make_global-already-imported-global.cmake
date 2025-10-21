#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cmake/make_global.cmake)

add_library(test_lib UNKNOWN IMPORTED GLOBAL)

set(targets test_lib)
rapids_cmake_make_global(targets)
