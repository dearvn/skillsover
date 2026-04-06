#!/usr/bin/env bash
# Fake Claude Code session for demo GIF recording

GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

sleep 0.3
echo -e "${GRAY}Claude Code — type /help for commands${RESET}"
echo ""
echo -e "${BOLD}> /commit${RESET}"
sleep 0.8

echo ""
echo -e "${CYAN}  Reading staged diff...${RESET}"
sleep 0.5
echo -e "${GRAY}  git diff --staged → api/auth.js (1 file, +1 line)${RESET}"
sleep 0.6

echo ""
echo -e "${GREEN}  Commit type:${RESET} feat"
echo -e "${GREEN}  Scope:${RESET}       auth"
sleep 0.4

echo ""
echo -e "${BOLD}  feat(auth): add rate limiting to login endpoint${RESET}"
echo ""
echo -e "${GRAY}  Prevents brute-force by capping failed login attempts per IP.${RESET}"
sleep 0.6

echo ""
echo -e "${CYAN}  Running git commit...${RESET}"
sleep 0.5
echo -e "${GREEN}  [main 4a2f1c9] feat(auth): add rate limiting to login endpoint${RESET}"
echo -e "${GRAY}   1 file changed, 1 insertion(+)${RESET}"
sleep 0.8
