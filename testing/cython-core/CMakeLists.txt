#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2023-2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================

add_cmake_config_test(rapids-cython-core.cmake)

add_cmake_config_test(cython-core_init.cmake)
add_cmake_config_test(cython-core_create_modules_errors.cmake SHOULD_FAIL
                      "You must call rapids_cython_init before calling this function")

add_cmake_build_test(cython-core_create_modules)
add_cmake_config_test(cython-core_create_modules_with_library)
add_cmake_config_test(cython-core_create_modules_with_prefix)
add_cmake_build_test(cython-core_create_modules_component)

add_cmake_config_test(cython-core_add_rpath_entries)
