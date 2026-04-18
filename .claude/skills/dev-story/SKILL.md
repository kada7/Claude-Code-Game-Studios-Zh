---
name: dev-story
description: "读取story文件并实现它。加载完整上下文（story、GDD需求、ADR指导、控制清单），路由到正确的程序员代理，实现代码和测试，并确认每个验收标准。核心实现技能 — 在/story-readiness之后、/code-review和/story-done之前运行。"
argument-hint: "[story-path]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion
---

# Dev Story

This skill bridges planning and code. It reads a story file in full, assembles
all the context a programmer needs, routes to the correct specialist agent, and
drives implementation to completion — including writing the test.

**每个story的循环：**
```
/qa-plan sprint           ← 在冲刺开始前定义测试需求
/story-readiness [path]   ← 在开始之前验证
/dev-story [path]         ← 实现它  (这个技能)
/code-review [files]      ← 审查它
/story-done [path]        ← 验证并关闭它
```

**在所有冲刺story完成后：** 运行 `/team-qa sprint` 来执行完整的QA周期并在推进项目阶段之前获得签署批准。

**输出:** 源代码 + 测试文件，位于项目的 `src/` 和 `tests/` 目录中。

---

## Phase 1: Find the Story

**如果提供了路径**: 直接读取该文件。

**如果没有参数**: 检查 `production/session-state/active.md` 中活跃的
story。如果找到，确认："继续处理 [story title] — 是否正确？"
如果未找到，询问："我们正在实现哪个story？" Glob
`production/epics/**/*.md` 并列出状态为 Ready 的 story。

---

## Phase 2: Load Full Context

**在加载任何上下文之前，验证必需的文件是否存在。** 从 story 的 `ADR Governing Implementation` 字段提取 ADR 路径，然后检查：

| 文件 | 路径 | 如果缺失 |
|------|------|------------|
| TR registry | `docs/architecture/tr-registry.yaml` | **停止** — "TR registry 未找到。运行 `/create-epics` 来生成它。" |
| Governing ADR | story ADR 字段中的路径 | **停止** — "ADR 文件 [path] 未找到。运行 `/architecture-decision` 来创建它，或更正 story ADR 字段中的文件名。" |
| Control manifest | `docs/architecture/control-manifest.md` | **警告并继续** — "Control manifest 未找到 — 无法检查层级规则。运行 `/create-control-manifest`。" |

如果 TR registry 或 governing ADR 缺失，在 session state 中将 story 状态设置为 **BLOCKED** 并且不生成任何程序员代理。

同时读取以下内容 — 这些是独立的读取。在所有上下文加载完成之前不要开始实现：

### story 文件
提取并保留：
- **Story title, ID, layer, type** (Logic / Integration / Visual/Feel / UI / Config/Data)
- **TR-ID** — GDD 需求标识符
- **Governing ADR** 引用
- **Manifest Version** 嵌入在 story 头部
- **Acceptance Criteria** — 每个复选框项目，原文
- **Implementation Notes** — story 中的 ADR 指导部分
- **Out of Scope** 边界
- **Test Evidence** — 必需的测试文件路径
- **Dependencies** — 在此 story 之前必须完成的

### TR registry
读取 `docs/architecture/tr-registry.yaml`。查找 story 的 TR-ID。
读取当前的 `requirement` 文本 — 这是 GDD 当前需求的权威来源。不要依赖 story 文件中的任何内联文本（可能已过时）。

### governing ADR
读取 `docs/architecture/[adr-file].md`。提取：
- 完整的 Decision 部分
- Implementation Guidelines 部分（这是程序员遵循的内容）
- Engine Compatibility 部分（post-cutoff APIs, 已知风险）
- ADR Dependencies 部分

### control manifest
读取 `docs/architecture/control-manifest.md`。提取此 story 层级的规则：
- Required patterns
- Forbidden patterns
- Performance guardrails

检查：story 中嵌入的 Manifest Version 是否与当前 manifest 头部日期匹配？
如果不同，在继续之前使用 `AskUserQuestion`：
- 提示："Story 是针对 manifest v[story-date] 编写的。当前 manifest 是 v[current-date]。新规则可能适用。你希望如何继续？"
- 选项：
  - `[A] 更新 story manifest 版本并使用当前规则实现（推荐）`
  - `[B] 使用旧规则实现 — 我接受不合规的风险`
  - `[C] 在这里停止 — 我想先审查 manifest 差异`

如果 [A]：在生成程序员之前，将 story 文件的 `Manifest Version:` 字段编辑为当前 manifest 日期。然后仔细阅读 manifest 中的新规则。
如果 [B]: 无论如何仔细阅读 manifest 中的新规则，并在 Phase 6 摘要的 "Deviations" 下注明版本不匹配。
如果 [C]: 停止。不要生成任何代理。让用户审查并重新运行 `/dev-story`。

### Dependency validation

从 story 文件提取 **Dependencies** 列表后，验证每个：

