---
name: gate-check
description: "验证进入下一阶段开发的准备情况。生成通过/关注/不通过的裁决，附带具体阻塞项和所需工件。当用户问'我们是否准备好进入X阶段'、'能否进入生产阶段'、'检查是否可以开始下一阶段'、'通过关卡'时使用。"
argument-hint: "[target-phase: systems-design | technical-setup | pre-production | production | polish | release] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task, AskUserQuestion
model: opus
---

# Phase Gate Validation

此技能验证项目是否准备好进入下一个开发阶段。它检查必需的工件、质量标准和阻塞项。

**与 `/project-stage-detect` 的区别**: 该技能是诊断性的 ("我们在哪里？")。
此技能是规定性的 ("我们准备好推进了吗？" 带有正式的裁决)。

## Production Stages (7)

项目通过这些阶段推进：

1. **Concept** — 头脑风暴，游戏概念文档
2. **Systems Design** — 映射系统，编写 GDDs
3. **Technical Setup** — 引擎配置，架构决策
4. **Pre-Production** — 原型制作，垂直切片验证
5. **Production** — 功能开发（Epic/Feature/Task 跟踪激活）
6. **Polish** — 性能，游戏测试，bug 修复
7. **Release** — 发布准备，认证

**当关卡通过时**，将新阶段名称写入 `production/stage.txt`
（单行，例如 `Production`）。这会立即更新状态行。

---

## 1. Parse Arguments

**目标阶段:** `$ARGUMENTS[0]`（空白 = 自动检测当前阶段，然后验证下一个转换）

还要解析审查模式（一次，存储用于此运行的所有关卡生成）：
1. 如果传入了 `--review [full|lean|solo]` → 使用它
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

注意：在 `solo` 模式下，director 生成（CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE）被跳过 — gate-check 变为仅工件存在性检查。在 `lean` 模式下，所有四个 director 仍然运行（关卡是 lean 模式的目的）。

- **带参数**: `/gate-check production` — 验证该特定阶段的准备情况
- **无参数**: 使用与 `/project-stage-detect` 相同的启发式方法自动检测当前阶段，然后**在运行前与用户确认**：

  使用 `AskUserQuestion`：
  - 提示："检测到阶段：**[current stage]**。正在为 [Current] → [Next] 转换运行关卡。是否正确？"
  - 选项：
    - `[A] 是 — 运行此关卡`（如果选中，显示第二个小部件列出所有关卡选项：Concept → Systems Design, Systems Design → Technical Setup, Technical Setup → Pre-Production, Pre-Production → Production, Production → Polish, Polish → Release）
  
  当未提供参数时，不要跳过此确认步骤。

---

## 2. Phase Gate Definitions

### Gate: Concept → Systems Design

**Required Artifacts:**
- [ ] `design/gdd/game-concept.md` 存在且有内容
- [ ] Game pillars 已定义（在 concept doc 或 `design/gdd/game-pillars.md` 中）
- [ ] Visual Identity Anchor 部分存在于 `design/gdd/game-concept.md` 中（来自 brainstorm Phase 4 art-director 输出）

**Quality Checks:**
- [ ] Game concept 已被审查 (`/design-review` 裁决不是 MAJOR REVISION NEEDED)
- [ ] Core loop 已被描述和理解
- [ ] Target audience 已被识别
- [ ] Visual Identity Anchor 包含一行视觉规则和至少 2 个支持性视觉原则

---

### Gate: Systems Design → Technical Setup

**Required Artifacts:**
- [ ] Systems index 存在于 `design/gdd/systems-index.md`，至少列出了 MVP 系统
- [ ] 所有 MVP-tier GDDs 存在于 `design/gdd/` 并单独通过 `/design-review`
- [ ] Cross-GDD 审查报告存在于 `design/gdd/`（来自 `/review-all-gdds`）

**Quality Checks:**
- [ ] 所有 MVP GDDs 通过单独的设计审查（8 个必需的部分，没有 MAJOR REVISION NEEDED 裁决）
- [ ] `/review-all-gdds` 裁决不是 FAIL（跨 GDD 一致性和设计理论检查通过）
- [ ] `/review-all-gdds` 标记的所有跨 GDD 一致性问题已解决或明确接受
- [ ] System dependencies 已在 systems index 中映射并且是双向一致的
- [ ] MVP priority tier 已定义
- [ ] 没有标记过时的 GDD 引用（较早的 GDD 已更新以反映在较晚的 GDD 中做出的决定）

