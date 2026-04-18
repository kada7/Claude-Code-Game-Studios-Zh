# 技能测试规范：/reverse-document

## 技能摘要

`/reverse-document` 根据现有源代码生成设计或架构文档。它读取指定的源文件，从类结构、方法名、常量和注释中推断设计意图，并生成 GDD 骨架（用于游戏玩法系统）或架构概述（用于技术系统）。输出是尽力推断 —— 魔法数字和未记录的代码逻辑可能导致 PARTIAL 裁决。

技能在创建文档前询问"May I write to [inferred path]?"

。不适用总监关卡。裁决：COMPLETE（干净的推断）或 PARTIAL（某些字段模糊，需要人工审查）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、PARTIAL
- [ ] 包含 "May I write" 协作协议语言，在写入文档前
- [ ] 具有下一步交接（例如，`/design-review` 以验证生成的文档）

---

## 总监关卡检查

无。`/reverse-document` 是文档工具。不适用总监关卡。

---

## 测试用例

### 用例 1：结构良好的源代码 —— 生成准确的设计文档骨架

**测试夹具：**
- `src/gameplay/health_system.gd` 存在，包含：
  - `@export var max_health: int = 100`
  - `func take_damage(amount: int)` 及 clamping 逻辑
  - `signal health_changed(new_value: int)`
  - 所有公共方法均有文档注释

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. 技能读取源文件并识别 health system
2. 技能推断设计意图：最大生命值、take_damage 行为、health signal
3. 技能生成 health system 的 GDD 骨架，包含 8 个必需部分：
   Overview、Player Fantasy、Detailed Rules、Formulas、Edge Cases、Dependencies、Tuning Knobs、Acceptance Criteria
4. Formulas 部分包含推断的 clamping 公式
5. Tuning Knobs 记录 `max_health = 100` 作为可配置值
6. 技能询问"May I write to `design/gdd/health-system.md`?"
7. 文件已写入；裁决为 COMPLETE

**断言：**
- [ ] 输出中存在所有 8 个必需的 GDD 部分
- [ ] `max_health = 100` 作为 Tuning Knob 出现
- [ ] Clamping 公式在 Formulas 部分被捕获
- [ ] "May I write" 询问了推断的路径
- [ ] 裁决为 COMPLETE

---

### 用例 2：模糊的源代码 —— 魔法数字，PARTIAL 裁决

**测试夹具：**
- `src/gameplay/enemy_ai.gd` 存在，包含：
  - 内联魔法数字：`if distance < 150:`、`speed = 3.5`
  - 无注释或文档字符串
  - 复杂的状态机逻辑，无法自解释

**输入：** `/reverse-document src/gameplay/enemy_ai.gd`

**预期行为：**
1. 技能读取文件并检测无上下文的魔法数字
2. 技能生成带有注释的 GDD 骨架："AMBIGUOUS VALUE: 150 (unknown units — is this pixels, world units, or tiles?)"
3. 技能将 Formulas 和 Tuning Knobs 部分标记为需要人工审查
4. 技能询问"May I write to `design/gdd/enemy-ai.md`?" 并附带 PARTIAL 建议
5. 文件使用 PARTIAL 标记写入；裁决为 PARTIAL

**断言：**
- [ ] 魔法数字出现 AMBIGUOUS VALUE 注释
- [ ] 明确标记了需要人工审查的部分
- [ ] 裁决为 PARTIAL（非 COMPLETE）
- [ ] 文件仍然写入 —— PARTIAL 不是阻塞失败

---

### 用例 3：多个相互依赖的文件 —— 生成跨系统概述

**测试夹具：**
- 用户提供 2 个源文件：`combat_system.gd` 和 `damage_resolver.gd`
- 文件相互引用（combat 调用 damage_resolver）

**输入：** `/reverse-document src/gameplay/combat_system.gd src/gameplay/damage_resolver.gd`

**预期行为：**
1. 技能读取两个文件并检测到依赖关系
2. 技能生成跨系统架构概述（非单独的 GDD）
3. 概述描述：Combat System → Damage Resolver 交互、共享接口、两者之间的数据流
4. 技能询问"May I write to `docs/architecture/combat-damage-overview.md`?"
5. 概述在批准后写入；裁决为 COMPLETE（或 PARTIAL（如果模糊））

**断言：**
- [ ] 两个文件一起分析（非作为两个单独的文档）
- [ ] 跨系统依赖在输出中被记录
- [ ] 输出文件写入 `docs/architecture/`（非 `design/gdd/`）
- [ ] 裁决为 COMPLETE 或 PARTIAL

---

### 用例 4：未找到源文件 —— 错误

**测试夹具：**
- `src/gameplay/inventory_system.gd` 不存在

**输入：** `/reverse-document src/gameplay/inventory_system.gd`

**预期行为：**
1. 技能尝试读取指定的文件 —— 未找到
2. 技能输出："Source file not found: src/gameplay/inventory_system.gd"
3. 技能建议检查路径或运行 `/map-systems` 以识别正确的源文件
4. 未创建文档

**断言：**
- [ ] 错误消息使用完整路径命名了缺失的文件
- [ ] 提供了替代建议（检查路径或 `/map-systems`）
- [ ] 未调用 Write 工具
- [ ] 未发出裁决（错误状态）

---

### 用例 5：总监关卡检查 —— 无关卡；reverse-document 是工具

**测试夹具：**
- 结构良好的源文件存在

**输入：** `/reverse-document src/gameplay/health_system.gd`

**预期行为：**
1. 技能生成并写入设计文档
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 COMPLETE 或 PARTIAL —— 无关卡裁决

---

## 协议合规性

- [ ] 在生成任何内容前读取源文件
- [ ] 目标是游戏玩法系统时生成所有 8 个必需的 GDD 部分
- [ ] 使用 AMBIGUOUS VALUE 标记注释模糊值
- [ ] 对于多个文件生成跨系统概述（非单独的 GDD）
- [ ] 在创建任何输出文件前询问 "May I write"
- [ ] 裁决为 COMPLETE（干净的推断）或 PARTIAL（模糊字段）

---

## 覆盖说明

- 架构概述格式（用于技术/基础设施系统）与 GDD 格式不同；推断的输出类型由源文件的性质决定（游戏逻辑 → GDD；引擎/基础设施代码 → 架构文档）。
- 源文件可读但仅包含无意义逻辑的自动生成样板代码的情况未测试；技能可能生成接近空的骨架并裁决为 PARTIAL。
- C# 和 Blueprint 源文件遵循与 GDScript 相同的推断模式；语言特定的差异在技能主体中处理。
