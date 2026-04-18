# 技能流程图

展示技能如何在 7 个开发阶段中串联的视觉地图。
这些图表显示每个技能前后运行什么，以及工件如何在它们之间流动。

---

## 完整流程概览（从零到发布）

```
PHASE 1: CONCEPT（概念）
  /start ──────────────────────────────────────────────────────► 路由到 A/B/C/D
  /brainstorm ──────────────────────────────────────────────────► design/gdd/game-concept.md
  /setup-engine ────────────────────────────────────────────────► CLAUDE.md + technical-preferences.md
  /design-review [game-concept.md] ────────────────────────────► 概念已验证
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 systems-design
        │
        ▼
PHASE 2: SYSTEMS DESIGN（系统设计）
  /map-systems ────────────────────────────────────────────────► design/gdd/systems-index.md
        │
        ▼（按依赖顺序逐个系统）
  /design-system [name] ──────────────────────────────────────► design/gdd/[system].md
  /design-review [system].md ─────────────────────────────────► 每份 GDD 评审意见
        │
        ▼（所有 MVP GDD 完成后）
  /review-all-gdds ────────────────────────────────────────────► design/gdd/gdd-cross-review-[date].md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 technical-setup
        │
        ▼
PHASE 3: TECHNICAL SETUP（技术设置）
  /create-architecture ────────────────────────────────────────► docs/architecture/master.md
  /architecture-decision（×N）────────────────────────────────► docs/architecture/[adr-nnn].md
  /architecture-review ────────────────────────────────────────► 评审报告 + docs/architecture/tr-registry.yaml
  /create-control-manifest ────────────────────────────────────► docs/architecture/control-manifest.md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 pre-production
        │
        ▼
PHASE 4: PRE-PRODUCTION（预生产）
  [UX — 在 epics 之前，以便 story 编写时规格已存在]
  /ux-design [screen/hud/patterns] ────────────────────────────► design/ux/*.md
  /ux-review ──────────────────────────────────────────────────► UX 规格已批准（/team-ui 的硬门槛）

  [测试基础设施 — 在 story 引用测试前搭建]
  /test-setup ─────────────────────────────────────────────────► 测试框架 + CI/CD 流水线
  /test-helpers ───────────────────────────────────────────────► tests/helpers/[engine-specific].gd

  [Stories + 原型]
  /create-epics [layer] ───────────────────────────────────────► production/epics/*/EPIC.md
  /create-stories [epic-slug] ─────────────────────────────────► production/epics/*/story-*.md
  /prototype [core-mechanic] ──────────────────────────────────► prototypes/[name]/
  /playtest-report ────────────────────────────────────────────► tests/playtest/vertical-slice.md
  /sprint-plan new ────────────────────────────────────────────► production/sprints/sprint-01.md
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 production
        │
        ▼
PHASE 5: PRODUCTION（生产，重复的冲刺循环）
  /sprint-status ──────────────────────────────────────────────► 冲刺快照
  /story-readiness [story] ────────────────────────────────────► story 已验证为 READY
        │
        ▼（选取并实现）
  /dev-story [story] ──────────────────────────────────────────► 路由到正确的程序员 Agent
        │
        ▼（实现期间，按需使用）
  /code-review ────────────────────────────────────────────────► 代码评审报告
  /scope-check ────────────────────────────────────────────────► 范围蔓延已检测 / 清晰
  /content-audit ──────────────────────────────────────────────► GDD 内容差距已识别
  /bug-report ─────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
  /bug-triage ─────────────────────────────────────────────────► bug 重新排序 + 分配

  [功能区域的团队技能 — 处理完整功能时生成]
  /team-combat / /team-narrative / /team-ui / /team-level / /team-audio

  [每轮冲刺的 QA 周期]
  /qa-plan ────────────────────────────────────────────────────► production/qa/qa-plan-sprint-NN.md
  /smoke-check ────────────────────────────────────────────────► 冒烟测试门槛（PASS/FAIL）
  /regression-suite ───────────────────────────────────────────► 覆盖差距 + 缺失的回归测试
  /test-evidence-review ───────────────────────────────────────► 证据质量报告
  /test-flakiness ─────────────────────────────────────────────► 不稳定测试报告
        │
        ▼
  /story-done [story] ─────────────────────────────────────────► story 已关闭 + 下一个已呈现
  /sprint-plan [next] ─────────────────────────────────────────► 下一轮冲刺
        │
        ▼（Production 里程碑后）
  /milestone-review ───────────────────────────────────────────► 里程碑报告
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 polish
        │
        ▼
PHASE 6: POLISH（打磨）
  /perf-profile ───────────────────────────────────────────────► 性能报告 + 修复
  /balance-check ──────────────────────────────────────────────► 平衡报告 + 修复
  /asset-audit ────────────────────────────────────────────────► 资产合规报告
  /tech-debt ──────────────────────────────────────────────────► docs/tech-debt-register.md
  /soak-test ──────────────────────────────────────────────────► 浸泡测试协议 + 结果
  /localize ───────────────────────────────────────────────────► 本地化就绪报告
  /team-polish ────────────────────────────────────────────────► 打磨冲刺编排
  /team-qa ────────────────────────────────────────────────────► 完整 QA 周期签核
  /gate-check ─────────────────────────────────────────────────► PASS → 推进到 release
        │
        ▼
PHASE 7: RELEASE（发布）
  /launch-checklist ───────────────────────────────────────────► 发布就绪报告
  /release-checklist ──────────────────────────────────────────► 平台特定检查清单
  /changelog ──────────────────────────────────────────────────► CHANGELOG.md
  /patch-notes ────────────────────────────────────────────────► 面向玩家的说明
  /team-release ───────────────────────────────────────────────► 发布流水线编排
        │
        ▼（发布后，持续进行）
  /hotfix ─────────────────────────────────────────────────────► 紧急修复，附带审计追踪
  /team-live-ops ──────────────────────────────────────────────► 实时运营内容计划
```

