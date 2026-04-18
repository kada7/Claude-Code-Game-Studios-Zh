---
name: adopt
description: "遗留项目接入 — 审核现有项目工件是否符合模板格式规范（不仅是存在性），按影响分类差距，并生成编号迁移计划。在加入进行中的项目或从旧模板版本升级时运行此技能。与/project-stage-detect（检查存在的内容）不同 — 此技能检查现有内容是否真正能配合模板的技能正常工作。"
argument-hint: "[focus: full | gdds | adrs | stories | infra]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
agent: technical-director
---

# Adopt — 遗留项目模板接入

此技能审核现有项目的工件是否**符合格式规范**，以适配模板的技能流水线，然后生成一份按优先级排序的迁移计划。

**这不是 `/project-stage-detect`。**
`/project-stage-detect` 回答的是：*存在什么？*
`/adopt` 回答的是：*现有内容是否能真正配合模板的技能正常工作？*

一个项目可以有 GDD、ADR 和 Story —— 但如果这些工件的内部格式错误，所有格式敏感的技能都会静默失败或产生错误结果。

**输出：** `docs/adoption-plan-[date].md` —— 一份持久、可检查的迁移计划。

**参数模式：**

**审核模式：** `$ARGUMENTS[0]`（留空 = `full`）

- **无参数 / `full`**：完整审核 —— 所有工件类型
- **`gdds`**：仅 GDD 格式合规性
- **`adrs`**：仅 ADR 格式合规性
- **`stories`**：仅 Story 格式合规性
- **`infra`**：仅基础设施工件缺失（registry、manifest、sprint-status、stage.txt）

---

## 阶段 1：检测项目状态

在读取前输出一行：`"Scanning project artifacts..."` —— 这确认技能在静默读取阶段正在运行。

然后在展示任何其他内容之前静默读取。

### 存在性检查
- `production/stage.txt` —— 如果存在，读取它（权威阶段）
- `design/gdd/game-concept.md` —— 概念是否存在？
- `design/gdd/systems-index.md` —— 系统索引是否存在？
- 统计 GDD 文件：`design/gdd/*.md`（排除 game-concept.md 和 systems-index.md）
- 统计 ADR 文件：`docs/architecture/adr-*.md`
- 统计 Story 文件：`production/epics/**/*.md`（排除 EPIC.md）
- `.claude/docs/technical-preferences.md` —— 引擎是否已配置？
- `docs/engine-reference/` —— 引擎参考文档是否存在？
- Glob `docs/adoption-plan-*.md` —— 如果存在，记录最新一份先前计划的文件名

### 推断阶段（如果没有 stage.txt）
使用与 `/project-stage-detect` 相同的启发式规则：
- `src/` 中有 10+ 个源文件 → Production
- `production/epics/` 中有 Story → Pre-Production
- ADR 存在 → Technical Setup
- systems-index.md 存在 → Systems Design
- game-concept.md 存在 → Concept
- 没有任何内容 → Fresh（不是遗留项目 —— 建议运行 `/start`）

如果项目看起来是全新的（没有任何工件），使用 `AskUserQuestion`：
- "This looks like a fresh project — no existing artifacts found. `/adopt` is for
  projects with work to migrate. What would you like to do?"
  - "Run `/start` — begin guided first-time onboarding"
  - "My artifacts are in a non-standard location — help me find them"
  - "Cancel"

然后停止 —— 无论用户选择哪个选项，都不要继续审核（每个选项会导向不同的技能或手动调查）。

报告："Detected phase: [phase]. Found: [N] GDDs, [M] ADRs, [P] stories."

---

## 阶段 2：格式审核

对于范围内的每种工件类型（基于参数模式），不仅检查文件是否存在，还要检查其是否包含模板要求的内部结构。

### 2a：GDD 格式审核

对于找到的每个 GDD 文件，通过扫描标题检查 8 个必需章节：

| 必需章节 | 要查找的标题模式 |
|---|---|
| 概述 | `## Overview` |
| 玩家幻想 | `## Player Fantasy` |
| 详细规则 / 设计 | `## Detailed` 或 `## Core Rules` 或 `## Detailed Design` |
| 公式 | `## Formulas` 或 `## Formula` |
| 边界情况 | `## Edge Cases` |
| 依赖关系 | `## Dependencies` 或 `## Depends` |
| 可调参数 | `## Tuning` |
| 验收标准 | `## Acceptance` |

对于每个 GDD，记录：
- 哪些章节存在
- 哪些章节缺失
- 现有章节是否包含实际内容，还是只有占位文本（`[To be designed]` 或类似内容）

