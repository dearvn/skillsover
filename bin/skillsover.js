#!/usr/bin/env node

const { execSync } = require('child_process')
const { mkdirSync, existsSync } = require('fs')
const { join } = require('path')
const https = require('https')

const REPO = 'https://raw.githubusercontent.com/dearvn/skillsover/main/skills'
const SKILLS = ['commit', 'review', 'debug', 'test', 'explain', 'security', 'perf', 'docs', 'refactor', 'safe-edit', 'scaffold', 'stack']

const TOOL_DIRS = {
  claude:  join(process.env.HOME, '.claude', 'skills'),
  cursor:  join(process.cwd(), '.cursor', 'rules'),
  cline:   join(process.cwd(), '.clinerules'),
  copilot: join(process.cwd(), '.github'),
}

const TOOL_INVOKE = {
  claude:  '/commit  /debug  /review  /safe-edit ...',
  cursor:  '@commit  @debug  @review  @safe-edit ...',
  cline:   'mention skill name in Cline chat',
  copilot: 'mention skill name in Copilot chat',
}

const args = process.argv.slice(2)
const cmd = args[0]
const toolArg = args.find(a => a.startsWith('--tool='))
const tool = toolArg ? toolArg.split('=')[1] : 'claude'

if (cmd !== 'init') {
  console.log('Usage: npx skillsover init [--tool=claude|cursor|cline|copilot]')
  process.exit(0)
}

if (!TOOL_DIRS[tool]) {
  console.error(`Unknown tool: ${tool}. Use: claude, cursor, cline, copilot`)
  process.exit(1)
}

const dir = TOOL_DIRS[tool]
console.log(`\nInstalling SkillsOver for ${tool}...`)
mkdirSync(dir, { recursive: true })

let installed = 0
const download = (skill) => new Promise((resolve, reject) => {
  const dest = join(dir, `${skill}.md`)
  const file = require('fs').createWriteStream(dest)
  https.get(`${REPO}/${skill}.md`, res => {
    res.pipe(file)
    file.on('finish', () => { file.close(); resolve() })
  }).on('error', reject)
})

;(async () => {
  for (const skill of SKILLS) {
    await download(skill)
    console.log(`  ✓ ${skill}`)
    installed++
  }
  console.log(`\n${installed} skills installed → ${dir}`)
  console.log(`\nUse in ${tool}:`)
  console.log(`  ${TOOL_INVOKE[tool]}`)
  console.log()
})()
