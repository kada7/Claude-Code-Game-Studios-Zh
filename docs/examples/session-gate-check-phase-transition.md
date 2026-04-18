# 示例会话：/gate-check 阶段过渡 — 系统设计 → 技术设置

**上下文：** 独立开发者，第 5 周末。系统设计阶段感觉已完成 — 6 份 MVP GDD 已编写，交叉评审完成，引擎已设置。用户希望正式推进到技术设置。

**起始状态：**
- `production/stage.txt` — 当前 `systems-design`
- `design/gdd/systems-index.md` — 列出 6 个 MVP 系统，全部标记 `Status: GDD Complete`
- `design/gdd/` — 6 份 GDD 文件存在
- `design/gdd/gdd-cross-review-2026-03-10.md` — 交叉评审报告，裁决：CONCERNS（1 条低优先级备注）
- 引擎已配置（Godot 4.6，`/setup-engine` 完成）

**会话时长：** ~20 分钟
**轮次：** 7
**结果：** 阶段门通过，`stage.txt` 更新为 `technical-setup`，清晰列出后续步骤

---

## Turn 1：用户启动阶段门检查

**用户：**
> /gate-check

## Turn 2：Agent 检测当前阶段并运行检查

**Agent（通过 /gate-check）：**
> 读取 `production/stage.txt` — 当前阶段：**systems-design**
>
> 运行阶段门：**系统设计 → 技术设置**
>
> ---
> **必需工件检查清单：**
>
> | 工件 | 要求 | 状态 |
> |----------|-------------|--------|
> | `design/gdd/systems-index.md` | 存在，列出所有 MVP 系统 | ✅ |
> | 每个系统 GDD | 所有 MVP 系统都有 GDD | ✅ (6/6) |
> | 每份 GDD 的 `/design-review` | 每份 GDD 已评审 | ✅ (6/6 评审意见已找到) |
> | 跨 GDD 评审报告 | `design/gdd/gdd-cross-review-*.md` 存在 | ✅ |
> | 交叉评审裁决 | PASS 或 CONCERNS（非 FAIL） | ✅ CONCERNS |
> | 引擎已配置 | `production/stage.txt` 或 CLAUDE.md 引擎条目 | ✅ Godot 4.6 |
>
> ---
> **内容扫描：**
>
> 检查 GDD 完整性（每个需要 8 个章节）...
>
> | GDD | 缺失章节 |
> |-----|-----------------|
> | movement-system.md | 无 ✅ |
> | stamina-system.md | 无 ✅ |
> | combat-system.md | 无 ✅ |
> | inventory-system.md | 无 ✅ |
> | crafting-system.md | 无 ✅ |
> | exploration-system.md | 无 ✅ |
>
> ---
> **交叉评审关注项（来自 `gdd-cross-review-2026-03-10.md`）：**
>
> 1. ⚠️ LOW — Crafting 和 inventory 都独立定义了"物品堆叠大小"，默认值不同（crafting：99，inventory：64）。一个系统应作为权威来源；另一个应引用它。不阻塞 — 可在 ADR 中解决。
>
> ---
> **裁决：PASS**
>
> 所有必需工件已存在。交叉评审关注项为 LOW 严重度，可在技术设置期间通过 ADR 解决。这是此阶段的正常发现。
>
> **我可以将 `production/stage.txt` 推进到 `technical-setup` 吗？**

## Turn 3：用户确认

**用户：**
> 是的，推进它。

## Turn 4：Agent 更新阶段并呈现后续步骤

