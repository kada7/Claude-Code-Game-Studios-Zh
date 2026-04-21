# Director Gates — 共享审查模式

本文档定义了所有总监和负责人在每个工作流程阶段的标准门控提示。技能引用本文档中的门控ID，而不是内嵌完整的提示语——消除提示语需要更新时的偏差。

**范围**: 所有7个生产阶段（概念 → 发布），所有3个一级总监，所有关键的二级负责人。任何技能、团队协调器或工作流程都可以调用这些门。

---

## 如何使用本文档

在任何技能中，将内联的总监提示替换为引用：

```
Spawn `creative-director` via Task using gate **CD-PILLARS** from
`.claude/docs/director-gates.md`.
```

传递该门控**待传递上下文**字段下列出的上下文，然后使用下面的**裁决处理**规则处理裁决。

---

## 审查模式

审查强度控制总监门控是否运行。它可以全局设置
（持久跨会话）或每次技能运行时覆盖。

**全局配置**: `production/review-mode.txt` — 一个单词：`full`、`lean` 或 `solo`。
在 `/start` 期间设置一次。直接编辑此文件可以在任何时候更改它。

**每次运行覆盖**: 任何使用门控的技能接受 `--review [full|lean|solo]` 作为
参数。这仅在该次运行中覆盖全局配置。

示例：
```
/brainstorm space horror           → 使用全局模式
/brainstorm space horror --review full   → 此次强制使用 full 模式
/architecture-decision --review solo     → 此次跳过所有门控
```

| 模式 | 运行内容 | 最适合 |
|------|-----------|----------|
| `full` | 所有门控激活 — 每个工作流程步骤都经过审查 | 团队、学习用户，或当你希望在每个步骤都获得彻底的总监反馈时 |
| `lean` | 仅 PHASE-GATEs 运行（`/gate-check`） — 每技能门控跳过 | **默认** — 单人开发和小团队；总监仅在里程碑处审查 |
| `solo` | 任何地方都不运行总监门控 | Game jam、原型、最大速度 |

**检查模式 — 在每个门控生成前应用：**

```
Before spawning gate [GATE-ID]:
1. If skill was called with --review [mode], use that
2. Else read production/review-mode.txt
3. Else default to full

Apply the resolved mode:
- solo → skip all gates. Note: "[GATE-ID] skipped — Solo mode"
- lean → skip unless this is a PHASE-GATE (CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE)
         Note: "[GATE-ID] skipped — Lean mode"
- full → spawn as normal
```

---

## 调用模式（复制到任何技能）

**必须: 在每个门控生成前解析审查模式。**永远不要在不检查的情况下生成门控。解析后的模式每次技能运行确定一次：
1. 如果技能以 `--review [mode]` 调用，使用该模式
2. 否则读取 `production/review-mode.txt`
3. 否则默认为 `lean`

应用解析后的模式：
- `solo` → **跳过所有门控**。在输出中注明：`[GATE-ID] skipped — Solo mode`
- `lean` → **跳过除非这是PHASE-GATE**（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）。注明：`[GATE-ID] skipped — Lean mode`
- `full` → 正常生成

```
# 应用模式检查，然后：
Spawn `[agent-name]` via Task:
- Gate: [GATE-ID] (参见 .claude/docs/director-gates.md)
- Context: [该门控下列出的字段]
- Await the verdict before proceeding.
```

对于并行生成（同一门控点多个总监同时）：

```
# 先对每个门控应用模式检查，然后生成所有通过的：
Spawn all [N] agents simultaneously via Task — issue all Task calls before
waiting for any result. Collect all verdicts before proceeding.
```

---

## 标准裁决格式

所有门控返回三种裁决之一。技能必须处理全部三种：

| 裁决 | 含义 | 默认操作 |
|---------|---------|----------------|
| **APPROVE / READY** | 没有问题。继续。 | 继续工作流程 |
| **CONCERNS [list]** | 存在问题但不阻塞。 | 通过 `AskUserQuestion` 呈现给用户 — 选项：`修订标注项` / `接受并继续` / `进一步讨论` |
| **REJECT / NOT READY [blockers]** | 阻塞性问题。不要继续。 | 将阻塞项呈现给用户。在解决前不要写入文件或推进阶段。 |

