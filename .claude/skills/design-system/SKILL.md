---
name: design-system
description: "引导式、逐节编写单个游戏系统的GDD。从现有文档收集上下文，协作完成每个必需章节，交叉引用依赖关系，并增量写入文件。"
argument-hint: "<system-name> [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, TodoWrite
---

当此 Skill 被调用时：

## 1. 解析参数并验证

解析审查模式（一次性解析，存储以供本次运行中所有 gate 调用使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整的检查模式请参阅 `.claude/docs/director-gates.md`。

系统名称或 retrofit 路径是**必需的**。如果缺失：

1. 检查 `design/gdd/systems-index.md` 是否存在。
2. 如果存在：读取它，找到状态为 "Not Started" 或同等状态的最高优先级系统，并使用 `AskUserQuestion`：
   - 提示："设计顺序中的下一个系统是 **[system-name]** ([priority] | [layer])。开始设计它吗？"
   - 选项：`[A] 是 — 设计 [system-name]` / `[B] 选择另一个系统` / `[C] 在此停止`
   - 如果选 [A]：继续使用该系统名称。如果选 [B]：询问要设计哪个系统（纯文本）。如果选 [C]：退出。
3. 如果不存在系统索引，则失败并提示：
   > "用法：`/design-system <system-name>` — 例如，`/design-system movement`
   > 或者要填补现有 GDD 的空白：`/design-system retrofit design/gdd/[system-name].md`
   > 未找到系统索引。请先运行 `/map-systems` 来映射您的系统并获取设计顺序。"

**检测 retrofit 模式：**
如果参数以 `retrofit` 开头，或者参数是 `design/gdd/` 下现有 `.md` 文件的路径，则进入 **retrofit 模式**：

1. 读取现有 GDD 文件。
2. 识别 8 个必需章节中哪些已存在（扫描章节标题）。
   必需章节：Overview, Player Fantasy, Detailed Design/Rules, Formulas,
   Edge Cases, Dependencies, Tuning Knobs, Acceptance Criteria。
3. 识别哪些章节仅包含占位文本（`[To be designed]` 或
   同等内容 — 空白、单行或明显不完整）。
4. 在执行任何操作之前向用户展示：
   ```
   ## Retrofit: [System Name]
   File: design/gdd/[filename].md

   已完成的章节（不会被修改）：
   ✓ [section name]
   ✓ [section name]

   缺失或不完整的章节（将被编写）：
   ✗ [section name] — 缺失
   ✗ [section name] — 仅占位符
   ```
5. 询问："是否要我填充这 [N] 个缺失的章节？我不会修改任何现有内容。"
6. 如果同意：正常进入 **Phase 2（收集上下文）**，但在 **Phase 3**
   中跳过创建骨架（文件已存在），在 **Phase 4** 中跳过
   已完成的章节。仅对缺失/不完整的章节运行章节循环。
7. **永远不要覆盖现有章节内容。** 使用 Edit 工具仅替换
   `[To be designed]` 占位符或空章节主体。

如果**不在** retrofit 模式，将系统名称规范化为 kebab-case 作为
文件名（例如，"combat system" 变为 `combat-system`）。

---

## 2. 收集上下文（读取阶段）

在询问用户任何问题之前，先读取所有相关上下文。这是本 Skill 相对于
即兴设计的主要优势 —— 它能够做到有备而来。

### 2a: 必需读取

- **游戏概念**：读取 `design/gdd/game-concept.md` — 如果缺失则失败：
  > "未找到游戏概念。请先运行 `/brainstorm`。"
- **系统索引**：读取 `design/gdd/systems-index.md` — 如果缺失则失败：
  > "未找到系统索引。请先运行 `/map-systems` 来映射您的系统。"
- **目标系统**：在索引中找到该系统。如果未列出，则警告：
  > "[system-name] 不在系统索引中。您想添加它，还是将其作为索引外系统来设计？"
- **实体注册表**：如果存在，读取 `design/registry/entities.yaml`。
  提取所有被该系统引用或与之相关的条目（grep
  `referenced_by.*[system-name]` 和 `source.*[system-name]`）。将这些作为**已知事实**保留在上下文中 —— 这些是其他 GDD 已经确立的值，本 GDD 不得与之矛盾。
- **反思日志**：如果存在，读取 `docs/consistency-failures.md`。
  提取 Domain 匹配该系统类别的条目。这些是反复出现的冲突模式 —— 在 Phase 2d 的上下文摘要中以 "Past failure patterns" 呈现给用户，让他们知道该领域以前在哪里出过问题。

### 2b: 依赖读取

从系统索引中识别：
- **上游依赖**：该系统所依赖的系统。如果它们的 GDD 存在，则读取它们
  （这些包含该系统必须遵守的决策）。
