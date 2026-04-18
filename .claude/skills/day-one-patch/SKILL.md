---
name: day-one-patch
description: "为游戏发布准备首日补丁。确定范围、优先级、实施并通过QA关卡，处理金版后、公开发布前或刚发布后发现的已知问题。将补丁视为带有自己QA关卡和回滚计划的迷你冲刺。"
argument-hint: "[scope: known-bugs | cert-feedback | all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion
---

# 首日补丁

每个发布的游戏都有首日补丁。在发布日之前规划它可以防止
混乱。此 skill 将补丁范围限定为仅安全和必要的内容，通过
轻量级 QA 通道，并确保在发布任何内容之前存在回滚计划。它是一个
迷你冲刺 — 不是热修复，不是完整冲刺。

**何时运行:**
- 金版构建锁定后 (认证批准或发布候选标记)
- 当存在在金版中修复风险过高的已知 bug 时
- 当认证反馈需要在提交后进行小修复时
- 当发布前游戏测试在发布门通过后显示必须修复的问题时

**首日补丁范围规则:**
- 仅 P1/P2 可快速安全修复的 bug
- 无新功能 — 仅限修复
- 无重构 — 最小可行更改
- 任何需要超过 4 小时开发时间的修复属于补丁 1.1，而非首日

**输出:** `production/releases/day-one-patch-[version].md`

---

## 阶段 1: 加载发布上下文

读取:
- `production/stage.txt` — 确认项目处于 Release 阶段
- `production/gate-checks/` 中最近的文件 — 读取发布门裁决
- `production/qa/bugs/*.md` — 加载所有状态为 Open 或 Fixed — Pending Verification 的 bug
- `production/sprints/` 最新的 — 了解发布了什么
- `production/security/security-audit-*.md` 最新的 — 检查任何开放的安全项目

如果 `production/stage.txt` 不是 `Release` 或 `Polish`:
> "首日补丁准备适用于 Release 阶段项目。当前阶段: [stage]。此 skill 在接近发布前不适用。"

---

## 阶段 2: 确定补丁范围

### 步骤 2a — 分类开放 bug 以纳入补丁

对于每个开放 bug，评估:

| 标准 | 纳入首日? |
|-----------|-------------------|
| S1 或 S2 严重度 | 是 — 如果修复安全则必须纳入 |
| P1 优先级 | 是 |
| 修复估计 < 4 小时 | 是 |
| 修复需要架构更改 | 否 — 推迟到 1.1 |
| 修复引入新代码路径 | 否 — 风险太高 |
| 修复仅为数据/配置 (无代码更改) | 是 — 风险很低 |
| 认证反馈要求 | 是 — 平台批准所需 |
| S3/S4 严重度 | 仅当为简单配置修复时; 否则推迟 |

### 步骤 2b — 向用户展示补丁范围

使用 `AskUserQuestion`:
- 提示: "基于开放 bug 和认证反馈，这是提议的首日补丁范围。这看起来对吗?"
- 展示: 纳入的 bug 表 (ID, 严重度, 描述, 估计工作量)
- 展示: 推迟的 bug 表 (ID, 严重度, 推迟原因)
- 选项: `[A] 批准此范围` / `[B] 调整 — 我想添加或删除项目` / `[C] 不需要首日补丁`

如果 [C]: 输出 "不需要首日补丁。继续到 `/launch-checklist`。" 停止。

### 步骤 2c — 检查总范围

汇总估计工作量。如果总计超过 1 天工作量:
> "⚠️ 补丁范围为 [N 小时] — 这超过了安全的首日窗口。考虑将较低优先级项目推迟到补丁 1.1。臃肿的首日补丁引入的风险比它消除的更多。"

使用 `AskUserQuestion` 确认继续或减少范围。

---

## 阶段 3: 回滚计划

在编写任何代码之前，定义回滚程序。这是不可协商的。

通过 Task 生成 `release-manager`。要求他们生成回滚计划，涵盖:
- 如何在每个目标平台上回滚到金版构建
- 平台特定的回滚约束 (某些平台无法回滚认证构建)
- 谁负责触发回滚
- 如果发生回滚，需要什么玩家沟通

展示回滚计划。询问: "我可以将此回滚计划写入 `production/releases/rollback-plan-[version].md` 吗?"

在回滚计划写入之前不要进入阶段 4。

---

