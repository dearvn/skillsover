# demo.tape — skillsover workflow demo
# Records a terminal session showing /commit and /debug skill usage
# Output: demo.gif

Output demo.gif

Require echo

Set Theme "Dracula"
Set FontSize 14
Set Width 1200
Set Height 600
Set TypingSpeed 60ms
Set Padding 20

# ─────────────────────────────────────────────
# Scene 1: Stage a git change
# ─────────────────────────────────────────────

Type "# Stage a small auth change"
Enter
Sleep 400ms

Type "echo '// add rate limiting' >> api/auth.js && git add api/auth.js"
Sleep 200ms
Enter
Sleep 600ms

Type "git status"
Sleep 200ms
Enter
Sleep 500ms

# Fake git status output
Type "echo ''"
Enter
Type `echo "On branch main"`
Enter
Type `echo "Changes to be committed:"`
Enter
Type `echo "  (use \"git restore --staged <file>...\" to unstage)"`
Enter
Type `echo "        modified:   api/auth.js"`
Enter
Sleep 800ms

# ─────────────────────────────────────────────
# Scene 2: Open Claude Code and run /commit
# ─────────────────────────────────────────────

Sleep 400ms
Type "clear"
Enter
Sleep 300ms

Type "# Now we'll use the /commit skill via Claude Code"
Enter
Sleep 400ms

# Simulate Claude Code prompt (faked via script)
Type "bash scripts/demo-commit.sh"
Sleep 200ms
Enter
Sleep 1200ms

# Simulate Claude analyzing git diff
Type `echo ""`
Enter
Type `echo " Analyzing staged changes..."`
Enter
Sleep 600ms
Type `echo ""`
Enter
Type `echo " Reading: api/auth.js"`
Enter
Sleep 500ms
Type `echo ""`
Enter
Type `echo " Proposed commit message:"`
Enter
Sleep 400ms
Type `echo ""`
Enter
Type `echo "  feat(auth): add rate limiting to login endpoint"`
Enter
Sleep 300ms
Type `echo ""`
Enter
Type `echo "  Prevents brute-force attacks by capping failed login"`
Enter
Type `echo "  attempts per IP. Aligns with OWASP A07 guidance."`
Enter
Sleep 400ms
Type `echo ""`
Enter
Type `echo " Running: git commit -m 'feat(auth): add rate limiting to login endpoint'"`
Enter
Sleep 700ms
Type `echo " [main 4a2f1c9] feat(auth): add rate limiting to login endpoint"`
Enter
Sleep 300ms
Type `echo "  1 file changed, 1 insertion(+)"`
Enter
Sleep 800ms

# ─────────────────────────────────────────────
# Scene 3: /debug with a sample error
# ─────────────────────────────────────────────

Sleep 500ms
Type "clear"
Enter
Sleep 300ms

Type "# Now let's debug a runtime error with /debug"
Enter
Sleep 400ms

Type "bash scripts/demo-debug.sh"
Sleep 200ms
Enter
Sleep 1200ms

Sleep 500ms
