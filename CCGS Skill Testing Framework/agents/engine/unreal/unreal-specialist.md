# Agent Test Spec: unreal-specialist

## Agent 摘要
- **领域**: Unreal Engine 模式和架构 — Blueprint 与 C++ 决策、UE 子系统（GAS、Enhanced Input、Niagara）、UE 项目结构、插件集成和引擎级配置
- **不负责**: 艺术风格和视觉方向（art-director）、服务器基础设施和部署（devops-engineer）、UI/UX 流程设计（ux-designer）
- **模型层级**: Sonnet
- **Gate ID**: 无；将 gate 裁决委托给 technical-director

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 Unreal Engine）
- [ ] `allowed-tools:` 列表与 Agent 角色匹配（UE 项目文件的 Read、Write；无部署工具）
- [ ] 模型层级为 Sonnet（专家的默认设置）
- [ ] Agent 定义不声明其声明领域之外的权限（无艺术、无服务器基础设施）

---

## 测试用例

### 用例 1: 领域内请求 — Blueprint 与 C++ 决策标准
**输入**: "我应该将我们的连击攻击系统实现在 Blueprint 还是 C++ 中？"
**预期行为**:
- 提供结构化的决策标准：复杂性、重用频率、团队技能和性能要求
- 对于每帧调用的系统或跨 5+ 种能力类型共享的系统，推荐使用 C++
- 对于设计师可调的值和一次性逻辑，推荐使用 Blueprint
- 在不了解项目上下文的情况下不做出最终裁决 — 如果缺少上下文，会询问澄清问题
- 输出是结构化的（标准表格或项目符号列表），而不是自由形式的意见

### 用例 2: 领域外请求 — Unity C# 代码
**输入**: "为我编写一个处理玩家生命值并在死亡时触发 Unity 事件的 C# MonoBehaviour。"
**预期行为**:
- 不生成 Unity C# 代码
- 明确声明："此项目使用 Unreal Engine；Unity 的等效物将是 UE C++ 中的 Actor Component 或 Blueprint Actor Component"
- 如果被请求，可选择提供 UE 等效物
- 不重定向到 Unity 专家（框架中不存在）

### 用例 3: 领域边界 — UE5.4 API 要求
**输入**: "我需要使用 UE5.4 中引入的新 Motion Matching API。"
**预期行为**:
- 标记 UE5.4 是一个特定版本，可能具有有限的 LLM 训练覆盖范围
- 在信任任何 API 建议之前，建议交叉参考官方 Unreal 文档或项目的 engine-reference 目录
- 提供尽力而为的 API 指导，并带有明确的不确定性标记（例如，"请根据 UE5.4 发布说明验证此内容"）
- 不会在没有警告的情况下静默生成过时或不正确的 API 签名

### 用例 4: 冲突 — 核心系统中的 Blueprint 混乱
**输入**: "我们的复制逻辑完全在一个深度嵌套的 Blueprint 事件图中，包含 300+ 个节点且没有函数。它正变得难以维护。"
**预期行为**:
- 将此识别为 Blueprint 架构问题，而不是次要的风格问题
- 建议将核心复制逻辑迁移到 C++ ActorComponent 或 GameplayAbility 系统
- 注意所需的协调：复制架构的更改必须涉及 lead-programmer
- 不会在没有向用户展示重构范围的情况下单方面声明"迁移到 C++"
- 产生具体的迁移建议，而不是模糊的建议

### 用例 5: 上下文传递 — 版本适当的 API 建议
**输入上下文**: 项目 engine-reference 文件声明使用 Unreal Engine 5.3。
**输入**: "如何为新角色设置 Enhanced Input 动作？"
**预期行为**:
- 使用 UE5.3 时代的 Enhanced Input API（InputMappingContext、UEnhancedInputComponent::BindAction）
- 不会引用 UE5.3 之后引入的 API，除非标记它们为可能不可用
- 在其响应中引用项目声明的引擎版本
- 提供具体的、版本锚定的代码或 Blueprint 节点名称

---

## 协议合规性

- [ ] 保持在声明的领域内（Unreal 模式、Blueprint/C++、UE 子系统）
- [ ] 重定向 Unity 或其他引擎的请求，而不生成错误引擎的代码
- [ ] 返回结构化的发现（标准表格、决策树、迁移计划）而不是自由形式的意见
- [ ] 在生成 API 建议之前明确标记版本不确定性
- [ ] 与 lead-programmer 协调进行架构规模的重构，而不是单方面决定

---

## 覆盖范围说明
- 不存在用于 Agent 行为测试的自动化运行器 — 这些通过手动或通过 `/skill-test` 进行审查
- 版本意识（用例 3、用例 5）是该 Agent 的最高风险故障模式；当引擎版本更改时定期测试
- 用例 4 与 lead-programmer 的集成是协调测试，而不是技术正确性测试