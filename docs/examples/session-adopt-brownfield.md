# 示例会话：/adopt — Brownfield 项目接入

**上下文：** 开发者在发现此 Agent 系统前已经构建游戏 3 个月。他们有代码、一些设计文档和粗略笔记 — 但没有适合技能使用的正确格式内容。

**起始状态：**
- `src/gameplay/` — ~4000 行 Godot 4.6 GDScript
- `design/` — 3 个带粗略设计笔记的 markdown 文件（非 GDD 模板格式）
- 无 `design/gdd/` 目录
- 无 `docs/architecture/` 目录
- 无 `production/` 目录
- 无 `design/gdd/systems-index.md`
- CLAUDE.md 存在（引擎已配置：Godot 4.6）

**会话时长：** ~30 分钟
**轮次：** 8
**结果：** 接入计划已编写，最紧急的差距（缺失系统索引）立即修复

---

## Turn 1：用户调用 /adopt

**用户：**
> /adopt

## Turn 2：Agent 检测项目状态

**Agent（technical-director，通过 /adopt，上下文：fork）：**
> 运行 brownfield 审计...
>
> **Phase 1：项目状态检测**
>
> | 工件类别 | 找到 | 备注 |
> |------------------|-------|-------|
> | 引擎配置 | ✅ | CLAUDE.md 中的 Godot 4.6 |
> | 源代码 | ✅ | `src/gameplay/` 中约 4000 行 |
> | 设计文档 | ⚠️ | `design/` 中 3 个文件，非 GDD 格式 |
> | 架构文档 | ❌ | `docs/architecture/` 缺失 |
> | 系统索引 | ❌ | `design/gdd/systems-index.md` 缺失 |
> | 生产跟踪 | ❌ | `production/` 目录缺失 |
> | 冲刺/story 文件 | ❌ | 无 |
>
> **Phase 2：格式审计（现有文件）**
>
> 检查 3 个设计文件的内部结构...
>
> *`design/combat-notes.md`：*
> - 有非正式笔记，无 GDD 模板章节
> - 包含：一些规则描述、伤害公式、粗略平衡数字
> - 缺失 GDD 模板的：Overview、Player Fantasy、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria（8 节中缺失 6 节）
>
> *`design/crafting-ideas.md`：*
> - 头脑风暴式笔记，无结构
> - 无公式，无验收标准
> - 代表早期概念思考 — 作为 GDD 的输入有用，还不是 GDD
>
> *`design/inventory.md`：*
> - 最接近 GDD — 有 Overview 和 Rules 章节
> - 缺失：Player Fantasy、Formulas、Edge Cases、Tuning Knobs、Acceptance Criteria（8 节中缺失 5 节）
>
> **Phase 3：差距分类**
>
> | 差距 | 严重度 | 原因 |
> |-----|----------|--------|
> | 无系统索引 | 阻塞 | `/design-system`、`/create-stories`、`/gate-check` 都需要它 |
> | GDD 文件非模板格式 | 高 | 技能无法从格式错误的 GDD 引用 TR-ID |
> | 无架构文档 | 高 | 无法运行 `/architecture-review` 或 `/create-control-manifest` |
> | 无生产跟踪 | 中 | 冲刺和 story 技能不会工作，但直到生产阶段才需要 |
> | `design/crafting-ideas.md` — 预 GDD 内容 | 低 | 作为输入有用；在阻塞任何东西前需要完整 GDD 编写 |

## Turn 3：Agent 呈现迁移计划

**Agent：**
> **Phase 4：迁移计划**
>
> 7 个有序步骤将你的项目带入完全对齐。绝不覆盖你现有内容 — 每一步仅填补差距。
>
> | # | 步骤 | 技能 | 优先级 | 备注 |
> |---|------|-------|----------|-------|
> | 1 | 创建 `design/gdd/systems-index.md` | `/map-systems` 或 `/adopt` 内联 | 阻塞 | 解除所有下游技能阻塞 |
> | 2 | 改造 `design/inventory.md` → GDD 格式 | `/design-system retrofit design/inventory.md` | 高 | 添加 5 个缺失章节，保留你现有内容 |
> | 3 | 改造 `design/combat-notes.md` → GDD 格式 | `/design-system retrofit design/combat-notes.md` | 高 | 添加 6 个缺失章节 |
> | 4 | 转换 `design/crafting-ideas.md` → 完整 GDD | `/design-system crafting`（新编写，使用想法作为输入） | 中 | 不是改造 — 太非正式而无法改造 |
> | 5 | 从现有代码创建架构 ADR | `/reverse-document` + `/architecture-decision` | 高 | 捕获代码中已做出的决策 |
> | 6 | 创建主架构文档 | `/create-architecture` | 高 | 在 ADR 之后 |
> | 7 | 设置生产跟踪 | `/sprint-plan new` | 中 | 在架构阶段之后 |
>
> **重要：** 步骤 1 必须在任何其他步骤之前发生。其他所有内容可以并行完成或根据你的优先级重新排序。
>
> 我可以将此计划写入 `docs/adoption-plan-2026-03-12.md` 吗？

