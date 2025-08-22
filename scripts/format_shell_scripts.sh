#!/bin/bash

set -euo pipefail

# Shell Script Formatter for C++ Development Environment Project
# This script formats all shell scripts in the project using shfmt with consistent rules

# Get the directory of the currently executing script
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common OS-agnostic utilities
# shellcheck source=./cpp_development_environment/common/utilities.sh
source "$SCRIPT_DIRECTORY/cpp_development_environment/common/utilities.sh"

# --- Configuration ---
readonly SHFMT_INDENT=2              # 2 spaces indentation
readonly SHFMT_BINARY_NEXT_LINE=true # Binary operators on next line
# readonly SHFMT_CASE_INDENT=true         # Indent case statements (not used, built into -ci)
readonly SHFMT_FUNCTION_NEXT_LINE=false # Function opening brace on same line

# --- Helper Functions ---

# Installs shfmt if not already available
ensure_shfmt_installed()
{
  log_info "🔍 Checking for shfmt installation..."

  if is_program_installed "shfmt"; then
    log_info "✅ shfmt is already installed"
    return 0
  fi

  log_info "📦 Installing shfmt..."

  case "$DETECTED_OPERATING_SYSTEM" in
    "macos")
      handle_critical_command "brew install shfmt" "Failed to install shfmt via Homebrew"
      ;;
    "linux")
      # Install shfmt via Go (most reliable method for Linux)
      if ! is_program_installed "go"; then
        log_info "Installing Go first (required for shfmt)..."
        update_apt_cache
        handle_critical_command "sudo apt-get install -y golang-go" "Failed to install Go"
      fi
      handle_critical_command "go install mvdan.cc/sh/v3/cmd/shfmt@latest" "Failed to install shfmt via Go"

      # Add GOPATH/bin to PATH if not already there
      local gopath_bin
      gopath_bin="$(go env GOPATH)/bin"
      if [[ ":$PATH:" != *":$gopath_bin:"* ]]; then
        export PATH="$PATH:$gopath_bin"
        log_info "Added $gopath_bin to PATH for current session"
      fi
      ;;
    *)
      handle_error "$ERROR_GENERAL" "Unsupported operating system for shfmt installation: $DETECTED_OPERATING_SYSTEM"
      ;;
  esac

  log_info "✅ shfmt installed successfully"
}

# Gets all shell script files in the project
get_shell_script_files()
{
  find "$SCRIPT_DIRECTORY" -name "*.sh" -type f | sort
}

# Formats a single shell script file
format_shell_script()
{
  local script_file="$1"
  local relative_path="${script_file#"$SCRIPT_DIRECTORY"/}"

  log_info "📝 Formatting: $relative_path"

  # Create backup
  local backup_file="${script_file}.backup"
  cp "$script_file" "$backup_file"

  # Format with shfmt
  local shfmt_args=(
    "-i" "$SHFMT_INDENT"
    "-ci" # indent case statements
    "-w"  # write to file
  )

  if [[ "$SHFMT_BINARY_NEXT_LINE" == "true" ]]; then
    shfmt_args+=("-bn")
  fi

  if [[ "$SHFMT_FUNCTION_NEXT_LINE" == "false" ]]; then
    shfmt_args+=("-fn")
  fi

  if shfmt "${shfmt_args[@]}" "$script_file"; then
    rm "$backup_file" # Remove backup if successful
    log_info "✅ Formatted: $relative_path"
  else
    # Restore backup if formatting failed
    mv "$backup_file" "$script_file"
    log_warning "⚠️ Failed to format: $relative_path (restored from backup)"
    return 1
  fi
}

# Validates that all scripts are properly formatted
validate_formatting()
{
  log_info "🔍 Validating shell script formatting..."

  local validation_failed=false
  local temp_file
  temp_file=$(mktemp)

  # Get list of shell scripts
  local script_list_file
  script_list_file=$(mktemp)
  get_shell_script_files >"$script_list_file"

  while IFS= read -r script_file; do
    local relative_path="${script_file#"$SCRIPT_DIRECTORY"/}"

    # Use the same shfmt options as formatting
    local shfmt_args=(
      "-i" "$SHFMT_INDENT"
      "-ci" # indent case statements
      "-d"  # diff mode
    )

    if [[ "$SHFMT_BINARY_NEXT_LINE" == "true" ]]; then
      shfmt_args+=("-bn")
    fi

    if [[ "$SHFMT_FUNCTION_NEXT_LINE" == "false" ]]; then
      shfmt_args+=("-fn")
    fi

    if ! shfmt "${shfmt_args[@]}" "$script_file" >"$temp_file" 2>/dev/null; then
      log_warning "⚠️ Formatting issues found in: $relative_path"
      validation_failed=true
    fi
  done <"$script_list_file"

  rm -f "$script_list_file"

  rm -f "$temp_file"

  if [[ "$validation_failed" == "true" ]]; then
    log_warning "Some scripts have formatting issues. Run with --format to resolve."
    return 1
  else
    log_info "✅ All shell scripts are properly formatted"
    return 0
  fi
}

