# 示例会话：使用 /design-system 编写 GDD

**上下文：** 独立开发者，项目第 3 周。`/map-systems` 已运行并生成了 `design/gdd/systems-index.md`。移动系统被列为 MVP 层级，基础优先级。

**起始状态：**
- `design/gdd/game-concept.md` 存在（生存-制作游戏，2D，Godot 4.6）
- `design/gdd/systems-index.md` 存在（识别出 15 个系统，移动是设计顺序中的第一个）
- 尚未编写每个系统的 GDD
- 移动没有上游依赖（它是基础）

**会话时长：** ~60 分钟
**轮次：** 14
**结果：** 完整的 `design/gdd/movement-system.md`，全部 8 个必需章节已写入文件，准备进行 `/design-review`

---

## Turn 1：用户调用技能

**用户：**
> /design-system movement

## Turn 2：Agent 加载上下文并呈现计划

**Agent（game-designer，通过 /design-system）：**
> 加载上下文，我们开始：
>
> - 读取 `design/gdd/game-concept.md` — 生存-制作，探索为主，孤独幸存者 stranded 在外星球
> - 读取 `design/gdd/systems-index.md` — 移动是 **基础 / MVP**，无上游依赖，下游：combat、exploration、stamina
> - 未找到先前的移动 GDD — 从零开始
>
> **技术可行性预检查：**
>
> | 领域 | 信号 |
> |--------|--------|
> | 引擎 | Godot 4.6 — CharacterBody2D 配合 move_and_slide() 支持良好 |
> | 物理 | Jolt 现在是 4.6 的默认 — 2D 移动不受影响，但注意未来 3D 工作 |
> | 下游风险 | Stamina 系统列为下游依赖 — 移动必须暴露 stamina 回调钩子 |
>
> GDD 模板有 **8 个必需章节**。我们一次一节：
> `Overview → Player Fantasy → Detailed Rules → Formulas → Edge Cases → Dependencies → Tuning Knobs → Acceptance Criteria`
>
> 我会向你展示每节的草稿，你批准或修订，然后我在进入下一节前将其写入文件。
>
> 现在创建带空章节标题的文件骨架 — 我可以写入带占位符的 `design/gdd/movement-system.md` 吗？

**用户：**
> 是

**Agent 写入** `design/gdd/movement-system.md`，含 8 个空章节标题。

---

## Turn 3：第 1 节 — Overview

**Agent：**
> **第 1 节草稿 — Overview：**
>
> > 移动系统是玩家与世界的主要接口。它管理孤独幸存者如何行走、奔跑、翻滚和穿越外星地形。移动是物理真实的 — 行星有比地球更重的重力，幸存者身体疲惫 — 但保持足够的响应性以不阻碍玩家。该系统直接输入探索节奏、战斗定位和耐力系统。
>
> 这捕捉了你想要的吗？

**用户：**
> 很好但添加一些关于地形的内容 — 表面会减慢你的速度或有摩擦修正。

**Agent：**
> 已修订：
>
> > 移动系统是玩家与世界的主要接口。它管理孤独幸存者如何行走、奔跑、翻滚和穿越外星地形。移动是物理真实的 — 行星有比地球更重的重力，幸存者身体疲惫 — 但保持足够的响应性以不阻碍玩家。地形表面施加摩擦和速度修正（光滑岩石、沙子、浅水），使导航成为一项有意义的技能。该系统直接输入探索节奏、战斗定位和耐力系统。
>
> 我可以将此写入文件中的第 1 节吗？

**用户：**
> 是

**Agent 将第 1 节写入文件。**

---

## Turn 4：第 2 节 — Player Fantasy

**Agent：**
> **第 2 节草稿 — Player Fantasy：**
>
> > 玩家应该感觉像一个疲惫但能力足够的幸存者 — 不是超级英雄，不是无助。早期游戏移动是审慎且费力的；玩家随着时间赢得流畅性。当穿越外星地形时，目标是谨慎导航伴随紧迫时刻（逃离威胁、跃过缺口）。幻想是"我了解这片地形" — 每种表面类型随着玩家内化摩擦系统而变得可读且可控。
>
> 批准、修订，还是改变方向？

