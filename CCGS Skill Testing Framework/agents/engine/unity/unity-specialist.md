# Agent 测试规范：unity-specialist

## Agent 摘要
领域：Unity 特定的架构模式、MonoBehaviour 与 DOTS 决策，以及子系统选择（Addressables、New Input System、UI Toolkit、Cinemachine 等）。
不负责：语言特定的深入探讨（委托给 unity-dots-specialist、unity-ui-specialist 等）。
模型层级：Sonnet（默认）。
未分配门控 ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且具有领域特定性（引用 Unity 模式 / MonoBehaviour / 子系统决策）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义确认子专家路由表（DOTS、UI、Shader、Addressables）

---

## 测试用例

### 用例 1：领域内请求 - 适当的输出
**输入：** "我应该使用 MonoBehaviour 还是 ScriptableObject 来存储敌人配置数据？"
**预期行为：**
- 生成一个模式决策树，涵盖：
  - MonoBehaviour：用于运行时行为，需要附加到 GameObject，具有 Update() 生命周期
  - ScriptableObject：用于纯数据/配置，作为资产存在，跨实例共享，无场景依赖
- 推荐使用 ScriptableObject 处理敌人配置数据（无状态、可重用、设计友好）
- 指出 MonoBehaviour 可以引用 ScriptableObject 供运行时使用
- 提供 ScriptableObject 类定义的具体示例（不生成完整代码 - 引用 engine-programmer 或 gameplay-programmer 进行实现）

### 用例 2：错误引擎重定向
**输入：** "为这个敌人系统设置带有信号的 Node 场景树。"
**预期行为：**
- 不生成 Godot Node/信号代码
- 识别这是 Godot 模式
- 说明在 Unity 中等效的是 GameObject 层级结构 + UnityEvent 或 C# 事件
- 映射概念：Godot Node → Unity MonoBehaviour，Godot Signal → C# 事件 / UnityEvent
- 在继续之前确认项目基于 Unity

### 用例 3：Unity 版本 API 标志
**输入：** "使用新的 Unity 6 GPU 常驻绘制器进行批量渲染。"
**预期行为：**
- 识别 Unity 6 功能（GPU Resident Drawer）
- 标记此 API 可能在早期 Unity 版本中不可用
- 在提供实现指导前询问或检查项目的 Unity 版本
- 指导验证官方 Unity 6 文档
- 未经确认不假设项目使用 Unity 6

### 用例 4：DOTS 与 MonoBehaviour 冲突
**输入：** "战斗系统使用 MonoBehaviour 进行状态管理，但我们想添加基于 DOTS 的投射物系统。它们能共存吗？"
**预期行为：**
- 识别这是混合架构场景
- 解释混合方法：MonoBehaviour 可以通过 SystemAPI、IComponentData 和托管组件与 DOTS 交互
- 指出混合两种模式的性能和复杂性权衡
- 建议将架构决策升级到 `lead-programmer` 或 `technical-director`
- 将 DOTS 侧实现细节委托给 `unity-dots-specialist`

### 用例 5：上下文传递 - Unity 版本
**输入：** 提供项目上下文：Unity 2023.3 LTS。请求："为此项目配置新的 Input System。"
**预期行为：**
- 应用 Unity 2023.3 LTS 上下文：使用 New Input System（com.unity.inputsystem）包
- 不生成旧版 Input Manager 代码（`Input.GetKeyDown()`、`Input.GetAxis()`）
- 指出任何 2023.3 特定的 Input System 行为或包版本约束
- 如果 Input System 与 DOTS 交互，引用项目版本以确认 Burst/Jobs 兼容性

---

## 协议合规性

- [ ] 保持在声明的领域内（Unity 架构决策、模式选择、子系统路由）
- [ ] 将 Godot 模式重定向到适当的 Godot 专家或标记为错误引擎
- [ ] 将 DOTS 实现重定向到 unity-dots-specialist
- [ ] 将 UI 实现重定向到 unity-ui-specialist
- [ ] 标记 Unity 版本限制的 API，并在建议它们之前需要版本确认
- [ ] 返回结构化的模式决策指南，而非自由形式的意见

---

## 覆盖范围说明
- MonoBehaviour 与 ScriptableObject（用例 1）如果导致项目级决策，应记录为 ADR
- 版本标志（用例 3）确认 Agent 在没有上下文的情况下不假设最新的 Unity 版本
- DOTS 混合（用例 4）验证 Agent 升级架构冲突而不是单方面解决它们