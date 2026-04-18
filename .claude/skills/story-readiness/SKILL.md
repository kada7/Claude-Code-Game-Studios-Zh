---
name: story-readiness
description: "验证 Story 文件是否已具备实现条件。检查嵌入的 GDD 需求、ADR 引用、引擎说明、清晰的验收标准以及无未解决的设计问题。生成 READY / NEEDS WORK / BLOCKED 裁决及具体差距。当用户说"这个 Story 准备好了吗"、"我可以开始这个 Story 吗"时使用。"
argument-hint: "[story-file-path or 'all' or 'sprint']"
user-invocable: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, Task
model: haiku
---

# Story 就绪检查

此技能验证 Story 文件是否包含开发人员开始实现所需的一切内容 — 
无需 Sprint 中途打断设计、无需猜测、无模糊的验收标准。在分配 Story 前运行。

**此技能是只读的。** 它永不编辑 Story 文件。它报告结果并询问
用户是否需要帮助填补差距。

**输出：** 每个 Story 的裁决（READY / NEEDS WORK / BLOCKED）以及每个不满足条件的 Story 的具体差距列表。

---

## 阶段0：解析审查模式

在启动时解析一次审查模式（存储以供本次运行中所有关卡生成使用）：

1. 如果技能以 `--review [full|lean|solo]` 调用 → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认为 `lean`

完整检查模式详见 `.claude/docs/director-gates.md`。

---

## 1. 解析参数

**范围：** `$ARGUMENTS[0]`（空白 = 通过 AskUserQuestion 询问用户）

- **特定路径**（例如 `/story-readiness production/epics/combat/story-001-basic-attack.md`）：
  验证该单个 Story 文件。
- **`sprint`**：从 `production/sprints/` 读取当前 Sprint 计划（最近的文件），
  提取其引用的每个 Story 路径，逐一验证。
- **`all`**：Glob `production/epics/**/*.md`，排除 `EPIC.md` 索引文件，
  验证找到的每个 Story 文件。
- **无参数**：询问用户要验证哪个范围。

如果未提供参数，使用 `AskUserQuestion`：
- "您想验证什么？"
  - 选项：「一个特定的 Story 文件」、「当前 Sprint 中的所有 Story」、
    「production/epics/ 中的所有 Story」、「特定史诗的 Story」

在继续之前报告范围："正在验证 [N] 个 Story 文件。"

---

## 2. 加载支持上下文

在检查任何 Story 之前，加载一次参考文档（而非每个 Story 加载一次）：

- `design/gdd/systems-index.md` — 了解哪些系统有已批准的 GDD
- `docs/architecture/control-manifest.md` — 了解存在哪些清单规则
  （如果文件不存在，注明一次缺失；不要对每个 Story 重复标记）
  如果文件存在，从头部块提取 `Manifest Version:` 日期。
- `docs/architecture/tr-registry.yaml` — 按 `id` 索引所有条目。用于
  验证 Story 中的 TR-ID。如果文件不存在，注明一次；所有 Story 的 TR-ID
  检查将自动通过（注册表先于 Story 存在，因此缺失的注册表意味着 Story 是在 TR 跟踪引入之前创建的）。
- 所有 ADR 状态字段 — 对于被检查 Story 中引用的每个唯一 ADR，
  读取 ADR 文件并记录其 `Status:` 字段。缓存这些内容，避免对每个 Story 重复读取同一 ADR。
- 当前 Sprint 文件（如果范围是 `sprint`）— 识别 Must Have / Should Have 优先级以供升级决策

---

## 3. Story 就绪检查清单

对于每个 Story 文件，评估以下每个项目。只有当所有
项目通过或明确标注 N/A 并说明原因时，Story 才是 READY。

### 设计完整性

- [ ] **引用了 GDD 需求**：Story 包含 `design/gdd/` 路径，
  并引用或链接了该 GDD 中的特定需求、验收标准或规则 —
  而不仅仅是 GDD 文件名。仅链接文档而不追踪到具体需求不通过。