1. Glob `production/epics/**/*.md` 来找到每个 dependency story 文件。
2. 读取其 `Status:` 字段。
3. 如果任何 dependency 的状态不是 `Complete` 或 `Done`：
   - 使用 `AskUserQuestion`：
     - 提示："Story '[current story]' 依赖于 '[dependency title]'，它当前的状态是 [status]，不是 Complete。你希望如何继续？"
     - 选项：
       - `[A] 无论如何继续 — 我接受 dependency 风险`
       - `[B] 停止 — 我先完成 dependency`
       - `[C] dependency 已完成但状态未更新 — 将其标记为 Complete 并继续`
   - 如果 [B]: 在 session state 中将 story 状态设置为 **BLOCKED** 并停止。不要生成任何程序员代理。
   - 如果 [C]: 在继续之前询问 "我可以将 [dependency path] 的 Status 更新为 Complete 吗？"
   - 如果 [A]: 在 Phase 6 摘要的 "Deviations" 下注明："Implemented with incomplete dependency: [dependency title] — [status]."

如果找不到 dependency 文件：警告 "Dependency story not found: [path]. Verify the path or create the story file."

---

### Engine reference
读取 `.claude/docs/technical-preferences.md`：
- `Engine:` 值 — 决定使用哪些程序员代理
- 命名约定（类名、文件名、信号/事件名）
- 性能预算（帧预算、内存上限）
- Forbidden patterns

---

## Phase 3: Route to the Right Programmer

根据 story 的 **Layer**、**Type** 和系统名称，决定通过 Task 生成哪个专家。

**Config/Data story — 完全跳过代理生成：**
如果 story 的 Type 是 `Config/Data`，不需要程序员代理或引擎专家。直接跳转到 Phase 4（Config/Data 说明）。实现是数据文件编辑 — 不需要路由表评估，不需要引擎专家。

### Primary agent routing table

| Story 上下文 | Primary agent |
|---|---|
| Foundation layer — 任何 type | `engine-programmer` |
| 任何 layer — Type: UI | `ui-programmer` |
| 任何 layer — Type: Visual/Feel | `gameplay-programmer` (实现) |
| Core 或 Feature — gameplay mechanics | `gameplay-programmer` |
| Core 或 Feature — AI behaviour, pathfinding | `ai-programmer` |
| Core 或 Feature — networking, replication | `network-programmer` |
| Config/Data — 无代码 | 不需要代理 (参见 Phase 4 Config 说明) |

### Engine specialist — 对于代码 story 始终作为 secondary 生成

读取 `.claude/docs/technical-preferences.md` 的 `Engine Specialists` 部分
来获取配置的主要专家。当 story 涉及引擎特定的 API、模式，或 ADR 具有 HIGH
引擎风险时，与他们一起生成。

| Engine | 可用的 Specialist agents |
|--------|----------------------------|
| Godot 4 | `godot-specialist`, `godot-gdscript-specialist`, `godot-shader-specialist` |
| Unity | `unity-specialist`, `unity-ui-specialist`, `unity-shader-specialist` |
| Unreal Engine | `unreal-specialist`, `ue-gas-specialist`, `ue-blueprint-specialist`, `ue-umg-specialist`, `ue-replication-specialist` |

**当引擎风险为 HIGH**（来自 ADR 或 VERSION.md）：始终生成引擎
专家，即使对于非引擎面向的 story。高风险意味着 ADR 记录了需要专家验证的关于 post-cutoff 引擎 API 的假设。

---

## Phase 4: Implement

通过 Task 生成选定的程序员代理，并提供完整的上下文包：

向代理提供：
1. 完整的 story 文件内容
2. 当前的 GDD 需求文本（来自 TR registry）
3. ADR Decision + Implementation Guidelines（原文 — 不要总结）
4. 此层级的 control manifest 规则
5. 引擎命名约定和性能预算
6. ADR Engine Compatibility 部分的任何引擎特定说明
7. 必须创建的测试文件路径
8. 明确指示：**实现此 story 并编写测试**

代理应该：
- 在 `src/` 中创建或修改文件，遵循 ADR 指南
- 尊重 control manifest 中的所有 Required 和 Forbidden 模式
- 保持在 story 的 Out of Scope 边界内（不要接触不相关的文件）
- 编写干净的、有文档注释的公共 API

### Config/Data story (不需要代理)

对于 Type: Config/Data 的 story，不需要程序员代理。实现是编辑数据文件。读取 story 的验收标准并直接对数据文件进行指定的更改。记录哪些值被更改以及它们从/到什么。

### Visual/Feel story

生成 `gameplay-programmer` 来实现代码/动画调用。注意
Visual/Feel 验收标准无法自动验证 — "感觉对吗？"
检查在 `/story-done` 中通过手动确认进行。

---

## Phase 5: Write the Test

对于 **Logic** 和 **Integration** story，测试必须作为此实现的一部分编写 — 不要推迟到以后。

提醒程序员代理：

