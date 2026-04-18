---
name: create-epics
description: "将已批准的GDD和架构转换为史诗 — 每个架构模块一个史诗。定义范围、管理ADR、引擎风险和未追踪需求。不分解为故事 — 每个史诗创建后运行/create-stories [epic-slug]。"
argument-hint: "[system-name | layer: foundation|core|feature|presentation | all] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
agent: technical-director
---

# 创建史诗

史诗是映射到单个架构模块的具名、有边界的工作体。它定义**需要构建什么**以及**谁在架构上负责**。它不规定实现步骤 — 那是story的工作。

**每层运行一次此技能**，在开发该层时执行。不要在Core层接近完成之前创建Feature层史诗 — 设计会发生变化。

**输出：** `production/epics/[epic-slug]/EPIC.md` + `production/epics/index.md`

**每个史诗创建后的下一步：** `/create-stories [epic-slug]`

**运行时机：** `/create-control-manifest` 和 `/architecture-review` 通过之后。

---

## 1. 解析参数

解析审查模式（一次性确定，本次运行中所有阶段门生成均使用此模式）：
1. 如果传入 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

详见 `.claude/docs/director-gates.md` 的完整检查模式。

**模式：**
- `/create-epics all` — 按层级顺序处理所有系统
- `/create-epics layer: foundation` — 仅Foundation层
- `/create-epics layer: core` — 仅Core层
- `/create-epics layer: feature` — 仅Feature层
- `/create-epics layer: presentation` — 仅Presentation层
- `/create-epics [system-name]` — 单个特定系统
- 无参数 — 询问："您希望为哪个层级或系统创建史诗？"

---

## 2. 加载输入

### 步骤 2a — 摘要扫描（快速）

在完整读取任何文件之前，先Grep所有GDD的 `## Summary` 部分：

```
Grep pattern="## Summary" glob="design/gdd/*.md" output_mode="content" -A 5
```

对于 `layer:` 或 `[system-name]` 模式：根据摘要快速参考过滤仅在范围内的GDD。跳过完整读取任何超出范围的内容。

### 步骤 2b — 完整文档加载（仅限范围内的系统）

利用步骤2a的grep结果，识别哪些系统在范围内。**仅为范围内的系统**完整读取文档 — 不读取超出范围系统或层级的GDD或ADR。

为范围内的系统读取：

- `design/gdd/systems-index.md` — 权威系统列表、层级、优先级
- 仅范围内的GDD（已批准或已设计状态，由步骤2a结果过滤）
- `docs/architecture/architecture.md` — 模块所有权和API边界
- **仅涵盖范围内系统领域的**已接受ADR — 读取"GDD Requirements Addressed"、"Decision"和"Engine Compatibility"部分；跳过与无关领域相关的ADR
- `docs/architecture/control-manifest.md` — 从头部获取清单版本日期
- `docs/architecture/tr-registry.yaml` — 用于将需求追踪到ADR覆盖
- `docs/engine-reference/[engine]/VERSION.md` — 引擎名称、版本、风险级别

报告："已加载 [N] 个GDD、[M] 个ADR，引擎：[名称 + 版本]。"

---

## 3. 处理顺序

按依赖安全的层级顺序处理：
1. **Foundation**（无依赖）
2. **Core**（依赖Foundation）
3. **Feature**（依赖Core）
4. **Presentation**（依赖Feature + Core）

每层内部，使用 `systems-index.md` 中的顺序。

---

## 4. 定义每个史诗

对于每个系统，将其映射到 `architecture.md` 中的架构模块。

对照TR注册表检查ADR覆盖率：
- **已追踪需求**：拥有已接受ADR覆盖的TR-ID
- **未追踪需求**：无ADR的TR-ID — 在继续之前发出警告

写入任何内容之前展示给用户：

```
## 史诗：[系统名称]

**层级**：[Foundation / Core / Feature / Presentation]
**GDD**：design/gdd/[filename].md
**架构模块**：[来自architecture.md的模块名称]
**管理ADR**：[ADR-NNNN, ADR-MMMM]
**引擎风险**：[LOW / MEDIUM / HIGH — 管理ADR中的最高风险]
**ADR覆盖的GDD需求**：[N / 总数]
**未追踪需求**：[无ADR的TR-ID列表，或"无"]
```

