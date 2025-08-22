#!/bin/bash

set -euo pipefail

# This script configures Visual Studio Code for C++ development by installing recommended extensions and applying settings.

# Get the directory of the currently executing script
CONFIGURE_VSCODE_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common OS-agnostic utilities
# shellcheck source=./os_agnostic_utils.sh
source "$CONFIGURE_VSCODE_DIRECTORY/os_agnostic_utils.sh"

log_info "⚙️ Configuring Visual Studio Code..."

# Check if the 'code' command is available in the PATH
if ! is_program_installed "code"; then
  log_warning "⚠️ 'code' command not found in PATH. Skipping VS Code extension installation."
  log_warning "   To enable, open VS Code, press Cmd+Shift+P, and run 'Shell Command: Install \'code\' command in PATH'."
  exit 0
fi

# --- List of extensions to install ---
# Using a function to keep the main logic clean
install_vscode_extensions()
{
  log_info "Preparing to install/verify VS Code extensions..."
  local extensions_to_install=(
    # --- C++ Core Development Tools ---
    "ms-vscode.cpptools"
    "llvm-vs-code-extensions.vscode-clangd"
    "ms-vscode.cmake-tools"
    "vadimcn.vscode-lldb"
    "cschlosser.doxdocgen"
    "josetr.cmake-language-support-vscode"

    # --- Testing Frameworks ---
    "matepek.vscode-catch2-test-adapter"
    "fredericbonnet.cmake-test-adapter"

    # --- Version Control & Collaboration ---
    "eamodio.gitlens"
    "github.vscode-pull-request-github"
    "mhutchie.git-graph"
    "ms-vsliveshare.vsliveshare"
    "atlassian.atlascode"

    # --- Code Quality & Readability ---
    "streetsidesoftware.code-spell-checker"
    "shardulm94.trailing-spaces"
    "oderwat.indent-rainbow"
    "usernamehw.errorlens"
    "editorconfig.editorconfig"
    "albert.tabout"
    "msfukui.eof-mark"

    # --- Other Useful Utilities ---
    "christian-kohler.path-intellisense"
    "redhat.vscode-yaml"
    "docker.docker"
    "ms-vscode-remote.remote-ssh"
    "sculove.translator"
  )

  local installed_extensions
  installed_extensions=$(code --list-extensions)

  for extension in "${extensions_to_install[@]}"; do
    # Check if the extension is already installed (case-insensitive check)
    if echo "${installed_extensions}" | grep -qi "^${extension}$"; then
      log_info "✅ VS Code extension '${extension}' is already installed."
    else
      log_info "Installing VS Code extension: '${extension}'..."
      handle_critical_command "code --install-extension \"${extension}\" --force" "Failed to install VS Code extension: '${extension}'"
      log_info "Successfully installed '${extension}'."
    fi
  done
}

# --- Apply VS Code Settings from Template ---

# Function to get the correct path to VS Code's settings.json
get_vscode_settings_path()
{
  local settings_path=""

  if [[ "$(uname)" == "Darwin" ]]; then
    settings_path="$HOME/Library/Application Support/Code/User/settings.json"
  elif [[ "$(uname)" == "Linux" ]]; then
    settings_path="$HOME/.config/Code/User/settings.json"
  else
    handle_error "$ERROR_GENERAL" "Unsupported OS for VS Code settings configuration"
  fi

  # Ensure the directory exists before returning the path
  mkdir -p "$(dirname "$settings_path")"
  echo "$settings_path"
}

# Function to ensure jq is installed
ensure_jq_installed()
{
  if ! is_program_installed "jq"; then
    log_info "'jq' is not installed. Attempting to install..."
    if [[ "$(uname)" == "Darwin" ]]; then
      handle_critical_command "brew install jq" "Failed to install 'jq' via Homebrew"
    elif [[ "$(uname)" == "Linux" ]]; then
      # Assuming apt-based distro, as per project scope
      handle_critical_command "sudo apt-get install -y jq" "Failed to install 'jq' via apt-get. Please install it manually"
    fi
  fi
  log_info "✅ 'jq' is available."
  return 0
}

# Function to apply settings from the template file
apply_vscode_settings()
{
  log_info "Applying VS Code settings from template..."

  if ! ensure_jq_installed; then
    log_warning "Cannot apply settings without 'jq'. Skipping."
    return
  fi

  local settings_file_path
  settings_file_path=$(get_vscode_settings_path)
  if [[ -z "$settings_file_path" ]]; then
    log_warning "Could not determine VS Code 'settings.json' path. Skipping."
    return
  fi

  # The template file is located in the project's root assets directory
  local settings_template_file="../../assets/vscode_settings_template.json"
  if [[ ! -f "$settings_template_file" ]]; then
    log_warning "VS Code settings template file not found at '$settings_template_file'. Skipping."
    return
  fi

  # Create the settings file with an empty JSON object if it doesn't exist
  if [[ ! -f "$settings_file_path" ]]; then
    log_info "Creating new 'settings.json' at '$settings_file_path'."
    echo "{}" >"$settings_file_path"
  fi

  # Use jq to merge the template settings into the user's settings.json
  local temporary_merged_settings_file
  temporary_merged_settings_file=$(mktemp)

  if jq -s '.[0] * .[1]' "$settings_file_path" "$settings_template_file" >"$temporary_merged_settings_file"; then
    mv "$temporary_merged_settings_file" "$settings_file_path"
    log_info "✅ Successfully updated VS Code settings in '$settings_file_path'."
  else
    log_error "❌ Failed to merge settings into '$settings_file_path' using jq."
    rm -f "$temporary_merged_settings_file"
  fi
}

# --- Main Execution ---
install_vscode_extensions
apply_vscode_settings

log_info "✅ VS Code configuration completed."