**用户：**
> 喜欢。写入它。

**Agent 将第 2 节写入文件。**

---

## Turn 5：第 3 节 — Detailed Rules

**Agent：**
> **第 3 节草稿 — Detailed Rules：**
>
> > **基础状态：**
> > - **Walk**（默认）：完全方向控制，中等速度，低耐力消耗
> > - **Run**（按住 Shift）：更快，每秒中等耐力消耗 — 耐力达到 0 时自动取消
> > - **Roll/Dodge**（轻按 Space）：移动方向上的快速爆发，短暂无敌帧，高耐力成本（固定）
> > - **Idle**：零移动输入，耐力以全速恢复
> >
> > **地形修正：**
> > - 普通地面：1.0x 速度乘数，标准摩擦
> > - 沙子/松散土壤：0.8x 速度，1.1x 耐力消耗（更难移动）
> > - 光滑岩石（湿）：1.1x 速度，降低停止摩擦（玩家滑过）
> > - 浅水（没过脚踝）：0.7x 速度，无摩擦修正
> > - 深水：移动禁用，替换为游泳（单独系统，范围外）
> >
> > **碰撞：**
> > - CharacterBody2D + move_and_slide()；启用 wall slide
> > - 最多 45° 坡度正常行走；>45° 阻挡
> > - 支持单向平台（用 Down + Jump 穿透）
>
> 这里内容很多 — 希望我删减还是扩展什么？

**用户：**
> 添加携带重物（如大块资源）时禁用奔跑。

**Agent：**
> 添加到 Run 规则：
> > - **Run**（按住 Shift）：更快，每秒中等耐力消耗 — 耐力达到 0 时自动取消。**携带重物时禁用**（由库存系统广播信号）。
>
> 写入文件？

**用户：**
> 是

**Agent 将第 3 节写入文件。**

---

## Turn 6：第 4 节 — Formulas

**Agent：**
> **第 4 节草稿 — Formulas：**
>
> 先定义变量，然后是公式：
>
> | 变量 | 类型 | 描述 |
> |----------|------|-------------|
> | `base_walk_speed` | float | 基础行走速度，单位 px/s（可调） |
> | `run_multiplier` | float | 奔跑速度 = 行走 × 此值 |
> | `terrain_speed_mod` | float | 每地形乘数（0.7–1.1） |
> | `stamina_drain_walk` | float | 行走时每秒耐力单位 |
> | `stamina_drain_run` | float | 奔跑时每秒耐力单位 |
> | `stamina_cost_roll` | float | 每次翻滚的固定耐力成本 |
> | `terrain_drain_mod` | float | 每地形耐力消耗乘数 |
>
> **有效速度：**
> ```
> effective_speed = base_walk_speed × run_multiplier（如果奔跑，否则 1.0）× terrain_speed_mod
> ```
>
> **耐力消耗（每秒）：**
> ```
> drain_per_sec = stamina_drain_walk（或如果奔跑则为 stamina_drain_run）× terrain_drain_mod
> ```
>
> **翻滚耐力成本（固定）：**
> ```
> stamina_after_roll = current_stamina - stamina_cost_roll
>（限制到 0 — 翻滚仍然执行，但玩家落地时耐力为 0）
> ```
>
> 批准还是调整变量名/公式？

**用户：**
> 看起来正确。写入它。

**Agent 将第 4 节写入文件。**

---

## Turn 7-9：第 5、6、7 节

*（这些遵循相同模式 — Agent 起草，用户批准或请求小调整，Agent 在继续前将每节写入文件。此处缩写。）*

**第 5 节 — Edge Cases** 涵盖：
- 玩家翻滚进墙（动画完成，无移动加成）
- 耐力在奔跑中达到 0（过渡到行走，无颠簸）
- 两种地形重叠（较低乘数获胜）
- 在光滑岩石上翻滚（仍然对停止应用光滑摩擦，不对翻滚本身）

