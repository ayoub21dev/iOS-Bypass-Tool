#!/bin/bash

# ==============================================================================
# Main Script for iOS-Bypass-Tool
# Coded by: Ayoub

#
# This script orchestrates the jailbreak and bypass processes,
# parsing user arguments and managing the overall workflow.
# ==============================================================================

# --- Strict Mode ---
set -euo pipefail
IFS=$'\n\t'

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Default Configuration ---
JAILBREAK_MODE="--fakefs" # Default mode
IOS_VERSION="" # Let palera1n autodetect by default
SIMULATE=false

# --- Helper Functions ---
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; exit 1; }

show_help() {
    echo "Usage: sudo $0 [OPTIONS]"
    echo "Orchestrates the jailbreak and bypass for checkm8 devices."
    echo ""
    echo "Options:"
    echo "  -m, --mode <mode>      Jailbreak mode. Either '--fakefs' (default) or '--rootless'."
    echo "  -i, --ios <version>    (Optional) Specify iOS version for palera1n (e.g., 15.7)."
    echo "      --simulate         Run in simulation mode without executing real commands."
    echo "  -h, --help             Show this help message."
    exit 0
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mode) JAILBREAK_MODE="$2"; shift ;;
        -i|--ios) IOS_VERSION="$2"; shift ;;
        --simulate) SIMULATE=true ;;
        -h|--help) show_help ;;
        *) warn "Unknown parameter passed: $1"; show_help; ;;
    esac
    shift
done

# --- Sudo Check ---
if [[ $EUID -ne 0 ]]; then
   error "This script needs to be run with root privileges.\nPlease use: sudo $0"
fi

# --- Welcome Message ---
echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}    Welcome to the iOS Bypass Tool   ${NC}"
echo -e "${YELLOW}      --- Coded by Ayoub & AI ---    ${NC}"
echo -e "${YELLOW}=====================================${NC}"
echo ""

# --- Mode Indicator ---
info "Selected Jailbreak Mode: $JAILBREAK_MODE"
if [[ "$JAILBREAK_MODE" == "--fakefs" ]]; then
    warn "You have selected a tethered/semi-tethered mode."
    warn "You will need to use this tool again if the device reboots."
fi
echo ""

# --- Main Execution Flow ---
info "--> Step 1: Running the Jailbreak script..."
# Pass the parsed arguments to the jailbreak script
./jailbreak.sh "$JAILBREAK_MODE" "$IOS_VERSION" "$SIMULATE"

if [ $? -eq 0 ]; then
    success "Jailbreak script completed successfully."
    echo ""
    info "--> Step 2: Running the Bypass script..."
    ./bypass.sh "$SIMULATE"
    if [ $? -ne 0 ]; then
        error "The bypass script failed."
    fi
else
    error "The jailbreak script failed. Cannot proceed to bypass."
fi

echo ""
success "✅ ALL DONE! The tool has finished all tasks successfully."
echo -e "${GREEN}Your device should now be bypassed. Enjoy!${NC}"