**升级规则**：当多个总监并行生成时，应用最严格的裁决 — 一个 NOT READY 覆盖所有 READY 裁决。

---

## 记录门控结果

门控解决后，在相关文档的状态头部记录裁决：

```markdown
> **[Director] Review ([GATE-ID])**: APPROVED [date] / CONCERNS (accepted) [date] / REVISED [date]
```

对于阶段门控，在 `docs/architecture/architecture.md` 或
`production/session-state/active.md` 中记录（根据适当情况）。

---

## Tier 1 — Creative Director Gates

Agent: `creative-director` | Model tier: Opus | Domain: 愿景、支柱、玩家体验

---

### CD-PILLARS — Pillar Stress Test

**触发时机**：在游戏支柱和反支柱定义后（brainstorm Phase 4，
或任何支柱修订时）

**待传递上下文**：
- 完整的支柱集合，包含名称、定义和设计测试
- 反支柱列表
- 核心幻想陈述
- 独特卖点 ("Like X, AND ALSO Y")

**提示**：
> "审查这些游戏支柱。它们是否可证伪 — 真实的设计决策是否可能不通过这个支柱？
> 它们在互相之间创造有意义的张力吗？它们能够将本游戏与最接近的可比游戏
> 区分开来吗？它们能够在实践中帮助解决设计争议，还是太模糊而无法
> 使用？返回每个支柱的具体反馈和整体裁决：APPROVE（强）、CONCERNS
> [列表]（需要锻炼），或 REJECT（弱 — 支柱没有承载力量）。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-GDD-ALIGN — GDD Pillar Alignment Check

**触发时机**：在系统GDD编写完成后（design-system、quick-design或任何
生成GDD的工作流程）

**待传递上下文**：
- GDD文件路径
- 游戏支柱（来自 `design/gdd/game-concept.md` 或 `design/gdd/game-pillars.md`）
- 本游戏的MDA美学目标
- 系统的 Player Fantasy 章节

**提示**：
> "审查这个系统GDD的支柱一致性。每个章节都服务于所述的支柱吗？
> 是否有与支柱矛盾或削弱支柱的机制或规则？Player Fantasy 章节与游戏的
> 核心幻想匹配吗？返回 APPROVE、CONCERNS
> [具体存在问题的章节]，或 REJECT [在该系统可实现之前必须重新设计的支柱违规项]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-SYSTEMS — Systems Decomposition Vision Check

**触发时机**：在系统索引由 `/map-systems` 编写完成后 — 在GDD编写开始前
验证完整的系统集合

**待传递上下文**：
- 系统索引路径（`design/gdd/systems-index.md`）
- 游戏支柱和核心幻想（来自 `design/gdd/game-concept.md`）
- 优先级层级分配（MVP / Vertical Slice / Alpha / Full Vision）
- 依赖关系图中识别的任何高风险或瓶颈系统

**提示**：
> "根据游戏的设计支柱审查这个系统分解。所有MVP层级系统能否
> 共同实现核心幻想？是否有机制不服务于任何所述支柱的系统 — 表明它们可能是
> 范围蔓延？是否有对支柱至关重要的玩家体验没有分配系统来实现？
> 核心循环需要的系统是否缺失？返回 APPROVE（系统服务于愿景）、CONCERNS [具体缺口或
> 与其支柱启示不一致的地方]，或 REJECT [根本性缺口 —
> 分解遗漏了关键设计意图，必须在GDD编写开始前修订]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-NARRATIVE — Narrative Consistency Check

**触发时机**：在叙事GDD、背景设定文档、对话规格或世界构建
文档编写完成后（team-narrative、故事系统的design-system、作家
交付物）

**待传递上下文**：
- 文档文件路径
- 游戏支柱
- 叙事方向简报或语气指南（如果在 `design/narrative/` 存在）
- 新文档引用的任何已有背景设定

