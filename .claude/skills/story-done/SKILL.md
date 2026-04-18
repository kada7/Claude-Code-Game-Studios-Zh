---
name: story-done
description: "Story 结束时的完成审查。读取 Story 文件，对照实现验证每个验收标准，检查 GDD/ADR 偏差，提示代码审查，将 Story 状态更新为 Complete，并从 Sprint 中呈现下一个就绪 Story。"
argument-hint: "[story-file-path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Edit, AskUserQuestion, Task
---

# Story 完成

此技能闭合设计与实现之间的环路。在实现任何 Story 结束时运行。
它确保每个验收标准在 Story 标记为完成之前经过验证，
GDD 和 ADR 偏差被明确记录而不是悄悄引入，
代码审查被提示而不是被遗忘，Story 文件反映实际完成状态。

**输出：** 更新的 Story 文件（Status: Complete）+ 呈现下一个 Story。

---

## 阶段1：找到 Story

解析审查模式（一次，存储供本次运行所有关卡生成使用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式详见 `.claude/docs/director-gates.md`。

**如果提供了文件路径**（例如 `/story-done production/epics/core/story-damage-calculator.md`）：
直接读取该文件。

**如果未提供参数：**

1. 在 `production/session-state/active.md` 中检查当前活跃的 Story。
2. 如果未找到，读取 `production/sprints/` 中最新的文件并
   查找标记为 IN PROGRESS 的 Story。
3. 如果找到多个进行中的 Story，使用 `AskUserQuestion`：
   - "我们正在完成哪个 Story？"
   - 选项：列出进行中的 Story 文件名。
4. 如果找不到任何 Story，要求用户提供路径。

---

## 阶段2：读取 Story

完整读取 Story 文件。提取并保存在上下文中：

- **Story 名称和 ID**
- **GDD 需求 TR-ID** 引用（例如 `TR-combat-001`）
- **嵌入在 Story 头部的清单版本**（例如 `2026-03-10`）
- **ADR 引用**
- **验收标准** — 完整列表（每个复选框项目）
- **实现文件** — "要创建/修改的文件"下列出的文件
- **Story 类型** — Story 头部的 `Type:` 字段（Logic / Integration / Visual/Feel / UI / Config/Data）
- **引擎说明** — 任何引擎专属约束
- **完成定义** — 如果存在，Story 级别的 DoD
- **估算与实际范围** — 如果注明了估算

同时读取：
- `docs/architecture/tr-registry.yaml` — 查找 Story 中的每个 TR-ID。
  从注册表条目读取*当前* `requirement` 文本。这是 GDD 要求内容的权威来源 —
  不要使用可能在 Story 中内联引用的任何需求文本（可能已过时）。
- 引用的 GDD 部分 — 仅验收标准和关键规则，而非完整文档。用于交叉验证注册表文本是否仍然准确。
- 引用的 ADR — 仅决策和结果部分
- `docs/architecture/control-manifest.md` 头部 — 提取当前
  `Manifest Version:` 日期（用于阶段4的过时检查）

---

## 阶段3：验证验收标准

对于 Story 中的每个验收标准，使用以下三种方法之一尝试验证：

### 自动验证（无需询问即可运行）

- **文件存在检查**：`Glob` 查找 Story 说将要创建的文件。
- **测试通过检查**：如果提到了测试文件路径，通过 `Bash` 运行它。
- **无硬编码值检查**：`Grep` 查找游戏玩法代码路径中应该在配置文件中的数字字面量。
- **无硬编码字符串检查**：`Grep` 查找 `src/` 中应该在本地化文件中的面向玩家的字符串。
- **依赖检查**：如果标准说"依赖于 X"，检查 X 是否存在。

### 手动验证并确认（使用 `AskUserQuestion`）

- 关于主观品质的标准（"感觉响应灵敏"、"动画正确播放"）
- 关于游戏行为的标准（"玩家受到伤害时..."、"敌人响应..."）
- 性能标准（"在 X 毫秒内完成"）— 询问是否已分析或接受为假设

将最多 4 个手动验证问题批量放入一个 `AskUserQuestion` 调用中：

```
question: "[标准] 是否满足？"
options: "是 — 通过", "否 — 失败", "尚未测试"
```

### 无法验证（标记但不阻塞）

- 需要完整游戏构建才能测试的标准（端到端游戏场景）
- 标记为：`DEFERRED — 需要游戏测试会话`

### 测试-标准可追溯性

完成上方的通过/失败/延迟检查后，将每个验收标准映射到覆盖它的测试：

对于 Story 中的每个验收标准：

