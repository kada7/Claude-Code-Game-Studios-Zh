---
name: architecture-review
description: "针对所有GDD验证项目架构的完整性和一致性。构建可追溯性矩阵，将每个GDD技术要求映射到ADR，识别覆盖差距，检测跨ADR冲突，验证所有决策中的引擎兼容性一致性，并生成通过/关注/不通过的裁决。相当于/design-review的架构版本。"
argument-hint: "[focus: full | coverage | consistency | engine | single-gdd path/to/gdd.md]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
agent: technical-director
model: opus
---

# Architecture Review

架构审查验证所有架构决策的完整性是否覆盖了全部游戏设计需求，是否在内部保持一致，并正确针对项目锁定的引擎版本。它是技术搭建与预生产之间的质量门。

**参数模式：**
- **无参数 / `full`**：完整审查 — 所有阶段
- **`coverage`**：仅可追溯性 — 哪些GDD需求没有ADR
- **`consistency`**：仅跨ADR冲突检测
- **`engine`**：仅引擎兼容性审计
- **`single-gdd [path]`**：审查特定GDD的架构覆盖
- **`rtm`**：需求可追溯性矩阵 — 将标准矩阵扩展为包含Story文件路径和测试文件路径；输出 `docs/architecture/requirements-traceability.md`，包含完整的 GDD需求 → ADR → Story → Test 链路。在已存在Story和测试的生产阶段使用。

---

## Phase 1: Load Everything

### Phase 1a — L0: Summary Scan (fast, low tokens)

在读取任何完整文档之前，使用 Grep 从所有GDD和ADR中提取 `## Summary` 章节：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 4
Grep pattern="## Summary" glob="docs/architecture/adr-*.md" output_mode="content" -A 3
```

对于 `single-gdd [path]` 模式：使用目标GDD的摘要来识别哪些ADR引用了同一系统（Grep ADR中的系统名称），然后仅完整读取这些ADR。跳过完整读取无关的GDD。

对于 `engine` 模式：仅完整读取ADR — GDD对于引擎检查不需要。

对于 `coverage` 或 `full` 模式：继续下面的完整读取。

### Phase 1b — L1/L2: Full Document Load

读取适合当前模式的所有输入：

### 设计文档
- `design/gdd/` 中所有范围内的GDD — 完整读取每个文件
- `design/gdd/systems-index.md` — 系统权威列表

### 架构文档
- `docs/architecture/` 中所有范围内的ADR — 完整读取每个文件
- 如果存在，`docs/architecture/architecture.md`

### 引擎参考
- `docs/engine-reference/[engine]/VERSION.md`
- `docs/engine-reference/[engine]/breaking-changes.md`
- `docs/engine-reference/[engine]/deprecated-apis.md`
- `docs/engine-reference/[engine]/modules/` 中的所有文件

### 项目标准
- `.claude/docs/technical-preferences.md`

报告数量："已加载 [N] 个GDD，[M] 个ADR，引擎：[名称 + 版本]。"

**同时读取 `docs/consistency-failures.md`** 如果存在。提取 Domain 与审查中的系统匹配（Architecture、Engine 或任何被覆盖的GDD Domain）的条目。将重复出现的模式作为"已知易冲突区域"注释，放在Phase 4冲突检测输出的顶部。

---

## Phase 2: Extract Technical Requirements from Every GDD

### Pre-load the TR Registry

在提取任何需求之前，如果存在则读取 `docs/architecture/tr-registry.yaml`。按 `id` 和规范化后的 `requirement` 文本（小写、去空格）索引已有条目。这可以防止审查运行间的ID重新编号。

对于每个提取的需求，匹配规则为：
1. **精确/近似匹配** 同一系统的已有注册表条目 → 复用该条目的TR-ID不变。仅在GDD措辞发生变化时（相同意图、更清晰表述）更新注册表中的 `requirement` 文本 — 添加 `revised: [date]` 字段。
2. **无匹配** → 分配新ID：该系统下一个可用的 `TR-[system]-NNN`，从最高已有序号 + 1 开始。
3. **模糊匹配**（部分匹配，意图不清）→ 询问用户：
   > "'[新需求文本]' 是否指与 `TR-[system]-NNN: [已有文本]'` 相同的需求，还是一个新需求？"
   用户回答："同一需求"（复用ID）或"新需求"（新ID）。

