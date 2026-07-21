/*
 * SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <demo_version.hpp>
#include <nested_version.hpp>

constexpr bool string_equal(char const* lhs, char const* rhs)
{
  while (*lhs && *lhs == *rhs) {
    ++lhs;
    ++rhs;
  }
  return *lhs == *rhs;
}

constexpr int dmajor = DEMO_VERSION_MAJOR;
constexpr int dminor = DEMO_VERSION_MINOR;
constexpr int dpatch = DEMO_VERSION_PATCH;

constexpr int nmajor = NESTED_VERSION_MAJOR;
constexpr int nminor = NESTED_VERSION_MINOR;
constexpr int npatch = NESTED_VERSION_PATCH;

int main()
{
  static_assert(dmajor == 3);
  static_assert(dminor == 2);
  static_assert(dpatch == 0);
  static_assert(string_equal(DEMO_VERSION, "3.2.0"));
  static_assert(DEMO_VERSION_GT(3, 1, 99));
  static_assert(DEMO_VERSION_LT(3, 2, 1));
  static_assert(DEMO_VERSION_EQ(3, 2, 0));

  static_assert(nmajor == 3);
  static_assert(nminor == 2);
  static_assert(npatch == 0);
  return 0;
}
