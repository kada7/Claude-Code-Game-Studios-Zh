# Agent 测试规范: godot-gdscript-specialist

## Agent 摘要
领域: GDScript 静态类型、GDScript 中的设计模式、信号架构、协程/await 模式以及 GDScript 性能。
不负责: 着色器代码 (godot-shader-specialist)、GDExtension 绑定 (godot-gdextension-specialist)。
模型层级: Sonnet (默认)。
未分配门控 ID。

---

## 静态断言 (结构)

- [ ] `description:` 字段存在且是领域特定的 (引用 GDScript / 静态类型 / 信号 / 协程)
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级是 Sonnet (专家的默认设置)
- [ ] Agent 定义不声明对着色器代码或 GDExtension 的权限

---

## 测试用例

### 用例 1: 领域内请求 — 适当的输出
**输入:** "Review this GDScript file for type annotation coverage."
**预期行为:**
- 读取提供的 GDScript 文件
- 标记每个缺少静态类型注解的变量、参数和返回类型
- 生成具体的逐行发现列表: `var speed = 5.0` → `var speed: float = 5.0`
- 指出 Godot 4 中静态类型在性能和工具方面的优势
- 不会未经提示重写整个文件 — 生成供开发者应用的发现列表

### 用例 2: 领域外请求 — 正确重定向
**输入:** "Write a vertex shader to distort the mesh in world space."
**预期行为:**
- 不会用 GDScript 或 Godot 的着色语言生成着色器代码
- 明确声明着色器编写属于 `godot-shader-specialist`
- 将请求重定向到 `godot-shader-specialist`
- 可以指出 GDScript 方面 (向着色器传递 uniform、设置着色器参数) 在其领域内

### 用例 3: 使用协程的异步加载
**输入:** "Load a scene asynchronously and wait for it to finish before spawning it."
**预期行为:**
- 为 Godot 4 生成 `await` + `ResourceLoader.load_threaded_request` 模式
- 全程使用静态类型 (`var scene: PackedScene`)
- 使用 `ResourceLoader.load_threaded_get_status()` 处理完成检查
- 指出加载失败的错误处理
- 不使用已弃用的 Godot 3 `yield()` 语法

### 用例 4: 性能问题 — 类型化数组推荐
**输入:** "The entity update loop is slow; it iterates an untyped Array of 1,000 nodes every frame."
**预期行为:**
- 识别出非类型化的 `Array` 在 GDScript 中放弃了编译器优化
- 建议转换为类型化数组 (`Array[Node]` 或特定类型) 以启用 JIT 提示
- 指出如果这仍然不足，建议将热点路径升级到 C# 迁移推荐
- 生成类型化数组重构作为立即修复
- 在没有性能分析证据的情况下，不建议将整个代码库迁移到 C#

### 用例 5: 上下文传递 — Godot 4.6 及截止日期后的功能
**输入:** 提供引擎版本上下文: Godot 4.6。请求: "Create an abstract base class for all enemy types using @abstract."
**预期行为:**
- 识别 `@abstract` 为 Godot 4.5+ 功能 (截止日期后)
- 在输出中指出这一点: 功能在 4.5 中引入，根据 VERSION.md 迁移说明进行验证
- 使用 `@abstract` 生成具有正确语法的 GDScript 类，如迁移说明中所述
- 由于截止日期后的状态，将输出标记为需要根据官方 4.5 发布说明进行验证
- 在抽象类中为所有方法签名使用静态类型

---

## 协议合规性

- [ ] 保持在声明的领域内 (GDScript — 类型、模式、信号、协程、性能)
- [ ] 将着色器请求重定向到 godot-shader-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回具有完整静态类型的结构化 GDScript 输出
- [ ] 仅使用 Godot 4 API — 不使用已弃用的 Godot 3 模式 (yield、带字符串的 connect 等)
- [ ] 标记截止日期后的功能 (4.4, 4.5, 4.6) 并将其标记为需要文档验证

---

## 覆盖范围说明
- 类型注解审查 (用例 1) 输出适合作为代码审查清单
- 异步加载 (用例 3) 应生成可在 `tests/unit/` 中通过单元测试验证的可测试代码
- 截止日期后的 @abstract (用例 5) 确认 Agent 标记版本不确定性，而不是静默使用未经验证的 API