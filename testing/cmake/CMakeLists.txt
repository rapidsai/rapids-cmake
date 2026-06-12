# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

add_cmake_config_test(rapids-cmake.cmake)

add_cmake_config_test(build_type-debug.cmake)
add_cmake_config_test(build_type-multiple.cmake)
add_cmake_config_test(build_type-user-specified.cmake)

add_cmake_config_test(check_conda_env.cmake)
add_cmake_config_test(check_conda_env-mismatch.cmake
                      SHOULD_FAIL
                      "Conda environment changed since this build directory was configured\\.\n\n    Configured with: /opt/conda/prefix-a\n    Current env:     /opt/conda/prefix-b\n\n  Delete the build directory and reconfigure:\n\n    foo"
)

add_cmake_config_test(conda_env-build.cmake)
add_cmake_config_test(conda_env-build-envvar.cmake)
add_cmake_config_test(conda_env-cross-build-arm.cmake)
add_cmake_config_test(conda_env-cross-build-arm-envvar.cmake)
add_cmake_config_test(conda_env-cross-build-x86.cmake)
add_cmake_config_test(conda_env-cross-build-x86-envvar.cmake)
add_cmake_config_test(conda_env-invalid.cmake)
add_cmake_config_test(conda_env-prefix.cmake)
add_cmake_config_test(conda_env-prefix-envvar.cmake)

add_cmake_build_test(default_install_component-simple)
add_cmake_build_test(default_install_component-sibling-default)
add_cmake_build_test(default_install_component-sibling-mixed)

add_cmake_config_test(download_with_retry-basic.cmake)
add_cmake_config_test(download_with_retry-overwrite.cmake)

add_cmake_config_test(install_lib_dir-after-gnuinstalldir-include.cmake)
add_cmake_config_test(install_lib_dir-build.cmake)
add_cmake_config_test(install_lib_dir-lib64-with-conda_build.cmake)
add_cmake_config_test(install_lib_dir-lib64-with-conda_prefix.cmake)
add_cmake_config_test(install_lib_dir-no-conda.cmake)
add_cmake_config_test(install_lib_dir-prefix.cmake)

add_cmake_config_test(make_global-already-imported-global.cmake)
add_cmake_config_test(make_global-is-alias.cmake)
add_cmake_config_test(make_global-no-targets.cmake)
add_cmake_config_test(make_global-not-imported.cmake)
add_cmake_config_test(make_global-valid.cmake)

add_cmake_config_test(parse_version-major-valid.cmake)
add_cmake_config_test(parse_version-major-invalid.cmake)
add_cmake_config_test(parse_version-minor-invalid.cmake)
add_cmake_config_test(parse_version-minor-valid.cmake)
add_cmake_config_test(parse_version-patch-valid.cmake)
add_cmake_config_test(parse_version-patch-invalid.cmake)
add_cmake_config_test(parse_version-major_minor-invalid.cmake)
add_cmake_config_test(parse_version-major_minor-valid.cmake)

add_cmake_build_test(write_git_revision-custom-prefix)
add_cmake_build_test(write_git_revision-dirty)
add_cmake_build_test(write_git_revision-embed)
add_cmake_build_test(write_git_revision-no-git)
add_cmake_build_test(write_git_revision-simple)

add_cmake_build_test(write_version-absolute)
add_cmake_build_test(write_version-all-zeroes)
add_cmake_build_test(write_version-custom-prefix)
add_cmake_build_test(write_version-leading-zeroes)
add_cmake_build_test(write_version-relative)
