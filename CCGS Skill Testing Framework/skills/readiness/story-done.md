# Skill Test Spec: /story-done

## 技能摘要

`/story-done` 在设计与实现之间完成闭环。在实现一个 story 结束时运行，它读取 story 文件并根据实现验证每个 acceptance criterion。它检查 GDD 和 ADR 偏差，提示进行 code review，将 story 状态更新为 `Complete`，记录任何 tech debt，并从 sprint 中提取下一个就绪的 story。它生成 COMPLETE / COMPLETE WITH NOTES / BLOCKED 裁决，并写入 story 文件，可选地写入 `docs/tech-debt-register.md`。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] 具有 ≥5 个阶段标题（复杂技能，如果适用则保证 `context: fork`）
- [ ] 包含裁决关键词：COMPLETE, BLOCKED
- [ ] 包含 "May I write" 协作协议语言（写入 story 文件和 tech debt 注册表）
- [ ] 具有下一步交接（从 sprint 中提取下一个 story）

---

## 测试用例

### 用例 1：顺利路径 — 所有 acceptance criteria 满足，无偏差

**Fixture:**
- Story 文件位于 `production/epics/core/story-light-pickup.md`，包含：
  - 3 个 acceptance criteria，全部按描述实现
  - `TR-ID: TR-light-001` 引用 GDD 需求
  - `ADR: docs/architecture/adr-003-inventory.md`（已接受）
  - `Status: In Progress`
- Story 中列出的实现文件存在于 `src/` 中
- GDD 需求文本在 TR-light-001 处与功能实现方式匹配
- ADR 指南已遵循（无偏差）

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取 story 文件并提取所有关键字段
2. 技能从 `tr-registry.yaml` 重新读取 GDD 需求（而非来自 story 的引用文本）
3. 技能读取引用的 ADR 以了解实现约束
4. 技能评估每个 acceptance criterion（尽可能自动，否则手动提示）
5. 技能检查 GDD 需求偏差
6. 技能检查 ADR 指南偏差
7. 技能提示用户："Please provide the code review outcome for this story"
8. 技能呈现 COMPLETE 裁决
9. 技能询问 "May I update story Status to Complete and add Completion Notes?"
10. 如果同意：技能更新 story 文件
11. 技能从 sprint 中提取下一个 `Ready for Dev` story

**断言：**
- [ ] 技能从 `docs/architecture/tr-registry.yaml` 读取 TR-ID 需求文本（不仅来自 story）
- [ ] 技能读取引用的 ADR 文件（不仅来自 story 引用）
- [ ] 每个 acceptance criterion 都列出 VERIFIED / DEFERRED / FAILED 状态
- [ ] 技能提示用户获取 code review 结果（不跳过此步骤）
- [ ] 当所有 criteria 已验证且无偏差存在时，裁决为 COMPLETE
- [ ] 技能在更新 story 文件前询问 "May I write"
- [ ] 技能不会在没有用户确认的情况下自动更新 story 状态
- [ ] 完成后，技能从 `production/sprints/` 中提取下一个就绪的 story

---

### 用例 2：受阻路径 — Acceptance criterion 无法验证

**Fixture:**
- Story 文件有一个 acceptance criterion："Player sees correct animation on pickup"
- 此 criterion 不存在自动化测试
- 尚未执行手动验证
- 所有其他 criteria 均已满足

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能处理所有 acceptance criteria
2. 到达动画 criterion — 无法自动验证
3. 技能询问用户："Acceptance criterion 'Player sees correct animation on pickup' cannot be auto-verified. Has this been manually tested?"
4. 如果用户回答 No：criterion 标记为 DEFERRED，裁决变为 COMPLETE WITH NOTES
5. 技能在完成记录中记录 deferred criterion
6. 询问 "May I write updated story with deferred criterion noted?"

**断言：**
- [ ] 技能询问用户关于无法验证的 criteria，而非假设 PASS
- [ ] Deferred criteria 导致 COMPLETE WITH NOTES（非 COMPLETE 或 BLOCKED）
- [ ] deferred criterion 在完成记录中明确命名
- [ ] 技能在更新 story 文件前仍询问 "May I write"

---

### 用例 3：受阻路径 — 检测到 GDD 偏差

**Fixture:**
- Story TR-ID 指向需求："Player can carry max 3 light sources"
- `src/` 中的实现使用变量 `MAX_CARRIED_LIGHTS = 5`
- 这是与 GDD 的有意偏差

**输入：** `/story-done production/epics/core/story-light-pickup.md`

