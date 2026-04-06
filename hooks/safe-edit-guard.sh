#!/usr/bin/env bash
# SkillsOver Hook: safe-edit guard for critical files
# Triggers before file edits — warns if touching high-risk files without /safe-edit
#
# Setup: add to Claude Code settings.json hooks section
# Event: PreToolUse (Edit tool)
#
# Configure CRITICAL_PATTERNS for your project's critical files

CRITICAL_PATTERNS=(
  "service"
  "auth"
  "payment"
  "billing"
  "streaming"
  "migration"
  "security"
)

FILE="${1:-}"

if [ -z "$FILE" ]; then
  exit 0
fi

for pattern in "${CRITICAL_PATTERNS[@]}"; do
  if echo "$FILE" | grep -qi "$pattern"; then
    echo ""
    echo "⚠  SkillsOver: Editing critical file: $FILE"
    echo "   This matches pattern: *${pattern}*"
    echo ""
    echo "   Use /safe-edit — writes characterization tests first,"
    echo "   makes minimal change only, verifies nothing broke."
    echo ""
    break
  fi
done