---

### Gate: Technical Setup → Pre-Production

**Required Artifacts:**
- [ ] Engine 已选择 (CLAUDE.md Technology Stack 不是 `[CHOOSE]`)
- [ ] Technical preferences 已配置 (`.claude/docs/technical-preferences.md` 已填充)
- [ ] Art bible 存在于 `design/art/art-bible.md`，至少有 Sections 1–4 (Visual Identity Foundation)
- [ ] 至少 3 个 Architecture Decision Records 在 `docs/architecture/` 中，涵盖
      Foundation-layer 系统（scene management, event architecture, save/load）
- [ ] Engine reference docs 存在于 `docs/engine-reference/[engine]/`
- [ ] Test framework 已初始化：`tests/unit/` 和 `tests/integration/` 目录存在
- [ ] CI/CD test workflow 存在于 `.github/workflows/tests.yml`（或等效文件）
- [ ] 至少一个示例测试文件存在以确认框架正常运行
- [ ] Master architecture document 存在于 `docs/architecture/architecture.md`
- [ ] Architecture traceability index 存在于 `docs/architecture/architecture-traceability.md`
- [ ] `/architecture-review` 已运行（审查报告文件存在于 `docs/architecture/`）
- [ ] `design/accessibility-requirements.md` 存在并已提交 accessibility tier
- [ ] `design/ux/interaction-patterns.md` 存在（pattern library 已初始化，即使是最小化的）

**Quality Checks:**
- [ ] Architecture decisions 涵盖核心系统（rendering, input, state management）
- [ ] Technical preferences 设置了命名约定和性能预算
- [ ] Accessibility tier 已定义并记录（即使是 "Basic" 也可以接受 — 未定义则不行）
- [ ] 至少一个屏幕的 UX spec 已开始（通常 main menu 或 core HUD 是在 Technical Setup 期间设计的）
- [ ] 所有 ADRs 都有 **Engine Compatibility section** 并带有引擎版本标记
- [ ] 所有 ADRs 都有 **GDD Requirements Addressed section** 并带有明确的 GDD 链接
- [ ] 没有 ADR 引用 `docs/engine-reference/[engine]/deprecated-apis.md` 中列出的 API
- [ ] 所有 HIGH RISK 引擎域（根据 VERSION.md）已在 architecture document 中明确解决
      或标记为 open questions
- [ ] Architecture traceability matrix 有 **zero Foundation layer gaps**
      （所有 Foundation requirements 必须在 Pre-Production 之前有 ADR 覆盖）

**ADR Circular Dependency Check**: 对于 `docs/architecture/` 中的所有 ADRs，读取每个 ADR 的
"ADR Dependencies" / "Depends On" 部分。构建依赖图（ADR-A → ADR-B 表示
A 依赖于 B）。如果检测到任何循环（例如 A→B→A，或 A→B→C→A）：
- 标记为 **FAIL**: "Circular ADR dependency: [ADR-X] → [ADR-Y] → [ADR-X].
  在循环存在时，两者都无法达到 Accepted。移除一条 'Depends On' 边来
  打破循环。"

**Engine Validation**（首先读取 `docs/engine-reference/[engine]/VERSION.md`）：
- [ ] 接触 post-cutoff 引擎 API 的 ADRs 标记有 Knowledge Risk: HIGH/MEDIUM
- [ ] `/architecture-review` 引擎审计显示没有已弃用的 API 使用
- [ ] 所有 ADRs 同意相同的引擎版本（没有过时的版本引用）

---

### Gate: Pre-Production → Production

**Required Artifacts:**
- [ ] 至少 1 个 prototype 在 `prototypes/` 中并带有 README
- [ ] First sprint plan 存在于 `production/sprints/`
- [ ] Art bible 已完成（所有 9 个部分）并且 AD-ART-BIBLE 签署裁决记录在 `design/art/art-bible.md` 中
- [ ] Character visual profiles 存在于 narrative docs 中引用的关键角色
- [ ] 来自 systems index 的所有 MVP-tier GDDs 已完成
- [ ] Master architecture document 存在于 `docs/architecture/architecture.md`
- [ ] 至少 3 个 ADRs 涵盖 Foundation-layer decisions 存在于 `docs/architecture/`
- [ ] Control manifest 存在于 `docs/architecture/control-manifest.md`
      （由 `/create-control-manifest` 从 Accepted ADRs 生成）