- **下游依赖者**：依赖于该系统的系统。如果它们的 GDD 存在，则读取它们
  （这些包含该系统必须满足的期望）。

对于每个存在的依赖 GDD，提取并保留在上下文中：
- 关键接口（系统之间流动的数据）
- 引用该系统输出的公式
- 假设该系统行为的边界情况
- 输入该系统的调节参数

### 2c: 可选读取

- **游戏支柱**：如果存在，读取 `design/gdd/game-pillars.md`
- **现有 GDD**：如果存在，读取 `design/gdd/[system-name].md`（继续，不要
  从头开始）
- **相关 GDD**：Glob `design/gdd/*.md` 并读取任何主题相关的
  （例如，如果设计的系统在范围上与另一个重叠，即使它不是正式的依赖关系，也要读取相关 GDD）

### 2d: 呈现上下文摘要

在开始设计工作之前，向用户呈现一份简要摘要：

> **正在设计：[System Name]**
> - 优先级：[来自索引] | 层级：[来自索引]
> - 依赖于：[列表，注明哪些有 GDD，哪些尚未设计]
> - 被依赖者：[列表，注明哪些有 GDD，哪些尚未设计]
> - 需要遵守的现有决策：[来自依赖 GDD 的关键约束]
> - 支柱对齐：[该系统主要服务的支柱]
> - **已知跨系统事实（来自注册表）：**
>   - [entity_name]: [attribute]=[value], [attribute]=[value]（由 [source GDD] 拥有）
>   - [item_name]: [attribute]=[value], [attribute]=[value]（由 [source GDD] 拥有）
>   - [formula_name]: variables=[list], output=[min–max]（由 [source GDD] 拥有）
>   - [constant_name]: [value] [unit]（由 [source GDD] 拥有）
>   *（这些值已锁定 —— 如果此 GDD 需要不同的值，请在写入前提出冲突。不要默默使用不同的数字。）*
>
> 如果没有相关的注册表条目：省略 "Known cross-system facts" 部分。

如果有任何上游依赖尚未设计，则警告：
> "[dependency] 还没有 GDD。我们需要对其接口做出假设。建议先设计它，或者我们可以定义预期的契约并将其标记为临时的。"

### 2e: 技术可行性预检

在要求用户开始设计之前，加载引擎上下文并提出任何将塑造设计的约束或知识差距。

**步骤 1 — 确定该系统的引擎域：**
将系统类别（来自 systems-index.md）映射到引擎域：

| System Category | Engine Domain |
|----------------|--------------|
| Combat, physics, collision | Physics |
| Rendering, visual effects, shaders | Rendering |
| UI, HUD, menus | UI |
| Audio, sound, music | Audio |
| AI, pathfinding, behavior trees | Navigation / Scripting |
| Animation, IK, rigs | Animation |
| Networking, multiplayer, sync | Networking |
| Input, controls, keybinding | Input |
| Save/load, persistence, data | Core |
| Dialogue, quests, narrative | Scripting |

**步骤 2 — 读取引擎上下文（如果可用）：**
- 读取 `.claude/docs/technical-preferences.md` 以识别引擎和版本
- 如果引擎已配置，读取 `docs/engine-reference/[engine]/VERSION.md`
- 如果存在，读取 `docs/engine-reference/[engine]/modules/[domain].md`
- 读取 `docs/engine-reference/[engine]/breaking-changes.md` 中与域相关的条目
- Glob `docs/architecture/adr-*.md` 并读取任何域匹配的 ADR
  （检查 Engine Compatibility 表的 "Domain" 字段）

**步骤 3 — 呈现可行性简报：**

如果引擎参考文档存在，则在开始设计前呈现：

```
## Technical Feasibility Brief: [System Name]
Engine: [name + version]
Domain: [domain]

### Known Engine Capabilities (verified for [version])
- [capability relevant to this system]
- [capability 2]

### Engine Constraints That Will Shape This Design
- [constraint from engine-reference or existing ADR]

### Knowledge Gaps (verify before committing to these)
- [post-cutoff feature this design might rely on — mark HIGH/MEDIUM risk]

### Existing ADRs That Constrain This System
- ADR-XXXX: [decision summary] — means [implication for this GDD]
  (or "None yet")
```

如果引擎参考文档不存在（引擎尚未配置），则显示简短说明：
> "尚未配置引擎 —— 跳过技术可行性检查。如果尚未配置，请在进入架构阶段之前运行 `/setup-engine`。"

**步骤 4 — 在继续之前询问：**

使用 `AskUserQuestion`：
- "在开始之前有什么要补充的约束吗，还是按照这些已记录的约束继续？"
  - 选项："按照这些已记录的继续", "先添加一个约束", "我需要检查引擎文档 —— 在此暂停"

---

