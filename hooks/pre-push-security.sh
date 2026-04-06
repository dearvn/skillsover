#!/usr/bin/env bash
# SkillsOver Hook: pre-push security reminder
# Triggers before git push — reminds to run /security if not done yet
#
# Setup: add to Claude Code settings.json hooks section
# Event: PreToolUse (Bash tool with git push)

STAGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -E "\.(py|ts|js|go|rs)$" | head -5)

if [ -n "$STAGED" ]; then
  echo ""
  echo "⚠  SkillsOver: Changed files detected before push:"
  echo "$STAGED" | sed 's/^/   /'
  echo ""
  echo "   Run /security before pushing to catch injection vectors and OWASP issues."
  echo "   Skip: push with --no-verify if already audited."
  echo ""
fi
