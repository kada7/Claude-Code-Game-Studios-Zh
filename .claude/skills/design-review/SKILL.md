---
name: design-review
description: "审查游戏设计文档的完整性、内部一致性、可实现性和对项目设计标准的遵循。在将设计文档交给程序员之前运行此技能。"
argument-hint: "[path-to-design-doc] [--depth full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
---

## 阶段0：解析参数

如果存在，提取 `--depth [full|lean|solo]`。默认值是没有标志时的 `full`。

**注意**：`--depth` 控制此技能的*分析深度*（生成多少专家Agent）。它独立于 `production/review-mode.txt` 中的全局审查模式，后者控制总监阶段门的生成。这是两个不同的概念 — `--depth` 关于此技能分析文档的彻底程度。

- **`full`**：完整审查 — 所有阶段 + 专家Agent委托（阶段3b）
- **`lean`**：所有阶段，无专家Agent — 更快，单次会话分析
- **`solo`**：仅阶段1-4，无委托，无阶段5后续步骤提示 — 从另一个技能内部调用时使用

---

## 阶段1：加载文档

完整读取目标设计文档。读取CLAUDE.md了解项目上下文和标准。读取目标文档引用或暗示的相关设计文档（检查 `design/gdd/` 中的相关系统）。

**依赖图验证：** 对于Dependencies部分列出的每个系统，使用 Glob 检查其GDD文件是否存在于 `design/gdd/` 中。标记任何不存在的 — 这些是下游作者会遇到的断开引用。

**背景/叙事对齐：** 如果 `design/gdd/game-concept.md` 或 `design/narrative/` 中的任何文件存在，读取它。注意此GDD中与已建立的世界规则、基调或设计支柱相矛盾的机制选择。在阶段3b中将此上下文传递给 `game-designer`。

**先前审查检查：** 检查 `design/gdd/reviews/[doc-name]-review-log.md` 是否存在。如果存在，读取最近的条目 — 注意给出的裁决和列出的阻塞项目。此会话是重新审查；追踪之前的项目是否已解决。

---

## 阶段2：完整性检查

对照设计文档标准检查清单进行评估：

- [ ] 有Overview（概述）部分（单段摘要）
- [ ] 有Player Fantasy（玩家幻想）部分（预期感受）
- [ ] 有Detailed Rules（详细规则）部分（明确机制）
- [ ] 有Formulas（公式）部分（所有数学使用变量定义）
- [ ] 有Edge Cases（边界情况）部分（处理的异常情况）
- [ ] 有Dependencies（依赖关系）部分（列出的其他系统）
- [ ] 有Tuning Knobs（调整参数）部分（可配置值已识别）
- [ ] 有Acceptance Criteria（验收标准）部分（可测试的成功条件）

---

## 阶段3：一致性与可实现性

**内部一致性：**
- 公式是否产生与描述行为相匹配的值？
- 边界情况是否与主要规则相矛盾？
- 依赖关系是否双向（另一个系统是否知道这个系统）？

**可实现性：**
- 规则是否精确到程序员可以无需猜测就能实现？
- 是否有任何"手挥"部分缺少细节？
- 是否考虑了性能影响？

**跨系统一致性：**
- 这是否与任何现有机制冲突？
- 这是否与其他系统产生意外的交互？
- 这是否与游戏的既定基调和支柱一致？

---

## 阶段3b：对抗性专家审查（仅full模式）

**在 `lean` 或 `solo` 模式下跳过此阶段。**

**此阶段在full模式下是强制的。** 不要跳过它。

**在生成任何Agent之前**，打印此通知：
> "完整审查：并行生成专家Agent。这通常需要8-15分钟。使用 `--review lean` 进行更快的单次会话分析。"

### 第1步 — 识别GDD涉及的所有领域

读取GDD并识别所涉及的每个领域。一个GDD可以同时涉及多个领域 — 要彻底。常见信号：