使用 `AskUserQuestion`：
- "准备好开始设计 [system-name] 了吗？"
  - 选项："是的，开始吧", "先给我展示更多上下文", "先设计一个依赖项"

---

## 3. 创建文件骨架

用户确认后，**立即**创建带有空章节标题的 GDD 文件。这确保增量写入有目标。

使用 `.claude/docs/templates/game-design-document.md` 的模板结构：

```markdown
# [System Name]

> **Status**: In Design
> **Author**: [user + agents]
> **Last Updated**: [today's date]
> **Implements Pillar**: [from context]

## Overview

[To be designed]

## Player Fantasy

[To be designed]

## Detailed Design

### Core Rules

[To be designed]

### States and Transitions

[To be designed]

### Interactions with Other Systems

[To be designed]

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## UI Requirements

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
```

询问："我可以在 `design/gdd/[system-name].md` 创建骨架文件吗？"

写入后，更新 `production/session-state/active.md`：
- 使用 Glob 检查文件是否存在。
- 如果**不存在**：使用 **Write** 工具创建它。永远不要对可能不存在的文件尝试 Edit。
- 如果**已存在**：使用 **Edit** 工具更新相关字段。

文件内容：
- 任务：Designing [system-name] GDD
- 当前章节：Starting (skeleton created)
- 文件：design/gdd/[system-name].md

---

## 4. 逐节设计

按顺序遍历每个章节。对于**每个章节**，遵循以下循环：

### 章节循环

```
Context  ->  Questions  ->  Options  ->  Decision  ->  Draft  ->  Approval  ->  Write
```

1. **上下文**：说明该章节需要包含什么内容，并提出来自依赖 GDD 的任何相关决策约束。

2. **问题**：提出针对该章节的澄清问题。使用
   `AskUserQuestion` 提出受约束的问题，使用对话文本进行开放式探索。

3. **选项**：如果该章节涉及设计选择（不仅仅是文档记录），
   提出 2-4 种方案及其优缺点。在对话文本中解释推理，
   然后使用 `AskUserQuestion` 捕获决策。

4. **决策**：用户选择一种方案或提供自定义方向。

5. **草稿**：在对话文本中写入章节内容以供审阅。标记任何关于未设计依赖项的临时假设。

6. **批准**：草稿之后立即 —— 在**同一回复**中 —— 使用
   `AskUserQuestion`。**永远不要使用纯文本。永远不要跳过此步骤。**
   - 提示："批准 [Section Name] 章节吗？"
   - 选项：`[A] 批准 — 写入文件` / `[B] 修改 — 描述要修复的内容` / `[C] 重新开始`

   **草稿和批准控件必须一起出现在一个回复中。
   如果草稿出现但没有控件，用户将面对空白提示
   无路可走 —— 这是协议违规。**

7. **写入**：使用 Edit 工具将占位符替换为批准的内容。
   **关键**：始终在 `old_string` 中包含章节标题以确保唯一性 —— 永远不要单独匹配 `[To be designed]`，因为多个章节使用相同的占位符，而 Edit 工具需要唯一匹配。使用此模式：
   ```
   old_string: "## [Section Name]\n\n[To be designed]"
   new_string: "## [Section Name]\n\n[approved content]"
   ```
   确认写入。

8. **注册表冲突检查**（仅适用于 C 和 D 章节 —— Detailed Design 和 Formulas）：
   写入后，扫描章节内容中出现在注册表中的实体名称、物品名称、公式
   名称和数值常量。对于每个匹配项：
   - 将刚刚写入的值与注册表条目进行比较。
   - 如果不同：**立即提出冲突**，然后再开始下一个章节。不要默默继续。
     > "注册表冲突：[name] 在 [source GDD] 中注册为 [registry_value]。
     > 本章节刚刚写入了 [new_value]。哪个是正确的？"
   - 如果是新的（不在注册表中）：将其标记为注册表注册的候选
     （将在 Phase 5 中处理）。

每写完一个章节后，使用已完成的章节名称更新 `production/session-state/active.md`。使用 Glob 检查文件是否存在 —— 如果不存在则使用 Write 创建，如果存在则使用 Edit 更新。

### 章节特定指导

每个章节都有独特的设计考虑，可能会受益于专家 Agent：

---

### Section A: Overview

**目标**：一个陌生人读了就能理解的段落。

**在构建控件之前推导推荐选项**：从系统索引中读取系统类别和层级（已在 Phase 2 的上下文中），然后确定每个标签的推荐选项：
- **Framing 标签**：Foundation/Infrastructure 层级 → `[A]` 推荐。面向玩家的类别（Combat, UI, Dialogue, Character, Animation, Visual Effects, Audio）→ `[C] Both` 推荐。
- **ADR ref 标签**：Glob `docs/architecture/adr-*.md` 并在任何 ADR 的 GDD Requirements 部分中 grep 系统名称。如果找到匹配的 ADR → `[A] Yes — cite the ADR` 推荐。如果未找到 → `[B] No` 推荐。
- **Fantasy 标签**：Foundation/Infrastructure 层级 → `[B] No` 推荐。所有其他类别 → `[A] Yes` 推荐。

