#!/bin/bash

set -euo pipefail

# This script installs Visual Studio Code on Linux.

# Get the directory of the currently executing script
INSTALL_VSCODE_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common_utils.sh
source "$INSTALL_VSCODE_LINUX_DIRECTORY/common_utils.sh"

# --- Helper Functions ---

# Installs prerequisite packages needed for adding the VS Code repository.
install_dependencies()
{
  log_info "Installing dependencies: wget, gpg, apt-transport-https"
  install_packages "wget" "gpg" "apt-transport-https"
}

# Adds the official Microsoft VS Code apt repository to the system.
# This function requires sudo privileges.
add_vscode_repository()
{
  log_info "📥 Adding Microsoft VS Code apt repository..."

  # Check for sudo privileges early
  validate_required_programs "sudo"

  # Download Microsoft GPG key, dearmor it, and save it to the keyrings directory
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg >/dev/null

  # Add the VS Code repository to the sources list
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

  log_info "✅ Microsoft VS Code apt repository added successfully."
}

# --- Script Main Logic ---
log_info "🖥️  Installing Visual Studio Code (Linux)..."

# Exit early if VS Code is already installed and verified.
if is_program_installed "code" && verify_command "code"; then
  log_info "✅ Visual Studio Code is already installed and verified."
  exit 0
fi

# 1. Install prerequisites for adding the repository.
install_dependencies

# 2. Add the custom repository for VS Code.
add_vscode_repository

# 3. Update apt cache to recognize the new repository.
log_info "Updating apt cache after adding new repository..."
update_apt_cache

# 4. Install Visual Studio Code itself.
# The 'false' flag indicates that this installation is not critical for the main setup to succeed,
# which is useful in environments like CI where a GUI application might not be needed.
install_and_verify_tool "code" "code" "false"

log_info "Visual Studio Code installation script finished."
