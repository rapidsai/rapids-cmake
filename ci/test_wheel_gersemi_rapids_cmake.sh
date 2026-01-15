#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

source rapids-init-pip

# Download the gersemi-rapids-cmake wheel built in the previous step
WHEELHOUSE=$(rapids-download-from-github "$(rapids-package-name "wheel_python" gersemi-rapids-cmake --pure)")

rapids-logger "Install gersemi-rapids-cmake and its basic dependencies in a virtual environment"

python -m venv env
. env/bin/activate
rapids-pip-retry install \
  -v \
  "$(echo "${WHEELHOUSE}/gersemi_rapids_cmake"*.whl)"

rapids-logger "Test a correctly formatted file"

gersemi -c --diff --line-length 80 --indent 2 --extensions rapids_cmake -- - <<EOF
rapids_cpm_find(
  cudf
  26.02
  CPM_ARGS
    OPTIONS
      "BUILD_SHARED_LIBS ON"
      "CMAKE_BUILD_TYPE Debug"
      "CMAKE_C_COMPILER /usr/bin/gcc"
      "CMAKE_CXX_COMPILER /usr/bin/g++"
      "CMAKE_CUDA_COMPILER /usr/bin/nvcc"
)
EOF

rapids-logger "Test an incorrectly formatted file"

! gersemi -c --diff --line-length 80 --indent 2 --extensions rapids_cmake -- - <<EOF
rapids_cpm_find(
  cudf
  26.02
  CPM_ARGS
  OPTIONS
  "BUILD_SHARED_LIBS ON"
  "CMAKE_BUILD_TYPE Debug"
  "CMAKE_C_COMPILER /usr/bin/gcc"
  "CMAKE_CXX_COMPILER /usr/bin/g++"
  "CMAKE_CUDA_COMPILER /usr/bin/nvcc"
)
EOF
