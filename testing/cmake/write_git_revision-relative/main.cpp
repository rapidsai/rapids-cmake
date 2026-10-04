/*
 * SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

#include <demo_git_version.hpp>
#include <nested_git_version.hpp>

static_assert(sizeof(DEMO_GIT_BRANCH) > 1, "Missing Git branch");
static_assert(sizeof(DEMO_GIT_SHA1) > 1, "Missing Git SHA1");
static_assert(sizeof(DEMO_GIT_VERSION) > 1, "Missing Git version");
static_assert(sizeof(NESTED_GIT_BRANCH) > 1, "Missing nested Git branch");
static_assert(sizeof(NESTED_GIT_SHA1) > 1, "Missing nested Git SHA1");
static_assert(sizeof(NESTED_GIT_VERSION) > 1, "Missing nested Git version");

int main() { return 0; }
