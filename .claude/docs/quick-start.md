# Game Studio Agent Architecture -- 快速入门指南

## 这是什么？

这是一个完整的 Claude Code 游戏开发 Agent 架构。它将 48 个专业化的 AI Agent 组织成一个镜像真实游戏开发团队的工作室层级结构，具有明确的责任、委托规则和协调协议。它包含用于 Godot、Unity 和 Unreal 的引擎专家 Agent —— 每个都有专门针对主要引擎子系统的子专家。所有设计 Agent 和模板都基于成熟的游戏设计理论（MDA 框架、自决理论、心流状态、Bartle 玩家类型）。请使用与你的项目匹配的引擎集。

## 如何使用

### 1. 理解层级结构

Agent 分为三个层级：

- **第 1 层 (Opus)**: 做出高层决策的总监
  - `creative-director` -- 愿景和创意冲突解决
  - `technical-director` -- 架构和技术决策
  - `producer` -- 调度、协调和风险管理

- **第 2 层 (Sonnet)**: 负责其领域的主管
  - `game-designer`, `lead-programmer`, `art-director`, `audio-director`,
    `narrative-director`, `qa-lead`, `release-manager`, `localization-lead`

- **第 3 层 (Sonnet/Haiku)**: 在其领域内执行的专家
  - 设计师、程序员、美术师、作家、测试人员、工程师

### 2. 选择合适的 Agent

问自己："在真实的工作室中，哪个部门会处理这个？"

| 我需要... | 使用这个 Agent |
|-------------|---------------|
| 设计一个新机制 | `game-designer` |
| 编写战斗代码 | `gameplay-programmer` |
| 创建着色器 | `technical-artist` |
| 编写对话 | `writer` |
| 计划下一个冲刺 | `producer` |
| 审查代码质量 | `lead-programmer` |
| 编写测试用例 | `qa-tester` |
| 设计一个关卡 | `level-designer` |
| 修复性能问题 | `performance-analyst` |
| 设置 CI/CD | `devops-engineer` |
| 设计战利品表 | `economy-designer` |
| 解决创意冲突 | `creative-director` |
| 做出架构决策 | `technical-director` |
| 管理发布 | `release-manager` |
| 准备字符串用于翻译 | `localization-lead` |
| 快速测试机制想法 | `prototyper` |
| 审查代码的安全问题 | `security-engineer` |
| 检查无障碍合规性 | `accessibility-specialist` |
| 获取 Unreal Engine 建议 | `unreal-specialist` |
| 获取 Unity 建议 | `unity-specialist` |
| 获取 Godot 建议 | `godot-specialist` |
| 设计 GAS 能力/效果 | `ue-gas-specialist` |
| 定义 BP/C++ 边界 | `ue-blueprint-specialist` |
| 实现 UE 复制 | `ue-replication-specialist` |
| 构建 UMG/CommonUI 小部件 | `ue-umg-specialist` |
| 设计 DOTS/ECS 架构 | `unity-dots-specialist` |
| 编写 Unity 着色器/VFX | `unity-shader-specialist` |
| 管理 Addressable 资产 | `unity-addressables-specialist` |
| 构建 UI Toolkit/UGUI 界面 | `unity-ui-specialist` |
| 编写地道的 GDScript | `godot-gdscript-specialist` |
| 创建 Godot 着色器 | `godot-shader-specialist` |
| 构建 GDExtension 模块 | `godot-gdextension-specialist` |
| 规划实时活动和赛季 | `live-ops-designer` |
| 为玩家编写补丁说明 | `community-manager` |
| 头脑风暴新的游戏想法 | 使用 `/brainstorm` skill |

### 3. 使用斜杠命令处理常见任务

