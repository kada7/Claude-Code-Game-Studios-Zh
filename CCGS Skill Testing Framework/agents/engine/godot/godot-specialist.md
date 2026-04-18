# Agent 测试规范：godot-specialist

## Agent 概览
**领域：** Godot 特定模式、节点/场景架构、信号、资源，以及 GDScript vs C# vs GDExtension 决策。
**不负责：** 特定语言的实际代码编写（委托给语言子专家）。
**模型层级：** Sonnet（默认）。
**未分配 Gate ID。**

---

## 静态断言（结构）

- [ ] `description:` 字段存在且是领域特定的（涉及 Godot 架构 / 节点模式 / 引擎决策）
- [ ] `allowed-tools:` 列表包括 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义引用 `docs/engine-reference/godot/VERSION.md` 作为权威 API 来源

---

## 测试用例

### 用例 1：领域内请求 —— 适当的输出
**输入：** "When should I use signals vs. direct method calls in Godot?"（何时应在 Godot 中使用信号 vs 直接方法调用？）
**预期行为：**
- 生成带有理由的模式决策指南：
  - 信号：解耦通信、父子关系无知、事件驱动的 UI 更新、一对多通知
  - 直接调用：紧密耦合的系统，其中调用者需要返回值，或性能关键的热点路径
- 在项目上下文中提供每种模式的具体示例
- 不生成两种模式的原始代码 —— 将实现交由 gdscript-specialist 或 csharp-specialist 处理
- 注意 "no upward signals" 约定（子节点不直接调用父节点方法 —— 使用信号代替）

### 用例 2：错误引擎重定向
**输入：** "Write a MonoBehaviour that runs on Start() and subscribes to a UnityEvent."（编写一个在 Start() 上运行并订阅 UnityEvent 的 MonoBehaviour。）
**预期行为：**
- 不生成 Unity MonoBehaviour 代码
- 清晰识别这是 Unity 模式，而非 Godot 模式
- 提供 Godot 等效方案：使用 `_ready()` 代替 `Start()` 的 Node 脚本，以及使用 Godot 信号代替 UnityEvent
- 确认项目基于 Godot 并重定向概念映射

### 用例 3：截止后 API 风险
**输入：** "Use the new Godot 4.5 @abstract annotation to define an abstract base class."（使用新的 Godot 4.5 @abstract 注解定义抽象基类。）
**预期行为：**
- 识别 `@abstract` 是截止后功能（在 Godot 4.5 中引入，晚于 LLM 知识截止日期）
- 标记版本风险：LLM 对此注解的知识可能不完整或不正确
- 引导用户验证 `docs/engine-reference/godot/VERSION.md` 和官方 4.5 迁移指南
- 基于版本参考中的迁移笔记提供尽力而为的指导，同时明确标记为未经验证

### 用例 4：热点路径的语言选择
**输入：** "The physics query loop runs every frame for 500 objects. Should we use GDScript or C# for this?"（物理查询循环每帧为 500 个对象运行。我们应该为此使用 GDScript 还是 C#？）
**预期行为：**
- 提供平衡分析：
  - GDScript：更简单、团队熟悉，但对于紧密循环较慢
  - C#：对于 CPU 密集型循环更快，需要 .NET 运行时，团队需要 C# 知识
- 不单方面做出最终决定
- 将决定交由 `lead-programmer`，并将分析作为输入
- 指出 GDExtension (C++) 是极端性能情况的第三种选择，并在 C# 不足时建议升级

### 用例 5：上下文传递 —— 引擎版本 4.6
**输入：** 提供引擎版本上下文：Godot 4.6，Jolt 作为默认物理引擎。请求："Set up a RigidBody3D for the player character."（为玩家角色设置 RigidBody3D。）
**预期行为：**
- 读取 4.6 上下文并应用 Jolt 默认知识（来自 VERSION.md 迁移笔记）
- 推荐与 Jolt 兼容的 RigidBody3D 配置选择（例如，注意在 Jolt 下表现不同的任何 GodotPhysics 特定设置）
- 引用关于 Jolt 成为默认物理引擎的 4.6 迁移笔记，而非仅依赖 LLM 训练数据
- 标记 RigidBody3D 属性在 GodotPhysics 和 Jolt 之间行为发生变化的任何情况

---

## 协议合规性

- [ ] 保持在声明的领域内（Godot 架构决策、节点/场景模式、语言选择）
- [ ] 将特定语言实现重定向到 godot-gdscript-specialist 或 godot-csharp-specialist
- [ ] 返回结构化发现（决策树、带有理由的模式推荐）
- [ ] 将 `docs/engine-reference/godot/VERSION.md` 视为权威，而非 LLM 训练数据
- [ ] 标记截止后 API 使用（4.4、4.5、4.6）并附带验证要求
- [ ] 在存在权衡时将语言选择决策交由 lead-programmer 处理

---

## 覆盖范围说明
- 信号 vs 直接调用指南（用例 1）应写入 `docs/architecture/` 作为可重用模式文档
- 截止后标记（用例 3）确认 Agent 不会自信地使用其无法验证的 API
- 引擎版本用例（用例 5）验证 Agent 应用版本参考中的迁移笔记，而非假设