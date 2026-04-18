# Agent 测试规范：technical-director

## Agent 概览
**负责领域：** 系统架构决策、技术可行性评估、ADR 监督与批准、引擎风险评估、技术阶段门。
**不负责：** 游戏设计决策（creative-director / game-designer）、创意指导、视觉艺术风格、制作排期（producer）。
**模型层级：** Opus（多文档综合、高风险架构和阶段门裁决）。
**处理的 Gate ID：** TD-SYSTEM-BOUNDARY、TD-FEASIBILITY、TD-ARCHITECTURE、TD-ADR、TD-ENGINE-RISK、TD-PHASE-GATE。

---

## 静态断言（结构）

通过读取 agent 的 `.claude/agents/technical-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且是领域特定的（涉及架构、可行性、ADR —— 非通用描述）
- [ ] `allowed-tools:` 列表可能包含用于架构文档的 Read；仅当技术检查需要时才包含 Bash
- [ ] 模型层级为 `claude-opus-4-6`（根据 coordination-rules.md，具有门综合能力的 directors 使用 Opus）
- [ ] Agent 定义不宣称对游戏设计决策或创意指导拥有权限

---

## 测试用例

### 用例 1：领域内请求 —— 适当的输出格式
**场景：** 提交 "Combat System" 的架构文档。它描述了一个分层设计：输入层 → 游戏逻辑层 → 表示层，每一层之间有明确定义的接口。请求标记为 TD-ARCHITECTURE。
**预期：** 返回 `TD-ARCHITECTURE: APPROVE`，并给出理由，确认系统边界正确分离且接口定义良好。
**断言：**
- [ ] 裁决正好是 APPROVE / CONCERNS / REJECT 之一
- [ ] 裁决标记格式为 `TD-ARCHITECTURE: APPROVE`
- [ ] 理由具体引用分层结构和接口定义 —— 而非通用的架构建议
- [ ] 输出保持在技术范围内 —— 不评论机制是否有趣或是否符合创意愿景

### 用例 2：领域外请求 —— 重定向或升级
**场景：** 编剧要求 technical-director 审查并批准游戏开场过场动画的对话脚本。
**预期：** Agent 拒绝评估对话质量，并重定向到 narrative-director。
**断言：**
- [ ] 不做出任何关于对话内容或结构的约束性决定
- [ ] 明确命名 `narrative-director` 为正确的处理者
- [ ] 可以指出影响对话的技术约束（例如，本地化字符串限制、数据格式），但推迟所有内容决策

### 用例 3：Gate 裁决 —— 正确的词汇
**场景：** 一个提议的多人游戏机制需要在每一帧对所有活动实体进行射线投射以检测视线。在预期玩家数量（大区域中 1000 个实体）下，这是每帧 O(n²) 的复杂度。请求标记为 TD-FEASIBILITY。
**预期：** 返回 `TD-FEASIBILITY: CONCERNS`，并具体引用 O(n²) 复杂度以及使该实现在目标帧率下不可行的实体数量阈值。
**断言：**
- [ ] 裁决正好是 APPROVE / CONCERNS / REJECT 之一 —— 非自由格式文本
- [ ] 裁决标记格式为 `TD-FEASIBILITY: CONCERNS`
- [ ] 理由包括特定的算法复杂度担忧和实体数量阈值
- [ ] 提出至少一种替代方法（例如，空间分区、兴趣度管理），但不强制选择哪一种

### 用例 4：冲突升级 —— 正确的上级
**场景：** game-designer 希望为每个库存物品（屏幕上同时存在数百个物品）添加实时物理模拟。technical-director 评估这在技术上成本高昂，并提出简化模拟。game-designer 不同意，认为这对游戏感觉至关重要。
**预期：** technical-director 清晰说明技术成本和约束，提出可实现类似感觉的替代实现方法，但明确将最终设计优先级决策交给 creative-director，作为玩家体验权衡的仲裁者。
**断言：**
- [ ] 具体表达技术担忧（例如，性能预算、预估成本）
- [ ] 提出至少一种能降低成本同时保留意图的替代方案
- [ ] 明确将 "是否值得付出此成本" 的决策交给 creative-director —— 不单方面削减功能
- [ ] 不宣称有权推翻 game-designer 的设计意图

### 用例 5：上下文传递 —— 使用提供的上下文
**场景：** Agent 接收一个 gate 上下文块，其中包含目标平台约束：移动设备、60fps 目标、2GB RAM 上限、无计算着色器。一个提议的架构包含 GPU 驱动的渲染管线。
**预期：** 评估引用上下文中的特定硬件约束，将计算着色器依赖识别为与所述平台约束不兼容，并返回 CONCERNS 或 REJECT 裁决，并引用这些具体点。
**断言：**
- [ ] 引用所提供的特定平台约束（移动设备、2GB RAM、无计算着色器）
- [ ] 不给出与所提供的约束无关的通用性能建议
- [ ] 正确识别与平台约束冲突的架构组件
- [ ] 裁决理由与提供的上下文相关联，而非样板警告

---

## 协议合规性

- [ ] 仅使用 APPROVE / CONCERNS / REJECT 词汇返回裁决
- [ ] 保持在声明的技术领域内
- [ ] 将设计优先级冲突交给 creative-director 处理
- [ ] 在输出中使用 gate ID（例如 `TD-FEASIBILITY: CONCERNS`），而非内嵌散文裁决
- [ ] 不做出约束性的游戏设计或创意指导决策

---

## 覆盖范围说明
- TD-ADR（架构决策记录批准）未覆盖 —— 当 /architecture-decision 技能生成 ADR 文档时，应添加专用用例。
- 针对特定引擎版本（例如，Godot 4.6 截止后 API）的 TD-ENGINE-RISK 评估未覆盖 —— 推迟到引擎专家集成测试。
- TD-PHASE-GATE（完整技术阶段推进）涉及综合多个子门结果的情况推迟处理。
- 多领域架构审查（例如，同时涉及 TD-ARCHITECTURE 和 TD-ENGINE-RISK）未覆盖在此处。