- [ ] Epics 定义在 `production/epics/` 中，至少有 Foundation 和 Core
      layer epics 存在（使用 `/create-epics layer: foundation` 和
      `/create-epics layer: core` 来创建它们，然后对每个 epic 使用 `/create-stories [epic-slug]`）
- [ ] Vertical Slice build 存在并且可玩（不仅仅是 scope-defined）
- [ ] Vertical Slice 已通过至少 3 个 session 进行游戏测试（internal OK）
- [ ] Vertical Slice playtest report 存在于 `production/playtests/` 或等效位置
- [ ] UX specs 存在于关键屏幕：main menu, core gameplay HUD（在 `design/ux/`），pause menu
- [ ] HUD design document 存在于 `design/ux/hud.md`（如果游戏有 in-game HUD）
- [ ] 所有关键屏幕 UX specs 已通过 `/ux-review`（裁决 APPROVED 或 NEEDS REVISION accepted）

**Quality Checks:**
- [ ] **Core loop fun is validated** — playtest data confirms the central mechanic is enjoyable, not just functional. 明确检查 Vertical Slice playtest report。
- [ ] UX specs 覆盖所有来自 MVP-tier GDDs 的 UI Requirements 部分
- [ ] Interaction pattern library 记录了关键屏幕中使用的模式
- [ ] 来自 `design/accessibility-requirements.md` 的 Accessibility tier 在所有关键屏幕 UX specs 中得到解决
- [ ] Sprint plan 引用来自 `production/epics/` 的真实 story file paths
      （不只是 GDDs — stories 必须嵌入 GDD req ID + ADR reference）
- [ ] **Vertical Slice 是 COMPLETE**，不仅仅是 scoped — build 展示了从头到尾的完整 core loop。至少一个完整的 [start → challenge → resolution] 循环工作。
- [ ] Architecture document 在 Foundation 或 Core layers 中没有未解决的 open questions
- [ ] 所有 ADRs 都有 Engine Compatibility sections 并带有引擎版本标记
- [ ] 所有 ADRs 都有 ADR Dependencies sections（即使所有字段都是 "None"）
- [ ] 手动验证确认 GDDs + architecture + epics 是一致的
      （如果最近没有完成，运行 `/review-all-gdds` 和 `/architecture-review`）
- [ ] **Core fantasy is delivered** — 至少一个 playtester 独立描述了一种与核心系统 GDDs 的 Player Fantasy 部分相匹配的体验（没有被提示）。

**Vertical Slice Validation**（如果任何项目是 NO 则 FAIL）：
- [ ] 人类在没有开发者指导的情况下玩过 core loop
- [ ] 游戏在玩的头 2 分钟内传达该做什么
- [ ] Vertical Slice build 中没有关键的 "fun blocker" bugs
- [ ] Core mechanic 交互起来感觉良好（这是一个主观检查 — 询问用户）

> **注意**: 如果任何 Vertical Slice Validation 项目是 FAIL，裁决自动为 FAIL
> 无论其他检查如何。在没有经过验证的 Vertical Slice 的情况下推进是
> 游戏开发中 production failure 的 #1 原因（根据 155 个项目的 GDC postmortem 数据）。

---

### Gate: Production → Polish

**Required Artifacts:**
- [ ] `src/` 有活跃代码组织到子系统中
- [ ] 来自 GDD 的所有 core mechanics 已实现（交叉引用 `design/gdd/` 与 `src/`）
- [ ] Main gameplay path 可从头到尾玩
- [ ] Test files 存在于 `tests/unit/` 和 `tests/integration/` 中，涵盖 Logic 和 Integration stories
- [ ] 来自此 sprint 的所有 Logic stories 在 `tests/unit/` 中有相应的单元测试文件
- [ ] Smoke check 已运行并获得 PASS 或 PASS WITH WARNINGS 裁决 — 报告存在于 `production/qa/`
- [ ] QA plan 存在于 `production/qa/`（由 `/qa-plan` 生成）涵盖此 sprint 或 final production sprint
- [ ] QA sign-off report 存在于 `production/qa/`（由 `/team-qa` 生成）并带有裁决 APPROVED 或 APPROVED WITH CONDITIONS
- [ ] 至少 3 个不同的 playtest sessions 记录在 `production/playtests/`
- [ ] Playtest reports 涵盖：new player experience, mid-game systems, 和 difficulty curve
- [ ] Fun hypothesis from Game Concept 已被明确验证或修订

