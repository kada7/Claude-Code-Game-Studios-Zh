# Agent 测试规范：godot-csharp-specialist

## Agent 概述
领域：Godot 4 中的 C# 模式、应用于 Godot 的 .NET 惯用法、[Export] 属性用法、信号委托和 async/await 模式。
不负责：GDScript 代码（gdscript-specialist）、GDExtension C/C++ 绑定（gdextension-specialist）。
模型层级：Sonnet（默认）。
未分配门控 ID。

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 Godot 4 中的 C# / .NET 模式 / 信号委托）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对 GDScript 或 GDExtension 代码具有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "Create an export property for enemy health with validation that clamps it between 1 and 1000."
**预期行为：**
- 生成带有 `[Export]` 属性的 C# 属性
- 使用带有属性 getter/setter 的备份字段，在 setter 中对值进行钳制
- 不使用没有验证的原始 `[Export]` 公共字段
- 遵循 Godot 4 C# 命名约定（属性使用 PascalCase，字段私有且带下划线前缀）
- 根据编码标准包含属性的 XML 文档注释

### 用例 2：领域外请求 — 正确重定向
**输入：** "Rewrite this enemy health system in GDScript."
**预期行为：**
- 不生成 GDScript 代码
- 明确声明 GDScript 编写属于 `godot-gdscript-specialist`
- 将请求重定向到 `godot-gdscript-specialist`
- 可以注明可以描述 C# 接口，以便 gdscript-specialist 了解预期的 API 形状

### 用例 3：异步信号等待
**输入：** "Wait for an animation to finish before transitioning game state using C# async."
**预期行为：**
- 生成使用 `ToSignal()` 等待 Godot 信号的正确 `async Task` 模式
- 使用 `await ToSignal(animationPlayer, AnimationPlayer.SignalName.AnimationFinished)`
- 不使用 `Thread.Sleep()` 或 `Task.Delay()` 作为轮询替代方案
- 注明调用方法必须是 `async`，并且 fire-and-forget `async void` 仅适用于事件处理程序
- 处理动画可能无法触发时的取消或超时

### 用例 4：线程模型冲突
**输入：** "This C# code accesses a Godot Node from a background Task thread to update its position."
**预期行为：**
- 标记此为竞态条件风险：Godot 节点不是线程安全的，必须仅从主线程访问
- 不批准或实现多线程节点访问模式
- 提供正确的模式：使用 `CallDeferred()`、`Callable.From().CallDeferred()` 或通过线程安全队列封送回主线程
- 解释 Godot 的主线程要求与 .NET 的线程无关类型之间的区别

### 用例 5：上下文传递 — Godot 4.6 API 正确性
**输入：** Engine version context: Godot 4.6. Request: "Connect a signal using the new typed signal delegate pattern."
**预期行为：**
- 生成使用 Godot 4 C# 中引入的类型化委托模式的 C# 信号连接（类型化信号上的 `+=` 运算符）
- 检查 4.6 上下文以确认 4.4、4.5 或 4.6 中没有对信号委托 API 的破坏性更改
- 不使用旧的基于字符串的 `Connect("signal_name", callable)` 模式（在 Godot 4 C# 中已弃用）
- 生成与项目中记录的固定 4.6 版本兼容的代码

---

## 协议合规性

- [ ] 保持在声明的领域内（Godot 4 中的 C# — 模式、导出、信号、异步）
- [ ] 将 GDScript 请求重定向到 godot-gdscript-specialist
- [ ] 将 GDExtension 请求重定向到 godot-gdextension-specialist
- [ ] 返回遵循 Godot 4 约定的 C# 代码（而非 Unity MonoBehaviour 模式）
- [ ] 将多线程 Godot 节点访问标记为不安全并提供正确模式
- [ ] 使用类型化信号委托 — 而非已弃用的基于字符串的 Connect() 调用
- [ ] 在生成代码前检查引擎版本引用以了解 API 更改

---

## 覆盖范围说明
- 带有验证的导出属性（用例 1）应具有验证钳制行为的单元测试
- 线程冲突（用例 4）是安全关键：Agent 必须无需提示即可识别并修复此问题
- 异步信号（用例 3）验证 Agent 在 Godot 的单线程约束内正确应用 .NET 惯用法