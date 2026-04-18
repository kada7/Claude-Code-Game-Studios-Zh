---
name: team-ui
description: "编排 UI 团队完成完整的 UX 流程:从 UX 规范编写到视觉设计、实现、审查和优化。与 /ux-design、/ux-review 和工作室 UX 模板集成。"
argument-hint: "[UI feature description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
调用此 skill 时，通过结构化流程编排 UI 团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示子代理的建议作为可选项。在对话中写入代理的完整分析，然后使用简洁的标签捕获决策。用户必须批准才能进入下一阶段。

## 团队组成
- **ux-designer** — 用户流程、线框图、无障碍性、输入处理
- **ui-programmer** — UI 框架、屏幕、小部件、数据绑定、实现
- **art-director** — 视觉风格、布局优化、与艺术圣经的一致性
- **engine UI specialist** — 根据引擎特定最佳实践验证 UI 实现模式 (从 `.claude/docs/technical-preferences.md` Engine Specialists → UI Specialist 读取)
- **accessibility-specialist** — 在阶段 4 审计无障碍性合规性

**此流程使用的模板:**
- `ux-spec.md` — 标准屏幕/流程 UX 规范
- `hud-design.md` — HUD 特定 UX 规范
- `interaction-pattern-library.md` — 可重用交互模式
- `accessibility-requirements.md` — 承诺的无障碍性层级和要求

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: ux-designer` — 用户流程、线框图、无障碍性、输入处理
- `subagent_type: ui-programmer` — UI 框架、屏幕、小部件、数据绑定
- `subagent_type: art-director` — 视觉风格、布局优化、艺术圣经一致性
- `subagent_type: [UI engine specialist]` — 引擎特定 UI 模式验证 (例如, unity-ui-specialist, ue-umg-specialist, godot-specialist)
- `subagent_type: accessibility-specialist` — 无障碍性合规审计

始终在代理的提示中提供完整上下文 (功能需求、现有 UI 模式、平台目标)。在流程允许的情况下并行启动独立代理 (例如，阶段 4 审查代理可以同时运行)。

## 流程

### 阶段 1a: 上下文收集

在设计任何内容之前，读取并综合:
- `design/gdd/game-concept.md` — 平台目标和预期受众
- `design/player-journey.md` — 玩家到达此屏幕时的状态和上下文
- 与此功能相关的所有 GDD UI 需求部分
- `design/ux/interaction-patterns.md` — 要重用的现有模式 (不重新发明)
- `design/accessibility-requirements.md` — 承诺的无障碍性层级 (例如, Basic, Enhanced, Full)

**如果 `design/ux/interaction-patterns.md` 不存在**，立即展示差距:
> "interaction-patterns.md 不存在 — 没有要重用的现有模式。"

然后使用 `AskUserQuestion` 提供选项:
- (a) 首先运行 `/ux-design patterns` 以建立模式库，然后继续
- (b) 在没有模式库的情况下继续 — ui-programmer 将所有创建的模式视为新的，并在完成时添加到新的 `design/ux/interaction-patterns.md`

不要仅从功能名称或 GDD 发明或假设模式。如果用户选择 (b)，在阶段 3 中明确指示 ui-programmer 将所有模式视为新的，并在实现完成时记录在 `design/ux/interaction-patterns.md` 中。在最终摘要报告中记录模式库状态 (已创建 / 缺失 / 已更新)。

为 ux-designer 总结上下文简报: 玩家在做什么、他们需要什么、应用什么约束以及哪些现有模式相关。

### 阶段 1b: UX 规范编写

调用 `/ux-design [feature name]` skill 或直接委派给 ux-designer 以生成遵循 `ux-spec.md` 模板的 `design/ux/[feature-name].md`。

如果设计 HUD，请改用 `hud-design.md` 模板。

> **特殊情况说明:**
> - 对于 HUD 设计，使用参数 `hud` 调用 `/ux-design` (例如, `/ux-design hud`)。
> - 对于交互模式库，在项目开始时运行一次 `/ux-design patterns`，并在以后阶段引入新模式时更新它。

输出: 填写所有必需规范部分的 `design/ux/[feature-name].md`。

### 阶段 1c: UX 审查

规范完成后，调用 `/ux-review design/ux/[feature-name].md`。

**门**: 在裁决为 APPROVED 之前不要进入阶段 2。如果裁决为 NEEDS REVISION，ux-designer 必须解决标记的问题并重新运行审查。用户可以明确接受 NEEDS REVISION 风险并继续，但这必须是有意识的决定 — 在询问是否继续之前，通过 `AskUserQuestion` 展示特定问题。

### 阶段 2: 视觉设计

委派给 **art-director**:
- 审查完整的 UX 规范 (流程、线框图、交互模式、无障碍性说明) — 不仅仅是线框图图像
- 应用艺术圣经中的视觉处理: 颜色、字体、间距、动画风格
- 检查视觉设计是否保持无障碍性合规性: 验证颜色对比度，并确认颜色从来不是状态的唯一指示器 (形状、文本或图标必须强化它)
- 指定艺术流程所需的所有资产要求: 指定尺寸的图标、背景纹理、字体、装饰元素 — 具有精确尺寸和格式要求
- 确保与现有已实现 UI 屏幕的一致性
- 输出: 带有风格说明和资产清单的视觉设计规范

### 阶段 3: 实现

在开始实现之前，生成 **engine UI specialist** (来自 `.claude/docs/technical-preferences.md` Engine Specialists → UI Specialist) 以审查 UX 规范和视觉设计规范，获取引擎特定实现指导:
- 应该为此屏幕使用哪个引擎 UI 框架? (例如，Unity 中的 UI Toolkit vs UGUI，Godot 中的 Control 节点 vs CanvasLayer，Unreal 中的 UMG vs CommonUI)
- 提议的布局或交互模式是否有任何引擎特定的陷阱?
- 引擎推荐的 widget/节点结构?
- 输出: 在 ui-programmer 开始前移交给他们的引擎 UI 实现说明

如果未配置引擎，跳过此步骤。

委派给 **ui-programmer**:
- 遵循 UX 规范和视觉设计规范实现 UI
- **使用 `design/ux/interaction-patterns.md` 中的模式** — 不重新发明已经指定的模式。如果模式几乎适合但需要修改，记录偏差并标记给 ux-designer 审查。
- **UI 永远不拥有或修改游戏状态** — 仅显示; 为所有玩家动作发出事件
- 所有文本通过本地化系统 — 没有硬编码的面向玩家的字符串
- 支持两种输入方式 (键盘/鼠标 AND 手柄)
- 根据 `design/accessibility-requirements.md` 中的承诺层级实现无障碍性功能
- 连接数据绑定到游戏状态
- **如果在实现期间创建了任何新的交互模式** (即，模式库中尚不存在的内容)，在标记实现完成之前将其添加到 `design/ux/interaction-patterns.md`
- 输出: 已实现的 UI 功能

### 阶段 4: 审查 (并行)

并行委派:
- **ux-designer**: 验证实现是否与线框图和交互规范匹配。测试纯键盘和纯手柄导航。检查无障碍性功能是否正确运行。
- **art-director**: 验证与艺术圣经的视觉一致性。检查最低和最高支持分辨率。
- **accessibility-specialist**: 根据 `design/accessibility-requirements.md` 中记录的承诺无障碍性层级验证合规性。将任何违规标记为阻止程序。

所有三个审查流必须在进入阶段 5 之前报告。

### 阶段 5: 优化

- 解决所有审查反馈
- 验证动画可跳过并尊重玩家的动作减少偏好
- 确认 UI 声音通过音频事件系统触发 (没有直接音频调用)
- 在所有支持的分辨率和宽高比下测试
- **验证 `design/ux/interaction-patterns.md` 是最新的** — 如果在此功能的实现期间引入了任何新模式，确认它们已添加到库中
- **确认所有 HUD 元素尊重 `design/ux/hud.md` 中定义的视觉预算** (元素计数、屏幕区域分配、最大不透明度值)

## 快速参考 — 何时使用哪个 Skill

- `/ux-design` — 从头开始为屏幕、流程或 HUD 编写新的 UX 规范
- `/ux-review` — 在实现前验证已完成的 UX 规范
- `/team-ui [feature]` — 从概念到优化的完整流程 (在内部调用 `/ux-design` 和 `/ux-review`)
- `/quick-design` — 不需要完整新 UX 规范的小 UI 更改

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

所有文件写入 (UX 规范、交互模式库更新、实现文件) 都委派给子代理和子技能 (`/ux-design`, `ui-programmer`)。每个都强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要报告: UX 规范状态、UX 审查裁决、视觉设计状态、实现状态、无障碍性合规性、输入方法支持、交互模式库更新状态以及任何未解决问题。

裁决: **COMPLETE** — UI 功能通过完整流程交付 (UX 规范 → 视觉 → 实现 → 审查 → 优化)。
裁决: **BLOCKED** — 流程停止; 展示阻止程序及其阶段然后停止。

## 后续步骤

- 如果尚未批准，对最终规范运行 `/ux-review`。
- 在关闭 stories 之前对 UI 实现运行 `/code-review`。
- 如果需要视觉或音频优化，运行 `/team-polish`。
