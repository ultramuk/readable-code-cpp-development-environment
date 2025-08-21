#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_CLANG_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_CLANG_MACOS_DIRECTORY/common_utils.sh"

# --- Helper Functions ---

# Checks if all specified tools are installed and available in the PATH.
# Returns 0 if all tools are found, 1 otherwise.
check_if_all_tools_are_installed()
{
  for tool in "$@"; do
    if ! is_program_installed "$tool"; then
      log_info "Tool '$tool' is not installed."
      return 1 # Indicates at least one tool is missing
    fi
  done
  return 0 # All tools are installed
}

# Creates symlinks for the specified LLVM tools from the Homebrew llvm installation
# directory to the main Homebrew bin directory.
# Usage: create_llvm_symlinks "tool1" "tool2" ...
create_llvm_symlinks()
{
  log_info "Creating symlinks for LLVM tools..."
  local llvm_install_prefix
  local homebrew_bin_directory
  llvm_install_prefix="$(brew --prefix llvm)"
  homebrew_bin_directory="$(brew --prefix)/bin"

  mkdir -p "$homebrew_bin_directory"

  for tool_to_link in "$@"; do
    local llvm_tool_path="$llvm_install_prefix/bin/$tool_to_link"
    if [[ -f "$llvm_tool_path" ]]; then
      ln -sf "$llvm_tool_path" "$homebrew_bin_directory/$tool_to_link"
      log_info "✅ Symlink for '$tool_to_link' ensured."
    else
      log_warning "⚠️ Could not find '$tool_to_link' in the llvm installation directory."
    fi
  done
}

# --- Script Main Logic ---
log_info "🧱 Installing LLVM helper tools for macOS..."

# 1. Verify Apple Clang (System Default)
log_info "--- Verifying System's Apple clang ---"
if is_program_installed "clang"; then
  log_info "✅ System's 'clang' is available and will be used as the default C/C++ compiler."
  clang --version | head -n 1
else
  log_warning "⚠️ System's 'clang' not found. You might need to install Xcode Command Line Tools ('xcode-select --install')."
fi

# 2. Define and check for required LLVM helper tools
LLVM_HELPER_TOOLS=("clangd" "clang-format" "clang-tidy")
log_info "--- Verifying LLVM Helper Tools (clangd, clang-format, clang-tidy) ---"

if check_if_all_tools_are_installed "${LLVM_HELPER_TOOLS[@]}"; then
  log_info "✅ All required LLVM helper tools are already installed and available."
else
  log_info "Missing tools found. Installing 'llvm' package via Homebrew..."
  handle_critical_command "_install_with_brew \"llvm\" \"formula\"" "Installation of 'llvm' package failed"
  create_llvm_symlinks "${LLVM_HELPER_TOOLS[@]}"
fi

# 3. Final verification of all tools
log_info "--- Final Verification ---"
ALL_VERIFIED=true
for tool in "${LLVM_HELPER_TOOLS[@]}"; do
  if verify_command "$tool"; then
    log_info "✅ $tool is successfully verified."
  else
    log_error "❌ Verification failed for $tool after installation."
    ALL_VERIFIED=false
  fi
done

if [[ "$ALL_VERIFIED" == "false" ]]; then
  handle_error "$ERROR_VERIFICATION_FAILED" "One or more LLVM helper tools could not be set up correctly. Please check the logs."
fi

log_info "✅ All LLVM helper tools are now installed and verified."
