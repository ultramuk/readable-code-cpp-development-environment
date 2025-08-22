#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common OS-agnostic utilities
# shellcheck source=./common/utilities.sh
source "$SCRIPT_DIRECTORY/common/utilities.sh"

# --- OS Detection and Pre-flight Checks ---
detect_os                                   # This will export DETECTED_OPERATING_SYSTEM
OPERATING_SYSTEM=$DETECTED_OPERATING_SYSTEM # Assign to a script-local variable

# Perform OS-specific pre-flight checks
perform_os_preflight_checks

# --- Main Execution ---
# Execute the complete installation workflow
execute_installation_workflow "$OPERATING_SYSTEM" "$SCRIPT_DIRECTORY"
