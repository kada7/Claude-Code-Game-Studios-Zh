---
name: create-architecture
description: "引导式、逐节编写游戏的主架构文档。读取所有GDD、系统索引、现有ADR和引擎参考库，在编写任何代码之前生成完整的架构蓝图。支持引擎版本感知：标记知识差距并针对固定引擎版本验证决策。"
argument-hint: "[focus-area: full | layers | data-flow | api-boundaries | adr-audit] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash, AskUserQuestion, Task
agent: technical-director
---

# Create Architecture

本 Skill 产出 `docs/architecture/architecture.md` —— 将所有已批准 GDD 转化为具体技术蓝图的主架构文档。
它位于设计与实现之间，必须在 Sprint 规划开始前存在。

**与 `/architecture-decision` 的区别**：ADR 记录单个决策点。
本 Skill 创建的是为 ADR 提供上下文的全系统蓝图。

解析审查模式（一次性解析，本次运行所有 gate 生成均使用此值）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式请参阅 `.claude/docs/director-gates.md`。

**参数模式：**
- **无参数 / `full`**：完整引导式 walkthrough —— 所有章节，从头到尾
- **`layers`**：仅聚焦系统层级图
- **`data-flow`**：仅聚焦模块间数据流
- **`api-boundaries`**：仅聚焦 API 边界定义
- **`adr-audit`**：仅审计现有 ADR 的引擎兼容性差距

---

## Phase 0: 加载全部上下文

在此之前，按以下顺序加载完整项目上下文：

### 0a. 引擎上下文（关键）

完整读取引擎参考库：

1. `docs/engine-reference/[engine]/VERSION.md`
   → 提取：引擎名称、版本、LLM 知识截止点、截止后风险等级
2. `docs/engine-reference/[engine]/breaking-changes.md`
   → 提取：所有 HIGH 和 MEDIUM 风险变更
3. `docs/engine-reference/[engine]/deprecated-apis.md`
   → 提取：需避免的 API
4. `docs/engine-reference/[engine]/current-best-practices.md`
   → 提取：截止后不同于训练数据的最佳实践
5. `docs/engine-reference/[engine]/modules/` 下的所有文件
   → 提取：各领域的当前 API 模式

如果未配置引擎，停止并提示：
> "未配置引擎。请先运行 `/setup-engine`。在不知道目标引擎和版本的情况下，无法编写架构。"

### 0b. 设计上下文 + 技术需求提取

读取所有已批准的设计文档，并从每份文档中提取技术需求：

1. `design/gdd/game-concept.md` —— 游戏支柱、类型、核心循环
2. `design/gdd/systems-index.md` —— 所有系统、依赖关系、优先级层级
3. `.claude/docs/technical-preferences.md` —— 命名约定、性能预算、
   允许的库、禁止的模式
4. **`design/gdd/` 下的每份 GDD** —— 对每份文档，提取技术需求：
   - 游戏规则隐含的数据结构
   - 明确或隐含的性能约束
   - 系统所需的引擎能力
   - 跨系统通信模式（什么与什么通信、如何通信）
   - 必须持久化的状态（存档/读档影响）
   - 线程或时序需求

构建一份**技术需求基线** —— 从所有 GDD 中提取的全部需求的扁平列表，编号为 `TR-[gdd-slug]-[NNN]`。这是架构必须覆盖的完整需求集合。以如下格式呈现：

```
## Technical Requirements Baseline
Extracted from [N] GDDs | [X] total requirements

| Req ID | GDD | System | Requirement | Domain |
|--------|-----|--------|-------------|--------|
| TR-combat-001 | combat.md | Combat | Hitbox detection per-frame | Physics |
| TR-combat-002 | combat.md | Combat | Combo state machine | Core |
| TR-inventory-001 | inventory.md | Inventory | Item persistence | Save/Load |
```

此基线贯穿所有后续阶段。本次会话结束时，不应有任何 GDD 需求未被架构决策支持。

### 0c. 现有架构决策

读取 `docs/architecture/` 下的所有文件，了解已做出的决策。
列出找到的所有 ADR 及其所属领域。

### 0d. 生成知识差距清单

在继续之前，显示结构化摘要：

```
## Engine Knowledge Gap Inventory
Engine: [name + version]
LLM Training Covers: up to approximately [version]
Post-Cutoff Versions: [list]

### HIGH RISK Domains (must verify against engine reference before deciding)
- [Domain]: [Key changes]

### MEDIUM RISK Domains (verify key APIs)
- [Domain]: [Key changes]

### LOW RISK Domains (in training data, likely reliable)
- [Domain]: [no significant post-cutoff changes]

### Systems from GDD that touch HIGH/MEDIUM risk domains:
- [GDD system name] → [domain] → [risk level]
```

询问："此清单识别出 [N] 个系统涉及 HIGH RISK 引擎领域。是否继续构建架构，并在全文中标记这些警告？"

---

## Phase 1: 系统层级映射

