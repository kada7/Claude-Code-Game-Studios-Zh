# 技能测试规范：/create-epics

## 技能概述

`/create-epics` 读取所有已批准的 GDD 并将其转换为 EPIC.md 文件，每个系统一个。Epic 按层级（Foundation → Core → Feature → Presentation）组织，并在每个层级内按优先级顺序处理。每个 EPIC.md 包含范围、管辖的 ADR、GDD 需求、引擎风险级别以及 Definition of Done。该技能在创建每个 EPIC 文件前会询问"我可以写入吗"。

在 `full` 审查模式下，PR-EPIC 关卡（producer）会在草拟 epic 之后、写入任何文件之前运行。在 `lean` 或 `solo` 模式下，PR-EPIC 被跳过并记录。Epic 写入到 `production/epics/[layer]/EPIC-[name].md`。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：CREATED、BLOCKED
- [ ] 包含"我可以写入"协作协议语言（每个 epic 的批准）
- [ ] 末尾具有下一步交接（`/create-stories`）
- [ ] 记录 PR-EPIC 关卡行为：在 full 模式下运行；在 lean/solo 模式下跳过

---

## Director 关卡检查

在 `full` 模式下：PR-EPIC（producer）关卡在 epic 草拟之后、任何 epic 文件写入之前运行。如果 PR-EPIC 返回 CONCERNS，则在进行"我可以写入"询问之前修订 epic。

在 `lean` 模式下：PR-EPIC 被跳过。输出记录："PR-EPIC skipped — lean mode"。

在 `solo` 模式下：PR-EPIC 被跳过。输出记录："PR-EPIC skipped — solo mode"。

---

## 测试用例

### 用例 1：Happy Path — 两个已批准的 GDD 创建两个 EPIC 文件

