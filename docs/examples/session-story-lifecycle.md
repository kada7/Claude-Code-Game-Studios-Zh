# 示例会话：完整 Story 生命周期 — /story-readiness → 实现 → /story-done

**上下文：** 独立开发者，生产冲刺中期。移动系统 GDD 和架构已完成。移动核心实现的故事已由 `/create-stories` 生成。

**起始状态：**
- `design/gdd/movement-system.md` — 完整，全部 8 节
- `docs/architecture/movement-adr-001.md` — 状态：已接受
- `production/sprints/sprint-03.md` — 在待办中列出 STORY-MOV-001
- `production/stories/STORY-MOV-001.md` — 存在但尚未验证
- 尚无实现代码

**会话时长：** ~50 分钟
**轮次：** 13
**结果：** Story 验证为就绪，已实现，通过 `/story-done` 验证完成

---

## Phase 1：Story 就绪检查

### Turn 1：用户运行就绪检查

**用户：**
> /story-readiness production/stories/STORY-MOV-001.md

### Turn 2：Agent 验证 Story

**Agent（通过 /story-readiness）：**
> 读取 `production/stories/STORY-MOV-001.md`...
>
> **STORY-MOV-001：实现带地形修正的 CharacterBody2D 移动**
>
> 运行 4 项验证检查：
>
> **1. 设计完整性**
> - 引用的 GDD：`design/gdd/movement-system.md` ✅
> - GDD 章节覆盖：Detailed Rules ✅、Formulas ✅、Edge Cases ✅
> - 嵌入的 TR-ID：TR-MOV-001 到 TR-MOV-008 ✅
>
> **2. 架构完整性**
> - 引用的 ADR：`docs/architecture/movement-adr-001.md` ✅
> - ADR 状态：**已接受** ✅ *（如果为提议中，则会被阻塞）*
> - Story 中的控制清单版本：`2026-03-10` — 当前清单为 `2026-03-10` ✅
>
> **3. 范围清晰度**
> - 验收标准：9 项，全部可衡量 ✅
> - 范围外项目已列出：swimming、climbing ✅
> - 发现的歧义：**1**
>   - ⚠️ Story 说"翻滚方向跟随最后输入方向"但 GDD 说"朝移动方向翻滚" — 当玩家停止并立即翻滚时这些冲突。在拾取前澄清。
>
> **4. 完成的定义**
> - 所需测试：公式函数的单元测试 ✅
> - 集成信号：`on_stamina_event` 必须正确触发 ✅
>
> ---
> **裁决：需要修改**
>
> 一个歧义必须在实现开始前解决。你想现在解决它以便我将 story 标记为就绪吗？

### Turn 3：用户解决歧义

**用户：**
> 翻滚使用最后移动方向。如果玩家静止不动，翻滚使用面向方向代替。

### Turn 4：Agent 更新 Story

**Agent：**
> 更新 story 的 Detailed Rules 章节：
>
> > 翻滚方向：最后移动方向。如果翻滚输入时速度为零，翻滚使用当前面向方向。
>
> 我可以将此写入 `production/stories/STORY-MOV-001.md` 并将状态设为 `ready-for-dev` 吗？

**用户：**
> 是

**Agent 写入更新。Story 状态：`ready-for-dev`。**

> **裁决：就绪**
> Story 已准备好实现。准备好构建时拾取它。

---

## Phase 2：实现

### Turn 5：用户开始实现

**用户：**
> 让我们实现 STORY-MOV-001。我准备好开始编码了。

### Turn 6：Agent 读取 Story 和 ADR

**Agent（gameplay-programmer）：**
> 读取 `production/stories/STORY-MOV-001.md`、`design/gdd/movement-system.md` 和 `docs/architecture/movement-adr-001.md`...
>
> **架构（来自 ADR-001）：**
> - `MovementComponent.gd` — 附加到玩家场景，不是单例
> - 通过 `TerrainLayer.get_modifier(tile_position)` 辅助进行地形修正查找
> - Stamina 事件通过信号（非直接调用 StaminaSystem）
>
> **我提出的文件结构：**
> ```
> src/gameplay/movement/
>   movement_component.gd       # CharacterBody2D 逻辑，状态机
>   terrain_modifier_table.gd   # 常量表：terrain_type -> {speed_mod, drain_mod}
> tests/unit/
>   test_movement_formulas.gd   # 速度/消耗计算的单元测试
> ```
>
> 我可以继续这个结构吗？

**用户：**
> 是

### Turn 7：Agent 实现并展示关键代码

**Agent：**
> 实现 `movement_component.gd`。写文件前供你审阅的关键摘录：
>
> ```gdscript
> class_name MovementComponent
> extends Node
>
> signal stamina_event(type: String, amount: float)
>
> @export var base_walk_speed: float = 120.0
> @export var run_multiplier: float = 1.7
> @export var stamina_drain_walk: float = 2.0
> @export var stamina_drain_run: float = 6.0
> @export var stamina_cost_roll: float = 15.0
>
> var _is_carrying_heavy: bool = false
>
> func _physics_process(delta: float) -> void:
>     var terrain_mod := _get_terrain_modifier()
>     var effective_speed := _calculate_speed(terrain_mod)
>     # ...
> ```
>
> 所有值都是 `@export` — 没有硬编码。这是你想要的吗？