**提示**：
> "审查此叙事内容与游戏支柱和已建立世界规则的一致性。语气是否
> 与游戏确立的声音匹配？是否与现有背景设定或世界构建存在矛盾？
> 内容是否服务于玩家体验支柱？返回 APPROVE、CONCERNS [具体不一致之处]，
> 或 REJECT [打破世界连贯性的矛盾]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-PLAYTEST — Player Experience Validation

**触发时机**：在游戏测试报告生成后（`/playtest-report`），或在
任何产生玩家反馈的会话后

**待传递上下文**：
- 游戏测试报告文件路径
- 游戏支柱和核心幻想陈述
- 正在测试的具体假设

**提示**：
> "根据游戏设计支柱和核心幻想审查此测试报告。玩家体验是否
> 与预期幻想匹配？是否有体现支柱漂移的系统性问题 — 单独看起来
> 正常但损害预期体验的机制？返回 APPROVE（核心幻想正在落地）、CONCERNS [预期与
> 实际体验之间的差距]，或 REJECT [核心幻想不存在 —
> 在进一步测试前需要重新设计]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### CD-PHASE-GATE — Creative Readiness at Phase Transition

**触发时机**：始终在 `/gate-check` — 与 TD-PHASE-GATE 和 PR-PHASE-GATE 并行生成

**待传递上下文**：
- 目标阶段名称
- 所有产出物列表（文件路径）
- 游戏支柱和核心幻想

**提示**：
> "从创意方向角度审查当前项目状态是否已准备好进入 [target phase] 阶段。
> 游戏支柱在所有设计产出物中得到忠实体现吗？当前状态保持了核心幻想吗？
> 跨GDD或架构的设计决策中是否有损害预期玩家体验的内容？
> 返回 READY、CONCERNS [列表]，或 NOT READY [阻塞项]。"

**裁决**: READY / CONCERNS / NOT READY

---

## Tier 1 — Technical Director Gates

Agent: `technical-director` | Model tier: Opus | Domain: 架构、引擎风险、性能

---

### TD-SYSTEM-BOUNDARY — System Boundary Architecture Review

**触发时机**：在 `/map-systems` Phase 3 依赖关系图确定后但GDD编写开始前 —
验证系统结构在架构上是否合理，避免团队在不合理的结构上投入GDD编写

**待传递上下文**：
- 系统索引路径（或如果索引尚未编写则提供依赖关系图摘要）
- 层级分配（Foundation / Core / Feature / Presentation / Polish）
- 完整的依赖关系图（每个系统依赖什么）
- 标记的任何瓶颈系统（大量依赖者）
- 发现的任何循环依赖及其建议解决方案

**提示**：
> "在GDD编写开始前，从架构角度审查这个系统分解。系统边界是否清晰
> — 每个系统是否拥有独特的关注点并且重叠最小？是否存在God Object风险（系统
> 做得太多）？依赖排序是否会导致实现序列问题？提议边界中是否有隐含的
> 共享状态问题会在实现时导致紧耦合？是否有Foundation层系统实际上
> 依赖于Feature层系统（反转依赖）？返回 APPROVE
> （边界在架构上是合理的 — 继续GDD编写）、CONCERNS
> [需要在GDD自身中解决的具体边界问题]，或 REJECT
> [根本性边界问题 — 系统结构将导致架构问题，必须在任何GDD编写之前重新构建]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-FEASIBILITY — Technical Feasibility Assessment

**触发时机**：在范围/可行性分析中最大技术风险被识别后
（brainstorm Phase 6、quick-design或任何早期阶段概念的技术未知）

**待传递上下文**：
- 概念的核心循环描述
- 目标平台
- 引擎选择（或"未确定"）
- 已识别的技术风险列表

**提示**：
> "审查这些技术风险，用于一款面向 [platform] 的 [genre] 游戏，使用
> [engine 或 '未确定引擎']。标记任何可能使所述概念无效的HIGH风险项，
> 任何影响引擎选择的引擎特定风险，以及任何单人开发者常常
> 低估的风险。返回 VIABLE（风险可管理）、CONCERNS [列表及缓解建议]，
> 或 HIGH RISK [阻塞项 — 需要修订概念或范围]。"