**预期行为：**
1. 技能读取 GDD 需求文本（最大 3）
2. 技能检测需求与实现值（5）之间的差异
3. 技能将此标记为 GDD 偏差，并要求用户分类：
   - INTENTIONAL：记录偏差及原因
   - ERROR：在 story 标记为 Complete 前必须修复实现
   - OUT OF SCOPE：需求已更改，GDD 需要更新
4. 如果 INTENTIONAL：技能在完成记录中记录偏差，裁决为 COMPLETE WITH NOTES
5. 如果 ERROR：裁决为 BLOCKED，直到实现被纠正

**断言：**
- [ ] 技能检测 GDD 需求与实现值之间的不匹配
- [ ] 技能要求用户分类偏差（不自动假设任一方）
- [ ] INTENTIONAL 偏差 → COMPLETE WITH NOTES（非 BLOCKED）
- [ ] ERROR 偏差 → BLOCKED 裁决，直到修复
- [ ] 检测到的偏差记录在完成记录或 tech debt 注册表中

---

### 用例 4：边界情况 — 无参数，自动检测当前 story

**Fixture:**
- `production/session-state/active.md` 包含对 `production/epics/core/story-oxygen-drain.md` 作为活动 story 的引用
- 该 story 文件存在且 `Status: In Progress`

**输入：** `/story-done`（无参数）

**预期行为：**
1. 技能读取 `production/session-state/active.md`
2. 技能找到活动 story 引用
3. 技能读取该 story 文件并正常进行
4. 输出确认自动检测到的 story

**断言：**
- [ ] 当未提供参数时，技能读取 `production/session-state/active.md`
- [ ] 技能在继续之前识别并确认自动检测到的 story
- [ ] 如果在会话状态中未找到 story，技能要求用户提供路径

---

### 用例 5：总监门禁 — LP-CODE-REVIEW 在不同 review 模式下的行为

**Fixture:**
- Story 文件位于 `production/epics/core/story-light-pickup.md`
- 所有 acceptance criteria 已验证，无 GDD 偏差
- `production/session-state/review-mode.txt` 存在

**用例 5a — full 模式：**
- `review-mode.txt` 包含 `full`

**输入：** `/story-done production/epics/core/story-light-pickup.md`（full 模式）

**预期行为：**
1. 技能读取 review 模式 — 确定 `full`
2. 实现验证后，技能调用 LP-CODE-REVIEW 门禁
3. Lead programmer 审查实现
4. 如果 LP 裁决为 NEEDS CHANGES → story 无法标记为 Complete
5. 如果 LP 裁决为 APPROVED → 技能继续标记 story 为 Complete

**断言（5a）：**
- [ ] 技能在决定是否调用 LP-CODE-REVIEW 前读取 review 模式
- [ ] LP-CODE-REVIEW 门禁在 full 模式下实现检查后被调用
- [ ] LP NEEDS CHANGES 裁决阻止 story 被标记为 Complete
- [ ] 门禁结果在输出中注明："Gate: LP-CODE-REVIEW — [result]"
- [ ] 即使 LP 批准，技能在更新 story 状态前仍询问 "May I write"

**用例 5b — lean 或 solo 模式：**
- `review-mode.txt` 包含 `lean` 或 `solo`

**预期行为：**
1. 技能读取 review 模式 — 确定 `lean` 或 `solo`
2. LP-CODE-REVIEW 门禁被跳过
3. 输出注明跳过："[LP-CODE-REVIEW] skipped — Lean/Solo mode"
4. story 完成仅基于 acceptance criteria 检查进行

**断言（5b）：**
- [ ] LP-CODE-REVIEW 门禁在 lean 或 solo 模式下不生成
- [ ] 跳过在输出中明确注明
- [ ] 技能在标记 story 为 Complete 前仍需要 "May I write" 批准

---

## 协议合规性

- [ ] 在更新 story 文件前使用 "May I write"
- [ ] 在向 `docs/tech-debt-register.md` 添加条目前使用 "May I write"
- [ ] 在请求批准前呈现完整发现（criteria 检查、偏差检查）
- [ ] 最后从 sprint 计划中提取下一个就绪的 story
- [ ] 如果任何 criteria 处于 ERROR 状态，则不标记 story 为 Complete
- [ ] 不跳过 code review 提示

---

## 覆盖说明

- 技能的完整 8 阶段流程在用例 1-3 中练习；并非每个阶段内的所有边界情况都被覆盖。
- Tech debt 记录（deferred 项目写入 `docs/tech-debt-register.md`）在用例 2 中提到，但不是主要断言重点；专用覆盖被推迟。
- `sprint-status.yaml` 更新（技能中的阶段 7）在用例 1 中隐含，但不是主要断言；假设遵循相同的 "May I write" 模式。
- 具有多个 TR-ID 或多个 ADR 的 story 未明确测试。