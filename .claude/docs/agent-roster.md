# Agent 名册

以下 Agent 可用。每个 Agent 在 `.claude/agents/` 中都有专门的定义文件。
使用最适合当前任务的 Agent。当任务涉及多个领域时，
协调 Agent（通常是 `producer` 或领域负责人）应委派给专家。

## 层级 1 -- 领导 Agent（Opus）
| Agent | 领域 | 使用时机 |
|-------|--------|-------------|
| `creative-director` | 高层愿景 | 主要创意决策、支柱冲突、基调/方向 |
| `technical-director` | 技术愿景 | 架构决策、技术栈选择、性能策略 |
| `producer` | 生产管理 | 冲刺规划、里程碑跟踪、风险管理、协调 |

## 层级 2 -- 部门负责人 Agent（Sonnet）
| Agent | 领域 | 使用时机 |
|-------|--------|-------------|
| `game-designer` | 游戏设计 | 机制、系统、进度、经济、平衡 |
| `lead-programmer` | 代码架构 | 系统设计、代码审查、API设计、重构 |
| `art-director` | 视觉方向 | 风格指南、艺术圣经、资产标准、UI/UX 方向 |
| `audio-director` | 音频方向 | 音乐方向、声音调色板、音频实施策略 |
| `narrative-director` | 故事和写作 | 故事弧、世界构建、角色设计、对话策略 |
| `qa-lead` | 质量保证 | 测试策略、Bug分级、发布准备、回归规划 |
| `release-manager` | 发布管道 | 构建管理、版本控制、更新日志、部署、回滚 |
| `localization-lead` | 国际化 | 字符串外部化、翻译流水线、区域测试 |

## 层级 3 -- 专业 Agent（Sonnet 或 Haiku）
| Agent | 领域 | 模型 | 使用时机 |
|-------|--------|-------|-------------|
| `systems-designer` | 系统设计 | Sonnet | 特定机制实施、公式设计、循环 |
| `level-designer` | 关卡设计 | Sonnet | 关卡布局、节奏、遭遇设计、流程 |
| `economy-designer` | 经济/平衡 | Sonnet | 资源经济、战利品表、进度曲线 |
| `gameplay-programmer` | 游戏玩法代码 | Sonnet | 功能实施、游戏玩法系统代码 |
| `engine-programmer` | 引擎系统 | Sonnet | 核心引擎、渲染、物理、内存管理 |
| `ai-programmer` | AI 系统 | Sonnet | 行为树、寻路、NPC逻辑、状态机 |
| `network-programmer` | 网络 | Sonnet | 网络代码、复制、延迟补偿、匹配 |
| `tools-programmer` | 开发工具 | Sonnet | 编辑器扩展、管道工具、调试工具 |
| `ui-programmer` | UI 实施 | Sonnet | UI 框架、屏幕、小部件、数据绑定 |
| `technical-artist` | 技术美术 | Sonnet | 着色器、VFX、优化、美术管道工具 |
| `sound-designer` | 声音设计 | Haiku | SFX 设计文档、音频事件列表、混音说明 |
| `writer` | 对话/传说 | Sonnet | 对话编写、传说条目、物品描述 |
| `world-builder` | 世界/传说设计 | Sonnet | 世界规则、派系设计、历史、地理 |
| `qa-tester` | 测试执行 | Haiku | 编写测试用例、Bug 报告、测试清单 |
| `performance-analyst` | 性能 | Sonnet | 性能分析、优化建议、内存分析 |
| `devops-engineer` | 构建/部署 | Haiku | CI/CD、构建脚本、版本控制工作流 |
| `analytics-engineer` | 遥测 | Sonnet | 事件跟踪、仪表板、A/B 测试设计 |
| `ux-designer` | UX 流程 | Sonnet | 用户流程、线框图、无障碍性、输入处理 |
| `prototyper` | 快速原型 | Sonnet | 一次性原型、机制测试、可行性验证 |
| `security-engineer` | 安全 | Sonnet | 反作弊、漏洞利用预防、存档加密、网络安全 |
| `accessibility-specialist` | 无障碍性 | Haiku | WCAG 合规性、色盲模式、重映射、文本缩放 |
| `live-ops-designer` | 实时运营 | Sonnet | 赛季、活动、战斗通行证、留存、实时经济 |
| `community-manager` | 社区 | Haiku | 补丁说明、玩家反馈、危机沟通、社区健康 |

## Engine-Specific Agents (use the set matching your engine)

### Engine Leads

| Agent | Engine | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `unreal-specialist` | Unreal Engine 5 | Sonnet | Blueprint vs C++, GAS overview, UE subsystems, Unreal optimization |
| `unity-specialist` | Unity | Sonnet | MonoBehaviour vs DOTS, Addressables, URP/HDRP, Unity optimization |
| `godot-specialist` | Godot 4 | Sonnet | GDScript patterns, node/scene architecture, signals, Godot optimization |

### Unreal Engine Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `ue-gas-specialist` | Gameplay Ability System | Sonnet | Abilities, gameplay effects, attribute sets, tags, prediction |
| `ue-blueprint-specialist` | Blueprint Architecture | Sonnet | BP/C++ boundary, graph standards, naming, BP optimization |
| `ue-replication-specialist` | Networking/Replication | Sonnet | Property replication, RPCs, prediction, relevancy, bandwidth |
| `ue-umg-specialist` | UMG/CommonUI | Sonnet | Widget hierarchy, data binding, CommonUI input, UI performance |

### Unity Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `unity-dots-specialist` | DOTS/ECS | Sonnet | Entity Component System, Jobs, Burst compiler, hybrid renderer |
| `unity-shader-specialist` | Shaders/VFX | Sonnet | Shader Graph, VFX Graph, URP/HDRP customization, post-processing |
| `unity-addressables-specialist` | Asset Management | Sonnet | Addressable groups, async loading, memory, content delivery |
| `unity-ui-specialist` | UI Toolkit/UGUI | Sonnet | UI Toolkit, UXML/USS, UGUI Canvas, data binding, cross-platform input |

### Godot Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `godot-gdscript-specialist` | GDScript | Sonnet | Static typing, design patterns, signals, coroutines, GDScript performance |
| `godot-shader-specialist` | Shaders/Rendering | Sonnet | Godot shading language, visual shaders, particles, post-processing |
| `godot-gdextension-specialist` | GDExtension | Sonnet | C++/Rust bindings, native performance, custom nodes, build systems |