**裁决**: VIABLE / CONCERNS / HIGH RISK

---

### TD-ARCHITECTURE — Architecture Sign-Off

**触发时机**：在主架构文档草稿完成后（`/create-architecture`
Phase 7），以及任何重大架构修订后

**待传递上下文**：
- 架构文档路径（`docs/architecture/architecture.md`）
- 技术需求基线（TR-IDs 和数量）
- ADR列表及其状态
- 引擎知识缺口清单

**提示**：
> "审查这份主架构文档的技术合理性。检查：(1) 基线中的每个技术需求
> 都是否被架构决策覆盖？(2) 所有HIGH风险引擎领域是否已明确解决或标记为
> 开放问题？(3) API边界是否清晰、最小化且可实现？(4) 在开始实现前
> Foundation层ADR缺口是否已解决？返回 APPROVE、CONCERNS [列表]，
> 或 REJECT [在开始编码前必须解决的阻塞项]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-ADR — Architecture Decision Review

**触发时机**：在单个ADR编写完成后（`/architecture-decision`），在
其被标记为 Accepted 之前

**待传递上下文**：
- ADR文件路径
- 引擎版本和该领域的知识缺口风险等级
- 相关ADR（如果有）

**提示**：
> "审查这份架构决策记录。它是否有清晰的问题陈述和理由？被拒绝的
> 替代方案是否得到了认真考虑？Consequences章节是否诚实地承认了
> 权衡？引擎版本是否已打印？Post-cutoff API风险是否已标记？它是否链接到
> 所覆盖的GDD需求？返回 APPROVE、CONCERNS [具体缺口]，或 REJECT
> [决策不足以或做出了不合理的技术假设]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-ENGINE-RISK — Engine Version Risk Review

**触发时机**：当做出的架构决策触及post-cutoff引擎API时，
或在最终确定任何引擎特定实现方案之前

**待传递上下文**：
- 正在使用的具体API或功能
- 引擎版本和LLM知识截止日期（来自 `docs/engine-reference/[engine]/VERSION.md`）
- 相关的breaking-changes或deprecated-apis文档摘录

**提示**：
> "根据版本参考审查此引擎API使用。该API在 [engine version] 中是否存在？
> 自LLM知识截止以来，它的签名、行为或命名空间是否发生了变化？
> 是否有已知的弃用或post-cutoff替代方案？返回 APPROVE（按描述安全使用）、
> CONCERNS [实现前验证]，或 REJECT [API已变更 — 提供更正方法]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### TD-PHASE-GATE — Technical Readiness at Phase Transition

**触发时机**：始终在 `/gate-check` — 与 CD-PHASE-GATE 和 PR-PHASE-GATE 并行生成

**待传递上下文**：
- 目标阶段名称
- 架构文档路径（如果存在）
- 引擎参考路径
- ADR列表

**提示**：
> "从技术方向角度审查当前项目状态是否已准备好进入 [target phase] 阶段。
> 该阶段的架构是否合理？所有高风险引擎领域是否已解决？性能预算
> 是否现实且已记录？Foundation层决策是否足够完整以开始实现？
> 返回 READY、CONCERNS [列表]，或 NOT READY [阻塞项]。"

**裁决**: READY / CONCERNS / NOT READY

---

## Tier 1 — Producer Gates

Agent: `producer` | Model tier: Opus | Domain: 范围、时间线、依赖、生产风险

---

### PR-SCOPE — Scope and Timeline Validation

**触发时机**：在范围层级定义后（brainstorm Phase 6、quick-design或
任何生成MVP定义和时间线估估的工作流程）

**待传递上下文**：
- 完整愿景范围描述
- MVP定义
- 时间线估估
- 团队规模（单人 / 小团队 / 等等）
- 范围层级（如果时间耗尽会交付什么）

