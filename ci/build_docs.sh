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

VERSION_NUMBER=$(rapids-get-rapids-version-from-git)

rapids-logger "Build Sphinx docs"
pushd docs
sphinx-build -b dirhtml . _html
sphinx-build -b text . _text
popd


if [[ ${RAPIDS_BUILD_TYPE} == "branch" ]]; then
  aws s3 sync --delete docs/_html "s3://rapidsai-docs/rapids-cmake/${VERSION_NUMBER}/html"
  aws s3 sync --delete docs/_text "s3://rapidsai-docs/rapids-cmake/${VERSION_NUMBER}/txt"
fi
