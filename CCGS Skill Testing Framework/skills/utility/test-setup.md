# 技能测试规范：/test-setup

## 技能摘要

`/test-setup` 根据配置的引擎为项目搭建测试框架。它创建 `coding-standards.md` 中定义的 `tests/` 目录结构（unit/、integration/、performance/、playtest/），并生成适合检测到的引擎的测试运行器配置：Godot 的 GdUnit4 配置、Unity 的 Unity Test Runner asmdef，或 Unreal Engine 的无头运行器。

创建的每个文件或目录都受"May I write"询问的限制。如果测试框架已存在，技能会验证配置而非重新初始化。不适用总监关卡。脚手架就位时裁决为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在创建文件前
- [ ] 具有下一步交接（例如，`/test-helpers` 以生成辅助工具）

---

## 总监关卡检查

无。`/test-setup` 是脚手架工具。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— Godot 项目，搭建 GdUnit4 测试结构

**测试夹具：**
- `technical-preferences.md` 将引擎设置为 Godot 4，语言为 GDScript
- `tests/` 目录尚不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能从 `technical-preferences.md` 读取引擎 → Godot 4 + GDScript
2. 技能起草测试目录结构：tests/unit/、tests/integration/、tests/performance/、tests/playtest/，以及 GdUnit4 运行器配置文件
3. 技能询问"May I write the tests/ directory structure?"
4. 目录和 GdUnit4 运行器脚本在批准后创建
5. 技能确认运行器脚本与 coding-standards.md 中的 CI 命令匹配：`godot --headless --script tests/gdunit4_runner.gd`
6. 裁决为 COMPLETE

**断言：**
- [ ] 所有 4 个子目录（unit/、integration/、performance/、playtest/）均已创建
- [ ] 生成了 GdUnit4 运行器配置
- [ ] 运行器脚本路径与 coding-standards.md 中的 CI 命令匹配
- [ ] 在创建任何文件前询问 "May I write"
- [ ] 裁决为 COMPLETE

---

### 用例 2：Unity 项目 —— 使用 asmdef 搭建 Unity Test Runner

**测试夹具：**
- `technical-preferences.md` 将引擎设置为 Unity，语言为 C#
- `tests/` 目录不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能读取引擎 → Unity + C#
2. 技能使用 Unity 约定创建 `Tests/` 目录（首字母大写）
3. 技能生成 `Tests/Tests.asmdef` 和 `Tests/Editor/EditorTests.asmdef`
4. 配置了 EditMode 和 PlayMode 测试运行器模式
5. 技能询问 "May I write the Tests/ directory structure?"
6. 裁决为 COMPLETE

**断言：**
- [ ] 创建了 Unity 特定的 `Tests/` 结构（非 Godot 结构）
- [ ] 生成了 `.asmdef` 文件
- [ ] 存在 EditMode 和 PlayMode 运行器配置
- [ ] 裁决为 COMPLETE

---

### 用例 3：测试框架已存在 —— 验证配置，非重新初始化

**测试夹具：**
- `tests/unit/`、`tests/integration/` 存在
- GdUnit4 运行器脚本存在（Godot 项目）

**输入：** `/test-setup`

**预期行为：**
1. 技能检测到现有的 tests/ 结构
2. 技能报告："Test framework already exists — verifying configuration"
3. 技能检查：运行器脚本路径、目录完整性、CI 命令对齐
4. 如果所有检查通过：报告 "Configuration verified — no changes needed"
5. 如果检查失败（例如，缺少 tests/performance/）：报告具体的差距并询问 "May I add the missing directories?"

**断言：**
- [ ] 框架存在时，技能不会重新初始化
- [ ] 对现有结构执行验证检查
- [ ] 仅缺失的部分触发 "May I write" 询问
- [ ] 无论一切正常还是差距已修复，裁决均为 COMPLETE

---

### 用例 4：未配置引擎 —— 重定向到 /setup-engine

**测试夹具：**
- `technical-preferences.md` 仅包含占位符（引擎未设置）

**输入：** `/test-setup`

**预期行为：**
1. 技能读取 `technical-preferences.md` 并找到引擎占位符
2. 技能报告："Engine not configured — cannot scaffold engine-specific test framework"
3. 技能建议先运行 `/setup-engine`
4. 未创建目录或文件

**断言：**
- [ ] 错误消息明确说明引擎未配置
- [ ] `/setup-engine` 被建议为下一步
- [ ] 未调用 Write 工具
- [ ] 裁决不为 COMPLETE（阻塞状态）

---

### 用例 5：总监关卡检查 —— 无关卡；test-setup 是脚手架工具

**测试夹具：**
- 引擎已配置，tests/ 不存在

**输入：** `/test-setup`

**预期行为：**
1. 技能搭建并写入所有测试框架文件
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 在生成任何脚手架前从 `technical-preferences.md` 读取引擎
- [ ] 生成适合引擎的测试运行器配置（非通用）
- [ ] 从 coding-standards.md 创建所有 4 个子目录
- [ ] 在创建文件前询问 "May I write"
- [ ] 检测到现有框架时提供验证（非重新初始化）
- [ ] 脚手架就位时裁决为 COMPLETE

---

## 覆盖说明

- Unreal Engine 测试脚手架（使用 `-nullrhi` 的无头运行器）遵循与用例 1 和 2 相同的模式，未单独使用夹具测试。
- CI 集成文件生成（例如，`.github/workflows/test.yml`）被引用但此处未断言测试 —— 它可能是单独的 skill 关注点。
- tests/ 存在但来自不同引擎的情况（例如，Unity 测试在现在使用 Godot 的项目中）未测试；技能会检测到不匹配并提供协调选项。
