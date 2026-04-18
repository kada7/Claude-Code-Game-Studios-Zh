---
name: help
description: "分析已完成的工作和用户查询，提供下一步操作的建议。当用户问'接下来该做什么'、'我现在该做什么'、'我卡住了'或'我不知道该做什么'时使用。"
argument-hint: "[optional: what you just finished, e.g. 'finished design-review' or 'stuck on ADRs']"
user-invocable: true
allowed-tools: Read, Glob, Grep
context: |
  !echo "=== Live Project State ===" && echo "Stage: $(cat production/stage.txt 2>/dev/null | tr -d '[:space:]' || echo 'not set')" && echo "Latest sprint: $(ls -t production/sprints/*.md 2>/dev/null | head -1 || echo 'none')" && echo "Session state: $(head -5 production/session-state/active.md 2>/dev/null || echo 'none')"
model: haiku
---

# Studio Help — What Do I Do Next?

这个技能是只读的 — 它报告 findings 但不写入文件。

这个技能准确指出你在游戏开发 pipeline 中的位置并
告诉你接下来做什么。它是 **轻量级的** — 不是完整的审计。对于完整的
gap analysis，使用 `/project-stage-detect`。

---

## Step 1: Read the Catalog

读取 `.claude/docs/workflow-catalog.yaml`。这是所有
phases、它们的步骤（按顺序）、每个步骤是必需还是可选、以及表示完成的工件 globs 的权威列表。

---

## Step 1b: Find Skills Not in the Catalog

读取 catalog 后，Glob `.claude/skills/*/SKILL.md` 以获取完整的已安装技能列表。对于每个文件，从其 frontmatter 中提取 `name:` 字段。

与 catalog 中的 `command:` 值进行比较。任何名称未作为 catalog command 出现的技能都是 **uncataloged skill** — 仍然可用但不是 phase-gated workflow 的一部分。

收集这些用于 Step 7 中的输出 — 将它们显示为页脚块：

```
### Also installed (not in workflow)
- `/skill-name` — [description from SKILL.md frontmatter]
- `/skill-name` — [description]
```

只有至少存在一个 uncataloged skill 时才显示此块。根据用户当前阶段限制为 10 个最相关的（QA skills 用于 production，team skills 用于 production/polish 等）。

---

## Step 2: Determine Current Phase

按此顺序检查：

1. **读取 `production/stage.txt`** — 如果它存在且有内容，这是权威的 phase name。将其映射到 catalog phase key：
   - "Concept" → `concept`
   - "Systems Design" → `systems-design`
   - "Technical Setup" → `technical-setup`
   - "Pre-Production" → `pre-production`
   - "Production" → `production`
   - "Polish" → `polish`
   - "Release" → `release`

2. **如果 stage.txt 缺失**，从工件推断 phase（最先进的匹配获胜）：
   - `src/` 有 10+ 源文件 → `production`
   - `production/stories/*.md` 存在 → `pre-production`
   - `docs/architecture/adr-*.md` 存在 → `technical-setup`
   - `design/gdd/systems-index.md` 存在 → `systems-design`
   - `design/gdd/game-concept.md` 存在 → `concept`
   - 无 → `concept` (fresh project)

---

## Step 3: Read Session Context

如果它存在，读取 `production/session-state/active.md`。提取：
- 最近完成的工作
- 任何正在进行的任务或开放问题
- 来自 STATUS 块的当前 epic/feature/task（如果存在）

这告诉你用户刚刚完成或卡在哪里 — 用它来个性化输出。

---

## Step 4: Check Step Completion for the Current Phase

对于当前阶段中的每个步骤（来自 catalog）：

### Artifact-based checks

如果步骤有 `artifact.glob`：
- 使用 Glob 检查是否有匹配模式的文件存在
- 如果指定了 `min_count`，验证至少有那么多的文件匹配
- 如果指定了 `artifact.pattern`，使用 Grep 验证模式是否存在于匹配的文件中
- **Complete** = 工件条件已满足
- **Incomplete** = 工件缺失或模式未找到

如果步骤有 `artifact.note`（没有 glob）：
- 标记为 **MANUAL** — 无法自动检测，将询问用户

如果步骤没有 `artifact` 字段：
- 标记为 **UNKNOWN** — 完成不可跟踪（例如可重复的 implementation work）

