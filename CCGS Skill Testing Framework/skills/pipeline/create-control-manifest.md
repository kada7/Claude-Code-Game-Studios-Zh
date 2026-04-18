# Skill Test Spec: /create-control-manifest

## Skill Summary

`/create-control-manifest` 读取 `docs/architecture/` 中所有已接受的 ADR，并生成控制清单 —— 一份汇总所有架构约束、必需模式和禁止模式的摘要文档。该清单是故事作者在编写故事文件时使用的参考文档，确保故事继承正确的架构规则，而无需单独阅读所有 ADR。

该技能仅包含已接受的 ADR；提案中的 ADR 被排除并注明。它没有主管关卡。该技能在写入 `docs/architecture/control-manifest.md` 之前会询问 \"我可以写入吗\"。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 —— 无需测试装置。

- [ ] 包含必需的前置字段：`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] 包含 ≥2 个阶段标题
- [ ] 包含裁决关键词：CREATED, BLOCKED
- [ ] 包含"我可以写入"协作协议语言（用于 control-manifest.md）
- [ ] 末尾有下一步交接（`/create-epics` 或 `/create-stories`）
- [ ] 记录仅包含已接受的 ADR（不包括提案中的）

---

## Director Gate Checks

无主管关卡 —— 此技能不生成任何主管关卡 Agent。控制清单是从已接受 ADR 中机械提取的；无需创意或技术审查关卡。

---

## Test Cases

### Case 1: Happy Path — 4 个已接受的 ADR 创建正确的清单

**Fixture:**
- `docs/architecture/` 包含 4 个 ADR 文件，全部带有 `Status: Accepted`
- 每个 ADR 都有一个"必需模式"和/或"禁止模式"部分
- 不存在现有的 `docs/architecture/control-manifest.md`

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能读取 `docs/architecture/` 中所有 ADR 文件
2. 从每个 ADR 中提取必需模式、禁止模式和关键约束
3. 使用正确的章节结构起草清单
4. 向用户展示清单草案
5. Asks "May I write `docs/architecture/control-manifest.md`?"
6. 批准后写入清单

**Assertions:**
- [ ] 所有 4 个已接受的 ADR 都在清单中体现
- [ ] 清单包含独立的必需模式和禁止模式部分
- [ ] 清单包含每个约束的来源 ADR 编号
- [ ] 写入前询问"我可以写入"
- [ ] 技能不会未经批准就写入
- [ ] 写入后裁决为 CREATED

---

### Case 2: Failure Path — 未找到 ADR

**Fixture:**
- `docs/architecture/` 目录存在但不包含任何 ADR 文件

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能读取 `docs/architecture/` 但未找到 ADR 文件
2. 技能输出："No ADRs found. Run `/architecture-decision` to create ADRs before generating the control manifest."
3. 技能退出，不创建任何文件
4. 裁决为 BLOCKED

**Assertions:**
- [ ] 未找到 ADR 时，技能输出清晰的错误信息
- [ ] 未写入控制清单文件
- [ ] 技能建议 `/architecture-decision` 作为下一步操作
- [ ] 裁决为 BLOCKED（非错误崩溃）

---

### Case 3: Mixed ADR Statuses — 仅包含已接受的 ADR

**Fixture:**
- `docs/architecture/` 包含 3 个已接受的 ADR 和 2 个提案中的 ADR

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能读取所有 ADR 文件并按状态进行筛选：已接受
2. 清单仅从 3 个已接受的 ADR 起草
3. 输出备注："2 Proposed ADRs were excluded: [adr-NNN-name, adr-NNN-name]"
4. 用户在批准写入前看到哪些 ADR 被排除
5. Asks "May I write `docs/architecture/control-manifest.md`?"

**Assertions:**
- [ ] 只有 3 个已接受的 ADR 出现在清单内容中
- [ ] 被排除的提案 ADR 在输出中按名称列出
- [ ] 用户在批准写入前看到排除列表
- [ ] 技能不会默默忽略提案中的 ADR 而不加注明

---

### Case 4: Edge Case — Manifest already exists

**Fixture:**
- `docs/architecture/control-manifest.md` 已存在（版本 1，日期为上周）
- `docs/architecture/` 包含已接受的 ADR（部分自上次清单后新增）

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能检测现有清单并读取其版本号/日期
2. 技能提供重新生成选项："control-manifest.md already exists (v1, [date]). Regenerate with current ADRs?"
3. 如果用户确认：技能起草更新后的清单，增加版本号
4. Asks "May I write `docs/architecture/control-manifest.md`?" (overwrite)
5. 批准后写入更新后的清单

**Assertions:**
- [ ] 技能读取并报告现有清单版本，然后再提供重新生成选项
- [ ] 用户获得重新生成/跳过选择 —— 不会自动覆盖
- [ ] 更新后的清单具有增加的版本号
- [ ] 覆盖现有文件前询问"May I write"

---

### Case 5: Director Gate — No gate spawned; no review-mode.txt read

**Fixture:**
- 4 个已接受的 ADR 存在
- `production/session-state/review-mode.txt` 存在且内容为 `full`

**Input:** `/create-control-manifest`

**Expected behavior:**
1. 技能读取 ADR 并起草清单
2. 技能不会读取 `production/session-state/review-mode.txt`
3. 任何阶段都不会生成主管关卡 Agent
4. 起草后，技能直接进行到"May I write"询问
5. 审查模式设置对此技能行为无影响

**Assertions:**
- [ ] 没有生成任何主管关卡 Agent（无 CD-、TD-、PR-、AD- 前缀的关卡）
- [ ] 技能不会读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含"Gate: [GATE-ID]"或关卡跳过条目
- [ ] 清单仅从 ADR 生成，无外部关卡审查

---

## Protocol Compliance

- [ ] 起草清单前读取所有 ADR 文件
- [ ] 仅包含已接受的 ADR —— 提案中的 ADR 注明排除
- [ ] "May I write"询问前向用户展示清单草案
- [ ] 写入前询问"May I write `docs/architecture/control-manifest.md`?"
- [ ] 无主管关卡 —— 不读取 `review-mode.txt`
- [ ] 以下一步交接结束：`/create-epics` 或 `/create-stories`

---

## Coverage Notes

- 生成的清单的确切章节结构（约束表、模式列表）由技能主体定义，不会在测试断言中重新枚举。
- `version` 字段递增逻辑（v1 → v2）通过 Case 4 测试，但确切的版本编号格式未固定于测试装置。
- ADR 解析（提取必需/禁止模式）依赖于一致的 ADR 结构 —— 通过 Case 1 的测试装置进行隐式测试。