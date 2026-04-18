# 技能测试规范：/qa-plan

## 技能摘要

`/qa-plan` 为功能或 Sprint 里程碑生成结构化的 QA 测试计划。它读取指定 Sprint 的 Story 文件，从每个 Story 中提取验收标准，交叉引用 `coding-standards.md` 中的测试标准以分配适当的测试类型（单元、集成、视觉、UI 或配置/数据），并生成一份优先级的 QA 计划文档。

技能在持久化输出前询问"May I write to `production/qa/qa-plan-sprint-NNN.md`?"。如果找到同一 Sprint 的现有测试计划，技能会提议更新而非替换。计划写入时裁决为 COMPLETE。不使用总监关卡 —— 关卡级别的 Story 准备度由 `/story-readiness` 处理。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在写入计划前
- [ ] 具有下一步交接（例如，`/smoke-check` 或 `/story-readiness`）

---

## 总监关卡检查

无。`/qa-plan` 是规划工具。Story 准备度关卡是单独的。

---

## 测试用例

### 用例 1：理想路径 —— 包含 4 个 Story 的 Sprint 生成完整测试计划

**测试夹具：**
- `production/sprints/sprint-003.md` 列出了 4 个具有已定义验收标准的 Story
- Story 跨越类型：1 个 logic（公式）、1 个 integration、1 个 visual、1 个 UI
- `coding-standards.md` 存在，包含测试证据表

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能读取 sprint-003.md 并识别 4 个 Story
2. 技能读取每个 Story 的验收标准
3. 技能根据 coding-standards.md 表分配测试类型：
   - Logic Story → 单元测试（BLOCKING）
   - Integration Story → 集成测试（BLOCKING）
   - Visual Story → 截图 + 主管签核（ADVISORY）
   - UI Story → 手动走查文档（ADVISORY）
4. 技能起草按 Story 划分的测试类型分解的 QA 计划
5. 技能询问"May I write to `production/qa/qa-plan-sprint-003.md`?"
6. 文件在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 计划中包含所有 4 个 Story
- [ ] 测试类型根据 coding-standards.md 分配（非猜测）
- [ ] 每个 Story 都注明了关卡级别（BLOCKING vs ADVISORY）
- [ ] "May I write" 询问了正确的文件路径
- [ ] 裁决为 COMPLETE

---

### 用例 2：Story 无验收标准 —— 标记为 UNTESTABLE

**测试夹具：**
- `production/sprints/sprint-004.md` 列出了 3 个 Story；其中一个的验收标准部分为空

**输入：** `/qa-plan sprint-004`

**预期行为：**
1. 技能读取所有 3 个 Story
2. 技能检测到无 AC 的 Story
3. 该 Story 在计划中被标记为 `UNTESTABLE — Acceptance Criteria required`
4. 其他 2 个 Story 获得正常的测试类型分配
5. 计划使用被标记的 UNTESTABLE Story 写入；裁决为 COMPLETE

**断言：**
- [ ] UNTESTABLE 标签出现在无 AC 的 Story 上
- [ ] 计划未被阻塞 —— 其他 Story 仍在计划中
- [ ] 输出建议向被标记的 Story 添加 AC（下一步）
- [ ] 裁决为 COMPLETE（计划仍然生成）

---

### 用例 3：找到现有测试计划 —— 提供更新而非替换

**测试夹具：**
- `production/qa/qa-plan-sprint-003.md` 已从之前的运行存在
- Sprint-003 自上次计划以来添加了 2 个新 Story

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能读取 sprint-003.md 并检测到 2 个不在现有计划中的 Story
2. 技能报告："Existing QA plan found for sprint-003 — offering to update"
3. 技能展示 2 个新 Story 及其提议的测试分配
4. 技能询问"May I update `production/qa/qa-plan-sprint-003.md`?"（非 overwrite）
5. 更新的计划在批准后写入

**断言：**
- [ ] 技能检测到现有的计划文件
- [ ] 使用 "update" 语言（非 "overwrite"）
- [ ] 仅提议添加新 Story —— 保留现有条目
- [ ] 裁决为 COMPLETE

---

### 用例 4：未找到 Sprint 的 Story —— 带引导的错误

**测试夹具：**
- `production/sprints/sprint-007.md` 不存在
- 无其他匹配 sprint-007 的 Sprint 文件

**输入：** `/qa-plan sprint-007`

**预期行为：**
1. 技能尝试读取 sprint-007.md —— 文件未找到
2. 技能输出："No sprint file found for sprint-007"
3. 技能建议先运行 `/sprint-plan` 来创建 Sprint
4. 未写入计划；未询问 "May I write"

**断言：**
- [ ] 错误消息命名了缺失的 Sprint 文件
- [ ] `/sprint-plan` 被建议为补救步骤
- [ ] 未调用 Write 工具
- [ ] 裁决不为 COMPLETE（错误状态）

---

### 用例 5：总监关卡检查 —— 无关卡；QA 规划是工具

**测试夹具：**
- Sprint 具有有效的 Story 和 AC

**输入：** `/qa-plan sprint-003`

**预期行为：**
1. 技能生成并写入 QA 计划
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 技能在无任何关卡检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在分配测试类型前读取 coding-standards.md 测试证据表
- [ ] 按 Story 类型分配 BLOCKING 或 ADVISORY 关卡级别
- [ ] 将无 AC 的 Story 标记为 UNTESTABLE（非静默跳过）
- [ ] 检测到现有计划时提供更新路径
- [ ] 在创建或更新计划文件前询问 "May I write"
- [ ] 计划写入时裁决为 COMPLETE

---

## 覆盖说明

- `coding-standards.md` 缺失（技能无法分配测试类型）的情况未使用夹具测试；行为将遵循带有恢复 standards 文件提示的 BLOCKED 模式。
- 多 Sprint 规划（跨越 2 个 Sprint）未测试；该技能设计为一次处理一个 Sprint。
- Config/data Story 类型（平衡调整 → 冒烟检查）遵循与用例 1 中其他类型相同的分配模式，未单独测试。
