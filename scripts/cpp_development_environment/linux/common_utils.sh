#!/bin/bash

set -euo pipefail

# Common utility functions for Linux installation scripts

LINUX_COMMON_UTILITIES_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/os_agnostic_utils.sh
source "$LINUX_COMMON_UTILITIES_DIRECTORY/../common/os_agnostic_utils.sh"

# --- Linux Specific Program and Package Manager Utilities ---

# Updates the apt package cache.
# Usage: update_apt_cache
update_apt_cache()
{
  log_info "Updating apt package cache (sudo apt-get update)..."
  handle_critical_command "sudo apt-get update -y" "Failed to update apt package cache. Please check permissions and network."
  log_info "✅ Apt package cache updated successfully."
  return 0
}

# Installs multiple packages using apt-get.
# Usage: install_packages "package1" "package2" ...
install_packages()
{
  local packages_to_install=("$@")
  if [ ${#packages_to_install[@]} -eq 0 ]; then
    log_warning "No packages specified for installation."
    return 0
  fi

  log_info "Installing packages: ${packages_to_install[*]}..."
  # We don't check if they are already installed, as apt will handle it gracefully.
  if sudo apt-get install -y "${packages_to_install[@]}"; then
    log_info "✅ Packages installed successfully."
    return 0
  else
    log_error "❌ Failed to install one or more packages. Please check apt-get logs."
    return 1
  fi
}

# Installs a package using apt-get.
# Usage: install_with_apt "package_name"
install_with_apt()
{
  local package_to_install="$1"
  local package_display_name="$package_to_install"

  log_info "Checking if $package_display_name is installed..."
  if dpkg -s "$package_to_install" &>/dev/null; then
    log_info "✅ $package_display_name is already installed."
    return 0
  fi

  log_info "Installing $package_display_name with apt-get..."
  if sudo apt-get install -y "$package_to_install"; then
    log_info "✅ $package_display_name installed successfully."
    return 0
  else
    log_error "❌ Failed to install $package_display_name. Please check apt-get logs."
    return 1
  fi
}

log_info "Linux specific common utilities loaded."

# A helper function to install and verify a tool.
# It handles both critical and non-critical tools.
# Usage: install_and_verify_tool <program_name> <package_name> <is_critical>
install_and_verify_tool()
{
  local program_name="$1"
  local package_name="$2"
  local is_critical="$3" # "true" or "false"

  log_info "--- Processing $program_name ---"

  if is_program_installed "$program_name"; then
    log_info "✅ $program_name is already installed. Verifying..."
    if verify_command "$program_name"; then
      log_info "✅ $program_name verification successful."
      return 0
    fi

    log_warning "Verification failed for installed $program_name. Attempting reinstallation."
  else
    log_info "$program_name is not installed. Proceeding with installation."
  fi

  # Installation/Reinstallation
  if ! install_with_apt "$package_name"; then
    if [[ "$is_critical" == "true" ]]; then
      handle_error "$ERROR_INSTALLATION_FAILED" "Installation of critical tool '$package_name' failed"
    else
      log_warning "Installation of non-critical tool '$package_name' failed."
      return 1
    fi
  fi

  # Final verification
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
