# 技能测试规范：/test-helpers

## 技能摘要

`/test-helpers` 为项目的测试套件生成引擎特定的测试辅助工具。辅助工具包括工厂函数（用于创建已知状态的测试实体）、测试固件加载器、断言辅助工具以及外部依赖的模拟存根。生成的辅助工具遵循 `coding-standards.md` 中的命名和结构约定，并写入 `tests/helpers/`。

每个辅助工具文件都通过“我可以写入吗”询问进行把关。如果辅助工具文件已存在，技能提供扩展而非替换的选项。无导演关卡适用。当辅助工具文件写入时，裁决为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需测试固件。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含在写入辅助工具前的“我可以写入吗”协作协议语言
- [ ] 具有下一步交接（例如，使用生成的辅助工具编写测试）

---

## 导演关卡检查

无。`/test-helpers` 是脚手架实用技能。无导演关卡适用。

---

## 测试用例

### 用例 1：理想路径 — 为 Godot/GDScript 生成玩家工厂辅助工具

**测试固件：**
- `technical-preferences.md` 中引擎为 Godot 4，语言为 GDScript
- `tests/` 目录存在（已运行 test-setup）
- `design/gdd/player.md` 存在并定义了玩家属性
- `tests/helpers/` 中无现有辅助工具

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能读取引擎（Godot 4 / GDScript）和玩家游戏设计文档以获取属性上下文
2. 技能以 GDScript 生成确定的 `PlayerFactory` 辅助工具：
   - `create_player(health: int = 100, speed: float = 200.0)` 函数
   - 返回预配置为已知状态的玩家节点
   - 使用依赖注入（无单例）
3. 技能询问“我可以写入 `tests/helpers/player_factory.gd` 吗？”
4. 批准后文件写入；裁决为 COMPLETE

**断言：**
- [ ] 生成的辅助工具为 GDScript（非 C# 或 Blueprint）
- [ ] 工厂函数参数使用符合游戏设计文档值的默认值
- [ ] 辅助工具使用依赖注入（无自动加载/单例引用）
- [ ] 文件名遵循 GDScript 的 snake_case 约定
- [ ] 裁决为 COMPLETE

---

### 用例 2：无测试设置存在 — 重定向到 /test-setup

**测试固件：**
- `tests/` 目录不存在

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能检查 `tests/` 目录 — 未找到
2. 技能报告：“未找到测试目录 — 必须先设置测试框架”
3. 技能建议在生成辅助工具前运行 `/test-setup`
4. 未创建辅助工具文件

**断言：**
- [ ] 错误消息标识缺失的 tests/ 目录
- [ ] 建议 `/test-setup` 作为先决步骤
- [ ] 不调用写入工具
- [ ] 裁决不为 COMPLETE（阻塞状态）

---

### 用例 3：辅助工具已存在 — 提供扩展而非替换的选项

**测试固件：**
- `tests/helpers/player_factory.gd` 已存在，包含 `create_player()` 函数
- 用户请求向工厂添加新的 `create_enemy()` 函数

**输入：** `/test-helpers enemy-factory`

**预期行为：**
1. 技能找到现有的 `player_factory.gd` 并检查是否是正确的扩展文件（或是否应创建单独的 `enemy_factory.gd`）
2. 技能提供选项：向现有工厂添加 `create_enemy()` 或创建 `tests/helpers/enemy_factory.gd`
3. 用户选择扩展；技能起草 `create_enemy()` 函数
4. 技能询问“我可以扩展 `tests/helpers/player_factory.gd` 吗？”
5. 批准后添加函数；裁决为 COMPLETE

**断言：**
- [ ] 检测到现有辅助工具并显示
- [ ] 用户获得扩展与新文件的选择
- [ ] 使用“我可以扩展”语言（而非用于替换的“我可以写入”）
- [ ] 扩展文件中保留现有的 `create_player()`
- [ ] 裁决为 COMPLETE

---

### 用例 4：系统无游戏设计文档 — 在辅助工具中注明缺失的设计上下文

**测试固件：**
- `technical-preferences.md` 中为 Godot 4 / GDScript
- `tests/` 存在
- 用户请求“inventory system”的辅助工具，但 `design/gdd/inventory.md` 不存在

**输入：** `/test-helpers inventory-factory`

**预期行为：**
1. 技能查找 `design/gdd/inventory.md` — 未找到
2. 技能注明：“未找到库存的游戏设计文档 — 使用占位符默认值生成辅助工具”
3. 技能生成具有通用占位符值的 `inventory_factory.gd`
   （item_count = 0, max_capacity = 20）和注释：“# TODO：编写游戏设计文档时与库存游戏设计文档对齐默认值”
4. 技能询问“我可以写入 `tests/helpers/inventory_factory.gd` 吗？”
5. 文件写入；裁决为 COMPLETE 并附带建议性说明

**断言：**
- [ ] 技能无需游戏设计文档继续进行（不阻塞）
- [ ] 生成的辅助工具具有带 TODO 注释的占位符默认值
- [ ] 输出中注明缺失的游戏设计文档（建议性警告）
- [ ] 裁决为 COMPLETE

---

### 用例 5：导演关卡检查 — 无导演关卡；test-helpers 是脚手架实用技能

**测试固件：**
- 引擎已配置，tests/ 存在

**输入：** `/test-helpers player-factory`

**预期行为：**
1. 技能生成并写入辅助工具文件
2. 不产生导演 Agent
3. 输出中不出现关卡 ID

**断言：**
- [ ] 不调用导演关卡
- [ ] 不出现关卡跳过消息
- [ ] 技能在不进行任何关卡检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在生成任何辅助工具前读取引擎（辅助工具是引擎特定的）
- [ ] 读取游戏设计文档获取默认值（如有）
- [ ] 注明缺失的游戏设计文档上下文而非阻塞
- [ ] 检测现有的辅助工具文件并提供扩展而非替换的选项
- [ ] 在任何文件操作前询问“我可以写入吗”（或“我可以扩展吗”）
- [ ] 辅助工具写入时裁决为 COMPLETE

---

## 覆盖率说明

- 模拟/存根辅助工具生成（针对如保存系统或音频总线等依赖项）遵循与工厂辅助工具相同的模式，不单独测试。
- Unity C# 辅助工具生成（使用 NSubstitute 或自定义模拟）遵循与用例 1 相同的逻辑，但输出为适当的语言。
- 未识别请求的辅助工具类型的情况未测试；技能将要求用户澄清辅助工具类型。