1. 询问：是否有测试 — 单元测试、集成测试或已确认的手动游戏测试 —
   直接验证此标准？
   - **单元测试**：在 `tests/unit/` 中检查与标准主题匹配的测试文件或函数名称
     （使用 `Glob` 和 `Grep`）
   - **集成测试**：类似地检查 `tests/integration/`
   - **手动确认**：如果上方通过 `AskUserQuestion` 以"是 — 通过"答案验证了标准，
     则将其计为手动测试

2. 生成可追溯性表格：

```
| 标准 | 测试 | 状态 |
|------|------|------|
| AC-1：[标准文本] | tests/unit/test_foo.gd::test_bar | COVERED |
| AC-2：[标准文本] | 手动游戏测试确认 | COVERED |
| AC-3：[标准文本] | — | UNTESTED |
```

3. 应用以下升级规则：

   - 如果**超过 50% 的标准是 UNTESTED**：升级为**阻塞** —
     测试覆盖率不足以确认 Story 实际完成。在覆盖率提高之前，阶段6的裁决不能为 COMPLETE。
   - 如果**部分（≤50%）标准是 UNTESTED**：保持**建议性** — 不阻塞完成，
     但必须出现在完成说明中。
   - 如果**所有标准都是 COVERED**：除在报告中包含表格外无需额外操作。

4. 对于任何建议性的未测试标准，在阶段7的完成说明中添加：
   `"未测试的标准：[AC-N 列表]。建议在后续 Story 中添加测试。"`

### 测试证据要求

根据阶段2中提取的 Story 类型，检查所需证据：

| Story 类型 | 必需证据 | 关卡级别 |
|---|---|---|
| **Logic** | `tests/unit/[system]/` 中的自动化单元测试 — 必须存在并通过 | 阻塞 |
| **Integration** | `tests/integration/[system]/` 中的集成测试或游戏测试文档 | 阻塞 |
| **Visual/Feel** | `production/qa/evidence/` 中的截图 + 签署 | 建议性 |
| **UI** | `production/qa/evidence/` 中的手动走查文档或交互测试 | 建议性 |
| **Config/Data** | `production/qa/smoke-*.md` 中的冒烟测试通过报告 | 建议性 |

**对于 Logic Story**：首先读取 Story 的 **Test Evidence** 部分以提取
确切的所需文件路径。使用 `Glob` 检查该确切路径。如果在该确切路径找不到，
也在 `tests/unit/[system]/` 范围内广泛搜索（文件可能在略有不同的位置）。
如果在任何位置都找不到测试文件：
- 标记为**阻塞**："Logic Story 没有单元测试文件。Story 要求它在
  `[Test Evidence 部分的确切路径]`。在将此 Story 标记为 Complete 之前创建并运行测试。"

**对于 Integration Story**：读取 Story 的 **Test Evidence** 部分获取确切的
所需路径。首先使用 `Glob` 检查该确切路径，然后在 `tests/integration/[system]/` 中
广泛搜索，然后检查 `production/session-logs/` 中引用此 Story 的游戏测试记录。
如果未找到：标记为**阻塞**（与 Logic 相同的规则）。

**对于 Visual/Feel 和 UI Story**：glob `production/qa/evidence/` 查找
引用此 Story 的文件。如果未找到：标记为**建议性** —
"未找到手动测试证据。在最终关闭之前，使用测试证据模板创建
`production/qa/evidence/[story-slug]-evidence.md` 并获取签署。"

**对于 Config/Data Story**：检查是否存在任何 `production/qa/smoke-*.md` 文件。
如果未找到：标记为**建议性** — "未找到冒烟测试报告。运行 `/smoke-check`。"

**如果未设置 Story 类型**：标记为**建议性** —
"未声明 Story 类型。在 Story 头部添加 `Type: [Logic|Integration|Visual/Feel|UI|Config/Data]`
以在未来 Story 中启用测试证据关卡执行。"

任何阻塞性测试证据差距都会阻止阶段6中的 COMPLETE 裁决。

---

## 阶段4：检查偏差

将实现与设计文档进行比较。

自动运行这些检查：

1. **GDD 规则检查**：使用 `tr-registry.yaml` 中的当前需求文本
   （按 Story 的 TR-ID 查找），检查实现是否反映了 GDD 现在实际要求的内容 —
   而不是写 Story 时要求的内容。
   `Grep` 实现文件中当前 GDD 部分提到的关键函数名、数据结构或类名。

2. **清单版本过时检查**：将 Story 头部中嵌入的 `Manifest Version:` 日期
   与当前 `docs/architecture/control-manifest.md` 头部中的 `Manifest Version:` 日期进行比较。
   - 如果匹配 → 静默通过。
   - 如果 Story 版本更旧 → 标记为建议性：
     `建议性：Story 根据清单 v[story-date] 编写；当前清单为 v[current-date]。可能适用新规则。运行 /story-readiness 检查。`
   - 如果 control-manifest.md 不存在 → 跳过此检查。

