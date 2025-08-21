#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_CMAKE_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_CMAKE_MACOS_DIRECTORY/common_utils.sh"

# --- Script Main Logic ---
log_info "🏗️  Installing CMake (macOS)..."

# Define program and package names
CMAKE_PROGRAM_NAME="cmake"
CMAKE_PACKAGE_NAME="cmake"

# Install and verify CMake using the shared helper function.
# CMake is a critical build tool, so the fourth argument is "true".
install_and_verify_tool "$CMAKE_PROGRAM_NAME" "$CMAKE_PACKAGE_NAME" "formula" "true"

log_info "CMake installation script finished successfully."
