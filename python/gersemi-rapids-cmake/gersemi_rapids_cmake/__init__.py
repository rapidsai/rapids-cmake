# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

import re

from gersemi_rapids_cmake_detail import (
    command_definitions as _command_definitions,
)


NON_DETAIL_RE = re.compile(r"^(?:rapids_|cpm|create_logger_macros$)")

command_definitions = {
    k: v for k, v in _command_definitions.items() if NON_DETAIL_RE.search(k)
}

__all__ = ["command_definitions"]
