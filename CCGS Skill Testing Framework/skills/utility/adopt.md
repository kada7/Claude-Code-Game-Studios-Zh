# Skill Test Spec: /adopt

## Skill Summary

`/adopt` 审计现有项目的工件 — GDD、ADR、故事、基础设施文件以及 `technical-preferences.md` — 是否符合模板技能管道的格式规范。它按严重程度（BLOCKING / HIGH / MEDIUM / LOW）分类每个差距，编写一个编号且有序的迁移计划，并在用户通过 `AskUserQuestion` 明确批准后将其写入 `docs/adoption-plan-[date].md`。

此技能不同于 `/project-stage-detect`（后者检查存在什么）。`/adopt` 检查已存在的内容是否实际适用于模板的技能。

没有导演关卡适用。该技能不会调用任何导演 Agent。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含严重程度层级关键词：BLOCKING、HIGH、MEDIUM、LOW
- [ ] 在写入采用计划前包含 “May I write” 或 `AskUserQuestion` 语言
- [ ] 在末尾有一个下一步交接（例如，提供立即修复最高优先级差距的选项）

---

## Director Gate Checks

无。`/adopt` 是一个棕地审计工具。没有导演关卡适用。

---

## Test Cases

### Case 1: Happy Path — 所有 GDD 合规，无差距，COMPLIANT

**Fixture:**
- `design/gdd/` 包含 3 个 GDD 文件；每个文件都具有所有 8 个必需部分的内容
- `docs/architecture/adr-0001.md` 存在，具有 `## Status`、`## Engine Compatibility` 和所有其他必需部分
- `production/stage.txt` 存在
- `docs/architecture/tr-registry.yaml` 和 `docs/architecture/control-manifest.md` 存在
- `technical-preferences.md` 中配置了引擎

**Input:** `/adopt`

**Expected behavior:**
1. 技能发出 “Scanning project artifacts...” 然后静默读取所有工件
2. 报告检测到的阶段、GDD 数量、ADR 数量、故事数量
3. 阶段 2 审计：所有 3 个 GDD 具有全部 8 个部分，Status 字段存在且有效
4. ADR 审计：所有必需部分存在
5. 基础设施审计：所有关键文件存在
6. 阶段 3：零个 BLOCKING，零个 HIGH，零个 MEDIUM，零个 LOW 差距
7. 摘要报告：“No blocking gaps — this project is template-compatible”
8. 使用 `AskUserQuestion` 询问是否编写计划；用户选择写入
9. 采用计划被写入 `docs/adoption-plan-[date].md`
10. 阶段 7 提供下一步操作：无阻塞差距，提供下一步选项

**Assertions:**
- [ ] 技能在呈现任何输出前静默读取
- [ ] “Scanning project artifacts...” 出现在静默读取阶段之前
- [ ] 差距计数显示 0 BLOCKING、0 HIGH、0 MEDIUM（或仅 LOW）
- [ ] 在编写采用计划前使用 `AskUserQuestion`
- [ ] 采用计划文件被写入 `docs/adoption-plan-[date].md`
- [ ] 阶段 7 提供具体的下一步操作（不仅仅是列表）

---

### Case 2: Non-Compliant Documents — GDD 缺少部分，NEEDS MIGRATION

**Fixture:**
- `design/gdd/` 包含 2 个 GDD 文件：
  - `combat.md` — 缺少 `## Acceptance Criteria` 和 `## Formulas` 部分
  - `movement.md` — 所有 8 个部分存在
- 一个 ADR（`adr-0001.md`）缺少 `## Status` 部分
- `docs/architecture/tr-registry.yaml` 不存在

**Input:** `/adopt`

**Expected behavior:**
1. 技能扫描所有工件
2. 阶段 2 审计发现：
   - `combat.md`：2 个缺少的部分（Acceptance Criteria、Formulas）
   - `adr-0001.md`：缺少 `## Status` — BLOCKING 影响
   - `tr-registry.yaml`：缺少 — HIGH 影响
3. 阶段 3 分类：
   - BLOCKING：`adr-0001.md` 缺少 `## Status`（story-readiness 静默通过）
   - HIGH：`tr-registry.yaml` 缺少；`combat.md` 缺少 Acceptance Criteria（无法生成故事）
   - MEDIUM：`combat.md` 缺少 Formulas
4. 阶段 4 构建有序迁移计划：
   - 步骤 1 (BLOCKING): 向 `adr-0001.md` 添加 `## Status` — 命令：`/architecture-decision retrofit`
   - 步骤 2 (HIGH): 运行 `/architecture-review` 以引导 tr-registry.yaml
   - 步骤 3 (HIGH): 向 `combat.md` 添加 Acceptance Criteria — 命令：`/design-system retrofit`
   - 步骤 4 (MEDIUM): 向 `combat.md` 添加 Formulas
5. 差距预览将 BLOCKING 项目显示为项目符号（实际文件名），HIGH/MEDIUM 显示为计数
6. `AskUserQuestion` 是否编写计划；批准后写入
7. 阶段 7 提供立即修复最高优先级差距（ADR Status）的选项