**提示**：
> "审查此范围估算。对于所述团队规模，MVP在所述时间线内是否可实现？
> 范围层级是否按风险正确排序 — 如果工作在某个层级停止，每个层级都能
> 交付一个可发布的产品吗？在时间压力下最可能的切割点是什么，它是
> 一个优雅的后备方案还是一个完全破坏的产品？返回 REALISTIC（范围与能力
> 匹配）、OPTIMISTIC [建议的具体调整]，或 UNREALISTIC [阻塞项 —
> 时间线或MVP必须修订]。"

**裁决**: REALISTIC / OPTIMISTIC / UNREALISTIC

---

### PR-SPRINT — Sprint Feasibility Review

**触发时机**：在确定Sprint计划前（`/sprint-plan`），以及在
任何Sprint中途范围变更后

**待传递上下文**：
- 建议的Sprint Story列表（标题、估估、依赖）
- 团队容量（可用小时）
- 当前Sprint候选列表债务（如果有）
- 里程碑约束

**提示**：
> "审查此Sprint计划的可行性。Story负载对于可用容量是否现实？
> Story是否按依赖正确排序？Story之间是否有隐藏的依赖可能在Sprint中途
> 阻止？考虑到技术复杂性，是否有任何Story被低估？返回 REALISTIC（计划
> 可实现）、CONCERNS [具体风险]，或 UNREALISTIC [Sprint必须
> 减少范围 — 确定哪些Story应该推迟]。"

**裁决**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-MILESTONE — Milestone Risk Assessment

**触发时机**：在里程碑审查（`/milestone-review`）时，在Sprint中期
回顾时，或当提出影响里程碑的范围变更时

**待传递上下文**：
- 里程碑定义和目标日期
- 当前完成百分比
- 阻塞Story数量
- Sprint速度数据（如果可用）

**提示**：
> "审查此里程碑状态。根据当前速度和阻塞Story数量，这个里程碑
> 能否在目标日期达成？从现在到里程碑之间的前3个生产风险是什么？
> 是否有应该裁减以保护里程碑日期的范围项，与不可谈判的项相比？
> 返回 ON TRACK、AT RISK [具体缓解措施]，或 OFF TRACK [日期必须滑动或
> 范围必须裁减 — 提供两种选项]。"

**裁决**: ON TRACK / AT RISK / OFF TRACK

---

### PR-EPIC — Epic Structure Feasibility Review

**触发时机**：在Epic由 `/create-epics` 定义后，在Story拆分前 —
验证Epic结构是可生产的，然后才调用 `/create-stories`

**待传递上下文**：
- 刚创建的所有Epic定义文件路径
- Epic索引路径（`production/epics/index.md`）
- 里程碑时间线和目标日期
- 团队容量（单人 / 小团队 / 规模）
- 正在Epic化的层级（Foundation / Core / Feature / 等等）

**提示**：
> "在Story拆分开始前，审查此Epic结构的生产可行性。Epic边界的范围
> 是否适当 — 每个Epic是否能在里程碑截止日期前实际完成？Epic是否按系统
> 依赖正确排序 — 是否有任何Epic需要另一个Epic的输出才能开始？
> 是否有任何Epic范围过小（太小，应该合并）或范围过大（太大，
> 应该拆分为2-3个聚焦的Epic）？Foundation层Epic的范围是否能够让Core层Epic
> 在Foundation完成后的下一个Sprint开始时启动？返回 REALISTIC（Epic结构是可生产的）、
> CONCERNS [在Story编写前需要的具体结构调整]，或 UNREALISTIC [Epic必须
> 拆分、合并或重新排序 — 在解决前无法开始Story拆分]。"

**裁决**: REALISTIC / CONCERNS / UNREALISTIC

---

### PR-PHASE-GATE — Production Readiness at Phase Transition

**触发时机**：始终在 `/gate-check` — 与 CD-PHASE-GATE 和 TD-PHASE-GATE 并行生成

**待传递上下文**：
- 目标阶段名称
- 存在的Sprint和里程碑产出物
- 团队规模和容量
- 当前阻塞Story数量

