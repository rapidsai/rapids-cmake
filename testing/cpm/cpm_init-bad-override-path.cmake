#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)

rapids_cpm_init(OVERRIDE ${CMAKE_CURRENT_LIST_DIR}/bad_path.cmake)
