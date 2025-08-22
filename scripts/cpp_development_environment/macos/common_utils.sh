#!/bin/bash

set -euo pipefail

# Common utility functions for macOS installation scripts

# Get the directory of the currently executing script
# This is needed to reliably source the utilities.sh
MACOS_COMMON_UTILITIES_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities (logging, safety options)
# shellcheck source=../common/utilities.sh
source "$MACOS_COMMON_UTILITIES_DIRECTORY/../common/utilities.sh"

# --- macOS Specific Program and Brew Utilities ---

# Installs a package using Homebrew, checking if it's already installed.
# Usage: install_with_brew <package_name> [package_name_for_brew_list] <install_type>
# <install_type> can be "formula" or "cask".
# If package_name_for_brew_list is empty or not provided, package_name is used.
install_with_brew()
{
  local package_name="$1"
  local list_name="$2"
  local install_type="$3" # "formula" or "cask"

  if [[ -z "$list_name" ]]; then
    list_name="$package_name"
  fi

  local list_command="brew list --formula"
  if [[ "$install_type" == "cask" ]]; then
    list_command="brew list --cask"
  fi

  log_info "Checking if $package_name ($install_type) is installed..."
  if $list_command | grep -q "^${list_name}$"; then
    log_info "✅ $package_name is already installed."
    return 0
  fi

  # If not installed, call the internal installer.
  _install_with_brew "$package_name" "$install_type"
}

# Internal helper to install a package using Homebrew.
# This function is not intended to be called directly from installation scripts.
# Usage: _install_with_brew <package_name> <install_type>
_install_with_brew()
{
  local package_name="$1"
  local install_type="$2" # "formula" or "cask"

  log_info "Installing $package_name ($install_type) with Homebrew..."

  # Use an array for brew arguments for safer handling of package names.
  local brew_args=("install" "$package_name")
  if [[ "$install_type" == "cask" ]]; then
    brew_args=("install" "--cask" "$package_name")
  fi

  if brew "${brew_args[@]}"; then
    log_info "✅ Successfully initiated installation for $package_name."
    return 0
  else
    log_error "❌ Failed to install '$package_name'. Please check Homebrew logs."
    return 1
  fi
}

# A helper function to install and verify a tool using Homebrew.
# It handles both critical and non-critical tools.
# The logic is structured to first check for completion, then attempt installation
# and verification, handling critical failures by exiting.
# Usage: install_and_verify_tool <program_name> <package_name> <install_type> <is_critical>
# <install_type> can be "formula" or "cask".
install_and_verify_tool()
{
  local program_name="$1"
  local package_name="$2"
  local install_type="$3" # "formula" or "cask"
  local is_critical="$4"  # "true" or "false"

  log_info "--- Processing $program_name ---"

  # If already installed and verified, we're done.
  if is_program_installed "$program_name" && verify_command "$program_name"; then
    log_info "✅ $program_name is already installed and verified."
    return 0
  fi

  # Log the reason for proceeding: either not installed or verification failed.
  if is_program_installed "$program_name"; then
    log_warning "Verification failed for installed $program_name. Attempting reinstallation."
  else
    log_info "$program_name is not installed. Proceeding with installation."
  fi

  # --- Installation ---
  if ! _install_with_brew "$package_name" "$install_type"; then
    if [[ "$is_critical" == "true" ]]; then
      handle_error "$ERROR_INSTALLATION_FAILED" "Installation of critical tool '$package_name' failed"
    else
      log_warning "Installation of non-critical tool '$package_name' failed."
      return 1
    fi
  fi

  # --- Final Verification ---
  if ! verify_command "$program_name"; then
    if [[ "$is_critical" == "true" ]]; then
      handle_error "$ERROR_VERIFICATION_FAILED" "Verification of critical tool '$program_name' failed after installation"
    else
      log_warning "Verification of non-critical tool '$program_name' failed after installation."
      return 1
    fi
  fi

  log_info "✅ Successfully installed and verified $program_name."
  return 0
}

log_info "macOS specific common utilities loaded."
