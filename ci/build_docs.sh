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

VERSION_NUMBER="23.06"

rapids-logger "Build Sphinx docs"
pushd docs
sphinx-build -b dirhtml . _html -W
sphinx-build -b text . _text -W
popd


if [[ ${RAPIDS_BUILD_TYPE} == "branch" ]]; then
  rapids-logger "Upload Docs to S3"
  aws s3 sync --no-progress --delete docs/_html "s3://rapidsai-docs/rapids-cmake/${VERSION_NUMBER}/html"
  aws s3 sync --no-progress --delete docs/_text "s3://rapidsai-docs/rapids-cmake/${VERSION_NUMBER}/txt"
fi
