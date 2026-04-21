---
name: milestone-review
description: "生成全面的里程碑进度审查，包括功能完整性、质量指标、风险评估和通过/不通过建议。在里程碑检查点或评估里程碑截止日期准备情况时使用。"
argument-hint: "[milestone-name|current] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
---

## 阶段 0：解析参数

提取里程碑名称（`current` 或特定名称）并解析审查模式（一次，存储用于此运行的所有关卡生成）：
1. 如果传入了 `--review [full|lean|solo]` → 使用它
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

有关完整检查模式，请参阅 `.claude/docs/director-gates.md`。

---

## 阶段 1：加载里程碑数据

从 `production/milestones/` 读取里程碑定义。如果参数是 `current`，使用最近修改的里程碑文件。

从 `production/sprints/` 读取此里程碑内所有冲刺的冲刺报告。

---

## 阶段 2：扫描代码库健康度

- 扫描表示未完成工作的 `TODO`, `FIXME`, `HACK` 标记
- 检查 `production/risk-register/` 中的风险登记册

---

## 阶段 3：生成里程碑审查

```markdown
# Milestone Review: [Milestone Name]

## Overview
- **Target Date**: [Date]
- **Current Date**: [Today]
- **Days Remaining**: [N]
- **Sprints Completed**: [X/Y]

## Feature Completeness

### Fully Complete
| Feature | Acceptance Criteria | Test Status |
|---------|-------------------|-------------|

### Partially Complete
| Feature | % Done | Remaining Work | Risk to Milestone |
|---------|--------|---------------|------------------|

### Not Started
| Feature | Priority | Can Cut? | Impact of Cutting |
|---------|----------|----------|------------------|

## Quality Metrics
- **Open S1 Bugs**: [N] -- [List]
- **Open S2 Bugs**: [N]
- **Open S3 Bugs**: [N]
- **Test Coverage**: [X%]
- **Performance**: [Within budget? Details]

## Code Health
- **TODO count**: [N across codebase]
- **FIXME count**: [N]
- **HACK count**: [N]
- **Technical debt items**: [List critical ones]

## Risk Assessment
| Risk | Status | Impact if Realized | Mitigation Status |
|------|--------|-------------------|------------------|

## Velocity Analysis
- **Planned vs Completed** (across all sprints): [X/Y tasks = Z%]
- **Trend**: [Improving / Stable / Declining]
- **Adjusted estimate for remaining work**: [Days needed at current velocity]

## Scope Recommendations
### Protect (Must ship with milestone)
- [Feature and why]

### At Risk (May need to cut or simplify)
- [Feature and risk]

### Cut Candidates (Can defer without compromising milestone)
- [Feature and impact of cutting]

## Go/No-Go Assessment

**Recommendation**: [GO / CONDITIONAL GO / NO-GO]

**Conditions** (if conditional):
- [Condition 1 that must be met]
- [Condition 2 that must be met]

**Rationale**: [Explanation of the recommendation]

## Action Items
| # | Action | Owner | Deadline |
|---|--------|-------|----------|
```

---

## 阶段 3b：制作人风险评估

**审查模式检查** — 在生成 PR-MILESTONE 之前应用：
- `solo` → 跳过。注意："PR-MILESTONE skipped — Solo mode。" 呈现没有 producer verdict 的 Go/No-Go 部分。
- `lean` → 跳过（不是 PHASE-GATE）。注意："PR-MILESTONE skipped — Lean mode。" 呈现没有 producer verdict 的 Go/No-Go 部分。
- `full` → 正常生成。

在生成 Go/No-Go 推荐之前，使用 gate **PR-MILESTONE** (`.claude/docs/director-gates.md`) 通过 Task 生成 `producer`。

传递：里程碑名称和目标日期、当前完成百分比、阻塞的 story 计数、来自冲刺报告的速度数据（如果可用）、cut candidates 列表。

在 Go/No-Go 部分内联呈现 producer 的评估。Producer 的 verdict（ON TRACK / AT RISK / OFF TRACK）通知整体推荐 — 不要在没有明确用户确认的情况下针对 OFF TRACK producer verdict 发出 GO。

---

## 阶段 4：保存审查

向用户呈现审查。

询问："我可以将此写入 `production/milestones/[milestone-name]-review.md` 吗？"

如果是，写入文件，如果需要则创建目录。Verdict: **COMPLETE** — 里程碑审查已保存。

如果否，在这里停止。Verdict: **BLOCKED** — 用户拒绝写入。

---

## 阶段 5：后续步骤

- 如果此里程碑标记开发阶段边界，运行 `/gate-check` 获得正式的阶段关卡裁决。
- 运行 `/sprint-plan` 根据上面的范围推荐调整下一个冲刺。