在每个标签的适当选项文本后附加 `(Recommended)`。

**框架问题（在起草前询问）**：使用 `AskUserQuestion` 和多标签控件：
- 标签 "Framing" — "概述应该如何框架这个系统？" 选项：`[A] 作为数据/基础设施层（技术框架）` / `[B] 通过其面向玩家的效果（设计框架）` / `[C] 两者 —— 描述数据层及其对玩家的影响`
- 标签 "ADR ref" — "概述是否应该引用该系统现有的 ADR？" 选项：`[A] 是 —— 引用 ADR 以获取实现细节` / `[B] 否 —— 保持 GDD 处于纯粹的设计层面`
- 标签 "Fantasy" — "这个系统是否有值得陈述的玩家幻想？" 选项：`[A] 是 —— 玩家直接感受到它` / `[B] 否 —— 纯基础设施，玩家感受到它所能实现的东西`

使用用户的答案来塑造草稿。不要自己回答这些问题并自动起草。

**要问的问题**：
- 这个系统一句话是什么？
- 玩家如何与之交互？（主动/被动/自动）
- 这个系统为什么存在 —— 没有它游戏会失去什么？

**交叉引用**：检查描述是否与系统索引中的描述一致。标记差异。

**设计与实现边界**：概述问题必须停留在行为层面 —— 系统*做什么*，而不是*如何构建*。如果在概述期间出现实现问题（例如，"这应该使用 Autoload 单例还是信号总线？"），将其标记为 "→ 成为 ADR" 并继续。实现模式属于 `/architecture-decision`，不属于 GDD。GDD 描述行为；ADR 描述用于实现它的技术方法。

---

### Section B: Player Fantasy

**目标**：情感目标 —— 玩家应该*感受到*什么。

**在构建控件之前推导推荐选项**：从 Phase 2 上下文中读取系统类别和层级：
- 面向玩家的类别（Combat, UI, Dialogue, Character, Animation, Audio, Level/World）→ `[A] Direct` 推荐
- Foundation/Infrastructure 层级 → `[B] Indirect` 推荐
- 混合类别（Camera/input, Economy, AI with visible player effects）→ `[C] Both` 推荐

在适当的选项文本后附加 `(Recommended)`。

**框架问题（在起草前询问）**：使用 `AskUserQuestion`：
- 提示："这个系统是玩家直接参与的，还是他们间接体验的基础设施？"
- 选项：`[A] Direct —— 玩家主动使用或感受这个系统` / `[B] Indirect —— 玩家感受效果，而非系统本身` / `[C] Both —— 有直接交互层和其下的基础设施`

使用答案来适当地框架 Player Fantasy 章节。不要假设答案。

**要问的问题**：
- 这服务于什么情感或力量幻想？
- 哪些参考游戏精准把握了这种感觉？具体是什么创造了它？
- 这是一个"你喜欢与之交互的系统"还是"你不会注意到的基础设施"？

**交叉引用**：必须与游戏支柱对齐。如果该系统服务于某个支柱，引用相关支柱文本。

**Agent 委派（强制）**：在给出框架答案后但在起草前，通过 Task 生成 `creative-director`：
- 提供：系统名称、框架答案（direct/indirect/both）、游戏支柱、用户提到的任何参考游戏、游戏概念摘要
- 询问："塑造该系统的 Player Fantasy。它应该服务于什么情感或力量幻想？我们应该锚定到哪个玩家时刻？什么语调和语言适合游戏已确立的感觉？要具体 —— 给我 2-3 个候选框架。"
- 收集 creative-director 的框架并连同草稿一起呈现给用户。

**在咨询 `creative-director` 之前不要起草 Section B。** 框架答案告诉我们它是*哪种*幻想；creative-director 塑造*如何描述*它 —— 语调、语言、要锚定的具体玩家时刻。

---

### Section C: Detailed Design (Core Rules, States, Interactions)

**目标**：程序员可以在没有问题的情况下实现的无歧义规范。

这通常是最长的章节。将其分解为子章节：

1. **Core Rules**：基本机制。对顺序过程使用编号规则，对属性使用项目符号。
2. **States and Transitions**：如果系统有状态，映射每个状态和每个有效转换。使用表格。
3. **Interactions with Other Systems**：对于每个依赖（上游和下游），指定什么数据流入、什么数据流出，以及谁拥有接口。

**要问的问题**：
- 带我逐步了解该系统的典型使用
- 玩家面临的决策点是什么？
- 玩家不能做什么？（约束与能力同等重要）