> "此 story 的测试文件在：`[path from Test Evidence section]` 是必需的。
> 没有它，story 无法通过 `/story-done` 关闭。编写测试
> 与实现一起，而不是之后。"

测试要求（来自 coding-standards.md）：
- 文件名: `[system]_[feature]_test.[ext]`
- 函数名: `test_[scenario]_[expected_outcome]`
- 每个验收标准必须至少有一个测试函数覆盖它
- 没有随机种子，没有时间相关的断言，没有外部 I/O
- 测试 GDD Formulas 部分的公式边界

对于 **Visual/Feel** 和 **UI** story：没有自动化测试。提醒代理在实现摘要中注明需要什么手动证据：
"Evidence doc required at `production/qa/evidence/[slug]-evidence.md`."

对于 **Config/Data** story：没有测试文件。smoke check 将作为证据。

---

## Phase 6: Collect and Summarise

程序员代理完成后，收集：

- 创建或修改的文件（带路径）
- 创建的测试文件（路径和编写的测试函数数量）
- 与 story Out of Scope 边界的任何偏差（标记这些）
- 代理提出的任何问题或阻塞项
- 专家标记的任何引擎特定风险

提供简洁的实现摘要：

```
## Implementation Complete: [Story Title]

**Files changed**:
- `src/[path]` — 创建 / 修改 ([brief description])
- `tests/[path]` — 测试文件 ([N] 测试函数)

**Acceptance criteria covered**:
- [x] [criterion] — 实现在 [file:function]
- [x] [criterion] — 由测试 [test_name] 覆盖
- [ ] [criterion] — 延期: 需要 playtest (Visual/Feel)

**Deviations from scope**: [无] 或 [列出在 story 边界外接触的文件]
**Engine risks flagged**: [无] 或 [specialist finding]
**Blockers**: [无] 或 [describe]

准备进行: `/code-review [file1] [file2]` 然后 `/story-done [story-path]`
```

---

## Phase 7: Update Session State

静默追加到 `production/session-state/active.md`：

```
## Session Extract — /dev-story [date]
- Story: [story-path] — [story title]
- Files changed: [comma-separated list]
- Test written: [path, 或 "None — Visual/Feel/Config story"]
- Blockers: [无, 或 description]
- Next: /code-review [files] 然后 /story-done [story-path]
```

如果它不存在，创建 `active.md`。确认："Session state updated."

---

## Error Recovery Protocol

如果任何生成的代理（通过 Task）返回 BLOCKED、错误或无法完成：

1. **立即显示**: 在继续到依赖阶段之前向用户报告 "[AgentName]: BLOCKED — [reason]"
2. **评估依赖项**: 检查被阻塞代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点继续。
3. **提供选项** 通过 AskUserQuestion 提供选择：
   - 跳过此代理并在最终报告中注明差距
   - 以更小范围重试
   - 在这里停止并先解决阻塞项
4. **始终生成部分报告** — 输出任何已完成的内容。永远不要因为一个代理阻塞而丢弃工作。

常见的阻塞项：
- 输入文件缺失（story 未找到，GDD 不存在）→ 重定向到创建它的技能
- ADR 状态是 Proposed → 不要实现；先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个 story
- ADR 和 story 之间的冲突指示 → 显示冲突，不要猜测
- Manifest 版本不匹配 → 向用户显示差异，询问是使用旧规则继续还是先更新 story

## Collaborative Protocol

- **文件写入被委托** — 所有源代码、测试文件和证据文档都由通过 Task 生成的子代理编写。每个子代理强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。
- **实现前加载** — 在所有上下文加载完成之前不要开始编码
  （story, TR-ID, ADR, manifest, engine prefs）。不完整的上下文会产生偏离设计的代码。
- **ADR 是法律** — 实现必须遵循 ADR 的 Implementation
  Guidelines。如果指南与看起来 "更好" 的内容冲突，在摘要中标记它而不是默默偏离。
- **保持在范围内** — Out of Scope 部分是契约。如果实现
  story 需要接触超出范围的文件，停止并显示它：
  "Implementing [criterion] requires modifying [file], which is out of scope.
  Shall I proceed or create a separate story?"
- **对于 Logic/Integration，测试不是可选的** — 不要在测试文件不存在的情况下标记实现完成
- **Visual/Feel 标准是延期，不是跳过** — 在摘要中将它们标记为 DEFERRED；它们将在 `/story-done` 中手动验证
- **在大的结构决策前询问** — 如果 story 需要 ADR 未涵盖的架构模式，在实施前显示它：
  "The ADR doesn't specify how to handle [case]. My plan is [X]. Proceed?"

---

## Recommended Next Steps

- 在关闭 story 之前运行 `/code-review [file1] [file2]` 来审查实现
- 运行 `/story-done [story-path]` 来验证验收标准并将 story 标记为完成
- 在所有 sprint story 完成后：在推进项目阶段之前运行 `/team-qa sprint` 进行完整的 QA 周期
