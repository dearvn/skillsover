#!/usr/bin/env bash
# SkillsOver Hook: post-stage commit reminder
# Triggers after git add — reminds to use /commit instead of writing manually
#
# Setup: add to Claude Code settings.json hooks section
# Event: PostToolUse (Bash tool with git add)

STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

if [ "$STAGED" -gt 0 ]; then
  echo ""
  echo "✓  SkillsOver: $STAGED file(s) staged."
  echo "   Type /commit — semantic commit from diff, no back-and-forth."
  echo ""
fi
