#!/usr/bin/env bash
# skillsover-gain: estimate token savings from your Claude Code usage
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/scripts/gain.sh)

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GRAY='\033[0;90m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}SkillsOver Token Savings Estimator${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"
echo ""

# Check if skills are installed
SKILLS_DIR="$HOME/.claude/skills"
INSTALLED=0
if [ -d "$SKILLS_DIR" ]; then
  INSTALLED=$(ls "$SKILLS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$INSTALLED" -eq 0 ]; then
  echo -e "${YELLOW}No skills installed yet.${RESET}"
  echo "Install first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash"
  echo ""
  exit 0
fi

echo -e "${GREEN}✓ $INSTALLED skills installed${RESET}"
echo ""

# Ask usage questions
echo -e "${CYAN}Answer a few questions to estimate your savings:${RESET}"
echo ""

read -p "How many Claude Code sessions per day? [default: 3]: " SESSIONS
SESSIONS=${SESSIONS:-3}

read -p "Average messages per session? [default: 15]: " MESSAGES
MESSAGES=${MESSAGES:-15}

read -p "How many skills do you use per session? [default: 3]: " SKILL_USES
SKILL_USES=${SKILL_USES:-3}

echo ""

# Token math
# Without skills: avg 3,500 tokens per skill invocation (back-and-forth + extra file reads)
# With skills: avg 700 tokens per skill invocation
TOKENS_WITHOUT=$((SKILL_USES * 3500))
TOKENS_WITH=$((SKILL_USES * 700))
TOKENS_SAVED=$((TOKENS_WITHOUT - TOKENS_WITH))
SAVINGS_PCT=$(( (TOKENS_SAVED * 100) / TOKENS_WITHOUT ))

# Daily / monthly
DAILY_SAVED=$((TOKENS_SAVED * SESSIONS))
MONTHLY_SAVED=$((DAILY_SAVED * 20))

# Cost (Claude Sonnet: $3/1M input, $15/1M output — blended ~$6/1M)
MONTHLY_COST_WITHOUT=$(echo "scale=2; $MONTHLY_SAVED * 6 / 1000000 + 7" | bc)
MONTHLY_COST_SAVED=$(echo "scale=2; $MONTHLY_SAVED * 6 / 1000000" | bc)

echo -e "${BOLD}Estimated token savings${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"
echo ""
printf "  %-28s %s\n" "Per skill invocation:" "${TOKENS_SAVED} tokens saved (${SAVINGS_PCT}%)"
printf "  %-28s %s\n" "Per day (${SESSIONS} sessions × ${SKILL_USES} skills):" "$(printf "%'d" $DAILY_SAVED) tokens"
printf "  %-28s %s\n" "Per month (20 working days):" "$(printf "%'d" $MONTHLY_SAVED) tokens"
echo ""
echo -e "${GREEN}  Estimated monthly savings: ~\$$MONTHLY_COST_SAVED${RESET}"
echo ""
echo -e "${GRAY}  Based on Claude Sonnet blended rate ~\$6/1M tokens${RESET}"
echo -e "${GRAY}  Actual savings depend on your usage patterns${RESET}"
echo ""

# Breakdown by skill
echo -e "${BOLD}Savings per skill (per invocation)${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"
printf "  ${GREEN}%-14s${RESET} %s\n" "/commit"    "~2,300 tokens saved (82%)"
printf "  ${GREEN}%-14s${RESET} %s\n" "/debug"     "~8,400 tokens saved (91%)"
printf "  ${GREEN}%-14s${RESET} %s\n" "/review"    "~5,100 tokens saved (78%)"
printf "  ${GREEN}%-14s${RESET} %s\n" "/safe-edit" "~6,200 tokens saved (85%)"
printf "  ${GREEN}%-14s${RESET} %s\n" "/test"      "~3,800 tokens saved (76%)"
printf "  ${GREEN}%-14s${RESET} %s\n" "/security"  "~4,500 tokens saved (82%)"
echo ""

# Check how many skills actually installed
echo -e "${BOLD}Installed skills${RESET}"
echo -e "${GRAY}────────────────────────────────────${RESET}"
for f in "$SKILLS_DIR"/*.md; do
  skill=$(basename "$f" .md)
  echo -e "  ${GREEN}✓${RESET} /$skill"
done
echo ""

if [ "$INSTALLED" -lt 10 ]; then
  MISSING=$((10 - INSTALLED))
  echo -e "${YELLOW}  $MISSING skills not installed. Run install again to get all 10.${RESET}"
  echo ""
fi

echo -e "${GRAY}To see the full token cost breakdown:${RESET}"
echo "  https://github.com/dearvn/skillsover/blob/main/TOKEN_COST.md"
echo ""
