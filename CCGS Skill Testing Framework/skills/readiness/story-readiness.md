# Skill Test Spec: /story-readiness

## 技能摘要

`/story-readiness` 验证一个 story 文件是否已准备好供开发人员拾取并实施。它检查四个维度：设计（嵌入的 GDD 需求）、架构（ADR 引用和状态）、范围（清晰的边界和 DoD）以及 Definition of Done（可测试的标准）。它产生 READY / NEEDS WORK / BLOCKED 的裁决。这是一个只读技能，在任何开发人员拾取 story 之前运行。

---

## 静态断言（结构性的）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题或编号的检查部分
- [ ] 包含裁决关键词：READY、NEEDS WORK、BLOCKED
- [ ] 不需要 "May I write" 语言（只读技能）
- [ ] 具有下一步交接（裁决后要做什么）

---

## 测试用例

### 用例 1：Happy Path — 完全准备好的 story

**Fixture:**
- Story 文件存在于 `production/epics/core/story-light-pickup.md`
- Story 包含：
  - `TR-ID: TR-light-001` (GDD 需求引用)
  - `ADR: docs/architecture/adr-003-inventory.md`
  - 引用的 ADR 存在且状态为 `Accepted`
  - 引用的 TR-ID 存在于 `docs/architecture/tr-registry.yaml`
  - Story 具有 `## Acceptance Criteria` 且包含 ≥3 个可测试项
  - Story 具有 `## Definition of Done` 部分
  - Story 具有 `Status: Ready for Dev`
  - Story 头部的 manifest 版本与当前的 `docs/architecture/control-manifest.md` 匹配

**输入:** `/story-readiness production/epics/core/story-light-pickup.md`

**预期行为:**
1. 技能读取 story 文件
2. 技能读取引用的 ADR — 验证状态为 `Accepted`
3. 技能读取 `docs/architecture/tr-registry.yaml` — 验证 TR-ID 存在
4. 技能读取 `docs/architecture/control-manifest.md` — 验证 manifest 版本匹配
5. 技能评估所有 4 个维度（设计、架构、范围、DoD）
6. 技能输出 READY 裁决，所有检查通过

**断言:**
- [ ] 技能读取引用的 ADR 文件（不仅仅是 story）
- [ ] 技能验证 ADR 状态为 `Accepted`（不是 `Proposed`）
- [ ] 技能读取 `tr-registry.yaml` 以验证 TR-ID 存在
- [ ] 输出包含所有 4 个维度的检查结果
- [ ] 当所有检查通过时，裁决为 READY
- [ ] 技能不写入任何文件

---

### 用例 2：Blocked Path — 引用的 ADR 是 Proposed（未 Accepted）

**Fixture:**
- Story 文件存在且包含 `ADR: docs/architecture/adr-005-light-system.md`
- `adr-005-light-system.md` 存在但状态为 `Status: Proposed`
- 所有其他 story 内容在其他方面是完整的

**输入:** `/story-readiness production/epics/core/story-light-system.md`

**预期行为:**
1. 技能读取 story
2. 技能读取 `adr-005-light-system.md` — 发现 `Status: Proposed`
3. 技能将此标记为 BLOCKING 问题（不能针对未接受的 ADR 实施）
4. 技能输出 BLOCKED 裁决
5. 技能建议：在拾取 story 之前接受或拒绝 ADR

**断言:**
- [ ] 当 ADR 为 Proposed 时，裁决为 BLOCKED（不是 NEEDS WORK 或 READY）
- [ ] 输出明确将 Proposed ADR 命名为阻塞项
- [ ] 输出建议在继续之前解决 ADR 状态
- [ ] 无论其他检查是否通过，技能都不输出 READY

---

### 用例 3：Needs Work — 缺少 Acceptance Criteria

**Fixture:**
- Story 文件存在但没有 `## Acceptance Criteria` 部分
- ADR 引用存在且为 `Accepted`
- TR-ID 存在于注册表中
- Manifest 版本匹配

**输入:** `/story-readiness production/epics/core/story-oxygen-drain.md`

**预期行为:**
1. 技能读取 story
2. 技能发现没有 Acceptance Criteria 部分
3. 技能将此标记为 NEEDS WORK 问题（story 不完整，但未被阻塞）
4. 技能输出 NEEDS WORK 裁决
5. 技能命名缺少的部分并建议添加可衡量的标准

