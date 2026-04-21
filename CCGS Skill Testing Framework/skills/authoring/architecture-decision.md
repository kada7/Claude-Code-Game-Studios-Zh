# Skill 测试规范：/architecture-decision

## Skill 摘要

`/architecture-decision` 引导用户逐节编写新的 Architecture Decision Record (ADR)。必需的部分包括：Status、Context、Decision、Consequences、Alternatives 和 Related ADRs。该技能还会从 `docs/engine-reference/` 中提取引擎版本参考并加盖到 ADR 中，以便追溯。

在 `full` 审查模式下，ADR 草案完成后会生成 TD-ADR (technical-director) 和 LP-FEASIBILITY (lead-programmer) 门控代理。如果两个门控都返回 APPROVED，ADR 状态将设置为 Accepted。在 `lean` 或 `solo` 模式下，两个门控都会被跳过，ADR 将以 Status: Proposed 写入。该技能在编写过程中会按节询问 "May I write"。ADR 被写入 `docs/architecture/adr-NNN-[name].md`。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键字：ACCEPTED、PROPOSED、CONCERNS
- [ ] 包含 "May I write" 协作协议语言（每节批准）
- [ ] 末尾具有下一步移交
- [ ] 记录了门控行为：TD-ADR + LP-FEASIBILITY 在 full 模式下；在 lean/solo 中跳过
- [ ] 记录了 ADR 状态在 full 模式且门控批准时为 Accepted，否则为 Proposed
- [ ] 提及来自 `docs/engine-reference/` 的引擎版本戳

---

## 导演门检查

在 `full` 模式下：ADR 草案完成后会生成 TD-ADR (technical-director) 和 LP-FEASIBILITY (lead-programmer)。如果两者都返回 APPROVED，ADR 状态将设置为 Accepted。如果任一返回 CONCERNS 或 FAIL，ADR 保持 Proposed。

在 `lean` 模式下：两个门控都被跳过。ADR 以 Status: Proposed 写入。输出注释："TD-ADR skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：两个门控都被跳过。ADR 以 Status: Proposed 写入。

---

## 测试用例

### 用例 1：正常路径 — 新的渲染方法 ADR，full 模式，门控批准