对于注册表中任何 `status: deprecated` 的需求 — 跳过它。
它已从GDD中故意移除。

对于每个GDD，读取并提取所有**技术要求** — 架构必须提供以使系统工作的内容。技术要求是任何暗示特定架构决策的陈述。

提取类别：

| 类别 | 示例 |
|----------|---------|
| **数据结构** | "每个实体都有生命值、最大生命值、状态效果" → 需要组件/数据模式 |
| **性能约束** | "碰撞检测必须在60fps下支持200个实体运行" → 物理预算ADR |
| **引擎能力** | "角色动画的反向运动学" → IK系统ADR |
| **跨系统通信** | "伤害系统同时通知UI和音频" → 事件/信号架构ADR |
| **状态持久化** | "玩家进度在会话间持久化" → 存档系统ADR |
| **线程/时序** | "AI决策在主线程外进行" → 并发ADR |
| **平台需求** | "支持键盘、手柄、触摸" → 输入系统ADR |

对于每个GDD，生成结构化列表：

```
GDD: [filename]
System: [system name]
Technical Requirements:
  TR-[GDD]-001: [requirement text] → Domain: [Physics/Rendering/etc]
  TR-[GDD]-002: [requirement text] → Domain: [...]
```

这成为**需求基线** — 架构必须覆盖的完整集合。

---

## Phase 3: Build the Traceability Matrix

对于Phase 2中提取的每个技术要求，搜索ADR：

1. 读取每个ADR的 "GDD Requirements Addressed" 章节
2. 检查它是否显式引用该需求或其GDD
3. 检查ADR的决策文本是否隐式覆盖该需求
4. 标记覆盖状态：

| 状态 | 含义 |
|--------|---------|
| ✅ **已覆盖** | ADR显式处理此需求 |
| ⚠️ **部分** | ADR部分覆盖此需求，或覆盖不明确 |
| ❌ **缺口** | 没有ADR处理此需求 |

构建完整矩阵：

```
## Traceability Matrix

| Requirement ID | GDD | System | Requirement | ADR Coverage | Status |
|---------------|-----|--------|-------------|--------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox detection < 1 frame | ADR-0003 | ✅ |
| TR-combat-002 | combat.md | Combat | Combo window timing | — | ❌ GAP |
| TR-inventory-001 | inventory.md | Inventory | Persistent item storage | ADR-0005 | ✅ |
```

统计总数：X已覆盖，Y部分，Z缺口。

---

## Phase 3b: Story and Test Linkage (RTM mode only)

*除非参数为 `rtm` 或 `full` 且Story已存在，否则跳过此阶段。*

此阶段将Phase 3矩阵扩展为包含实现每个需求的Story和验证它的测试 — 生成完整的Requirements Traceability Matrix (RTM)。

### Step 3b-1 — Load stories

Glob `production/epics/**/*.md`（排除 EPIC.md 索引文件）。对于每个Story文件：
- 从Story的 Context 章节提取 `TR-ID`
- 提取Story文件路径、标题、Status
- 提取 `## Test Evidence` 章节 — 声明的测试文件路径

### Step 3b-2 — Load test files

Glob `tests/unit/**/*_test.*` 和 `tests/integration/**/*_test.*`。
构建索引：system → [test file paths]。

对于Step 3b-1中的每个测试文件路径，通过 Glob 确认文件是否实际存在。如果声明的路径不存在，标注 MISSING。

### Step 3b-3 — Build the extended RTM

对于Phase 3矩阵中的每个TR-ID，添加：
- **Story**：引用此TR-ID的Story文件路径（可能有多个）
- **Test File**：Story的 Test Evidence 章节中声明的测试文件路径
- **Test Status**：COVERED（测试文件存在）/ MISSING（声明了路径但未找到）/ NONE（未声明测试路径，Story类型可能是Visual/Feel/UI）/ NO STORY（需求还没有Story — 预生产缺口）

扩展矩阵格式：

