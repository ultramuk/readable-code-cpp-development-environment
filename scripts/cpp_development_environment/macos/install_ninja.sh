#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_NINJA_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_NINJA_MACOS_DIRECTORY/common_utils.sh"

# --- Script Main Logic ---
log_info "⚡ Installing Ninja (macOS)..."

# Define program and package names
NINJA_PROGRAM_NAME="ninja"
NINJA_PACKAGE_NAME="ninja"

# Install and verify Ninja using the shared helper function.
# Ninja is a critical build tool, so the fourth argument is "true".
install_and_verify_tool "$NINJA_PROGRAM_NAME" "$NINJA_PACKAGE_NAME" "formula" "true"

log_info "Ninja installation script finished successfully."