---

## 技能链：/design-system 详解

单份 GDD 如何编写、评审并交接给架构：

```
systems-index.md（输入）
game-concept.md（输入）
上游 GDD（输入，如果有）
        │
        ▼
/design-system [name]
        │
        ├── 预检查：可行性表 + 引擎风险标记
        │
        ├── 章节循环 × 8：
        │     question → options → decision → draft → approval → WRITE
        │     [每节在批准后立即写入文件]
        │
        └── 输出：design/gdd/[system].md（完整，全部 8 节）
                │
                ▼
        /design-review design/gdd/[system].md
                │
                ├── APPROVED → 在 systems-index 中标记 DONE，进入下一个系统
                ├── NEEDS REVISION → Agent 展示具体问题，重新进入章节循环
                └── MAJOR REVISION → 需要重大重新设计，然后才能进入下一个系统
                        │
                        ▼（所有 MVP GDD + 交叉评审后）
                /review-all-gdds
                        │
                        └── 输出：gdd-cross-review-[date].md
```

---

## 技能链：UX / UI 流程详解

UX 规格在 Phase 4（预生产）中编写，在 epics 编写之前，以便 story 验收标准可以引用特定的 UX 工件。

```
design/gdd/*.md（提取出的 UI/UX 需求）
design/player-journey.md（情感弧线，如果已编写）
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → UX 规格就绪，进入 /create-epics
        ├── NEEDS REVISION → 列出阻塞问题 → 修复 → 重新运行评审
        └── MAJOR REVISION → 根本性 UX 问题 → 在 epics 前重新设计
                │
                ▼（APPROVED 后 — Phase 5 实现 UI 功能时）
        /team-ui
                │
                ├── Phase 1：/ux-design（如果还有缺失规格）+ /ux-review
                ├── Phase 2：视觉设计（art-director）
                ├── Phase 3：布局实现（ui-programmer）
                ├── Phase 4：无障碍审计（accessibility-specialist）
                └── Phase 5：最终评审

注意：/ux-design 和 /ux-review 属于 Phase 4（预生产）。
      /team-ui 属于 Phase 5（生产），当构建 UI 功能时使用。
```

