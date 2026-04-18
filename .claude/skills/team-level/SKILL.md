---
name: team-level
description: "Orchestrate level design team: level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester for complete area/level creation."
argument-hint: "[level name or area to design]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---

当调用此 skill 时:

**决策点:** 在每个步骤转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一步。

1. **读取参数** 以获取目标关卡或区域 (例如, `tutorial`,
   `forest dungeon`, `hub town`, `final boss arena`)。

2. **收集上下文**:
   - 读取 `design/gdd/game-concept.md` 的游戏概念
   - 读取 `design/gdd/game-pillars.md` 的游戏支柱
   - 读取 `design/levels/` 中的现有关卡文档
   - 读取 `design/narrative/` 中的相关叙事文档
   - 读取区域区域/派系的 world-building 文档

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: narrative-director` — 叙事目的、角色、情感弧线
- `subagent_type: world-builder` — 传说上下文、环境叙事、世界规则
- `subagent_type: level-designer` — 空间布局、节奏、遭遇、导航
- `subagent_type: systems-designer` — 敌人组成、战利品表、难度平衡
- `subagent_type: art-director` — 视觉主题、调色板、光照、资产需求
- `subagent_type: accessibility-specialist` — 导航清晰度、色盲安全、认知负荷
- `subagent_type: qa-tester` — 测试用例、边界测试、游戏测试清单

始终在代理的提示中提供完整上下文 (游戏概念、支柱、现有关卡文档、叙事文档)。

3. **编排关卡设计团队** 按顺序:

### 步骤 1: 叙事 + 视觉指导 (并行: narrative-director + world-builder + art-director)

同时生成所有三个代理 — 在等待任何结果之前发出所有三个 Task 调用。

生成 `narrative-director` 代理以:
- 定义此区域的叙事目的 (这里发生什么故事节拍?)
- 识别关键角色、对话触发器和传说元素
- 指定情感弧线 (玩家进入时、期间、离开时应该感觉如何?)

生成 `world-builder` 代理以:
- 提供此区域的传说上下文 (历史、派系存在、生态)
- 定义环境叙事机会
- 指定影响此区域游戏玩法的任何世界规则

生成 `art-director` 代理以:
- 为此区域建立视觉主题目标 — 这些是布局的 INPUTS，而非输出
- 定义此区域的色温和光照氛围 (它与相邻区域有何不同?)
- 指定形状语言方向 (角形堡垒? 有机洞穴? 衰败的宏伟?)
- 命名将引导玩家的主要视觉地标
- 如果存在，读取 `design/art/art-bible.md` — 将方向锚定在已建立的艺术圣经中

**步骤 1 的 art-director 视觉目标必须在步骤 2 传递给 level-designer** 作为显式约束。布局决策在视觉方向内发生，而非之前。

**门**: 使用 `AskUserQuestion` 展示所有三个步骤 1 输出 (叙事简报、传说基础、视觉指导目标) 并在进入步骤 2 前确认。

### 步骤 2: 布局和遭遇设计 (level-designer)
使用完整的步骤 1 输出作为上下文生成 `level-designer` 代理:
- 叙事简报 (来自 narrative-director)
- 传说基础 (来自 world-builder)
- **视觉指导目标 (来自 art-director)** — 布局必须在这些目标内工作，而非与它们矛盾

level-designer 应该:
- 设计空间布局 (关键路径、可选路径、秘密) — 确保主要路线与步骤 1 的视觉地标目标对齐
- 定义节奏曲线 (紧张峰值、休息区、探索区) — 与 narrative-director 的情感弧线协调
- 放置具有难度进展的遭遇
- 设计环境谜题或导航挑战
- 定义兴趣点和寻路地标 — 这些必须与 art-director 指定的视觉地标匹配
- 指定进入/退出点和与相邻区域的连接

**相邻区域依赖检查**: 布局生成后，检查 level-designer 引用的每个相邻区域的 `design/levels/`。如果任何引用区域的 `.md` 文件不存在，展示差距:
> "Level 引用 [area-name] 作为相邻区域但 `design/levels/[area-name].md` 不存在。"

使用 `AskUserQuestion` 提供选项:
- (a) 使用占位符引用继续 — 在关卡文档中将连接标记为 UNRESOLVED 并在摘要报告的开放跨关卡依赖部分列出
- (b) 暂停并首先运行 `/team-level [area-name]` 以建立该区域

不要为缺失的相邻区域编造内容。

**门**: 使用 `AskUserQuestion` 展示步骤 2 布局 (包括任何未解决的相邻区域依赖) 并在进入步骤 3 前确认。

### 步骤 3: 系统集成 (systems-designer)
生成 `systems-designer` 代理以:
- 指定敌人组成和遭遇公式
- 定义战利品表和奖励放置
- 相对于预期玩家等级/装备平衡难度
- 设计任何区域特定机制或环境危险
- 指定资源分配 (生命拾取、保存点、商店)

**门**: 使用 `AskUserQuestion` 展示步骤 3 输出并在进入步骤 4 前确认。

### 步骤 4: 生产概念 + 无障碍 (并行: art-director + accessibility-specialist)

**注意**: art-director 的方向通过 (视觉主题、颜色目标、氛围) 发生在步骤 1。此通过是位置特定的生产概念 — 给定最终确定的布局，每个特定空间看起来如何?

使用步骤 2 的最终确定布局生成 `art-director` 代理:
- 为关键空间生成位置特定的概念规范 (入口、关键遭遇区、地标、出口)
- 指定哪些艺术资产对此区域是唯一的 vs 来自全局池的共享
- 定义每个关键空间的视线和光照设置 (这些现在由布局通知，而非方向性的)
- 指定此区域布局特定的 VFX 需求 (天气体积、粒子、大气效果)
- 标记布局创建与步骤 1 目标的视觉方向冲突的任何位置 — 将这些作为生产风险展示

并行生成 `accessibility-specialist` 代理以:
- 审查关卡布局的导航清晰度 (玩家能否在不依赖颜色的情况下定位自己?)
- 检查关键路径路标是否使用形状/图标/声音提示以及颜色
- 审查任何谜题机制的认知负荷 — 标记任何需要同时保持超过 3 个状态的
- 检查关键游戏玩法区域是否有足够的对比度供色盲玩家使用
- 输出: 带有严重度 (BLOCKING / RECOMMENDED / NICE TO HAVE) 的无障碍问题列表

在继续前等待两个代理返回。

**门**: 使用 `AskUserQuestion` 展示两个步骤 4 结果。如果 accessibility-specialist 返回任何 BLOCKING 问题，突出显示并提供:
- (a) 返回 level-designer 和 art-director 以在步骤 5 前重新设计标记的元素
- (b) 记录为已知的无障碍差距并使用最终报告中明确记录的问题进入步骤 5

不要在用户确认任何 BLOCKING 无障碍问题的情况下进入步骤 5。

### 步骤 5: QA 规划 (qa-tester)
生成 `qa-tester` 代理以:
- 为关键路径编写测试用例
- 识别边界和边界情况 (序列中断、软锁)
- 创建区域的游戏测试清单
- 定义关卡完成的验收标准

4. **编译关卡设计文档** 将所有团队输出结合到
   关卡设计模板格式中。

5. **保存到** `design/levels/[level-name].md`。

6. **输出摘要** 包括: 区域概述、遭遇计数、估计资产
   列表、叙事节拍、任何跨团队依赖或开放问题、开放
   跨关卡依赖 (引用但尚未设计的相邻区域，每个
   标记为 UNRESOLVED) 及其解决状态的无障碍问题。

## 文件写入协议

所有文件写入 (关卡设计文档、叙事文档、测试清单) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 
协议。此编排器不直接写入文件。

裁决: **COMPLETE** — 关卡设计文档已生成，所有团队输出已编译。
裁决: **BLOCKED** — 一个或多个代理被阻止; 生成部分报告并列出未解决的项目。

## 后续步骤

- 运行 `/design-review design/levels/[level-name].md` 以验证已完成的关卡设计文档。
- 设计获批后运行 `/dev-story` 以实现关卡内容。
- 运行 `/qa-plan` 为此关卡生成 QA 测试计划。

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
