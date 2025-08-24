#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_GIT_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_INSTALL_GIT_LINUX_DIRECTORY="${INSTALL_GIT_LINUX_DIRECTORY%/*}"

# Source utilities
# shellcheck source=../common/utilities.sh
source "$PARENT_INSTALL_GIT_LINUX_DIRECTORY/common/utilities.sh"

# --- Script Main Logic ---
log_info "Starting Git installation script for Linux..."

# Update apt cache before installing packages.
update_apt_cache

# Define program and package names
GIT_PROGRAM_NAME="git"
GIT_PACKAGE_NAME="git"

# Install and verify Git using the shared helper function.
# Git is critical for development, so the third argument is "true".
install_and_verify_tool "$GIT_PROGRAM_NAME" "$GIT_PACKAGE_NAME" "true"

log_info "Git installation script finished successfully."
