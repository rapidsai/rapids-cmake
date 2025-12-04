# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

import os
from pathlib import Path

from gersemi.immutable import make_immutable
from gersemi.runner import (
    AdaptivePool,
    WarningSink,
    find_all_custom_command_definitions,
)

from ._patch import apply_patches


paths = (
    Path(base) / file
    for base, _, files in os.walk(Path(__file__).parent / "stubs")
    for file in files
    if file.endswith(".stubs")
)
pool = AdaptivePool(1)
warning_sink = WarningSink(False)

found_definitions = find_all_custom_command_definitions(paths, pool, warning_sink)

if warning_sink.records:
    warning_sink.flush()
    raise RuntimeError

command_definitions = make_immutable(apply_patches(found_definitions))

__all__ = ["command_definitions"]
