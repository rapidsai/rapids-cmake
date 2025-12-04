#!/bin/bash

# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

# It's not possible for pre-commit to install a local Python package, so
# manually add it to the PYTHONPATH instead.

set -euo pipefail

PYTHONPATH="$(dirname "$0")/../../python/gersemi-rapids-cmake:${PYTHONPATH:-}" gersemi "${@}"
