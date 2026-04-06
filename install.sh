#!/usr/bin/env bash
set -e

REPO="https://raw.githubusercontent.com/dearvn/skillsover/main/skills"
SKILLS_DIR="$HOME/.claude/skills"
SKILLS=(commit review debug test explain security perf docs refactor)

echo "Installing SkillsOver..."
mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  curl -fsSL "$REPO/$skill.md" -o "$SKILLS_DIR/$skill.md"
  echo "  ✓ /$skill"
done

echo ""
echo "Done. Use in Claude Code:"
echo "  /commit   /review   /debug   /test   /explain"
echo "  /security /perf     /docs    /refactor"
