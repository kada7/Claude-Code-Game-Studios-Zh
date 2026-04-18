# 技能测试规范：/create-stories

## 技能概述

`/create-stories` 将单个 epic 分解为可供开发者使用的 story 文件。它读取 EPIC.md、对应的 GDD、管辖的 ADR、control manifest 和 TR registry。每个 story 获得结构化的 frontmatter，包括：Title、Epic、Layer、Priority、Status、TR-ID、ADR references、Acceptance Criteria 和 Definition of Done。Story 按类型（Logic / Integration / Visual/Feel / UI / Config/Data）分类，这决定了所需的测试证据路径。

在 `full` 审查模式下，QL-STORY-READY 检查在每个 story 创建后运行。在 `lean` 或 `solo` 模式下，QL-STORY-READY 被跳过。该技能在写入每个 story 文件前会询问"我可以写入吗"。Story 写入到 `production/epics/[layer]/story-[name].md`。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：COMPLETE、BLOCKED、NEEDS WORK
- [ ] 包含"我可以写入"协作协议语言（每个 story 的批准）
- [ ] 末尾具有下一步交接（`/story-readiness`、`/dev-story`）
- [ ] 记录 story Status：当管辖的 ADR 为 Proposed 时标记为 Blocked
- [ ] 记录 QL-STORY-READY 关卡：在 full 模式下激活，在 lean/solo 模式下跳过

---

## Director 关卡检查

在 `full` 模式下：QL-STORY-READY 检查在每个 story 创建后运行。未通过检查的 story 在"我可以写入"询问前标记为 NEEDS WORK。

在 `lean` 模式下：QL-STORY-READY 被跳过。输出记录："QL-STORY-READY skipped — lean mode" 每个 story。

在 `solo` 模式下：QL-STORY-READY 被跳过并具有等效记录。

---

## 测试用例

### 用例 1：Happy Path — 包含 3 个 story 的 Epic，所有 ADR 已接受

**Fixture：**
- `production/epics/[layer]/EPIC-[name].md` 存在，包含 3 个 GDD 需求
- 对应的 GDD 存在且具有匹配的验收标准
- 所有管辖的 ADR 具有 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `docs/architecture/tr-registry.yaml` 为所有 3 个需求具有 TR-ID
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 技能读取 EPIC.md、GDD、管辖的 ADR、control manifest 和 TR registry
2. 将每个需求分类为一个 story 类型（Logic / Integration / Visual/Feel / UI / Config/Data）
3. 使用正确的 frontmatter 模式草拟 3 个 story 文件
4. QL-STORY-READY 被跳过（lean 模式）— 在输出中记录
5. 在写入每个 story 文件前询问"我可以写入吗"
6. 批准后写入所有 3 个 story 文件

**断言：**
- [ ] 每个 story 的 frontmatter 包含：Title、Epic、Layer、Priority、Status、TR-ID、ADR reference、Acceptance Criteria、DoD
- [ ] Story 类型被正确分类（fixture 中至少有一个 Logic 类型）
- [ ] 按每个 story 询问"我可以写入"（而不是一次性为整个批次询问）
- [ ] 在输出中记录 QL-STORY-READY 跳过
- [ ] 所有 3 个 story 文件以正确的命名写入：`story-[name].md`
- [ ] 技能不开始实施

---

### 用例 2：失败路径 — 未找到 epic 文件

**Fixture：**
- 提供的 epic 路径在 `production/epics/` 中不存在

**输入：** `/create-stories nonexistent-epic`

**预期行为：**
1. 技能尝试读取 EPIC.md 文件
2. 文件未找到
3. 技能输出清晰的错误信息，显示其搜索的路径
4. 技能建议检查 `production/epics/` 或先运行 `/create-epics`
5. 不创建任何 story 文件

**断言：**
- [ ] 技能输出清晰的错误信息，命名缺失的文件路径
- [ ] 未写入任何 story 文件
- [ ] 技能推荐正确的下一步操作（`/create-epics`）
- [ ] 在没有有效的 EPIC.md 的情况下，技能不创建 story

---

### 用例 3：被阻塞的 Story — ADR 为 Proposed