**Assertions:**
- [ ] BLOCKING 差距在差距预览中被列为显式的文件名项目符号
- [ ] HIGH 和 MEDIUM 在差距预览中显示为计数
- [ ] 迁移计划项目按 BLOCKING 优先顺序排列
- [ ] 每个计划项目包括修复命令或手动步骤
- [ ] 在写入前使用 `AskUserQuestion`
- [ ] 阶段 7 提供立即修复第一个 BLOCKING 项目的选项

---

### Case 3: Mixed State — 部分文档合规，部分不合规，部分报告

**Fixture:**
- 4 个 GDD 文件：2 个完全合规，2 个有差距（一个缺少 Tuning Knobs，一个缺少 Edge Cases）
- ADR：3 个文件 — 2 个合规，1 个缺少 `## ADR Dependencies`
- 故事：5 个文件 — 3 个具有 TR-ID 引用，2 个没有
- 基础设施：所有关键文件存在；`technical-preferences.md` 已完全配置

**Input:** `/adopt`

**Expected behavior:**
1. 技能审计所有工件类型
2. 审计摘要显示总计：“4 GDDs (2 fully compliant, 2 with gaps); 3 ADRs (2 fully compliant, 1 with gaps); 5 stories (3 with TR-IDs, 2 without)”
3. 差距分类：
   - 无 BLOCKING 差距
   - HIGH：1 个 ADR 缺少 `## ADR Dependencies`
   - MEDIUM：2 个 GDD 缺少部分；2 个故事缺少 TR-IDs
   - LOW：无
4. 迁移计划首先列出 HIGH 差距，然后按顺序列出 MEDIUM 差距
5. 包含说明：“Existing stories continue to work — do not regenerate stories that are in progress or done”
6. `AskUserQuestion` 是否编写计划；批准后写入

**Assertions:**
- [ ] 显示每个工件的合规计数（N 个合规，M 个有差距）
- [ ] 采用计划中包含现有故事兼容性说明
- [ ] 无 BLOCKING 差距导致迁移计划中没有 BLOCKING 部分
- [ ] HIGH 差距在计划排序中位于 MEDIUM 差距之前
- [ ] 在写入前使用 `AskUserQuestion`

---

### Case 4: No Artifacts Found — 新项目，引导运行 /start

**Fixture:**
- 仓库在 `design/gdd/`、`docs/architecture/`、`production/epics/` 中没有文件
- `production/stage.txt` 不存在
- `src/` 目录不存在或文件数少于 10 个
- 没有 game-concept.md，没有 systems-index.md

**Input:** `/adopt`

**Expected behavior:**
1. 阶段 1 存在性检查未找到任何工件
2. 技能推断为 “Fresh” — 无需迁移棕地工作
3. 使用 `AskUserQuestion`：
   - “This looks like a fresh project — no existing artifacts found. `/adopt` is for projects with work to migrate. What would you like to do?”
   - 选项：“Run `/start`”、“My artifacts are in a non-standard location”、“Cancel”
4. 技能停止 — 无论用户选择如何，不继续进行审计

**Assertions:**
- [ ] 当未找到任何工件时使用 `AskUserQuestion`（不是纯文本消息）
- [ ] `/start` 作为一个命名选项提供
- [ ] 技能在问题后停止 — 不运行任何审计阶段
- [ ] 不写入采用计划文件

---

### Case 5: Director Gate Check — 无关卡；adopt 是一个工具审计技能

**Fixture:**
- 包含混合合规和不合规 GDD 的项目

**Input:** `/adopt`

**Expected behavior:**
1. 技能完成完整审计并生成迁移计划
2. 在任何时候都不会生成导演 Agent
3. 输出中不出现任何关卡 ID（CD-*, TD-*, AD-*, PR-*）
4. 在技能运行期间不调用 `/gate-check`

**Assertions:**
- [ ] 不调用任何导演关卡
- [ ] 不出现任何关卡跳过消息
- [ ] 技能在没有关卡裁决的情况下到达计划编写或取消阶段

---

## Protocol Compliance

- [ ] 在静默读取阶段之前发出 “Scanning project artifacts...”
- [ ] 在呈现任何结果之前静默读取所有工件
- [ ] 在询问是否写入之前显示 Adoption Audit Summary 和 Gap Preview
- [ ] 在写入采用计划文件之前使用 `AskUserQuestion`
- [ ] 采用计划写入 `docs/adoption-plan-[date].md` — 而不是任何其他路径
- [ ] 迁移计划项目排序：BLOCKING 优先，HIGH 其次，MEDIUM 第三，LOW 最后
- [ ] 阶段 7 始终提供单一的、具体的下一步操作（不是通用列表）
- [ ] 从不重新生成现有工件 — 仅填补现有工件的空白
- [ ] 在任何时候都不调用导演关卡

---

## Coverage Notes

- `gdds`、`adrs`、`stories` 和 `infra` 参数模式缩小审计范围；每个模式遵循与完整审计相同的模式，但仅限于该工件类型。在此不单独进行 fixture 测试。
- systems-index.md 附带的状态值检查（BLOCKING）是一个特殊情况，在编写计划前触发立即修复提议；不单独测试。
- review-mode.txt 提示（阶段 6b）在计划编写后运行，如果 `production/review-mode.txt` 不存在；在此不单独测试。