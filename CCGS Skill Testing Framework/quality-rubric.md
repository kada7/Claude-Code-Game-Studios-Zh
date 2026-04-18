# Skill 质量评分标准

由 `/skill-test category [name|all]` 使用，用于评估技能在结构合规性之外的质量。
每个类别定义了 4–5 个与技能工作相关的二进制 PASS/FAIL 指标。

当技能的书面指令明确满足标准时，指标为 PASS。
当指令缺失、模糊或矛盾时，指标为 FAIL。
当指令部分满足标准时，指标为 WARN。

---

## Skill 类别

### `gate`

**Skills**: gate-check

Gate 技能控制阶段转换。它们必须在不自动推进阶段的情况下强制保证正确性，并且必须尊重三种审查模式。

| 指标 | PASS 标准 |
|---|---|
| **G1 — 审查模式读取** | 技能在决定生成哪些 directors 之前读取 `production/session-state/review-mode.txt`（或等效文件） |
| **G2 — 完整模式：生成全部 4 个 directors** | 在 `full` 模式下，所有 4 个 Tier-1 directors（CD、TD、PR、AD）的 PHASE-GATE 提示被并行调用 |
| **G3 — 精简模式：仅 PHASE-GATE** | 在 `lean` 模式下，仅运行 `*-PHASE-GATE` 门；跳过内联门（CD-PILLARS、TD-ARCHITECTURE 等） |
| **G4 — 单人模式：无 directors** | 在 `solo` 模式下，不生成任何 director 门；每个门都标记为 "skipped — Solo mode" |
| **G5 — 无自动推进** | 技能在未通过 "May I write" 获得明确用户确认的情况下，从不写入 `production/stage.txt` |

---

### `review`

**Skills**: design-review, architecture-review, review-all-gdds

Review 技能读取文档并生成结构化裁决。它们主要为只读操作，且不得在分析阶段触发 director 门。

| 指标 | PASS 标准 |
|---|---|
| **R1 — 只读强制执行** | 技能未经明确用户批准不修改被审查的文档；任何写入操作（审查日志、索引更新）都需通过 "May I write" 确认 |
| **R2 — 8 章节检查** | 技能显式评估所有 8 个必需的 GDD 章节（或等效的架构章节） |
| **R3 — 正确的裁决词汇** | 裁决必须是以下之一：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED（设计）或 PASS / CONCERNS / FAIL（架构） |
| **R4 — 分析期间无 director 门** | 技能在其分析阶段不生成 director 门；分析后的 director 审查（如 architecture-review）在技能范围和风险适当时是可接受的 |
| **R5 — 结构化发现** | 输出在最终裁决前包含每章节状态表或检查清单 |

> **例外情况：**
> - `design-review`：在 allowed-tools 中包含 `Write, Edit` 以支持可选的 "Revise now" 路径（所有写入都需用户批准）并写入审查日志。R1 满足，因为被审查的文档从未被静默修改。
> - `architecture-review`：在其分析完成后生成 TD-ARCHITECTURE 和 LP-FEASIBILITY 门。这是有意为之 —— 架构审查风险高，受益于 director 签署。R4 满足，因为这些门在分析后运行，而非分析期间。

---

### `authoring`

**Skills**: design-system, quick-design, architecture-decision, ux-design, ux-review, art-bible, create-architecture

Authoring 技能协作创建或更新设计文档。完整的 GDD/UX 创作技能使用逐章节循环；轻量级创作技能使用适用于其较小范围的单稿模式。

| 指标 | PASS 标准 |
|---|---|
| **A1 — 逐章节循环** | 完整的创作技能（design-system、ux-design、art-bible）一次创作一个章节，在继续进行下一章节前呈现内容以获得批准。轻量级技能（quick-design、architecture-decision、create-architecture）可以草拟完整文档然后请求批准 —— 对于约 4 小时实现范围内的文档，单稿是可接受的。 |
| **A2 — 每章节的 May-I-write** | 完整的创作技能在每次章节写入前询问 "May I write this to [filepath]?"。轻量级技能仅对完整文档询问一次。 |
| **A3 — 重构模式** | 技能检测目标文件是否已存在，并提出来更新特定章节而非覆盖整个文档。始终创建新文件的轻量级技能（quick-design）豁免此项。 |
| **A4 — 正确层级的 director 门** | 如果为此技能定义了 director 门（例如，CD-GDD-ALIGN、TD-ADR），则其在正确的模式阈值（full/lean）下运行 —— 而非在 solo 模式下 |
| **A5 — 骨架优先** | 完整的创作技能在填充内容前创建包含所有章节标题的文件骨架，以在会话中断时保留进度。轻量级技能豁免此项。 |

> **完整创作技能**（必须通过全部 5 个指标）：`design-system`、`ux-design`、`art-bible`
> **轻量级创作技能**（A1、A2、A5 使用单稿模式；仅创建新文件的技能豁免 A3）：`quick-design`、`architecture-decision`、`create-architecture`
> **审查模式技能**（依据 review 指标评估）：`ux-review`

