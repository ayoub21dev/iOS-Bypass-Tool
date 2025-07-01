#!/bin/bash

# A script to handle the jailbreak process using the pre-built palera1n binary
#
# Coded by: Ayoub & The AI 🧠
# Version: 5.2 - Added user confirmation step

# --- Colors ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Configuration ---
PALERA1N_URL="https://github.com/palera1n/palera1n/releases/latest/download/palera1n-linux-x86_64"
PALERA1N_BINARY="./palera1n-x86_64"

# --- Main Logic ---
echo -e "${BLUE}[JAILBREAK] Starting the jailbreak process...${NC}"

if [ -f "$PALERA1N_BINARY" ]; then
    echo -e "${GREEN}[JAILBREAK] palera1n binary already exists. Skipping download.${NC}"
else
    echo -e "${BLUE}[JAILBREAK] palera1n binary not found. Downloading from GitHub releases...${NC}"
    wget -O "$PALERA1N_BINARY" "$PALERA1N_URL"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[JAILBREAK-ERROR] Failed to download palera1n. Please check your internet connection.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}[JAILBREAK] Setting execution permissions...${NC}"
    chmod +x "$PALERA1N_BINARY"
    if [ $? -ne 0 ]; then
        echo -e "${RED}[JAILBREAK-ERROR] Failed to set permissions. Aborting.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}------------------------------------------------${NC}"
echo -e "${GREEN}  palera1n is ready to use.                     ${NC}"
echo -e "${GREEN}------------------------------------------------${NC}"

# --- ### NEW PART: User Confirmation Step ### ---
echo -e "${YELLOW}IMPORTANT: The next step will start the jailbreak.${NC}"
echo -e "${YELLOW}1. Please connect your iPhone to the computer now.${NC}"
echo -e "${YELLOW}2. Make sure the USB is passed through to this Virtual Machine.${NC}"
echo -e "${YELLOW}3. palera1n will guide you to enter Recovery and DFU mode.${NC}"
echo -e ""
read -p "--> Press [Enter] when you are ready to begin..."

# Now, run the palera1n command
echo -e "${BLUE}[JAILBREAK] Starting palera1n... Please follow the on-screen instructions carefully.${NC}"

# Execute with the correct argument for rootful jailbreak
sudo "$PALERA1N_BINARY" --fakefs

# Check the exit code
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[JAILBREAK] palera1n finished successfully!${NC}"
else
    echo -e "${RED}[JAILBREAK-ERROR] palera1n failed or was cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}[JAILBREAK] Jailbreak script completed successfully.${NC}"
