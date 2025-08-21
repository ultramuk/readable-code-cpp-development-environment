#!/bin/bash

set -euo pipefail

# This script installs the Fira Code font on Linux.

# Get the directory of the currently executing script
INSTALL_CODING_FONT_LINUX_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common_utils.sh
source "$INSTALL_CODING_FONT_LINUX_DIRECTORY/common_utils.sh"

# --- Configuration ---
FONT_NAME="FiraCode"
FONT_PACKAGE_NAME="fonts-firacode"

# --- Main Logic ---
log_info "✍️  Installing $FONT_NAME font for Linux..."

# Check if font-config utility is available
validate_required_programs "fc-list"

# Check if the font is already installed
if fc-list | grep -i "$FONT_NAME" >/dev/null; then
  log_info "✅ $FONT_NAME font is already installed."
else
  log_info "Font '$FONT_NAME' not found. Proceeding with installation of '$FONT_PACKAGE_NAME'..."

  # Update apt-cache and install the font package.
  # The script will exit on failure due to 'set -euo pipefail'.
  update_apt_cache
  install_with_apt "$FONT_PACKAGE_NAME"

  log_info "✅ $FONT_PACKAGE_NAME package installed. Restart your applications to use the '$FONT_NAME' font."
fi