**Quality Checks:**
- [ ] Tests 正在通过（通过 Bash 运行测试套件）
- [ ] 任何 bug tracker 或 known issues 中没有 critical/blocker bugs
- [ ] Core loop 按设计运行（与 GDD 验收标准比较）
- [ ] Performance 在预算内（检查 technical-preferences.md 目标）
- [ ] Playtest findings 已被审查并且关键的 fun issues 已解决（不仅仅是记录）
- [ ] 没有识别出 "confusion loops" — 游戏中没有 >50% 的 playtesters 被困住而不知道为什么的点
- [ ] Difficulty curve 与 Difficulty Curve design doc 匹配（如果在 `design/difficulty-curve.md` 存在）
- [ ] 所有实现的屏幕都有相应的 UX specs（没有 "designed in-code" 的屏幕）
- [ ] Interaction pattern library 与实现中使用的所有模式保持最新
- [ ] Accessibility compliance 根据 `design/accessibility-requirements.md` 中提交的 tier 进行验证

---

### Gate: Polish → Release

**Required Artifacts:**
- [ ] Milestone plan 中的所有功能已实现
- [ ] Content 已完成（design docs 中引用的所有 levels, assets, dialogue 存在）
- [ ] Localization strings 已外部化（`src/` 中没有硬编码的玩家 facing 文本）
- [ ] QA test plan 存在 (`/qa-plan` output in `production/qa/`)
- [ ] QA sign-off report 存在 (`/team-qa` output — APPROVED 或 APPROVED WITH CONDITIONS)
- [ ] 此 sprint 的所有 Must Have story test evidence 存在（Logic/Integration: 测试文件通过；Visual/Feel/UI: `production/qa/evidence/` 中的签署文档）
- [ ] Smoke check 在 release candidate build 上干净地通过（PASS verdict）
- [ ] 没有来自先前 sprint 的测试回归（测试套件完全通过）
- [ ] Balance data 已被审查（`/balance-check` 已运行）
- [ ] Release checklist 已完成（`/release-checklist` 或 `/launch-checklist` 已运行）
- [ ] Store metadata 已准备（如果适用）
- [ ] Changelog / patch notes 已起草

**Quality Checks:**
- [ ] Full QA pass 由 `qa-lead` 签署
- [ ] 所有测试通过
- [ ] 所有目标平台的性能目标已达到
- [ ] 没有已知的 critical, high, 或 medium-severity bugs
- [ ] Accessibility basics 已覆盖（remapping, text scaling 如果适用）
- [ ] Localization 已为所有目标语言验证
- [ ] Legal requirements 已满足（EULA, privacy policy, age ratings 如果适用）
- [ ] Build 干净地编译和打包

---

## 3. Run the Gate Check

**在运行工件检查之前**，如果它存在，读取 `docs/consistency-failures.md`。
提取 Domain 与目标阶段匹配的条目（例如，如果检查
Systems Design → Technical Setup，拉取 Economy, Combat, 或任何 GDD domain 中的条目；
如果检查 Technical Setup → Pre-Production，拉取 Architecture, Engine 中的条目）。
将这些作为上下文携带 — 目标 domain 中的反复冲突模式需要
对这些特定检查进行更严格的审查。

对于目标关卡中的每个项目：

### Artifact Checks
- 使用 `Glob` 和 `Read` 验证文件存在并有有意义的内容
- 不要只检查存在性 — 验证文件有真实内容（不仅仅是模板头部）
- 对于代码检查，验证目录结构和文件计数

