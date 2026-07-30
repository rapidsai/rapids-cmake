# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================
add_cmake_config_test(rapids_cmake-multiple-cpm NO_RAPIDS_CMAKE_HOOKS)
add_cmake_config_test(rapids_cmake-multiple-simple NO_RAPIDS_CMAKE_HOOKS)

add_cmake_config_test(rapids_cmake-fetch-via-git NO_RAPIDS_CMAKE_HOOKS EXPECT_MATCH
                      "Fetching rapids-cmake from https://github\\.com/rapidsai/rapids-cmake/@main")
add_cmake_config_test(rapids_cmake-fetch-via-zip
                      NO_RAPIDS_CMAKE_HOOKS
                      EXPECT_MATCH
                      "Fetching rapids-cmake from https://github\\.com/rapidsai/rapids-cmake/archive/refs/heads/main\\.zip"
)

add_cmake_config_test(FetchContent-legacy NO_RAPIDS_CMAKE_HOOKS)
add_cmake_config_test(FetchContent-hostile-legacy NO_RAPIDS_CMAKE_HOOKS)