| 命令 | 功能 |
|---------|-------------|
| `/start` | 首次上手 — 询问你现在的位置，引导你到正确的工作流程 |
| `/help` | 上下文感知的"下一步该做什么？" — 读取你当前阶段和工件 |
| `/project-stage-detect` | 分析项目状态、检测阶段、识别差距 |
| `/setup-engine` | 配置引擎 + 版本，填充参考文档 |
| `/adopt` | 现有项目的棕地审计和迁移计划 |
| `/brainstorm` | 从头开始的引导式游戏概念构思 |
| `/map-systems` | 将概念分解为系统，映射依赖关系，指导每个系统的 GDD |
| `/design-system` | 单个游戏系统的引导式、逐节 GDD 编写 |
| `/quick-design` | 小型变更的轻量级规范 — 调整优化、次要机制、平衡更改 |
| `/review-all-gdds` | 跨 GDD 一致性和游戏设计理论审查 |
| `/propagate-design-change` | 查找受 GDD 更改影响的 ADR 和故事 |
| `/ux-design` | 编写 UX 规范（屏幕/流程、HUD、交互模式） |
| `/ux-review` | 验证 UX 规范的无障碍性和 GDD 对齐 |
| `/create-architecture` | 游戏的主架构文档 |
| `/architecture-decision` | 创建 ADR |
| `/architecture-review` | 验证所有 ADR、依赖排序、GDD 可追溯性 |
| `/create-control-manifest` | 基于已接受 ADR 的扁平化程序员规则表 |
| `/create-epics` | 将 GDD + ADR 转换为史诗（每个架构模块一个） |
| `/create-stories` | 将单个史诗分解为可实现的 story 文件 |
| `/dev-story` | 读取 story 并实现它 — 路由到正确的程序员 Agent |
| `/sprint-plan` | 创建或更新冲刺计划 |
| `/sprint-status` | 快速 30 行冲刺快照 |
| `/story-readiness` | 验证 story 在拾取前是否已准备好实现 |
| `/story-done` | story 完成审查 — 验证验收标准 |
| `/estimate` | 生成结构化的工作量估算 |
| `/design-review` | 审查设计文档 |
| `/code-review` | 审查代码质量和架构 |
| `/balance-check` | 分析游戏平衡数据 |
| `/asset-audit` | 审计资产的合规性 |
| `/content-audit` | GDD 指定内容与已实现内容对比 — 找出差距 |
| `/scope-check` | 检测范围蔓延与计划对比 |
| `/perf-profile` | 性能分析和瓶颈识别 |
| `/tech-debt` | 扫描、追踪和优先处理技术债务 |
| `/gate-check` | 验证阶段准备情况（通过/关注/未通过） |
| `/consistency-check` | 扫描所有 GDD 以查找跨文档不一致性（冲突的统计数据、名称、规则） |
| `/reverse-document` | 从现有代码生成设计/架构文档 |
| `/milestone-review` | 审查里程碑进展 |
| `/retrospective` | 运行冲刺/里程碑回顾 |
| `/bug-report` | 结构化 Bug 报告创建 |
| `/playtest-report` | 创建或分析游戏测试反馈 |
| `/onboard` | 为角色生成上手文档 |
| `/release-checklist` | 验证发布前清单 |
| `/launch-checklist` | 完整的发布准备验证 |
| `/changelog` | 从 git 历史生成更新日志 |
| `/patch-notes` | 生成面向玩家的补丁说明 |
| `/hotfix` | 带有审计追踪的紧急修复 |
| `/prototype` | 搭建一次性原型 |
| `/localize` | 本地化扫描、提取、验证 |
| `/team-combat` | 编排完整的战斗团队流水线 |
| `/team-narrative` | 编排完整的叙事团队流水线 |
| `/team-ui` | 编排完整的 UI 团队流水线 |
| `/team-release` | 编排完整的发布团队流水线 |
| `/team-polish` | 编排完整的优化团队流水线 |
| `/team-audio` | 编排完整的音频团队流水线 |
| `/team-level` | 编排完整的关卡创建流水线 |
| `/team-live-ops` | 为赛季、活动和发布后内容编排 live-ops 团队 |
| `/team-qa` | 编排完整的 QA 团队周期 — 测试计划、测试用例、冒烟测试、签署 |
| `/qa-plan` | 为冲刺或功能生成 QA 测试计划 |
| `/bug-triage` | 重新评估开放 Bug 的优先级，分配到冲刺，发现系统趋势 |
| `/smoke-check` | 在 QA 交接前运行关键路径冒烟测试门（通过/未通过） |
| `/soak-test` | 为长时间游戏会话生成浸泡测试协议 |
| `/regression-suite` | 将测试覆盖映射到 GDD 关键路径，标记差距，维护回归测试套件 |
| `/test-setup` | 为项目引擎搭建测试框架 + CI 流水线（运行一次） |
| `/test-helpers` | 生成引擎特定的测试辅助库和工厂函数 |
| `/test-flakiness` | 从 CI 历史中检测不稳定测试，标记为隔离或修复 |
| `/test-evidence-review` | 测试文件和手动证据文档的质量审查 — 充分/不完整/缺失 |
| `/skill-test` | 验证 Skill 文件的合规性和正确性（静态 / 规范 / 审计） |