**Fixture：**
- EPIC.md 存在，包含 2 个需求
- 需求 1 由已接受的 ADR 覆盖
- 需求 2 由具有 `Status: Proposed` 的 ADR 覆盖

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 技能读取需求 2 的 ADR 并发现 Status: Proposed
2. 需求 2 的 story 以 `Status: Blocked` 草拟
3. 阻塞说明引用具体的 ADR："BLOCKED: ADR-NNN is Proposed"
4. 需求 1 的 story 正常草拟，`Status: Ready`
5. 两个 story 都在草稿中显示 — 询问用户"我可以写入吗"用于两者

**断言：**
- [ ] Story 2 在其 frontmatter 中具有 `Status: Blocked`
- [ ] 阻塞说明命名具体的 ADR 编号并推荐 `/architecture-decision`
- [ ] Story 1 具有 `Status: Ready` — 阻塞状态不影响未被阻塞的 story
- [ ] 在写入前，阻塞状态在草稿预览中显示
- [ ] 两个 story 文件都被写入（被阻塞的 story 仍然被写入 — 只是被标记）

---

### 用例 4：边界情况 — 未提供参数

**Fixture：**
- `production/epics/` 目录存在，具有 ≥2 个 epic 子目录

**输入：** `/create-stories`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用错误："No epic specified. Usage: /create-stories [epic-name]"
3. 技能列出 `production/epics/` 中可用的 epic
4. 不创建任何 story 文件

**断言：**
- [ ] 当未提供参数时，技能输出使用错误
- [ ] 技能列出可用的 epic 以帮助用户选择
- [ ] 未写入任何 story 文件
- [ ] 在没有用户输入的情况下，技能不静默选择 epic

---

### 用例 5：Director 关卡 — Full 模式运行 QL-STORY-READY；未通过的 story 标记为 NEEDS WORK

**Fixture：**
- EPIC.md 存在，包含 2 个需求
- 两个管辖的 ADR 都是已接受的
- `production/session-state/review-mode.txt` 包含 `full`
- QL-STORY-READY 检查发现一个 story 具有模糊的验收标准

**输入：** `/create-stories [epic-name]`

**预期行为：**
1. 两个 story 都被草拟
2. QL-STORY-READY 检查为每个 story 运行
3. Story 1 通过 QL-STORY-READY
4. Story 2 未通过 QL-STORY-READY — 标记为 NEEDS WORK 并具有具体反馈
5. 在"我可以写入吗"询问前，向用户显示两个 story 的通过/失败状态
6. 用户可以继续（story 按原样写入，带有 NEEDS WORK 说明）或先修订

**断言：**
- [ ] QL-STORY-READY 结果在输出中按每个 story 出现
- [ ] Story 2 被标记为 NEEDS WORK，并显示具体的未通过标准
- [ ] Story 1 显示为通过 QL-STORY-READY
- [ ] 在写入前，向用户提供继续或修订的选择
- [ ] 在没有用户输入的情况下，技能不自动阻止写入未通过 QL-STORY-READY 的 story

---

## 协议合规性

- [ ] 在草拟 story 前加载所有上下文（EPIC、GDD、ADR、manifest、TR registry）
- [ ] 在任何"我可以写入吗"询问前完整显示 story 草稿
- [ ] 按每个 story 询问"我可以写入吗"（而不是为整个批次询问一次）
- [ ] 在写入批准前标记被阻塞的 story — 而不是在写入后发现
- [ ] TR-ID 引用 registry — 需求文本不内联嵌入在 story 文件中
- [ ] 每个 story 的控制 manifest 规则从 manifest 中引用，而不是自行编造
- [ ] 以下一步交接结束：`/story-readiness` → `/dev-story`

---

## 覆盖范围说明

- Integration story 测试证据（playtest doc 替代方案）遵循与 Logic story 相同的批准模式 — 不独立进行 fixture 测试。
- Story 排序（foundational 优先，UI 最后）通过用例 1 的多 story fixture 隐式验证。
- Story 大小规则（拆分大型需求组）在此处未测试 — 它在 `/create-stories` 技能的内部逻辑中处理。