3. **ADR 约束检查**：读取引用的 ADR 的决策部分。如果存在 `docs/architecture/control-manifest.md`，
   检查禁止的模式。`Grep` ADR 中明确禁止的模式。

4. **硬编码值检查**：`Grep` 实现文件中游戏逻辑中应该在数据文件中的数字字面量。

5. **范围检查**：实现是否触及了 Story 规定范围之外的文件？
   （"要创建/修改的文件"中未列出的文件）

对于每个发现的偏差，分类：

- **阻塞** — 实现与 GDD 或 ADR 矛盾（标记为完成前必须修复）
- **建议性** — 实现与规范略有偏差但功能等效（记录，用户决定）
- **超出范围** — 触及了 Story 规定边界之外的额外文件（标记提示 — 可能有效或可能是范围蔓延）

---

## 阶段4b：QA 覆盖率关卡

**审查模式检查** — 在生成 QL-TEST-COVERAGE 之前应用：
- `solo` → 跳过。注明："QL-TEST-COVERAGE 已跳过 — Solo 模式。"继续阶段5。
- `lean` → 跳过（非 PHASE-GATE）。注明："QL-TEST-COVERAGE 已跳过 — Lean 模式。"继续阶段5。
- `full` → 正常生成。

完成阶段4的偏差检查后，通过 Task 生成 `qa-lead`，使用关卡 **QL-TEST-COVERAGE**（`.claude/docs/director-gates.md`）。

传递：
- Story 文件路径和 Story 类型
- 阶段3中找到的测试文件路径（确切路径，或"未找到"）
- Story 的 `## QA Test Cases` 部分（Story 创建时预先编写的测试规范）
- Story 的 `## Acceptance Criteria` 列表

qa-lead 检查测试是否真正覆盖了规定的内容 — 不仅仅是文件是否存在。

应用裁决：
- **ADEQUATE** → 继续阶段5
- **GAPS** → 标记为**建议性**："QA 主管发现覆盖差距：[列表]。Story 可以完成，但应在后续 Story 中解决差距。"
- **INADEQUATE** → 标记为**阻塞**："QA 主管：关键逻辑未测试。在覆盖率提高之前裁决不能为 COMPLETE。具体差距：[列表]。"

对于 Config/Data Story 跳过此阶段（不需要代码测试）。

---

## 阶段5：首席程序员代码审查关卡

**审查模式检查** — 在生成 LP-CODE-REVIEW 之前应用：
- `solo` → 跳过。注明："LP-CODE-REVIEW 已跳过 — Solo 模式。"继续阶段6（完成报告）。
- `lean` → 跳过（非 PHASE-GATE）。注明："LP-CODE-REVIEW 已跳过 — Lean 模式。"继续阶段6（完成报告）。
- `full` → 正常生成。

通过 Task 生成 `lead-programmer`，使用关卡 **LP-CODE-REVIEW**（`.claude/docs/director-gates.md`）。

传递：实现文件路径、Story 文件路径、相关 GDD 部分、管理 ADR。

向用户呈现裁决。如果 CONCERNS，通过 `AskUserQuestion` 呈现：
- 选项：`修改标记的问题` / `接受并继续` / `进一步讨论`
如果 REJECT，在问题解决之前不继续阶段6裁决。

如果 Story 还没有实现文件（裁决在编码完成前运行），跳过此阶段并注明："LP-CODE-REVIEW 已跳过 — 未找到实现文件。在实现完成后运行。"

---

## 阶段6：呈现完成报告

在更新任何文件之前，呈现完整报告：

```markdown
## Story 完成：[Story 名称]
**Story**：[文件路径]
**日期**：[今天]

### 验收标准：[X/Y 通过]
- [x] [标准1] — 自动验证（测试通过）
- [x] [标准2] — 已确认
- [ ] [标准3] — 失败：[原因]
- [?] [标准4] — DEFERRED：需要游戏测试

### 测试-标准可追溯性
| 标准 | 测试 | 状态 |
|------|------|------|
| AC-1：[文本] | [测试文件::测试名称] | COVERED |
| AC-2：[文本] | 手动确认 | COVERED |
| AC-3：[文本] | — | UNTESTED |

### 测试证据
**Story 类型**：[Logic | Integration | Visual/Feel | UI | Config/Data | 未声明]
**必需证据**：[单元测试文件 | 集成测试或游戏测试 | 截图 + 签署 | 走查文档 | 冒烟测试通过]
**找到的证据**：[是 — `[路径]` | 否 — 阻塞 | 否 — 建议性]

### 偏差
[无] 或：
- 阻塞：[描述] — [GDD/ADR 引用]
- 建议性：[描述] — 用户接受 / 标记为技术债务

### 范围
[所有变更在规定范围内] 或：
- 触及的额外文件：[列表] — [注明是否有效或范围蔓延]

### 裁决：COMPLETE / COMPLETE WITH NOTES / BLOCKED
```