---

## 技能链：Dev Story 流程详解

Story 如何从待办到关闭：

```
/story-readiness [story]
        │
        ├── READY → 状态：ready-for-dev → 选取进行实现
        ├── NEEDS WORK → Agent 展示具体差距 → 解决 → 重新运行 readiness
        └── BLOCKED → ADR 仍为 Proposed，或上游 story 不完整
                │
                ▼（READY 后）
        /dev-story [story]
                │
                ├── 读取：story 文件、链接的 GDD 需求、ADR 决策、控制清单
                ├── 路由到：gameplay-programmer / engine-programmer / ui-programmer / 等
                │
                └── 实现开始
                        │
                        ▼（可选，实现期间/之后）
                /code-review          → 变更集的架构评审
                /scope-check          → 验证与原始 story 标准无范围蔓延
                /test-evidence-review → 验证测试文件和手动证据质量
                        │
                        ▼
                /story-done [story]
                        │
                        ├── COMPLETE → 状态：Complete，sprint-status.yaml 已更新，下一个 story 已呈现
                        ├── COMPLETE WITH NOTES → 已完成，但部分标准已延期（已记录）
                        └── BLOCKED → 验收标准无法验证 → 调查阻塞原因
```

---

## 技能链：Story 生命周期（从待办到关闭）

Story 如何从待办到关闭（摘要视图）：

```
/create-epics [layer]
        │
        └── 输出：production/epics/[slug]/EPIC.md
                │
                ▼
        /create-stories [epic-slug]
                │
                └── 输出：production/epics/[slug]/story-NNN-[slug].md
                            （状态：Ready 或 Blocked（如果 ADR 是 Proposed））
                │
                ▼
        /story-readiness [story]
                │
                ├── READY → /dev-story → 实现 → /story-done
                ├── NEEDS WORK → 解决差距 → 重新运行
                └── BLOCKED → 先修复上游依赖
```

---

## 技能链：QA 流程详解

```
[Phase 4 — 一次性基础设施搭建]
/test-setup ────────────────────────────────────────────────────► 测试框架已搭建 + CI/CD 已连接
/test-helpers ──────────────────────────────────────────────────► tests/helpers/[engine].gd（GDUnit4、NUnit 等）

[Phase 5 — 每轮冲刺的 QA 周期]
/qa-plan [sprint or feature]
        │
        ├── 读取：story 文件、GDD、验收标准
        ├── 按测试类型分类每个 story：
        │     Logic → 自动化单元测试（BLOCKING）
        │     Integration → 集成测试或记录的游戏测试（BLOCKING）
        │     Visual/Feel → 截图 + 主管签核（ADVISORY）
        │     UI → 手动走查或交互测试（ADVISORY）
        │     Config/Data → 冒烟测试（ADVISORY）
        └── 输出：production/qa/qa-plan-sprint-NN.md
                │
                ▼
        /smoke-check
                │
                ├── PASS → QA 交接已清除
                └── FAIL → 阻止冲刺关闭 → 先修复关键路径
                        │
                        ▼
                /regression-suite
                        │
                        └── 覆盖差距 + 已修复 bug 但未写回归测试的列表
                                │
                                ▼
                        /test-evidence-review
                                │
                                └── 验证证据质量，不仅仅是存在性
                                        │
                                        ▼（如果 CI 运行历史可用）
                        /test-flakiness
                                │
                                └── 不稳定测试报告 + 修复建议

[Phase 6 — 扩展稳定性测试]
/soak-test ─────────────────────────────────────────────────────► 浸泡测试协议 + 观察结果
/team-qa ───────────────────────────────────────────────────────► 发布门槛的完整 QA 周期签核

[持续 — bug 管理]
/bug-report ────────────────────────────────────────────────────► production/qa/bugs/bug-NNN.md
/bug-triage ────────────────────────────────────────────────────► 待处理 bug 重新排序 + 分配

[元 — 工具验证]
/skill-test [lint|spec|catalog] ────────────────────────────────► 技能文件结构性 + 行为检查
```

