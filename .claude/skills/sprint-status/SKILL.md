---
name: sprint-status
description: "快速 Sprint 状态检查。读取当前 Sprint 计划，扫描 Story 文件以获取状态，并生成包含燃尽评估和新出现风险的简明进度快照。在 Sprint 期间的任何时间运行以快速了解情况。当用户询问'how is the sprint going'、'sprint update'、'show sprint progress'时使用。"
argument-hint: "[sprint-number or blank for current]"
user-invocable: true
allowed-tools: Read, Glob, Grep
model: haiku
---

# Sprint 状态

这是快速情况感知检查，不是 Sprint 审查。它读取
当前 Sprint 计划和 Story 文件，扫描状态标记，并在 30 行内生成
简明快照。对于详细的 Sprint 管理，使用
`/sprint-plan update` 或 `/milestone-review`。

**此 Skill 是只读的。** 它从不提议更改，从不询问写入
文件，最多提出一个具体建议。

---

## 1. 查找 Sprint

**参数：** `$ARGUMENTS[0]`（空白 = 使用当前 Sprint）

- 如果给出参数（例如 `/sprint-status 3`），搜索
  `production/sprints/` 以查找匹配 `sprint-03.md`、`sprint-3.md` 的文件，
  或类似文件。报告找到的文件。
- 如果未给出参数，在 `production/sprints/` 中查找最新修改的文件并将其视为当前 Sprint。
- 如果 `production/sprints/` 不存在或为空，报告："No sprint
  files found。Start a sprint with `/sprint-plan new`。" 然后停止。

完整读取 Sprint 文件。提取：
- Sprint 编号和目标
- 开始日期和结束日期
- 所有 Story 或任务条目及其优先级（Must Have / Should Have /
  Nice to Have）、负责人和预估

---

## 2. 计算剩余天数

使用今天的日期和 Sprint 文件中的 Sprint 结束日期，计算：
- Sprint 总天数（结束减去开始）
- 已过去天数
- 剩余天数
- 时间消耗百分比

如果 Sprint 文件不包含明确日期，注明 "Sprint dates not
found — burndown assessment skipped。"

---

## 3. 扫描 Story 状态

**首先：检查 `production/sprint-status.yaml`。**

如果存在，直接读取它 —— 它是状态的真实来源。
从 `status` 字段提取每个 Story 的状态。无需 Markdown 扫描。
使用其 `sprint`、`goal`、`start`、`end` 字段代替重新解析 Sprint 计划。

**如果 `sprint-status.yaml` 不存在**（旧 Sprint 或首次设置），
回退到 Markdown 扫描：

1. 如果条目引用 Story 文件路径，检查文件是否存在。
   读取文件并扫描状态标记：DONE、COMPLETE、IN PROGRESS、
   BLOCKED、NOT STARTED（不区分大小写）。
2. 如果条目没有文件路径（Sprint 计划中的内联任务），扫描
   Sprint 计划本身以查找该条目旁边的状态标记。
3. 如果未找到状态标记，分类为 NOT STARTED。
4. 如果引用了文件但文件不存在，分类为 MISSING 并注明。

使用回退时，在输出底部添加注释：
"⚠ No `sprint-status.yaml` found — status inferred from markdown。Run `/sprint-plan update` to generate one。"

可选（仅快速检查 —— 不进行深度扫描）：grep `src/` 以查找与 Story 的系统 slug 匹配的目录或文件名，以检查
实现证据。这只是提示，不是确定性状态。

### 陈旧 Story 检测

收集所有 Story 的状态后，检查每个 IN PROGRESS Story 的陈旧性：

- 对于每个有引用文件的 Story，读取文件并在 frontmatter 或标题中查找
  `Last Updated:` 字段（例如 `Last Updated: 2026-04-01`
  或 `updated: 2026-04-01`）。接受任何合理的日期字段名称：`Last Updated`、
  `Updated`、`last-updated`、`updated_at`。
- 使用该日期和今天的日期计算自该日期以来的天数。
- 如果日期是 2 天前，将 Story 标记为 **STALE**。
- 如果在 Story 文件中未找到日期字段，注明 "no timestamp — cannot check staleness。"
- 如果 Story 没有引用文件（内联任务），注明 "inline task — cannot check staleness。"

