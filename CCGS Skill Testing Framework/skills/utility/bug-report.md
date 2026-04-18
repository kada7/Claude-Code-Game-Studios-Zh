# 技能测试规范：/bug-report

## 技能摘要

`/bug-report` 根据用户描述创建结构化错误报告文档。它生成的报告包含以下必填字段：标题、复现步骤、预期行为、实际行为、严重等级（CRITICAL/HIGH/MEDIUM/LOW）、受影响系统、构建/版本。如果用户的初始描述缺少任何必填字段，技能会在生成草稿前询问后续问题来填补空白。

该技能会检查可能的重复报告（通过与 `production/bugs/` 中的现有文件进行比较），并提议关联而非创建新报告。每份报告在询问"May I write"后写入 `production/bugs/bug-[date]-[slug].md`。不使用总监关卡 —— 错误报告是运营工具。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在写入报告前
- [ ] 具有下一步交接（例如，`/bug-triage` 重新分级，`/hotfix` 处理关键问题）

---

## 总监关卡检查

无。`/bug-report` 是运营文档技能。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— 用户描述崩溃，生成完整报告

**测试夹具：**
- `production/bugs/` 目录存在且为空
- 无类似的现有报告

**输入：** `/bug-report`（用户描述："Game crashes when player enters the boss arena"）

**预期行为：**
1. 技能提取：标题 = "Game crashes when entering boss arena"
2. 技能将崩溃报告识别为 CRITICAL 严重等级
3. 技能与用户确认复现步骤、预期（无崩溃）、实际（崩溃）、受影响系统（arena/boss）和构建版本
4. 技能起草完整的结构化报告
5. 技能询问"May I write to `production/bugs/bug-2026-04-06-game-crashes-boss-arena.md`?"
6. 文件在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 报告中存在所有 7 个必填字段
- [ ] 崩溃报告的严重等级为 CRITICAL
- [ ] 文件名遵循 `bug-[date]-[slug].md` 约定
- [ ] "May I write" 询问了完整的文件路径
- [ ] 裁决为 COMPLETE

---

### 用例 2：最小输入 —— 技能询问后续问题以填补缺失字段

**测试夹具：**
- 用户提供："Sometimes the audio cuts out"
- 无现有报告

**输入：** `/bug-report`

**预期行为：**
1. 技能识别缺失的必填字段：复现步骤、预期 vs. 实际、严重等级、受影响系统、构建版本
2. 技能针对每个缺失字段询问有针对性的后续问题（一次一个或结构化提示）
3. 用户提供答案
4. 技能根据答案编译完整报告
5. 技能询问 "May I write?" 并在批准后写入

**断言：**
- [ ] 至少询问 3 个后续问题来填补缺失字段
- [ ] 在报告定稿前填写每个必填字段
- [ ] 在所有必填字段齐全前不写入报告
- [ ] 所有字段填写完毕且文件写入后，裁决为 COMPLETE

---

### 用例 3：可能的重复 —— 提议关联而非创建新报告

**测试夹具：**
- `production/bugs/bug-2026-03-20-audio-cut-out.md` 已存在，具有类似标题和 MEDIUM 严重等级

**输入：** `/bug-report`（用户描述："Audio randomly stops working"）

**预期行为：**
1. 技能扫描现有报告并找到类似的音频错误
2. 技能报告："A similar bug report exists: bug-2026-03-20-audio-cut-out.md"
3. 技能展示选项：关联为重复（添加到现有注释）、仍然创建新报告
4. 如果用户选择关联：技能向现有文件添加交叉引用注释（询问 "May I update the existing report?"）
5. 如果用户选择创建新报告：正常进行报告创建

**断言：**
- [ ] 在创建新报告前展示现有的类似报告
- [ ] 用户有选择权（未被强制关联或创建）
- [ ] 如果关联：在修改现有文件前询问 "May I update"
- [ ] 两种路径均裁决为 COMPLETE

---

### 用例 4：多系统错误 —— 报告创建时带有多个系统标签

**测试夹具：**
- 无现有报告

**输入：** `/bug-report`（用户描述："After finishing a level, the save system freezes and the UI doesn't show the completion screen"）

**预期行为：**
1. 技能从描述中识别出 2 个受影响系统：Save System 和 UI
2. 报告起草时两个系统均列在 Affected System(s) 下
3. 评估严重等级（可能为 HIGH —— 保存冻结存在数据丢失风险）
4. 技能询问 "May I write" 并使用适当的文件名
5. 报告写入时两个系统均已标记；裁决为 COMPLETE

**断言：**
- [ ] 报告中列出了两个受影响系统
- [ ] 创建了单个报告（非每个系统一个）
- [ ] 严重等级反映了影响最大的组件（保存冻结 → HIGH 或 CRITICAL）
- [ ] 裁决为 COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；错误报告是运营性的

**测试夹具：**
- 提供了任何错误描述

**输入：** `/bug-report`

**预期行为：**
1. 技能创建并写入错误报告
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 技能在无任何关卡检查的情况下达到 COMPLETE

---

## 协议合规性

- [ ] 在起草报告前收集所有 7 个必填字段
- [ ] 针对任何缺失的必填字段询问后续问题
- [ ] 在创建新报告前检查类似的现有报告
- [ ] 在写入前询问 "May I write to `production/bugs/bug-[date]-[slug].md`?"
- [ ] 报告文件写入时，裁决为 COMPLETE

---

## 覆盖说明

- 用户提供与描述影响相比过低的严重等级（例如，崩溃报告为 LOW）的情况未测试；技能可能建议更高的严重等级，但最终尊重用户输入。
- 构建/版本字段是必填的，但如果用户不知道，可以是 "unknown" —— 这作为有效值被接受，未单独测试。
- 报告 slug 生成（将标题清理为文件名）是此处未断言测试的实现细节。
