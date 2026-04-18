---
name: team-combat
description: "Orchestrate the combat team: coordinates game-designer, gameplay-programmer, ai-programmer, technical-artist, sound-designer, and qa-tester to design, implement, and validate a combat feature end-to-end."
argument-hint: "[combat feature description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
**参数检查:** 如果没有提供战斗功能描述，输出:
> "Usage: `/team-combat [combat feature description]` — 提供要设计和实现的战斗功能描述 (例如, `melee parry system`, `ranged weapon spread`)。"
然后立即停止而不生成任何子代理或读取任何文件。

当使用有效参数调用此 skill 时，通过结构化流程编排战斗团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一阶段。

## 团队组成
- **game-designer** — 设计机制，定义公式和边界情况
- **gameplay-programmer** — 实现核心游戏玩法代码
- **ai-programmer** — 为功能实现 NPC/敌人 AI 行为
- **technical-artist** — 创建 VFX、着色器效果和视觉反馈
- **sound-designer** — 定义音频事件、打击声音和环境战斗音频
- **engine specialist** (primary) — 验证架构和实现模式对于引擎是否符合习惯 (从 `.claude/docs/technical-preferences.md` Engine Specialists 部分读取)
- **qa-tester** — 编写测试用例并验证实现

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: game-designer` — 设计机制，定义公式和边界情况
- `subagent_type: gameplay-programmer` — 实现核心游戏玩法代码
- `subagent_type: ai-programmer` — 实现 NPC/敌人 AI 行为
- `subagent_type: technical-artist` — 创建 VFX、着色器效果、视觉反馈
- `subagent_type: sound-designer` — 定义音频事件、打击声音、环境音频
- `subagent_type: [primary engine specialist]` — 验证架构和实现的引擎习惯用法
- `subagent_type: qa-tester` — 编写测试用例并验证实现

始终在代理的提示中提供完整上下文 (设计文档路径、相关代码文件、约束)。在流程允许的情况下并行启动独立代理 (例如，阶段 3 代理可以同时运行)。

## 流程

### 阶段 1: 设计
委派给 **game-designer**:
- 在 `design/gdd/` 中创建或更新设计文档，涵盖: 机制概述、玩家幻想、详细规则、带变量定义的公式、边界情况、依赖关系、带安全范围的调整旋钮和验收标准
- 输出: 完成的设计文档

### 阶段 2: 架构
委派给 **gameplay-programmer** (如果涉及 AI，则与 **ai-programmer** 一起):
- 审查设计文档
- 设计代码架构: 类结构、接口、数据流
- 识别与现有系统的集成点
- 输出: 架构草图及文件列表和接口定义

然后生成 **primary engine specialist** 以验证提议的架构:
- 类/节点/组件结构对于固定引擎是否符合习惯? (例如, Godot 节点层次结构, Unity MonoBehaviour vs DOTS, Unreal Actor/Component 设计)
- 是否应该使用引擎原生系统而不是自定义实现?
- 固定引擎版本中是否有任何提议的 API 已弃用或更改?
- 输出: 引擎架构说明 — 在阶段 3 开始前纳入架构

### 阶段 3: 实现 (尽可能并行)
并行委派:
- **gameplay-programmer**: 实现核心战斗机制代码
- **ai-programmer**: 实现 AI 行为 (如果功能涉及 NPC 反应)
- **technical-artist**: 创建 VFX 和着色器效果
- **sound-designer**: 定义音频事件列表和混音说明

### 阶段 4: 集成
- 将游戏玩法代码、AI、VFX 和音频连接在一起
- 确保所有调整旋钮都暴露且数据驱动
- 验证功能与现有战斗系统协同工作

### 阶段 5: 验证
委派给 **qa-tester**:
- 从验收标准编写测试用例
- 测试设计中记录的所有边界情况
- 验证性能影响在预算内
- 为发现的任何问题提交 bug 报告

### 阶段 6: 签署
- 收集所有团队成员的结果
- 报告功能状态: COMPLETE / NEEDS WORK / BLOCKED
- 列出任何未解决问题及其分配的所有者

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

所有文件写入 (设计文档、实现文件、测试用例) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 
协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要报告: 设计完成状态、每个团队成员的实现状态、测试结果和任何开放问题。

裁决: **COMPLETE** — 战斗功能已设计、实现和验证。
裁决: **BLOCKED** — 一个或多个阶段无法完成; 生成部分报告并列出未解决的项目。

## 后续步骤

- 在关闭 stories 之前对实现的战斗代码运行 `/code-review`。
- 运行 `/balance-check` 以验证战斗公式和调整值。
- 如果需要 VFX、音频或性能优化，运行 `/team-polish`。
