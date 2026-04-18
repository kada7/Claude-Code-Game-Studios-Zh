# Agent 测试规范：ue-blueprint-specialist

## Agent 概述
- **领域**: Blueprint 架构、Blueprint/C++ 边界、Blueprint 图表质量、Blueprint 性能优化、Blueprint 函数库设计
- **不负责**: C++ 实现（engine-programmer 或 gameplay-programmer）、美术资源或着色器、UI/UX 流程设计（ux-designer）
- **模型层级**: Sonnet
- **阶段门 ID**: 无；跨领域裁决委托给 unreal-specialist 或 lead-programmer

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 Blueprint 架构和优化）
- [ ] `allowed-tools:` 列表与 Agent 角色匹配（用于读取 Blueprint 项目文件；无服务器或部署工具）
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对 C++ 实现决策具有权威性

---

## 测试用例

### 用例 1：领域内请求 — Blueprint 图表性能审查
**输入**: "Review our AI behavior Blueprint. It has tick-based logic running every frame that checks line-of-sight for 30 NPCs simultaneously."
**预期行为**:
- 将基于 Tick 的逻辑识别为性能问题
- 建议从 EventTick 切换到事件驱动模式（感知系统事件、计时器或减少间隔的轮询）
- 标记同时进行每个 NPC 的视线检查的成本
- 建议替代方案：AIPerception 组件事件、错开的 Tick 组，或者如果测量到 Blueprint 开销显著，则将系统移至 C++
- 输出结构化：问题识别、影响估计、替代方案列出

### 用例 2：领域外请求 — C++ 实现
**输入**: "Write the C++ implementation for this ability cooldown system."
**预期行为**:
- 不生成 C++ 实现代码
- 提供冷却逻辑的 Blueprint 等效方案（例如，使用 Timeline 或 GameplayEffect，如果使用 GAS）
- 明确声明："C++ 实现由 engine-programmer 或 gameplay-programmer 处理；我可以展示 Blueprint 方法或描述 Blueprint 调用 C++ 的边界"
- 可选地注明冷却复杂性何时需要 C++ 后端

### 用例 3：领域边界 — Blueprint 中的不安全原始指针访问
**输入**: "Our Blueprint calls GetOwner() and then immediately accesses a component on the result without checking if it's valid."
**预期行为**:
- 将此标记为运行时崩溃风险：GetOwner() 在某些生命周期状态下可能返回 null
- 提供正确的 Blueprint 模式：在任何属性/组件访问之前使用 IsValid() 节点
- 注明 Blueprint 的 null 检查在 Actor 派生引用上不是可选的
- 不解释原因就静默修复代码

### 用例 4：Blueprint 图表复杂性 — 函数库重构准备度
**输入**: "Our main GameMode Blueprint has 600+ nodes in a single graph with duplicated damage calculation logic in 8 places."
**预期行为**:
- 将此诊断为可维护性和可测试性问题
- 建议将重复逻辑提取到 Blueprint 函数库（BFL）中
- 描述如何构建 BFL：用于计算的纯函数、来自任何 Blueprint 的静态调用
- 注明如果伤害逻辑对性能敏感或与 C++ 共享，可能是迁移到 unreal-specialist 审查的候选者
- 输出是具体的重构计划，而不是模糊的建议

### 用例 5：上下文传递 — Blueprint 复杂性预算
**输入上下文**: 项目约定规定每个 Blueprint 事件图在强制函数库提取之前最多 100 个节点。
**输入**: "Here is our inventory Blueprint graph [150 nodes shown]. Is it ready to ship?"
**预期行为**:
- 引用项目约定中规定的 150 个节点数对比 100 个节点预算
- 标记图表超出复杂性阈值
- 不批准其当前状态
- 生成候选子图列表，用于函数库提取，以使主图在预算内

---

## 协议合规性

- [ ] 保持在声明的领域内（Blueprint 架构、性能、图表质量）
- [ ] 将 C++ 实现请求重定向到 engine-programmer 或 gameplay-programmer
- [ ] 返回结构化发现（问题/影响/替代方案格式）而不是自由形式的意见
- [ ] 主动强制执行 Blueprint 安全模式（null 检查、IsValid）
- [ ] 在评估图表复杂性时引用项目约定

---

## 覆盖范围说明
- 用例 3（null 指针安全）是安全关键测试 — 这是发布崩溃的常见来源
- 用例 5 要求项目约定包含规定的节点预算；如果未配置，Agent 应注明缺失并建议设置一个
- 无自动运行器；通过 `/skill-test` 手动审查