# Checks shell scripts with shellcheck
run_shellcheck()
{
  log_info "🔍 Running shellcheck on all shell scripts..."

  if ! is_program_installed "shellcheck"; then
    log_warning "shellcheck not found. Installing..."
    case "$DETECTED_OPERATING_SYSTEM" in
      "macos")
        handle_critical_command "brew install shellcheck" "Failed to install shellcheck"
        ;;
      "linux")
        update_apt_cache
        handle_critical_command "sudo apt-get install -y shellcheck" "Failed to install shellcheck"
        ;;
    esac
  fi

  local shellcheck_failed=false

  # Get list of shell scripts
  local script_list_file
  script_list_file=$(mktemp)
  get_shell_script_files >"$script_list_file"

  while IFS= read -r script_file; do
    local relative_path="${script_file#"$SCRIPT_DIRECTORY"/}"

    if ! shellcheck "$script_file"; then
      log_warning "⚠️ shellcheck issues found in: $relative_path"
      shellcheck_failed=true
    fi
  done <"$script_list_file"

  rm -f "$script_list_file"

  if [[ "$shellcheck_failed" == "true" ]]; then
    log_warning "Some scripts have shellcheck issues. Please review and fix."
    return 1
  else
    log_info "✅ All shell scripts pass shellcheck"
    return 0
  fi
}

# Shows usage information
show_usage()
{
  cat <<EOF
Shell Script Formatter for C++ Development Environment

Usage: $0 [OPTIONS]

OPTIONS:
  --format, -f     Format all shell scripts in the project
  --check, -c      Check if all scripts are properly formatted (no changes)
  --shellcheck, -s Run shellcheck on all shell scripts
  --all, -a        Run format, check, and shellcheck
  --help, -h       Show this help message

Examples:
  $0 --format              # Format all shell scripts
  $0 --check               # Check formatting without changes
  $0 --shellcheck          # Run shellcheck
  $0 --all                 # Format and validate everything

EOF
}

# --- Main Logic ---

# Detect OS first
detect_os

# Parse command line arguments
if [[ $# -eq 0 ]]; then
  show_usage
  exit 0
fi

case "$1" in
  --format | -f)
    log_info "🎨 Shell Script Formatting Started..."
    ensure_shfmt_installed

    script_count=0
    formatted_count=0
    failed_count=0

    # Get list of shell scripts
    script_list_file=$(mktemp)
    get_shell_script_files >"$script_list_file"

    while IFS= read -r script_file; do
      ((script_count++))
      if format_shell_script "$script_file"; then
        ((formatted_count++))
      else
        ((failed_count++))
      fi
    done <"$script_list_file"

    rm -f "$script_list_file"

    echo ""
    log_info "📊 Formatting Summary:"
    log_info "  Total scripts: $script_count"
    log_info "  Successfully formatted: $formatted_count"
    if [[ $failed_count -gt 0 ]]; then
      log_warning "  Failed to format: $failed_count"
      exit 1
    else
      log_info "✅ All shell scripts formatted successfully!"
    fi
    ;;

  --check | -c)
    log_info "🔍 Checking shell script formatting..."
    ensure_shfmt_installed
    validate_formatting
    ;;

  --shellcheck | -s)
    log_info "🔍 Running shellcheck..."
    run_shellcheck
    ;;

  --all | -a)
    log_info "🚀 Running complete shell script validation..."
    ensure_shfmt_installed

    log_info ""
    log_info "Step 1: Formatting all scripts..."
    "$0" --format

    log_info ""
    log_info "Step 2: Validating formatting..."
    validate_formatting

    log_info ""
    log_info "Step 3: Running shellcheck..."
    run_shellcheck

    log_info ""
    log_info "🎉 ✅ All shell script validation completed successfully!"
    ;;

  --help | -h | *)
    show_usage
    ;;
esac