**Agent 委派（强制）**：在起草 Section C 之前，通过 Task 并行生成专家 Agent：
- 在路由表中查找系统类别（本 Skill 的第 6 节）
- 生成 Primary Agent 和 Supporting Agent(s)
- 向每个 Agent 提供：系统名称、游戏概念摘要、支柱集、依赖 GDD 摘录、正在处理的特定章节
- 在起草前收集他们的发现
- 通过 `AskUserQuestion` 向用户展示 Agent 之间的任何分歧
- 仅在收到专家输入后才起草

**在咨询适当的专家之前不要起草 Section C。** `systems-designer` 审查规则和机制会发现主会话无法发现的设计缺口。

**交叉引用**：对于列出的每个交互，验证它是否与依赖 GDD 指定的内容匹配。如果依赖定义了一个值或公式，而该系统期望不同的内容，则标记冲突。

---

### Section D: Formulas

**目标**：每个数学公式，变量已定义，范围已指定，边界情况已注明。

**完成引导 —— 始终以这个精确结构开始每个公式：**

```
The [formula_name] formula is defined as:

`[formula_name] = [expression]`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| [name] | [sym] | float/int | [min–max] | [what it represents] |

**Output Range:** [min] to [max] under normal play; [behaviour at extremes]
**Example:** [worked example with real numbers]
```

不要写 `[Formula TBD]` 或在没有变量表的情况下用散文描述公式。没有定义变量的公式无法在没有猜测的情况下实现。

**要问的问题**：
- 该系统执行哪些核心计算？
- 缩放应该是线性的、对数的还是阶梯式的？
- 早期/中期/晚期游戏的输出范围应该是什么？

**Agent 委派（强制）**：在提出任何公式或平衡值之前，通过 Task 并行生成专家 Agent：
- **始终生成 `systems-designer`**：提供 Section C 的 Core Rules、用户的调节目标、依赖 GDD 的平衡上下文。要求他们提出带有变量表和输出范围的公式。
- **对于经济/成本系统，还要生成 `economy-designer`**：提供放置成本、升级成本意图和进度目标。要求他们验证成本曲线和比率。
- 通过 `AskUserQuestion` 向用户展示专家的提案以供审阅
- 由用户决定；主会话写入文件
- **在没有专家输入的情况下不要发明公式值或平衡数字。** 没有平衡设计专业知识的用户无法评估原始数字 —— 他们需要专家的推理。

**交叉引用**：如果依赖 GDD 定义了一个输出流入该系统的公式，请明确引用它。不要重新发明 —— 连接。

---

### Section E: Edge Cases

**目标**：明确处理异常情况，使它们不会成为 Bug。

**完成引导 —— 将每个边界情况格式化为：**
- **If [condition]**: [exact outcome]. [rationale if non-obvious]

示例（根据游戏领域调整术语）：
- **If [resource] reaches 0 while [protective condition] is active**: hold at minimum until condition ends, then apply consequence.
- **If two [triggers/events] fire simultaneously**: resolve in [defined priority order]; ties use [defined tiebreak rule].

不要写模糊的条目，如 "handle appropriately" —— 每个条目必须命名确切的条件和确切的解决方案。没有解决方案的边界情况是一个开放的设计问题，而不是规范。

**要问的问题**：
- 在零时会发生什么？在最大值时？在超出范围的值时？
- 当两条规则同时适用时会发生什么？
- 如果玩家发现非预期的交互会发生什么？（识别退化策略）

**Agent 委派（强制）**：在最终确定边界情况之前，通过 Task 生成 `systems-designer`。提供：已完成的 C 和 D 章节，并要求他们从公式和规则空间中识别主会话可能遗漏的边界情况。对于叙事系统，还要生成 `narrative-director`。展示他们的发现并询问用户要包含哪些。

**交叉引用**：对照依赖 GDD 检查边界情况。如果依赖定义了该系统可能违反的下限、上限或解决规则，则标记它。

---

### Section F: Dependencies

**目标**：映射每个系统连接的方向和性质。

该章节部分从上下文收集阶段预填充。呈现来自系统索引的已知依赖并询问：
- 我遗漏了什么依赖吗？
- 对于每个依赖，具体的数据接口是什么？
- 哪些依赖是硬性的（系统没有它就无法运行）vs. 软性的（有它会增强，但没有它也能工作）？

**交叉引用**：该章节必须是双向一致的。如果该系统列出 "depends on Combat"，那么 Combat GDD 应该列出 "depended on by [this system]"。标记任何单向依赖以供纠正。

---

### Section G: Tuning Knobs

**目标**：每个设计师可调整的值，带有安全范围和极端行为。

