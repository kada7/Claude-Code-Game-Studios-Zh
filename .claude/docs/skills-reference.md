# 可用技能（斜杠命令）

按阶段组织的 68 个斜杠命令。在 Claude Code 中输入 `/` 即可访问其中任何一个。

## 入门与导航

| 命令 | 用途 |
|---------|---------|
| `/start` | 首次入门引导 —— 询问你当前位置，然后引导至正确的工作流 |
| `/help` | 上下文感知的"接下来我该做什么？" —— 读取当前阶段并提示所需的下一步 |
| `/project-stage-detect` | 完整项目审计 —— 检测阶段、识别存在差距、推荐下一步 |
| `/setup-engine` | 配置引擎 + 版本，检测知识差距，填充版本感知参考文档 |
| `/adopt` | 棕地格式审计 —— 检查现有 GDDs/ADRs/stories 的内部结构，生成迁移计划 |

## 游戏设计

| 命令 | 用途 |
|---------|---------|
| `/brainstorm` | 使用专业工作室方法进行引导式构思（MDA、SDT、Bartle、动词优先） |
| `/map-systems` | 将游戏概念分解为系统，映射依赖关系，确定设计顺序优先级 |
| `/design-system` | 为单个游戏系统进行引导式逐节 GDD 编写 |
| `/quick-design` | 小型变更的轻量级设计规范 —— 调整、微调、小规模添加 |
| `/review-all-gdds` | 跨 GDD 一致性和游戏设计整体性审查所有设计文档 |
| `/propagate-design-change` | 当 GDD 被修订时，查找受影响的 ADR 并生成影响报告 |

## UX 与界面设计

| 命令 | 用途 |
|---------|---------|
| `/ux-design` | 引导式逐节 UX 规范编写（屏幕/流程、HUD 或模式库） |
| `/ux-review` | 验证 UX 规范是否符合 GDD、可访问性和模式合规性 |

## 架构

| 命令 | 用途 |
|---------|---------|
| `/create-architecture` | 引导式主架构文档编写 |
| `/architecture-decision` | 创建架构决策记录 (ADR) |
| `/architecture-review` | 验证所有 ADR 的完整性、依赖排序和 GDD 覆盖范围 |
| `/create-control-manifest` | 从已接受的 ADR 生成平面程序员规则表 |

## 故事与 Sprints

| 命令 | 用途 |
|---------|---------|
| `/create-epics` | 将 GDDs + ADRs 转换为史诗 —— 每个架构模块一个 |
| `/create-stories` | 将单个史诗分解为可实施的故事文件 |
| `/dev-story` | 读取故事并实施它 —— 路由到正确的程序员 agent |
| `/sprint-plan` | 生成或更新 sprint 计划；初始化 sprint-status.yaml |
| `/sprint-status` | 快速 30 行 sprint 快照（读取 sprint-status.yaml） |
| `/story-readiness` | 在实施前验证故事是否已准备好（READY/NEEDS WORK/BLOCKED） |
| `/story-done` | 实施后的 8 阶段完成审查；更新故事文件，提示下一个故事 |
| `/estimate` | 结构化工作量估算，包含复杂性、依赖关系和风险分解 |

## 审查与分析

| 命令 | 用途 |
|---------|---------|
| `/design-review` | 审查游戏设计文档的完整性和一致性 |
| `/code-review` | 对文件或变更集进行架构代码审查 |
| `/balance-check` | 分析游戏平衡数据、公式和配置 —— 标记异常值 |
| `/asset-audit` | 审计资产的命名规范、文件大小预算和流水线合规性 |
| `/content-audit` | 审计 GDD 指定的内容数量与实际实施内容的对比 |
| `/scope-check` | 分析功能或 sprint 范围与原始计划的对比，标记范围蔓延 |
| `/perf-profile` | 结构化性能分析，包含瓶颈识别 |
| `/tech-debt` | 扫描、跟踪、优先级排序和报告技术债务 |
| `/gate-check` | 验证在开发阶段间推进的准备情况（PASS/CONCERNS/FAIL） |
| `/consistency-check` | 扫描所有 GDD 与实体注册表的对比，检测跨文档不一致性（统计数据、名称、相互矛盾的规则） |

## QA 与测试

| 命令 | 用途 |
|---------|---------|
| `/qa-plan` | 为 sprint 或功能生成 QA 测试计划 |
| `/smoke-check` | 在 QA 移交前运行关键路径冒烟测试门 |
| `/soak-test` | 生成长时间游戏会话的浸泡测试协议 |
| `/regression-suite` | 将测试覆盖映射到 GDD 关键路径，识别没有回归测试的已修复缺陷 |
| `/test-setup` | 为项目引擎搭建测试框架和 CI/CD 流水线 |
| `/test-helpers` | 为测试套件生成引擎特定的测试辅助库 |
| `/test-evidence-review` | 测试文件和手动证据文档的质量审查 |
| `/test-flakiness` | 从 CI 运行日志中检测非确定性（不稳定）测试 |
| `/skill-test` | 验证技能文件的结构合规性和行为正确性 |

## 生产

| 命令 | 用途 |
|---------|---------|
| `/milestone-review` | 审查里程碑进度并生成状态报告 |
| `/retrospective` | 运行结构化的 sprint 或里程碑回顾会议 |
| `/bug-report` | 创建结构化的缺陷报告 |
| `/bug-triage` | 读取所有开放缺陷，重新评估优先级与严重性，分配负责人和标签 |
| `/reverse-document` | 从现有实施生成设计或架构文档 |
| `/playtest-report` | 生成结构化的游戏测试报告或分析现有游戏测试笔记 |

## 发布

| 命令 | 用途 |
|---------|---------|
| `/release-checklist` | 为当前构建生成和验证预发布检查清单 |
| `/launch-checklist` | 完成所有部门的发布准备情况验证 |
| `/changelog` | 从 git 提交和 sprint 数据自动生成变更日志 |
| `/patch-notes` | 从 git 历史记录和内部数据生成面向玩家的补丁说明 |
| `/hotfix` | 紧急修复工作流，包含审计跟踪，绕过正常 sprint 流程 |

## 创意与内容

| 命令 | 用途 |
|---------|---------|
| `/prototype` | 快速抛弃式原型以验证机制（宽松标准，独立工作树） |
| `/onboard` | 为新贡献者或 agent 生成上下文入门文档 |
| `/localize` | 本地化工作流：字符串提取、验证、翻译准备 |

## 团队协调

协调多个 agent 处理单个功能领域：

| 命令 | 协调的团队 |
|---------|-------------|
| `/team-combat` | game-designer + gameplay-programmer + ai-programmer + technical-artist + sound-designer + qa-tester |
| `/team-narrative` | narrative-director + writer + world-builder + level-designer |
| `/team-ui` | ux-designer + ui-programmer + art-director + accessibility-specialist |
| `/team-release` | release-manager + qa-lead + devops-engineer + producer |
| `/team-polish` | performance-analyst + technical-artist + sound-designer + qa-tester |
| `/team-audio` | audio-director + sound-designer + technical-artist + gameplay-programmer |
| `/team-level` | level-designer + narrative-director + world-builder + art-director + systems-designer + qa-tester |
| `/team-live-ops` | live-ops-designer + economy-designer + community-manager + analytics-engineer |
| `/team-qa` | qa-lead + qa-tester + gameplay-programmer + producer |