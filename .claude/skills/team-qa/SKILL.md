---
name: team-qa
description: "Orchestrate the QA team through a full testing cycle. Coordinates qa-lead (strategy + test plan) and qa-tester (test case writing + bug reporting) to produce a complete QA package for a sprint or feature. Covers: test plan generation, test case writing, smoke check gate, manual QA execution, and sign-off report."
argument-hint: "[sprint | feature: system-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
agent: qa-lead
---

当调用此 skill 时，通过结构化测试周期编排 QA 团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一阶段。

## 团队组成

- **qa-lead** — QA 策略、测试计划生成、story 分类、签署报告
- **qa-tester** — 测试用例编写、bug 报告编写、手动 QA 文档

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: qa-lead` — 策略、规划、分类、签署
- `subagent_type: qa-tester` — 测试用例编写和 bug 报告编写

始终在代理的提示中提供完整上下文 (story 文件路径、QA 计划路径、范围约束)。在可能的情况下并行启动独立的 qa-tester 任务 (例如，阶段 5 中的多个 stories 可以同时搭建)。

## 流程

### 阶段 1: 加载上下文

在做其他任何事情之前，收集完整范围:

1. 从参数检测当前冲刺或功能范围:
   - 如果参数是冲刺标识符 (例如, `sprint-03`): 读取 `production/sprints/[sprint]/` 中的所有 story 文件
   - 如果参数是 `feature: [system-name]`: 为该系统的 glob story 文件标记
   - 如果没有参数: 读取 `production/session-state/active.md` 和 `production/sprint-status.yaml` (如果存在) 以推断活动冲刺

2. 读取 `production/stage.txt` 以确认当前项目阶段。

3. 计算找到的 stories 并向用户报告:
   > "QA 周期开始于 [sprint/feature]。找到 [N] 个 stories。当前阶段: [stage]。准备好开始 QA 策略了吗?"

### 阶段 2: QA 策略 (qa-lead)

通过 Task 生成 `qa-lead` 以审查所有范围内的 stories 并生成 QA 策略。

提示 qa-lead 以:
- 读取每个 story 文件
- 按类型分类每个 story: **Logic** / **Integration** / **Visual/Feel** / **UI** / **Config/Data**
- 识别哪些 stories 需要自动化测试证据 vs 手动 QA
- 标记任何带有缺失验收标准或缺失测试证据的 stories，这些会阻塞 QA
- 估计手动 QA 工作量 (需要的测试会话数量)
- 检查 `tests/smoke/` 中的 smoke 测试场景; 对于每个，评估鉴于当前构建是否可以验证。生成 smoke 检查裁决: **PASS** / **PASS WITH WARNINGS [list]** / **FAIL [list of failures]**
- 生成策略摘要表和 smoke 检查结果:

  | Story | Type | Automated Required | Manual Required | Blocker? |
  |-------|------|--------------------|-----------------|----------|

  **Smoke Check**: [PASS / PASS WITH WARNINGS / FAIL] — [如果不是 PASS 则提供详细信息]

如果 smoke 检查结果为 **FAIL**，qa-lead 必须突出显示失败。QA 无法通过失败的 smoke 检查进入策略阶段。

向用户展示 qa-lead 的完整策略，然后使用 `AskUserQuestion`:

```
question: "QA 策略审查"
options:
  - "看起来不错 — 继续到测试计划"
  - "在继续前调整 story 类型"
  - "跳过被阻塞的 stories 并继续其余部分"
  - "Smoke 检查失败 — 修复问题并重新运行 /team-qa"
  - "取消 — 首先解决阻止程序"
```

如果 smoke 检查 **FAIL**: 不要进入阶段 3。展示失败并停止。用户必须修复它们并重新运行 `/team-qa`。
如果 smoke 检查 **PASS WITH WARNINGS**: 记录签署报告的警告并继续。
如果存在阻止程序: 明确列出它们。用户可以选择跳过被阻塞的 stories 或取消周期。

### 阶段 3: 测试计划生成

使用阶段 2 的策略，生成结构化测试计划文档。

测试计划应涵盖:
- **范围**: 冲刺/功能名称、story 计数、日期
- **Story 分类表**: 来自阶段 2 策略
- **自动化测试要求**: 哪些 stories 需要测试文件，`tests/` 中的预期路径
- **手动 QA 范围**: 哪些 stories 需要手动演练以及验证什么
- **范围外**: 此周期明确不测试什么以及为什么
- **进入标准**: QA 开始前必须为真 (smoke 检查通过、构建稳定)
- **退出标准**: 什么构成已完成的 QA 周期 (所有 stories PASS 或 FAIL 并提交 bug)

询问: "我可以将 QA 计划写入 `production/qa/qa-plan-[sprint]-[date].md` 吗?"

仅在收到批准后写入。

### 阶段 4: 测试用例编写 (qa-tester)

> **Smoke 检查** 作为阶段 2 (QA 策略) 的一部分执行。如果阶段 2 中的 smoke 检查返回 FAIL，周期在那里停止。此阶段仅在阶段 2 smoke 检查为 PASS 或 PASS WITH WARNINGS 时运行。

对于每个需要手动 QA 的 story (Visual/Feel、UI、没有自动化测试的 Integration):

为每个 story 生成 `qa-tester` (尽可能并行运行)，提供:
- Story 文件路径
- 该 story 的 QA 计划的相关部分
- 被测试系统的 GDD 验收标准 (如果可用)
- 编写涵盖所有验收标准的详细测试用例的说明

每个测试用例集应包括:
- **前置条件**: 测试开始前需要的游戏状态
- **步骤**: 编号的、明确的动作
- **预期结果**: 应该发生什么
- **实际结果**: 空白字段供测试人员填写
- **通过/失败**: 空白字段

向用户展示测试用例以供审查。按 story 分组。

对每个 story 组使用 `AskUserQuestion` (批量 3-4):

```
question: "[Story Group] 的测试用例已准备好。在手动 QA 开始前审查?"
options:
  - "已批准 — 开始这些 stories 的手动 QA"
  - "修改 [story name] 的测试用例"
  - "跳过 [story name] 的手动 QA — 尚未准备好"
