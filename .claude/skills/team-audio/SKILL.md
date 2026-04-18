---
name: team-audio
description: "Orchestrate audio team: audio-director + sound-designer + technical-artist + gameplay-programmer for full audio pipeline from direction to implementation."
argument-hint: "[feature or area to design audio for]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---

如果没有提供参数，输出使用指南并退出而不生成任何代理:
> Usage: `/team-audio [feature or area]` — 指定要为其设计音频的功能或区域 (例如, `combat`, `main menu`, `forest biome`, `boss encounter`)。不要在此处使用 `AskUserQuestion`; 直接输出指南。

当使用参数调用此 skill 时，通过结构化流程编排音频团队。

**决策点:** 在每个步骤转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一步。

1. **读取参数** 以获取目标功能或区域 (例如, `combat`,
   `main menu`, `forest biome`, `boss encounter`)。

2. **收集上下文**:
   - 读取功能的相关设计文档 `design/gdd/`
   - 如果存在，读取 `design/gdd/sound-bible.md` 的声音圣经
   - 读取 `assets/audio/` 中的现有音频资产列表
   - 读取此区域的任何现有声音设计文档

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: audio-director` — 声音识别、情感基调、音频调色板
- `subagent_type: sound-designer` — SFX 规范、音频事件、混音组
- `subagent_type: technical-artist` — 音频中间件、总线结构、内存预算
- `subagent_type: [primary engine specialist]` — 验证引擎的音频集成模式
- `subagent_type: gameplay-programmer` — 音频管理器、游戏玩法触发器、自适应音乐

始终在代理的提示中提供完整上下文 (功能描述、现有音频资产、设计文档引用)。

3. **编排音频团队** 按顺序:

### 步骤 1: 音频指导 (audio-director)
生成 `audio-director` 代理以:
- 为此功能/区域定义声音识别
- 指定情感基调和音频调色板
- 设置音乐方向 (自适应层、音轨、过渡)
- 定义音频优先级和混音目标
- 建立任何自适应音频规则 (战斗强度、探索、紧张)

### 步骤 2: 声音设计和音频无障碍 (并行)
生成 `sound-designer` 代理以:
- 为每个音频事件创建详细的 SFX 规范
- 定义声音类别 (ambient, UI, gameplay, music, dialogue)
- 指定每个声音的参数 (音量范围、音高变化、衰减)
- 使用触发条件规划音频事件列表
- 定义混音组和闪避规则

并行生成 `accessibility-specialist` 代理以:
- 识别哪些音频事件携带关键游戏玩法信息 (受到伤害、敌人在附近、目标完成) 并需要听力障碍玩家的视觉替代
- 指定字幕要求: 哪些音频事件需要字幕、文本格式、屏幕持续时间
- 检查没有游戏状态仅靠音频传达 (所有必须有视觉后备)
- 审查音频事件列表，识别可能对听觉敏感玩家造成问题的 (高频警报、突然的响亮事件)
- 输出: 集成到音频事件规范的音频无障碍要求列表

### 步骤 3: 技术实现 (并行)
生成 `technical-artist` 代理以:
- 设计音频中间件集成 (Wwise/FMOD/native)
- 定义音频总线结构和路由
- 指定每个平台的音频资产内存预算
- 规划流式传输 vs 预加载资产策略
- 设计任何音频反应视觉效果

并行生成 **primary engine specialist** (来自 `.claude/docs/technical-preferences.md` Engine Specialists) 以验证集成方法:
- 提议的音频中间件集成对于引擎是否符合习惯? (例如, Godot 的内置 AudioStreamPlayer vs FMOD, Unity 的 Audio Mixer vs Wwise, Unreal 的 MetaSounds vs FMOD)
- 应该使用的引擎特定音频节点/组件模式?
- 固定引擎版本中影响集成计划的已知音频系统更改?
- 输出: 与 technical-artist 的计划合并的引擎音频集成说明

如果未配置引擎，跳过专家生成。

### 步骤 4: 代码集成 (gameplay-programmer)
生成 `gameplay-programmer` 代理以:
- 实现音频管理器系统或审查现有系统
- 将音频事件连接到游戏玩法触发器
- 实现自适应音乐系统 (如果指定)
- 设置音频遮挡/混响区域
- 为音频事件触发器编写单元测试

4. **编译音频设计文档** 结合所有团队输出。

5. **保存到** `design/gdd/audio-[feature].md`。

6. **输出摘要** 包括: 音频事件计数、估计资产计数、
   实现任务和团队成员之间的任何开放问题。

裁决: **COMPLETE** — 音频设计文档已生成，团队流程完成。

如果流程因依赖项未解决而停止 (例如，关键无障碍差距或用户未解决的缺失 GDD):

裁决: **BLOCKED** — [reason]

## 文件写入协议

所有文件写入 (音频设计文档、SFX 规范、实现文件) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 
协议。此编排器不直接写入文件。

## 后续步骤

- 在开始实施前与 audio-director 审查音频设计文档。
- 设计获批后使用 `/dev-story` 实现音频管理器和事件系统。
- 创建音频资产后运行 `/asset-audit` 以验证命名和格式合规性。

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
