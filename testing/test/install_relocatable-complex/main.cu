/*
 * SPDX-FileCopyrightText: Copyright (c) 2022-2025, NVIDIA CORPORATION.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <iostream>
#include <vector>

#include "rapids_cmake_ctest_allocation.cpp"
#include "rapids_cmake_ctest_allocation.hpp"

int main()
{
  if (rapids_cmake::using_resources()) {
    std::cout << "found a resource file" << std::endl;
    return 0;
  }
  return 1;
}
