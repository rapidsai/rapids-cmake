/*
 * SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <no_combined.hpp>

#ifdef NO_COMBINED_VERSION
#error "NO_COMBINED_VERSION_MACRO failed to disable the combined version define"
#endif

// Passing NO_COMBINED_VERSION_MACRO to one call doesn't affect other calls, so this
// second header still gets its combined version define.
#include <combined.hpp>

#ifndef COMBINED_VERSION
#error "COMBINED_VERSION should be defined when NO_COMBINED_VERSION_MACRO isn't used"
#endif

constexpr bool string_equal(char const* lhs, char const* rhs)
{
  while (*lhs && *lhs == *rhs) {
    ++lhs;
    ++rhs;
  }
  return *lhs == *rhs;
}

constexpr int nmajor = NO_COMBINED_VERSION_MAJOR;
constexpr int nminor = NO_COMBINED_VERSION_MINOR;
constexpr int npatch = NO_COMBINED_VERSION_PATCH;

int main()
{
  // Everything but the combined version define is still generated
  static_assert(nmajor == 3);
  static_assert(nminor == 2);
  static_assert(npatch == 1);
  static_assert(NO_COMBINED_VERSION_GT(3, 2, 0));
  static_assert(NO_COMBINED_VERSION_LT(3, 3, 0));
  static_assert(NO_COMBINED_VERSION_EQ(3, 2, 1));

  static_assert(string_equal(COMBINED_VERSION, "3.2.1"));
  return 0;
}
