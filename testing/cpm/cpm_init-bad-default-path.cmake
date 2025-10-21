#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2024, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cpm/init.cmake)

rapids_cpm_init(CUSTOM_DEFAULT_VERSION_FILE ${CMAKE_CURRENT_LIST_DIR}/bad_path.cmake)