```

### 阶段 6: 手动 QA 执行

演练批准的手动 QA 列表中的每个 story。

将 stories 批量分组为 3-4 个，并对每个使用 `AskUserQuestion`:

```
question: "手动 QA — [Story Title]\n[要测试的内容简要描述]"
options:
  - "PASS — 所有验收标准已验证"
  - "PASS WITH NOTES — 发现小问题 (之后描述)"
  - "FAIL — 标准未满足 (之后描述)"
  - "BLOCKED — 尚无法测试 (原因)"
```

每个 FAIL 结果后: 使用 `AskUserQuestion` 收集失败描述，然后通过 Task 生成 `qa-tester` 以在 `production/qa/bugs/` 中编写正式 bug 报告。

Bug 报告命名: `BUG-[NNN]-[short-slug].md` (从目录中的现有 bugs 递增 NNN)。

收集所有结果后，总结:
- Stories PASS: [count]
- Stories PASS WITH NOTES: [count]
- Stories FAIL: [count] — 提交的 bugs: [IDs]
- Stories BLOCKED: [count]

### 阶段 7: QA 签署报告

通过 Task 生成 `qa-lead` 以使用阶段 4-6 的所有结果生成签署报告。

签署报告格式:

```markdown
## QA 签署报告: [Sprint/Feature]
**日期**: [date]
**QA Lead 签署**: [pending]

### 测试覆盖摘要
| Story | Type | Auto Test | Manual QA | Result |
|-------|------|-----------|-----------|--------|
| [title] | Logic | PASS | — | PASS |
| [title] | Visual | — | PASS | PASS |

### 发现的 Bugs
| ID | Story | Severity | Status |
|----|-------|----------|--------|
| BUG-001 | [story] | S2 | Open |

### 裁决: APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED

**条件** (如果有): [list what must be fixed before the build advances]

### 下一步
[guidance based on verdict]
```

裁决规则:
- **APPROVED**: 所有 stories PASS 或 PASS WITH NOTES; 没有开放的 S1/S2 bugs
- **APPROVED WITH CONDITIONS**: 开放的 S3/S4 bugs，或记录的 PASS WITH NOTES 问题; 没有 S1/S2 bugs
- **NOT APPROVED**: 任何开放的 S1/S2 bugs; 或 stories FAIL 没有记录的变通方法

按裁决的下一步指导:
- APPROVED: "构建已准备好进入下一阶段。运行 `/gate-check` 以验证进展。"
- APPROVED WITH CONDITIONS: "在进展前解决条件。S3/S4 bugs 可能会推迟到优化。"
- NOT APPROVED: "解决 S1/S2 bugs 并在进展前重新运行 `/team-qa` 或有针对性的手动 QA。"

询问: "我可以将此 QA 签署报告写入 `production/qa/qa-signoff-[sprint]-[date].md` 吗?"

仅在收到批准后写入。

## 错误恢复协议

如果任何生成的代理 (通过 Task) 返回 BLOCKED、错误或无法完成:

1. **立即展示**: 在向用户报告 "[AgentName]: BLOCKED — [reason]"，然后继续到依赖阶段
2. **评估依赖关系**: 检查被阻止代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点。
3. **提供选项** 通过 AskUserQuestion 提供选择:
   - 跳过此代理并记录最终报告中的差距
   - 以更窄的范围重试
   - 在此处停止并首先解决阻止程序
4. **始终生成部分报告** — 输出已完成的内容。切勿因为代理被阻止而丢弃工作。

常见阻止程序:
- 输入文件缺失 (story 未找到, GDD 不存在) → 重定向到创建它的 skill
- ADR 状态为 Proposed → 不实现; 先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个 stories
- ADR 和 story 之间的冲突说明 → 展示冲突，不要猜测

## 输出

涵盖以下内容的摘要: 范围内的 stories、smoke 检查结果、手动 QA 结果、提交的 bugs (带有 ID 和严重度) 以及最终 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 裁决。

裁决: **COMPLETE** — QA 周期完成。
裁决: **BLOCKED** — smoke 检查失败或关键阻止程序阻止周期完成; 生成部分报告。
