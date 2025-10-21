#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2022-2023, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/test/init.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/test/add.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/test/generate_resource_spec.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/test/gpu_requirements.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/test/install_relocatable.cmake)
