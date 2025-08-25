#!/bin/bash

set -euo pipefail

# Guard to prevent multiple sourcing
if [[ -n "${UTILITIES_LOADED:-}" ]]; then
  return 0
fi
readonly UTILITIES_LOADED=1

# Common utility functions

# --- Logging functions ---
# Usage: log_info "This is an info message"
log_info()
{
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Usage: log_error "This is an error message"
log_error()
{
  echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Usage: log_warning "This is a warning message"
log_warning()
{
  echo "[WARN] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# --- Standardized Error Handling Functions ---

# Exit codes for consistent error reporting
readonly ERROR_GENERAL=1
readonly ERROR_DEPENDENCY_MISSING=2
readonly ERROR_INSTALLATION_FAILED=3
readonly ERROR_VERIFICATION_FAILED=4
readonly ERROR_CONFIGURATION_FAILED=5
readonly ERROR_PERMISSION_DENIED=6
export ERROR_GENERAL ERROR_DEPENDENCY_MISSING ERROR_INSTALLATION_FAILED
export ERROR_VERIFICATION_FAILED ERROR_CONFIGURATION_FAILED ERROR_PERMISSION_DENIED

# Usage: handle_error <error_code> <error_message> [cleanup_function]
handle_error()
{
  local error_code="$1"
  local error_message="$2"
  local cleanup_function="${3:-}"

  log_error "💀 Fatal error: $error_message"

  # Run cleanup function if provided
  if [[ -n "$cleanup_function" && $(type -t "$cleanup_function") == "function" ]]; then
    log_info "🧹 Running cleanup: $cleanup_function"
    "$cleanup_function" || log_warning "Cleanup function failed"
  fi

  exit "$error_code"
}

# Usage: handle_critical_command <command> <error_message> [cleanup_function]
handle_critical_command()
{
  local command="$1"
  local error_message="$2"
  local cleanup_function="${3:-}"

  if ! eval "$command"; then
    handle_error "$ERROR_GENERAL" "$error_message" "$cleanup_function"
  fi
}

# Usage: validate_required_programs <program1> <program2> ...
validate_required_programs()
{
  local missing_programs=()

  for program in "$@"; do
    if ! is_program_installed "$program"; then
      missing_programs+=("$program")
    fi
  done

  if [[ ${#missing_programs[@]} -gt 0 ]]; then
    local missing_list
    missing_list=$(printf ", %s" "${missing_programs[@]}")
    missing_list=${missing_list:2} # Remove leading ", "
    handle_error "$ERROR_DEPENDENCY_MISSING" "Required programs not found: $missing_list"
  fi
}

# Indicate that utilities have been loaded (optional, for debugging)
# log_info "utilities loaded."

# Performs pre-flight checks
# Usage: perform_preflight_checks
perform_preflight_checks()
{
  log_info "🔍 Running Linux pre-flight checks..."
  validate_required_programs "apt-get" "sudo"
  log_info "✅ Linux pre-flight checks completed successfully"
}

# Defines the installation steps for the linux
# Usage: get_installation_steps <script_directory>
get_installation_steps()
{
  local script_directory="$1"
  local target_directory="$script_directory/linux"

  declare -a steps
  steps=(
    "$target_directory/install_clang.sh"
    "$target_directory/install_cmake.sh"
    "$target_directory/install_ninja.sh"
    "$target_directory/install_git.sh"
    "$target_directory/install_github_cli.sh"
    "$target_directory/install_coding_font.sh"
    "$target_directory/install_vscode.sh"
    "$script_directory/common/configure_vscode.sh"
    "$script_directory/common/setup_sample_project.sh"
  )

  printf '%s\n' "${steps[@]}"
}

# Executes a single installation step with proper logging
# Usage: execute_installation_step <script_path>
execute_installation_step()
{
  local script_path="$1"
  local step_name
  step_name=$(basename "$script_path")

  echo ""
  log_info "🔹 Running: $step_name"
  echo "----------------------------------------"

  handle_critical_command "bash \"$script_path\"" "Failed to execute installation step: $step_name"

  log_info "✅ Done: $step_name"
  echo "----------------------------------------"
}

# Executes all installation steps for the linux
# Usage: execute_installation_workflow <script_directory>
execute_installation_workflow()
{
  local script_directory="$1"

  log_info "🚀 Starting installation workflow for linux..."

  # Get installation steps and execute each one
  # Using temporary file for maximum compatibility
  local temp_steps_file
  temp_steps_file=$(mktemp)
  get_installation_steps "$script_directory" >"$temp_steps_file"

  while IFS= read -r step; do
    if [[ -n "$step" ]]; then
      execute_installation_step "$step"
    fi
  done <"$temp_steps_file"

  rm -f "$temp_steps_file"

  log_info "🎉 ✅ All components installed and configured successfully for linux!"
}

# --- Common Program and Command Utilities ---

# Checks if a program (command) is installed and in PATH.
# This function is universal for any POSIX-compliant shell.
# Usage: if is_program_installed "git"; then ...
is_program_installed()
{
  local program_name="$1"
  command -v "$program_name" &>/dev/null
}

# Verifies if a command is available and executable by running it with a version flag.
# This is generally, as most command-line tools support a --version or similar flag.
# Usage: verify_command "git" "[--version]"
verify_command()
{
  local program_to_verify="$1"
  local verification_arguments="${2:---version}" # Default to --version if no second arg

  log_info "Verifying '$program_to_verify' command..."
  if is_program_installed "$program_to_verify"; then
    log_info "Attempting to get version or status: $program_to_verify $verification_arguments"
    local verification_output
    local verification_exit_status
    # Using eval to correctly interpret verification_arguments if it contains spaces or multiple options
    # Capture both stdout and stderr
    verification_output=$(eval "$program_to_verify $verification_arguments" 2>&1)
    verification_exit_status=$?
    log_info "Output of '$program_to_verify $verification_arguments':"
    # Log multiline output correctly
    while IFS= read -r line; do log_info "  $line"; done <<<"$verification_output"

    if [ $verification_exit_status -eq 0 ]; then
      log_info "✅ '$program_to_verify' verification successful (command exited with 0)."
    else
      # For many tools, a non-zero exit for a version check is not a critical failure.
      log_warning "⚠️ '$program_to_verify $verification_arguments' exited with status $verification_exit_status. This might be normal for some tools."
    fi
  else
    log_error "❌ '$program_to_verify' not found in PATH. Verification failed."
    return 1
  fi
  return 0
}

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

# --- Linux specific common utilities loaded ---

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