**用户：**
> 是。写入它。

**Agent 写入接入计划。**

## Turn 4：Agent 主动修复最紧急的差距

**Agent：**
> 阻塞差距是缺失的 `design/gdd/systems-index.md`。
>
> 我现在可以通过读取你现有代码和设计文档来推断你已构建的系统来创建一个。这比从头运行 `/map-systems` 更快 — 我会基于已存在的内容填充它，然后你确认或调整。
>
> 你想让我现在做这个吗？

**用户：**
> 是的，做吧。

## Turn 5：Agent 读取代码库并起草系统索引

**Agent：**
> 读取 `src/gameplay/` 以推断系统...
>
> 在代码中找到这些系统边界：
>
> - `src/gameplay/combat/` — 伤害计算、命中检测、状态效果
> - `src/gameplay/inventory/` — 物品管理、重量、堆叠
> - `src/gameplay/crafting/` — 配方查找、结果生成（引用 inventory）
> - `src/gameplay/movement/` — CharacterBody2D、地形修正（被 combat 引用用于定位）
> - `src/gameplay/ui/` — HUD、库存界面、对话框
> - `src/gameplay/world/` — 瓦片地图、地形类型、区块加载
>
> **系统索引草稿：**
>
> | 系统 | 类别 | 优先级 | 依赖 | GDD 状态 |
> |--------|----------|----------|--------------|------------|
> | Movement | 基础 | MVP | 无 | ❌ 缺失 |
> | World/Terrain | 基础 | MVP | Movement | ❌ 缺失 |
> | Combat | 核心 | MVP | Movement | ⚠️ 需要改造 |
> | Inventory | 核心 | MVP | 无 | ⚠️ 需要改造 |
> | Crafting | 功能 | MVP | Inventory | ❌ 仅预 GDD |
> | UI / HUD | 表现 | MVP | Combat、Inventory、Movement | ❌ 缺失 |
>
> 这看起来对吗？我遗漏或错分了什么吗？

**用户：**
> 看起来对。添加一个 Stamina 系统 — 它在 combat/ 中但应该是自己的系统。

**Agent：**
> 将 Stamina 添加为核心 / MVP 系统：
>
> | Stamina | 核心 | MVP | Movement、Combat | ❌ 缺失 |
>
> 已更新依赖：Movement 依赖 Stamina（移动消耗它）。
>
> 我可以将此写入 `design/gdd/systems-index.md` 吗？

## Turn 6：用户批准

**用户：**
> 是

**Agent 写入 `design/gdd/systems-index.md`。**

## Turn 7：Agent 展示现在已解锁的内容

**Agent：**
> `design/gdd/systems-index.md` 已创建。
>
> **阻塞差距已解决。** 以下技能现在可以运行：
>
> - ✅ `/design-system [name]` — 任何系统的引导式 GDD 编写
> - ✅ `/design-system retrofit [path]` — 在现有文档中填补缺失章节
> - ✅ `/gate-check` — 现在有系统索引可验证
> - ✅ `/help` — 现在可以显示正确的阶段工作流
>
> **（来自接入计划的）推荐下一步：**
>
> 1. 运行 `/design-system retrofit design/inventory.md` — 你最完整的现有文档，最容易的胜利
> 2. 运行 `/design-system retrofit design/combat-notes.md`
> 3. 运行 `/design-system crafting` — 使用你的想法文件作为输入编写制作 GDD
>
> 这 3 个完成后，你将有 7 个系统中的 5 个拥有完整 GDD。然后运行 `/review-all-gdds` 以在架构工作前捕获跨系统一致性问题。

## Turn 8：用户确认计划

**用户：**
> 完美。我会从库存改造开始。

**Agent：**
> 运行：
> ```
> /design-system retrofit design/inventory.md
> ```
>
> 该技能会检测到你现有的 Overview 和 Rules 章节，展示 8 节中哪些缺失，并仅为差距运行章节循环。你现有内容不会被触及。

---

## 此示例演示了什么

- **FORMAT 审计，非存在性审计**：`/adopt` 不仅仅检查文件是否存在 — 它检查其内部结构是否匹配技能期望。名为 `gdd.md` 的文件如果没有模板章节，会被标记为差距。
- **迁移，非替换**：现有内容永远不会被覆盖。计划仅填补差距。
- **阻塞差距优先呈现**：缺失的系统索引被识别为阻塞，因为它阻止最多的技能运行。
- **内联创建紧急差距**：Agent 不仅仅报告差距，还提供在同一会话中立即修复它。
- **从代码推断**：系统索引从代码库结构自举，而非从头编写 — brownfield 代码已经包含答案。
- **改造 vs. 新编写**：`/design-system retrofit` 处理现有但不完整的文档；完整 `/design-system` 处理全新文档。接入计划区分每种文件适用哪种。
- **上下文：fork**：`/adopt` 在 forked 上下文中运行，以避免用跨整个代码库的大量文件读取污染主会话。
