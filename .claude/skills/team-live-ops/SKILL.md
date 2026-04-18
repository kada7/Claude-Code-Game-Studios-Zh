---
name: team-live-ops
description: "Orchestrate the live-ops team for post-launch content planning: coordinates live-ops-designer, economy-designer, analytics-engineer, community-manager, writer, and narrative-director to design and plan a season, event, or live content update."
argument-hint: "[season name or event description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
**参数检查:** 如果没有提供赛季名称或事件描述，输出:
> "Usage: `/team-live-ops [season name or event description]` — 提供要规划的赛季或实时事件的名称或描述。"
然后立即停止而不生成任何子代理或读取任何文件。

当使用有效参数调用此 skill 时，通过结构化规划流程编排实时运营团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一阶段。

## 团队组成
- **live-ops-designer** — 赛季结构、事件节奏、留存机制、战斗通行证
- **economy-designer** — 实时经济平衡、商店轮换、货币定价、保底机制
- **analytics-engineer** — 成功指标、A/B 测试设计、事件追踪、仪表板规范
- **community-manager** — 面向玩家的公告、事件描述、赛季消息传递
- **narrative-director** — 赛季叙事主题、故事弧线、世界事件框架
- **writer** — 事件描述、奖励物品名称、赛季风味文本、公告文案

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: live-ops-designer` — 赛季/事件结构和留存机制
- `subagent_type: economy-designer` — 实时经济平衡和奖励定价
- `subagent_type: analytics-engineer` — 成功指标、A/B 测试、事件工具
- `subagent_type: community-manager` — 面向玩家的沟通和消息传递
- `subagent_type: narrative-director` — 赛季主题和叙事框架
- `subagent_type: writer` — 所有面向玩家的文本: 事件描述、物品名称、文案

始终在代理的提示中提供完整上下文 (游戏概念路径、现有赛季文档、伦理政策路径、当前经济状态)。在流程允许的情况下并行启动独立代理 (阶段 3 和 4 可以同时运行)。

## 流程

### 阶段 1: 赛季/事件范围界定
委派给 **live-ops-designer**:
- 定义赛季或事件: 类型 (赛季性、限时事件、挑战)、持续时间、主题方向
- 概述内容列表: 新增内容 (模式、物品、挑战、故事节拍)
- 定义留存钩子: 在本赛季期间什么让玩家每日/每周回归
- 识别资源预算: 需要创建多少新内容与重用
- 输出: 赛季简报，包含范围、内容列表和留存机制概述

### 阶段 2: 叙事主题
委派给 **narrative-director**:
- 从阶段 1 读取赛季简报
- 设计赛季叙事主题: 此事件如何与游戏世界连接?
- 定义玩家将在事件期间发现的中心故事钩子
- 识别本赛季可以推进的现有传说线索
- 输出: 叙事框架文档 (主题、故事钩子、传说连接)

### 阶段 3: 经济设计 (如果主题明确，与阶段 2 并行)
委派给 **economy-designer**:
- 从 `design/live-ops/economy-rules.md` 读取赛季简报和现有经济规则
- 设计奖励轨道: 免费层级进度、高级层级价值主张
- 规划赛季内经济: 赛季货币、商店轮换、定价
- 为任何随机元素定义保底机制和坏运气保护
- 验证高级轨道中没有付费获胜物品
- 输出: 经济设计文档，包含奖励表、定价和货币流

### 阶段 4: 分析和成功指标 (与阶段 3 并行)
委派给 **analytics-engineer**:
- 读取赛季简报
- 定义成功指标: 参与率目标、留存提升目标、战斗通行证完成率
- 设计本赛季期间运行的任何 A/B 测试 (例如，不同的奖励节奏)
- 指定本赛季内容所需的新遥测事件
- 输出: 包含成功标准和工具要求的分析计划

### 阶段 5: 内容编写 (并行)
并行委派:
- **narrative-director** (如果需要): 为赛季编写任何游戏内叙事文本 (过场动画脚本、NPC 对话、世界事件描述)
- **writer**: 编写所有面向玩家的文本 — 事件名称、奖励物品描述、挑战目标文本、赛季风味文本
- 两者都应从阶段 2 读取叙事框架文档

### 阶段 6: 玩家沟通计划
委派给 **community-manager**:
- 从阶段 1-3 读取赛季简报、经济设计和叙事框架
- 起草赛季发布公告 (基调、关键亮点、平台特定版本)
- 规划沟通节奏: 发布前预告、发布日帖子、赛季中提醒、最后一周 FOMO 推送
- 为第一天补丁说明起草已知问题部分占位符
- 输出: 每个接触点的沟通日历及草稿文案

### 阶段 7: 审查和签署
收集所有阶段的输出并展示综合赛季计划:
- 赛季简报 (阶段 1)
- 叙事框架 (阶段 2)
- 经济设计和奖励表 (阶段 3)
- 分析计划和成功指标 (阶段 4)
- 编写的内容清单 (阶段 5)
- 沟通日历 (阶段 6)

向用户展示摘要:
- **内容范围**: 正在创建什么
- **经济健康检查**: 奖励轨道是否感觉公平且非掠夺性?
- **分析准备**: 成功标准是否已定义和工具化?
- **伦理审查**: 对照 `design/live-ops/ethics-policy.md` 检查阶段 3 经济设计
  - 如果文件不存在: 标记 "ETHICS REVIEW SKIPPED: `design/live-ops/ethics-policy.md` 未找到。经济设计未针对伦理政策进行审查。建议在生产开始前创建一个。" 在赛季设计输出文档中包含此标记。添加到后续步骤: 创建 `design/live-ops/ethics-policy.md`。
  - 如果文件存在且发现违规: 标记 "ETHICS FLAG: 阶段 3 经济设计中的 [element] 违反 [policy rule]。在解决之前阻止批准。" 不要发出 COMPLETE 裁决或写入输出文档。使用 `AskUserQuestion` 提供选项: 修改经济设计 / 用文档化的理由覆盖 / 取消。如果用户选择修改: 重新生成 economy-designer 以产生修正的设计，然后返回阶段 7 审查。
- **开放问题**: 生产开始前仍需要的决策

要求用户在委派给生产团队之前批准赛季计划。仅在用户批准后且没有未解决的伦理违规时发出 COMPLETE 裁决。如果伦理违规未解决，以裁决: **BLOCKED** 结束。

## 输出文档

所有文档保存到 `design/live-ops/`:
- `seasons/S[N]_[name].md` — 赛季设计文档 (来自阶段 1-3)
- `seasons/S[N]_[name]_analytics.md` — 分析计划 (来自阶段 4)
- `seasons/S[N]_[name]_comms.md` — 沟通日历 (来自阶段 6)

## 错误恢复协议

如果任何生成的代理 (通过 Task) 返回 BLOCKED、错误或无法完成:

1. **立即展示**: 在向用户报告 "[AgentName]: BLOCKED — [reason]"，然后继续到依赖阶段
2. **评估依赖关系**: 检查被阻止代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点。
3. **提供选项** 通过 AskUserQuestion 提供选择:
   - 跳过此代理并记录最终报告中的差距
   - 以更窄的范围重试
   - 在此处停止并首先解决阻止程序
4. **始终生成部分报告** — 输出已完成的内容。切勿因为代理被阻止而丢弃工作。

如果 BLOCKED 状态无法解决，以裁决: **BLOCKED** 而非 COMPLETE 结束。

## 文件写入协议

所有文件写入 (赛季设计文档、分析计划、沟通日历) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要: 赛季主题和范围、经济设计亮点、成功指标、内容列表、沟通计划以及生产前需要用户输入的任何开放决策。

裁决: **COMPLETE** — 赛季计划已生成并移交给生产。

## 后续步骤

- 对赛季设计文档运行 `/design-review` 以进行一致性验证。
- 运行 `/sprint-plan` 以安排赛季的内容创建工作。
- 赛季内容准备好部署时运行 `/team-release`。
