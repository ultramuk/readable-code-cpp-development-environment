#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_GITHUB_CLI_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_GITHUB_CLI_MACOS_DIRECTORY/common_utils.sh"

# --- Script Main Logic ---
log_info "🧭 Installing GitHub CLI (macOS)..."

# Define program and package names
GH_PROGRAM_NAME="gh"
GH_PACKAGE_NAME="gh"

# Install and verify GitHub CLI using the shared helper function.
# GitHub CLI is not considered critical for the script to succeed, so the fourth argument is "false".
install_and_verify_tool "$GH_PROGRAM_NAME" "$GH_PACKAGE_NAME" "formula" "false"

log_info "GitHub CLI installation script finished successfully."
