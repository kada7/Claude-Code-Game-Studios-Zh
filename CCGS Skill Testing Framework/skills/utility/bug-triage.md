# 技能测试规范：/bug-triage

## 技能摘要

`/bug-triage` 读取 `production/bugs/` 中的所有开放错误报告，并按严重等级（CRITICAL → HIGH → MEDIUM → LOW）排序生成优先级的分类表。它在 Haiku 模型上运行（只读、格式化/排序任务），不产生文件写入 —— 分类输出是对话式的。该技能会标记缺少复现步骤的错误，并通过比较标题和受影响系统来识别可能的重复项。

裁决始终为 TRIAGED —— 该技能是咨询性和信息性的。不适用总监关卡。输出旨在帮助制作人或 QA 主管确定接下来要处理哪些错误。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：TRIAGED
- [ ] 不包含 "May I write" 语言（技能为只读）
- [ ] 具有下一步交接（例如，`/bug-report` 创建新报告，`/hotfix` 处理关键错误）

---

## 总监关卡检查

无。`/bug-triage` 是只读咨询技能。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— 5 个不同严重等级的错误，生成排序表

**测试夹具：**
- `production/bugs/` 包含 5 个错误报告文件：
  - bug-2026-03-10-audio-crash.md (CRITICAL)
  - bug-2026-03-12-score-overflow.md (HIGH)
  - bug-2026-03-14-ui-overlap.md (MEDIUM)
  - bug-2026-03-15-typo-tutorial.md (LOW)
  - bug-2026-03-16-vfx-flicker.md (HIGH)

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取所有 5 个错误报告文件
2. 技能从每个报告中提取严重等级、标题、系统和复现状态
3. 技能生成分类表，排序：CRITICAL 优先，然后是 HIGH、MEDIUM、LOW
4. 相同严重等级内，错误按日期排序（最早的优先）
5. 裁决为 TRIAGED

**断言：**
- [ ] 分类表恰好有 5 行
- [ ] CRITICAL 错误出现在两个 HIGH 错误之前
- [ ] HIGH 错误出现在 MEDIUM 和 LOW 错误之前
- [ ] 裁决为 TRIAGED
- [ ] 未写入任何文件

---

### 用例 2：未找到错误报告 —— 引导运行 /bug-report

**测试夹具：**
- `production/bugs/` 目录存在但为空（或不存在）

**输入：** `/bug-triage`

**预期行为：**
1. 技能扫描 `production/bugs/` 并未找到报告
2. 技能输出："No open bug reports found in production/bugs/"
3. 技能建议运行 `/bug-report` 来创建错误报告
4. 未生成分类表

**断言：**
- [ ] 输出明确说明未找到错误
- [ ] `/bug-report` 被建议为下一步
- [ ] 技能不会报错 —— 它优雅地处理空目录
- [ ] 裁决为 TRIAGED（带有"未找到错误"上下文）

---

### 用例 3：错误缺少复现步骤 —— 标记为 NEEDS REPRO INFO

**测试夹具：**
- `production/bugs/` 包含 3 个错误报告；其中一个的 "Repro Steps" 部分为空

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取所有 3 个报告
2. 技能检测到缺少复现步骤的报告
3. 该错误在分类表中显示 `NEEDS REPRO INFO` 标签
4. 其他错误正常分类
5. 裁决为 TRIAGED

**断言：**
- [ ] `NEEDS REPRO INFO` 标签出现在缺少复现步骤的错误旁边
- [ ] 被标记的错误仍包含在表中（未被排除）
- [ ] 其他错误不受影响
- [ ] 裁决为 TRIAGED

---

### 用例 4：可能的重复错误 —— 在分类输出中标记

**测试夹具：**
- `production/bugs/` 包含 2 个标题相似的报告：
  - bug-2026-03-18-player-fall-through-floor.md
  - bug-2026-03-20-player-clips-through-floor.md
  - 两个都影响 "Physics" 系统，严重等级相同

**输入：** `/bug-triage`

**预期行为：**
1. 技能读取两个报告并检测到相似的标题 + 相同的系统 + 相同的严重等级
2. 两个错误都包含在分类表中
3. 每个都标记为 `POSSIBLE DUPLICATE` 并交叉引用另一个报告
4. 未合并或删除任何错误 —— 标记是咨询性的
5. 裁决为 TRIAGED

**断言：**
- [ ] 两个错误都出现在表中（未合并）
- [ ] 两个都标记为 `POSSIBLE DUPLICATE`
- [ ] 每个都交叉引用另一个（通过文件名或标题）
- [ ] 裁决为 TRIAGED

---

### 用例 5：总监关卡检查 —— 无关卡；分类是咨询性的

**测试夹具：**
- `production/bugs/` 包含任意数量的报告

**输入：** `/bug-triage`

**预期行为：**
1. 技能生成分类表
2. 不生成总监代理
3. 输出中不出现关卡 ID
4. 未调用 Write 工具

**断言：**
- [ ] 未调用总监关卡
- [ ] 未调用 Write 工具
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 TRIAGED，无任何关卡检查

---

## 协议合规性

- [ ] 在生成表前读取 `production/bugs/` 中的所有文件
- [ ] 按严重等级排序（CRITICAL → HIGH → MEDIUM → LOW）
- [ ] 标记缺少复现步骤的错误
- [ ] 通过标题/系统相似性标记可能的重复项
- [ ] 不写入任何文件
- [ ] 裁决在所有情况下均为 TRIAGED（即使为空）

---

## 覆盖说明

- 错误报告格式错误（完全缺少严重等级字段）的情况未使用夹具测试；技能会将其标记为 `UNKNOWN SEVERITY` 并排在表的最后。
- 状态转换（将错误标记为已解决）超出此技能的范围 —— bug-triage 是只读的。
- 重复检测启发式方法（标题相似性 + 相同系统）是近似的；精确匹配逻辑在技能主体中定义。
