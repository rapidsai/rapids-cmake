# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

add_cmake_build_test(project-bootstrap SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/project-bootstrap)
add_cmake_build_test(conda-support SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/conda-support)
add_cmake_build_test(cuda-features SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/cuda-features)
add_cmake_build_test(export-feature SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/export-feature)
add_cmake_build_test(find-generate-module SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/find-generate-module)
add_cmake_build_test(project-override SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/project-override NO_CPM_CACHE)
add_cmake_build_test(version-header SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/version-header)
add_cmake_build_test(thirdparty-dependencies SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/thirdparty-dependencies)
add_cmake_build_test(pin-dependencies SOURCE_DIR
                     ${CMAKE_CURRENT_SOURCE_DIR}/../../examples/pin-dependencies NO_CPM_CACHE)