**Systems Design → Technical Setup 关卡 — cross-GDD review check**：
使用 `Glob('design/gdd/gdd-cross-review-*.md')` 来找到 `/review-all-gdds` 报告。
如果没有匹配的文件，将 "cross-GDD review report exists" 工件标记为 **FAIL** 并
显著显示它："No `/review-all-gdds` report found in `design/gdd/`. Run
`/review-all-gdds` before advancing to Technical Setup."
如果找到文件，读取它并检查裁决行：FAIL 裁决意味着 cross-GDD
consistency check 失败，必须在推进之前解决。

### Quality Checks
- 对于测试检查：如果配置了测试运行器，通过 `Bash` 运行测试套件
- 对于设计审查检查：`Read` GDD 并检查 8 个必需的部分
- 对于性能检查：`Read` technical-preferences.md 并与任何数据进行比较
  `tests/performance/` 或最近的 `/perf-profile` 输出中的性能分析数据
- 对于本地化检查：`Grep` `src/` 中的硬编码字符串

### Cross-Reference Checks
- 将 `design/gdd/` 文档与 `src/` 实现进行比较
- 检查 architecture docs 中引用的每个系统都有相应的代码
- 验证 sprint plans 引用真实的工作项

---

## 4. Collaborative Assessment

对于无法自动验证的项目，**询问用户**：

- "我无法自动验证 core loop 是否运行良好。它经过游戏测试了吗？"
- "没有找到 playtest report。是否进行了非正式测试？"
- "没有性能分析数据可用。你想运行 `/perf-profile` 吗？"

**永远不要假设 PASS 用于无法验证的项目。** 将它们标记为 MANUAL CHECK NEEDED。

---

## 4b. Director Panel Assessment

在生成最终裁决之前，使用 `.claude/docs/director-gates.md` 中的 parallel gate protocol 将四个 director 都作为 **parallel subagents** 通过 Task 生成。同时发出所有四个 Task 调用 — 不要在开始下一个之前等待一个完成。

**并行生成：**

1. **`creative-director`** — 关卡 **CD-PHASE-GATE** (`.claude/docs/director-gates.md`)
2. **`technical-director`** — 关卡 **TD-PHASE-GATE** (`.claude/docs/director-gates.md`)
3. **`producer`** — 关卡 **PR-PHASE-GATE** (`.claude/docs/director-gates.md`)
4. **`art-director`** — 关卡 **AD-PHASE-GATE** (`.claude/docs/director-gates.md`)

传递给每个：目标阶段名称、存在的工件列表，以及该关卡定义中列出的上下文字段。

**收集所有四个响应，然后呈现 Director Panel summary：**

```
## Director Panel Assessment

Creative Director:  [READY / CONCERNS / NOT READY]
  [feedback]

Technical Director: [READY / CONCERNS / NOT READY]
  [feedback]

Producer:           [READY / CONCERNS / NOT READY]
  [feedback]

Art Director:       [READY / CONCERNS / NOT READY]
  [feedback]
```

**应用于裁决：**
- 任何 director 返回 NOT READY → 裁决最少为 FAIL（用户可以用明确的确认覆盖）
- 任何 director 返回 CONCERNS → 裁决最少为 CONCERNS
- 所有四个 READY → 有资格获得 PASS（仍受第 3 节中的工件和质量检查约束）

---

## 5. Output the Verdict

```
## Gate Check: [Current Phase] → [Target Phase]

**Date**: [date]
**Checked by**: gate-check skill

### Required Artifacts: [X/Y present]
- [x] design/gdd/game-concept.md — 存在, 2.4KB
- [ ] docs/architecture/ — 缺失 (no ADRs found)
- [x] production/sprints/ — 存在, 1 sprint plan

### Quality Checks: [X/Y passing]
- [x] GDD has 8/8 required sections
- [ ] Tests — FAILED (tests/unit/ 中有 3 个失败)
- [?] Core loop playtested — MANUAL CHECK NEEDED

### Blockers
1. **No Architecture Decision Records** — 在进入 production 之前运行 `/architecture-decision` 创建一个
   涵盖核心系统架构。
2. **3 test failures** — 在推进之前修复 tests/unit/ 中的失败测试。

### Recommendations
- [解决阻塞项的优先操作]
- [不是阻塞项的可选改进]

### Verdict: [PASS / CONCERNS / FAIL]
- **PASS**: 所有必需的工件存在，所有质量检查通过
- **CONCERNS**: 存在轻微差距但可以在下一阶段解决
- **FAIL**: 必须在推进之前解决关键阻塞项
```

