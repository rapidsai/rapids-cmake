/*
 * SPDX-FileCopyrightText: Copyright (c) 2021-2024, NVIDIA CORPORATION.
 * SPDX-License-Identifier: Apache-2.0
 */

static __global__ void example_cuda_kernel(int& r, int x, int y) { r = x * y + (x * 4 - (y / 2)); }

int static_launch_kernelC(int x, int y)
{
  int r;
  example_cuda_kernel<<<1, 1>>>(r, x, y);
  return r;
}