**Fixture：**
- `design/gdd/systems-index.md` 存在，其中列出了 2 个系统
- 两个系统在 `design/gdd/` 中都有已批准的 GDD
- `docs/architecture/architecture.md` 存在且具有匹配的模块
- 每个系统至少存在一个已接受的 ADR
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-epics`

**预期行为：**
1. 技能读取系统索引和两个 GDD
2. 草拟 2 个 EPIC 定义（层级、GDD 路径、ADR、需求、引擎风险）
3. PR-EPIC 关卡被跳过（lean 模式）— 在输出中记录
4. 对于每个 epic：询问"我可以写入 `production/epics/[layer]/EPIC-[name].md` 吗？"
5. 批准后：写入两个 EPIC 文件
6. 创建或更新 `production/epics/index.md`

**断言：**
- [ ] 在任何写入询问前显示 epic 摘要
- [ ] 按每个 epic 询问"我可以写入"（而不是一次性为所有 epic 询问）
- [ ] 每个 EPIC.md 包含：层级、GDD 路径、管辖的 ADR、需求表格、Definition of Done
- [ ] 在输出中记录 PR-EPIC 跳过
- [ ] 写入后更新 `production/epics/index.md`
- [ ] 技能在没有每个 epic 批准的情况下不会写入 EPIC 文件

---

### 用例 2：失败路径 — 未找到已批准的 GDD

**Fixture：**
- `design/gdd/systems-index.md` 存在
- `design/gdd/` 中没有 GDD 具有已批准状态（全部为 Draft 或 In Progress）

**输入：** `/create-epics`

**预期行为：**
1. 技能读取系统索引并尝试查找已批准的 GDD
2. 未找到已批准的 GDD
3. 技能输出："No approved GDDs to convert. GDDs must be Approved before creating epics."
4. 技能建议先运行 `/design-system` 并完成 GDD 批准
5. 技能退出，不创建任何 EPIC 文件

**断言：**
- [ ] 当不存在已批准的 GDD 时，技能清晰地停止并给出明确信息
- [ ] 未写入任何 EPIC 文件
- [ ] 技能推荐正确的下一步操作
- [ ] 判定为 BLOCKED

---

### 用例 3：Director 关卡 — Full 模式在写入前生成 PR-EPIC

**Fixture：**
- 存在 2 个已批准的 GDD
- `production/session-state/review-mode.txt` 包含 `full`

**Full 模式预期行为：**
1. 技能草拟两个 epic
2. PR-EPIC 关卡生成并审查 epic 草稿
3. 如果 PR-EPIC 返回 APPROVED："我可以写入"询问正常进行
4. 批准后写入 epic 文件

**断言（full 模式）：**
- [ ] PR-EPIC 关卡在输出中显示为活动关卡
- [ ] PR-EPIC 在任何"我可以写入"询问之前运行
- [ ] 在 PR-EPIC 完成之前不写入 epic 文件

**Fixture（lean 模式）：**
- 相同的 GDD
- `production/session-state/review-mode.txt` 包含 `lean`

**Lean 模式预期行为：**
1. 草拟 epic
2. PR-EPIC 被跳过 — 在输出中记录
3. "我可以写入"询问直接进行

**断言（lean 模式）：**
- [ ] 输出中出现"PR-EPIC skipped — lean mode"
- [ ] 技能继续进行"我可以写入"询问，无需等待 PR-EPIC

---

### 用例 4：边界情况 — GDD 的 Epic 已存在

**Fixture：**
- `production/epics/[layer]/EPIC-[name].md` 已为其中一个已批准的 GDD 存在
- 另一个 GDD 没有现有的 EPIC 文件

**输入：** `/create-epics`

**预期行为：**
1. 技能检测到第一个系统的现有 EPIC 文件
2. 技能提供更新而不是覆盖的选项："EPIC-[name].md already exists. Update it, or skip?"
3. 对于第二个系统（无现有文件）：正常进行"我可以写入"询问

**断言：**
- [ ] 技能在写入前检测到现有的 EPIC 文件
- [ ] 向用户提供"更新"或"跳过"选项 — 不自动覆盖
- [ ] 新系统的 EPIC 正常创建，无冲突

---

### 用例 5：Director 关卡 — PR-EPIC 返回 CONCERNS

**Fixture：**
- 存在 2 个已批准的 GDD
- `production/session-state/review-mode.txt` 包含 `full`
- PR-EPIC 关卡返回 CONCERNS（例如，某个 epic 的范围太大）

**输入：** `/create-epics`

**预期行为：**
1. PR-EPIC 关卡生成并返回具有具体反馈的 CONCERNS
2. 在任何写入询问前，技能向用户呈现 concerns
3. 向用户提供选项：修订 epic、接受 concerns 并继续，或停止
4. 如果用户修订：在"我可以写入"询问前显示更新后的 epic 草稿
5. 在 CONCERNS 未解决时，技能不写入 epic

**断言：**
- [ ] 在写入前向用户显示来自 PR-EPIC 的 CONCERNS
- [ ] 当返回 CONCERNS 时，技能不自动写入 epic
- [ ] 向用户提供修订、继续或停止的明确选择
- [ ] 修订后的 epic 草稿在最终批准前重新显示

---

## 协议合规性

- [ ] 在任何"我可以写入"询问前向用户显示 epic 草稿
- [ ] 按每个 epic 询问"我可以写入"，而不是为整个批次询问一次
- [ ] PR-EPIC 关卡（如果活动）在写入询问之前运行 — 而不是之后
- [ ] 在输出中按名称和模式记录跳过的关卡
- [ ] EPIC.md 内容仅来源于 GDD、ADR 和架构文档 — 不自行编造
- [ ] 以下一步交接结束：`/create-stories [epic-slug]` 每个创建的 epic

---

## 覆盖范围说明

- Core、Feature 和 Presentation 层级的处理遵循与 Foundation 相同的每个 epic 模式 — 层级特定排序不独立测试。
- 从管辖的 ADR 分配的引擎风险级别（LOW/MEDIUM/HIGH）通过用例 1 的 fixture 结构隐式验证。
- `layer: [name]` 和 `[system-name]` 参数模式遵循默认（所有系统）模式相同的批准模式。