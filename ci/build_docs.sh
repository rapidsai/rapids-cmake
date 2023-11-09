#!/bin/bash
# Copyright (c) 2023, NVIDIA CORPORATION.

set -euo pipefail

rapids-logger "Create test conda environment"
. /opt/conda/etc/profile.d/conda.sh

rapids-dependency-file-generator \
  --output conda \
  --file_key docs \
  --matrix "cuda=${RAPIDS_CUDA_VERSION%.*};arch=$(arch);py=${RAPIDS_PY_VERSION}" | tee env.yaml

rapids-mamba-retry env create --force -f env.yaml -n docs
conda activate docs

rapids-print-env

export RAPIDS_VERSION_NUMBER="24.02"
export RAPIDS_DOCS_DIR="$(mktemp -d)"

rapids-logger "Build Sphinx docs"
pushd docs
sphinx-build -b dirhtml . _html -W
sphinx-build -b text . _text -W
mkdir -p "${RAPIDS_DOCS_DIR}/rapids-cmake/"{html,txt}
mv _html/* "${RAPIDS_DOCS_DIR}/rapids-cmake/html"
mv _text/* "${RAPIDS_DOCS_DIR}/rapids-cmake/txt"
popd

rapids-upload-docs
