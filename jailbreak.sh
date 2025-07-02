#!/bin/bash

# ==============================================================================
# Jailbreak Script for iOS-Bypass-Tool
# Coded by: Ayoub 
# Version: 7.0 - The Professional
# ==============================================================================

# --- Strict Mode & Safety Net ---
set -euo pipefail
IFS=$'\n\t'

# --- Logging Setup ---
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/jailbreak-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log file for this session: $LOG_FILE"
echo "-------------------------------------"

# --- Color Definitions & Helpers ---
# (You can copy the color and helper function definitions from the previous version)
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; exit 1; } # Exit on error

# --- Sudo Check ---
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root."
fi

# --- Receive Arguments from main.sh ---
JAILBREAK_MODE=${1:---fakefs} # Default to --fakefs if not provided
IOS_VERSION=${2:-} # Default to empty string if not provided

# --- Architecture and Binary Configuration ---
ARCH=$(uname -m)
PALERA1N_BINARY=""
PALERA1N_URL=""

info "Detecting architecture..."
case "$ARCH" in
  x86_64)
    PALERA1N_BINARY="./palera1n-linux-x86_64"
    PALERA1N_URL="https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-x86_64"
    success "Architecture detected: x86_64"
    ;;
  aarch64 | arm64)
    PALERA1N_BINARY="./palera1n-linux-arm64"
    PALERA1N_URL="https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-arm64"
    success "Architecture detected: arm64/aarch64"
    ;;
  *)
    error "Unsupported architecture: $ARCH."
    ;;
esac

# --- Download Logic ---
if [ -f "$PALERA1N_BINARY" ]; then
    success "palera1n binary already exists. Skipping download."
else
    info "Downloading palera1n for $ARCH..."
    if command -v curl &>/dev/null; then
        curl -L -o "$PALERA1N_BINARY" "$PALERA1N_URL"
    elif command -v wget &>/dev/null; then
        wget -O "$PALERA1N_BINARY" "$PALERA1N_URL"
    else
        error "Neither 'curl' nor 'wget' is available."
    fi
    if [ ! -s "$PALERA1N_BINARY" ]; then rm -f "$PALERA1N_BINARY"; error "Download failed or file is empty."; fi
    chmod +x "$PALERA1N_BINARY"
    success "Download and setup complete."
fi

# --- Execution Logic ---
success "palera1n is ready to use."
warn "IMPORTANT: The next step will start the jailbreak."
read -p "--> Press [Enter] when you are ready to begin..."

info "Starting palera1n with mode: $JAILBREAK_MODE"

# Build the final command
CMD_ARGS=()
CMD_ARGS+=("$JAILBREAK_MODE")
if [ -n "$IOS_VERSION" ]; then
    # Note: The pre-built binary might not support --tweaks. This is for future-proofing.
    # For now, palera1n v2.0.2 does not use this.
    # CMD_ARGS+=("--tweaks" "$IOS_VERSION")
    warn "iOS version argument is provided but might be ignored by this palera1n version."
fi

# We don't need sudo here anymore because the script is already running as root
"$PALERA1N_BINARY" "${CMD_ARGS[@]}"

success "Jailbreak script completed."
