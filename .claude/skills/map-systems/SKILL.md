---
name: map-systems
description: "将游戏概念分解为单独的系统，映射依赖关系，确定设计优先级顺序，并创建系统索引。"
argument-hint: "[next | system-name] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, TodoWrite, Task
---

调用此技能时：

## Parse Arguments

两种模式：

- **无参数**: `/map-systems` — 运行完整的分解工作流（Phases 1-5）
  来创建或更新 systems index。
- **`next`**: `/map-systems next` — 从索引中挑选最高优先级的未设计系统
  并移交给 `/design-system` (Phase 6)。

还要解析审查模式（一次，存储用于此运行的所有关卡生成）：
1. 如果传入了 `--review [full|lean|solo]` → 使用它
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

有关完整检查模式，请参阅 `.claude/docs/director-gates.md`。

---

## Phase 1: Read Concept (Required Context)

读取游戏概念和任何现有的设计工作。这提供了系统分解的原材料。

**必需：**
- 读取 `design/gdd/game-concept.md` — **如果缺失则失败并显示清晰消息**：
  > "在 `design/gdd/game-concept.md` 未找到游戏概念。首先运行 `/brainstorm` 
  > 来创建一个，然后回来将其分解为系统。"

**可选（如果存在则读取）：**
- 读取 `design/gdd/game-pillars.md` — pillars 限制优先级和范围
- 读取 `design/gdd/systems-index.md` — 如果存在，**从它离开的地方恢复**
  （更新，不要从头重新创建）
- Glob `design/gdd/*.md` — 检查哪些系统 GDDs 已经存在

**如果 systems index 已经存在：**
- 读取它并向用户展示当前状态
- 使用 `AskUserQuestion` 询问：
  "Systems index 已经存在，包含 [N] 个系统（[M] 个已设计，[K] 个未开始）。
  你想做什么？"
  - 选项："使用新系统更新索引"、"设计下一个未设计的系统"、
    "审查和修订优先级"

---

## Phase 2: Systems Enumeration (Collaborative)

提取并识别游戏需要的所有系统。这是技能的创造性核心 — 它需要人工判断，因为概念文档很少明确列出每个系统。

### Step 2a: Extract Explicit Systems

扫描游戏概念以查找直接提及的系统和机制：
- Core Mechanics section（最明确的）
- Core Loop section（暗示每个循环层级需要什么系统驱动）
- Technical Considerations section（networking, procedural generation, 等）
- MVP Definition section（必需的功能 = 必需的系统）

### Step 2b: Identify Implicit Systems

对于每个显式系统，识别它暗示的 **隐藏系统**。游戏总是需要比概念文档提及的更多的系统。使用这种推断模式：

- "Inventory" 暗示：item database, equipment slots, weight/capacity rules,
  inventory UI, item serialization for save/load
- "Combat" 暗示：damage calculation, health system, hit detection, status effects,
  enemy AI, combat UI（health bars, damage numbers）, death/respawn
- "Open world" 暗示：streaming/chunking, LOD system, fast travel, map/minimap,
  point of interest tracking, world state persistence
- "Multiplayer" 暗示：networking layer, lobby/matchmaking, state synchronization,
  anti-cheat, network UI（ping, player list）
- "Crafting" 暗示：recipe database, ingredient gathering, crafting UI,
  success/failure mechanics, recipe discovery/learning
- "Dialogue" 暗示：dialogue tree system, dialogue UI, choice tracking, NPC
  state management, localization hooks
- "Progression" 暗示：XP system, level-up mechanics, skill tree, unlock
  tracking, progression UI, progression save data

在对话文本中解释为什么需要每个隐式系统（带示例）。

### Step 2c: User Review

按类别呈现枚举。对于每个系统，显示：
- 名称
- 类别
- 简要描述（1 句话）
- 它是显式的（来自概念）还是隐式的（推断的）

然后使用 `AskUserQuestion` 捕获反馈：
- "此列表中缺少系统吗？"
- "其中任何系统应该合并或拆分吗？"
- "此游戏不需要列出的系统吗？"

