#!/bin/bash

set -euo pipefail

# Guard to prevent multiple sourcing
if [[ -n "${UTILITIES_LOADED:-}" ]]; then
  return 0
fi
readonly UTILITIES_LOADED=1

# Common OS-agnostic utility functions

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

# Indicate that OS-agnostic utilities have been loaded (optional, for debugging)
# log_info "OS-agnostic utilities loaded."

# Detects the current operating system and exports it as DETECTED_OS
# Usage: detect_os
#        echo "Running on: $DETECTED_OS"
detect_os()
{
  local detected_os_type
  if [[ -z "${OSTYPE-''}" ]]; then
    case "$(uname -s)" in
      Darwin*) detected_os_type="darwin" ;;
      Linux*) detected_os_type="linux-gnu" ;;
      *) detected_os_type="unknown" ;;
    esac
  else
    detected_os_type="$OSTYPE"
  fi

  if [[ "$detected_os_type" == "darwin"* ]]; then
    export DETECTED_OPERATING_SYSTEM="macos"
  elif [[ "$detected_os_type" == "linux-gnu"* ]]; then
    export DETECTED_OPERATING_SYSTEM="linux"
  else
    log_error "❌ Unsupported operating system: '$detected_os_type'"
    exit 1
  fi
  log_info "Operating System detected: $DETECTED_OPERATING_SYSTEM"
}

# Performs OS-specific pre-flight checks
# Usage: perform_os_preflight_checks
perform_os_preflight_checks()
{
  local os="$DETECTED_OPERATING_SYSTEM"

  case "$os" in
    "macos")
      log_info "🔍 Running macOS pre-flight checks..."
      validate_required_programs "brew"
      log_info "✅ macOS pre-flight checks completed successfully"
      ;;
    "linux")
      log_info "🔍 Running Linux pre-flight checks..."
      validate_required_programs "apt-get" "sudo"
      log_info "✅ Linux pre-flight checks completed successfully"
      ;;
    *)
      handle_error "$ERROR_GENERAL" "Unsupported operating system for pre-flight checks: $os"
      ;;
  esac
}

# Defines the installation steps for the specified OS
# Usage: get_installation_steps <operating_system> <script_directory>
get_installation_steps()
{
  local os="$1"
  local script_directory="$2"
  local target_directory="$script_directory/$os"

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

# Executes all installation steps for the specified OS
# Usage: execute_installation_workflow <operating_system> <script_directory>
execute_installation_workflow()
{
  local os="$1"
  local script_directory="$2"

  log_info "🚀 Starting installation workflow for $os..."

  # Get installation steps and execute each one
  # Using temporary file for maximum compatibility
  local temp_steps_file
  temp_steps_file=$(mktemp)
  get_installation_steps "$os" "$script_directory" >"$temp_steps_file"

  while IFS= read -r step; do
    if [[ -n "$step" ]]; then
      execute_installation_step "$step"
    fi
  done <"$temp_steps_file"

  rm -f "$temp_steps_file"

  log_info "🎉 ✅ All components installed and configured successfully for $os!"
}

# --- OS-Agnostic Program and Command Utilities ---

# Checks if a program (command) is installed and in PATH.
# This function is universal for any POSIX-compliant shell.
# Usage: if is_program_installed "git"; then ...
is_program_installed()
{
  local program_name="$1"
  command -v "$program_name" &>/dev/null
}

# Verifies if a command is available and executable by running it with a version flag.
# This is generally OS-agnostic, as most command-line tools support a --version or similar flag.
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
