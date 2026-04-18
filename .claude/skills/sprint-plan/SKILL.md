---
name: sprint-plan
description: "根据当前里程碑、已完成的工作和可用容量生成新的 Sprint 计划或更新现有计划。从生产文档和设计待办事项中提取上下文。"
argument-hint: "[new|update|status] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
context: |
  !ls production/sprints/ 2>/dev/null
---

## 阶段 0: 解析参数

提取模式参数（`new`、`update` 或 `status`）并解析审查模式（一次性设置，本次运行中所有 gate 生成使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式请参阅 `.claude/docs/director-gates.md`。

---

## 阶段 1: 收集上下文

1. **从 `production/milestones/` 读取当前里程碑**。

2. **从 `production/sprints/` 读取上一个 Sprint**（如果有），以
   了解速度和结转项。

3. **扫描 `design/gdd/` 中的设计文档**，查找标记为准备实现的功能。

4. **检查 `production/risk-register/` 的风险登记册**。

---

## 阶段 2: 生成输出

对于 `new`：

**生成 Sprint 计划**遵循以下格式并展示给用户。在运行生产者可行性 gate（阶段 4）之前不要询问写入，该阶段可能需要修订后才能写入文件。

```markdown
# Sprint [N] -- [开始日期] 至 [结束日期]

## Sprint 目标
[一句话描述本次 Sprint 对里程碑的贡献]

## 容量
- 总天数: [X]
- 缓冲（20%）: [Y 天保留用于计划外工作]
- 可用: [Z 天]

## 任务

### 必须有（关键路径）
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|---------|--------|----------|

### 应该有
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|---------|--------|----------|

### 最好有
| ID | 任务 | Agent/负责人 | 预估天数 | 依赖项 | 验收标准 |
|----|------|-------------|---------|--------|----------|

## 从上一 Sprint 结转
| 任务 | 原因 | 新预估 |
|------|------|-------|

## 风险
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|

## 对外部因素的依赖
- [列出任何外部依赖]

## 本 Sprint 的完成定义
- [ ] 所有"必须有"任务完成
- [ ] 所有任务通过验收标准
- [ ] QA 计划存在 (`production/qa/qa-plan-sprint-[N].md`)
- [ ] 所有逻辑/集成 Story 都有通过的单元/集成测试
- [ ] Smoke check 通过 (`/smoke-check sprint`)
- [ ] QA 签署报告：APPROVED 或 APPROVED WITH CONDITIONS (`/team-qa sprint`)
- [ ] 交付功能中没有 S1 或 S2 级 Bug
- [ ] 如有偏差，设计文档已更新
- [ ] 代码已审查并合并
```

对于 `status`：

**生成状态报告**：

```markdown
# Sprint [N] 状态 -- [日期]

## 进度: [X/Y 任务完成] ([Z%])

### 已完成
| 任务 | 完成者 | 备注 |
|------|-------|------|

### 进行中
| 任务 | 负责人 | 完成% | 阻塞项 |
|------|-------|-------|--------|

### 未开始
| 任务 | 负责人 | 有风险? | 备注 |
|------|-------|--------|------|

### 已阻塞
| 任务 | 阻塞项 | 阻塞项负责人 | 预计时间 |
|------|--------|------------|---------|

## 燃尽评估
[按计划进行 / 落后 / 提前]
[如果落后：正在削减或推迟什么]

## 新出现的风险
- [本 Sprint 识别的任何新风险]
```

---

## 阶段 3: 写入 Sprint 状态文件

生成新的 Sprint 计划后，同时写入 `production/sprint-status.yaml`。
这是 Story 状态的机器可读真实来源 —— `/sprint-status`、`/story-done` 和 `/help` 读取它而无需解析 Markdown。

询问："我可以同时写入 `production/sprint-status.yaml` 来跟踪 Story 状态吗？"

格式：

```yaml
# 由 /sprint-plan 自动生成。由 /story-done 更新。
# 请勿手动编辑 —— 使用 /story-done 更新 Story 状态。

sprint: [N]
goal: "[sprint 目标]"
start: "[YYYY-MM-DD]"
end: "[YYYY-MM-DD]"
generated: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"

stories:
  - id: "[epic-story, 例如 1-1]"
    name: "[story 名称]"
    file: "[production/stories/path.md]"
    priority: must-have        # must-have | should-have | nice-to-have
    status: ready-for-dev      # backlog | ready-for-dev | in-progress | review | done | blocked
    owner: ""
    estimate_days: 0
    blocker: ""
    completed: ""
```

