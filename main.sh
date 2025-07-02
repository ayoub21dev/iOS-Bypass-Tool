#!/bin/bash

# ==============================================================================
# Main Script for iOS-Bypass-Tool
# Coded by: Ayoub 
# Version: 7.0 - The Conductor
#
# This script orchestrates the jailbreak and bypass processes.
# ==============================================================================

# --- Strict Mode ---
set -euo pipefail
IFS=$'\n\t'

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Default Configuration ---
JAILBREAK_MODE="--fakefs" # Default mode
IOS_VERSION="" # Let palera1n autodetect by default
DRY_RUN=false

# --- Helper Functions ---
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Orchestrates the jailbreak and bypass for checkm8 devices."
    echo ""
    echo "Options:"
    echo "  -m, --mode <mode>      Jailbreak mode. Either '--fakefs' (default) or '--rootless'."
    echo "  -i, --ios <version>    (Optional) Specify iOS version for palera1n."
    echo "      --dry-run          Print what the script would do without executing."
    echo "  -h, --help             Show this help message."
    exit 0
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mode) JAILBREAK_MODE="$2"; shift ;;
        -i|--ios) IOS_VERSION="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help) show_help ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# --- Sudo Check ---
# We need root privileges to run the sub-scripts
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script needs to be run with root privileges.${NC}"
   echo "Please use: sudo $0"
   exit 1
fi

# --- Welcome Message ---
echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}    Welcome to the iOS Bypass Tool   ${NC}"
echo -e "${YELLOW}      --- Coded by Ayoub & AI ---    ${NC}"
echo -e "${YELLOW}=====================================${NC}"
echo ""

# --- Dry Run Check ---
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] The script would perform the following steps:${NC}"
    echo "1. Run jailbreak.sh with mode: '$JAILBREAK_MODE' and iOS version: '${IOS_VERSION:-Not Specified}'"
    echo "2. If successful, run bypass.sh"
    exit 0
fi

# --- Main Execution Flow ---
echo -e "${YELLOW}--> Step 1: Running the Jailbreak script...${NC}"
# Pass the parsed arguments to the jailbreak script
./jailbreak.sh "$JAILBREAK_MODE" "$IOS_VERSION"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[INFO] Jailbreak script completed successfully.${NC}"
    echo ""
    echo -e "${YELLOW}--> Step 2: Running the Bypass script...${NC}"
    ./bypass.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] The bypass script failed.${NC}"
        exit 1
    fi
else
    echo -e "${RED}[ERROR] The jailbreak script failed. Cannot proceed to bypass.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}[SUCCESS] Tool has finished all tasks!${NC}"
