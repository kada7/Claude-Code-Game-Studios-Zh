---
name: create-stories
description: "将单个史诗分解为可实现的story文件。读取史诗、其GDD、管理ADR和控制清单。每个story嵌入其GDD需求TR-ID、ADR指导、验收标准、story类型和测试证据路径。在每个史诗创建后运行/create-epics之后执行。"
argument-hint: "[epic-slug | epic-path] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
agent: lead-programmer
---

# 创建Story

Story是单个可实现的行为 — 足够小可以在一次专注的会话中完成，自包含，并完全可追溯到GDD需求和ADR决策。Story是开发人员要拾取的内容。史诗是架构师定义的内容。

**每个史诗运行一次此技能**，而不是每层。先为Foundation史诗运行，然后是Core，依此类推 — 与依赖顺序匹配。

**输出：** `production/epics/[epic-slug]/story-NNN-[slug].md` 文件

**上一步：** `/create-epics [system]`
**Story创建后的下一步：** `/story-readiness [story-path]` 然后 `/dev-story [story-path]`

---

## 1. 解析参数

如果存在，提取 `--review [full|lean|solo]` 并作为本次运行的审查模式覆盖值存储。如果未提供，读取 `production/review-mode.txt`（缺失时默认 `full`）。此解析模式适用于本技能中所有阶段门生成 — 在每次阶段门调用之前应用 `.claude/docs/director-gates.md` 中的检查模式。

- `/create-stories [epic-slug]` — 例如 `/create-stories combat`
- `/create-stories production/epics/combat/EPIC.md` — 也接受完整路径
- 无参数 — 询问："您希望将哪个史诗分解为story？"
  使用 Glob 匹配 `production/epics/*/EPIC.md` 并列出可用史诗及其状态。

---

## 2. 加载此史诗的所有内容

完整读取：

- `production/epics/[epic-slug]/EPIC.md` — 史诗概述、管理ADR、GDD需求表
- 史诗的GDD（`design/gdd/[filename].md`）— 读取全部8个部分，特别是验收标准、公式和边界情况
- 史诗中列出的所有管理ADR — 读取Decision、Implementation Guidelines、Engine Compatibility和Engine Notes部分
- `docs/architecture/control-manifest.md` — 提取此史诗层级的规则；注意头部的清单版本日期
- `docs/architecture/tr-registry.yaml` — 加载此系统的所有TR-ID

**ADR存在验证**：读取史诗中的管理ADR列表后，确认每个ADR文件存在于磁盘上。如果找不到任何ADR文件，**立即停止**，在分解任何story之前：

> "史诗引用了 [ADR-NNNN: 标题] 但未找到 `docs/architecture/[adr-file].md`。
> 检查史诗的管理ADR列表中的文件名，或运行 `/architecture-decision`
> 创建它。在所有引用的ADR文件确认存在之前无法创建story。"

在所有引用的ADR文件确认存在之前，不要进行第3步。

报告："已加载史诗 [名称]，GDD [文件名]，[N] 个管理ADR（全部确认存在），控制清单版本 v[日期]。"

---

## 3. 按类型对Story分类

**Story类型分类** — 根据验收标准为每个story分配类型：

| Story类型 | 当标准涉及时分配... |
|---|---|
| **Logic（逻辑）** | 公式、数值阈值、状态转换、AI决策、计算 |
| **Integration（集成）** | 两个或多个系统交互、跨边界信号、存档/读档往返 |
| **Visual/Feel（视觉/感觉）** | 动画行为、VFX、"感觉响应"、时机、屏幕抖动、音频同步 |
| **UI** | 菜单、HUD元素、按钮、屏幕、对话框、工具提示 |
| **Config/Data（配置/数据）** | 仅平衡调整值、仅数据文件变更 — 无新代码逻辑 |

混合story：分配实现风险最高的类型。
类型决定 `/story-done` 关闭story之前需要什么测试证据。

---

## 4. 将GDD分解为Story

对于每个GDD验收标准：

1. 将需要相同核心实现的相关标准分组
2. 每个组 = 一个story
3. Story排序：基础行为优先，边界情况最后，UI最后

**Story大小规则：** 一个story = 一次专注的会话（约2-4小时）。如果一组标准需要更长时间，则拆分为两个story。