---

### `readiness`

**Skills**: story-readiness, story-done

Readiness 技能在实现前后验证故事。它们必须生成多维裁决，并正确与 director 门模式集成。

| 指标 | PASS 标准 |
|---|---|
| **RD1 — 多维检查** | 技能检查 ≥3 个独立维度（例如，设计、架构、范围、DoD）并分别报告每个维度 |
| **RD2 — 三级裁决层次** | 裁决层次明确定义：READY/COMPLETE > NEEDS WORK/COMPLETE WITH NOTES > BLOCKED |
| **RD3 — BLOCKED 需要外部操作** | BLOCKED 裁决保留给无法仅由故事作者解决的问题（例如，提议的 ADR、无法解决的依赖） |
| **RD4 — 正确模式下的 director 门** | QL-STORY-READY 或 LP-CODE-REVIEW 门在 `full` 模式下生成，在 `lean`/`solo` 下跳过并显示跳过的消息 |
| **RD5 — 下一故事交接** | 完成后，技能从当前冲刺中找出下一个 READY 故事 |

---

### `pipeline`

**Skills**: create-epics, create-stories, dev-story, create-control-manifest, propagate-design-change, map-systems

Pipeline 技能生成其他技能消费的工件。它们必须以正确的模式写入文件，尊重层次/优先级排序，并在写入前进行门控。

| 指标 | PASS 标准 |
|---|---|
| **P1 — 正确的输出模式** | 每个生成的文件遵循项目模板（EPIC.md、故事 frontmatter 等）；技能引用模板路径 |
| **P2 — 层次/优先级排序** | 生成史诗或故事的技能尊重层次排序（核心 → 扩展 → 元）和优先级字段 |
| **P3 — 每个工件前的 May-I-write** | 技能在创建每个输出文件前询问 "May I write [artifact]?"，而不是一次性批量批准所有文件 |
| **P4 — 正确层级的 director 门** | 范围内的门（PR-EPIC、QL-STORY-READY、LP-CODE-REVIEW 等）在 `full` 模式下运行，在 `lean`/`solo` 模式下跳过并注明跳过 |
| **P5 — 写入前读取** | 技能在生成工件前读取相关的 GDD/ADR/清单以确保对齐 |

---

### `analysis`

**Skills**: consistency-check, balance-check, content-audit, code-review, tech-debt,
scope-check, estimate, perf-profile, asset-audit, security-audit, test-evidence-review, test-flakiness

Analysis 技能扫描项目并展示发现。它们在分析期间为只读操作，必须在建议任何文件写入前询问。

| 指标 | PASS 标准 |
|---|---|
| **AN1 — 只读扫描** | 分析阶段仅使用 Read/Glob/Grep 工具；扫描期间不使用 Write 或 Edit |
| **AN2 — 结构化发现表** | 输出包含发现表或检查清单（不仅限于散文），每个发现附带严重性/优先级 |
| **AN3 — 无自动写入** | 任何建议的文件写入（例如，技术债务登记、修复补丁）都需通过 "May I write" 确认 |
| **AN4 — 分析期间无 director 门** | 分析技能不生成 director 门；它们生成发现以供人工审查 |

---

### `team`

**Skills**: team-combat, team-narrative, team-audio, team-level, team-ui, team-qa,
team-release, team-polish, team-live-ops

Team 技能为部门协调多个专家 agent。它们必须生成正确的 agent，并行运行独立的 agent，并立即展示阻塞。

| 指标 | PASS 标准 |
|---|---|
| **T1 — 命名的 agent 列表** | 技能明确命名其生成哪些 agent 以及以何种顺序 |
| **T2 — 独立时并行** | 输入不相互依赖的 agent 并行生成（单条消息，多个 Task 调用） |
| **T3 — BLOCKED 展示** | 如果任何生成的 agent 返回 BLOCKED 或失败，技能立即展示并停止依赖工作 —— 从不静默跳过 |
| **T4 — 在继续前收集所有裁决** | 依赖阶段等待所有并行 agent 完成后再继续 |
| **T5 — 无参数时的用法错误** | 如果缺少必需参数（例如，功能名称），技能输出用法提示并停止，不生成 agent |

---

### `sprint`

**Skills**: sprint-plan, sprint-status, milestone-review, retrospective, changelog, patch-notes

Sprint 技能读取生产状态并生成报告或计划工件。它们在特定模式阈值下具有 PR-SPRINT 或 PR-MILESTONE 门。

| 指标 | PASS 标准 |
|---|---|
| **SP1 — 读取冲刺/里程碑状态** | 技能在生成输出前读取 `production/sprints/` 或 `production/milestones/` |
| **SP2 — 正确的冲刺门** | PR-SPRINT（用于计划）或 PR-MILESTONE（用于里程碑审查）门在 `full` 模式下运行，在 `lean`/`solo` 下跳过 |
| **SP3 — 结构化输出** | 输出使用一致的结构（速度表、风险列表、行动项）而非自由散文 |
| **SP4 — 无自动提交** | 技能在未通过 "May I write" 确认的情况下从不写入冲刺文件或里程碑记录 |

