# Skill Test Spec: /brainstorm

## Skill Summary

`/brainstorm` 促进引导式游戏概念构思。它呈现 2-4 个带有优缺点分析的概念选项，让用户选择并完善一个概念，然后生成结构化的 `design/gdd/game-concept.md` 文档。该技能是协作式的 — 在提出选项前会询问问题，并迭代直到用户批准概念方向。

在 `full` 审查模式下，概念草案完成后会并行生成四个导演关卡：CD-PILLARS (creative-director)、AD-CONCEPT-VISUAL (art-director)、TD-FEASIBILITY (technical-director) 和 PR-SCOPE (producer)。在 `lean` 模式下，所有 4 个内联关卡都会被跳过（lean 模式仅运行 PHASE-GATE，而 brainstorm 没有）。在 `solo` 模式下，所有关卡都会被跳过。该技能在写入 `design/gdd/game-concept.md` 前会询问 “May I write”。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：APPROVED、REJECTED、CONCERNS
- [ ] 包含 “May I write” 协作协议语言（用于 game-concept.md）
- [ ] 在末尾有一个下一步交接（`/map-systems`）
- [ ] 在 full 模式下记录 4 个导演关卡：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
- [ ] 记录所有 4 个关卡在 lean 和 solo 模式下被跳过

---

## Director Gate Checks

在 `full` 模式下：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY 和 PR-SCOPE 在用户批准概念草案后并行生成。

在 `lean` 模式下：所有 4 个内联关卡都被跳过（brainstorm 没有 PHASE-GATE，所以 lean 模式跳过所有内容）。输出将全部 4 个记为：“[GATE-ID] skipped — lean mode”。

在 `solo` 模式下：所有 4 个关卡都被跳过。输出将全部 4 个记为：“[GATE-ID] skipped — solo mode”。

---

## Test Cases

### Case 1: Happy Path — Full 模式，3 个概念，用户选择一个，所有 4 个导演批准

**Fixture:**
- 没有现有的 `design/gdd/game-concept.md`
- `production/session-state/review-mode.txt` 包含 `full`

**Input:** `/brainstorm`

**Expected behavior:**
1. 技能询问用户关于类型、范围和目标感受的问题
2. 技能呈现 3 个带有优缺点分析的概念选项
3. 用户选择一个概念
4. 技能将选定的概念详细阐述为结构化草案
5. 所有 4 个导演关卡并行生成：CD-PILLARS、AD-CONCEPT-VISUAL、TD-FEASIBILITY、PR-SCOPE
6. 全部 4 个返回 APPROVED
7. 技能询问 “May I write `design/gdd/game-concept.md`?”
8. 批准后写入概念

**Assertions:**
- [ ] 恰好呈现 3 个概念选项（不是 1 个，不是 5+）
- [ ] 所有 4 个导演关卡并行生成（非顺序）
- [ ] 所有 4 个关卡在 “May I write” 询问前完成
- [ ] 在写入前询问 “May I write `design/gdd/game-concept.md`?”
- [ ] 未经用户批准不写入概念文件
- [ ] 存在向 `/map-systems` 的下一步交接

---

### Case 2: Failure Path — CD-PILLARS 返回 REJECT

**Fixture:**
- 概念草案已完成
- `production/session-state/review-mode.txt` 包含 `full`
- CD-PILLARS 关卡返回 REJECT：“The concept has no identifiable creative pillar”

**Input:** `/brainstorm`

**Expected behavior:**
1. CD-PILLARS 关卡返回 REJECT 并提供具体反馈
2. 技能向用户展示拒绝结果
3. 概念不被写入文件
4. 询问用户：重新思考概念方向，或覆盖拒绝
5. 如果重新思考：技能返回到概念选项阶段

**Assertions:**
- [ ] 当 CD-PILLARS 返回 REJECT 时不写入概念
- [ ] 拒绝反馈逐字显示给用户
- [ ] 用户可以选择重新思考或覆盖
- [ ] 如果用户选择重新思考，技能返回到概念构思阶段