| 如果GDD包含... | 生成这些Agent |
|------------------------|-------------------|
| 费用、价格、掉落、奖励、经济 | `economy-designer` |
| 战斗属性、伤害、血量、DPS | `game-designer`, `systems-designer` |
| AI行为、寻路、瞄准 | `ai-programmer` |
| 关卡布局、生成、波次结构 | `level-designer` |
| 玩家进度、经验值、解锁 | `economy-designer`, `game-designer` |
| UI、HUD、菜单、面向玩家的显示 | `ux-designer`, `ui-programmer` |
| 对话、任务、故事、背景故事 | `narrative-director` |
| 动画、手感、时机、果汁感 | `gameplay-programmer` |
| 多人游戏、同步、复制 | `network-programmer` |
| 音频提示、音乐触发 | `audio-director` |
| 性能、绘制调用、内存 | `performance-analyst` |
| 引擎特定模式或API | 主要引擎专家（来自 `.claude/docs/technical-preferences.md`） |
| 验收标准、测试覆盖 | `qa-lead` |
| 数据架构、资源结构 | `systems-designer` |
| 任何游戏系统 | `game-designer`（始终） |

**始终将 `game-designer` 和 `systems-designer` 作为基准最小值生成。** 每个GDD都涉及他们的领域。

### 第2步 — 并行生成所有相关专家

**重要：此技能中的 Task 生成一个子Agent — 一个有独立上下文窗口的独立Claude会话。它不是任务追踪。不要在内部模拟专家视角。不要自己推理领域观点。必须发出实际的 Task 调用。模拟审查不是专家审查。**

同时发出所有 Task 调用。不要逐个生成。

**以对抗性方式提示每个专家：**
> "这是 [系统] 的GDD以及主审查到目前为止的结构性发现。
> 你的工作不是验证这个设计 — 你的工作是找出问题。
> 从你的领域专业知识挑战设计选择。什么是错误的、
> 规格不足的、可能导致问题的，或完全缺失的？
> 要具体且批判性。欢迎与主审查持不同意见。"

**每个Agent类型的附加说明：**

- **`game-designer`**：将你的审查锚定在此GDD第B节中陈述的玩家幻想上。这个设计真的能实现那种幻想吗？玩家会感受到预期的体验吗？标记任何服务于可实现性但损害所陈述感受的规则。

- **`systems-designer`**：对于GDD中的每个公式，代入边界值（最小和最大合理输入）。报告是否有任何输出变得退化 — 负值、除以零、无穷大，或在极端情况下产生无意义的结果。

- **`qa-lead`**：审查每个验收标准。标记任何不能独立测试的 — 像"感觉平衡"、"正确工作"、"性能良好"这样的措辞不是验收标准。建议对任何未通过此测试的标准进行具体改写。

### 第3步 — 高级主管审查

所有专家响应后，生成 `creative-director` 作为**高级审查者**：
- 提供：GDD、所有专家发现、它们之间的任何分歧
- 询问："综合这些发现。最重要的问题是什么？你同意专家的意见吗？你对这个设计的总体裁决是什么？"
- creative-director的综合成为阶段4中的**最终裁决**。

### 第4步 — 暴露分歧

如果专家之间或与creative-director之间存在分歧，不要静默选择一个观点。在阶段4中明确展示分歧，让用户裁决。

用来源标记每个发现：`[game-designer]`、`[economy-designer]`、`[creative-director]` 等。

---

## 阶段4：输出审查

```
## 设计审查：[文档标题]
咨询的专家：[列出生成的Agent]
重新审查：[是 — 先前裁决于 YYYY-MM-DD 为 X / 否 — 首次审查]

### 完整性：[X/8部分存在]
[列出缺失的部分]

### 依赖图
[列出每个声明的依赖关系以及其GDD文件是否存在于磁盘上]
- ✓ enemy-definition-data.md — 存在
- ✗ loot-system.md — 未找到（文件尚不存在）

### 实现前需要
[编号列表 — 仅阻塞问题。每个项目标记来源Agent。]

### 建议修订
[编号列表 — 重要但不阻塞。来源标记。]

### 专家分歧
[Agent之间或与主审查分歧的情况。
呈现两方观点 — 不要静默解决。]

### 锦上添花
[次要改进，低优先级。]

### 高级裁决 [creative-director]
[创意总监的综合和总体评估。]

### 范围信号
根据以下因素估计实现范围：依赖数量、公式数量、
涉及的系统，以及是否需要新ADR。
- **S** — 单一系统，无公式，无新ADR，<3个依赖
- **M** — 中等复杂度，1-2个公式，3-6个依赖
- **L** — 多系统集成，3+个公式，可能需要新ADR
- **XL** — 横切关注点，5+个依赖，可能需要多个新ADR
清晰标记："粗略范围信号：M（制作人应在冲刺规划前验证）"

### 裁决：[APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
```

此技能是只读的 — 阶段4期间不写入任何文件。

