/*
 * SPDX-FileCopyrightText: Copyright (c) 2021-2026, NVIDIA CORPORATION.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <version.h>

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

int main()
{
  static_assert(dmajor == 9);
  static_assert(dminor == 8);
  static_assert(dpatch == 2);

  static_assert(string_equal(DEMO_VERSION, "9.8.2"));

  static_assert(DEMO_VERSION_GT(9, 8, 1));
  static_assert(DEMO_VERSION_GT(9, 7, 99));
  static_assert(DEMO_VERSION_GT(8, 99, 99));
  static_assert(!DEMO_VERSION_GT(9, 8, 2));
  static_assert(!DEMO_VERSION_GT(9, 9, 1));

  static_assert(DEMO_VERSION_LT(9, 8, 3));
  static_assert(DEMO_VERSION_LT(9, 9, 0));
  static_assert(DEMO_VERSION_LT(10, 0, 0));
  static_assert(!DEMO_VERSION_LT(9, 8, 2));
  static_assert(!DEMO_VERSION_LT(8, 9, 9));

  static_assert(DEMO_VERSION_EQ(9, 8, 2));
  static_assert(!DEMO_VERSION_EQ(9, 8, 1));
  static_assert(!DEMO_VERSION_EQ(9, 7, 2));
  static_assert(!DEMO_VERSION_EQ(8, 8, 2));

  return 0;
}
