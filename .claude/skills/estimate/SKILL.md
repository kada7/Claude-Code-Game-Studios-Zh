---
name: estimate
description: "通过分析复杂度、依赖关系、历史速率和风险因素来估算任务工作量。生成带有置信水平的结构化估算。"
argument-hint: "[task-description]"
user-invocable: true
allowed-tools: Read, Glob, Grep
---

## Phase 1: Understand the Task

从参数中读取任务描述。如果描述太模糊而无法进行有意义的估算，在继续之前要求澄清。

读取 CLAUDE.md 获取项目上下文：技术栈、编码标准、架构模式和任何估算指南。

如果任务与文档化的功能或系统相关，从 `design/gdd/` 读取相关的设计文档。

---

## Phase 2: Scan Affected Code

识别需要更改的文件和模块：

- 评估复杂度（大小、依赖项数量、圈复杂度）
- 识别与其他系统的集成点
- 检查受影响区域的现有测试覆盖率
- 从 `production/sprints/` 读取过去的冲刺数据，获取类似已完成的任务和历史速度

---

## Phase 3: Analyze Complexity Factors

**Code Complexity:**
- 受影响文件中的代码行数
- 依赖项数量和耦合级别
- 这是接触核心/引擎代码还是叶子/功能代码
- 是可以遵循现有模式还是需要新模式

**Scope:**
- 接触的系统数量
- 新代码与修改现有代码
- 需要的新测试覆盖范围
- 需要的数据迁移或配置更改

**Risk:**
- 新技术或不熟悉的库
- 不清晰或模糊的需求
- 对未完成工作的依赖
- 跨系统集成复杂度
- 性能敏感度

---

## Phase 4: Generate the Estimate

```markdown
## Task Estimate: [Task Name]
Generated: [Date]

### Task Description
[用1-2句话清楚地重述任务]

### Complexity Assessment

| Factor | Assessment | Notes |
|--------|-----------|-------|
| Systems affected | [List] | [Core, gameplay, UI, etc.] |
| Files likely modified | [Count] | [Key files listed below] |
| New code vs modification | [Ratio] | |
| Integration points | [Count] | [Which systems interact] |
| Test coverage needed | [Low / Medium / High] | |
| Existing patterns available | [Yes / Partial / No] | |

**Key files likely affected:**
- `[path/to/file1]` -- [what changes here]

### Effort Estimate

| Scenario | Days | Assumption |
|----------|------|------------|
| Optimistic | [X] | 一切顺利，没有意外 |
| Expected | [Y] | 正常节奏，小问题，一轮审查 |
| Pessimistic | [Z] | 出现重大未知，阻塞一天 |

**Recommended budget: [Y days]**

### Confidence: [High / Medium / Low]

[解释哪些因素决定了此特定任务的置信水平。]

### Risk Factors

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|

### Dependencies

| Dependency | Status | Impact if Delayed |
|-----------|--------|-------------------|

### Suggested Breakdown

| # | Sub-task | Estimate | Notes |
|---|----------|----------|-------|
| 1 | [Research / spike] | [X days] | |
| 2 | [Core implementation] | [X days] | |
| 3 | [Testing and validation] | [X days] | |
| | **Total** | **[Y days]** | |

### Notes and Assumptions
- [影响估算的关键假设]
- [关于范围边界的任何注意事项]
```

输出估算并附带简要摘要：推荐预算、置信水平和最大的单一风险因素。

这个技能是只读的 — 不写入文件。Verdict: **COMPLETE** — 估算已生成。

---

## Phase 5: Next Steps

- 如果置信度低：建议在提交之前进行有时间限制的原型制作 (`/prototype`)。
- 如果任务 > 10 天：建议通过 `/create-stories` 将其拆分为更小的 story。
- 要安排任务：运行 `/sprint-plan update` 将其添加到下一个冲刺。

### Guidelines

- 始终给出一个范围（optimistic / expected / pessimistic），而不是单个数字
- 推荐预算应该是预期估算，而不是乐观估算
- 四舍五入到半天增量 — 以小时为单位估算意味着对超过一天的任务有虚假的精确度
- 不要悄悄地增加估算 — 明确标出风险以便团队决定