- [ ] **需求是自包含的**：Story 中的验收标准无需打开 GDD 即可理解。
  开发人员无需阅读单独的文档就能理解什么是"完成"的意思。
- [ ] **验收标准可测试**：每个标准都是具体的、可观察的条件 —
  而不是"实现 X"或"系统正确工作"。
  反例："实现跳跃机制。" 正例："按住跳跃键时，0.3 秒内跳跃达到最大高度 5 个单位。"
- [ ] **无需判断的验收标准**：像"感觉响应灵敏"或"看起来不错"
  这样的标准在没有定义基准的情况下无法测试。必须用具体可观察的条件或
  游戏测试协议替换。

### 架构完整性

- [ ] **引用了 ADR 或声明了 N/A**：Story 至少引用一个 ADR，
  或明确声明"不适用 ADR"并简要说明原因。
  没有 ADR 引用且没有明确 N/A 注记的 Story 不通过此检查。
- [ ] **ADR 已接受（非 Proposed）**：对于每个引用的 ADR，使用第2节加载的缓存 ADR 状态检查其 `Status:` 字段。
  - 如果 `Status: Accepted` → 通过。
  - 如果 `Status: Proposed` → **BLOCKED**：ADR 可能在被接受前发生变更，
    Story 的实现指南可能有误。
    修复：`BLOCKED: ADR-NNNN 处于 Proposed 状态 — 在实现前等待接受。`
  - 如果 ADR 文件不存在 → **BLOCKED**：引用的 ADR 缺失。
  - 如果 Story 有明确的"不适用 ADR" N/A 注记则自动通过。
- [ ] **TR-ID 有效且活跃**：如果 Story 包含 `TR-[system]-NNN`
  引用，在第2节加载的 TR 注册表中查找。
  - 如果 ID 存在且 `status: active` → 通过。
  - 如果 ID 存在且 `status: deprecated` 或 `status: superseded-by: ...` →
    NEEDS WORK：需求已删除或替换。
    修复：更新 Story 以引用当前需求 ID 或在不再适用时删除。
  - 如果 ID 在注册表中不存在 → NEEDS WORK：ID 未注册
    （Story 可能早于注册表，或注册表需要运行 `/architecture-review`）。
  - 如果 Story 没有 TR-ID 引用或注册表不存在则自动通过。
- [ ] **清单版本是最新的**：如果 Story 头部有 `Manifest Version:` 日期
  且 `docs/architecture/control-manifest.md` 存在：
  - 如果 Story 版本与当前清单 `Manifest Version:` 匹配 → 通过。
  - 如果 Story 版本比当前清单旧 → NEEDS WORK：可能适用新规则。
    修复：检查更改的清单规则，如果任何禁止/必需条目发生更改则更新 Story，
    然后将 Story 的 `Manifest Version:` 更新为当前版本。
  - 如果 Story 没有 `Manifest Version:` 字段或清单不存在则自动通过。
- [ ] **存在引擎说明**：对于此 Story 可能触及的任何截止日期后引擎 API，
  包含实现说明或验证要求。如果 Story 明显不涉及引擎 API（例如，纯数据/配置变更），
  "不适用 — 不涉及引擎 API"是可接受的。
- [ ] **注明了控制清单规则**：引用了控制清单中的相关层规则，
  或声明了"不适用 — 清单尚未创建"。
  如果 `docs/architecture/control-manifest.md` 尚不存在，此项自动通过
  （不惩罚在清单创建之前编写的 Story）。

### 范围清晰度

- [ ] **存在估算**：Story 包含规模估算（小时数、点数或 T 恤尺寸）。
  没有估算的 Story 无法规划。
- [ ] **说明了范围内/范围外边界**：Story 说明了它**不**包含的内容，
  要么在明确的"超出范围"部分，要么用语言使边界清晰无误。没有这些，
  实现期间范围蔓延是很可能的。
- [ ] **列出了 Story 依赖关系**：如果此 Story 依赖于其他 Story 先完成，
  则列出那些 Story ID。如果没有依赖关系，明确声明"无"（不只是省略）。

### 未解决问题

