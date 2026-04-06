#!/usr/bin/env bash
# Fake Claude Code /debug session for demo GIF recording

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

sleep 0.3
echo -e "${BOLD}> /debug${RESET}"
sleep 0.8

echo ""
echo -e "${CYAN}  REPRODUCE${RESET}"
echo -e "${GRAY}  Error: TypeError: Cannot read properties of undefined (reading 'headers')${RESET}"
echo -e "${GRAY}  at verifyToken (middleware/auth.js:23)${RESET}"
sleep 0.6

echo ""
echo -e "${CYAN}  LOCATE${RESET}"
echo -e "${GRAY}  Reading middleware/auth.js:23...${RESET}"
sleep 0.5
echo -e "${GRAY}  → req is undefined when middleware called without Express context${RESET}"
sleep 0.4

echo ""
echo -e "${CYAN}  ROOT CAUSE${RESET}"
echo -e "${YELLOW}  verifyToken() assumes req exists but route registration is missing middleware args${RESET}"
sleep 0.5

echo ""
echo -e "${CYAN}  FIX — middleware/auth.js:23${RESET}"
echo -e "${RED}  - const token = req.headers.authorization?.split(' ')[1]${RESET}"
echo -e "${GREEN}  + if (!req?.headers) return next(new Error('Bad request'))${RESET}"
echo -e "${GREEN}  + const token = req.headers.authorization?.split(' ')[1]${RESET}"
sleep 0.8

echo ""
echo -e "${GREEN}  Fix applied. Run tests to verify.${RESET}"
sleep 0.5
