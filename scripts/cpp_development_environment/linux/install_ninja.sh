#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_NINJA_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_NINJA_LINUX_DIRECTORY/common_utils.sh"

# --- Script Main Logic ---
log_info "Starting Ninja installation script for Linux..."

# Update apt cache before installing packages. This function has a built-in check
# to avoid redundant updates if the cache is already fresh.
update_apt_cache

# Define program and package names
NINJA_PROGRAM_NAME="ninja"
NINJA_PACKAGE_NAME="ninja-build"

# Install and verify Ninja using the shared helper function.
# Ninja is a critical build tool, so the third argument is "true".
install_and_verify_tool "$NINJA_PROGRAM_NAME" "$NINJA_PACKAGE_NAME" "true"

log_info "Ninja installation script finished successfully."