如果存在未追踪需求：
> "⚠️ [系统] 中有 [N] 个需求没有ADR。史诗可以创建，但这些需求的story将标记为Blocked，直到ADR存在为止。先运行 `/architecture-decision`，或使用占位符继续。"

询问："我应该创建史诗：[名称] 吗？"
选项："是，创建它"、"跳过"、"暂停 — 我需要先编写ADR"

---

## 4b. 制作人史诗结构阶段门

**审查模式检查** — 在生成 PR-EPIC 之前执行：
- `solo` → 跳过。记录："PR-EPIC 已跳过 — Solo 模式。"进行第5步（写入史诗文件）。
- `lean` → 跳过（非PHASE-GATE）。记录："PR-EPIC 已跳过 — Lean 模式。"进行第5步（写入史诗文件）。
- `full` → 正常生成。

在当前层级的所有史诗都定义完成（第4步对所有范围内系统完成）后，在写入任何文件之前，通过 Task 生成 `producer`，使用阶段门 **PR-EPIC**（`.claude/docs/director-gates.md`）。

传递：完整史诗结构摘要（所有史诗、范围摘要、管理ADR数量）、正在处理的层级、里程碑时间线和团队容量。

展示制作人的评估。如果UNREALISTIC，提供修订史诗边界（拆分超出范围或合并范围不足的史诗）的选项，然后再写入。如果CONCERNS，提交给用户决定。在制作人阶段门解决之前不写入史诗文件。

---

## 5. 写入史诗文件

获批后，询问："我可以将史诗文件写入 `production/epics/[epic-slug]/EPIC.md` 吗？"

用户确认后写入：

### `production/epics/[epic-slug]/EPIC.md`

```markdown
# 史诗：[系统名称]

> **层级**：[Foundation / Core / Feature / Presentation]
> **GDD**：design/gdd/[filename].md
> **架构模块**：[模块名称]
> **状态**：Ready
> **Stories**：尚未创建 — 运行 `/create-stories [epic-slug]`

## 概述

[1段描述此史诗实现的内容，源自GDD概述和架构模块的职责说明]

## 管理ADR

| ADR | 决策摘要 | 引擎风险 |
|-----|-----------------|-------------|
| ADR-NNNN: [标题] | [1行摘要] | LOW/MEDIUM/HIGH |

## GDD需求

| TR-ID | 需求 | ADR覆盖 |
|-------|-------------|--------------|
| TR-[system]-001 | [来自注册表的需求文本] | ADR-NNNN ✅ |
| TR-[system]-002 | [需求文本] | ❌ 无ADR |

## 完成标准

此史诗在以下条件下视为完成：
- 所有story均已实现、审查并通过 `/story-done` 关闭
- 来自 `design/gdd/[filename].md` 的所有验收标准均已验证
- 所有Logic和Integration story在 `tests/` 中有通过的测试文件
- 所有Visual/Feel和UI story在 `production/qa/evidence/` 中有带签署的证据文档

## 下一步

运行 `/create-stories [epic-slug]` 将此史诗分解为可实现的story。
```

### 更新 `production/epics/index.md`

创建或更新主索引：

```markdown
# 史诗索引

最后更新：[日期]
引擎：[名称 + 版本]

| 史诗 | 层级 | 系统 | GDD | Stories | 状态 |
|------|-------|--------|-----|---------|--------|
| [名称] | Foundation | [系统] | [文件] | 尚未创建 | Ready |
```

---

## 6. 阶段门检查提醒

为请求的范围写入所有史诗后：

- **Foundation + Core 完成**：这些是预生产 → 生产阶段门的必要条件。运行 `/gate-check production` 检查准备情况。
- **提醒**：史诗定义范围。Story定义实现步骤。在开发人员可以开始工作之前，为每个史诗运行 `/create-stories [epic-slug]`。

---

## 协作协议

1. **一次一个史诗** — 在要求创建之前展示每个史诗定义
2. **警告差距** — 在继续之前标记未追踪的需求
3. **写入前询问** — 在写入任何文件之前逐史诗获得批准
4. **不凭空发明** — 所有内容来自GDD、ADR和架构文档
5. **永不创建story** — 此技能在史诗层级停止

处理完所有请求的史诗后：

- **裁决：COMPLETE** — [N] 个史诗已写入。对每个史诗运行 `/create-stories [epic-slug]`。
- **裁决：BLOCKED** — 用户拒绝了所有史诗，或未找到符合条件的系统。