**提示**：
> "从生产角度审查当前项目状态是否已准备好进入 [target phase] 阶段。
> 对于所述时间线和团队规模，范围是否现实？依赖是否正确排序，以便
> 团队可以按序执行？是否有可能在前两个Sprint内导致阶段脱轨的里程碑或
> Sprint风险？返回 READY、CONCERNS [列表]，或 NOT READY [阻塞项]。"

**裁决**: READY / CONCERNS / NOT READY

---

## Tier 1 — Art Director Gates

Agent: `art-director` | Model tier: Sonnet | Domain: 视觉身份、美术圣经、视觉生产准备

---

### AD-CONCEPT-VISUAL — Visual Identity Anchor

**触发时机**：在游戏支柱锁定后（brainstorm Phase 4），与 CD-PILLARS 并行

**待传递上下文**：
- 游戏概念（电梯间推介、核心幻想、独特卖点）
- 完整的支柱集合，包含名称、定义和设计测试
- 目标平台（如果已知）
- 用户提到的任何参考游戏或视觉基准

**提示**：
> "基于这些游戏支柱和核心概念，提出2-3个不同的视觉身份方向。
> 对于每个方向提供：(1) 一条可以指导所有视觉决策的视觉规则
> （例如，'一切都必须运动'、'美在衰败中'），(2) 氛围和气氛目标，
> (3) 形状语言（尖锐/圆润/有机/几何偏重），(4) 色彩哲学
> （调色板方向，这个世界中颜色的含义）。要具体 — 避免通用描述。
> 一个方向应该直接服务于主要设计支柱。为每个方向命名。
> 推荐哪个最能服务所述支柱并解释原因。"

**裁决**: CONCEPTS (多个有效选项 — 用户选择) / STRONG (一个方向明显占优) / CONCERNS (支柱还未提供足够方向以区分视觉身份)

---

### AD-ART-BIBLE — Art Bible Sign-Off

**触发时机**：在Art Bible草稿完成后（`/art-bible`），资产生产开始前

**待传递上下文**：
- Art Bible路径（`design/art/art-bible.md`）
- 游戏支柱和核心幻想
- 平台和性能约束（如果在 `.claude/docs/technical-preferences.md` 中已配置）
- 头脑风暴期间选定的视觉身份锚点（来自 `design/gdd/game-concept.md`）

**提示**：
> "审查此Art Bible的完整性和内部一致性。色彩系统是否与氛围目标匹配？
> 形状语言是否从视觉身份陈述中衍生而来？资产标准是否在平台约束
> 内可实现？角色设计方向是否给了艺术家足够的信息而不过度规定？
> 章节之间是否有矛盾？外包团队能否从此文档生成资产而不需要额外
> 简报？返回 APPROVE（Art Bible已可生产）、CONCERNS [需要明确的具体章节]，
> 或 REJECT [在资产生产开始前必须解决的根本性不一致之处]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### AD-PHASE-GATE — Visual Readiness at Phase Transition

**触发时机**：始终在 `/gate-check` — 与 CD-PHASE-GATE、TD-PHASE-GATE 和 PR-PHASE-GATE 并行生成

**待传递上下文**：
- 目标阶段名称
- 存在的所有美术/视觉产出物列表（文件路径）
- 来自 `design/gdd/game-concept.md` 的视觉身份锚点（如果存在）
- 如果存在，Art Bible路径（`design/art/art-bible.md`）

**提示**：
> "从视觉方向角度审查当前项目状态是否已准备好进入 [target phase] 阶段。
> 视觉身份是否已在该阶段所需的水平上建立并记录？正确的视觉产出物
> 是否已到位？视觉团队能否在没有导致后续昂贵重做的视觉方向缺口的情况下
> 开始工作？是否有视觉决策正在超过最后负责时刻被推迟？
> 返回 READY、CONCERNS [可能导致生产重做的具体视觉方向缺口]，或 NOT READY
> [在此阶段成功之前必须存在的视觉阻塞项 — 指定缺失什么产出物以及
> 它在此阶段为什么重要]。"