对于每个story，确定：
- **GDD需求**：这满足哪些验收标准？
- **TR-ID**：在 `tr-registry.yaml` 中查找。使用稳定ID。如果没有匹配，使用 `TR-[system]-???` 并发出警告。
- **管理ADR**：哪个ADR管理如何实现这个？
  - `Status: Accepted` → 正常嵌入
  - `Status: Proposed` → 将story `Status` 设为 Blocked，备注："BLOCKED: ADR-NNNN 处于Proposed状态 — 运行 `/architecture-decision` 推进它"
- **Story类型**：来自第3步分类
- **引擎风险**：来自ADR的知识风险字段

---

## 4b. QA主管Story就绪阶段门

**审查模式检查** — 在生成 QL-STORY-READY 之前执行：
- `solo` → 跳过。记录："QL-STORY-READY 已跳过 — Solo 模式。"进行第5步（展示story供审查）。
- `lean` → 跳过（非PHASE-GATE）。记录："QL-STORY-READY 已跳过 — Lean 模式。"进行第5步（展示story供审查）。
- `full` → 正常生成。

在所有story分解完成（第4步完成）后但在展示它们供写入批准之前，通过 Task 生成 `qa-lead`，使用阶段门 **QL-STORY-READY**（`.claude/docs/director-gates.md`）。

传递：包含验收标准、story类型和TR-ID的完整story列表；参考用的史诗GDD验收标准。

展示QA主管的评估。对于每个被标记为GAPS或INADEQUATE的story，在继续之前修改验收标准 — 具有不可测标准的story无法正确实现。一旦所有story达到ADEQUATE，继续进行。

**ADEQUATE之后**：对于每个Logic和Integration story，要求qa-lead产生具体的测试用例规范 — 每个验收标准一个 — 格式如下：

```
测试：[标准文本]
  前提：[前置条件]
  当：[操作]
  则：[预期结果/断言]
  边界情况：[要测试的边界值或失败状态]
```

对于Visual/Feel和UI story，改为产生手动验证步骤：
```
手动检查：[标准文本]
  设置：[如何到达该状态]
  验证：[要查找的内容]
  通过条件：[明确的通过描述]
```

这些测试用例规范直接嵌入每个story的 `## QA测试用例` 部分。开发人员针对这些用例进行实现。程序员不需要从头编写测试 — QA已经定义了"完成"的样子。

---

## 5. 展示Story供审查

写入任何文件之前，展示完整story列表：

```
## 史诗的Story：[名称]

Story 001：[标题] — Logic — ADR-NNNN
  涵盖：TR-[system]-001（[需求1行摘要]）
  需要测试：tests/unit/[system]/[slug]_test.[ext]

Story 002：[标题] — Integration — ADR-MMMM
  涵盖：TR-[system]-002, TR-[system]-003
  需要测试：tests/integration/[system]/[slug]_test.[ext]

Story 003：[标题] — Visual/Feel — ADR-NNNN
  涵盖：TR-[system]-004
  需要证据：production/qa/evidence/[slug]-evidence.md

[共N个story：N个Logic，N个Integration，N个Visual/Feel，N个UI，N个Config/Data]
```

使用 `AskUserQuestion`：
- 提示："我可以将这 [N] 个story写入 `production/epics/[epic-slug]/` 吗？"
- 选项：`[A] 是 — 写入所有 [N] 个story` / `[B] 暂不 — 我想先审查或调整`

---

## 6. 写入Story文件

对于每个story，写入 `production/epics/[epic-slug]/story-[NNN]-[slug].md`：

