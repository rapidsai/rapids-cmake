// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <cstdio>
#include <zlib.h>

void find_generate_module_function()
{
  printf("find-generate-module example\n");
  printf("zlib version: %s\n", zlibVersion());
}
