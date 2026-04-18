# 技能测试规范：/sprint-status

## 技能摘要

`/sprint-status` 是一个 Haiku 层级的只读技能，读取当前活动的 Sprint 文件和会话状态以生成简洁的 Sprint 健康摘要。它按状态报告 Story 数量（Complete / In Progress / Blocked / Not Started）并发出三种 Sprint 健康裁决之一：ON TRACK、AT RISK 或 BLOCKED。它从不写入文件，也不调用任何导演关卡。它专为会话期间的快速、低成本状态检查而设计。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题或编号检查部分
- [ ] 包含裁决关键词：ON TRACK、AT RISK、BLOCKED
- [ ] 不包含 "May I write" 语言（只读技能）
- [ ] 具有下一步交接（根据裁决结果该做什么）

---

## 导演关卡检查

无。`/sprint-status` 是只读报告技能；不调用任何关卡。

---

## 测试用例

### 用例 1：理想路径 —— 混合 Sprint，AT RISK 并标明阻塞项

**测试夹具：**
- `production/sprints/sprint-004.md` 存在（活动 Sprint，在 `active.md` 中链接）
- Sprint 包含 6 个 Story：
  - 3 个状态为 `Complete`
  - 2 个状态为 `In Progress`
  - 1 个状态为 `Blocked`（阻塞项："等待物理 ADR 接受"）
- Sprint 截止日期还有 2 天

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 `production/session-state/active.md` 以查找活动 Sprint 引用
2. 技能读取 `production/sprints/sprint-004.md`
3. 技能按状态统计 Story 数量：3 个 Complete，2 个 In Progress，1 个 Blocked
4. 技能检测到 Blocked 的 Story 和临近的截止日期
5. 技能输出 AT RISK 裁决并明确命名阻塞项

**断言：**
- [ ] 输出包含按状态划分的 Story 数量细分
- [ ] 输出命名具体的阻塞 Story 及其阻塞原因
- [ ] 当存在任何 Blocked 的 Story 时，裁决为 AT RISK（不是 BLOCKED，不是 ON TRACK）
- [ ] 技能不写入任何文件

---

### 用例 2：所有 Story 已完成 —— Sprint COMPLETE 裁决

**测试夹具：**
- `production/sprints/sprint-004.md` 存在
- 所有 5 个 Story 的状态为 `Complete`

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 Sprint 文件 —— 所有 Story 都是 Complete
2. 技能输出 ON TRACK 裁决或 SPRINT COMPLETE 标签
3. 技能建议运行 `/milestone-review` 或 `/sprint-plan` 作为后续步骤

**断言：**
- [ ] 当所有 Story 都是 Complete 时，裁决为 ON TRACK 或 SPRINT COMPLETE
- [ ] 输出记录 Sprint 已完全完成
- [ ] 后续步骤建议引用 `/milestone-review` 或 `/sprint-plan`
- [ ] 不写入任何文件

---

### 用例 3：未找到活动 Sprint 文件 —— 引导运行 /sprint-plan

**测试夹具：**
- `production/session-state/active.md` 未引用活动 Sprint
- `production/sprints/` 目录为空或不存在

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 `active.md` —— 未找到活动 Sprint 引用
2. 技能检查 `production/sprints/` —— 未找到文件
3. 技能输出信息性消息：未检测到活动 Sprint
4. 技能建议运行 `/sprint-plan` 创建一个

**断言：**
- [ ] 当不存在 Sprint 文件时，技能不会报错或崩溃
- [ ] 输出明确说明未找到活动 Sprint
- [ ] 输出推荐 `/sprint-plan` 作为后续操作
- [ ] 不发出裁决关键词（没有可评估的 Sprint）

---

### 用例 4：边界情况 —— 陈旧的 In Progress Story（被标记）

**测试夹具：**
- `production/sprints/sprint-004.md` 存在
- 一个 Story 状态为 `In Progress`，并在 `active.md` 中有注释：`Last updated: 2026-03-30`（比今天的会话日期早 2 天以上）
- 没有 Blocked 的 Story

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 Sprint 文件和会话状态
2. 技能检测到该 Story 已处于 In Progress 状态超过 2 天未更新
3. 技能在输出中将该 Story 标记为"陈旧"
4. 裁决为 AT RISK（陈旧的进行中 Story 表明存在隐藏的阻塞项）

**断言：**
- [ ] 技能将 Story "上次更新"元数据与会话日期进行比较
- [ ] 陈旧的 In Progress Story 在输出中按名称被标记
- [ ] 当检测到陈旧 Story 时，裁决为 AT RISK，不是 ON TRACK
- [ ] 输出不会将"陈旧"与"Blocked"混为一谈 —— 标签是区分开的

---

### 用例 5：关卡合规性 —— 只读；不调用关卡

**测试夹具：**
- `production/sprints/sprint-004.md` 存在，包含 4 个 Story（2 个 Complete，2 个 In Progress）
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/sprint-status`

**预期行为：**
1. 技能读取 Sprint 并生成状态摘要
2. 无论审查模式如何，技能都不调用任何导演关卡
3. 输出是包含 ON TRACK、AT RISK 或 BLOCKED 裁决的纯状态报告
4. 技能不提示用户批准或要求写入任何文件

**断言：**
- [ ] 在任何审查模式下都不调用导演关卡
- [ ] 输出不包含任何 "May I write" 提示
- [ ] 技能在没有用户交互的情况下完成并返回裁决
- [ ] 审查模式文件被忽略（或确认与此技能无关）

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在发出裁决前展示 Story 数量细分
- [ ] 不询问批准
- [ ] 以基于裁决的推荐后续步骤结束
- [ ] 在 Haiku 模型层级上运行（快速、低成本）

---

## 覆盖说明

- 未测试同时有多个活动 Sprint 的情况；技能读取 `active.md` 引用的任何 Sprint。
- 部分 Sprint 完成百分比未明确验证；按状态的计数输出隐含了它们。
- `solo` 模式审查模式变体未单独测试；用例 5 中的关卡行为同等地适用于所有模式。