```
## Requirements Traceability Matrix (RTM)

| TR-ID | GDD | Requirement | ADR | Story | Test File | Test Status |
|-------|-----|-------------|-----|-------|-----------|-------------|
| TR-combat-001 | combat.md | Hitbox < 1 frame | ADR-0003 | story-001-hitbox.md | tests/unit/combat/hitbox_test.gd | COVERED |
| TR-combat-002 | combat.md | Combo window | — | story-002-combo.md | — | NONE (Visual/Feel) |
| TR-inventory-001 | inventory.md | Persistent storage | ADR-0005 | — | — | NO STORY |
```

RTM覆盖摘要：
- COVERED: [N] — 有ADR + Story + 通过测试的需求
- MISSING test: [N] — Story存在但测试文件未找到
- NO STORY: [N] — 有ADR但还没有Story
- NO ADR: [N] — 没有架构覆盖的需求（来自Phase 3缺口）
- 完整链路完成 (COVERED): [N/total] ([%])

---

## Phase 4: Cross-ADR Conflict Detection

将每个ADR与其他每个ADR进行比较以检测矛盾。当以下情况存在时，即存在冲突：

- **数据所有权冲突**：两个ADR声称对同一数据的独占所有权
- **集成契约冲突**：ADR-A假设系统X有接口Y，但ADR-B用不同接口定义了系统X
- **性能预算冲突**：ADR-A分配N毫秒给物理，ADR-B分配N毫秒给AI，合起来超过总帧预算
- **依赖循环**：ADR-A说系统X在Y之前初始化；ADR-B说Y在X之前初始化
- **架构模式冲突**：ADR-A对子系统使用事件驱动通信；ADR-B对同一子系统使用直接函数调用
- **状态管理冲突**：两个ADR对同一游戏状态定义权威（例如Combat ADR和Character ADR都声称拥有生命值）

对于发现的每个冲突：

```
## Conflict: [ADR-NNNN] vs [ADR-MMMM]
Type: [Data ownership / Integration / Performance / Dependency / Pattern / State]
ADR-NNNN claims: [...]
ADR-MMMM claims: [...]
Impact: [如果两者都按所写实现，什么会出问题]
Resolution options:
  1. [选项 A]
  2. [选项 B]
```

### ADR Dependency Ordering

冲突检测后，分析所有ADR间的依赖图：

1. **收集所有 `Depends On` 字段** 从每个ADR的 "ADR Dependencies" 章节
2. **拓扑排序**：确定正确的实现顺序 — 无依赖的ADR优先（Foundation），依赖它们的ADR随后，等等。
3. **标记未解决的依赖**：如果ADR-A的 "Depends On" 字段引用了一个仍为 `Proposed` 或不存在的ADR，标记它：
   ```
   ⚠️  ADR-0005 依赖于 ADR-0002 — 但 ADR-0002 仍为 Proposed。
       ADR-0005 在 ADR-0002 被 Accepted 之前无法安全实现。
   ```
4. **循环检测**：如果ADR-A依赖于ADR-B且ADR-B依赖于ADR-A（直接或间接），标记为 `DEPENDENCY CYCLE`：
   ```
   🔴 DEPENDENCY CYCLE: ADR-0003 → ADR-0006 → ADR-0003
      此循环必须在任一实现之前打破。
   ```
5. **输出推荐的实现顺序**：
   ```
   ### Recommended ADR Implementation Order (topologically sorted)
   Foundation (no dependencies):
     1. ADR-0001: [title]
     2. ADR-0003: [title]
   Depends on Foundation:
     3. ADR-0002: [title] (requires ADR-0001)
     4. ADR-0005: [title] (requires ADR-0003)
   Feature layer:
     5. ADR-0004: [title] (requires ADR-0002, ADR-0005)
   ```

---

## Phase 5: Engine Compatibility Cross-Check

跨所有ADR检查引擎一致性：

### Version Consistency
- 所有提及引擎版本的ADR是否都同意同一版本？
- 如果任何ADR为旧引擎版本编写，标记为可能过时

### Post-Cutoff API Consistency
- 从所有ADR收集 "Post-Cutoff APIs Used" 字段
- 对每个字段，根据相关模块参考文档验证
- 检查没有两个ADR对同一post-cutoff API做出矛盾的假设

