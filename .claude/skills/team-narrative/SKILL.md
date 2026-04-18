---
name: team-narrative
description: "Orchestrate the narrative team: coordinates narrative-director, writer, world-builder, and level-designer to create cohesive story content, world lore, and narrative-driven level design."
argument-hint: "[narrative content description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion, TodoWrite
---
如果没有提供参数，输出使用指南并退出而不生成任何代理:
> Usage: `/team-narrative [narrative content description]` — 描述要处理的故事内容、场景或叙事区域 (例如, `boss encounter cutscene`, `faction intro dialogue`, `tutorial narrative`)。不要在此处使用 `AskUserQuestion`; 直接输出指南。

当使用参数调用此 skill 时，通过结构化流程编排叙事团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一阶段。

## 团队组成
- **narrative-director** — 故事弧线、角色设计、对话策略、叙事愿景
- **writer** — 对话编写、传说条目、物品描述、游戏内文本
- **world-builder** — 世界规则、派系设计、历史、地理、环境叙事
- **art-director** — 角色视觉设计、环境视觉叙事、过场动画/电影基调
- **level-designer** — 服务于叙事的关卡布局、节奏、环境叙事节拍

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: narrative-director` — 故事弧线、角色设计、叙事愿景
- `subagent_type: writer` — 对话编写、传说条目、游戏内文本
- `subagent_type: world-builder` — 世界规则、派系设计、历史、地理
- `subagent_type: art-director` — 角色视觉配置文件、环境视觉叙事、电影基调
- `subagent_type: level-designer` — 服务于叙事的关卡布局、节奏
- `subagent_type: localization-lead` — i18n 验证、字符串键合规性、翻译余量

始终在代理的提示中提供完整上下文 (叙事简报、传说依赖关系、角色配置文件)。在流程允许的情况下并行启动独立代理 (例如，阶段 2 代理可以同时运行)。

## 流程

### 阶段 1: 叙事指导
委派给 **narrative-director**:
- 定义此内容的叙事目的: 它服务于什么故事节拍?
- 识别涉及的角色、他们的动机以及这如何融入整体弧线
- 设置情感基调和节奏目标
- 指定任何传说依赖关系或此介绍的新传说
- 输出: 包含故事要求的叙事简报

### 阶段 2: 世界基础 (并行)
并行委派 — 在等待任何结果之前同时发出所有三个 Task 调用:
- **world-builder**: 创建或更新与此内容相关的派系、地点和历史的传说条目。对照现有传说检查矛盾。为新条目设置正典级别。
- **writer**: 使用声音配置文件起草角色对话。确保所有行少于 120 个字符，对变量使用命名占位符，并准备好本地化。
- **art-director**: 定义此内容中出现的关键角色的角色视觉设计方向 (剪影、视觉原型、区分特征)。为每个关键空间指定环境视觉叙事元素 (道具组合、光照说明、空间安排)。为任何过场动画或脚本序列定义色调色板和电影指导。

### 阶段 3: 关卡叙事集成
委派给 **level-designer**:
- 审查叙事简报和传说基础
- 设计关卡中的环境叙事元素
- 放置叙事触发器、对话区域和发现点
- 确保节奏同时服务于游戏玩法和故事

### 阶段 4: 审查和一致性
委派给 **narrative-director**:
- 对照角色声音配置文件审查所有对话
- 验证新旧条目之间的传说一致性
- 确认叙事节奏与关卡设计对齐
- 检查所有谜题是否有记录的"真实答案"

### 阶段 5: 润色 (并行)
并行委派:
- **writer**: 最终自我审查 — 验证没有行超过对话框约束，所有文本使用字符串键 (而非原始字符串)，占位符变量名称一致
- **localization-lead**: 验证 i18n 合规性 — 检查字符串键命名约定，标记任何带有硬编码格式的字符串，这些格式在翻译后无法保留，验证扩展语言的字符限制余量 (德语/芬兰语通常 +30%)，确认文本中没有需要区域特定变体的文化假设
- **world-builder**: 为所有新传说条目最终确定正典级别

## 错误恢复协议

如果任何生成的代理 (通过 Task) 返回 BLOCKED、错误或无法完成:

1. **立即展示**: 在向用户报告 "[AgentName]: BLOCKED — [reason]"，然后继续到依赖阶段
2. **评估依赖关系**: 检查被阻止代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点。
3. **提供选项** 通过 AskUserQuestion 提供选择:
   - 跳过此代理并记录最终报告中的差距
   - 以更窄的范围重试
   - 在此处停止并首先解决阻止程序
4. **始终生成部分报告** — 输出已完成的内容。切勿因为代理被阻止而丢弃工作。

常见阻止程序:
- 输入文件缺失 (story 未找到, GDD 不存在) → 重定向到创建它的 skill
- ADR 状态为 Proposed → 不实现; 先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个 stories
- ADR 和 story 之间的冲突说明 → 展示冲突，不要猜测

## 文件写入协议

所有文件写入 (叙事文档、对话文件、传说条目) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要报告: 叙事简报状态、创建/更新的传说条目、编写的对话行、关卡叙事集成点、一致性审查结果以及任何未解决的矛盾。

裁决: **COMPLETE** — 叙事内容已交付。

如果流程因依赖项未解决而停止 (例如，用户未解决的传说矛盾或缺失先决条件):

裁决: **BLOCKED** — [reason]

## 后续步骤

- 对叙事文档运行 `/design-review` 以进行一致性验证。
- 对话最终确定后运行 `/localize extract` 以提取新字符串进行翻译。
- 运行 `/dev-story` 以在引擎中实现对话触发器和叙事事件。