**测试夹具：**
- `docs/architecture/` 存在，没有现有的渲染 ADR
- `docs/engine-reference/[engine]/VERSION.md` 存在
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-decision rendering-approach`

**预期行为：**
1. 技能引导用户完成每个必需部分（Status、Context、Decision、Consequences、Alternatives、Related ADRs）
2. 引擎版本从 `docs/engine-reference/` 加盖到 ADR 中
3. 每节：展示草稿，询问 "May I write this section?"，获得批准
4. 所有部分完成后：TD-ADR 和 LP-FEASIBILITY 门控并行生成
5. 两个门控都返回 APPROVED
6. ADR 状态设置为 Accepted
7. 技能写入 `docs/architecture/adr-NNN-rendering-approach.md`
8. 如果定义了新的 TR-IDs，则更新 `docs/architecture/tr-registry.yaml`

**断言：**
- [ ] 所有 6 个必需部分都已编写并写入
- [ ] ADR 中加盖了引擎版本参考
- [ ] TD-ADR 和 LP-FEASIBILITY 并行生成（不是顺序生成）
- [ ] 在 full 模式下两个门控都返回 APPROVED 时，ADR 状态为 Accepted
- [ ] 编写过程中每节都询问 "May I write"
- [ ] 文件写入 `docs/architecture/adr-NNN-[name].md`

---

### 用例 2：失败路径 — TD-ADR 返回 CONCERNS

**测试夹具：**
- ADR 草稿已完成（所有部分已填充）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ADR 门控返回 CONCERNS："The decision does not address [specific concern]"

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. TD-ADR 门控生成并返回 CONCERNS，附带具体反馈
2. 技能向用户呈现疑虑
3. ADR 状态保持 Proposed（不是 Accepted）
4. 询问用户：修改决策以解决疑虑，或作为 Proposed 接受
5. 如果疑虑未解决，ADR 以 Status: Proposed 写入

**断言：**
- [ ] TD-ADR 疑虑逐字向用户展示
- [ ] 当 TD-ADR 返回 CONCERNS 时，ADR 状态为 Proposed（不是 Accepted）
- [ ] 在 CONCERNS 未解决时，技能不设置 Status: Accepted
- [ ] 用户可以选择修改并重新运行门控

---

### 用例 3：Lean 模式 — 两个门控都被跳过；ADR 以 Proposed 写入

**测试夹具：**
- `production/session-state/review-mode.txt` 包含 `lean`
- 为新技朧决策编写了 ADR 草稿

**输入：** `/architecture-decision [topic]`

**预期行为：**
1. 技能引导用户完成所有 6 个部分
2. 草稿完成后：TD-ADR 和 LP-FEASIBILITY 都被跳过
3. 输出注明："TD-ADR skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"
4. ADR 以 Status: Proposed 写入（不是 Accepted，因为门控未批准）
5. 在最终文件写入前仍询问 "May I write"

**断言：**
- [ ] 输出中出现两个门控跳过注释
- [ ] 在 lean 模式下，ADR 状态为 Proposed（不是 Accepted）
- [ ] 在写入文件前仍询问 "May I write"
- [ ] 用户批准后技能写入 ADR

---

### 用例 4：边缘情况 — 此主题已存在 ADR

**测试夹具：**
- `docs/architecture/` 包含涵盖相同主题的现有 ADR
- 现有 ADR 的状态为 Accepted

**输入：** `/architecture-decision [same-topic]`

**预期行为：**
1. 技能检测到涵盖相同主题的现有 ADR
2. 技能询问："An ADR for [topic] already exists ([filename]). Update it, or create a new superseding ADR?"
3. 用户选择更新或取代
4. 技能不会静默创建重复 ADR

**断言：**
- [ ] 技能在编写开始前检测到现有 ADR
- [ ] 向用户提供更新或取代选项 —— 无静默重复
- [ ] 如果更新：技能打开现有 ADR 进行逐节修订
- [ ] 如果取代：新 ADR 在 Related ADRs 部分引用被取代的 ADR

---

### 用例 5：导演门 — 基于模式和门控结果正确设置状态

**测试夹具：**
- ADR 草稿已完成
- 两个场景：(a) full 模式，两个门控都 APPROVED；(b) full 模式，一个门控 CONCERNS

**Full 模式，两个都 APPROVED：**
- ADR 状态设置为 Accepted

**断言（两个都批准）：**
- [ ] ADR frontmatter/标题显示 `Status: Accepted`
- [ ] TD-ADR 和 LP-FEASIBILITY 都在输出中显示为 APPROVED

**Full 模式，一个门控返回 CONCERNS：**
- ADR 状态保持 Proposed

**断言（CONCERNS）：**
- [ ] ADR frontmatter/标题显示 `Status: Proposed`
- [ ] 疑虑在输出中列出
- [ ] 当任何门控返回 CONCERNS 时，技能不设置 Status: Accepted

**Lean/solo 模式：**
- 无论内容质量如何，ADR 状态始终为 Proposed

**断言（lean/solo）：**
- [ ] 在 lean 模式下，ADR 状态为 Proposed
- [ ] 在 solo 模式下，ADR 状态为 Proposed
- [ ] 在 lean 或 solo 模式下不出现门控输出

---

## 协议合规性

- [ ] 门控评审前已编写所有 6 个必需部分
- [ ] 引擎版本从 `docs/engine-reference/` 加盖到 ADR 中
- [ ] 编写过程中每节都询问 "May I write"
- [ ] TD-ADR 和 LP-FEASIBILITY 在 full 模式下并行生成
- [ ] 跳过的门控在 lean/solo 输出中按名称和模式注明
- [ ] ADR 状态：仅在 full 模式且两个门控都 APPROVED 时为 Accepted
- [ ] 以下一步移交结束：`/architecture-review` 或 `/create-control-manifest`

---

## 覆盖说明

- ADR 编号（自动递增 NNN）未独立进行夹具测试 ——
  技能读取现有 ADR 文件名以分配下一个编号。
- Related ADRs 部分链接（supersedes / related-to）通过用例 4 进行结构性测试，
  但并非所有链接类型都单独验证。
- 当 ADR 中定义了新的 TR-IDs 时的 TR-registry 更新（属于写入阶段的一部分）—— 通过用例 1 隐式测试。
