#!/bin/bash

set -euo pipefail

# Get the directory of the currently executing script
SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common utilities
# shellcheck source=./common/utilities.sh
source "$SCRIPT_DIRECTORY/common/utilities.sh"

# Perform pre-flight checks
perform_preflight_checks

# --- Main Execution ---
# Execute the complete installation workflow
execute_installation_workflow "$SCRIPT_DIRECTORY"