**Agent：**
> 已更新 `production/stage.txt` → `technical-setup`
>
> ---
> **你现在处于：技术设置**
>
> 此阶段在生产编码开始前建立技术基础。你的目标是获得完整、已批准的架构，以便预生产中编写的每个 story 都有清晰、明确的技术指导。
>
> **此阶段需要的步骤（按顺序）：**
>
> 1. **`/create-architecture`** — 编写主架构文档。涵盖系统分解、数据流、层边界和模块职责。
>
> 2. **`/architecture-decision`（每个重大技术选择一次）** — 至少：
>    - 渲染方案（2D 相机、视口等）
>    - 存档/加载策略
>    - 音频总线架构
>    - 交叉评审中的"物品堆叠大小权威来源"问题（crafting vs inventory）
>
> 3. **`/architecture-review`** — 验证所有 ADR 的完整性、依赖排序和 GDD 可追溯性。产出 TR-registry。
>
> 4. **`/create-control-manifest`** — 将已接受的 ADR 转换为扁平程序员规则表。这是实现 Agent 编码期间会查阅的内容。
>
> 5. **`/gate-check`** — 技术设置 → 预生产阶段门。需要：架构文档、所有 ADR 已接受、控制清单、依赖排序已解决。
>
> **可选但推荐：**
> - 如果你有任何计划保留的原型代码，运行 `/tech-debt` 扫描
> - 如果你尚未获取 Godot 4.6 API 快照，重新运行 `/setup-engine`
>
> **提示：** 从 `/architecture-decision` 处理物品堆叠大小冲突开始。这是一个快速胜利，可以在之后为两个 ADR 创造歧义之前关闭一个开放问题。

## Turn 5：用户询问交叉评审关注项

**用户：**
> 我在 ADR 中实际应该写什么来处理堆叠大小冲突？

## Turn 6：Agent 提供建议

**Agent：**
> ADR 的决策是：**哪个系统拥有规范的 `max_stack_size` 值？**
>
> 两个选项供考虑：
>
> **选项 A：Inventory 拥有它**
> - `ItemData` 资源（由 inventory 拥有）获得 `max_stack_size: int = 64`
> - Crafting 系统从 `ItemData` 读取，从不设置自己的值
> - 优点：inventory 是所有物品属性的真相来源
> - 缺点：crafting 团队需要知道去查看 inventory 数据
>
> **选项 B：物品数据资源拥有它（共享资源）**
> - `ItemData.max_stack_size` 是两个系统的权威来源
> - Crafting 和 inventory 都从 `ItemData` 导入
> - 优点：单一来源，crafting 和 inventory 模块之间无耦合
> - 缺点：共享数据层中多一个东西
>
> 大多数工作室在有 >2 个系统触及物品数据时选择 B（共享资源）。但对独立项目来说，两者都有效。
>
> 运行 `/architecture-decision`，它会引导你完成 ADR 格式，包括 Dependencies 章节，将此 ADR 链接回两份 GDD。

## Turn 7：用户收尾

**用户：**
> 明白了。我会从这个的 `/architecture-decision` 开始。

**Agent：**
> 好的起点。ADR 将记录决策、推理以及它满足的 GDD 需求 — 这样当你几个月后编写代码时，依据得以保留。
>
> 你的阶段门已记录。在技术设置期间的任何时候运行 `/help`，都可以查看你针对所需检查清单的当前进度。

---

## 此示例演示了什么

- **阶段门检查是自动化的，非手动的**：Agent 读取工件并检查它们 — 用户无需填写表格
- **CONCERNS ≠ FAIL**：交叉评审关注项为 LOW 严重度并通过阶段门。FAIL 需要在推进前解决。
- **Stage.txt 是权威来源**：状态行、`/help` 和所有技能从 `production/stage.txt` 读取 — 在此处更新会改变每个后续技能看到的内容
- **后续步骤是阶段特定的**：Agent 不会给出一个通用的"祝你好运" — 它会给出技术设置特定的有序检查清单
- **阶段门检查呈现遗留工作**：堆叠大小冲突是交叉评审备注；阶段门检查确保它成为具体的 ADR 而非丢失
- **每个阶段门一次推进**：用户明确确认推进。阶段门不会自动推进；需要人工确认。
