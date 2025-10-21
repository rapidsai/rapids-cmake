#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021-2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include_guard(GLOBAL)

include(utils/cmake_test.cmake)

function(add_cmake_ctest_test source_or_dir)
  add_cmake_test(TEST "${source_or_dir}" ${ARGN})
endfunction()