---

## 5a. Chain-of-Verification

在第 5 阶段起草裁决后，在最终确定之前挑战它。

**第 1 步 — 生成 5 个挑战问题** 旨在反驳裁决：

对于 **PASS** draft：
- "哪些质量检查我通过实际读取文件验证的，与推断它们通过相对？"
- "有没有我标记为 PASS 的 MANUAL CHECK NEEDED 项目没有用户确认？"
- "我是否确认所有列出的工件都有真实内容，不仅仅是空头部？"
- "我是否决为轻微的任何阻塞项实际上可能阻止阶段成功？"
- "我最不自信的是哪一项检查，为什么？"

对于 **CONCERNS** draft：
- "考虑到项目当前状态，任何列出的 CONCERN 是否可以提升为阻塞项？"
- "concern 可以在下一阶段解决，还是会随着时间的推移而加剧？"
- "我是否将任何 FAIL 条件软化为 CONCERN 以避免更难的裁决？"
- "我是否没有检查可能揭示额外阻塞项的工件？"
- "所有 CONCERNS 结合在一起是否会造成一个阻塞问题，即使每个单独都是轻微的？"

对于 **FAIL** draft：
- "我是否准确区分了硬阻塞项和强有力的建议？"
- "我是否对任何 PASS 项目过于宽松？"
- "我是否遗漏了用户应该知道的任何额外阻塞项？"
- "我可以提供一条通往 PASS 的最小路径 — 必须改变的具体 3 件事？"
- "失败条件是可解决的，还是表明存在更深的设计问题？"

**第 2 步 — 独立回答每个问题**。
不要引用草稿裁决文本 — 重新检查特定文件或询问用户。

**第 3 步 — 如果需要则修订：**
- 如果任何答案揭示了遗漏的阻塞项 → 升级裁决（PASS→CONCERNS 或 CONCERNS→FAIL）
- 如果任何答案揭示了夸大其词的阻塞项 → 只有在引用具体证据的情况下才降级
- 如果答案一致 → 确认裁决不变

**第 4 步 — 在最终报告输出中注明验证**：
`Chain-of-Verification: [N] questions checked — verdict [unchanged | revised from X to Y]`

---

## 6. Update Stage on PASS

当裁决是 **PASS** 并且用户确认他们想推进时：

1. 将新阶段名称写入 `production/stage.txt`（单行，无尾随换行符）
2. 这会立即更新所有未来 session 的状态行

示例：如果通过 "Pre-Production → Production" 关卡：
```bash
echo -n "Production" > production/stage.txt
```

**总是在写入前询问**: "关卡通过。我可以将 `production/stage.txt` 更新为 'Production' 吗？"

---

## 7. Closing Next-Step Widget

在裁决呈现并且任何 stage.txt 更新完成后，使用 `AskUserQuestion` 关闭结构化的下一步提示。

**根据刚刚运行的关卡定制选项：**

对于 **systems-design PASS**：
```
关卡通过。接下来你想做什么？
[A] 运行 /create-architecture — 生成你的 master architecture blueprint 和 ADR work plan（推荐的下一步）
[B] 先设计更多 GDDs — 当所有 MVP 系统完成时再回来
[C] 在此 session 停止
```

> **systems-design PASS 注意**: `/create-architecture` 是在编写任何 ADR 之前必需的下一步。它生成 master architecture document 和要编写的 ADRs 的优先级列表。在没有此步骤的情况下运行 `/architecture-decision` 意味着在没有蓝图的情况下编写 ADR — 自行承担跳过它的风险。

对于 **technical-setup PASS**：
```
关卡通过。接下来你想做什么？
[A] 开始 Pre-Production — 开始为 Vertical Slice 制作原型
[B] 先编写更多 ADRs — 运行 /architecture-decision [next-system]
[C] 在此 session 停止
```

对于所有其他关卡，提供该阶段最合理的两个下一步加上 "Stop here"。

---

## 8. Follow-Up Actions

根据裁决，建议具体的下一步：

