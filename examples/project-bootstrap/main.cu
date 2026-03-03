// =============================================================================
// SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION.
// SPDX-License-Identifier: Apache-2.0
// =============================================================================

#include <cstdio>

extern void project_bootstrap_function();

int main()
{
  printf("project-bootstrap example\n");
  printf("This example demonstrates the standard RAPIDS project initialization pattern\n");
  printf("used by ALL production RAPIDS projects (RMM, cuDF, cuVS, etc.)\n");
  project_bootstrap_function();
  return 0;
}
