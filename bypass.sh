#!/bin/bash

# ==============================================================================
# Bypass Script for iOS-Bypass-Tool
# Coded by: Ayoub
# ==============================================================================

# --- Strict Mode & Safety Net ---
set -euo pipefail
IFS=$'\n\t'

# --- Cleanup Trap ---
trap 'echo -e "\n${YELLOW}[WARNING] Bypass script interrupted.${NC}"' ERR INT TERM

# --- Logging Setup ---
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bypass-$(date +%Y%m%d-%H%M%S).log"
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
SIMULATE=${1:-false}

# --- Configuration ---
SSH_RD_SCRIPT="./sshrd.sh"
SSH_RD_URL="https://raw.githubusercontent.com/verygenericname/SSHRD_Script/main/sshrd.sh"

# --- Download Logic ---
if [ -f "$SSH_RD_SCRIPT" ]; then
    success "SSH_RD script already exists. Skipping download."
else
    info "Downloading SSH_RD script..."
    if command -v curl &>/dev/null; then curl -L -o "$SSH_RD_SCRIPT" "$SSH_RD_URL"; else wget -O "$SSH_RD_SCRIPT" "$SSH_RD_URL"; fi
    chmod +x "$SSH_RD_SCRIPT"
    success "Download complete."
fi

# --- Bypass Steps ---
warn "IMPORTANT: The device should be in DFU mode for this step."
read -p "--> Press [Enter] to start the SSH Ramdisk and Bypass process..."

MAX_RETRIES=3
RETRY_COUNT=0

if [ "$SIMULATE" = true ]; then
    warn "[SIMULATION] Pretending to build and boot SSH Ramdisk..."
    sleep 2
    info "[SIMULATION] Pretending to connect via SSH and apply bypass..."
    warn "[SIMULATION] Would run the following commands on the device:"
    echo "   -> mount -uw /mnt6/ && mount -uw /mnt1/"
    echo "   -> mv /mnt6/Applications/Setup.app /mnt6/Applications/Setup.app.bak"
    echo "   -> rm -rf /mnt1/mobile/Library/Accounts/"
    echo "   -> reboot"
    sleep 2
else
    # --- REAL PATH ---
    until ./"$SSH_RD_SCRIPT" boot; do
        RETRY_COUNT=$((RETRY_COUNT+1))
        if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
            error "Failed to boot SSH Ramdisk after $MAX_RETRIES attempts."
        fi
        warn "Boot failed. Retrying in 5 seconds... (Attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
        sleep 5
    done
    success "SSH Ramdisk booted successfully!"

    info "Connecting via SSH and applying bypass..."
    ssh -p 2222 -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" root@localhost << 'EOF'
# Stop on first error to prevent partial bypass
set -e

echo "--> Mounting filesystems with write access..."
mount -uw /mnt6/ && mount -uw /mnt1/
echo "--> Filesystems mounted."

if [ -d "/mnt6/Applications/Setup.app" ]; then
    echo "--> Renaming Setup.app to disable it..."
    mv /mnt6/Applications/Setup.app /mnt6/Applications/Setup.app.bak
    echo "--> Setup.app has been renamed."
else
    echo "--> Setup.app not found, skipping rename."
fi

if [ -d "/mnt1/mobile/Library/Accounts/" ]; then
    echo "--> Deleting iCloud account data..."
    rm -rf /mnt1/mobile/Library/Accounts/
    echo "--> Accounts directory has been deleted."
else
    echo "--> Accounts directory not found, skipping delete."
fi

echo "--> Bypass commands sent successfully! Rebooting device now..."
reboot
EOF
fi

success "Bypass script completed! The device should reboot into the Home Screen."