**要问的问题**：
- 设计师应该能够在不修改代码的情况下调整哪些值？
- 对于每个参数，设置得太高会崩溃什么？太低呢？
- 哪些参数相互交互？（改变 A 会使 B 无关紧要）

**Agent 委派**：如果公式复杂，委派给 `systems-designer`
以从公式变量中推导调节参数。

**交叉引用**：如果依赖 GDD 列出了影响该系统的调节参数，在这里引用它们。不要创建重复参数 —— 指向真相来源。

---

### Section H: Acceptance Criteria

**目标**：可测试的条件，证明系统按设计工作。

**完成引导 —— 将每个标准格式化为 Given-When-Then：**
- **GIVEN** [initial state], **WHEN** [action or trigger], **THEN** [measurable outcome]

示例（根据游戏领域调整术语）：
- **GIVEN** [initial state], **WHEN** [player action or system trigger], **THEN** [specific measurable outcome].
- **GIVEN** [a constraint is active], **WHEN** [player attempts an action], **THEN** [feedback shown and action result].

至少包含：Section C 中每条核心规则一个标准，Section D 中每个公式一个标准。不要写 "the system works as designed" —— 每个标准必须能够被 QA 测试员在不阅读 GDD 的情况下独立验证。

**Agent 委派（强制）**：在最终确定验收标准之前，通过 Task 生成 `qa-lead`。提供：已完成的 GDD 章节 C、D、E，并要求他们验证标准是否可独立测试并涵盖所有核心规则和公式。向用户展示任何缺口或不可测试的标准。

**要问的问题**：
- 证明其有效的最小测试集是什么？
- 该系统获得什么性能预算？（帧时间、内存）
- QA 测试员首先会检查什么？

**交叉引用**：包含验证跨系统交互有效的标准，而不仅仅是该系统本身。

---

### 可选章节：Visual/Audio, UI Requirements, Open Questions

这些章节包含在模板中。对于视觉系统类别，Visual/Audio 是**必需**的 —— 不是可选的。在询问之前确定需求级别：

**Visual/Audio 是必需（强制 —— 不要提供跳过选项）的系统类别：**
- Combat, damage, health
- UI systems (HUD, menus)
- Animation, character movement
- Visual effects, particles, shaders
- Character systems
- Dialogue, quests, lore
- Level/world systems

对于必需系统：**在起草此章节之前，通过 Task 生成 `art-director`**。提供：系统名称、游戏概念、游戏支柱、art bible 第 1–4 节（如果存在）。要求他们指定：(1) 该系统事件的 VFX 和视觉反馈需求，(2) 任何动画或视觉风格约束，(3) 哪些 art bible 原则最直接适用于该系统。展示他们的输出；对于视觉系统，不要将此章节留为 `[To be designed]`。

对于**所有其他系统类别**（Foundation/Infrastructure, Economy, AI/pathfinding, Camera/input），在必需章节之后提供可选章节：

使用 `AskUserQuestion`：
- "8 个必需章节已完成。您是否还想定义 Visual/Audio
  需求、UI 需求，或记录开放问题？"
  - 选项："是的，全部三个", "只要开放问题", "跳过 —— 我稍后会添加这些"

对于**Visual/Audio**（非必需系统）：如果需要细节，与 `art-director` 和 `audio-director` 协调。通常在 GDD 阶段一个简短的说明就足够了。

> **Asset Spec Flag**：在 Visual/Audio 章节写入真实内容后，输出此通知：
> "📌 **Asset Spec** —— Visual/Audio 需求已定义。在 art bible 获得批准后，运行 `/asset-spec system:[system-name]` 以从本章节生成每项资产的视觉描述、尺寸和生成提示。"

对于**UI Requirements**：对于复杂的 UI 系统，与 `ux-designer` 协调。
写入此章节后，检查它是否包含真实内容（不仅仅是
`[To be designed]` 或说明该系统没有 UI 的注释）。如果它确实有真实的
UI 需求，则立即输出此标志：

> **📌 UX Flag —— [System Name]**：该系统有 UI 需求。在 Phase 4
> (Pre-Production) 中，在编写 epics 之前，运行 `/ux-design` 为该系统贡献的每个屏幕或
> HUD 元素创建 UX 规范。引用 UI 的 Stories 应该引用 `design/ux/[screen].md`，而不是直接引用 GDD。
>
> 如果更新系统索引，请在其中记录这一点。

对于**Open Questions**：记录设计过程中出现但未完全解决的任何问题。每个问题都应该有一个负责人和目标解决日期。

---

## 5. 设计后验证

所有章节写入后：

### 5a: 自检

从文件中读回完整的 GDD（不要从对话记忆中读取 —— 文件是
真相来源）。验证：
- 所有 8 个必需章节都有真实内容（不是占位符）
- 公式引用已定义的变量
- 边界情况有解决方案
- 依赖项已列出并带有接口
- 验收标准是可测试的

