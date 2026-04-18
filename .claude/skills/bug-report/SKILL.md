---
name: bug-report
description: "根据描述创建结构化Bug报告，或分析代码以识别潜在Bug。确保每个Bug报告都有完整的复现步骤、严重度评估和上下文。"
argument-hint: "[description] | analyze [path-to-file]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

## 阶段 1: 解析参数

从参数确定模式:

- 无关键字 → **描述模式**: 从提供的描述生成结构化 bug 报告
- `analyze [path]` → **分析模式**: 读取目标文件并识别潜在 bug
- `verify [BUG-ID]` → **验证模式**: 确认报告的修复是否实际解决了 bug
- `close [BUG-ID]` → **关闭模式**: 将已验证的 bug 标记为关闭并记录解决方案

如果没有提供参数，在继续前询问用户 bug 描述。

---

## 阶段 2A: 描述模式

1. **解析描述** 以获取关键信息: 什么坏了、何时发生、如何复现、预期行为是什么。

2. **搜索代码库** 使用 Grep/Glob 添加上下文 (受影响的系统、可能的文件)。

3. **起草 bug 报告**:

```markdown
# Bug 报告

## 摘要
**标题**: [简洁、描述性的标题]
**ID**: BUG-[NNNN]
**严重度**: [S1-Critical / S2-Major / S3-Minor / S4-Trivial]
**优先级**: [P1-Immediate / P2-Next Sprint / P3-Backlog / P4-Wishlist]
**状态**: Open
**报告时间**: [Date]
**报告人**: [Name]

## 分类
- **类别**: [Gameplay / UI / Audio / Visual / Performance / Crash / Network]
- **系统**: [受影响的游戏系统]
- **频率**: [Always / Often (>50%) / Sometimes (10-50%) / Rare (<10%)]
- **回归**: [Yes/No/Unknown -- 这之前工作正常吗?]

## 环境
- **构建**: [版本或提交哈希]
- **平台**: [操作系统, 相关硬件]
- **场景/关卡**: [游戏中的位置]
- **游戏状态**: [相关状态 -- 库存、任务进度等]

## 复现步骤
**前置条件**: [开始前的必需状态]

1. [精确步骤 1]
2. [精确步骤 2]
3. [精确步骤 3]

**预期结果**: [应该发生什么]
**实际结果**: [实际发生了什么]

## 技术上下文
- **可能受影响的文件**: [基于代码库搜索的文件列表]
- **相关系统**: [可能涉及的其他系统]
- **可能根本原因**: [如果可从描述中识别]

## 证据
- **日志**: [可用的相关日志输出]
- **视觉**: [视觉证据描述]

## 相关问题
- [相关 bug 或设计文档的链接]

## 备注
[任何额外的上下文或观察]
```

---

## 阶段 2B: 分析模式

1. **读取目标文件** 参数中指定的文件。

2. **识别潜在 bug**: null 引用、差一错误、竞态条件、未处理的边界情况、资源泄漏、不正确的状态转换。

3. **对于每个潜在 bug**，使用上面的模板生成 bug 报告，填写可能的触发场景和推荐的修复。

---

## 阶段 2C: 验证模式

读取 `production/qa/bugs/[BUG-ID].md`。提取复现步骤和预期结果。

1. **重新运行复现步骤** — 使用 Grep/Glob 检查根本原因代码路径是否仍如描述所述存在。如果修复已移除或更改它，记录更改。
2. **运行相关测试** — 如果 bug 的系统在 `tests/` 中有测试文件，通过 Bash 运行它并报告通过/失败。
3. **检查回归** — 在代码库中搜索导致 bug 的模式的新出现。

生成验证裁决:

- **VERIFIED FIXED** — 复现步骤不再产生 bug; 相关测试通过
- **STILL PRESENT** — bug 如描述所述复现; 修复未解决问题
- **CANNOT VERIFY** — 自动化检查无结论; 需要手动游戏测试

询问: "我可以更新 `production/qa/bugs/[BUG-ID].md` 以设置 Status: Verified Fixed / Still Present / Cannot Verify 吗?"

如果 STILL PRESENT: 重新打开 bug，将 Status 设置回 Open，并建议重新运行 `/hotfix [BUG-ID]`。

---

## 阶段 2D: 关闭模式

读取 `production/qa/bugs/[BUG-ID].md`。确认 Status 为 `Verified Fixed` 后再关闭。如果状态是其他内容，停止: "Bug [ID] 必须先 Verified Fixed 才能关闭。请先运行 `/bug-report verify [BUG-ID]`。"

在 bug 文件后附加关闭记录:

```markdown
## 关闭记录
**关闭时间**: [date]
**解决方案**: Fixed — [更改内容的一行描述]
**修复提交 / PR**: [如果已知]
**验证人**: qa-tester
**关闭人**: [user]
**回归测试**: [测试文件路径, 或 "Manual verification"]
**状态**: Closed
```

将顶层 `**Status**: Open` 字段更新为 `**Status**: Closed`。

询问: "我可以更新 `production/qa/bugs/[BUG-ID].md` 以将其标记为 Closed 吗?"

关闭后，检查 `production/qa/bug-triage-*.md` — 如果 bug 出现在开放分类报告中，注意: "Bug [ID] 在分类报告中被引用。运行 `/bug-triage` 以刷新开放 bug 计数。"

---

## 阶段 3: 保存报告

向用户展示完成的 bug 报告。

询问: "我可以将其写入 `production/qa/bugs/BUG-[NNNN].md` 吗?"

如果同意，写入文件，如果需要则创建目录。裁决: **COMPLETE** — bug 报告已归档。

如果不同意，在此停止。裁决: **BLOCKED** — 用户拒绝写入。

---

## 阶段 4: 后续步骤

保存后，根据模式建议:

**归档后 (描述/分析模式):**
- 运行 `/bug-triage` 以与现有开放 bug 一起确定优先级
- 如果是 S1 或 S2: 运行 `/hotfix [BUG-ID]` 进行紧急修复工作流

**修复 bug 后 (开发者确认修复已入):**
- 运行 `/bug-report verify [BUG-ID]` — 在关闭前确认修复实际有效
- 切勿在未验证的情况下将 bug 标记为已关闭 — 未验证的修复仍是 Open

**验证返回 VERIFIED FIXED 后:**
- 运行 `/bug-report close [BUG-ID]` — 写入关闭记录并更新状态
- 运行 `/bug-triage` 以刷新开放 bug 计数并将其从活动列表中移除