---

### Case 3: Lean Mode — 所有 4 个关卡跳过；用户确认后写入概念

**Fixture:**
- 没有现有游戏概念
- `production/session-state/review-mode.txt` 包含 `lean`

**Input:** `/brainstorm`

**Expected behavior:**
1. 概念选项被呈现，用户选择一个
2. 概念被详细阐述为结构化草案
3. 所有 4 个导演关卡被跳过 — 每个被注明：“[GATE-ID] skipped — lean mode”
4. 技能询问用户确认概念已准备好写入
5. 确认后询问 “May I write `design/gdd/game-concept.md`?”
6. 批准后写入概念

**Assertions:**
- [ ] 所有 4 个关卡跳过注释出现：“CD-PILLARS skipped — lean mode”、“AD-CONCEPT-VISUAL skipped — lean mode”、“TD-FEASIBILITY skipped — lean mode”、“PR-SCOPE skipped — lean mode”
- [ ] 仅用户确认后写入概念（lean 模式下无需导演批准）
- [ ] 写入前仍询问 “May I write”

---

### Case 4: Solo Mode — 所有关卡跳过；仅用户批准后写入概念

**Fixture:**
- 没有现有游戏概念
- `production/session-state/review-mode.txt` 包含 `solo`

**Input:** `/brainstorm`

**Expected behavior:**
1. 概念选项被呈现，用户选择一个
2. 概念草案展示给用户
3. 所有 4 个导演关卡被跳过 — 每个注明 “solo mode”
4. 询问 “May I write `design/gdd/game-concept.md`?”
5. 用户批准后写入概念

**Assertions:**
- [ ] 所有 4 个跳过注释带有 “solo mode” 标签
- [ ] 不生成导演 Agent
- [ ] 仅用户批准后写入概念
- [ ] 行为在此技能的其他方面等同于 lean 模式

---

### Case 5: Director Gate — PR-SCOPE 返回 CONCERNS（范围过大）

**Fixture:**
- 概念草案已完成
- `production/session-state/review-mode.txt` 包含 `full`
- PR-SCOPE 关卡返回 CONCERNS：“The concept scope would require 18+ months for a solo developer”

**Input:** `/brainstorm`

**Expected behavior:**
1. PR-SCOPE 关卡返回 CONCERNS 并提供具体的范围反馈
2. 技能向用户展示范围顾虑
3. 在写入前将范围顾虑记录在概念草案中
4. 询问用户：缩小范围、接受顾虑并记录它们，或重新思考
5. 如果接受顾虑：概念被写入，同时嵌入 “Scope Risk” 注释

**Assertions:**
- [ ] PR-SCOPE 的顾虑在 “May I write” 询问前展示给用户
- [ ] 技能不会在不展示范围顾虑的情况下写入概念
- [ ] 如果用户接受：范围顾虑记录在概念文件中
- [ ] 技能不会由于 PR-SCOPE 的 CONCERNS 而自动拒绝概念（由用户决定）

---

## Protocol Compliance

- [ ] 在用户承诺前呈现 2-4 个带有优缺点分析的概念选项
- [ ] 用户在导演关卡被调用前确认概念方向
- [ ] 在 full 模式下所有 4 个导演关卡并行生成
- [ ] 所有 4 个关卡在 lean 和 solo 模式下都被跳过 — 每个按名称注明
- [ ] 写入前询问 “May I write `design/gdd/game-concept.md`?”
- [ ] 以下一步交接结束：`/map-systems`

---

## Coverage Notes

- AD-CONCEPT-VISUAL 关卡（艺术总监可行性）与其他 3 个关卡在并行生成中分组 — 不单独进行 fixture 测试。
- 迭代概念细化循环（用户拒绝所有选项，技能生成新的选项）未进行 fixture 测试 — 它遵循与选项选择阶段相同的模式。
- game-concept.md 文档结构（必需部分）在技能正文中定义，未在测试断言中重新列举。