将 `systems-index.md` 中的每个系统映射到架构层级。标准游戏架构层级为：

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │  ← UI, HUD, menus, VFX, audio
├─────────────────────────────────────────────┤
│  FEATURE LAYER                              │  ← gameplay systems, AI, quests
├─────────────────────────────────────────────┤
│  CORE LAYER                                 │  ← physics, input, combat, movement
├─────────────────────────────────────────────┤
│  FOUNDATION LAYER                           │  ← engine integration, save/load,
│                                             │    scene management, event bus
├─────────────────────────────────────────────┤
│  PLATFORM LAYER                             │  ← OS, hardware, engine API surface
└─────────────────────────────────────────────┘
```

对每个 GDD 系统，询问：
- 它属于哪个层级？
- 它的模块边界是什么？
- 它独占什么？（数据、状态、行为）

呈现建议的层级分配，并在进入下一节前请求批准。将批准的层级映射立即写入骨架文件。

**引擎感知检查**：对每个分配到 Core 和 Foundation 层级的系统，标记它是否触及 HIGH 或 MEDIUM 风险引擎领域。内联显示相关引擎参考摘录。

---

## Phase 2: 模块所有权映射

对 Phase 1 中定义的每个模块，定义所有权：

- **Owns（拥有）**：此模块独占负责的数据和状态
- **Exposes（暴露）**：其他模块可以读取或调用的内容
- **Consumes（消费）**：它从其他模块读取的内容
- **Engine APIs used（使用的引擎 API）**：此模块直接调用的具体引擎类/节点/信号（注明版本和风险等级）

按层级以表格形式呈现，然后以 ASCII 依赖图呈现。

**引擎感知检查**：对每个列出的引擎 API，对照相关模块参考文档进行验证。如果 API 为截止后版本，标记它：

```
⚠️  [ClassName.method()] — Godot 4.6 (post-cutoff, HIGH risk)
    Verified against: docs/engine-reference/godot/modules/[domain].md
    Behaviour confirmed: [yes / NEEDS VERIFICATION]
```

在写入前获取用户对所有权映射的批准。

---

## Phase 3: 数据流

定义数据在关键游戏场景中如何在模块间流动。至少覆盖：

1. **帧更新路径**：Input → Core systems → State → Rendering
2. **事件/信号路径**：系统如何在不紧耦合的情况下通信
3. **存档/读档路径**：哪些状态被序列化，哪个模块拥有序列化权
4. **初始化顺序**：哪些模块必须在其他模块之前启动

在有帮助的地方使用 ASCII 序列图。对每个数据流：
- 命名正在传输的数据
- 识别生产者和消费者
- 说明这是同步调用、信号/事件，还是共享状态
- 标记任何跨线程边界的数据流

每个场景在写入前获取用户批准。

---

## Phase 4: API 边界

定义模块间的公共契约。对每个边界：

- 模块向系统其余部分暴露的接口是什么？
- 入口点有哪些（函数/信号/属性）？
- 调用者必须遵守哪些不变量？
- 模块必须向调用者保证什么？

以伪代码或项目实际语言（来自技术偏好）编写。
这些成为程序员实现所依据的契约。

**引擎感知检查**：如果任何接口使用引擎特定类型（例如 Godot 中的 `Node`、`Resource`、`Signal`），标记版本并验证该类型在目标引擎版本中存在且签名未变更。

---

## Phase 5: ADR 审计 + 可追溯性检查

对照 Phase 1-4 中构建的架构以及 Phase 0b 中的 Technical Requirements Baseline，审查 Phase 0c 中的所有现有 ADR。

### ADR 质量检查

对每个 ADR：
- [ ] 是否有 Engine Compatibility 章节？
- [ ] 是否记录了引擎版本？
- [ ] 是否标记了截止后 API？
- [ ] 是否有 "GDD Requirements Addressed" 章节？
- [ ] 是否与本次会话中做出的层级/所有权决策冲突？
- [ ] 对固定引擎版本是否仍然有效？

| ADR | Engine Compat | Version | GDD Linkage | Conflicts | Valid |
|-----|--------------|---------|-------------|-----------|-------|
| ADR-0001: [title] | ✅/❌ | ✅/❌ | ✅/❌ | None/[conflict] | ✅/⚠️ |

### Traceability Coverage Check

将 Technical Requirements Baseline 中的每个需求映射到现有 ADR。
对每个需求，检查是否有 ADR 的 "GDD Requirements Addressed" 章节或决策文本覆盖了它：

| Req ID | Requirement | ADR Coverage | Status |
|--------|-------------|--------------|--------|
| TR-combat-001 | Hitbox detection per-frame | ADR-0003 | ✅ |
| TR-combat-002 | Combo state machine | — | ❌ GAP |

统计：X 已覆盖，Y 存在差距。对每个差距，它成为一个**必需的新 ADR**。

### Required New ADRs

列出本次架构会话（Phase 1-4）中做出的所有尚未有对应 ADR 的决策，加上所有未覆盖的 Technical Requirements。
按层级分组 —— Foundation 优先：

**Foundation Layer（在编写任何代码前必须创建）：**
- `/architecture-decision [title]` → covers: TR-[id], TR-[id]

**Core Layer：**
- `/architecture-decision [title]` → covers: TR-[id]

---

## Phase 6: 缺失 ADR 列表

基于完整架构，产出一份应存在但尚不存在的完整 ADR 列表。按优先级分组：

**编码开始前必须拥有（Foundation & Core 决策）：**
- [例如 "Scene management and scene loading strategy"]
- [例如 "Event bus vs direct signal architecture"]

**在构建相关系统前应该拥有：**
- [例如 "Inventory serialisation format"]

**可推迟到实现阶段：**
- [例如 "Specific shader technique for water"]

---

## Phase 7: 编写主架构文档

所有章节获批后，将完整文档写入
`docs/architecture/architecture.md`。

询问："我可以将主架构文档写入 `docs/architecture/architecture.md` 吗？"

文档结构：

```markdown
# [Game Name] — Master Architecture

