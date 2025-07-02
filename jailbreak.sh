#!/bin/bash

# ==============================================================================
# Jailbreak Script for iOS-Bypass-Tool
# Coded by: Ayoubl
# ==============================================================================

# --- Strict Mode & Safety Net ---
set -euo pipefail
IFS=$'\n\t'

# --- Cleanup Trap ---
cleanup() {
    echo ""
    warn "An error occurred or the script was interrupted."
    warn "Cleaning up any partial downloads..."
    [ -f "./palera1n-linux-x86_64" ] && rm -f "./palera1n-linux-x86_64"
    [ -f "./palera1n-linux-arm64" ] && rm -f "./palera1n-linux-arm64"
    info "Cleanup complete."
}
trap cleanup ERR INT TERM

# --- Logging Setup ---
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/jailbreak-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log file for this session: $LOG_FILE"
uname -a
echo "-------------------------------------"

# --- Color Definitions & Helpers ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; exit 1; }

# --- Sudo Check ---
if [[ $EUID -ne 0 ]]; then error "This script must be run as root."; fi
info "Running with root privileges."

# --- Receive Arguments ---
JAILBREAK_MODE=${1:---fakefs}
IOS_VERSION=${2:-}
SIMULATE=${3:-false}

# --- Initial Device Check ---
info "Checking for connected device in normal mode..."
if ! command -v ideviceinfo &>/dev/null; then
    warn "'ideviceinfo' not found. Skipping device check. To enable, run: sudo apt install libimobiledevice-utils"
elif ! ideviceinfo -q &>/dev/null; then
    warn "No device detected in normal mode. This is okay if you plan to connect it later."
else
    success "Device detected in normal mode!"
fi

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
  *) error "Unsupported architecture: $ARCH."; ;;
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
    if [ ! -s "$PALERA1N_BINARY" ]; then error "Download failed or file is empty."; fi
    chmod +x "$PALERA1N_BINARY"
    success "Download and setup complete."
fi

# --- Execution Logic ---
success "------------------------------------------------"
success "  palera1n is ready to use.                     "
success "------------------------------------------------"
warn "IMPORTANT: The next step will start the jailbreak."
read -p "--> Press [Enter] when you are ready to begin..."

# --- Build palera1n command ---
CMD_ARGS=() # Start with an empty array
if [ -n "$IOS_VERSION" ]; then
    info "Using specified iOS version: $IOS_VERSION"
    CMD_ARGS+=("--override-version" "$IOS_VERSION")
else
    info "Auto-detecting iOS version."
fi
CMD_ARGS+=("$JAILBREAK_MODE") # Add the main jailbreak mode

info "Starting palera1n with command: --tweaks ${CMD_ARGS[@]}"

if [ "$SIMULATE" = true ]; then
    warn "[SIMULATION] Pretending to run palera1n..."
    warn "[SIMULATION] Full command that would run: $PALERA1N_BINARY --tweaks ${CMD_ARGS[@]}"
    sleep 3
    success "[SIMULATION] palera1n has 'finished' successfully."
else
    # We add --tweaks because it's required for SSH to work for the bypass
    if ! "$PALERA1N_BINARY" --tweaks "${CMD_ARGS[@]}"; then
        error "palera1n command failed. Check the log above for details."
    fi
fi

success "Jailbreak script completed."
