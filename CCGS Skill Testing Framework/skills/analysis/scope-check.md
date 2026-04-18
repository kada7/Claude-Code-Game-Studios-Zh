# Skill Test Spec: /scope-check

## Skill Summary

`/scope-check` 是一个 Haiku 层级的只读技能，用于分析功能、sprint 或 story 的范围蔓延风险。它读取 sprint 和 story 文件，并将其与活跃的 milestone 目标进行比较。它设计用于在规划之前或期间进行快速、低成本的检查。不会调用任何 director gate。不会写入任何文件。裁决结果：ON SCOPE、CONCERNS 或 SCOPE CREEP DETECTED。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：ON SCOPE、CONCERNS、SCOPE CREEP DETECTED
- [ ] 不需要 "May I write" 语言（只读技能）
- [ ] 具有下一步交接（基于裁决结果的操作）

---

## Director Gate Checks

无。Scope check 是一个只读的咨询技能；不会调用任何 gate。

---

## Test Cases

### Case 1: Happy Path — Sprint stories align with milestone goals

**Fixture:**
- `production/milestones/milestone-03.md` 列出 3 个目标：combat system、enemy AI、level loading
- `production/sprints/sprint-006.md` 包含 5 个 stories，全部标记为这 3 个目标之一
- `production/session-state/active.md` 引用 milestone-03 作为活跃的 milestone

**Input:** `/scope-check`

**Expected behavior:**
1. 技能从 milestone-03 读取活跃的 milestone 目标
2. 技能读取 sprint-006 stories 并检查每个 story 是否符合 milestone 目标
3. 所有 5 个 stories 都映射到 3 个目标之一
4. 技能输出一个映射表：story → milestone goal
5. 裁决结果为 ON SCOPE

**Assertions:**
- [ ] 每个 story 在输出中都映射到一个 milestone goal
- [ ] 当所有 stories 都映射到 milestone goals 时，裁决结果为 ON SCOPE
- [ ] 没有写入任何文件
- [ ] 技能不会修改 sprint 或 milestone 文件

---

### Case 2: Scope Creep Detected — Stories introducing systems not in milestone

**Fixture:**
- `production/milestones/milestone-03.md` 目标：combat、enemy AI、level loading
- `production/sprints/sprint-006.md` 包含 5 个 stories：
  - 3 个 stories 映射到 milestone 目标
  - 2 个 stories 引用 "online leaderboard" 和 "achievement system"（不在 milestone-03 中）

**Input:** `/scope-check`

**Expected behavior:**
1. 技能读取 milestone 目标和 sprint stories
2. 技能识别出 2 个没有匹配 milestone 目标的 stories
3. 技能命名超出范围的 stories："Online Leaderboard Feature"、"Achievement System Setup"
4. 裁决结果为 SCOPE CREEP DETECTED

**Assertions:**
- [ ] 超出范围的 stories 在输出中明确命名
- [ ] 当任何 story 没有 milestone 目标匹配时，裁决结果为 SCOPE CREEP DETECTED
- [ ] 技能不会自动删除 stories — 发现结果是咨询性的
- [ ] 输出建议将超出范围的 stories 推迟到后续的 milestone

---

### Case 3: No Milestone Defined — CONCERNS; scope cannot be validated

**Fixture:**
- `production/session-state/active.md` 没有 milestone 引用
- `production/milestones/` 目录存在但为空
- `production/sprints/sprint-006.md` 有 4 个 stories

**Input:** `/scope-check`

**Expected behavior:**
1. 技能读取 active.md — 发现没有 milestone 引用
2. 技能检查 `production/milestones/` — 没有找到 milestone 文件
3. 技能输出："No active milestone defined — scope cannot be validated"
4. 裁决结果为 CONCERNS

**Assertions:**
- [ ] 当没有定义 milestone 时，技能不会出错
- [ ] 输出明确说明范围验证需要 milestone 引用
- [ ] 裁决结果为 CONCERNS（没有数据时不是 ON SCOPE 或 SCOPE CREEP DETECTED）
- [ ] 输出建议运行 `/milestone-review` 或创建 milestone

---

### Case 4: Single Story Check — Evaluated against its parent epic

**Fixture:**
- 用户针对单个 story：`production/epics/combat/story-parry-timing.md`
- Story 引用父 epic：`epic-combat.md`
- `production/epics/combat/epic-combat.md` 的范围："melee combat mechanics"
- Story 标题："Implement parry timing window" — 匹配 epic 范围

**Input:** `/scope-check production/epics/combat/story-parry-timing.md`

**Expected behavior:**
1. 技能读取指定的 story 文件
2. 技能读取父 epic 以获取范围定义
3. 技能根据 epic 范围评估 story — "parry timing" 匹配 "melee combat"
4. 裁决结果为 ON SCOPE

**Assertions:**
- [ ] 接受单文件参数（story 路径，不是 sprint）
- [ ] 技能读取 story 文件中引用的父 epic
- [ ] 在单 story 模式下，story 根据 epic 范围评估（不是 milestone 范围）
- [ ] 当 story 匹配 epic 范围时，裁决结果为 ON SCOPE

---

### Case 5: Gate Compliance — No gate; PR may be consulted separately

**Fixture:**
- Sprint 有 2 个 SCOPE CREEP stories 和 3 个 ON SCOPE stories
- `review-mode.txt` 包含 `full`

**Input:** `/scope-check`

**Expected behavior:**
1. 技能读取 milestone 和 sprint；识别出 2 个 scope creep 项目
2. 无论 review mode 如何，都不会调用 director gate
3. 技能展示发现结果，裁决结果为 SCOPE CREEP DETECTED
4. 输出注明："Consider raising scope concerns with the Producer before sprint begins"
5. 技能结束，不写入任何文件

**Assertions:**
- [ ] 在任何 review mode 下都不会调用 director gate
- [ ] 建议咨询 Producer（不是强制要求）
- [ ] 没有写入任何文件
- [ ] 裁决结果为 SCOPE CREEP DETECTED

---

## Protocol Compliance

- [ ] 在分析之前读取 milestone 目标和 sprint/story 文件
- [ ] 将每个 story 映射到 milestone 目标（或标记为未映射）
- [ ] 不写入任何文件
- [ ] 不会调用任何 director gate
- [ ] 在 Haiku 模型层级运行（快速、低成本）
- [ ] 裁决结果为以下之一：ON SCOPE、CONCERNS、SCOPE CREEP DETECTED

---

## Coverage Notes

- 没有测试 sprint 文件本身不存在的情况；技能会输出 CONCERNS 裁决，并附带关于缺少 sprint 数据的消息。
- 没有明确测试部分范围重叠的情况（story 涉及 milestone 目标但也引入新范围）；实现可能将其分类为 CONCERNS 而不是 SCOPE CREEP DETECTED。