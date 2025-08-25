#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_CLANG_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_INSTALL_CLANG_LINUX_DIRECTORY="${INSTALL_CLANG_LINUX_DIRECTORY%/*}"

# Source utilities
# shellcheck source=../common/utilities.sh
source "$PARENT_INSTALL_CLANG_LINUX_DIRECTORY/common/utilities.sh"

# --- Script Main Logic ---
log_info "Starting Clang and related tools installation script for Linux..."

# Update apt cache
update_apt_cache

# --- Install and Verify Tools ---
install_and_verify_tool "clang" "clang" "true"
install_and_verify_tool "clangd" "clangd" "true"
install_and_verify_tool "clang-tidy" "clang-tidy" "false"
install_and_verify_tool "clang-format" "clang-format" "false"
install_and_verify_tool "lldb" "lldb" "true"

log_info "Clang and related tools installation script finished successfully."
