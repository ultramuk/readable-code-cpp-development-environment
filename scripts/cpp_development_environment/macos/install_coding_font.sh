#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
INSTALL_CODING_FONT_MACOS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source common utilities
# shellcheck source=./common_utils.sh
source "$INSTALL_CODING_FONT_MACOS_DIRECTORY/common_utils.sh"

# --- Constants ---
FONT_NAME="Fira Code"
FONT_VERSION="6.2"
FONT_PRESENCE_CHECK_FILE="$HOME/Library/Fonts/FiraCode-Bold.ttf"
FONT_DIRECTORY="$HOME/Library/Fonts"
DOWNLOAD_URL="https://github.com/tonsky/FiraCode/releases/download/${FONT_VERSION}/Fira_Code_v${FONT_VERSION}.zip"
TEMPORARY_DIRECTORY="/tmp/FiraCode_install"

# --- Helper Functions ---

# Ensures the temporary directory is cleaned up on script exit.
cleanup()
{
  if [ -d "$TEMPORARY_DIRECTORY" ]; then
    log_info "🧹 Cleaning up temporary files..."
    rm -rf "$TEMPORARY_DIRECTORY"
  fi
}

# Downloads, unzips, and installs the Fira Code font.
download_and_install_fira_code()
{
  local temporary_zip_file="$TEMPORARY_DIRECTORY/FiraCode.zip"

  log_info "📥 Downloading and installing $FONT_NAME..."
  mkdir -p "$TEMPORARY_DIRECTORY"

  log_info "Downloading from $DOWNLOAD_URL..."
  handle_critical_command "curl -f -L -o \"$temporary_zip_file\" \"$DOWNLOAD_URL\"" "Failed to download Fira Code font. Please check the URL or your network connection"

  log_info "📦 Unzipping font..."
  # Redirect only stdout to /dev/null to hide file list but still show errors.
  handle_critical_command "unzip -o \"$temporary_zip_file\" -d \"$TEMPORARY_DIRECTORY/extracted_fonts\" >/dev/null" "Failed to unzip the font archive. It may be corrupted"

  log_info "📂 Copying font files to $FONT_DIRECTORY..."
  mkdir -p "$FONT_DIRECTORY"
  handle_critical_command "cp \"$TEMPORARY_DIRECTORY/extracted_fonts/ttf/\"*.ttf \"$FONT_DIRECTORY/\"" "Failed to copy font files. Please check permissions for $FONT_DIRECTORY"

  log_info "✅ $FONT_NAME font installed successfully."
}

# --- Script Main Logic ---

# Register the cleanup function to be called on script exit.
trap cleanup EXIT

log_info "✍️  Installing Fira Code font (macOS)..."

if [ -f "$FONT_PRESENCE_CHECK_FILE" ]; then
  log_info "✅ $FONT_NAME font is already present."
else
  download_and_install_fira_code
  log_info "📌 Restart your terminal, IDE, and other applications to see the new font."
fi

log_info "Fira Code font installation script finished."
