#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_GITHUB_CLI_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_INSTALL_GITHUB_CLI_LINUX_DIRECTORY="${INSTALL_GITHUB_CLI_LINUX_DIRECTORY%/*}"

# Source utilities
# shellcheck source=../common/utilities.sh
source "$PARENT_INSTALL_GITHUB_CLI_LINUX_DIRECTORY/common/utilities.sh"

# --- Helper Functions ---

# Adds the official GitHub CLI apt repository to the system.
# This function requires sudo privileges.
add_github_cli_repository()
{
  log_info "📥 Adding GitHub CLI apt repository..."

  # Check for sudo privileges early to provide a clear error message.
  validate_required_programs "sudo"

  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  log_info "✅ GitHub CLI apt repository added successfully."
}

# --- Script Main Logic ---
log_info "🧭 Installing GitHub CLI (Linux)..."

# The script will exit immediately if gh is already installed and verified.
if is_program_installed "gh" && verify_command "gh"; then
  log_info "✅ GitHub CLI is already installed and verified."
  exit 0
fi

# 1. Install prerequisites (curl)
# curl is critical for adding the repository.
install_and_verify_tool "curl" "curl" "true"

# 2. Add the custom repository for GitHub CLI
add_github_cli_repository

# 3. Update apt cache to recognize the new repository
log_info "Updating apt cache after adding new repository..."
update_apt_cache

# 4. Install GitHub CLI using the helper function
# gh is considered a critical tool for this development environment.
install_and_verify_tool "gh" "gh" "true"

log_info "GitHub CLI installation script finished successfully."
