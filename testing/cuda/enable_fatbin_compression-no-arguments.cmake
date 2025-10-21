#=============================================================================
# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0
#=============================================================================
include(${rapids-cmake-dir}/cuda/enable_fatbin_compression.cmake)

enable_language(CUDA)

rapids_cuda_enable_fatbin_compression()