- [ ] **无未解决的设计问题**：Story 在任何验收标准、实现说明或规则声明中
  不包含标记为"UNRESOLVED"、"TBD"、"TODO"、"?"或等效标记的文本。
- [ ] **依赖 Story 不在 DRAFT 状态**：对于列为依赖的每个 Story，
  检查文件是否存在且状态不为 DRAFT。依赖 DRAFT 或缺失 Story 的 Story
  是 BLOCKED，而不仅仅是 NEEDS WORK。

### 资产引用检查

- [ ] **引用的资产存在**：扫描 Story 文本中的资产路径模式
  （包含 `assets/` 的路径，或文件扩展名 `.png`、`.jpg`、`.svg`、
  `.wav`、`.ogg`、`.mp3`、`.glb`、`.gltf`、`.tres`、`.tscn`、`.res`）。
  - 对于每个找到的资产路径：使用 Glob 检查文件是否存在。
  - 如果任何引用的资产不存在：**NEEDS WORK** — 注明缺失的路径。
    （Story 引用了尚未创建的资产。要么删除引用，创建占位符，或将其标记为对资产创建 Story 的明确依赖。）
  - 如果所有引用的资产都存在：注明"已验证引用的资产：找到 [数量] 个。"
  - 如果 Story 中没有引用资产路径：注明"Story 中未找到资产引用 — 跳过资产检查。"此项自动通过。
  - 这是仅检查存在性。不验证文件格式或内容。

### 完成定义

- [ ] **至少 3 个可测试的验收标准**：少于 3 个表明
  Story 要么过于简单（它应该是一个 Story 吗？）要么规格不足。
- [ ] **如果适用则注明了性能预算**：如果此 Story 涉及游戏循环、
  渲染或物理的任何部分，存在性能预算或"预期无性能影响 — [原因]"的注记。
- [ ] **声明了 Story 类型**：Story 在其头部包含 `Type:` 字段，
  标识测试类别（Logic / Integration / Visual/Feel / UI / Config/Data）。
  没有这个，Story 关闭时无法执行测试证据要求。
  修复：在 Story 头部添加 `Type: [Logic|Integration|Visual/Feel|UI|Config/Data]`。
- [ ] **测试证据要求清晰**：如果设置了 Story 类型，Story 包含
  `## Test Evidence` 部分，说明证据将存储在哪里（Logic/Integration 的测试文件路径，
  或 Visual/Feel/UI 的证据文档路径）。
  修复：为 Story 类型添加包含预期证据位置的 `## Test Evidence`。

---

## 4. 裁决分配

为每个 Story 分配三种裁决之一：

**READY** — 所有检查清单项目通过或有明确的 N/A 理由。
Story 可以立即分配。

**NEEDS WORK** — 一个或多个检查清单项目失败，但所有依赖 Story
存在且不在 DRAFT 状态。Story 可以在分配之前修复。

**BLOCKED** — 一个或多个依赖 Story 缺失或处于 DRAFT 状态，
或关键设计问题（在标准或规则中标记为 UNRESOLVED）没有负责人。
在解决阻塞项之前无法分配该 Story。注意：BLOCKED 的 Story 也可能有 NEEDS WORK 项目 — 两者都列出。

---

## 5. 输出格式

### 单个 Story 输出

```
## Story 就绪检查：[Story 标题]
文件：[路径]
裁决：[READY / NEEDS WORK / BLOCKED]

### 通过的检查（N/[总数]）
[简要列出通过的项目]

### 差距
- [检查清单项目]：[缺失或错误的具体描述]
  修复：[解决此差距所需的具体文本]

### 阻塞项（如果 BLOCKED）
- [什么在阻塞]：[必须先解决的 Story ID 或设计问题]
```

### 多个 Story 汇总输出

```
## Story 就绪检查摘要 — [范围] — [日期]

就绪：      [N] 个 Story
需要完善：  [N] 个 Story
已阻塞：    [N] 个 Story

### 就绪的 Story
- [Story 标题] ([路径])

### 需要完善
- [Story 标题]：[主要差距 — 一行]
- [Story 标题]：[主要差距 — 一行]

### 已阻塞的 Story
- [Story 标题]：被 [Story ID / 设计问题] 阻塞

---
[每个不满足条件的 Story 的完整详情，使用单个 Story 格式]
```