### 5a-bis: Creative Director 支柱审查

**审查模式检查** —— 在生成 CD-GDD-ALIGN 之前应用：
- `solo` → 跳过。注意："CD-GDD-ALIGN 已跳过 —— Solo 模式。" 进入步骤 5b。
- `lean` → 跳过（不是 PHASE-GATE）。注意："CD-GDD-ALIGN 已跳过 —— Lean 模式。" 进入步骤 5b。
- `full` → 正常生成。

在最终确定 GDD 之前，通过 Task 使用 gate **CD-GDD-ALIGN** (`.claude/docs/director-gates.md`) 生成 `creative-director`。

传递：已完成的 GDD 文件路径、游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`）、MDA 美学目标。

按照 `director-gates.md` 中的标准规则处理裁决。解决后，在 GDD Status 标题中记录裁决：
`> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]`

---

### 5b: 更新实体注册表

扫描已完成的 GDD，查找应注册的跨系统事实：
- 具有属性或掉落物的命名实体（敌人、NPC、Boss）
- 具有值、权重或类别的命名物品
- 具有已定义变量和输出范围的命名公式
- 在多个地方按值引用的命名常量

对于每个候选，检查它是否已存在于 `design/registry/entities.yaml` 中：
```
Grep pattern="  - name: [candidate_name]" path="design/registry/entities.yaml"
```

呈现摘要：
```
Registry candidates from this GDD:
  NEW (not yet registered):
    - [entity_name] [entity]: [attribute]=[value], [attribute]=[value]
    - [item_name] [item]: [attribute]=[value], [attribute]=[value]
    - [formula_name] [formula]: variables=[list], output=[min–max]
  ALREADY REGISTERED (referenced_by will be updated):
    - [constant_name] [constant]: value=[N] ← matches registry ✅