### 4. 为新文档使用模板

模板位于 `.claude/docs/templates/` 中：

- `game-design-document.md` -- 用于新机制和系统
- `architecture-decision-record.md` -- 用于技术决策
- `architecture-traceability.md` -- 将 GDD 需求映射到 ADR 再到 story ID
- `risk-register-entry.md` -- 用于新风险
- `narrative-character-sheet.md` -- 用于新角色
- `test-plan.md` -- 用于功能测试计划
- `sprint-plan.md` -- 用于冲刺规划
- `milestone-definition.md` -- 用于新里程碑
- `level-design-document.md` -- 用于新关卡
- `game-pillars.md` -- 用于核心设计支柱
- `art-bible.md` -- 用于视觉风格参考
- `technical-design-document.md` -- 用于每个系统的技术设计
- `post-mortem.md` -- 用于项目/里程碑回顾
- `sound-bible.md` -- 用于音频风格参考
- `release-checklist-template.md` -- 用于平台发布清单
- `changelog-template.md` -- 用于面向玩家的补丁说明
- `release-notes.md` -- 用于面向玩家的发布说明
- `incident-response.md` -- 用于实时事件响应手册
- `game-concept.md` -- 用于初始游戏概念（MDA、SDT、心流、Bartle）
- `pitch-document.md` -- 用于向利益相关者推介游戏
- `economy-model.md` -- 用于虚拟经济设计（水槽/水龙头模型）
- `faction-design.md` -- 用于派系身份、传说和游戏玩法角色
- `systems-index.md` -- 用于系统分解和依赖关系映射
- `project-stage-report.md` -- 用于项目阶段检测输出
- `design-doc-from-implementation.md` -- 用于将现有代码反向文档化为 GDD
- `architecture-doc-from-code.md` -- 用于将代码反向文档化为架构文档
- `concept-doc-from-prototype.md` -- 用于将原型反向文档化为概念文档
- `ux-spec.md` -- 用于每个屏幕的 UX 规范（布局区域、状态、事件）
- `hud-design.md` -- 用于整个游戏的 HUD 哲学、区域和元素规范
- `accessibility-requirements.md` -- 用于项目范围的无障碍层级和功能矩阵
- `interaction-pattern-library.md` -- 用于标准 UI 控件和游戏特定模式
- `player-journey.md` -- 用于 6 阶段情感弧线和按时间尺度的留存钩子
- `difficulty-curve.md` -- 用于难度轴、上手斜坡和跨系统交互
- `test-evidence.md` -- 用于记录手动测试证据的模板（截图、走查笔记）

另外在 `.claude/docs/templates/collaborative-protocols/` 中（由 Agent 使用，通常不直接编辑）：

- `design-agent-protocol.md` -- 设计 Agent 的问题-选项-草稿-批准循环
- `implementation-agent-protocol.md` -- 通过 /story-done 循环的 story 拾取编程 Agent
- `leadership-agent-protocol.md` -- 总监层级的跨部门委托和升级

### 5. 遵循协调规则

1. 工作向下流动层级结构：总监 -> 主管 -> 专家
2. 冲突向上升级层级结构
3. 跨部门工作由 `producer` 协调
4. Agent 未经委托不得修改其领域外的文件
5. 所有决策都有文档记录

## 新项目的初步步骤

**不知道从哪里开始？** 运行 `/start`。它会询问你现在的位置并引导你到正确的工作流程。不对你的游戏、引擎或经验水平做任何假设。

如果你已经知道需要什么，直接跳到相关路径：