**第 6 节 — Dependencies** 涵盖：
- **Stamina 系统**（下游）：移动暴露 `on_stamina_event(type: String, amount: float)` 信号
- **Inventory 系统**（下游）：监听 `carrying_heavy_object_changed(is_heavy: bool)` 信号
- **Input 系统**：移动方向来自 `InputMap` — 标准 Godot 动作名称（`ui_left`、`ui_right` 等）
- **Terrain 层**：瓦片元数据驱动地形修正查找

**第 7 节 — Tuning Knobs** 涵盖：
- `base_walk_speed`（默认：120 px/s）
- `run_multiplier`（默认：1.7）
- 每地形速度和消耗修正（4 种地形类型的表格）
- `stamina_drain_walk`、`stamina_drain_run`、`stamina_cost_roll`

---

## Turn 10：第 8 节 — Acceptance Criteria

**Agent：**
> **第 8 节草稿 — Acceptance Criteria：**
>
> 这些是证明此系统完成的可测试条件：
>
> - [ ] 玩家在正常地面以 `base_walk_speed` 行走（用调试覆盖层测量）
> - [ ] 玩家在正常地面以 `base_walk_speed × run_multiplier` 奔跑
> - [ ] 耐力达到 0 时奔跑自动取消，无需输入
> - [ ] 翻滚以正确无敌帧执行（通过碰撞箱调试模式验证）
> - [ ] 每种地形类型应用正确速度修正（冲刺计划中的 QA 表格）
> - [ ] 携带重物禁用奔跑（用库存集成测试）
> - [ ] Stamina 系统在行走、奔跑和翻滚期间接收 `on_stamina_event` 信号
> - [ ] 所有移动值来自导出变量 — 代码中无硬编码数字
>
> 这涵盖了你认为的"完成"吗？

**用户：**
> 添加一个关于坡度的 — 确保 >45 度坡度阻挡移动。

**Agent：**
> 已添加：
> - [ ] 坡度 ≤45° 正常穿越；坡度 >45° 阻挡移动（玩家滑回）
>
> 写入文件？

**用户：**
> 是。写入它。

**Agent 将第 8 节写入文件。**

---

## Turn 11：完成摘要

**Agent：**
> 全部 8 节已写入 `design/gdd/movement-system.md`。
>
> **GDD 状态：**
> - ✅ Overview
> - ✅ Player Fantasy
> - ✅ Detailed Rules
> - ✅ Formulas
> - ✅ Edge Cases
> - ✅ Dependencies（暴露 2 个信号：stamina_event、carrying_heavy）
> - ✅ Tuning Knobs
> - ✅ Acceptance Criteria
>
> **做出的关键决策：**
> - 地形修正作为瓦片元数据（而非代码常量）
> - 翻滚有固定耐力成本（非每秒）
> - 重载禁用奔跑（信号驱动，非硬编码检查）
>
> **推荐的下一步：** 在队列中进入下一个系统前（根据 systems-index 的依赖顺序，stamina 是下一个），运行 `/design-review design/gdd/movement-system.md`。
>
> 评审将验证完整性、内部一致性，并捕获在此 GDD 上构建前需要修订的任何内容。

---

## 此示例演示了什么

- **增量文件写入**：每节在批准后即刻写入磁盘 — 会话崩溃最多丢失一个进行中的章节
- **模板填充**：GDD 模板的 8 个章节通过对话变成具体内容，而非批量生成
- **依赖信号**：Agent 在 Dependencies 章节中主动呈现下游信号契约（stamina、inventory）
- **技术可行性预检查**：Agent 在设计开始前注意到 Jolt 物理变更，而非在实现损坏后
- **逐节循环**：没有一次性倾倒完整草稿 — 每节是一个小型、可评审的单元
- **恢复**：如果会话崩溃，Agent 在重启时重新读取文件并从第一个空节恢复