```

询问："我可以用这 [N] 个新条目更新 `design/registry/entities.yaml`
并更新现有条目的 `referenced_by` 吗？"

如果同意：追加新条目并更新 `referenced_by` 数组。在没有首先将其作为冲突提出之前，永远不要修改现有的 `value` / attribute 字段。

### 5c: 提供设计审查

呈现完成摘要：

> **GDD 完成：[System Name]**
> - 已写入章节：[列表]
> - 临时假设：[关于未设计依赖项的任何假设列表]
> - 发现的跨系统冲突：[列表或 "none"]

> **要验证此 GDD，请打开一个新的 Claude Code 会话并运行：**
> `/design-review design/gdd/[system-name].md`
>
> **永远不要在 `/design-system` 的同一个会话中运行 `/design-review`。** 审查
> Agent 必须独立于编写上下文。在这里运行它会继承完整的设计历史，使独立批评变得不可能。

**永远不要内联提供运行 `/design-review`。** 始终引导用户到新窗口。

### 5d: 更新系统索引

GDD 完成后（并可选审查后）：

- 读取系统索引
- 更新目标系统的行：
  - 如果运行了 design-review 且裁决为 APPROVED：Status → "Approved"
  - 如果运行了 design-review 且裁决为 NEEDS REVISION：Status → "In Review"
  - 如果跳过了 design-review：Status → "Designed"（待审查）
  - 如果用户选择 "I'll review it myself first"：Status → "Designed"
  - Design Doc: 链接到 `design/gdd/[system-name].md`
- 更新 Progress Tracker 计数

询问："我可以更新 `design/gdd/systems-index.md` 吗？"

### 5d: 更新会话状态

使用以下内容更新 `production/session-state/active.md`：
- 任务：[system-name] GDD
- 状态：Complete（如果运行了 design-review，则为 In Review）
- 文件：design/gdd/[system-name].md
- 章节：全部 8 个已写入
- 下一步：[从设计顺序中建议下一个系统]

### 5e: 建议后续步骤

使用 `AskUserQuestion`：
- "接下来做什么？"
  - 选项：
    - "运行 `/consistency-check` —— 验证此 GDD 的值是否与现有 GDD 冲突（在设计下一个系统之前推荐）"
    - "设计下一个系统 ([next-in-order])" —— 如果还有未设计的系统
    - "修复审查发现的问题" —— 如果 design-review 标记了问题
    - "本次会话在此停止"
    - "运行 `/gate-check`" —— 如果已设计和审查了足够的 MVP 系统

---

## 6. 专家 Agent 路由

本 Skill 将任务委派给专家 Agent 以获取领域专业知识。主会话
编排整体流程；Agent 提供专家内容。

| System Category | Primary Agent | Supporting Agent(s) |
|----------------|---------------|---------------------|
| **Foundation/Infrastructure** (event bus, save/load, scene mgmt, service locator) | `systems-designer` | `gameplay-programmer` (feasibility), `engine-programmer` (engine integration) |
| Combat, damage, health | `game-designer` | `systems-designer` (formulas), `ai-programmer` (enemy AI), `art-director` (hit feedback visual direction, VFX intent) |
| Economy, loot, crafting | `economy-designer` | `systems-designer` (curves), `game-designer` (loops) |
| Progression, XP, skills | `game-designer` | `systems-designer` (curves), `economy-designer` (sinks) |
| Dialogue, quests, lore | `game-designer` | `narrative-director` (story), `writer` (content), `art-director` (character visual profiles, cinematic tone) |
| UI systems (HUD, menus) | `game-designer` | `ux-designer` (flows), `ui-programmer` (feasibility), `art-director` (visual style direction), `technical-artist` (render/shader constraints) |
| Audio systems | `game-designer` | `audio-director` (direction), `sound-designer` (specs) |
| AI, pathfinding, behavior | `game-designer` | `ai-programmer` (implementation), `systems-designer` (scoring) |
| Level/world systems | `game-designer` | `level-designer` (spatial), `world-builder` (lore) |
| Camera, input, controls | `game-designer` | `ux-designer` (feel), `gameplay-programmer` (feasibility) |
| Animation, character movement | `game-designer` | `art-director` (animation style, pose language), `technical-artist` (rig/blend constraints), `gameplay-programmer` (feel) |
| Visual effects, particles, shaders | `game-designer` | `art-director` (VFX visual direction), `technical-artist` (performance budget, shader complexity), `systems-designer` (trigger/state integration) |
| Character systems (stats, archetypes) | `game-designer` | `art-director` (character visual archetype), `narrative-director` (character arc alignment), `systems-designer` (stat formulas) |

**通过 Task 工具委派时**：
- 提供：系统名称、游戏概念摘要、依赖 GDD 摘录、正在处理的特定章节，以及需要专家输入的问题
- Agent 将分析/提案返回给主会话
- 主会话通过 `AskUserQuestion` 向用户展示 Agent 的输出
- 由用户决定；主会话写入文件
- Agent 不直接写入文件 —— 主会话拥有所有文件写入权

---

## 7. 恢复与续接

如果会话中断（压缩、崩溃、新会话）：

1. 读取 `production/session-state/active.md` —— 它记录了当前系统和哪些章节已完成
2. 读取 `design/gdd/[system-name].md` —— 有真实内容的章节已完成；
   带有 `[To be designed]` 的章节仍需处理
3. 从下一个不完整的章节续接 —— 无需重新讨论已完成的章节

这就是增量写入的重要性：每个批准的章节都能经受住任何中断。

---

## 协作协议

本 Skill 在每一步都遵循协作设计原则：

1. 对于每个章节，遵循 **Question -> Options -> Decision -> Draft -> Approval**
2. 在每个决策点使用 **AskUserQuestion**（Explain -> Capture 模式）：
   - Phase 2："准备好开始了，还是需要更多上下文？"
   - Phase 3："我可以创建骨架吗？"
   - Phase 4（每个章节）：设计问题、方案选项、草稿批准
   - Phase 5："运行设计审查？更新系统索引？接下来做什么？"
3. 在骨架和每次章节写入之前，询问 **"May I write to [filepath]?"**
4. **增量写入**：每个章节在批准后立即写入文件
5. **会话状态更新**：每次章节写入后
6. **交叉引用**：每个章节都检查现有 GDD 是否存在冲突
7. **专家路由**：复杂章节获取专家 Agent 输入，展示给用户以供决策 —— 永远不会默默写入

**永远不要**自动生成完整的 GDD 并将其作为既成事实呈现。
**永远不要**未经用户批准就写入章节。
**永远不要**在没有标记冲突的情况下与现有已批准 GDD 矛盾。
**始终**展示决策的来源（依赖 GDD、支柱、用户选择）。

## 上下文窗口感知

这是一个长时间运行的 Skill。每写完一个章节后，检查状态行是否显示上下文使用率已达到或超过 70%。如果是，则在回复中附加此通知：

> **上下文接近限制（≥70%）。** 您的进度已保存 —— 所有已批准的章节都已写入 `design/gdd/[system-name].md`。当您准备好继续时，打开一个新的 Claude Code 会话并运行 `/design-system [system-name]` —— 它会检测哪些章节已完成并从下一个章节续接。

---

## 推荐的后续步骤

- 在**新会话**中运行 `/design-review design/gdd/[system-name].md` 以独立验证已完成的 GDD
- 运行 `/consistency-check` 以验证此 GDD 的值是否与其他 GDD 冲突
- 运行 `/map-systems next` 以移动到下一个最高优先级的未设计系统
- 当所有 MVP GDD 都已编写和审查后，运行 `/gate-check pre-production`