迭代直到用户批准枚举。

---

## Phase 3: Dependency Mapping (Collaborative)

对于每个系统，确定它依赖什么。如果一个系统没有另一个系统先存在就无法运行，则它 "依赖于" 另一个系统。

### Step 3a: Map Dependencies

对于每个系统，列出其依赖项。使用这些依赖启发式：
- **Input/output dependencies**：System A 产生 System B 需要的数据
- **Structural dependencies**：System A 提供 System B 插入的框架
- **UI dependencies**：每个 gameplay system 都有一个依赖于它的 corresponding UI system（但 UI 是在 gameplay system 之后设计的）

### Step 3b: Sort by Dependency Order

将系统排列成层：
1. **Foundation**：零依赖的系统（首先设计和构建）
2. **Core**：仅依赖于 Foundation 系统的系统
3. **Feature**：依赖于 Core 系统的系统
4. **Presentation**：包装 gameplay 系统的 UI 和 feedback 系统
5. **Polish**：Meta-systems, tutorials, analytics, accessibility

### Step 3c: Detect Circular Dependencies

检查依赖图中的循环。如果发现：
- 向用户突出显示它们
- 提出解决方案（interface abstraction, simultaneous design, breaking the
  cycle by defining a contract between the two systems）

### Step 3d: Present to User

将依赖图显示为分层列表。突出显示：
- 任何 circular dependencies
- 任何 "bottleneck" 系统（许多其他依赖于它们 — 这些是高风险的）
- 任何没有依赖项的系统（叶节点 — 风险较低，可以稍后设计）

使用 `AskUserQuestion` 询问："此依赖顺序看起来正确吗？我遗漏的任何依赖项或应该删除的吗？"

**审查模式检查** — 在生成 TD-SYSTEM-BOUNDARY 之前应用：
- `solo` → 跳过。注意："TD-SYSTEM-BOUNDARY skipped — Solo mode。" Proceed to priority assignment。
- `lean` → 跳过（不是 PHASE-GATE）。注意："TD-SYSTEM-BOUNDARY skipped — Lean mode。" Proceed to priority assignment。
- `full` → 正常生成。

**依赖映射批准后，在继续优先级分配之前，使用 gate TD-SYSTEM-BOUNDARY (`.claude/docs/director-gates.md`) 通过 Task 生成 `technical-director`。**

传递：依赖图摘要、层分配、bottleneck 系统列表、任何 circular dependency resolutions。

展示评估。如果 REJECT，在写入系统索引之前与用户修订系统边界。如果 CONCERNS，内联记录在系统索引中并继续。

---

## Phase 4: Priority Assignment (Collaborative)

根据每个系统需要的里程碑，将每个系统分配给优先级层。

### Step 4a: Auto-Assign Based on Concept

使用这些启发式方法进行初始分配：
- **MVP**：概念的 "Required for MVP" 部分中提及的系统，加上它们的
  Foundation-layer 依赖项
- **Vertical Slice**：一个区域完整体验所需的系统
- **Alpha**：所有剩余的 gameplay 系统
- **Full Vision**：Polish, meta, 和 nice-to-have 系统

### Step 4b: User Review

在表格中呈现优先级分配。对于每个层，解释为什么系统被放在那里。

使用 `AskUserQuestion` 询问："这些优先级分配符合你的愿景吗？哪些系统应该更高或更低优先级？"

在对话中解释推理："我将 [system] 放在 MVP 中，因为 core loop 需要它 — 没有 [system]，30 秒循环无法运行。"

**"Why" 列指导**：解释为什么每个系统被放在优先级层时，将技术必要性与玩家体验推理混合。不要使用纯粹的技术理由，如 "Combat needs damage math" — 在系统直接塑造玩家体验的地方连接到玩家体验。好的 "Why" 条目示例：
- "Required for the core loop — without it, placement decisions have no consequence (Pillar 2: Placement is the Puzzle)"
- "Ballista's punch-through identity is established here — this stat definition is what makes it feel different from Archer"
- "Foundation for all economy decisions — players must understand upgrade costs to make meaningful placement choices"

