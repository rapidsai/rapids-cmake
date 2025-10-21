#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/find/generate_module.cmake)

rapids_find_generate_module(RapidsTest HEADER_NAMES rapids-cmake-test-header_only.hpp
                                                    INITIAL_CODE_BLOCK var_doesn't_exist
                            INSTALL_EXPORT_SET test_set)
