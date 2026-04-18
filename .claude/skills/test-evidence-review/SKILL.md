---
name: test-evidence-review
description: "测试文件和手动证据文档的质量审查。超越存在性检查 — 评估断言覆盖率、边界情况处理、命名规范和证据完整性。为每个 story 生成 ADEQUATE/INCOMPLETE/MISSING 裁决。在 QA 签署或按需之前运行。"
argument-hint: "[story-path | sprint | system-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

# Test Evidence Review

`/smoke-check` 验证测试文件是否**存在**并**通过**。此 skill 更进一步 — 它审查这些测试和证据文档的**质量**。一个存在且通过的测试文件仍可能遗漏关键行为。一个存在的证据文档可能缺少关闭所需的签署。

**输出：** 摘要报告（在对话中）+ 可选的 `production/qa/evidence-review-[date].md`

**何时运行：**

- QA 交接签署之前 (`/team-qa` 阶段 5)
- 任何测试质量存疑的 story
- 作为里程碑审查的一部分，用于 Logic 和 Integration story 质量审计

---

## 1. 解析参数

**模式：**

- `/test-evidence-review [story-path]` — 审查单个 story 的证据
- `/test-evidence-review sprint` — 审查当前冲刺中的所有 stories
- `/test-evidence-review [system-name]` — 审查 epic/system 中的所有 stories
- 无参数 — 询问哪个范围："单个 story"、"当前冲刺"、"一个系统"

---

## 2. 加载范围内的 Stories

基于参数：

**单个 story**：直接读取 story 文件。提取：Story Type、Test Evidence 部分、story slug、system name。

**冲刺**：读取 `production/sprints/` 中最近修改的文件。从冲刺计划中提取 story 文件路径列表。读取每个 story 文件。

**系统**：Glob `production/epics/[system-name]/story-*.md`。读取每个。

对于每个 story，收集：

- `Type:` 字段 (Logic / Integration / Visual/Feel / UI / Config/Data)
- `## Test Evidence` 部分 — 声明的预期测试文件路径或证据文档
- Story slug（来自文件名）
- System name（来自目录路径）
- Acceptance Criteria 列表（所有复选框项目）

---

## 3. 定位证据文件

对于每个 story，查找证据：

**Logic stories**: Glob `tests/unit/[system]/[story-slug]_test.*`

- 如果未找到，也尝试：在 `tests/unit/[system]/` 中 Grep 包含 story slug 的文件

**Integration stories**: Glob `tests/integration/[system]/[story-slug]_test.*`

- 也检查 `production/session-logs/` 中提及该 story 的游戏测试记录

**Visual/Feel and UI stories**: Glob `production/qa/evidence/[story-slug]-evidence.*`

**Config/Data stories**: Glob `production/qa/smoke-*.md`（任何 smoke check 报告）

记录每个 story 找到的内容（路径）或未找到的内容（差距）。

---

## 4. 审查自动化测试质量 (Logic / Integration)

对于每个找到的测试文件，读取并评估：

### 断言覆盖率

统计不同断言的数量（包含 assert、expect、check、verify 或引擎特定断言模式的行）。低断言数量是一个质量信号 — 每个测试函数只有 1 个断言的测试可能无法覆盖预期行为的范围。

阈值：

- **每个测试函数 3+ 断言** → 正常
- **每个测试函数 1-2 断言** → 标记为可能薄弱
- **0 断言**（测试存在但没有断言）→ 标记为 **BLOCKING** — 测试空洞通过，证明不了什么

### 边界情况覆盖

对于 story 中包含数字、阈值或 "when X happens" 条件的每个验收标准：检查测试函数名或测试体是否引用了该特定情况。

启发式方法：

- 在测试文件中 Grep "zero"、"max"、"null"、"empty"、"min"、"invalid"、"boundary"、"edge" — 任何一个存在都是积极信号
- 如果 story 的 Formulas 部分有特定边界：检查测试是否至少练习最小值/最大值

### 命名质量

测试函数名应描述：场景 + 预期结果。
模式：`test_[scenario]_[expected_outcome]`

标记命名通用（`test_1`、`test_run`、`testBasic`）的函数为**命名问题** — 它们使失败更难诊断。

### 公式可追溯性

对于 GDD 有 Formulas 部分的 Logic stories：检查测试文件是否包含至少一个测试，其名称或注释引用了公式名称或公式值。一个练习公式但不提及其名称的测试在公式更改时更难维护。

---