从 Sprint 计划的任务表中初始化每个 Story：
- Must Have 任务 → `priority: must-have`, `status: ready-for-dev`
- Should Have 任务 → `priority: should-have`, `status: backlog`
- Nice to Have 任务 → `priority: nice-to-have`, `status: backlog`

对于 `update`：读取现有的 `sprint-status.yaml`，对未更改的 Story 保留状态，
添加新 Story，删除已放弃的 Story。

---

## 阶段 4: 生产者可行性 Gate

**审查模式检查** —— 在生成 PR-SPRINT 之前应用：
- `solo` → 跳过。注明："PR-SPRINT 跳过 —— 单人模式。" 进入阶段 5（QA 计划 gate）。
- `lean` → 跳过（不是 PHASE-GATE）。注明："PR-SPRINT 跳过 —— 精简模式。" 进入阶段 5（QA 计划 gate）。
- `full` → 正常生成。

在最终确定 Sprint 计划之前，使用 gate **PR-SPRINT**（`.claude/docs/director-gates.md`）通过 Task 生成 `producer`。

传递：提议的 Story 列表（标题、预估、依赖项）、团队总容量（小时/天）、
上一 Sprint 的任何结转项、里程碑约束和截止日期。

展示生产者的评估。如果 UNREALISTIC，在请求写入批准之前修改 Story 选择（将 Story 推迟到 Should Have 或 Nice to Have）。
如果有 CONCERNS，展示它们并让用户决定是否调整。

处理完生产者的裁决后，询问："我可以将此 Sprint 计划写入 `production/sprints/sprint-[N].md` 吗？" 如果同意，写入文件，如果需要则创建目录。
裁决：**COMPLETE** —— Sprint 计划已创建。如果不同意：裁决：**BLOCKED** —— 用户拒绝写入。

写入后，添加：

> **范围检查：** 如果此 Sprint 包含超出原始 Epic 范围的 Story，在实现开始前运行 `/scope-check [epic]` 以检测范围蔓延。

---

## 阶段 5: QA 计划 Gate

在关闭 Sprint 计划之前，检查此 Sprint 是否存在 QA 计划。

使用 `Glob` 查找 `production/qa/qa-plan-sprint-[N].md` 或 `production/qa/` 中引用此 Sprint 编号的任何文件。

**如果找到 QA 计划**：在 Sprint 计划输出中注明 —— "QA 计划：`[path]`" —— 然后继续。

**如果不存在 QA 计划**：不要默默继续。明确展示：

> "此 Sprint 没有 QA 计划。没有 QA 计划的 Sprint 意味着测试需求未定义 —— 开发者不会从 QA 角度知道"完成"是什么样子，并且没有它，Sprint 无法通过 Production → Polish gate。
>
> 现在运行 `/qa-plan sprint`，在开始任何实现之前。这需要一次会话，并生成每个 Story 需要的测试用例需求。"

使用 `AskUserQuestion`：
- 提示："未找到此 Sprint 的 QA 计划。您想如何继续？"
- 选项：
  - `[A] 立即运行 /qa-plan sprint —— 我会在开始实现之前执行（推荐）`
  - `[B] 暂时跳过 —— 我理解 QA 签署将在 Production → Polish gate 被阻塞`

如果 [A]：关闭并显示 "Sprint 计划已写入。接下来运行 `/qa-plan sprint` —— 然后开始实现。"
如果 [B]：向 Sprint 计划文档添加警告块：

```markdown
> ⚠️ **无 QA 计划**：此 Sprint 在没有 QA 计划的情况下开始。在最后一个 Story 实现之前运行 `/qa-plan sprint`。
> Production → Polish gate 需要 QA 签署报告，而这需要 QA 计划。
```

---

## 阶段 6: 下一步

在 Sprint 计划写入且 QA 计划状态解决后：

- `/qa-plan sprint` —— **在开始实现之前必需** —— 定义每个 Story 的测试用例，以便开发者根据 QA 规范而非空白进行实现
- `/story-readiness [story-file]` —— 在开始之前验证 Story 是否准备就绪
- `/dev-story [story-file]` —— 开始实现第一个 Story
- `/sprint-status` —— Sprint 中期检查进度
- `/scope-check [epic]` —— 在实现开始前验证无范围蔓延
