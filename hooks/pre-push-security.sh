#!/usr/bin/env bash
# SkillsOver Hook: pre-push security reminder
# Triggers before git push — warns if changed files haven't been audited
#
# Setup: add to Claude Code settings.json hooks section
# Event: PreToolUse (Bash tool with git push)

BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
REMOTE_REF="origin/$BRANCH"

# Get files changed since last push (vs remote), fallback to HEAD~1 if remote unknown
if git rev-parse "$REMOTE_REF" &>/dev/null; then
  CHANGED=$(git diff --name-only "$REMOTE_REF"..HEAD 2>/dev/null | grep -E "\.(py|ts|js|go|rs|sh)$")
else
  CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -E "\.(py|ts|js|go|rs|sh)$")
fi

if [ -n "$CHANGED" ]; then
  FILE_COUNT=$(echo "$CHANGED" | wc -l | tr -d ' ')
  echo ""
  echo "⚠  SkillsOver: $FILE_COUNT changed file(s) pending push:"
  echo "$CHANGED" | sed 's/^/   /'
  echo ""
  echo "   Run /security before pushing to catch injection vectors and OWASP issues."
  echo "   If already audited, proceed with push."
  echo ""
fi
