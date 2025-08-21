#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_CMAKE_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_CMAKE_LINUX_DIRECTORY/common_utils.sh"

# --- Script Main Logic ---
log_info "Starting CMake installation script for Linux..."

# Update apt cache (important before installing packages)
update_apt_cache

# Define program and package names
CMAKE_PROGRAM_NAME="cmake"
CMAKE_PACKAGE_NAME="cmake"

# Install and verify CMake using the shared helper function
# CMake is critical for building, so the third argument is "true"
install_and_verify_tool "$CMAKE_PROGRAM_NAME" "$CMAKE_PACKAGE_NAME" "true"

log_info "CMake installation script finished successfully."
