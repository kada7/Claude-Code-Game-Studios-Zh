<p align="center">
  <h1 align="center">Claude Code Game Studios</h1>
  <p align="center">
    将一个 Claude Code 会话转变为完整的游戏开发工作室。
    <br />
    49 个 Agent，72 个 Skill，一个协同运作的 AI 团队。
  </p>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".claude/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".claude/skills"><img src="https://img.shields.io/badge/skills-72-green" alt="72 Skills"></a>
  <a href=".claude/hooks"><img src="https://img.shields.io/badge/hooks-12-orange" alt="12 Hooks"></a>
  <a href=".claude/rules"><img src="https://img.shields.io/badge/rules-11-red" alt="11 Rules"></a>
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/built%20for-Claude%20Code-f5f5f5?logo=anthropic" alt="Built for Claude Code"></a>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20this%20project-FFDD00?logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee"></a>
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Support%20this%20project-ea4aaa?logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

---

## 中文化说明
本项目是基于[Claude-Code-Game-Studios](https://github.com/Donchitos/Claude-Code-Game-Studios)的中文化

**当前版本只是非常粗糙地进行AI翻译，未做人工校对，主要用于学习、研究原始项目**

**请勿直接将此版本用于claude code，原版英文项目可正常进行中文交流及输出**

欢迎pull request，让这个中文版本更具实用价值。

## 为什么存在这个项目

独自使用 AI 进行游戏开发是非常强大的，但单个聊天会话缺乏结构。没有人能阻止你硬编码“魔术数字”、跳过设计文档或编写混乱的代码（spaghetti code）。没有 QA 环节，没有设计评审，也没有人问“这真的符合游戏的愿景吗？”

**Claude Code Game Studios** 通过为你的 AI 会话提供真实工作室的结构来解决这个问题。你得到的不再是一个通用的助手，而是 49 个组织在工作室层级中的专业 Agent —— 指导愿景的总监（Directors）、负责各自领域的部门负责人（Department Leads），以及进行实际工作的专家（Specialists）。每个 Agent 都有明确的职责、升级路径和质量检查点（Quality Gates）。

结果是：你仍然做出每一个决定，但现在你拥有了一个会提出正确问题、尽早发现错误，并让你的项目从最初的脑暴到发布都井井有条的团队。

---

## 目录

- [包含内容](#包含内容)
- [工作室层级](#工作室层级)
- [Slash 命令](#slash-命令)
- [入门指南](#入门指南)
- [升级](#升级)
- [项目结构](#项目结构)
- [工作原理](#工作原理)
- [设计理念](#设计理念)
- [自定义](#自定义)
- [平台支持](#平台支持)
- [社区](#社区)
- [支持本项目](#支持本项目)
- [许可证](#许可证)

---

## 包含内容

| 分类 | 数量 | 描述 |
|----------|-------|-------------|
| **Agents** | 49 | 涵盖设计、编程、美术、音频、叙事、QA 和生产的专业子 Agent |
| **Skills** | 72 | 用于工作流各个阶段的 Slash 命令（`/start`, `/design-system`, `/create-epics`, `/create-stories`, `/dev-story`, `/story-done` 等） |
| **Hooks** | 12 | 针对提交、推送、资源变更、会话生命周期、Agent 审计追踪和缺口检测的自动化验证 |
| **Rules** | 11 | 编辑游戏玩法、引擎、AI、UI、网络代码等时执行的路径范围编码标准 |
| **Templates** | 39 | 用于 GDD、UX 规范、ADR、Sprint 计划、HUD 设计、无障碍设计等的文档模板 |

## 工作室层级

Agent 分为三个层级，与现实工作室的运作方式一致：

```
Tier 1 — 总监 Directors (Opus)
  创意总监              技术总监              制作人
  creative-director    technical-director    producer

Tier 2 — 部门负责人 Department Leads (Sonnet)
  游戏设计师          主程              艺术总监
  game-designer      lead-programmer   art-director

  音频总监            叙事总监              QA负责人
  audio-director     narrative-director    qa-lead

  发布经理              本地化负责人
  release-manager      localization-lead

Tier 3 — 专家 Specialists (Sonnet/Haiku)
  游戏玩法程序员       引擎程序员            AI程序员
  gameplay-programmer  engine-programmer     ai-programmer

  网络程序员           工具程序员            UI程序员
  network-programmer   tools-programmer      ui-programmer

  系统设计师           关卡设计师            经济设计师
  systems-designer     level-designer        economy-designer

  技术美术             音效设计师            编剧
  technical-artist     sound-designer        writer

  世界构建师           UX设计师              原型设计师
  world-builder        ux-designer           prototyper

  性能分析师           运维工程师            数据分析师
  performance-analyst  devops-engineer       analytics-engineer

  安全工程师           QA测试员              无障碍专家
  security-engineer    qa-tester             accessibility-specialist

   live-ops设计师      社区经理
  live-ops-designer    community-manager
```

### 引擎专家 (Engine Specialists)

模板包含了针对三大主流引擎的 Agent 集。请使用与你的项目匹配的集：

| 引擎 | 负责人 (Lead Agent) | 子专家 (Sub-Specialists) |
|--------|-----------|-----------------|
| **Godot 4** | `godot-specialist` | GDScript, Shaders, GDExtension |
| **Unity** | `unity-specialist` | DOTS/ECS, Shaders/VFX, Addressables, UI Toolkit |
| **Unreal Engine 5** | `unreal-specialist` | GAS, Blueprints, Replication, UMG/CommonUI |

## Slash 命令

在 Claude Code 中输入 `/` 即可访问所有 72 个 Skills：

**入门与导航**
`/start` `/help` `/project-stage-detect` `/setup-engine` `/adopt`

**游戏设计**
`/brainstorm` `/map-systems` `/design-system` `/quick-design` `/review-all-gdds` `/propagate-design-change`

**美术与资源**
`/art-bible` `/asset-spec` `/asset-audit`

**UX 与界面设计**
`/ux-design` `/ux-review`

**架构**
`/create-architecture` `/architecture-decision` `/architecture-review` `/create-control-manifest`

**故事与 Sprint**
`/create-epics` `/create-stories` `/dev-story` `/sprint-plan` `/sprint-status` `/story-readiness` `/story-done` `/estimate`

**评审与分析**
`/design-review` `/code-review` `/balance-check` `/content-audit` `/scope-check` `/perf-profile` `/tech-debt` `/gate-check` `/consistency-check`

**QA 与测试**
`/qa-plan` `/smoke-check` `/soak-test` `/regression-suite` `/test-setup` `/test-helpers` `/test-evidence-review` `/test-flakiness` `/skill-test` `/skill-improve`

**生产**
`/milestone-review` `/retrospective` `/bug-report` `/bug-triage` `/reverse-document` `/playtest-report`

**发布**
`/release-checklist` `/launch-checklist` `/changelog` `/patch-notes` `/hotfix`

**创意与内容**
`/prototype` `/onboard` `/localize`

**团队编排** (协调多个 Agent 完成单个功能)
`/team-combat` `/team-narrative` `/team-ui` `/team-release` `/team-polish` `/team-audio` `/team-level` `/team-live-ops` `/team-qa`

## 入门指南

### 前提条件

- [Git](https://git-scm.com/)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- **推荐**: [jq](https://jqlang.github.io/jq/) (用于 hook 验证) 和 Python 3 (用于 JSON 验证)

如果缺少可选工具，所有 hooks 都会优雅地失败 —— 不会破坏任何东西，只是失去相应的验证功能。

### 设置

1. **克隆或作为模板使用**:
   ```bash
   git clone https://github.com/Donchitos/Claude-Code-Game-Studios.git my-game
   cd my-game
   ```

2. **打开 Claude Code** 并启动会话：
   ```bash
   claude
   ```

3. **运行 `/start`** —— 系统会询问你当前所处的阶段（没有想法、模糊概念、清晰设计、现有工作）并引导你进入正确的工作流。没有预设的假设。

   或者如果你已经知道需要什么，可以直接跳转到特定的 Skill：
   - `/brainstorm` —— 从零开始探索游戏创意
   - `/setup-engine godot 4.6` —— 如果已知，则配置你的引擎
   - `/project-stage-detect` —— 分析现有项目

## 升级

已经在旧版本模板上使用？请查阅 [UPGRADING.md](UPGRADING.md)，获取分步迁移指南、版本间变更说明，以及哪些文件可以安全覆盖、哪些需要手动合并的详细信息。

## 项目结构

```
CLAUDE.md                           # 主配置
.claude/
  settings.json                     # Hooks, 权限, 安全规则
  agents/                           # 49 个 Agent 定义 (Markdown + YAML frontmatter)
  skills/                           # 72 个 Slash 命令 (每个 Skill 一个子目录)
  hooks/                            # 12 个 Hook 脚本 (Bash, 跨平台)
  rules/                            # 11 个 路径范围编码标准
  statusline.sh                     # 状态行脚本 (context%, model, stage, epic breadcrumb)
  docs/
    workflow-catalog.yaml           # 7 阶段流水线定义 (由 /help 读取)
    templates/                      # 39 个文档模板
src/                                # 游戏源代码
assets/                             # 美术, 音频, VFX, 着色器, 数据文件
design/                             # GDD, 叙事文档, 关卡设计
docs/                               # 技术文档和 ADR
tests/                              # 测试套件 (单元, 集成, 性能, 游戏测试)
tools/                              # 构建和流水线工具
prototypes/                         # 临时原型 (与 src/ 隔离)
production/                         # Sprint 计划, 里程碑, 发布追踪
```

## 工作原理

### Agent 协同

Agent 遵循结构化的委托模型：

1. **垂直委托** —— Directors 委托给 Leads，Leads 委托给 Specialists
2. **水平咨询** —— 同级 Agent 可以相互咨询，但不能做出跨域的约束性决策
3. **冲突解决** —— 分歧会向上升级至共同的父级（设计相关归 `creative-director`，技术相关归 `technical-director`）
4. **变更传播** —— 跨部门变更由 `producer` 协调
5. **域边界** —— 未经明确委托，Agent 不得修改其领域之外的文件

### 协作，而非自治

这不是一个自动驾驶系统。每个 Agent 都遵循严格的协作协议：

1. **询问** —— Agent 在提出解决方案之前会先提问
2. **提供选项** —— Agent 会展示 2-4 个选项及其优缺点
3. **你来决定** —— 用户始终掌握决策权
4. **起草** —— Agent 在定稿前会展示工作成果
5. **批准** —— 未经你的认可，任何内容都不会被写入文件

你始终保持控制权。Agent 提供的是结构和专业知识，而不是自主性。

### 自动化安全

**Hooks** 会在每个会话中自动运行：

| Hook | 触发条件 | 功能 |
|------|---------|--------------|
| `validate-commit.sh` | PreToolUse (Bash) | 检查硬编码值、TODO 格式、JSON 有效性、设计文档部分 —— 如果命令不是 `git commit` 则立即退出 |
| `validate-push.sh` | PreToolUse (Bash) | 在推送到保护分支时发出警告 —— 如果命令不是 `git push` 则立即退出 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 验证命名规范和 JSON 结构 —— 如果文件不在 `assets/` 中则立即退出 |
| `session-start.sh` | 会话开启 | 显示当前分支和最近的提交以供参考 |
| `detect-gaps.sh` | 会话开启 | 检测新项目（建议运行 `/start`）以及当代码或原型存在时缺失的设计文档 |
| `pre-compact.sh` | 压缩前 | 保存会话进度笔记 |
| `post-compact.sh` | 压缩后 | 提醒 Claude 从 `active.md` 恢复会话状态 |
| `notify.sh` | 通知事件 | 通过 PowerShell 显示 Windows Toast 通知 |
| `session-stop.sh` | 会话关闭 | 将 `active.md` 归档到会话日志并记录 Git 活动 |
| `log-agent.sh` | Agent 生成 | 审计追踪开启 —— 记录子 Agent 调用 |
| `log-agent-stop.sh` | Agent 停止 | 审计追踪停止 —— 完成子 Agent 记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 建议在任何 `.claude/skills/` 变更后运行 `/skill-test` |

> **注意**：`validate-commit.sh`, `validate-assets.sh` 和 `validate-skill-change.sh` 会在每次 Bash/Write 工具调用时触发，如果命令或文件路径不相关则立即退出 (exit 0)。这是正常的 Hook 行为 —— 不会造成性能问题。

`settings.json` 中的**权限规则**会自动允许安全操作（git status, 测试运行）并阻止危险操作（强制推送, `rm -rf`, 读取 `.env` 文件）。

### 路径范围规则 (Path-Scoped Rules)

编码标准会根据文件位置自动执行：

| 路径 | 执行标准 |
|------|----------|
| `src/gameplay/**` | 数据驱动的值, delta time 使用, 禁止引用 UI |
| `src/core/**` | 热路径 (hot paths) 中零分配, 线程安全, API 稳定性 |
| `src/ai/**` | 性能预算, 可调试性, 数据驱动参数 |
| `src/networking/**` | 服务端权威, 版本化消息, 安全性 |
| `src/ui/**` | 禁止拥有游戏状态, 支持本地化, 无障碍支持 |
| `design/gdd/**` | 要求 8 个部分, 公式格式, 边缘情况 |
| `tests/**` | 测试命名, 覆盖率要求, 固定模式 (fixture patterns) |
| `prototypes/**` | 标准较宽松, 要求包含 README, 记录假设 |

## 设计理念

本模板立足于专业游戏开发实践：

- **MDA 框架** —— 游戏设计的机制 (Mechanics)、动态 (Dynamics)、美学 (Aesthetics) 分析
- **自我决定论** —— 玩家动机的自主性、胜任感、关联感
- **心流设计** —— 玩家参与度的挑战-技能平衡
- **Bartle 玩家类型** —— 受众定位与验证
- **验证驱动开发** —— 先测试，后实现

## 自定义

这是一个 **模板**，而非锁死的框架。一切都可以自定义：

- **添加/移除 Agent** —— 删除不需要的 Agent 文件，为你的领域添加新 Agent
- **编辑 Agent Prompt** —— 调整 Agent 行为，添加项目特定知识
- **修改 Skill** —— 调整工作流以匹配你的团队流程
- **添加规则** —— 为项目目录结构创建新的路径范围规则
- **调整 Hooks** —— 调整验证的严格程度，添加新的检查项
- **选择你的引擎** —— 使用 Godot, Unity 或 Unreal Agent 集（或者不使用）
- **设置评审强度** —— `full` (所有 Director 关卡), `lean` (仅阶段关卡), 或 `solo` (无)。在 `/start` 时设置，或编辑 `production/review-mode.txt`。运行任何 Skill 时可通过 `--review solo` 临时覆盖。

## 平台支持

已在 **Windows 10** 和 Git Bash 环境下测试。所有 Hooks 使用 POSIX 兼容模式 (`grep -E`, 而非 `grep -P`)，并包含对缺失工具的 Fallback。无需修改即可在 macOS 和 Linux 上运行。

## 社区

- **讨论** —— [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 用于提问、创意交流和展示你的作品
- **Issues** —— [Bug 报告与功能请求](https://github.com/Donchitos/Claude-Code-Game-Studios/issues)

---

## 支持本项目

Claude Code Game Studios 是免费且开源的。如果它为你节省了时间或帮助你发布了游戏，请考虑支持持续的开发：

<p>
  <a href="https://www.buymeacoffee.com/donchitos3"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/Donchitos"><img src="https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors"></a>
</p>

- **[Buy Me a Coffee](https://www.buymeacoffee.com/donchitos3)** —— 一次性支持
- **[GitHub Sponsors](https://github.com/sponsors/Donchitos)** —— 通过 GitHub 进行定期支持

赞助有助于资助维护 Skills、添加新 Agent、跟进 Claude Code 和引擎 API 变更以及响应社区 Issue 所花费的时间。

---

*为 Claude Code 而生。持续维护与扩展 —— 欢迎通过 [GitHub Discussions](https://github.com/Donchitos/Claude-Code-Game-Studios/discussions) 贡献。*

## 许可证

MIT 许可证。详情请参阅 [LICENSE](LICENSE)。
