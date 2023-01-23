#!/bin/bash
# Copyright (c) 2023, NVIDIA CORPORATION.

set -euo pipefail

rapids-logger "Create test conda environment"
. /opt/conda/etc/profile.d/conda.sh

rapids-dependency-file-generator \
  --output requirements \
  --file_key docs \
  --matrix "cuda=${RAPIDS_CUDA_VERSION%.*};arch=$(arch);py=${RAPIDS_PY_VERSION}" | tee requirements.txt

rapids-mamba-retry create -n test
conda activate test
pip install -r requirements.txt

rapids-print-env

rapids-logger "Downloading artifacts from previous jobs"
CPP_CHANNEL=$(rapids-download-conda-from-s3 cpp)
VERSION_NUMBER=$(rapids-get-rapids-version-from-git)

rapids-mamba-retry install \
  --channel "${CPP_CHANNEL}" \
  rapids_core_dependencies


# Build CPP docs
gpuci_logger "Build CPP docs"
pushd docs
sphinx-build -b dirhtml . _build
popd


if [[ ${RAPIDS_BUILD_TYPE} == "branch" ]]; then
  aws s3 sync --delete doxygen/html "s3://rapidsai-docs/rapids-cmake/${VERSION_NUMBER}/_build"
fi