当系统直接塑造玩家体验时，纯粹的技术必要性（"X depends on Y"）单独是不够的。

**审查模式检查** — 在生成 PR-SCOPE 之前应用：
- `solo` → 跳过。注意："PR-SCOPE skipped — Solo mode。" Proceed to writing the systems index。
- `lean` → 跳过（不是 PHASE-GATE）。注意："PR-SCOPE skipped — Lean mode。" Proceed to writing the systems index。
- `full` → 正常生成。

**优先级批准后，在写入索引之前，使用 gate PR-SCOPE (`.claude/docs/director-gates.md`) 通过 Task 生成 `producer`。**

传递：每个里程碑层的总系统计数、每层估计的实现量（系统计数 × 平均复杂度）、团队规模、说明的项目时间线。

展示评估。如果 UNREALISTIC，在写入索引之前提供修订优先级层分配。如果 CONCERNS，记录它们并继续。

### Step 4c: Determine Design Order

结合依赖排序 + 优先级层以产生最终设计顺序：
1. 首先是 MVP Foundation 系统
2. 其次是 MVP Core 系统
3. 第三是 MVP Feature 系统
4. Vertical Slice Foundation/Core 系统
5. ...依此类推
n
这是团队应该编写 GDDs 的顺序。

---

## Phase 5: Create Systems Index (Write)

### Step 5a: Draft the Document

使用 `.claude/docs/templates/systems-index.md` 的模板，用 Phases 2-4 的所有数据填充 systems index：
- 填写枚举表
- 填写依赖图
- 填写推荐的设计顺序
- 填写高风险系统
- 填写进度跟踪器（最初所有系统都是 "Not Started"，除非 GDDs 已经存在）

### Step 5b: Approval

展示文档摘要：
- 按类别统计的总系统数
- MVP 系统计数
- 设计顺序中的前 3 个系统
- 任何高风险项目

询问："我可以将 systems index 写入 `design/gdd/systems-index.md` 吗？"

等待批准。只有在 "yes" 之后才写入文件。

**审查模式检查** — 在生成 CD-SYSTEMS 之前应用：
- `solo` → 跳过。注意："CD-SYSTEMS skipped — Solo mode。" Proceed to Phase 7 next steps。
- `lean` → 跳过（不是 PHASE-GATE）。注意："CD-SYSTEMS skipped — Lean mode。" Proceed to Phase 7 next steps。
- `full` → 正常生成。

**写入 systems index 后，使用 gate CD-SYSTEMS (`.claude/docs/director-gates.md`) 通过 Task 生成 `creative-director`。**

传递：systems index 路径、game pillars 和 core fantasy（来自 `design/gdd/game-concept.md`）、MVP 优先级层系统列表。

展示评估。如果 REJECT，在 GDD 编写开始之前与用户修订系统集。如果 CONCERNS，在相关层部分的顶部将其记录为 `> **Creative Director Note**`。

### Step 5c: Update Session State

写入后，如果它不存在则创建 `production/session-state/active.md`，然后用以下内容更新它：
- 任务：Systems decomposition
- 状态：Systems index created
- 文件：design/gdd/systems-index.md
- 下一步：Design individual system GDDs

**Verdict: COMPLETE** — systems index 写入 `design/gdd/systems-index.md`。
如果用户拒绝：**Verdict: BLOCKED** — 用户未批准写入。

---

## Phase 6: Design Individual Systems (Handoff to /design-system)

当以下情况时进入此阶段：
- 用户在创建索引后说 "yes" 设计系统
- 用户调用 `/map-systems [system-name]`
- 用户调用 `/map-systems next`

### Step 6a: Select the System

- 如果提供了系统名称，在 systems index 中找到它
- 如果使用 `next`，挑选最高优先级的未设计系统（按设计顺序）
- 如果用户刚刚完成索引，询问：
  "你现在想开始设计单个系统吗？设计顺序中的第一个系统是 [name]。或者你想在这里停止稍后再回来？"