### Sprint 升级

如果范围是 `sprint` 且任何 Must Have Story 是 NEEDS WORK 或 BLOCKED，
在输出顶部添加醒目警告：

```
警告：[N] 个 Must Have Story 未准备好实现。
[列出其主要差距或阻塞项。]
在 Sprint 开始前解决这些问题，或使用 `/sprint-plan update` 重新规划。
```

---

## 6. 协作协议

此技能是只读的。它永不提出编辑或请求写入文件。

报告结果后，提供：

"您想要帮助填补这些 Story 的差距吗？我可以为您的批准起草缺失的部分。"

如果用户对特定 Story 说是，仅在对话中起草缺失的部分。
不使用 Write 或 Edit 工具 — 由用户（或 `/create-stories`）处理写入。

**重定向规则：**
- 如果 Story 文件根本不存在："此 Story 文件完全缺失。
  运行 `/create-epics [layer]` 然后 `/create-stories [epic-slug]` 以从 GDD 和 ADR 生成 Story。"
- 如果 Story 没有 GDD 引用且工作量看起来很小："此 Story
  没有 GDD 引用。如果变更很小（约 4 小时内），运行
  `/quick-design [description]` 创建快速设计规范，然后在 Story 中引用该规范。"
- 如果 Story 的范围超出了原始规模："此 Story 的范围似乎已扩大。
  在实现开始前考虑拆分它或升级到制作人。"

---

## 7. 下一个 Story 交接

完成单个 Story 就绪检查后（不是 `all` 或 `sprint` 范围）：

1. 从 `production/sprints/` 读取当前 Sprint 文件（最近的）。
2. 找到满足以下条件的 Story：
   - 状态：READY 或 NOT STARTED
   - 不是刚检查的 Story
   - 未被未完成的依赖项阻塞
   - 处于 Must Have 或 Should Have 层级

如果找到，呈现最多 3 个：

```
### 此 Sprint 中的其他就绪 Story

1. [Story 名称] — [1行描述] — 估算：[X 小时]
2. [Story 名称] — [1行描述] — 估算：[X 小时]

运行 `/story-readiness [路径]` 在开始前验证。
```

如果不存在 Sprint 文件或没有找到其他就绪 Story，静默跳过此部分。

---

## 阶段8：总监关卡 — Story 就绪审查

在生成 QL-STORY-READY 之前应用阶段0中解析的审查模式：

- `solo` → 跳过。注明："QL-STORY-READY 已跳过 — Solo 模式。"继续关闭。
- `lean` → 跳过。注明："QL-STORY-READY 已跳过 — Lean 模式。"继续关闭。
- `full` → 正常生成。

通过 Task 生成 `qa-lead`，使用关卡 **QL-STORY-READY**（`.claude/docs/director-gates.md`）。

传递以下上下文：
- Story 标题
- 验收标准列表（Story 验收标准部分的所有项目）
- 依赖状态（列出的所有依赖项及其当前状态：存在 / DRAFT / 缺失）
- 第4阶段的总体裁决（READY / NEEDS WORK / BLOCKED）

按照 `director-gates.md` 中的标准规则处理裁决：
- **ADEQUATE** → Story 已通过。继续关闭。
- **GAPS [列表]** → 通过 `AskUserQuestion` 将具体差距呈现给用户：
  选项：`更新 Story 以修复建议的差距` / `接受并继续` / `进一步讨论`。
- **INADEQUATE** → 呈现具体差距；询问用户是否更新 Story 或继续。

---

## 推荐的后续步骤

- 一旦 Story 是 READY，运行 `/dev-story [story-path]` 开始实现
- 运行 `/story-readiness sprint` 一次性检查当前 Sprint 中的所有 Story
- 如果 Story 文件完全缺失，运行 `/create-stories [epic-slug]`