STALE Stories 包含在输出表中并收集到"需要注意"
章节（见阶段 5 输出格式）。

**陈旧 Story 升级**：如果任何 IN PROGRESS Story 被标记为 STALE，燃尽裁决
至少升级为 **At Risk** —— 即使完成百分比在正常
On Track 窗口内。记录此升级原因："At Risk — [N] story(ies) with no progress in
[N] days。"

---

## 4. 燃尽评估

计算：
- 任务完成（DONE 或 COMPLETE）
- 任务进行中（IN PROGRESS）
- 任务被阻塞（BLOCKED）
- 任务未开始（NOT STARTED 或 MISSING）
- 完成百分比：(complete / total) * 100

通过比较完成百分比与时间消耗百分比来评估燃尽：

- **On Track**：完成 % 在时间消耗 % 的 10 个点内或提前
- **At Risk**：完成 % 落后时间消耗 % 10-25 个点
- **Behind**：完成 % 落后时间消耗 % 超过 25 个点

如果日期不可用，跳过燃尽评估并报告 "On Track /
At Risk / Behind: unknown — sprint dates not found。"

---

## 5. 输出

将总输出保持在 30 行或更少。使用此格式：

```markdown
## Sprint [N] 状态 —— [今天的日期]
**Sprint 目标**: [来自 Sprint 计划]
**剩余天数**: [N] / [total] ([% 时间消耗])

### 进度: [complete/total] 任务 ([%])

| Story / 任务         | 优先级   | 状态      | 负责人   | 阻塞项        |
|----------------------|------------|-------------|---------|----------------|
| [title]              | Must Have  | DONE        | [owner] |                |
| [title]              | Must Have  | IN PROGRESS | [owner] |                |
| [title]              | Must Have  | BLOCKED     | [owner] | [简要原因] |
| [title]              | Should Have| NOT STARTED | [owner] |                |

### 需要注意
| Story / 任务         | 状态      | 最后更新   | 陈旧天数 | 备注           |
|----------------------|-------------|----------------|------------|----------------|
| [title]              | IN PROGRESS | [date or N/A]  | [N 天]   | [STALE / no timestamp — cannot check staleness / inline task — cannot check staleness] |

*（如果没有 IN PROGRESS Story 陈旧或有时间戳问题，完全省略此部分。）*

### 燃尽: [On Track / At Risk / Behind]
[1-2 句话。如果落后：哪些 Must Haves 有风险。如果按计划：确认
并注明团队可以拉取的任何 Should Haves。]

### Must-Haves 有风险
[列出任何 BLOCKED 或 NOT STARTED 且 Sprint 时间剩余少于
40% 的 Must Have Stories。如果没有，写 "None。"]

### 新出现的风险
[从 Story 扫描中可见的任何风险：缺失文件、级联阻塞、
没有负责人的 Stories。如果没有，写 "None identified。"]

### 建议
[一个具体行动，或 "Sprint is on track — no action needed。"]
```

---

## 6. 快速升级规则

在输出前应用这些规则，如果触发则将标志放在输出的
顶部（状态表上方）：

**关键标志** —— 如果 Must Have Stories 是 BLOCKED 或 NOT STARTED 且
Sprint 时间剩余少于 40%：

```
SPRINT AT RISK: [N] Must Have stories are not complete with [X]% of sprint
time remaining。Recommend replanning with `/sprint-plan update`。
```

**完成标志** —— 如果所有 Must Have Stories 都是 DONE：

```
All Must Haves complete。Team can pull from Should Have backlog。
```

**缺失 Stories 标志** —— 如果任何引用的 Story 文件不存在：

```
NOTE: [N] story files referenced in the sprint plan are missing。
Run `/story-readiness sprint` to validate story file coverage。
```

---

## 协作协议

此 Skill 是只读的。它报告磁盘上文件的观察事实。

- 它不更新 Sprint 计划
- 它不更改 Story 状态
- 它不提议范围削减（那是 `/sprint-plan update`）
- 每次运行最多提出一个建议

有关特定 Story 的更多详细信息，用户可以直接读取 Story 文件
或运行 `/story-readiness [path]`。

对于 Sprint 重新规划，使用 `/sprint-plan update`。
对于 Sprint 结束回顾，使用 `/milestone-review`。
