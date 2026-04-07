#!/usr/bin/env bash
# SkillsOver Hook: pkg-install-audit
# Intercepts npm install / pip install / composer require / yarn add / cargo add
# BEFORE the command runs — scans for supply chain threats in packages being added.
#
# Setup: add to Claude Code settings.json hooks section
# Event: PreToolUse — Bash tool
# Matcher: command matches (npm install|npm i |yarn add|pnpm add|pip install|composer require|cargo add)
#
# This hook catches the AI auto-install problem:
#   AI sees outdated package → auto-upgrades → new version has malicious postinstall
#   This hook warns BEFORE the install runs.

set -euo pipefail

# ─── Read the command being executed ─────────────────────────────────────────
# Claude Code passes the command via CLAUDE_TOOL_INPUT_COMMAND env var
CMD="${CLAUDE_TOOL_INPUT_COMMAND:-}"

if [ -z "$CMD" ]; then
  exit 0  # Not invoked via hook context, skip
fi

# ─── Determine package manager and extract package names ─────────────────────
PM=""
PACKAGES=()

if echo "$CMD" | grep -qE "^npm (install|i |ci |update)|^npx npm "; then
  PM="npm"
  # Extract package names from: npm install pkg@version pkg2 --save-dev
  PACKAGES=($(echo "$CMD" | sed 's/npm \(install\|i\|update\) //' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/@.*//' | head -20))

elif echo "$CMD" | grep -qE "^yarn (add|upgrade|up)"; then
  PM="yarn"
  PACKAGES=($(echo "$CMD" | sed 's/yarn \(add\|upgrade\|up\) //' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/@.*//' | head -20))

elif echo "$CMD" | grep -qE "^pnpm (add|install|update|up)"; then
  PM="pnpm"
  PACKAGES=($(echo "$CMD" | sed 's/pnpm \(add\|install\|update\|up\) //' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/@.*//' | head -20))

elif echo "$CMD" | grep -qE "^pip (install|install -U|install --upgrade)"; then
  PM="pip"
  PACKAGES=($(echo "$CMD" | sed 's/pip install//' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/[>=<].*//' | head -20))

elif echo "$CMD" | grep -qE "^pip3 (install|install -U)"; then
  PM="pip"
  PACKAGES=($(echo "$CMD" | sed 's/pip3 install//' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/[>=<].*//' | head -20))

elif echo "$CMD" | grep -qE "^composer (require|update)"; then
  PM="composer"
  PACKAGES=($(echo "$CMD" | sed 's/composer \(require\|update\) //' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/:.*//' | head -20))

elif echo "$CMD" | grep -qE "^cargo (add|install)"; then
  PM="cargo"
  PACKAGES=($(echo "$CMD" | sed 's/cargo \(add\|install\) //' | \
    tr ' ' '\n' | grep -v '^-' | grep -v '^$' | sed 's/@.*//' | head -20))
fi

# No package manager matched — not an install command
if [ -z "$PM" ]; then
  exit 0
fi

# ─── Known compromised / high-risk packages ──────────────────────────────────
KNOWN_BAD=(
  "event-stream"
  "flatmap-stream"
  "crossenv"
  "cross-env.js"
  "eslint-scope"
  "getcookies"
  "bootstrap-sass"
  "electron-native-notify"
  "ua-parser-js"
  "coa"
  "rc"
  "colors"          # v1.4.44-liberty-2 was sabotaged
  "faker"           # sabotaged version
  "node-ipc"        # contains geopolitical malware
  "ctx"
  "mariadb-connector"
  "discord-selfbot-v14"
  "discordjs"       # typosquat
  "nodesteam"       # credential stealer
  "jest-runner-eslint" # check version
)

# ─── Typosquatting: top packages and their common squats ─────────────────────
declare -A SQUATS=(
  ["axois"]="axios"
  ["axiso"]="axios"
  ["axxios"]="axios"
  ["lodahs"]="lodash"
  ["logdash"]="lodash"
  ["lodash-utils"]="lodash (verify this is intentional)"
  ["expres"]="express"
  ["expresss"]="express"
  ["recat"]="react"
  ["rect"]="react"
  ["momment"]="moment"
  ["mooment"]="moment"
  ["reqest"]="request"
  ["requets"]="request"
  ["commancer"]="commander"
  ["commmander"]="commander"
  ["bable"]="babel"
  ["webpakc"]="webpack"
  ["webapck"]="webpack"
  ["typscript"]="typescript"
  ["typescipt"]="typescript"
  ["cros-env"]="cross-env"
  ["cross_env"]="cross-env"
  ["colour"]="colors (verify: British spelling used by some legitimate packages)"
  ["dotenv-safe"]="verify: check maintainer before installing"
  ["dotenv-flow"]="verify: check maintainer before installing"
)

# ─── Run checks ───────────────────────────────────────────────────────────────
WARNINGS=()
CRITICALS=()

for pkg in "${PACKAGES[@]}"; do
  # Skip empty
  [ -z "$pkg" ] && continue

  # Check known bad packages
  for bad in "${KNOWN_BAD[@]}"; do
    if [ "$pkg" = "$bad" ]; then
      CRITICALS+=("KNOWN COMPROMISED: '$pkg' is in the known-malicious package list")
    fi
  done

  # Check typosquatting
  if [ "${SQUATS[$pkg]+exists}" ]; then
    WARNINGS+=("TYPOSQUAT RISK: '$pkg' looks like a misspelling of ${SQUATS[$pkg]}")
  fi

  # npm-specific: check if package has install scripts BEFORE installing
  if [ "$PM" = "npm" ] || [ "$PM" = "yarn" ] || [ "$PM" = "pnpm" ]; then
    if command -v npm &>/dev/null; then
      SCRIPTS=$(npm info "$pkg" scripts --json 2>/dev/null || echo "{}")
      HAS_INSTALL=$(echo "$SCRIPTS" | python3 -c "
import sys, json
try:
  s = json.load(sys.stdin)
  triggers = ['preinstall','install','postinstall','prepare','prepack']
  found = [t for t in triggers if t in s]
  if found: print(','.join(found))
except: pass
" 2>/dev/null || echo "")

      if [ -n "$HAS_INSTALL" ]; then
        # Get the install script content
        SCRIPT_CONTENT=$(npm info "$pkg" scripts --json 2>/dev/null | \
          python3 -c "
import sys, json
try:
  s = json.load(sys.stdin)
  triggers = ['preinstall','install','postinstall','prepare']
  for t in triggers:
    if t in s: print(t+': '+s[t])
except: pass
" 2>/dev/null || echo "unknown")

        # Check if install script has network calls
        if echo "$SCRIPT_CONTENT" | grep -qiE "curl|wget|http|https|fetch|download"; then
          CRITICALS+=("INSTALL SCRIPT FETCHES NETWORK: '$pkg' has $HAS_INSTALL that makes network requests: $SCRIPT_CONTENT")
        elif echo "$SCRIPT_CONTENT" | grep -qiE "eval|exec|spawn|sh |bash |node -e"; then
          WARNINGS+=("INSTALL SCRIPT EXECUTES SHELL: '$pkg' runs: $SCRIPT_CONTENT — review before installing")
        else
          WARNINGS+=("HAS INSTALL SCRIPT: '$pkg' runs at install time ($HAS_INSTALL): $SCRIPT_CONTENT")
        fi
      fi

      # Check last publish date — very recently published updates are higher risk
      LAST_MODIFIED=$(npm info "$pkg" time.modified 2>/dev/null | head -1 || echo "")
      MAINTAINERS=$(npm info "$pkg" maintainers 2>/dev/null | head -3 || echo "")
    fi
  fi

  # Python: check PyPI for basic info
  if [ "$PM" = "pip" ]; then
    if command -v pip &>/dev/null; then
      # Check if package exists on PyPI at all (typosquat check)
      PKG_INFO=$(pip index versions "$pkg" 2>/dev/null || echo "")
      if echo "$PKG_INFO" | grep -q "WARNING\|error\|not found"; then
        WARNINGS+=("NOT FOUND ON PYPI: '$pkg' — possible typosquat or private package")
      fi
    fi
  fi

done

# ─── Output ───────────────────────────────────────────────────────────────────
if [ ${#CRITICALS[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
  # No issues — let install proceed silently
  # Uncomment below if you want confirmation on every install:
  # echo "SkillsOver: $PM install looks clean for: ${PACKAGES[*]}"
  exit 0
fi

echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│  SkillsOver Supply Chain Audit — INSTALL INTERCEPTED        │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "  Package manager: $PM"
echo "  Packages:        ${PACKAGES[*]:-none detected}"
echo ""

if [ ${#CRITICALS[@]} -gt 0 ]; then
  echo "  ─── CRITICAL — DO NOT INSTALL ───────────────────────────────"
  for c in "${CRITICALS[@]}"; do
    echo "  [CRITICAL] $c"
  done
  echo ""
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo "  ─── WARNINGS — Review before proceeding ─────────────────────"
  for w in "${WARNINGS[@]}"; do
    echo "  [WARN] $w"
  done
  echo ""
fi

echo "  ─── Recommended actions ──────────────────────────────────────"
if [ ${#CRITICALS[@]} -gt 0 ]; then
  echo "  1. DO NOT proceed with this install."
  echo "  2. Run: /supply-chain for a full audit of your current packages."
  echo "  3. Check the npm registry page for the package manually."
  echo "  4. If you must install, pin to a known-clean version explicitly."
else
  echo "  1. Check the package manually: npm info ${PACKAGES[0]:-<pkg>} maintainers"
  echo "  2. Review install scripts: npm info ${PACKAGES[0]:-<pkg>} scripts"
  echo "  3. Run: /supply-chain after installing to verify no malicious patterns."
  echo "  4. To proceed anyway, re-run the install command."
fi
echo ""

# Exit 0 = warning only, install is NOT blocked (user decides)
# Exit 1 = block the install (use for CRITICAL only if you want hard blocking)
if [ ${#CRITICALS[@]} -gt 0 ]; then
  exit 1  # Block: known malicious or network-fetching install script
else
  exit 0  # Warn but allow: user can decide
fi