**断言:**
- [ ] 当 Acceptance Criteria 部分缺失时，裁决为 NEEDS WORK（不是 BLOCKED 或 READY）
- [ ] 输出具体标识缺少的 Acceptance Criteria 部分
- [ ] 输出建议添加可测试/可衡量的标准
- [ ] 技能区分 NEEDS WORK（无需外部依赖即可修复）和 BLOCKED（需要外部操作）

---

### 用例 4：边缘情况 — 过时的 manifest 版本

**Fixture:**
- Story 文件头部具有 `Manifest Version: 2026-01-15`
- `docs/architecture/control-manifest.md` 具有 `Manifest Version: 2026-03-10`
- 版本不匹配（story 在 manifest 更新之前创建）

**输入:** `/story-readiness production/epics/core/story-mirror-rotation.md`

**预期行为:**
1. 技能读取 story 并提取 manifest 版本 `2026-01-15`
2. 技能读取 control manifest 头部并提取当前版本 `2026-03-10`
3. 技能检测到版本不匹配
4. 技能将此标记为 ADVISORY 问题（不阻塞，但值得注意）
5. 裁决为 NEEDS WORK，并注明 manifest 过时

**断言:**
- [ ] 技能读取 `docs/architecture/control-manifest.md` 以获取当前版本
- [ ] 技能将 story 嵌入的 manifest 版本与当前 manifest 版本进行比较
- [ ] 过时的 manifest 版本导致 NEEDS WORK（不是 BLOCKED，不是 READY）
- [ ] 输出解释 story 的嵌入指导可能已过时

---

### 用例 5：Director Gate — 跨审查模式的 QL-STORY-READY 行为

**Fixture:**
- Story 文件存在且为 READY（所有 4 个维度通过，ADR Accepted，标准存在）
- `production/session-state/review-mode.txt` 存在

**用例 5a — full 模式:**
- `review-mode.txt` 包含 `full`

**输入:** `/story-readiness production/epics/core/story-light-pickup.md` (full 模式)

**预期行为:**
1. 技能读取审查模式 — 确定 `full`
2. 完成自身的 4 维度检查后，技能调用 QL-STORY-READY gate
3. QA lead 审查 story 的准备情况
4. 如果 QA lead 裁决为 INADEQUATE → story 裁决为 BLOCKED，无论 4 维度结果如何
5. 如果 QA lead 裁决为 ADEQUATE → 裁决正常进行

**断言 (5a):**
- [ ] 技能在决定是否调用 QL-STORY-READY 之前读取审查模式
- [ ] 在 full 模式下，4 维度检查完成后调用 QL-STORY-READY gate
- [ ] QA lead 的 INADEQUATE 裁决覆盖 READY 的 4 维度结果 → 最终裁决为 BLOCKED
- [ ] 输出中注明 gate 调用："Gate: QL-STORY-READY — [result]"

**用例 5b — lean 或 solo 模式:**
- `review-mode.txt` 包含 `lean` 或 `solo`

**预期行为:**
1. 技能读取审查模式 — 确定 `lean` 或 `solo`
2. QL-STORY-READY gate 被跳过
3. 输出注明跳过："[QL-STORY-READY] skipped — Lean/Solo mode"
4. 裁决仅基于 4 维度检查

**断言 (5b):**
- [ ] 在 lean 或 solo 模式下，QL-STORY-READY gate 不会启动
- [ ] 跳过操作在输出中明确注明
- [ ] 裁决仅基于 4 维度检查

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在裁决前呈现完整的检查结果
- [ ] 不请求批准（无文件写入）
- [ ] 以建议的下一步结束（修复问题或继续实施）
- [ ] 清晰区分三个裁决级别（READY vs NEEDS WORK vs BLOCKED）

---

## 覆盖范围说明

- 完全缺失于注册表的 TR-ID 的情况未在此明确测试；它遵循与用例 3 相同的 NEEDS WORK 模式。
- "无参数"路径（技能自动检测当前 story）未测试，因为它依赖于 `production/session-state/active.md` 内容，这很难可靠地 fixture。
- 具有多个 ADR 引用的 story 未测试；行为假定为累加的（所有 ADR 必须为 Accepted 才能获得 READY 裁决）。