同时检查：每个 GDD 的头部块中是否有 `**Status**:` 字段？
有效值：`In Design`、`Designed`、`In Review`、`Approved`、`Needs Revision`。

### 2b：ADR 格式审核

对于找到的每个 ADR 文件，检查以下关键章节：

| 章节 | 缺失时的影响 |
|---|---|
| `## Status` | **阻塞级** —— `/story-readiness` 的 ADR 状态检查会静默通过所有内容 |
| `## ADR Dependencies` | 高 —— `/architecture-review` 中的依赖排序会中断 |
| `## Engine Compatibility` | 高 —— 截止日期后的 API 风险未知 |
| `## GDD Requirements Addressed` | 中 —— 可追溯性矩阵失去覆盖 |
| `## Performance Implications` | 低 —— 不影响流水线关键路径 |

对于每个 ADR，记录：哪些章节存在、哪些缺失、如果 Status 章节存在则记录当前 Status 值。

### 2c：systems-index.md 格式审核

如果 `design/gdd/systems-index.md` 存在：

1. **括号状态值** —— Grep 查找任何包含括号的 Status 单元格：`"Needs Revision ("`、`"In Progress ("` 等。
   这些会破坏 `/gate-check`、`/create-stories` 和 `/architecture-review` 中的精确字符串匹配。**阻塞级。**

2. **有效状态值** —— 检查 Status 列的值是否仅来自：
   `Not Started`、`In Progress`、`In Review`、`Designed`、`Approved`、`Needs Revision`
   标记任何无法识别的值。

3. **列结构** —— 检查表格是否至少包含：System name、Layer、Priority、Status 列。缺失列会降低技能功能。

### 2d：Story 格式审核

对于找到的每个 Story 文件：

- **`Manifest Version:` 字段** —— 是否存在于 Story 头部？（低 —— 缺失时自动通过）
- **TR-ID 引用** —— Story 是否包含 `TR-[a-z]+-[0-9]+` 模式？（中 —— 无陈旧性追踪）
- **ADR 引用** —— Story 是否引用了至少一个 ADR？（检查 `ADR-` 模式）
- **Status 字段** —— 是否存在且可读？
- **验收标准** —— Story 是否有复选框列表（`- [ ]`）？

### 2e：基础设施审核

| 工件 | 路径 | 缺失时的影响 |
|---|---|---|
| TR registry | `docs/architecture/tr-registry.yaml` | 高 —— 无稳定需求 ID |
| Control manifest | `docs/architecture/control-manifest.md` | 高 —— 无 Story 的层级规则 |
| Manifest 版本戳 | 在 manifest 头部：`Manifest Version:` | 中 —— 陈旧性检查失效 |
| Sprint status | `production/sprint-status.yaml` | 中 —— `/sprint-status` 回退到 markdown |
| Stage 文件 | `production/stage.txt` | 中 —— 阶段自动检测不可靠 |
| Engine reference | `docs/engine-reference/[engine]/VERSION.md` | 高 —— ADR 引擎检查失效 |
| Architecture traceability | `docs/architecture/architecture-traceability.md` | 中 —— 无可持久化矩阵 |

### 2f：技术偏好审核

读取 `.claude/docs/technical-preferences.md`。检查每个字段是否为 `[TO BE CONFIGURED]`：
- Engine、Language、Rendering、Physics → 未配置时为高（ADR 技能会失败）
- 命名约定 → 中
- 性能预算 → 中
- Forbidden Patterns、Allowed Libraries → 低（设计上初始为空）

---

## 阶段 3：分类并确定差距优先级

将所有审核中发现的每个差距组织到四个严重级别中：

**阻塞级** —— 会导致模板技能**立即**静默产生错误结果。
示例：ADR 缺失 Status 字段、systems-index 存在括号状态值、ADR 存在时引擎未配置。

**高** —— 会导致 Story 生成时缺少安全检查，或基础设施引导失败。
示例：ADR 缺失 Engine Compatibility、GDD 缺失 Acceptance Criteria（无法从中生成 Story）、tr-registry.yaml 缺失。

**中** —— 降低质量和流水线追踪能力，但不会破坏功能。
示例：GDD 缺失 Tuning Knobs 或 Formulas 章节、Story 缺失 TR-ID、sprint-status.yaml 缺失。

**低** —— 追溯性改进，有则更好，但不紧急。
示例：Story 缺失 Manifest Version 戳、GDD 缺失 Open Questions 章节。

统计每个级别的总数。如果阻塞级和高级均为零：报告项目已与模板兼容，仅需建议性改进。

---

## 阶段 4：构建迁移计划