### Deprecated API Check
- Grep所有ADR中列在 `deprecated-apis.md` 中的API名称
- 标记任何引用已弃用API的ADR

### Missing Engine Compatibility Sections
- 列出所有缺少 Engine Compatibility 章节的ADR
- 这些是盲点 — 它们的引擎假设未知

输出格式：
```
### Engine Audit Results
Engine: [name + version]
ADRs with Engine Compatibility section: X / Y total

Deprecated API References:
  - ADR-0002: uses [deprecated API] — deprecated since [version]

Stale Version References:
  - ADR-0001: written for [older version] — current project version is [version]

Post-Cutoff API Conflicts:
  - ADR-0004 and ADR-0007 both use [API] with incompatible assumptions
```

---

### Engine Specialist Consultation

完成上述引擎审计后，通过 Task 生成**主引擎专家**以获取领域专家的第二意见：
- 读取 `.claude/docs/technical-preferences.md` 的 `Engine Specialists` 章节以获取主专家
- 如果没有配置引擎，跳过此咨询
- 生成 `subagent_type: [primary specialist]`，携带：所有包含引擎特定决策或 `Post-Cutoff APIs Used` 字段的ADR、引擎参考文档、以及Phase 5审计发现。要求他们：
  1. 确认或质疑每个审计发现 — 专家可能了解参考文档未涵盖的引擎细微差别
  2. 识别审计可能遗漏的ADR中的引擎特定反模式（例如，使用错误的Godot节点类型、Unity组件耦合、Unreal子系统误用）
  3. 标记对引擎行为做出与锁定版本实际行为不同假设的ADR

在Phase 5输出的 `### Engine Specialist Findings` 下纳入额外发现。这些进入最终裁决 — 专家识别的问题与审计识别的问题权重相同。

---

## Phase 5b: Design Revision Flags (Architecture → GDD Feedback)

对于Phase 5中的每个**高风险引擎发现**，检查是否有GDD做出与已验证引擎现实相矛盾的假设。

具体检查情况：

1. **Post-cutoff API行为与训练数据假设不同**：如果ADR记录了与默认LLM假设不同的已验证API行为，检查所有引用相关系统的GDD。寻找围绕旧（假设）行为编写的设计规则。

2. **ADR中的已知引擎限制**：如果ADR记录了已知引擎限制（例如 "Jolt忽略HingeJoint3D damp"、"D3D12现在是默认后端"），检查围绕受影响功能设计机制的GDD。

3. **弃用API冲突**：如果Phase 5标记了ADR中使用的弃用API，检查是否有GDD包含假设弃用API行为的机制。

对于发现的每个冲突，记录在GDD Revision Flags表中：

```
### GDD Revision Flags (Architecture → Design Feedback)
These GDD assumptions conflict with verified engine behaviour or accepted ADRs.
The GDD should be revised before its system enters implementation.

| GDD | Assumption | Reality (from ADR/engine-reference) | Action |
|-----|-----------|--------------------------------------|--------|
| combat.md | "Use HingeJoint3D damp for weapon recoil" | Jolt ignores damp — ADR-0003 | Revise GDD |
```

如果没有发现修订标记，写："No GDD revision flags — all GDD assumptions
are consistent with verified engine behaviour."

问："Should I flag these GDDs for revision in the systems index?"
- 如果同意：将相关系统的 Status 字段更新为 "Needs Revision"，并在相邻的 Notes/Description 列中添加简短的内联注释解释冲突。
  写入前请求批准。
  （不要使用括号如 "Needs Revision (Architecture Feedback)" — 其他Skill匹配精确字符串 "Needs Revision"，括号会破坏该匹配。）

---

## Phase 6: Architecture Document Coverage

如果 `docs/architecture/architecture.md` 存在，根据GDD验证它：

- `systems-index.md` 中的每个系统是否都出现在架构层级中？
- 数据流章节是否覆盖了GDD中定义的所有跨系统通信？
- API边界是否支持GDD中的所有集成需求？
- 架构文档中是否有系统没有对应的GDD（孤立架构）？

---