---

## 技能链：UX 流程详解（遗留参考）

```
design/gdd/*.md（提取出的 UX 需求）
design/player-journey.md（情感弧线）
        │
        ▼
/ux-design hud              → design/ux/hud.md
/ux-design screen [name]    → design/ux/screens/[name].md
/ux-design patterns         → design/ux/interaction-patterns.md
        │
        ▼
/ux-review design/ux/
        │
        ├── APPROVED → 所有规格已准备好交给 /team-ui
        ├── NEEDS REVISION → 列出阻塞问题 → 修复 → 重新运行评审
        └── MAJOR REVISION → 根本性 UX 问题 → 重大重新设计
                │
                ▼（APPROVED 后）
        /team-ui
                │
                ├── Phase 1：上下文加载 + /ux-design（如果规格缺失）
                ├── Phase 2：视觉设计（art-director）
                ├── Phase 3：布局实现（ui-programmer）
                ├── Phase 4：无障碍审计（accessibility-specialist）
                └── Phase 5：最终评审
```

---

## Brownfield 接入流程

对于已有工作的项目（使用 `/start` 选项 D 或直接运行）：

```
/project-stage-detect    → 阶段检测报告
        │
        ▼
/adopt
        │
        ├── Phase 1：检测存在什么
        ├── Phase 2：FORMAT 审计（不仅仅是存在性）
        ├── Phase 3：分类差距（BLOCKING / HIGH / MEDIUM / LOW）
        ├── Phase 4：有序迁移计划
        ├── Phase 5：写入 docs/adoption-plan-[date].md
        └── Phase 6：内联修复最紧急的差距（可选）
                │
                ▼
        /design-system retrofit [path]    → 填补缺失的 GDD 章节
        /architecture-decision retrofit [path] → 填补缺失的 ADR 章节
        /gate-check                       → 你在流程中的哪个位置？
```

---

## 如何阅读这些图表

| 符号 | 含义 |
|--------|---------|
| `──►` | 产生此工件 |
| `│ ▼` | 流入下一步 |
| `├──` | 分支（多种可能结果） |
| `×N` | 运行 N 次（每个系统、story 等一次） |
| `(input)` | 被技能读取但不在此处产生 |
| `[optional]` | 门槛通过不需要 |
| `WRITE`（大写） | 立即写入磁盘 |

---

## 常见入口点

| 你的位置 | 运行这个 |
|---------------|---------|
| 全新，一无所知 | `/start` → `/brainstorm` |
| 有概念，无引擎 | `/setup-engine` |
| 有概念 + 引擎 | `/map-systems` |
| 系统设计中期 | `/design-system [next system]` 或 `/map-systems next` |
| 所有 GDD 完成 | `/review-all-gdds` → `/gate-check` |
| 技术设置中 | `/create-architecture` → `/architecture-decision` |
| 开始 UX 设计 | `/ux-design screen [name]` 或 `/ux-design hud` |
| 搭建测试 | `/test-setup` → `/test-helpers` |
| 有 stories，准备编码 | `/story-readiness [story]` → `/dev-story [story]` |
| Story 完成 | `/story-done [story]` |
| 为冲刺运行 QA | `/qa-plan` → `/smoke-check` → `/regression-suite` |
| Bug 待办需要整理 | `/bug-triage` |
| 扩展稳定性测试 | `/soak-test` |
| 不确定 | `/help` |
| 现有项目 | `/adopt` |