## Document Status
- Version: [N]
- Last Updated: [date]
- Engine: [name + version]
- GDDs Covered: [list]
- ADRs Referenced: [list]

## Engine Knowledge Gap Summary
[Condensed from Phase 0d inventory — HIGH/MEDIUM risk domains and their implications]

## System Layer Map
[From Phase 1]

## Module Ownership
[From Phase 2]

## Data Flow
[From Phase 3]

## API Boundaries
[From Phase 4]

## ADR Audit
[From Phase 5]

## Required ADRs
[From Phase 6]

## Architecture Principles
[3-5 key principles that govern all technical decisions for this project,
derived from the game concept, GDDs, and technical preferences]

## Open Questions
[Decisions deferred — must be resolved before the relevant layer is built]
```

---

## Phase 7b: Technical Director 签核 + Lead Programmer 可行性审查

编写主架构文档后，在交接前执行明确的签核。

**Step 1 — Technical Director 自审**（本 Skill 以 technical-director 身份运行）：

将 gate **TD-ARCHITECTURE**（`.claude/docs/director-gates.md`）作为自审应用。对照该 gate 定义中的全部四项标准检查完成的文档。

**审查模式检查** —— 在生成 LP-FEASIBILITY 前应用：
- `solo` → 跳过。注明："LP-FEASIBILITY 已跳过 —— Solo 模式。"进入 Phase 8 交接。
- `lean` → 跳过（非 PHASE-GATE）。注明："LP-FEASIBILITY 已跳过 —— Lean 模式。"进入 Phase 8 交接。
- `full` → 正常生成。

**Step 2 — 通过 Task 生成 `lead-programmer`，使用 gate LP-FEASIBILITY（`.claude/docs/director-gates.md`）：**

传递：架构文档路径、技术需求基线摘要、ADR 列表。

**Step 3 — 向用户呈现两份评估：**

并排显示 Technical Director 评估和 Lead Programmer 裁决。

使用 `AskUserQuestion` —— "Technical Director 和 Lead Programmer 已审查架构。你希望如何继续？"
选项：`Accept — proceed to handoff` / `Revise flagged items first` / `Discuss specific concerns`

**Step 4 — 在架构文档中记录签核：**

更新 Document Status 章节：
```
- Technical Director Sign-Off: [date] — APPROVED / APPROVED WITH CONDITIONS
- Lead Programmer Feasibility: FEASIBLE / CONCERNS ACCEPTED / REVISED
```

询问："我可以更新 `docs/architecture/architecture.md` 中的 Document Status 章节以记录签核吗？"

---

## Phase 8: 交接

编写文档后，提供清晰的交接：

1. **接下来运行这些 ADR**（来自 Phase 6，按优先级）：列出前 3 个
2. **Gate check**："主架构文档已完成。当所有必需 ADR 也编写完毕后，运行 `/gate-check pre-production`。"
3. **更新会话状态**：将摘要写入 `production/session-state/active.md`

---

## Collaborative Protocol

本 Skill 在每个阶段都遵循协同设计原则：

1. **静默加载上下文** —— 不要叙述文件读取
2. **呈现发现** —— 展示知识差距清单和层级提案
3. **决策前询问** —— 对每个架构选择呈现选项
4. **写入前获取批准** —— 每个阶段章节仅在用户批准内容后才写入
5. **增量写入** —— 每个批准的章节立即写入；不要累积所有内容到最后才写。这能应对会话崩溃。

未经用户输入，不得做出有约束力的架构决策。如果用户不确定，在询问决定前呈现 2-4 个选项及其优缺点。

---

## Recommended Next Steps

- 对 Phase 6 中列出的每个必需 ADR 运行 `/architecture-decision [title]` —— Foundation 层 ADR 优先
- 必需 ADR 编写完毕后，运行 `/create-control-manifest` 以产出层级规则清单
- 所有必需 ADR 编写完毕且架构已签核后，运行 `/gate-check pre-production`