编写一份编号的、有序的行动计划。排序规则：
1. 阻塞级差距优先（必须在任何流水线技能可靠运行前修复）
2. 高级差距次之，基础设施优先于 GDD/ADR 内容（引导需要正确的格式）
3. 中级差距排序：GDD 差距优先于 ADR 差距，ADR 差距优先于 Story 差距（Story 依赖 GDD 和 ADR）
4. 低级差距最后

对于每个差距，生成一个计划条目，包含：
- 清晰的问题陈述（一句话，无术语）
- 如果有技能可以处理，提供确切的修复命令
- 如果需要直接编辑，提供手动步骤
- 时间估算（粗略：5 分钟 / 30 分钟 / 1 个会话）
- 一个复选框 `- [ ]` 用于追踪

**特殊情况 —— systems-index 括号状态值：**
如果存在，这永远是第一项。显示需要更改的确切值和确切替换文本。在写入计划前提供立即修复。

**特殊情况 —— ADR 缺失 Status 字段：**
对于每个受影响的 ADR，修复方式为：
`/architecture-decision retrofit docs/architecture/adr-[NNNN]-[slug].md`
将每个 ADR 列为单独的待检查项。

**特殊情况 —— GDD 缺失章节：**
对于每个受影响的 GDD，列出缺失的章节和修复方式：
`/design-system retrofit design/gdd/[filename].md`

**基础设施引导顺序** —— 始终按以下顺序呈现：
1. 先修复 ADR 格式（registry 依赖读取 ADR Status 字段）
2. 运行 `/architecture-review` → 引导生成 `tr-registry.yaml`
3. 运行 `/create-control-manifest` → 创建带版本戳的 manifest
4. 运行 `/sprint-plan update` → 创建 `sprint-status.yaml`
5. 运行 `/gate-check [phase]` → 权威写入 `stage.txt`

**现有 Story** —— 明确注明：
> "Existing stories continue to work with all template skills — all new format
> checks auto-pass when the fields are absent. They won't benefit from TR-ID
> staleness tracking or manifest version checks until they're regenerated. This
> is intentional: do not regenerate stories that are already in progress."

---

## 阶段 5：展示摘要并询问是否写入

在写入前展示一份紧凑摘要：

```
## Adoption Audit Summary
Phase detected: [phase]
Engine: [configured / NOT CONFIGURED]
GDDs audited: [N] ([X] fully compliant, [Y] with gaps)
ADRs audited: [N] ([X] fully compliant, [Y] with gaps)
Stories audited: [N]

Gap counts:
  BLOCKING: [N] — template skills will malfunction without these fixes
  HIGH:     [N] — unsafe to run /create-stories or /story-readiness
  MEDIUM:   [N] — quality degradation
  LOW:      [N] — optional improvements

Estimated remediation: [X blocking items × ~Y min each = roughly Z hours]
```

在询问写入前，展示一份**差距预览**：
- 将每个阻塞级差距列为单行项目，描述实际问题（例如 `systems-index.md: 3 rows have parenthetical status values`、`adr-0002.md: missing ## Status section`）。不要只显示数量 —— 展示具体项目。
- 高级 / 中级 / 低级仅显示数量（例如 `HIGH: 4, MEDIUM: 2, LOW: 1`）。

这给用户足够的上下文来判断范围，再决定是否写入文件。

如果在阶段 1 检测到先前的接入计划，添加备注：
> "A previous plan exists at `docs/adoption-plan-[prior-date].md`. The new plan will
> reflect current project state — it does not diff against the prior run."

使用 `AskUserQuestion`：
- "Ready to write the migration plan?"
  - "Yes — write `docs/adoption-plan-[date].md`"
  - "Show me the full plan preview first (don't write yet)"
  - "Cancel — I'll handle migration manually"

如果用户选择 "Show me the full plan preview"，将完整计划作为围栏 markdown 代码块输出。然后再次用相同的三个选项询问。

---

## 阶段 6：写入接入计划

如果获得批准，写入 `docs/adoption-plan-[date].md`，结构如下：