**裁决**: READY / CONCERNS / NOT READY

---

## Tier 2 — Lead Gates

这些门控由编排技能和高级技能在需要领域
专家的可行性签署时调用。二级负责人使用Sonnet（默认）。

---

### LP-FEASIBILITY — Lead Programmer Implementation Feasibility

**触发时机**：在主架构文档编写完成后（`/create-architecture`
Phase 7b），或当新的架构模式被提出时

**待传递上下文**：
- 架构文档路径
- 技术需求基线摘要
- ADR列表及其状态

**提示**：
> "审查此架构的实现可行性。标记：(a) 任何在所述引擎和语言下
> 难以或不可能实现的决策，(b) 任何缺失的接口定义而程序员需要
> 自己发明，(c) 任何创造可避免技术债务或与标准 [engine] 习惯用法
> 矛盾的模式。返回 FEASIBLE、CONCERNS [列表]，或
> INFEASIBLE [使此架构按所写不可实现的阻塞项]。"

**裁决**: FEASIBLE / CONCERNS / INFEASIBLE

---

### LP-CODE-REVIEW — Lead Programmer Code Review

**触发时机**：在开发Story实现完成后（`/dev-story`、`/story-done`），或
作为 `/code-review` 的一部分

**待传递上下文**：
- 实现文件路径
- Story文件路径（用于验收标准）
- 相关GDD章节
- 管理该系统的ADR

**提示**：
> "根据Story验收标准和管辖ADR审查此实现。代码是否与架构边界定义匹配？
> 是否有违反编码标准或禁用模式？公共API是否可测试且已文档化？
> 与GDD规则相比是否有任何正确性问题？返回 APPROVE、CONCERNS [具体问题]，
> 或 REJECT [在合并前必须修订]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### QL-STORY-READY — QA Lead Story Readiness Check

**触发时机**：在Story被接受进入Sprint前 — 由 `/create-stories`、
`/story-readiness` 和 `/sprint-plan` 在Story选择期间调用

**待传递上下文**：
- Story文件路径
- Story类型（Logic / Integration / Visual/Feel / UI / Config/Data）
- 验收标准列表（来自Story的原文）
- Story覆盖的GDD需求（TR-ID和文本）

**提示**：
> "在Story进入Sprint前，审查此Story的验收标准的可测试性。所有标准
> 都是否足够具体，以便开发者可以毫无疑问地知道什么时候完成？
> 对于Logic类型Story：每个标准都能通过自动测试验证吗？对于Integration Story：
> 每个标准都能在可控的测试环境中观察到吗？标记太模糊而无法
> 实现的标准，并标记需要完整游戏构建才能测试的标准（标记这些为
> DEFERRED，而不是BLOCKED）。返回 ADEQUATE（标准可按所写实现）、
> GAPS [需要精练的具体标准]，或 INADEQUATE [标准太模糊
> — Story必须在进入Sprint前修订]。"

**裁决**: ADEQUATE / GAPS / INADEQUATE

---

### QL-TEST-COVERAGE — QA Lead Test Coverage Review

**触发时机**：在实现Story完成后，在标记Epic完成前，或在 `/gate-check` Production → Polish

**待传递上下文**：
- 已实现Story列表及其Story类型（Logic / Integration / Visual / UI / Config）
- `tests/` 中的测试文件路径
- 系统的GDD验收标准

**提示**：
> "审查这些实现Story的测试覆盖。所有Logic Story都是否被通过的单元测试
> 覆盖？Integration Story是否被集成测试或记录的游戏测试覆盖？GDD验收标准
> 每个是否都映射到至少一个测试？GDD Edge Cases章节中是否有未测试的
> 边界情况？返回 ADEQUATE（覆盖达到标准）、GAPS [具体缺失的测试]，或
> INADEQUATE [关键逻辑未被测试 — 不要推进]。"

**裁决**: ADEQUATE / GAPS / INADEQUATE

---

### ND-CONSISTENCY — Narrative Director Consistency Check

