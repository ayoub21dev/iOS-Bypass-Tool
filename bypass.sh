#!/bin/bash

# ==============================================================================
# Bypass Script for iOS-Bypass-Tool
# Coded by: Ayoub &
# Version: 7.0 - The Professional
# ==============================================================================

# --- Strict Mode & Safety Net ---
set -euo pipefail
IFS=$'\n\t'

# --- Logging Setup ---
LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bypass-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log file for this session: $LOG_FILE"
echo "-------------------------------------"

# --- Color Definitions & Helpers ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; exit 1; }

# --- Sudo Check ---
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root."
fi

# --- Configuration ---
SSH_RD_SCRIPT="./ssh-rd.sh"
SSH_RD_URL="https://raw.githubusercontent.com/verygenericname/SSHRD_Script/main/sshrd.sh"

# --- Download Logic ---
if [ -f "$SSH_RD_SCRIPT" ]; then
    success "SSH_RD script already exists. Skipping download."
else
    info "Downloading SSH_RD script..."
    if command -v curl &>/dev/null; then
        curl -L -o "$SSH_RD_SCRIPT" "$SSH_RD_URL"
    else
        wget -O "$SSH_RD_SCRIPT" "$SSH_RD_URL"
    fi
    chmod +x "$SSH_RD_SCRIPT"
    success "Download complete."
fi

# --- Real Bypass Steps ---
warn "IMPORTANT: The device should be in DFU mode for this step."
read -p "--> Press [Enter] to start the SSH Ramdisk and Bypass process..."

info "Step 1: Building the SSH Ramdisk..."
./"$SSH_RD_SCRIPT" build

info "Step 2: Booting the SSH Ramdisk..."
./"$SSH_RD_SCRIPT" boot

info "Step 3: Connecting via SSH and renaming Setup.app..."
# The ssh-rd script opens a tunnel on port 2222.
ssh -p 2222 -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" root@localhost << EOF
mount -uw /mnt6/
if [ -d "/mnt6/Applications/Setup.app" ]; then
    mv /mnt6/Applications/Setup.app /mnt6/Applications/Setup.app.bak
    echo "Setup.app has been renamed. Rebooting..."
    reboot
else
    echo "Setup.app not found. It might have been already bypassed. Rebooting..."
    reboot
fi
EOF

success "Bypass script completed! The device will reboot into the Home Screen."
