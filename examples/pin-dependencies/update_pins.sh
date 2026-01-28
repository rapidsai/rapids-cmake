#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025-2026, NVIDIA CORPORATION.
# SPDX-License-Identifier: Apache-2.0

# This script builds the project without using the pinned versions,
# which causes rapids-cmake to generate a new pinned versions file.
# If the build is successful, it replaces the existing pins.json with
# the newly generated one.

set -e

echo "Building project to generate new pinned versions..."

# Configure without the pins preset to generate new pins
cmake --preset default

# Build the project
cmake --build --preset default

# Check if the build succeeded by running the executable
echo "Testing the built executable..."
./build/pin_dependencies_example

# If we got here, the build and test succeeded
# Copy the generated pinned versions file
GENERATED_PIN_FILE="build/rapids-cmake/pinned_versions.json"

if [ -f "$GENERATED_PIN_FILE" ]; then
    echo "Build successful! Updating pins.json with generated versions..."
    cp "$GENERATED_PIN_FILE" pins.json
    echo "pins.json has been updated successfully."
    echo ""
    echo "Contents of new pins.json:"
    cat pins.json
else
    echo "Warning: Generated pin file not found at $GENERATED_PIN_FILE"
    echo "The project may not have GENERATE_PINNED_VERSIONS enabled in rapids_cpm_init()"
    exit 1
fi

echo ""
echo "To use the pinned versions in your next build, use:"
echo "  cmake --preset with-pins"
echo "  cmake --build --preset with-pins"
