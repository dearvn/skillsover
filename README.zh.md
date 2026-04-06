# SkillsOver

[![GitHub stars](https://img.shields.io/github/stars/dearvn/skillsover?style=flat-square)](https://github.com/dearvn/skillsover/stargazers)
[![License](https://img.shields.io/github/license/dearvn/skillsover?style=flat-square)](LICENSE)

**AI 编程技能集，让你的 token 费用降低 87%。支持 Claude Code、Cursor、Cline、Copilot。**

[English](README.md) | [Tiếng Việt](README.vi.md) | 中文

```bash
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash
```

```bash
npx skillsadd dearvn/skillsover   # alternative
```

然后只需输入 `/commit`、`/debug`、`/review` — 再也不用为 Claude 的废话前言买单。

![SkillsOver demo](demo.gif)

---

## 问题所在

```
没有 skill：

  你："fix the bug in OrderService"
         │
         ├─ Claude 读取 6 个文件"以了解上下文"   +4,800 tokens
         ├─ Claude 提出 2 个澄清问题              +  800 tokens
         ├─ Claude 解释它在做什么                 +  300 tokens
         └─ Claude 总结它做了什么                 +  200 tokens
                                                  ───────────
                                           总计：  ~6,100 tokens  ≈ $0.040


使用 /debug：

  你：/debug [粘贴报错信息]
         │
         ├─ Claude 读取指定行的 1 个文件           + 800 tokens
         └─ Claude 输出：根本原因 + 修复方案       + 200 tokens
                                                   ──────────
                                            总计：  ~1,000 tokens  ≈ $0.005

                                                         减少 84%  ↓
```

---

## 支持的工具

| 工具 | 安装位置 | 调用方式 |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `/commit`、`/debug`... |
| **Cursor** | `.cursor/rules/` | `@commit`、`@debug`... |
| **Cline** | `.clinerules/` | 在聊天中提及 |
| **Copilot** | `.github/` | 在聊天中提及 |

```bash
# Claude Code（默认）
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash

# Cursor
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cursor

# Cline
curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/install.sh | bash --tool cline
```

---

## Token 节省情况

| 任务 | 无 skill | 有 skill | 节省 |
|---|---|---|---|
| 编写 commit message | ~$0.0138 | ~$0.0018 | **87%** |
| Debug 一个 bug | ~$0.0400 | ~$0.0051 | **87%** |
| 每月（每天 5 次） | ~$50 | ~$7 | **~$43/月** |

查看你自己的节省情况：`bash <(curl -fsSL https://raw.githubusercontent.com/dearvn/skillsover/main/scripts/gain.sh)`

---

## Skill 列表

```
/commit    从 staged diff 生成语义化 commit — 无需反复确认
/review    PR 前代码审查：安全 P0、逻辑 P1、性能 P2
/debug     4 阶段根本原因分析 — 从不猜测
/test      为任意框架生成测试（pytest、Jest、Go、RSpec...）
/explain   解释代码：做什么 → 怎么做 → 注意点 — 跳过显而易见的部分
/security  OWASP Top 10 审计，只读，只报告发现的问题
/perf      先 profile，再优化真正的性能瓶颈
/docs      JSDoc / docstrings / godoc — 记录为什么，而非是什么
/refactor  安全重构，先写特征测试
/safe-edit 在不破坏现有行为的前提下进行编辑
```

---

## 文档

- [GETTING_STARTED.md](GETTING_STARTED.md) — 从零到第一个 skill，5 分钟搞定
- [TOKEN_COST.md](TOKEN_COST.md) — 账单飙升的确切原因及 skill 的解决方式
- [WHY.md](WHY.md) — 与其他方案的对比

---

## Skill 参考文档

### `/commit` — 从 Diff 生成语义化 Commit
**适用场景**：暂存更改后，不想手动写 commit message 时。

**工作方式**：
1. 读取 `git diff --staged` 和 `git status`
2. 确定 commit 类型（feat/fix/refactor/perf/test/docs/chore/style）
3. 编写不超过 72 个字符的祈使句式摘要
4. 按规范格式创建 commit

**示例输出**：
```
feat(auth): add refresh token rotation
fix(api): return 404 instead of 500 for missing resource
perf(cache): cache dashboard stats with 60s TTL
```

**Token 成本**：~300 tokens（仅读取 staged diff）
**节省时间**：每次 commit 节省 2-5 分钟，彻底告别糟糕的 commit message

---

### `/review` — PR 前代码审查
**适用场景**：开 PR 之前，或审查他人的 PR 时。

**工作方式**：
1. 读取当前分支与 main 之间的 diff
2. 检查 OWASP 安全问题（P0 — 阻止 PR）
3. 检查逻辑和正确性 bug（P1 — 阻止 PR）
4. 检查性能问题（P2 — 建议）
5. 只报告带有 file:行号 引用的发现 — 不夸奖，不废话

**示例输出**：
```
[P0] api/users.ts:45 — User input passed directly to SQL query string
Suggestion: Use parameterized query or ORM

[P1] services/order.ts:112 — Missing null check before .items.length
Suggestion: Add guard: if (!order?.items) return []
```

**Token 成本**：~800-1500 tokens（读取 diff + 相关文件）
**节省时间**：在代码审查环节前发现 bug（节省 1-3 轮审查）

---

### `/debug` — 系统性根本原因分析
**适用场景**：任何出现 bug、报错、崩溃或异常行为的时候。

**工作方式**：
4 阶段流程 — 从不猜测：
1. **REPRODUCE** — 获取精确的报错信息和复现步骤
2. **LOCATE** — 追踪 stack trace 到具体的 file:行号
3. **HYPOTHESIZE** — 提出唯一一个假设并验证
4. **FIX** — 只修复根本原因，不顺手重构周边代码

**示例输出**：
```
Root cause: Redis connection not re-established after EAGAIN error
Evidence: market_pressure_service.py:847 — ctx->err not cleared after error
Fix: Add ctx->err = 0 and reconnect logic after EAGAIN returns
Risk: Must test reconnection under load — single-threaded Redis ctx
```

**Token 成本**：~500-1000 tokens（仅读取 stack trace 中的文件）
**节省时间**：通过系统化流程，消灭 30-60 分钟的无头绪 debug

---

### `/test` — 为现有代码编写测试
**适用场景**：写完一个函数后，或需要补充缺失的测试覆盖率时。

**工作方式**：
1. 读取目标函数/模块
2. 识别：正常路径、边界情况、错误路径
3. Mock 外部依赖（HTTP、DB、time、filesystem）
4. 按 AAA 结构（Arrange/Act/Assert）编写测试
5. 每个测试只包含一个断言

**支持**：pytest、Jest、xUnit、Go testing、RSpec — 任意框架

**Token 成本**：~600-1200 tokens
**节省时间**：从头为 50 行函数写测试需要 20-40 分钟；用 /test 只需约 5 分钟

---

### `/explain` — 解释代码帮助理解
**适用场景**：入职新项目，或需要理解复杂逻辑时。

**工作方式**：
1. 读取指定代码
2. 从上下文判断你的知识水平
3. 解释：做什么 → 如何运作 → 关键概念 → 注意事项
4. 跳过显而易见的部分 — 只解释读者真正可能忽略的内容

**使用示例**：
```
/explain this function [select code]
/explain how authentication works in this codebase
/explain the DTE routing logic in market_pressure_service.py
```

**Token 成本**：~400-800 tokens
**最适合**：入职上手、代码审查理解、调试陌生代码

---

### `/security` — 快速安全审计
**适用场景**：上线新功能前，或审查现有接口时。

**工作方式**：
检查 OWASP Top 10 — 只读，绝不修改代码：
- SQL 注入、XSS、路径遍历
- 身份验证缺陷（缺少中间件、JWT 校验）
- 代码中的密钥泄露
- 不安全的反序列化
- 敏感数据写入日志

**示例输出**：
```
[CRITICAL] routes/upload.ts:67 — File extension not validated before save
Fix: Validate MIME type + extension whitelist, never trust Content-Type header

[HIGH] middleware/auth.ts:23 — JWT expiry not checked
Fix: Verify exp claim: if (decoded.exp < Date.now() / 1000) throw Unauthorized()
```

**Token 成本**：~600-1000 tokens
**为什么省钱**：上线前发现安全漏洞 vs 被攻破后再处理 — 成本差距是数量级的

---

### `/perf` — 性能分析
**适用场景**：某个地方变慢了，但不知道原因在哪。

**工作方式**：
1. **先 profile** — 在读取任何代码前，提供适合你技术栈的 profiling 命令
2. **定位瓶颈** — 只读取 profiler 识别出的慢函数
3. **识别模式** — N+1、缺少索引、无分页、阻塞 I/O、重复渲染
4. **给出修复建议** — 具体的改动方案及预期效果

**常见发现**：
- N+1 查询（循环中调用 DB）→ 用 `IN` 子句批量查询
- 在 50 列的表上 `SELECT *` → 只查需要的列
- WHERE 条件列缺少索引 → 添加索引
- React 组件每次按键都重新渲染 → 使用 memo 或 debounce

**Token 成本**：~500-900 tokens
**原则**：绝不跳过 profiling 步骤。优化错误的地方是在浪费所有人的时间。

---

### `/docs` — 生成内联文档
**适用场景**：写完函数后，或 PR 前需要补充缺失文档时。

**工作方式**：
1. 读取目标代码
2. 识别真正需要解释的内容（跳过显而易见的部分）
3. 生成 JSDoc / Python docstrings / C# XML docs / Go godoc
4. 记录：参数、返回值、异常/错误、副作用、示例

**设计原则**：记录为什么，而不是做什么。代码本身已经告诉你做了什么。

**支持**：TypeScript（JSDoc）、Python（Google style）、C#（XML）、Go（godoc）、Java（Javadoc）

**Token 成本**：~300-600 tokens
**节省时间**：为一个复杂函数写好文档需要 10-20 分钟；/docs 几秒钟搞定

---

### `/refactor` — 安全重构
**适用场景**：代码能跑，但难读、难维护或难测试时。

**工作方式**：
1. 读取并理解当前行为（包括边界情况）
2. 如果没有测试，先写特征测试
3. 只应用一种重构手法：提取函数 / 重命名 / 消除重复 / 简化条件 / 拆分函数
4. 每一步之后都运行测试

**原则**：绝不在同一个 commit 中同时修改逻辑和结构。

**Token 成本**：~700-1500 tokens
**降低风险**：特征测试能捕获意外的行为变更 — 节省回归 debug 时间

---

## 设计原则

### 为什么这些 skill 能节省 token

| 无 skill | 有 skill |
|--------------|------------|
| Claude 每次从头想方案 | 方案已预定义 — Claude 直接执行 |
| 多轮澄清确认 | 单次调用，输出清晰 |
| Claude 为了"了解上下文"读太多文件 | Skill 将范围约束在最少必要文件 |
| 打印冗长的推理过程 | Skill 只输出结果格式 |

### Token 高效的 skill 设计要点
1. **规定范围** — 明确告诉 Claude 读哪些文件，以及不读哪些文件
2. **规定输出格式** — Claude 不用考虑如何呈现，直接填模板
3. **规定流程** — 编号步骤消除探索开销
4. **抑制废话** — "只输出发现，不要夸奖" 可减少 40-60% 的输出 token

---

## 贡献

一个好的通用 skill 应该：
- 适用于任意语言/框架（或明确说明其要求）
- 只读取必要的最少文件 — 绝不"为了上下文而读"
- 有明确的输出格式
- 节省的时间多于调用它所花的时间

将你的 skill 以 `skills/{name}.md` 的形式提交，并包含以下 frontmatter：
```yaml
---
name: skill-name
description: One line — what it does and when to use it.
---
```