### 特殊情况：production phase — 读取 `sprint-status.yaml`

当当前阶段是 `production` 时，在执行任何基于 glob 的 story 检查之前检查 `production/sprint-status.yaml`。如果它存在，直接读取它：

- `status: in-progress` 的 Stories → 显示为 "currently active"
- `status: ready-for-dev` 的 Stories → 显示为 "next up"
- `status: done` 的 Stories → 计为完成
- `status: blocked` 的 Stories → 显示为带有 `blocker` 字段的 blocker

这提供了精确的 per-story 状态，无需 markdown 扫描。跳过 `implement` 和 `story-done` 步骤的 glob artifact check — YAML 是权威的。

### 特殊情况：`repeatable: true` (non-production)

对于 production 之外的可重复步骤（例如 "System GDDs"），工件
check 告诉你是否完成了*任何*工作，而不是是否完成。
不同地标记这些 — 显示检测到的内容，然后注意它可能正在进行。

---

## Step 5: Find Position and Identify Next Steps

从完成数据中确定：

1. **Last confirmed complete step** — 最远的已完成的必需步骤
2. **Current blocker** — 第一个未完成的*必需*步骤（这是用户接下来必须做的）
3. **Optional opportunities** — 现在可以在此 blocker 之前或同时进行的未完成的*可选*步骤
4. **Upcoming required steps** — 当前 blocker 之后的必需步骤（显示为 "coming up" 以便用户提前计划）

如果用户提供了参数（例如 "just finished design-review"），使用它
来推进用户命名的步骤，即使工件检查是模糊的。

---

## Step 6: Check for In-Progress Work

如果 `active.md` 显示一个活跃的任务或 epic：
- 在顶部突出显示它："看起来你之前在 [X] 上工作"
- 建议继续它或确认是否完成

---

## Step 7: Present Output

保持 **简短直接**。这是一个快速的 orientation，不是报告。

```
## Where You Are: [Phase Label]

**In progress:** [来自 active.md，如果有]

### ✓ Done
- [completed step name]
- [completed step name]

### → Next up (REQUIRED)
**[Step name]** — [description]
Command: `[/command]`

### ~ Also available (OPTIONAL)
- **[Step name]** — [description] → `/command`
- **[Step name]** — [description] → `/command`

### Coming up after that
- [Next required step name] (`/command`)
- [Next required step name] (`/command`)

---
Approaching **[next phase]** gate → 准备好时运行 `/gate-check`。
```

**Formatting rules:**
- `✓` 表示已确认完成
- `→` 表示当前必需的下一步（只有一个 — 第一个 blocker）
- `~` 表示现在可用的可选步骤
- 将命令内联显示为反引号代码
- 如果步骤没有命令（例如 "Implement Stories"），解释要做什么而不是显示 slash command
- 对于 MANUAL 步骤，询问用户："我无法判断 [step] 是否完成 — 它完成了吗？"

Verdict: **COMPLETE** — 已确定下一步。

---

## Step 8: Gate Warning (if close)

在当前阶段的步骤之后，检查用户是否可能接近一个关卡：
- 如果当前阶段的所有必需步骤都已完成（或几乎完成），
  添加："你接近 **[Current] → [Next]** 关卡了。准备好时运行 `/gate-check`。"
- 如果多个必需步骤剩余，跳过关卡警告 — 它还不相关。

---

## Step 9: Escalation Paths

在推荐之后，如果用户看起来卡住或困惑，添加：

```
---
需要更多细节？
- `/project-stage-detect` — 列出所有缺失工件的完整 gap analysis
- `/gate-check` — 下一个阶段的正式 readiness 检查
- `/start` — 从头开始重新定位
```

只有当用户的输入表明困惑时才显示此内容（例如 "I don't know", "stuck",
"lost", "not sure"）。不要为简单的 "what's next?" 查询显示它。

---

## Collaborative Protocol

- **永远不要自动运行下一个技能。** 推荐它，让用户调用它。
- **询问 MANUAL 步骤** 而不是假设完成或未完成。
- **匹配用户的语气** — 如果他们听起来压力大（"I'm totally lost"），要
  令人安心并给出一个行动，而不是六个行动的列表。
- **一个主要推荐** — 用户离开时应该确切知道下一步要做的一件事。可选步骤和 "coming up" 是次要的上下文。
