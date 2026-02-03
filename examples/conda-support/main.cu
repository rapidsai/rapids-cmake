// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <cstdio>

extern void conda_support_function();

int main()
{
  printf("conda-support example\n");
  conda_support_function();
  return 0;
}
