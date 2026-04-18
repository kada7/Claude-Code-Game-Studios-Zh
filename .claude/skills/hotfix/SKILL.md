---
name: hotfix
description: "绕过正常冲刺流程的紧急修复工作流，带有完整审计追踪。创建热修复分支、跟踪审批，并确保修复被正确回溯移植。"
argument-hint: "[bug-id or description]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task
---

> **仅显式调用**: 只有当用户显式使用 `/hotfix` 请求时，此技能才应运行。不要基于上下文匹配自动调用。

## Phase 1: Assess Severity

读取 bug 描述或 ID。确定严重程度：

- **S1 (Critical)**: 游戏无法玩，数据丢失，安全漏洞 — 立即热修复
- **S2 (Major)**: 重要功能损坏，存在解决方法 — 24 小时内热修复
- 如果严重性是 S3 或更低，建议改用正常的 bug 修复工作流并停止。

---

## Phase 2: Create Hotfix Record

起草热修复记录：

```markdown
## Hotfix: [Short Description]
Date: [Date]
Severity: [S1/S2]
Reporter: [Who found it]
Status: IN PROGRESS

### Problem
[清晰描述损坏的内容和玩家影响]

### Root Cause
[在调查期间填写]

### Fix
[在实现期间填写]

### Testing
[测试内容和方式]

### Approvals
- [ ] Fix reviewed by lead-programmer
- [ ] Regression test passed (qa-tester)
- [ ] Release approved (producer)

### Rollback Plan
[如果修复导致新问题，如何回滚]
```

询问："我可以将此写入 `production/hotfixes/hotfix-[date]-[short-name].md` 吗？"

如果是，写入文件，如果需要则创建目录。

---

## Phase 3: Create Hotfix Branch

如果 git 已初始化，创建热修复分支：

```
git checkout -b hotfix/[short-name] [release-tag-or-main]
```

---

## Phase 4: Investigate and Implement

专注于解决问题的最小更改。不要与热修复一起重构、清理或添加功能。

通过运行受影响系统的有针对性的测试来验证修复。检查相邻系统的回归。

用热修复记录更新根本原因、修复详细信息和测试结果。

---

## Phase 5: Collect Approvals

使用 Task 工具并行请求签署：

- `subagent_type: lead-programmer` — 审查修复的正确性和副作用
- `subagent_type: qa-tester` — 在受影响系统上运行有针对性的回归测试
- `subagent_type: producer` — 批准部署时间和沟通计划

在继续之前，所有三个都必须返回 APPROVE。如果任何返回 CONCERNS 或 REJECT，不要部署 — 先显示问题并解决它。

---

## Phase 5b: QA Re-Entry Gate

批准后，确定在部署热修复之前所需的 QA 范围。通过 Task 生成 `qa-lead`：
- 热修复描述和受影响的系统
- 来自 Phase 5 的回归测试结果
- 所有接触更改文件的系统列表（使用 Grep 查找调用者）

询问 qa-lead：**完整的 smoke check 足够，还是此修复需要有针对性的 team-qa 通过？**

应用裁决：
- **Smoke check 足够** — 针对热修复 build 运行 `/smoke-check`。如果 PASS，进入 Phase 6。
- **需要 Targeted QA pass** — 仅对更改的系统运行 `/team-qa [affected-system]`。如果 QA 返回 APPROVED 或 APPROVED WITH CONDITIONS，进入 Phase 6。
- **需要 Full QA** — 接触核心系统的 S1 修复可能需要完整的 `/team-qa sprint`。这会延迟部署但防止糟糕的补丁。

不要跳过此关卡。一个破坏其他东西的热修复比原来的 bug 更糟。

---

## Phase 6: Update Bug Status and Deploy

如果存在原始 bug 文件则更新它：

```markdown
## Fix Record
**Fixed in**: hotfix/[branch-name] — [commit hash or description]
**Fixed date**: [date]
**Status**: Fixed — Pending Verification
```

在 bug 文件头部设置 `**Status**: Fixed — Pending Verification`。

输出部署摘要：

```
## Hotfix Ready to Deploy: [short-name]

**Severity**: [S1/S2]
**Root cause**: [one line]
**Fix**: [one line]
**QA gate**: [Smoke check PASS / Team-QA APPROVED]
**Approvals**: lead-programmer ✓ / qa-tester ✓ / producer ✓
**Rollback plan**: [from Phase 2 record]

合并到: release branch AND development branch
Next: /bug-report verify [BUG-ID] after deploy to confirm resolution
```

### Rules
- 热修复必须是修复问题的最小更改 — 不清理，不重构
- 每个热修复在部署前必须有记录的回滚计划
- 热修复分支合并到 release branch AND development branch
- 所有热修复在 48 小时内需要事后审查
- 如果修复复杂到需要超过 4 小时，升级到 `technical-director`

---

## Phase 7: Post-Deploy Verification

部署后，运行 `/bug-report verify [BUG-ID]` 以确认修复在部署的 build 中解决了问题。

如果 VERIFIED FIXED: 运行 `/bug-report close [BUG-ID]` 正式关闭它。
如果 STILL PRESENT: 热修复失败 — 立即重新打开，评估回滚，并升级。

使用 `/retrospective hotfix` 在 48 小时内安排事后审查。