## Phase 7: Output the Review Report

```
## Architecture Review Report
Date: [date]
Engine: [name + version]
GDDs Reviewed: [N]
ADRs Reviewed: [M]

---

### Traceability Summary
Total requirements: [N]
✅ Covered: [X]
⚠️ Partial: [Y]
❌ Gaps: [Z]

### Coverage Gaps (no ADR exists)
For each gap:
  ❌ TR-[id]: [GDD] → [system] → [requirement]
     Suggested ADR: "/architecture-decision [suggested title]"
     Domain: [Physics/Rendering/etc]
     Engine Risk: [LOW/MEDIUM/HIGH]

### Cross-ADR Conflicts
[List all conflicts from Phase 4]

### ADR Dependency Order
[Topologically sorted implementation order from Phase 4 — dependency ordering section]
[Unresolved dependencies and cycles if any]

### GDD Revision Flags
[GDD assumptions that conflict with verified engine behaviour — from Phase 5b]
[Or: "None — all GDD assumptions consistent with verified engine behaviour"]

### Engine Compatibility Issues
[List all engine issues from Phase 5]

### Architecture Document Coverage
[List missing systems and orphaned architecture from Phase 6]

---

### Verdict: [PASS / CONCERNS / FAIL]

PASS: 所有需求已覆盖，无冲突，引擎一致
CONCERNS: 存在部分缺口或部分覆盖，但无阻塞冲突
FAIL: 关键缺口（Foundation/Core层需求未覆盖），
      或检测到阻塞性跨ADR冲突

### Blocking Issues (must resolve before PASS)
[List items that must be resolved — FAIL verdict only]

### Required ADRs
[Prioritised list of ADRs to create, most foundational first]
```

---

## Phase 8: Write and Update Traceability Index

使用 `AskUserQuestion` 获取写入批准：
- "Review complete. What would you like to write?"
  - [A] 写入全部三个文件（审查报告 + 可追溯性索引 + TR注册表）
  - [B] 仅写入审查报告 — `docs/architecture/architecture-review-[date].md`
  - [C] 暂时不写入任何内容 — 我需要先审查发现

### RTM Output (rtm mode only)

对于 `rtm` 模式，额外询问："是否可以将完整的需求可追溯性矩阵
写入 `docs/architecture/requirements-traceability.md`？"

RTM文件格式：

```markdown
# Requirements Traceability Matrix (RTM)

> Last Updated: [date]
> Mode: /architecture-review rtm
> Coverage: [N]% full chain complete (GDD → ADR → Story → Test)

## How to read this matrix

| Column | Meaning |
|--------|---------|
| TR-ID | Stable requirement ID from tr-registry.yaml |
| GDD | Source design document |
| ADR | Architectural decision governing implementation |
| Story | Story file that implements this requirement |
| Test File | Automated test file path |
| Test Status | COVERED / MISSING / NONE / NO STORY |

## Full Traceability Matrix

| TR-ID | GDD | Requirement | ADR | Story | Test File | Status |
|-------|-----|-------------|-----|-------|-----------|--------|
[Full matrix rows from Phase 3b]

## Coverage Summary

| Status | Count | % |
|--------|-------|---|
| COVERED — full chain complete | [N] | [%] |
| MISSING test — story exists, no test | [N] | [%] |
| NO STORY — ADR exists, not yet implemented | [N] | [%] |
| NO ADR — architectural gap | [N] | [%] |
| **Total requirements** | **[N]** | **100%** |

## Uncovered Requirements (Priority Fix List)

Requirements where the full chain is broken, prioritised by layer:

### Foundation layer gaps
[list with suggested action per gap]

### Core layer gaps
[list]

### Feature / Presentation layer gaps
[list — lower priority]

## History

| Date | Full Chain % | Notes |
|------|-------------|-------|
| [date] | [%] | Initial RTM |
```

### TR Registry Update

同时询问："是否可以用本次审查的新需求ID更新
`docs/architecture/tr-registry.yaml`？"

