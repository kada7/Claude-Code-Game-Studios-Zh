# 技能测试规范：/milestone-review

## 技能摘要

`/milestone-review` 生成已完成里程碑的全面审查：已交付内容、速度指标、延期项目、暴露的风险和回顾种子。在完整模式下，PR-MILESTONE 导演关卡在审查编译后运行（制作人审查范围交付）。在精简和单人模式下，关卡被跳过。该技能在持久化前询问"我可以写入 `production/milestones/review-milestone-N.md` 吗？"。裁决结果：MILESTONE COMPLETE 或 MILESTONE INCOMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：MILESTONE COMPLETE、MILESTONE INCOMPLETE
- [ ] 包含 "May I write" 语言（技能写入审查文档）
- [ ] 具有下一步交接（审查文档写入后该做什么）

---

## 导演关卡检查

| 关卡 ID       | 触发条件              | 模式限制              |
|---------------|-------------------------|-------------------------|
| PR-MILESTONE  | 审查文档编译后 | 仅 full 模式（非 lean/solo） |

---

## 测试用例

### 用例 1：理想路径 —— 几乎完成的里程碑，有一个延期 Story

**测试夹具：**
- `production/milestones/milestone-03.md` 存在，包含 8 个 Story
- 7 个 Story 的状态为 `Complete`
- 1 个 Story 的状态为 `Deferred`（延期到 milestone-04）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取 `milestone-03.md` 和所有引用的 Sprint 文件
2. 技能编译：7 个已交付，1 个延期；速度；无阻塞项
3. 技能向用户展示审查草稿
4. 调用 PR-MILESTONE 关卡；制作人批准
5. 技能询问"我可以写入 `production/milestones/review-milestone-03.md` 吗？"
6. 用户批准；文件写入；裁决为 MILESTONE COMPLETE

**断言：**
- [ ] 延期的 Story 在审查中被记录并标明其目标里程碑
- [ ] 尽管有一个延期 Story，裁决仍为 MILESTONE COMPLETE
- [ ] 在 full 模式下，PR-MILESTONE 关卡在草稿编译后被调用
- [ ] 技能在写入审查文件前询问 "May I write"
- [ ] 审查文档路径匹配 `production/milestones/review-milestone-03.md`

---

### 用例 2：阻塞的里程碑 —— 多个阻塞的 Story

**测试夹具：**
- `production/milestones/milestone-03.md` 存在，包含 5 个 Story
- 2 个 Story 的状态为 `Complete`
- 3 个 Story 的状态为 `Blocked`（每个 Story 中都列出了具体的阻塞项）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取里程碑和 Sprint 文件
2. 技能发现 3 个阻塞的 Story；编译阻塞项详情
3. 裁决为 MILESTONE INCOMPLETE
4. PR-MILESTONE 关卡运行；制作人记录了未解决的阻塞项
5. 在批准后写入包含阻塞项列表的审查

**断言：**
- [ ] 当存在任何阻塞的 Story 时，裁决为 MILESTONE INCOMPLETE
- [ ] 每个阻塞的 Story 的名称和阻塞原因都列在审查中
- [ ] 即使在裁决为 INCOMPLETE 的情况下，PR-MILESTONE 关卡仍在 full 模式下被调用
- [ ] "May I write" 提示仍在文件写入前出现

---

### 用例 3：Full 模式 —— PR-MILESTONE 返回 CONCERNS

**测试夹具：**
- Milestone-03 有 6 个已完成的 Story，但其中有 2 个不在原始范围内（在 Sprint 中期添加）
- `review-mode.txt` 包含 `full`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能编译审查；记录 2 个超出范围的 Story 已交付
2. 调用 PR-MILESTONE 关卡；制作人返回关于范围蔓延的 CONCERNS
3. 技能将 CONCERNS 展示给用户，并在审查中添加"范围蔓延"记录
4. 用户批准修订后的审查；文件写入为 MILESTONE COMPLETE 并附带警告

**断言：**
- [ ] PR-MILESTONE 关卡的 CONCERNS 在写入前展示给用户
- [ ] 范围蔓延在写入的审查文档中被明确记录
- [ ] 裁决为 MILESTONE COMPLETE（Story 已交付）并附带 CONCERNS 注释
- [ ] 技能不会压制关卡反馈

---

### 用例 4：边界情况 —— 未找到指定里程碑的里程碑文件

**测试夹具：**
- 用户调用 `/milestone-review milestone-07`
- `production/milestones/milestone-07.md` 不存在

**输入：** `/milestone-review milestone-07`

**预期行为：**
1. 技能尝试读取 `production/milestones/milestone-07.md`
2. 文件未找到；技能输出错误信息
3. 技能建议检查 `production/milestones/` 中的可用里程碑
4. 不调用关卡；不写入文件

**断言：**
- [ ] 当里程碑文件不存在时，技能不会崩溃
- [ ] 输出在错误信息中命名了预期的文件路径
- [ ] 输出建议检查 `production/milestones/` 以获取有效的里程碑名称
- [ ] 裁决为 BLOCKED（无法审查不存在的里程碑）

---

### 用例 5：Lean/Solo 模式 —— PR-MILESTONE 关卡被跳过

**测试夹具：**
- `production/milestones/milestone-03.md` 存在，包含 5 个已完成的 Story
- `review-mode.txt` 包含 `solo`

**输入：** `/milestone-review milestone-03`

**预期行为：**
1. 技能读取审查模式 —— 确定为 `solo`
2. 技能编译审查草稿
3. PR-MILESTONE 关卡被跳过；输出记录"[PR-MILESTONE] skipped —— Solo mode"
4. 技能询问用户直接批准审查
5. 用户批准；审查文件写入；裁决为 MILESTONE COMPLETE

**断言：**
- [ ] 在 solo（或 lean）模式下不调用 PR-MILESTONE 关卡
- [ ] 跳过在技能输出中被明确记录
- [ ] 在写入前仍需要用户的直接批准
- [ ] 成功写入后裁决为 MILESTONE COMPLETE

---

## 协议合规性

- [ ] 在调用 PR-MILESTONE 或询问写入前展示编译的审查草稿
- [ ] 在写入审查文档前始终询问 "May I write"
- [ ] PR-MILESTONE 关卡仅在 full 模式下运行
- [ ] 跳过消息出现在 lean 和 solo 模式输出中
- [ ] 裁决为 MILESTONE COMPLETE 或 MILESTONE INCOMPLETE，明确说明

---

## 覆盖说明

- 未测试里程碑有零个 Story 的情况；它遵循 MILESTONE INCOMPLETE 模式，并附带一条注释，建议该里程碑可能尚未规划。
- 速度计算细节（Story 点数 vs. Story 数量）不在此处验证；它们是审查编译阶段的实现细节。
