# =============================================================================
# cmake-format: off
# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
# cmake-format: on
# =============================================================================

set(default_dependency_file "${install_dir}/default_dependency/dependencies/default_dependency.txt")
set(default_testing_file "${install_dir}/default_dependency/dependencies/testing_dependency.txt")
set(testing_dependency_file "${install_dir}/testing/dependencies/testing_dependency.txt")
set(testing_default_file "${install_dir}/testing/dependencies/default_dependency.txt")

if(NOT EXISTS "${default_dependency_file}")
  message(FATAL_ERROR "DefaultDependency did not install as component defaultdependency")
endif()
if(EXISTS "${default_testing_file}")
  message(FATAL_ERROR "TestingDependency incorrectly installed as component defaultdependency")
endif()
if(NOT EXISTS "${testing_dependency_file}")
  message(FATAL_ERROR "TestingDependency did not install as component testing")
endif()
if(EXISTS "${testing_default_file}")
  message(FATAL_ERROR "DefaultDependency incorrectly installed as component testing")
endif()
