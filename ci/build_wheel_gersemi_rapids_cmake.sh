#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

source rapids-init-pip

rapids-logger "Generating build requirements"

rapids-dependency-file-generator \
  --output requirements \
  --file-key "py_build_gersemi_rapids_cmake" \
  --matrix "" \
| tee /tmp/requirements-build.txt

rapids-logger "Installing build requirements"
rapids-pip-retry install \
  -v \
  --prefer-binary \
  -r /tmp/requirements-build.txt

rapids-generate-version > ./VERSION
rapids-generate-version > ./python/gersemi-rapids-cmake/gersemi_rapids_cmake_detail/VERSION

cd ./python/gersemi-rapids-cmake

rapids-logger "Building 'gersemi-rapids-cmake' wheel"
rapids-telemetry-record build-gersemi-rapids-cmake.log rapids-pip-retry wheel \
  -w dist \
  -v \
  --no-deps \
  --disable-pip-version-check \
  .

cp dist/* "${RAPIDS_WHEEL_BLD_OUTPUT_DIR}"

rapids-logger "validate packages with 'pydistcheck'"
pydistcheck \
  --inspect \
  "$(echo "${RAPIDS_WHEEL_BLD_OUTPUT_DIR}"/*.whl)"

rapids-logger "validate packages with 'twine'"
twine check \
  --strict \
  "$(echo "${RAPIDS_WHEEL_BLD_OUTPUT_DIR}"/*.whl)"
