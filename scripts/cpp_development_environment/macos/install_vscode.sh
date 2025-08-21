#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_VSCODE_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_VSCODE_MACOS_DIRECTORY/common_utils.sh"

# --- Constants ---
VSCODE_PROGRAM_NAME="code"
VSCODE_PACKAGE_NAME="visual-studio-code"
VSCODE_APP_PATH="/Applications/Visual Studio Code.app"

# --- Helper Functions ---

# Installs and verifies Visual Studio Code.
# This is a special case because VS Code is a GUI application (cask)
# and the 'code' command-line tool might require manual setup.
install_and_verify_vscode()
{
  # install_with_brew handles the check for whether the cask is already installed.
  # Try to install VS Code, but don't fail critically since it's not essential
  if ! install_with_brew "$VSCODE_PACKAGE_NAME" "" "cask"; then
    log_warning "Visual Studio Code installation via Homebrew failed."
    return 1
  fi

  log_info "Verifying VS Code installation..."

  # Primary verification: Check for the application bundle.
  if [ -d "$VSCODE_APP_PATH" ]; then
    log_info "✅ Found Visual Studio Code application bundle at '$VSCODE_APP_PATH'."
  else
    log_warning "⚠️ Visual Studio Code application bundle NOT FOUND at '$VSCODE_APP_PATH'. The installation might be incomplete."
  fi

  # Secondary verification: Check for the 'code' command-line tool.
  if is_program_installed "$VSCODE_PROGRAM_NAME"; then
    log_info "✅ '$VSCODE_PROGRAM_NAME' command is available."
  else
    log_warning "⚠️ '$VSCODE_PROGRAM_NAME' command not found. This is often expected after a fresh install."
    log_info "👉 To enable the 'code' command, open VS Code, press Cmd+Shift+P, type 'Shell Command: Install \'code\' command in PATH', and select it."
  fi
}

# --- Script Main Logic ---

log_info "🖥️  Installing Visual Studio Code (macOS)..."

install_and_verify_vscode

log_info "Visual Studio Code installation script finished successfully."