```markdown
# Adoption Plan

> **Generated**: [date]
> **Project phase**: [phase]
> **Engine**: [name + version, or "Not configured"]
> **Template version**: v1.0+

Work through these steps in order. Check off each item as you complete it.
Re-run `/adopt` anytime to check remaining gaps.

---

## Step 1: Fix Blocking Gaps

[One sub-section per blocking gap with problem, fix command, time estimate, checkbox]

---

## Step 2: Fix High-Priority Gaps

[One sub-section per high gap]

---

## Step 3: Bootstrap Infrastructure

### 3a. Register existing requirements (creates tr-registry.yaml)
Run `/architecture-review` — even if ADRs already exist, this run bootstraps
the TR registry from your existing GDDs and ADRs.
**Time**: 1 session (review can be long for large codebases)
- [ ] tr-registry.yaml created

### 3b. Create control manifest
Run `/create-control-manifest`
**Time**: 30 min
- [ ] docs/architecture/control-manifest.md created

### 3c. Create sprint tracking file
Run `/sprint-plan update`
**Time**: 5 min (if sprint plan already exists as markdown)
- [ ] production/sprint-status.yaml created

### 3d. Set authoritative project stage
Run `/gate-check [current-phase]`
**Time**: 5 min
- [ ] production/stage.txt written

---

## Step 4: Medium-Priority Gaps

[One sub-section per medium gap]

---

## Step 5: Optional Improvements

[One sub-section per low gap]

---

## What to Expect from Existing Stories

Existing stories continue to work with all template skills. New format checks
(TR-ID validation, manifest version staleness) auto-pass when the fields are
absent — so nothing breaks. They won't benefit from staleness tracking until
regenerated. Do not regenerate stories that are in progress or done.

---

## Re-run

Run `/adopt` again after completing Step 3 to verify all blocking and high gaps
are resolved. The new run will reflect the current state of the project.
```

---

## 阶段 6b：设置审核模式

写入接入计划后（或如果用户取消写入），检查 `production/review-mode.txt` 是否存在。

**如果存在**：读取它并记录当前模式 —— "Review mode is already set to `[current]`." —— 跳过提示。

**如果不存在**：使用 `AskUserQuestion`：

- **Prompt**: "One more setup step: how much design review would you like as you work through the workflow?"
- **Options**:
  - `Full` —— Director specialists review at each key workflow step. Best for teams, learning the workflow, or when you want thorough feedback on every decision.
  - `Lean (recommended)` —— Directors only at phase gate transitions (/gate-check). Skips per-skill reviews. Balanced for solo devs and small teams.
  - `Solo` —— No director reviews at all. Maximum speed. Best for game jams, prototypes, or if reviews feel like overhead.

选择后立即写入 `production/review-mode.txt` —— 不需要单独的 "May I write?"：
- `Full` → 写入 `full`
- `Lean (recommended)` → 写入 `lean`
- `Solo` → 写入 `solo`

如果 `production/` 目录不存在，创建它。

---

## 阶段 7：提供首个行动

写入计划后，不要就此停止。挑选单个最高优先级的差距，并使用 `AskUserQuestion` 提供立即处理。选择第一个适用的分支：

**如果 systems-index.md 中存在括号状态值：**
使用 `AskUserQuestion`：
- "The most urgent fix is `systems-index.md` — [N] rows have parenthetical status
  values (e.g. `Needs Revision (see notes)`) that break /gate-check,
  /create-stories, and /architecture-review right now. I can fix these in-place."
  - "Fix it now — edit systems-index.md"
  - "I'll fix it myself"
  - "Done — leave me with the plan"

**如果 ADR 缺失 `## Status`（且没有括号问题）：**
使用 `AskUserQuestion`：
- "The most urgent fix is adding `## Status` to [N] ADR(s): [list filenames].
  Without it, /story-readiness silently passes all ADR checks. Start with
  [first affected filename]?"
  - "Yes — retrofit [first affected filename] now"
  - "Retrofit all [N] ADRs one by one"
  - "I'll handle ADRs myself"

**如果 GDD 缺失 Acceptance Criteria（且没有上述阻塞问题）：**
使用 `AskUserQuestion`：
- "The most urgent gap is missing Acceptance Criteria in [N] GDD(s):
  [list filenames]. Without them, /create-stories can't generate stories.
  Start with [highest-priority GDD filename]?"
  - "Yes — add Acceptance Criteria to [GDD filename] now"
  - "Do all [N] GDDs one by one"
  - "I'll handle GDDs myself"

**如果不存在阻塞级或高级差距：**
使用 `AskUserQuestion`：
- "No blocking gaps — this project is template-compatible. What next?"
  - "Walk me through the medium-priority improvements"
  - "Run /project-stage-detect for a broader health check"
  - "Done — I'll work through the plan at my own pace"

---

## 协作协议

1. **静默读取** —— 在展示任何内容前完成完整审核
2. **先展示摘要** —— 让用户在看到范围后再决定是否写入
3. **写入前询问** —— 在创建接入计划文件前始终确认
4. **提供建议，不强制** —— 计划是建议性的；用户决定修复什么以及何时修复
5. **一次一个行动** —— 交付计划后，提供一个具体的下一步，而不是同时列出六件事
6. **绝不重新生成现有工件** —— 只填补现有内容的差距；不要重写已有内容的 GDD、ADR 或 Story