---

## 阶段5：后续步骤

**所有关闭交互均使用 `AskUserQuestion`。** 不使用纯文本。

**第一个Widget — 下一步：**

如果APPROVED（首次通过，无需修订），直接进入系统索引Widget、审查日志Widget，然后进入最终关闭Widget。不显示单独的"下一步做什么"Widget — 最终关闭Widget涵盖后续步骤。

如果NEEDS REVISION或MAJOR REVISION NEEDED，选项：
- `[A] 现在修订GDD — 一起解决阻塞项目`
- `[B] 停在这里 — 在单独的会话中修订`
- `[C] 按原样接受并继续（仅当所有项目都是建议性的时）`

**如果用户选择[A] — 现在修订：**

处理所有阻塞项目，仅在无法从GDD和现有文档中解决问题时才询问设计决策。在进行任何编辑之前，将所有设计决策问题分组到单个多标签 `AskUserQuestion` 中 — 不要为每个阻塞项目单独中断修订。

所有修订完成后，显示摘要表（阻塞 → 已应用的修复）并使用 `AskUserQuestion` 进行**修订后关闭Widget**：

- 提示："修订完成 — 已解决 [N] 个阻塞项目。下一步？"
- 注意当前上下文使用情况：如果上下文超过约50%，添加："（推荐：在重新审查之前 /clear — 此会话已使用 X% 上下文。完整重新审查运行5个Agent，需要干净的上下文。）"
- 选项：
  - `[A] 在新会话中重新审查 — 在 /clear 后运行 /design-review [doc-path]`
  - `[B] 接受修订并标记为Approved — 更新系统索引，跳过重新审查`
  - `[C] 转到下一个系统 — /design-system [下一个系统] （设计顺序中的#N）`
  - `[D] 停在这里`

不要用纯文本结束修订流程。始终用此Widget关闭。

**第二个Widget — 系统索引更新（始终单独显示）：**

使用第二个 `AskUserQuestion`：
- 提示："我可以更新 `design/gdd/systems-index.md` 将 [系统] 标记为 [In Review / Approved] 吗？"
- 选项：`[A] 是 — 更新它` / `[B] 否 — 保持原样`

**第三个Widget — 审查日志（始终提供）：**

使用第三个 `AskUserQuestion`：
- 提示："我可以将此审查摘要追加到 `design/gdd/reviews/[doc-name]-review-log.md` 吗？这创建了修订历史，让未来的重新审查可以追踪变化。"
- 选项：`[A] 是 — 追加到审查日志` / `[B] 否 — 跳过`

如果是，以此格式追加条目：
```
## 审查 — [YYYY-MM-DD] — 裁决：[APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED]
范围信号：[S/M/L/XL]
专家：[列表]
阻塞项目：[数量] | 建议：[数量]
摘要：[来自creative-director裁决的2-3句关键发现摘要]
先前裁决已解决：[是 / 否 / 首次审查]
```

---

**最终关闭Widget — 始终在所有文件写入完成后显示：**

系统索引和审查日志Widget回答后，检查项目状态并显示最终的 `AskUserQuestion`：

在构建选项之前，读取：
- `design/gdd/systems-index.md` — 找到任何Status为In Review或NEEDS REVISION的系统（除刚刚审查的那个之外）
- 计算 `design/gdd/` 中的 `.md` 文件数量（不包括game-concept.md、systems-index.md）以确定是否值得提供 `/review-all-gdds`（≥2个GDD）
- 在设计顺序中找到Status为Not Started的下一个系统

动态构建选项列表 — 仅包括真正属于下一步的选项：
- `[_] 运行 /design-review [other-gdd-path] — [系统名称] 仍处于 [In Review / NEEDS REVISION]`（如果另一个GDD需要审查则包含）
- `[_] 运行 /consistency-check — 验证此GDD的值不与现有GDD冲突`（如果存在≥1个其他GDD则始终包含）
- `[_] 运行 /review-all-gdds — 跨所有设计系统的整体设计理论审查`（如果存在≥2个GDD则包含）
- `[_] 运行 /design-system [next-system] — 设计顺序中的下一个`（始终包含，命名实际系统）
- `[_] 停在这里`

仅为实际包含的选项分配字母A、B、C…。将最有利于推进管线的选项标记为 `（推荐）`。

不要在文件写入后用纯文本结束技能。始终用此Widget关闭。