## 5. 审查手动证据质量 (Visual/Feel / UI)

对于每个找到的证据文档，读取并评估：

### 标准关联性

证据文档应引用 story 中的每个验收标准。检查：证据文档是否包含每个标准（或清晰的改写）？缺失标准意味着该标准从未被验证。

### 签署完整性

检查三行签署（或等效字段）：

- Developer sign-off
- Designer / art-lead sign-off（对于 Visual/Feel）
- QA lead sign-off

如果任何一项缺失或空白：标记为 INCOMPLETE — story 在没有所有必需签署的情况下无法完全关闭。

### 截图/工件完整性

对于 Visual/Feel stories：检查证据文档中是否引用了截图文件路径。如果引用了，Glob 它们以确认它们存在。

对于 UI stories：检查是否存在演练序列（逐步交互日志）。

### 日期覆盖

证据文档应有日期。如果日期早于 story 上次重大更改的日期（启发式：与冲刺计划中的冲刺开始日期比较），标记为 POTENTIALLY STALE — 证据可能无法覆盖最终实现。

---

## 6. 构建审查报告

对于每个 story，分配一个裁决：

| 裁决 | 含义 |
|------|------|
| **ADEQUATE** | 测试/证据存在，通过质量检查，所有标准已覆盖 |
| **INCOMPLETE** | 测试/证据存在但有质量差距（薄弱断言、缺失签署） |
| **MISSING** | 对于需要它的 story 类型，未找到测试或证据 |

整体冲刺/系统裁决是存在的最差 story 裁决。

```markdown
## Test Evidence Review

> **Date**: [date]
> **Scope**: [single story path | Sprint [N] | [system name]]
> **Stories reviewed**: [N]
> **Overall verdict**: ADEQUATE / INCOMPLETE / MISSING

---

### Story-by-Story Results

#### [Story Title] — [Type] — [ADEQUATE/INCOMPLETE/MISSING]

**Test/evidence path**: `[path]` (找到) / (未找到)

**Automated test quality** *(仅 Logic/Integration)*:

- Assertion coverage: [N per function on average] — [adequate / thin / none]
- Edge cases: [covered / partial / not found]
- Naming: [consistent / [N] generic names flagged]
- Formula traceability: [yes / no — formula names not referenced in tests]

**Manual evidence quality** *(仅 Visual/Feel/UI)*:

- Criterion linkage: [N/M criteria referenced]
- Sign-offs: [Developer ✓ | Designer ✗ | QA Lead ✗]
- Artefacts: [screenshots present / missing / N/A]
- Freshness: [dated [date] — current / potentially stale]

**Issues**:

- BLOCKING: [description] *(阻止 story-done)*
- ADVISORY: [description] *(应在发布前修复)*

---

### Summary

| Story | Type | Verdict | Issues |
|-------|------|---------|--------|
| [title] | Logic | ADEQUATE | None |
| [title] | Integration | INCOMPLETE | Thin assertions (avg 1.2/function) |
| [title] | Visual/Feel | INCOMPLETE | QA lead sign-off missing |
| [title] | Logic | MISSING | No test file found |

**BLOCKING items** (必须在 story 关闭前解决): [N]
**ADVISORY items** (应在发布前解决): [N]
```

---

## 7. 写入输出（可选）

在对话中展示报告。

询问："我可以将此 test evidence review 写入 `production/qa/evidence-review-[date].md` 吗？"

这是可选的 — 报告本身很有用。仅在用户想要持久记录时才写入。

报告之后：

- 对于 BLOCKING items："这些必须在 `/story-done` 将 story 标记为 Complete 之前解决。您想现在解决其中任何一个吗？"
- 对于薄弱断言："考虑运行 `/test-helpers [system]` 以查看常见情况的脚手架断言模式。"
- 对于缺失签署："需要 [role] 的手动签署。与他们分享 `[evidence-path]` 以完成签署。"

裁决：**COMPLETE** — evidence review 完成。如果发现 BLOCKING items，使用 CONCERNS。

---

## Collaborative Protocol

- **报告质量问题，不修复它们** — 此 skill 读取和评估；它不修改测试文件或证据文档
- **ADEQUATE 意味着足够发布，不是完美** — 避免挑剔运行正常且足够全面的测试
- **BLOCKING vs. ADVISORY 区分很重要** — 仅在差距使 story 标准真正未经验证时才标记为 BLOCKING
- **写入前询问** — 报告文件是可选的；写入前始终确认