**触发时机**：在作家交付物（对话、背景设定、物品描述）
编写完成后，或当设计决策有叙事影响时

**待传递上下文**：
- 文档或内容文件路径
- 叙事圣经或语气指南路径（如果存在）
- 相关的世界构建规则
- 受影响的角色或阵营档案

**提示**：
> "审查此叙事内容的内部一致性和对已建立世界规则的遵守。角色声音
> 是否与其已建立的档案一致？背景设定是否与任何已确定的事实矛盾？
> 语气是否与游戏的叙事方向一致？返回 APPROVE、CONCERNS [需要修复的
> 具体不一致之处]，或 REJECT [打破叙事基础的矛盾]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

### AD-VISUAL — Art Director Visual Consistency Review

**触发时机**：在美术方向决策做出后，当新资产类型被
引入时，或当技术美术决策影响视觉风格时

**待传递上下文**：
- Art Bible路径（如果在 `design/art-bible.md` 存在）
- 正在审查的具体资产类型、风格决策或视觉方向
- 参考图像或风格描述
- 平台和性能约束

**提示**：
> "审查此视觉方向决策与已确立的美术风格和生产约束的一致性。它是否
> 与Art Bible匹配？它在平台性能预算内是否可实现？是否有创造技术风险的
> 资产管线流含义？返回 APPROVE、CONCERNS [具体调整]，或
> REJECT [风格违规或生产风险必须先解决]。"

**裁决**: APPROVE / CONCERNS / REJECT

---

## Parallel Gate Protocol

当工作流程需要多个总监在同一检查点（最常见于
`/gate-check`），同时生成所有Agent：

```
Spawn in parallel (issue all Task calls before waiting for any result):
1. creative-director  → gate CD-PHASE-GATE
2. technical-director → gate TD-PHASE-GATE
3. producer           → gate PR-PHASE-GATE
4. art-director       → gate AD-PHASE-GATE

Collect all four verdicts, then apply escalation rules:
- Any NOT READY / REJECT → overall verdict minimum FAIL
- Any CONCERNS → overall verdict minimum CONCERNS
- All READY / APPROVE → eligible for PASS (still subject to artifact checks)
```

---

## Adding New Gates

当新技能或工作流程需要新门控时：

1. 分配门控ID：`[DIRECTOR-PREFIX]-[DESCRIPTIVE-SLUG]`
   - 前缀：`CD-` `TD-` `PR-` `LP-` `QL-` `ND-` `AD-`
   - 为新Agent添加新前缀：`AudioDirector` → `AU-`，`UX` → `UX-`
2. 在适当的总监章节下添加门控，包含全部五个字段：
   Trigger、Context to pass、Prompt、Verdicts 和任何特殊处理说明
3. 在技能中仅按ID引用 — 永远不要把提示文本复制到技能中

---

## Gate Coverage by Stage

| 阶段 | 必需门控 | 可选门控 |
|-------|---------------|----------------|
| **概念** | CD-PILLARS, AD-CONCEPT-VISUAL | TD-FEASIBILITY, PR-SCOPE |
| **系统设计** | TD-SYSTEM-BOUNDARY, CD-SYSTEMS, PR-SCOPE, CD-GDD-ALIGN (每GDD) | ND-CONSISTENCY, AD-VISUAL |
| **技术搭建** | TD-ARCHITECTURE, TD-ADR (每ADR), LP-FEASIBILITY, AD-ART-BIBLE | TD-ENGINE-RISK |
| **预生产** | PR-EPIC, QL-STORY-READY (每Story), PR-SPRINT, 全部四个PHASE-GATEs (通过gate-check) | CD-PLAYTEST |
| **生产** | LP-CODE-REVIEW (每Story), QL-STORY-READY, PR-SPRINT (每Sprint) | PR-MILESTONE, QL-TEST-COVERAGE, AD-VISUAL |
| **抛光** | QL-TEST-COVERAGE, CD-PLAYTEST, PR-MILESTONE | AD-VISUAL |
| **发布** | 全部四个PHASE-GATEs (通过gate-check) | QL-TEST-COVERAGE |
