#!/bin/bash

# This script verifies that all essential tools are installed and executable after running the setup script.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Get the directory of the currently executing script
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common OS-agnostic utilities
# shellcheck source=./common/os_agnostic_utils.sh
source "$SCRIPT_DIRECTORY/common/os_agnostic_utils.sh"

# Detect the OS and source the appropriate# --- OS Detection ---
detect_os # This will export DETECTED_OPERATING_SYSTEM
OPERATING_SYSTEM=$DETECTED_OPERATING_SYSTEM

# Source OS-specific utilities
# shellcheck source=./macos/common_utils.sh
source "$SCRIPT_DIRECTORY/$OPERATING_SYSTEM/common_utils.sh"

log_info "🚀 Starting verification of installed tools..."

# List of essential commands to verify.
# Note: Font installation is hard to verify in a CI environment, so we skip it.
# VS Code is also skipped as it's a GUI application.
COMMANDS_TO_VERIFY=(
  "clang"
  "clangd"
  "clang-tidy"
  "clang-format"
  "lldb"
  "cmake"
  "ninja"
  "git"
  "gh"
)

# --- Helper Functions ---

# Verifies a single essential tool. Uses standardized error handling.
verify_essential_tool()
{
  local tool_name="$1"
  echo
  log_info "--- Verifying '$tool_name' ---"

  if ! is_program_installed "$tool_name"; then
    handle_error "$ERROR_DEPENDENCY_MISSING" "'$tool_name' is not installed or not in PATH. Please run the setup script."
  fi

  if ! verify_command "$tool_name"; then
    handle_error "$ERROR_VERIFICATION_FAILED" "'$tool_name' was found, but verification (e.g., --version) failed."
  fi

  log_info "✅ '$tool_name' is installed and verified."
}

# --- Main Verification Logic ---

for tool in "${COMMANDS_TO_VERIFY[@]}"; do
  verify_essential_tool "$tool"
done

echo
log_info "🎉 All essential tools are installed and verified successfully!"
