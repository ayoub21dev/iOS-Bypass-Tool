#!/bin/bash

# --- الألوان ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- بداية البرنامج ---
echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}    Welcome to the iOS Bypass Tool   ${NC}"
echo -e "${YELLOW}=====================================${NC}"
echo ""
echo -e "${GREEN}[INFO] Starting the process...${NC}"
echo ""

# --- استدعاء سكريبت الجيلبريك ---
echo -e "${YELLOW}--> Step 1: Running the Jailbreak script...${NC}"
./jailbreak.sh

echo ""
echo -e "${GREEN}[INFO] Main script finished.${NC}"