---

### `utility`

**Skills**: start, help, brainstorm, onboard, adopt, hotfix, prototype, localize,
launch-checklist, release-checklist, smoke-check, soak-test, test-setup, test-helpers,
regression-suite, qa-plan, bug-triage, bug-report, playtest-report, asset-spec,
reverse-document, project-stage-detect, setup-engine, skill-test, skill-improve,
day-one-patch, 以及任何上述类别中未包含的其他技能

Utility 技能通过 7 项标准静态检查。如果它们恰好生成 director 门，则门模式逻辑也必须正确。

| 指标 | PASS 标准 |
|---|---|
| **U1 — 通过全部 7 项静态检查** | `/skill-test static [name]` 返回 COMPLIANT，其中 0 个 FAIL |
| **U2 — 门模式正确（如适用）** | 如果技能生成任何 director 门，则其读取 review-mode 并正确应用 full/lean/solo 逻辑 |

---

## Agent 类别

用于验证 `tests/agents/` 中的 agent 规范文件。

### `director`

**Agents**: creative-director, technical-director, art-director, producer

| 指标 | PASS 标准 |
|---|---|
| **D1 — 正确的裁决词汇** | 返回 APPROVE / CONCERNS / REJECT（或领域等效词汇：producer 为 REALISTIC/CONCERNS/UNREALISTIC） |
| **D2 — 领域边界尊重** | 不在其声明的领域之外做出约束性决策 |
| **D3 — 冲突升级** | 当两个部门冲突时，升级到正确的上级（creative-director 或 technical-director）而非单方面决定 |
| **D4 — Opus 模型层级** | Agent 根据 coordination-rules.md 分配为 Opus 模型 |

### `lead`

**Agents**: lead-programmer, qa-lead, narrative-director, audio-director, game-designer,
systems-designer, level-designer

| 指标 | PASS 标准 |
|---|---|
| **L1 — 领域裁决** | 返回领域特定的裁决（例如，lead-programmer 为 FEASIBLE/INFEASIBLE，qa-lead 为 PASS/FAIL） |
| **L2 — 升级到共享上级** | 领域外冲突升级到 creative-director（设计）或 technical-director（技术） |
| **L3 — Sonnet 模型层级** | Agent 根据 coordination-rules.md 分配为 Sonnet 模型（默认） |

### `specialist`

**Agents**: gameplay-programmer, ai-programmer, technical-artist, sound-designer,
engine-programmer, tools-programmer, network-programmer, security-engineer,
accessibility-specialist, ux-designer, ui-programmer, performance-analyst, prototyper,
qa-tester, writer, world-builder

| 指标 | PASS 标准 |
|---|---|
| **S1 — 保持在领域内** | 明确限定自身为其声明的领域；推迟领域外请求 |
| **S2 — 无约束性跨领域决策** | 不单方面决定属于另一专家的事项 |
| **S3 — 正确推迟** | 领域外请求被重定向到正确的 agent，而非静默拒绝 |

### `engine`

**Agents**: godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
godot-shader-specialist, godot-gdextension-specialist, unity-specialist, unity-ui-specialist,
unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist,
unreal-specialist, ue-blueprint-specialist, ue-gas-specialist, ue-umg-specialist,
ue-replication-specialist

| 指标 | PASS 标准 |
|---|---|
| **E1 — 版本感知** | 在建议 API 调用前参考 `docs/engine-reference/` 中的引擎版本；标记截止后风险 |
| **E2 — 文件路由** | 将文件类型路由到正确的子专家（例如，`.gdshader` → godot-shader-specialist，而非 godot-gdscript-specialist） |
| **E3 — 引擎特定模式** | 强制执行引擎特定习惯用法（例如，GDScript 静态类型、C# 属性导出、Blueprint 函数库） |

### `qa`

**Agents**: qa-tester, qa-lead, security-engineer, accessibility-specialist

| 指标 | PASS 标准 |
|---|---|
| **Q1 — 生成工件而非代码** | 主要输出是测试用例、错误报告或覆盖缺口 —— 而非实现代码 |
| **Q2 — 证据格式** | 测试用例遵循项目的测试证据格式（根据 coding-standards.md 的单元/集成/视觉/UI） |
| **Q3 — 无范围蔓延** | 不提议新功能；标记缺口供人工决定 |

### `operations`

**Agents**: devops-engineer, release-manager, live-ops-designer, community-manager,
analytics-engineer, economy-designer, localization-lead

| 指标 | PASS 标准 |
|---|---|
| **O1 — 领域所有权明确** | Agent 描述清晰说明其负责的内容（流水线、发布、经济等） |
| **O2 — 推迟实现** | 不编写游戏逻辑或引擎代码；委托给适当的专家 |
| **O3 — 工具集匹配角色** | frontmatter 中的 `allowed-tools` 匹配角色的操作（非编码）性质 |