### 路径 A: "我不知道要构建什么"

1. **运行 `/start`**（或 `/brainstorm open`）— 引导式创意探索：
   什么让你兴奋，你玩过什么，你的约束条件
   - 生成 3 个概念，帮助你挑选一个，定义核心循环和支柱
   - 生成游戏概念文档并推荐引擎
2. **设置引擎** — 运行 `/setup-engine`（使用头脑风暴的推荐）
   - 配置 CLAUDE.md，检测知识差距，填充参考文档
   - 创建 `.claude/docs/technical-preferences.md`，包含命名约定、
     性能预算和引擎特定默认值
   - 如果引擎版本比 LLM 的训练数据更新，它会从网络获取
     当前文档，以便 Agent 建议正确的 API
3. **验证概念** — 运行 `/design-review design/gdd/game-concept.md`
4. **分解为系统** — 运行 `/map-systems` 映射所有系统和依赖关系
5. **设计每个系统** — 运行 `/design-system [system-name]`（或 `/map-systems next`）
   按依赖顺序编写 GDD
6. **测试核心循环** — 运行 `/prototype [core-mechanic]`
7. **游戏测试它** — 运行 `/playtest-report` 验证假设
8. **计划第一个冲刺** — 运行 `/sprint-plan new`
9. 开始构建

### 路径 B: "我知道要构建什么"

如果你已经有游戏概念和引擎选择：

1. **设置引擎** — 运行 `/setup-engine [engine] [version]`
   （例如，`/setup-engine godot 4.6`）— 同时创建技术偏好
2. **编写游戏支柱** — 委托给 `creative-director`
3. **分解为系统** — 运行 `/map-systems` 枚举系统和依赖关系
4. **设计每个系统** — 运行 `/design-system [system-name]` 按依赖顺序编写 GDD
5. **创建初始 ADR** — 运行 `/architecture-decision`
6. **在 `production/milestones/` 中创建第一个里程碑**
7. **计划第一个冲刺** — 运行 `/sprint-plan new`
8. 开始构建

### 路径 C: "我知道游戏但不知道引擎"

如果你有概念但不知道哪个引擎适合：

1. **不带参数运行 `/setup-engine`** — 它会询问你游戏的需求
   （2D/3D、平台、团队规模、语言偏好）并根据你的答案推荐引擎
2. 从步骤 2 开始遵循路径 B

### 路径 D: "我有一个现有项目"

如果你已经有设计文档、原型或代码：

1. **运行 `/start`**（或 `/project-stage-detect`）— 分析现有内容，
   识别差距，并推荐下一步
2. **运行 `/adopt`** 如果你有现有的 GDD、ADR 或 story — 审计
   内部格式合规性，并构建一个编号的迁移计划来填补差距
   而不会覆盖你现有的工作
3. **如果需要则配置引擎** — 如果尚未配置，运行 `/setup-engine`
4. **验证阶段准备情况** — 运行 `/gate-check` 查看你处于什么位置
5. **计划下一个冲刺** — 运行 `/sprint-plan new`

## 文件结构参考

```
CLAUDE.md                          -- 主配置（首先阅读这个，约 60 行）
.claude/
  settings.json                    -- Claude Code 钩子和项目设置
  agents/                          -- 48 个 Agent 定义（YAML frontmatter）
  skills/                          -- 68 个斜杠命令定义（YAML frontmatter）
  hooks/                           -- 12 个钩子脚本 (.sh) 通过 settings.json 连接
  rules/                           -- 11 个路径特定的规则文件
  docs/
    quick-start.md                 -- 本文件
    technical-preferences.md       -- 项目特定标准（由 /setup-engine 填充）
    coding-standards.md            -- 编码和设计文档标准
    coordination-rules.md          -- Agent 协调规则
    context-management.md          -- 上下文预算和压缩说明
    directory-structure.md         -- 项目目录布局
    workflow-catalog.yaml          -- 7 阶段流水线定义（由 /help 读取）
    setup-requirements.md          -- 系统先决条件（Git Bash、jq、Python）
    settings-local-template.md     -- 个人 settings.local.json 指南
    templates/                     -- 37 个文档模板
```