如果同意：
- **追加** 此审查前注册表中不存在的任何新TR-ID
- **更新** 任何GDD措辞发生变化的条目的 `requirement` 文本和 `revised` 日期（ID保持不变）
- **标记** `status: deprecated` 对于任何GDD需求不再存在的注册表条目（标记弃用前与用户确认）
- **绝不** 重新编号或删除已有条目
- 更新顶部的 `last_updated` 和 `version` 字段

这确保所有未来的Story文件都可以引用在每次后续架构审查中持续存在的稳定TR-ID。

### Reflexion Log Update

写入审查报告后，将Phase 4中发现的任何 🔴 CONFLICT 条目追加到 `docs/consistency-failures.md`（如果文件存在）：

```markdown
### [YYYY-MM-DD] — /architecture-review — 🔴 CONFLICT
**Domain**: Architecture / [specific domain e.g. State Ownership, Performance]
**Documents involved**: [ADR-NNNN] vs [ADR-MMMM]
**What happened**: [specific conflict — what each ADR claims]
**Resolution**: [how it was or should be resolved]
**Pattern**: [generalised lesson for future ADR authors in this domain]
```

仅追加 CONFLICT 条目 — 不要记录 GAP 条目（缺失ADR在架构完成前是预期的）。如果文件缺失不要创建 — 仅在文件已存在时追加。

### Session State Update

写入所有批准的文件后，静默追加到 `production/session-state/active.md`：

    ## Session Extract — /architecture-review [date]
    - Verdict: [PASS / CONCERNS / FAIL]
    - Requirements: [N] total — [X] covered, [Y] partial, [Z] gaps
    - New TR-IDs registered: [N, or "None"]
    - GDD revision flags: [comma-separated GDD names, or "None"]
    - Top ADR gaps: [top 3 gap titles from the report, or "None"]
    - Report: docs/architecture/architecture-review-[date].md

如果 `active.md` 不存在，以此块作为初始内容创建它。
在对话中确认："会话状态已更新。"

可追溯性索引格式：

```markdown
# Architecture Traceability Index
Last Updated: [date]
Engine: [name + version]

## Coverage Summary
- Total requirements: [N]
- Covered: [X] ([%])
- Partial: [Y]
- Gaps: [Z]

## Full Matrix
[Complete traceability matrix from Phase 3]

## Known Gaps
[All ❌ items with suggested ADRs]

## Superseded Requirements
[Requirements whose GDD was changed after the ADR was written]
```

---

## Phase 9: Handoff

完成审查并写入批准的文件后，呈现：

1. **Immediate actions**: 列出前3个需要创建的ADR（高影响缺口优先，Foundation层在Feature层之前）
2. **Gate guidance**: "When all blocking issues are resolved, run `/gate-check
   pre-production` to advance"
3. **Rerun trigger**: "Re-run `/architecture-review` after each new ADR is written
   to verify coverage improves"

然后以 `AskUserQuestion` 结束：
"架构审查完成。接下来你想做什么？"
  - [A] 编写缺失的ADR — 打开新会话并运行 `/architecture-decision [system]`
  - [B] 运行 `/gate-check pre-production` — 如果所有阻塞缺口已解决
  - [C] 此会话在此停止

---

## Error Recovery Protocol

如果任何生成的Agent返回BLOCKED、错误或无法完成：

1. **立即上报**：在继续前报告 "[AgentName]: BLOCKED — [reason]"
2. **评估依赖**：如果被阻塞Agent的输出被后续阶段需要，在没有用户输入的情况下不要越过该阶段
3. 通过 AskUserQuestion 提供三个选项：
   - 跳过此Agent并在最终报告中注明缺口
   - 以更窄的范围重试（更少GDD、单系统聚焦）
   - 在此停止并先解决阻塞项
4. **始终生成部分报告** — 输出已完成的内容，以免工作丢失

---

## Collaborative Protocol

1. **静默读取** — 不要叙述每个文件读取
2. **展示矩阵** — 在请求任何内容前呈现完整的可追溯性矩阵；让用户看到状态
3. **不要猜测** — 如果需求不明确，问："[X] 是技术要求
   还是设计偏好？"
4. **写入前询问** — 写入报告文件前始终确认
5. **非阻塞** — 裁决是建议性的；用户决定是否尽管有 CONCERNS 甚至 FAIL 发现也继续