```markdown
# Story [NNN]：[标题]

> **史诗**：[史诗名称]
> **状态**：Ready
> **层级**：[Foundation / Core / Feature / Presentation]
> **类型**：[Logic | Integration | Visual/Feel | UI | Config/Data]
> **清单版本**：[来自control-manifest.md头部的日期]

## 上下文

**GDD**：`design/gdd/[filename].md`
**需求**：`TR-[system]-NNN`
*（需求文本在 `docs/architecture/tr-registry.yaml` 中 — 审查时重新读取）*

**管理实现的ADR**：[ADR-NNNN: 标题]
**ADR决策摘要**：[ADR决定的1-2句摘要]

**引擎**：[名称 + 版本] | **风险**：[LOW / MEDIUM / HIGH]
**引擎说明**：[来自ADR引擎兼容性部分 — 截止日期后API、需要验证]

**控制清单规则（此层级）**：
- 必须：[相关必须模式]
- 禁止：[相关禁止模式]
- 护栏：[相关性能护栏]

---

## 验收标准

*来自GDD `design/gdd/[filename].md`，范围限定在此story：*

- [ ] [标准1 — 直接来自GDD]
- [ ] [标准2]
- [ ] [性能标准（如适用）]

---

## 实现说明

*源自ADR-NNNN实现指南：*

[来自ADR的具体、可操作指导。不要以改变含义的方式转述。这是程序员阅读的内容，而不是ADR本身。]

---

## 超出范围

*由相邻story处理 — 不要在此实现：*

- [Story NNN+1]：[它处理的内容]

---

## QA测试用例

*由qa-lead在story创建时编写。开发人员针对这些用例实现 — 不要在实现期间发明新的测试用例。*

**[对于Logic / Integration story — 自动化测试规范]：**

- **AC-1**：[标准文本]
  - 前提：[前置条件]
  - 当：[操作]
  - 则：[断言]
  - 边界情况：[边界值/失败状态]

**[对于Visual/Feel / UI story — 手动验证步骤]：**

- **AC-1**：[标准文本]
  - 设置：[如何到达该状态]
  - 验证：[要查找的内容]
  - 通过条件：[明确的通过描述]

---

## 测试证据

**Story类型**：[类型]
**需要的证据**：
- Logic：`tests/unit/[system]/[story-slug]_test.[ext]` — 必须存在并通过
- Integration：`tests/integration/[system]/[story-slug]_test.[ext]` 或游戏测试文档
- Visual/Feel：`production/qa/evidence/[story-slug]-evidence.md` + 签署
- UI：`production/qa/evidence/[story-slug]-evidence.md` 或交互测试
- Config/Data：冒烟测试通过（`production/qa/smoke-*.md`）

**状态**：[ ] 尚未创建

---

## 依赖关系

- 依赖：[Story NNN-1 必须处于DONE状态，或"无"]
- 解锁：[Story NNN+1，或"无"]
```

### 同时更新 `production/epics/[epic-slug]/EPIC.md`

将"Stories: 尚未创建"行替换为填充的表格：

```markdown
## Stories

| # | Story | 类型 | 状态 | ADR |
|---|-------|------|--------|-----|
| 001 | [标题] | Logic | Ready | ADR-NNNN |
| 002 | [标题] | Integration | Ready | ADR-MMMM |
```

---

## 7. 写入后

使用 `AskUserQuestion` 以上下文感知的后续步骤关闭：

检查：
- 在 `production/epics/` 中是否有其他还没有story的史诗？列出它们。
- 这是最后一个史诗吗？如果是，将 `/sprint-plan` 作为选项。

Widget：
- 提示："[N] 个story已写入 `production/epics/[epic-slug]/`。下一步？"
- 选项（包含所有适用的）：
  - `[A] 开始实现 — 运行 /story-readiness [第一个story路径]`（推荐）
  - `[B] 为 [next-epic-slug] 创建story — 运行 /create-stories [slug]`（仅当其他史诗还没有story时）
  - `[C] 规划冲刺 — 运行 /sprint-plan`（仅当所有史诗都有story时）
  - `[D] 本次会话停在这里`

在输出中注明："按顺序完成story — 每个story的 `依赖关系:` 字段告诉你在开始之前必须完成什么。"

---

## 协作协议

1. **展示前先读取** — 在显示story列表之前静默加载所有输入
2. **一次询问** — 在一个摘要中展示史诗的所有story，而不是逐个
3. **警告被阻塞的story** — 在写入之前标记任何具有Proposed ADR的story
4. **写入前询问** — 在写入文件之前获得完整story集的批准
5. **不凭空发明** — 验收标准来自GDD，实现说明来自ADR，规则来自清单
6. **永不开始实现** — 此技能在story文件层级停止

写入后（或拒绝后）：

- **裁决：COMPLETE** — [N] 个story已写入 `production/epics/[epic-slug]/`。运行 `/story-readiness` → `/dev-story` 开始实现。
- **裁决：BLOCKED** — 用户拒绝。未写入story文件。
