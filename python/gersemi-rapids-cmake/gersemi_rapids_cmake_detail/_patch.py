# SPDX-FileCopyrightText: Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

from typing import TYPE_CHECKING

from gersemi.builtin_commands import builtin_commands

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence
    from typing import Any


def _filter_existing_keywords(
    definition: "Mapping[str, Any]", keywords: "Sequence[str]"
) -> tuple[str, ...]:
    return tuple(
        kw
        for kw in keywords
        if kw
        not in {
            *definition["options"],
            *definition["one_value_keywords"],
            *definition["multi_value_keywords"],
        }
    )


def _combine_keywords(
    definition: "Mapping[str, Any]", called_definition: "Mapping[str, Any]"
) -> "Mapping[str, Any]":
    return {
        **definition,
        "options": (
            *definition["options"],
            *_filter_existing_keywords(definition, called_definition["options"]),
        ),
        "one_value_keywords": (
            *definition["one_value_keywords"],
            *_filter_existing_keywords(
                definition, called_definition["one_value_keywords"]
            ),
        ),
        "multi_value_keywords": (
            *definition["multi_value_keywords"],
            *_filter_existing_keywords(
                definition, called_definition["multi_value_keywords"]
            ),
        ),
    }


def apply_patches(command_definitions: "Mapping[str, Any]") -> "Mapping[str, Any]":
    CPMAddPackage = _combine_keywords(
        command_definitions["cpmaddpackage"], builtin_commands["FetchContent_Declare"]
    )
    CPMFindPackage = _combine_keywords(
        command_definitions["cpmfindpackage"], builtin_commands["FetchContent_Declare"]
    )

    return {
        **command_definitions,
        "cpmaddpackage": CPMAddPackage,
        "cpmfindpackage": CPMFindPackage,
        "rapids_cpm_find": {
            **command_definitions["rapids_cpm_find"],
            "options": tuple(
                kw
                for kw in command_definitions["rapids_cpm_find"]["options"]
                if kw != "CPM_ARGS"
            ),
            "one_value_keywords": tuple(
                kw
                for kw in command_definitions["rapids_cpm_find"]["one_value_keywords"]
                if kw != "SOURCE_SUBDIR"
            ),
            "multi_value_keywords": (
                *command_definitions["rapids_cpm_find"]["multi_value_keywords"],
                "CPM_ARGS",
            ),
            "sections": {
                "CPM_ARGS": CPMAddPackage,
            },
        },
        "rapids_export_cpm": {
            **command_definitions["rapids_export_cpm"],
            "sections": {
                "CPM_ARGS": CPMAddPackage,
            },
        },
    }


__all__ = ["apply_patches"]