使用 `AskUserQuestion`："现在开始设计 [system-name]，挑选不同的系统，还是在这里停止？"

### Step 6b: Hand Off to /design-system

一旦选择了系统，调用 `/design-system [system-name]` 技能。

`/design-system` 技能处理完整的 GDD 编写过程：
- 从游戏概念、systems index 和 dependency GDDs 收集上下文
- 立即创建文件骨架
- 一次遍历所有 8 个必需的部分（协作、增量）
- 交叉引用现有文档以防止矛盾
- 为 domain expertise 路由到 specialist agents
- 每个部分一批准就写入文件
- 完成时运行 `/design-review`
- 更新 systems index

**不要在这里重复 /design-system 工作流。** 此技能拥有 systems
*index*；`/design-system` 拥有单个 system *GDDs*。

### Step 6c: Loop or Stop

`/design-system` 完成后，使用 `AskUserQuestion`：
- "继续到下一个系统（[next system name]）？"
- "挑选不同的系统？"
- "在此 session 停止？"

如果继续，返回 Step 6a。

---

## Phase 7: Suggest Next Steps

创建 systems index 后（或设计一些系统后），使用 `AskUserQuestion` 呈现下一步操作：

- "Systems index 已写入。接下来你想做什么？"
  - [A] 开始设计 GDDs — 运行 `/design-system [first-system-in-order]`
  - [B] 先请 director 审查索引 — 在承诺 10+ GDD sessions 之前要求 `creative-director` 或 `technical-director` 验证系统集
  - [C] 在此 session 停止

**Director 审查选项（[B]）值得强调**：在开始在许多文档中锁定它们之前，让 Creative Director 或 Technical Director 审查完成的 systems index 可以捕获 scope issues, missing systems, 和 boundary problems。它是可选的但建议用于新项目。

任何单个 GDD 完成后：
- "在 fresh session 中运行 `/design-review design/gdd/[system].md` 来验证质量"
- "当所有 MVP GDDs 完成时运行 `/gate-check systems-design`"

---

## Collaborative Protocol

此技能在每个阶段都遵循协作设计原则：

1. **Question -> Options -> Decision -> Draft -> Approval** 在每个步骤
2. **AskUserQuestion** 在每个决策点（Explain -> Capture pattern）：
   - Phase 2: "Missing systems? Combine or split?"
   - Phase 3: "Dependency ordering correct?"
   - Phase 4: "Priority assignments match your vision?"
   - Phase 5: "May I write the systems index?"
   - Phase 6: "Start designing, pick different, or stop?" 然后移交给 `/design-system`
3. **"May I write to [filepath]?"** 在每个文件写入之前
4. **Incremental writing**：设计每个系统后更新 systems index
5. **Handoff**：Individual GDD 编写由 `/design-system` 拥有，它处理
   incremental section writing, cross-referencing, design review, 和 index updates
6. **Session state updates**：在每个里程碑（index created, system designed, priorities changed）后写入 `production/session-state/active.md`

**永远不要**自动生成完整的系统列表并在未经审查的情况下写入。
**永远不要**在没有用户确认的情况下开始设计系统。
**始终**显示枚举、依赖项和优先级以供用户验证。

## Context Window Awareness

如果上下文在任何时刻达到或超过 70%，追加此通知：

> **Context 正在接近限制 (≥70%)。** Systems index 已保存到
> `design/gdd/systems-index.md`。打开一个新的 Claude Code session 来继续
> 设计单个 GDDs — 运行 `/map-systems next` 从你离开的地方继续。

---

## Recommended Next Steps

- 运行 `/design-system [first-system-in-order]` 来编写第一个 GDD（使用索引中的设计顺序）
- 运行 `/map-systems next` 来自动始终挑选最高优先级的未设计系统
- 在每个 GDD 编写后的 fresh session 中运行 `/design-review design/gdd/[system].md`
- 当所有 MVP GDDs 编写和审查后运行 `/gate-check pre-production`
