#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2021, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================

add_subdirectory(D)

add_library(B STATIC static.not_cu)
set_source_files_properties(static.not_cu PROPERTIES LANGUAGE CUDA)