**用户：**
> 看起来不错。写入它。

### Turn 8-9：Agent 写入文件和测试

**Agent 写入：**
- `src/gameplay/movement/movement_component.gd`
- `src/gameplay/movement/terrain_modifier_table.gd`
- `tests/unit/test_movement_formulas.gd`

**Agent：**
> 文件已写入。运行可用的 linting 检查...
>
> 无错误。测试文件已创建，含 6 个单元测试覆盖：
> - 行走速度公式（3 种地形类型）
> - 奔跑速度公式
> - 耐力消耗计算
> - 翻滚耐力成本（含和不含零速度边界情况）
>
> 需要手动测试：无敌帧、坡度阻挡、地形集成（需要运行场景）。

---

## Phase 3：Story 完成

### Turn 10：用户手动测试并运行 /story-done

**用户：**
> 我已经在场景中测试过了 — 一切正常。/story-done production/stories/STORY-MOV-001.md

### Turn 11：Agent 运行完成评审

**Agent（通过 /story-done）：**
> 读取 story、GDD、ADR...
>
> **Phase 1：Story 已定位** ✅ `production/stories/STORY-MOV-001.md`
>
> **Phase 2：验收标准验证**
>
> | # | 标准 | 验证 | 状态 |
> |---|-----------|--------------|--------|
> | 1 | 正常地面行走速度正确 | 自动：公式单元测试通过 | ✅ 自动 |
> | 2 | 奔跑速度正确 | 自动：公式单元测试通过 | ✅ 自动 |
> | 3 | 耐力 0 时奔跑取消 | 手动：用户确认 | ✅ 手动 |
> | 4 | 翻滚无敌帧工作 | 手动：用户确认 | ✅ 手动 |
> | 5 | 地形修正正确应用 | 手动：用户确认 | ✅ 手动 |
> | 6 | 重载禁用奔跑 | 自动：尚不可测试（库存未集成） | ⏳ 已延期 |
> | 7 | Stamina 信号正确触发 | 自动：集成测试待进行 | ⏳ 已延期 |
> | 8 | 无硬编码值 | 自动：grep 魔术数字 → 找到 0 个 | ✅ 自动 |
> | 9 | 坡度 >45° 阻挡移动 | 手动：用户确认 | ✅ 手动 |
>
> **Phase 3：GDD/ADR 偏差**
>
> 针对 TR-ID 扫描实现...
>
> - TR-MOV-001 到 TR-MOV-007：✅ 按规格实现
> - TR-MOV-008（重载信号）：⚠️ 建议 — 延期到库存集成 story。不是偏差，只是现在无法验证。
>
> **Phase 4：清单陈旧度检查**
>
> Story 控制清单版本 `2026-03-10` 匹配当前清单 `2026-03-10`。✅
>
> **Phase 5：代码评审提示**
>
> 建议在标记完成前运行 `/code-review src/gameplay/movement/`。不阻塞。
>
> ---
> **完成报告：带备注完成**
>
> Story 已完成。两个标准延期到库存集成 — 记录为延期，非阻塞。
>
> 我可以将 story 状态更新为 `Status: Complete` 并添加完成备注，以及更新 `production/sprint-status.yaml` 吗？

**用户：**
> 是

### Turn 12：Agent 关闭 Story

**Agent 写入：**
- Story `Status: Complete` + 完成备注（延期标准已记录）
- `production/sprint-status.yaml` — STORY-MOV-001 设为 `done`

**Agent：**
> STORY-MOV-001 已关闭。
>
> **已记录延期标准**（将在库存集成 story 中自动呈现）：
> - 重载禁用奔跑（需要库存信号）
> - Stamina 信号集成测试（需要 stamina 系统）
>
> **来自 sprint 的下一个就绪 story：**
> - STORY-MOV-002：Stamina 系统 — 这是逻辑上的下一个 story（下游依赖现已解除阻塞）
> - STORY-HUD-001：移动 HUD 指示器 — 也已解除阻塞
>
> 无论你拾取哪个，都对其运行 `/story-readiness`。

---

## 此示例演示了什么

- **就绪门槛捕获真实问题**：翻滚方向歧义会导致 `/story-readiness` 在没有它的情况下产生后期实现决策
- **ADR 状态是硬门槛**：如果 `movement-adr-001.md` 是 `Proposed` 而非 `Accepted`，story 会是 `BLOCKED`，实现不会开始
- **延期标准**：不是每个验收标准都能在 story 关闭时验证 — `/story-done` 跟踪延期项目，而非阻塞完成
- **TR-ID 引用**：story 存储 `TR-MOV-001` ID，而非引用 GDD 文本 — 避免 GDD 措辞稍后清理时产生错误偏差标记
- **sprint-status.yaml**：冲刺状态的单一真相来源，由 `/story-done` 更新，由 `/sprint-status` 读取
- **清单版本检查**：确保 story 的实现指导未偏离当前架构决策
