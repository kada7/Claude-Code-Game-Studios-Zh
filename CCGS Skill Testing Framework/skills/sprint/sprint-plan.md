# 技能测试规范：/sprint-plan

## 技能摘要

`/sprint-plan` 读取当前里程碑文件和待办 Story，然后按实现层和优先级分数排序生成一个新的编号 Sprint。在 full 模式下，PR-SPRINT 导演关卡在 Sprint 草稿编译后运行（制作人审查计划）。在 lean 和 solo 模式下，关卡被跳过。该技能在持久化前询问"我可以写入 `production/sprints/sprint-NNN.md` 吗？"。裁决结果：COMPLETE（Sprint 已生成并写入）或 BLOCKED（由于缺少数据或关卡失败而无法继续）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 语言（技能写入 Sprint 文件）
- [ ] 具有下一步交接（Sprint 写入后该做什么）

---

## 导演关卡检查

| 关卡 ID   | 触发条件        | 模式限制         |
|-----------|--------------------------|--------------------|
| PR-SPRINT | Sprint 草稿构建后 | 仅 full 模式（非 lean/solo） |

---

## 测试用例

### 用例 1：理想路径 —— 有待办 Story 的待办列表生成 Sprint

**测试夹具：**
- `production/milestones/milestone-02.md` 存在，容量为 `10 story points`
- 待办列表包含跨 2 个 Epic 的 5 个未开始 Story，优先级各异
- `production/session-state/review-mode.txt` 包含 `full`
- 下一个 Sprint 编号为 `003`（Sprint 001 和 002 已存在）

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取当前里程碑以获取容量和目标
2. 技能读取待办列表中所有未开始的 Story；按层 + 优先级排序
3. 技能起草 sprint-003，包含在容量范围内的 Story
4. 技能在调用关卡前向用户展示草稿
5. 技能调用 PR-SPRINT 关卡（full 模式）；制作人批准
6. 技能询问"我可以写入 `production/sprints/sprint-003.md` 吗？"
7. 用户批准；文件写入

**断言：**
- [ ] Story 在按优先级排序前先按实现层排序
- [ ] Sprint 草稿在任何写入或关卡调用前展示
- [ ] PR-SPRINT 关卡在 full 模式下于草稿准备就绪后被调用
- [ ] 技能在写入 Sprint 文件前询问 "May I write"
- [ ] 写入的文件路径匹配 `production/sprints/sprint-003.md`
- [ ] 成功写入后裁决为 COMPLETE

---

### 用例 2：阻塞路径 —— 待办列表为空

**测试夹具：**
- `production/milestones/milestone-02.md` 存在
- 任何 Epic 待办列表中都不存在未开始的 Story

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取待办列表 —— 未找到未开始的 Story
2. 技能输出"待办列表中没有未开始的 Story"
3. 技能建议运行 `/create-stories` 来填充待办列表
4. 不调用关卡；不写入文件

**断言：**
- [ ] 裁决为 BLOCKED
- [ ] 输出包含"没有未开始的 Story"或等效信息
- [ ] 输出推荐 `/create-stories`
- [ ] 不调用 PR-SPRINT 关卡
- [ ] 不调用写入工具

---

### 用例 3：关卡返回 CONCERNS —— Sprint 超载，写入前修订

**测试夹具：**
- 待办列表有 8 个 Story，总计 16 点；里程碑容量为 10 点
- `review-mode.txt` 包含 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能起草包含所有 8 个 Story 的 Sprint（超出容量）
2. PR-SPRINT 关卡运行；制作人返回 CONCERNS：Sprint 超载
3. 技能将顾虑展示给用户并询问要延期哪些 Story
4. 用户选择延期 3 个 Story；Sprint 修订为 5 个 Story / 10 点
5. 技能用修订后的 Sprint 询问 "May I write"；在批准后写入

**断言：**
- [ ] PR-SPRINT 关卡的 CONCERNS 在任何写入前展示给用户
- [ ] 技能允许在关卡反馈后修订 Sprint
- [ ] 修订后的 Sprint（而非原始版本）被写入文件
- [ ] 修订和写入后裁决为 COMPLETE

---

### 用例 4：Lean 模式 —— PR-SPRINT 关卡被跳过

**测试夹具：**
- 待办列表有 4 个 Story；里程碑容量为 8 点
- `review-mode.txt` 包含 `lean`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取审查模式 —— 确定为 `lean`
2. 技能起草 Sprint 并向用户展示
3. PR-SPRINT 关卡被跳过；输出记录"[PR-SPRINT] skipped —— Lean mode"
4. 技能询问用户直接批准 Sprint
5. 用户批准；Sprint 文件写入

**断言：**
- [ ] 在 lean 模式下不调用 PR-SPRINT 关卡
- [ ] 跳过在输出中被明确记录
- [ ] 在写入前仍需要用户批准（关卡跳过 ≠ 批准跳过）
- [ ] 写入后裁决为 COMPLETE

---

### 用例 5：边界情况 —— 先前的 Sprint 仍有未完成的 Story

**测试夹具：**
- `production/sprints/sprint-002.md` 存在，其中 2 个 Story 仍为 `Status: In Progress`
- 待办列表有 5 个新的未开始 Story
- `review-mode.txt` 包含 `full`

**输入：** `/sprint-plan`

**预期行为：**
1. 技能读取 sprint-002 并检测到 2 个未完成的（进行中）Story
2. 技能标记："Sprint 002 有 2 个未完成的 Story —— 在规划 Sprint 003 前确认结转"
3. 技能向用户展示选择：结转 Story、延期它们或取消
4. 用户确认结转；结转的 Story 以 `[CARRY]` 标签前置到新 Sprint
5. 构建 Sprint 草稿；PR-SPRINT 关卡运行；在批准后写入 Sprint

**断言：**
- [ ] 技能检查最新的 Sprint 文件以查找未完成的 Story
- [ ] 要求用户在 Sprint 规划继续前确认结转
- [ ] 结转的 Story 以区分标签出现在新 Sprint 草稿中
- [ ] 技能不会静默忽略先前 Sprint 中未完成的 Story

---

## 协议合规性

- [ ] 在调用 PR-SPRINT 关卡或询问写入前展示 Sprint 草稿
- [ ] 在写入 Sprint 文件前始终询问 "May I write"
- [ ] PR-SPRINT 关卡仅在 full 模式下运行
- [ ] 跳过消息出现在 lean 和 solo 模式输出中
- [ ] 裁决在技能输出末尾明确说明

---

## 覆盖说明

- 未明确测试不存在里程碑文件的情况；行为遵循 BLOCKED 模式，并建议运行 `/gate-check` 进行里程碑推进。
- Solo 模式行为等效于 lean（关卡跳过，需要用户批准），未单独测试。
- 并行 Story 选择算法不在此处测试；它们是 Sprint-plan 子代理的单元关注点。
