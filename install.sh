#!/usr/bin/env bash
set -e

REPO="https://raw.githubusercontent.com/dearvn/skillsover/main/skills"
SKILLS=(commit review debug test explain security perf docs refactor safe-edit scaffold stack)
TOOL="claude"

# Parse --tool flag
for arg in "$@"; do
  case $arg in
    --tool=*) TOOL="${arg#*=}" ;;
    --tool)   shift; TOOL="$1" ;;
  esac
done

# Set install directory based on tool
case $TOOL in
  cursor)
    SKILLS_DIR=".cursor/rules"
    INVOKE="@skill-name in Cursor chat"
    ;;
  cline)
    SKILLS_DIR=".clinerules"
    INVOKE="mention skill name in Cline chat"
    ;;
  copilot)
    SKILLS_DIR=".github"
    INVOKE="mention skill name in Copilot chat"
    ;;
  *)
    TOOL="claude"
    SKILLS_DIR="$HOME/.claude/skills"
    INVOKE="/commit  /debug  /review  /safe-edit ..."
    ;;
esac

echo "Installing SkillsOver for $TOOL..."
mkdir -p "$SKILLS_DIR"

for skill in "${SKILLS[@]}"; do
  curl -fsSL "$REPO/$skill.md" -o "$SKILLS_DIR/$skill.md"
  echo "  ✓ $skill"
done

echo ""
echo "Done. Use in $TOOL:"
echo "  $INVOKE"