## 阶段 4: 实施修复

对于批准范围内的每个 bug，生成一个专注的实现循环:

1. 通过 Task 生成 `lead-programmer`，并传递:
   - Bug 报告 (确切的复现步骤和已知根本原因)
   - 约束: 仅最小可行修复，无清理
   - 受影响的文件 (来自 bug 报告 Technical Context 部分)

2. lead-programmer 实现并运行有针对性的测试。

3. 通过 Task 生成 `qa-tester` 以验证: 修复后 bug 是否复现?

对于仅配置/数据的修复: 直接进行更改 (不需要程序员代理)。确认值已更改并重新运行任何相关的 smoke 测试。

---

## 阶段 5: 补丁 QA 门

这是一个轻量级 QA 通道 — 不是完整的 `/team-qa`。补丁已通过发布门获得 QA 批准; 我们仅重新验证更改的区域。

通过 Task 生成 `qa-lead`，并传递:
- 所有更改文件的列表
- 修复的 bug 列表 (来自阶段 4 的验证状态)
- 受影响系统的 smoke 检查范围

要求 qa-lead 确定: **有针对性的 smoke 检查是否足够，还是任何修复需要更广泛的回归?**

运行所需的 QA 范围:
- **有针对性的 smoke 检查** — 运行 `/smoke-check [affected-systems]`
- **更广泛的回归** — 为受影响系统在 `tests/unit/` 和 `tests/integration/` 中运行有针对性的测试

QA 裁决在继续前必须是 PASS 或 PASS WITH WARNINGS。如果 FAIL: 将失败的修复排除在首日补丁之外并推迟到 1.1。

---

## 阶段 6: 生成补丁记录

```markdown
# 首日补丁: [Game Name] v[version]

**准备日期**: [date]
**目标发布**: [launch date or "day of launch"]
**基础构建**: [gold master tag or commit]
**补丁构建**: [patch tag or commit]

---

## 补丁说明 (内部)

### 修复的 Bug
| BUG-ID | Severity | Description | Fix summary |
|--------|----------|-------------|-------------|
| BUG-NNN | S[1-4] | [description] | [one-line fix] |

### 推迟到 1.1
| BUG-ID | Severity | Description | Reason deferred |
|--------|----------|-------------|-----------------|
| BUG-NNN | S[1-4] | [description] | [reason] |

---

## QA 签署

**QA 范围**: [Targeted smoke / Broader regression]
**裁决**: [PASS / PASS WITH WARNINGS]
**QA lead**: qa-lead agent
**日期**: [date]
**警告 (如果有)**: [list or "None"]

---

## 回滚计划

参见: `production/releases/rollback-plan-[version].md`

**触发条件**: 如果发布后 [X] 小时内报告 [N] 个或更多 S1 bug，执行回滚。
**回滚负责人**: [user / producer]

---

## 部署前需要的批准

- [ ] lead-programmer: 所有修复已审查
- [ ] qa-lead: QA 门 PASS 确认
- [ ] producer: 部署时间已批准
- [ ] release-manager: 平台提交已确认

---

## 面向玩家的补丁说明

[供 community-manager 在发布前审查的草稿]

[以 plain language 列出面向玩家的更改]
```

询问: "我可以将此补丁记录写入 `production/releases/day-one-patch-[version].md` 吗?"

---

## 阶段 7: 后续步骤

写入补丁记录后:

1. 运行 `/patch-notes` 生成补丁说明的面向玩家版本
2. 补丁上线后为每个修复的 bug 运行 `/bug-report verify [BUG-ID]`
3. 为每个验证的修复运行 `/bug-report close [BUG-ID]`
4. 发布后 48–72 小时安排发布后审查，使用 `/retrospective launch`

**如果补丁后仍有开放 S1 bug:**
> "⚠️ S1 bug 仍开放且未修补。这些是已接受的风险。将它们记录在回滚计划触发条件中 — 如果它们大规模发生，回滚可能比后续补丁更可取。"

---

## 协作协议

- **范围纪律就是一切** — 抵制范围蔓延; 每个增加都会增加风险
- **回滚计划优先，始终** — 没有回滚计划的补丁是不负责任的
- **推迟不是遗忘** — 每个推迟的 bug 自动获得 1.1 票
- **玩家沟通是补丁的一部分** — `/patch-notes` 是必需的输出，不是可选的
