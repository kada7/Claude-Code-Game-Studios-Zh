# 技能测试规范：/setup-engine

## 技能摘要

`/setup-engine` 通过填充 `technical-preferences.md` 来配置项目的引擎、语言、渲染后端、物理引擎、专家代理分配和命名约定。它接受可选的引擎参数（例如，`/setup-engine godot`）以跳过引擎选择步骤。对于 `technical-preferences.md` 的每个部分，技能展示草稿并询问"May I write to `technical-preferences.md`?" 后再更新。

该技能还根据所选引擎填充专家路由表（文件扩展名 → agent 映射）。它没有总监关卡 —— 配置是技术工具任务。文件完全写入时裁决始终为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在更新 technical-preferences.md 前
- [ ] 具有下一步交接（例如，`/brainstorm` 或 `/start`，取决于流程）

---

## 总监关卡检查

无。`/setup-engine` 是技术配置技能。不适用总监关卡。

---

## 测试用例

### 用例 1：Godot 4 + GDScript —— 完整的引擎配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 提供了引擎参数：godot

**输入：** `/setup-engine godot`

**预期行为：**
1. 技能跳过引擎选择步骤（提供了参数）
2. 技能展示 Godot 的语言选项：GDScript 或 C#
3. 用户选择 GDScript
4. 技能起草所有引擎部分：engine/language/rendering/physics 字段、命名约定（GDScript 的 snake_case）、专家分配（godot-specialist、gdscript-specialist、godot-shader-specialist 等）
5. 技能填充路由表：`.gd` → gdscript-specialist、`.gdshader` → godot-shader-specialist、`.tscn` → godot-specialist
6. 技能询问"May I write to `technical-preferences.md`?"
7. 文件在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] Engine 字段设置为 Godot 4（非占位符）
- [ ] Language 字段设置为 GDScript
- [ ] 命名约定适合 GDScript（snake_case）
- [ ] 路由表包含 `.gd`、`.gdshader` 和 `.tscn` 条目
- [ ] 专家已分配（非占位符）
- [ ] 在写入前询问 "May I write"
- [ ] 裁决为 COMPLETE

---

### 用例 2：Unity + C# —— Unity 特定的配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 提供了引擎参数：unity

**输入：** `/setup-engine unity`

**预期行为：**
1. 技能设置引擎为 Unity，语言为 C#
2. 命名约定适合 C#（类使用 PascalCase，字段使用 camelCase）
3. 专家分配引用 unity-specialist、csharp-specialist
4. 路由表：`.cs` → csharp-specialist、`.asmdef` → unity-specialist、`.unity`（场景）→ unity-specialist
5. 技能询问 "May I write to `technical-preferences.md`?" 并在批准后写入

**断言：**
- [ ] Engine 字段设置为 Unity（非 Godot 或 Unreal）
- [ ] Language 字段设置为 C#
- [ ] 命名约定反映 C# 约定
- [ ] 路由表包含 `.cs` 和 `.unity` 条目
- [ ] 裁决为 COMPLETE

---

### 用例 3：Unreal + Blueprint —— Unreal 特定的配置

**测试夹具：**
- `technical-preferences.md` 仅包含占位符
- 提供了引擎参数：unreal

**输入：** `/setup-engine unreal`

**预期行为：**
1. 技能设置引擎为 Unreal Engine 5，主要语言为 Blueprint（Visual Scripting）
2. 专家分配引用 unreal-specialist、blueprint-specialist
3. 路由表：`.uasset` → blueprint-specialist 或 unreal-specialist、`.umap` → unreal-specialist
4. 性能预算预设为 Unreal 默认值（例如，更高的 draw call 预算）
5. 技能询问 "May I write" 并在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] Engine 字段设置为 Unreal Engine 5
- [ ] 路由表包含 `.uasset` 和 `.umap` 条目
- [ ] 已分配 Blueprint specialist
- [ ] 裁决为 COMPLETE

---

### 用例 4：引擎已配置 —— 提供重新配置特定部分

**测试夹具：**
- `technical-preferences.md` 已将引擎设置为 Godot 4，所有字段已填充
- 未提供引擎参数

**输入：** `/setup-engine`

**预期行为：**
1. 技能读取 `technical-preferences.md` 并检测到完全配置的引擎（Godot 4）
2. 技能报告："Engine already configured as Godot 4 + GDScript"
3. 技能展示选项：重新配置所有内容、仅重新配置特定部分（Engine/Language、Naming Conventions、Specialists、Performance Budgets）
4. 用户选择 "Reconfigure Performance Budgets only"
5. 仅更新性能预算部分；所有其他字段保持不变
6. 技能询问 "May I write to `technical-preferences.md`?" 并在批准后写入

**断言：**
- [ ] 仅请求部分更新时，技能不会覆盖所有字段
- [ ] 向用户提供特定部分的重新配置选项
- [ ] 写入的文件中仅修改了选定的部分
- [ ] 裁决为 COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；setup-engine 是工具技能

**测试夹具：**
- 全新项目，未配置引擎

**输入：** `/setup-engine godot`

**预期行为：**
1. 技能完成完整的引擎配置
2. 任何时刻都不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 在询问写入前展示草稿配置
- [ ] 在写入前询问 "May I write to `technical-preferences.md`?"
- [ ] 提供引擎参数时尊重该参数（跳过选择步骤）
- [ ] 检测到现有配置时提供部分重新配置
- [ ] 为所选引擎的所有关键文件类型填充路由表
- [ ] 文件写入后裁决为 COMPLETE

---

## 覆盖说明

- Godot 4 + C#（替代 GDScript）遵循与用例 1 相同的流程，但命名约定不同，并分配 godot-csharp-specialist。此变体未单独测试。
- 引擎版本特定的引导（例如，来自 VERSION.md 的 Godot 4.6 知识差距警告）由技能展示，但此处未断言测试。
- 每个引擎的性能预算默认值被注明为引擎特定的，但确切的默认值未断言测试。
