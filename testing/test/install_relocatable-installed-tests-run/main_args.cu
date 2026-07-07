/*
 * SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 */
#include <cstring>
#include <dlfcn.h>

int main(int argc, char** argv)
{
  if (argc != 3) { return 1; }
  if (strcmp(argv[1], "arg")) { return 1; }
  void* handle = dlopen(argv[2], RTLD_LAZY);
  if (!handle) { return 1; }
  auto* callback = reinterpret_cast<int (*)()>(dlsym(handle, "callback"));
  if (!callback) { return 1; }
  if (callback()) { return 1; }
  if (dlclose(handle)) { return 1; }

  return 0;
}