- **没有 art bible？** → `/art-bible` 创建视觉 identity 规范
- **Art bible 存在但没有 asset specs？** → `/asset-spec system:[name]` 从批准的 GDDs 生成每个 asset 的视觉规格和生成提示
- **没有 game concept？** → `/brainstorm` 创建一个
- **没有 systems index？** → `/map-systems` 将 concept 分解为系统
- **缺少 design docs？** → `/reverse-document` 或委托给 `game-designer`
- **需要小的设计更改？** → `/quick-design` 用于约 4 小时以下的更改（绕过完整的 GDD pipeline）
- **没有 UX specs？** → `/ux-design [screen name]` 编写 specs，或 `/team-ui [feature]` 用于完整 pipeline
- **UX specs 未审查？** → `/ux-review [file]` 或 `/ux-review all` 来验证
- **没有 accessibility requirements doc？** → 使用 `AskUserQuestion` 提供立即创建它：
  - 提示："关卡需要 `design/accessibility-requirements.md`。我现在就创建它吗？"
  - 选项：`立即创建 — 我会选择一个 accessibility tier`, `我自己创建`, `暂时跳过`
  - 如果 "立即创建"：使用第二个 `AskUserQuestion` 询问 tier：
    - 提示："哪个 accessibility tier 适合这个项目？"
    - 选项：`Basic — remapping + subtitles only (最低工作量)`, `Standard — Basic + colorblind modes + scalable UI`, `Comprehensive — Standard + motor accessibility + full settings menu`, `Exemplary — Comprehensive + external audit + full customization`
  - 然后使用 `.claude/docs/templates/accessibility-requirements.md` 的模板写入 `design/accessibility-requirements.md`，填入所选的 tier。确认："我可以写入 `design/accessibility-requirements.md` 吗？"
- **没有 interaction pattern library？** → `/ux-design patterns` 初始化它
- **GDDs 未交叉审查？** → `/review-all-gdds`（在所有 MVP GDDs 单独批准后运行）
- **Cross-GDD 一致性问题？** → 修复标记的 GDDs，然后重新运行 `/review-all-gdds`
- **没有 test framework？** → `/test-setup` 为引擎搭建框架
- **当前 sprint 没有 QA plan？** → 在开始实现之前运行 `/qa-plan sprint` 生成一个
- **缺少 ADRs？** → `/architecture-decision` 用于单个决策
- **没有 master architecture doc？** → `/create-architecture` 用于完整 blueprint
- **ADRs 缺少 engine compatibility sections？** → 重新运行 `/architecture-decision`
  或手动将 Engine Compatibility sections 添加到现有的 ADRs
- **缺少 control manifest？** → `/create-control-manifest`（需要 Accepted ADRs）
- **缺少 epics？** → `/create-epics layer: foundation` 然后 `/create-epics layer: core`（需要 control manifest）
- **epic 缺少 stories？** → `/create-stories [epic-slug]`（在每个 epic 创建后运行）
- **Stories 未准备好实现？** → 在开发者接手之前运行 `/story-readiness` 验证 stories
- **Tests failing？** → 委托给 `lead-programmer` 或 `qa-tester`
- **没有 playtest data？** → `/playtest-report`
- **少于 3 个 playtest sessions？** → 在推进之前运行更多 playtests。使用 `/playtest-report` 组织 findings。
- **没有 Difficulty Curve doc？** → 考虑在 polish 之前在 `design/difficulty-curve.md` 创建一个
- **没有 player journey document？** → 使用 player journey template 创建 `design/player-journey.md`
- **需要快速的 sprint check？** → `/sprint-status` 获取当前 sprint 进度快照
- **Performance 未知？** → `/perf-profile`
- **未本地化？** → `/localize`
- **准备好发布了？** → `/launch-checklist`

---

## Collaborative Protocol

此技能遵循协作设计原则：

1. **首先扫描**: 检查所有工件和质量关卡
2. **询问未知**: 不要假设你无法验证的事情为 PASS
3. **呈现 findings**: 显示完整清单及状态
4. **用户决定**: 裁决是建议 — 用户做最终决定
5. **获得批准**: "我可以将此关卡检查报告写入 production/gate-checks/ 吗？"

**永远不要**阻止用户推进 — 裁决是建议性的。记录风险
并让用户决定是否尽管有 concerns 也要继续。