**裁决定义：**
- **COMPLETE**：所有标准通过，无阻塞性偏差
- **COMPLETE WITH NOTES**：所有标准通过，已记录建议性偏差
- **BLOCKED**：失败的标准或阻塞性偏差必须先解决

如果裁决是 **BLOCKED**：不继续阶段7。列出必须修复的内容。提供帮助修复阻塞项。

---

## 阶段7：更新 Story 状态

写入前询问："我可以更新 Story 文件将其标记为 Complete 并记录完成说明吗？"

如果是，编辑 Story 文件：

1. 更新状态字段：`Status: Complete`
2. 在底部添加 `## Completion Notes` 部分：

```markdown
## 完成说明
**完成日期**：[日期]
**标准**：[X/Y 通过]（[任何延迟的项目列出]）
**偏差**：[无] 或 [建议性偏差列表]
**测试证据**：[Logic：路径处的测试文件 | Visual/Feel：路径处的证据文档 | 无需（Config/Data）]
**代码审查**：[待定 / 完成 / 已跳过]
```

3. 如果存在建议性偏差，询问："是否应将这些记录为 `docs/tech-debt-register.md` 中的技术债务？"

4. **更新 `production/sprint-status.yaml`**（如果存在）：
   - 找到与此 Story 文件路径或 ID 匹配的条目
   - 设置 `status: done` 和 `completed: [今天的日期]`
   - 更新顶级 `updated` 字段
   - 这是静默更新 — 不需要额外批准（上方步骤已批准）

### 会话状态更新

更新 Story 文件后，静默追加到 `production/session-state/active.md`：

    ## 会话提取 — /story-done [日期]
    - 裁决：[COMPLETE / COMPLETE WITH NOTES / BLOCKED]
    - Story：[Story 文件路径] — [Story 标题]
    - 记录的技术债务：[N 项，或"无"]
    - 下一步推荐：[下一个就绪 Story 标题和路径，或"未识别"]

如果 `active.md` 不存在，以此块为初始内容创建它。
在对话中确认："会话状态已更新。"

---

## 阶段8：呈现下一个 Story

完成后，帮助开发人员保持动力：

1. 从 `production/sprints/` 读取当前 Sprint 计划。
2. 找到满足以下条件的 Story：
   - 状态：READY 或 NOT STARTED
   - 未被其他未完成的 Story 阻塞
   - 处于 Must Have 或 Should Have 层级

呈现：

```
### 下一步
以下 Story 准备好可以开始：
1. [Story 名称] — [1行描述] — 估算：[X 小时]
2. [Story 名称] — [1行描述] — 估算：[X 小时]

在开始之前运行 `/story-readiness [路径]` 确认 Story 准备好实现。
```

如果此 Sprint 中没有更多 Must Have Story（全部为 Complete 或 Blocked）：

```
### Sprint 收尾流程

所有 Must Have Story 已完成。在推进之前需要 QA 签署。
按顺序运行：

1. `/smoke-check sprint` — 验证关键路径仍然端到端工作
2. `/team-qa sprint` — 完整 QA 周期：测试用例执行、Bug 分类、签署报告
3. `/gate-check` — QA 批准后推进到下一阶段

在 `/team-qa` 返回 APPROVED 或 APPROVED WITH CONDITIONS 之前不要运行 `/gate-check`。
```

如果仍有 Should Have Story 未开始，在收尾流程旁呈现它们，让用户选择：
现在关闭 Sprint，还是先拉入更多工作。

如果没有更多 Story 就绪但 Must Have Story 仍在进行中（未 Complete）：
"没有更多 Story 准备好开始 — [N] 个 Must Have Story 仍在进行中。在 Sprint 收尾前继续实现这些。"

---

## 协作协议

- **未经用户批准永不将 Story 标记为完成** — 阶段7需要
  明确的"是"才能编辑任何文件。
- **永不自动修复失败的标准** — 报告它们并询问该怎么做。
- **偏差是事实，不是判断** — 中立地呈现；用户决定是否可接受。
- **BLOCKED 裁决是建议性的** — 用户可以覆盖并无论如何标记为完成；
  如果用户这样做，明确记录风险。
- 对代码审查提示和批量手动标准确认使用 `AskUserQuestion`。

---

## 推荐的后续步骤

- 运行 `/story-readiness [next-story-path]` 在开始实现之前验证下一个 Story
- 如果所有 Must Have Story 已完成：运行 `/smoke-check sprint` → `/team-qa sprint` → `/gate-check`
- 如果记录了技术债务：通过 `/tech-debt` 跟踪以保持注册表最新
