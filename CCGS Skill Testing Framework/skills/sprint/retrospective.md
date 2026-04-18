# 技能测试规范：/retrospective

## 技能摘要

`/retrospective` 生成结构化的 Sprint 或里程碑回顾，涵盖三个类别：哪些做得好、哪些做得不好以及行动项。它读取 Sprint 文件和会话日志来编译观察结果，然后生成一份回顾文档。不调用任何导演关卡 —— 回顾是团队自我反思的工件。该技能在持久化前询问"我可以写入 `production/retrospectives/retro-sprint-NNN.md` 吗？"。裁决结果始终为 COMPLETE（回顾是结构化输出，不是通过/失败评估）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 语言（技能写入回顾文档）
- [ ] 具有下一步交接（回顾文档写入后该做什么）

---

## 导演关卡检查

无。回顾是团队自我反思文档；不调用任何关卡。

---

## 测试用例

### 用例 1：理想路径 —— 结果参半的 Sprint

**测试夹具：**
- `production/sprints/sprint-005.md` 存在，包含 6 个 Story（4 个 Complete，1 个 Blocked，1 个 Deferred）
- `production/session-logs/` 包含该 Sprint 期间的日志条目
- 此前不存在 sprint-005 的回顾

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能读取 sprint-005 和会话日志
2. 技能编译三个回顾类别：做得好（4 个 Story 已交付）、做得不好（1 个阻塞，1 个延期）和行动项（解决阻塞项根本原因）
3. 技能向用户展示回顾草稿
4. 技能询问"我可以写入 `production/retrospectives/retro-sprint-005.md` 吗？"
5. 用户批准；文件写入；裁决为 COMPLETE

**断言：**
- [ ] 回顾包含所有三个类别（做得好 / 做得不好 / 行动项）
- [ ] 阻塞和延期的 Story 出现在"做得不好"部分
- [ ] 至少从阻塞的 Story 生成一个行动项
- [ ] 技能在写入文件前询问 "May I write"
- [ ] 成功写入后裁决为 COMPLETE

---

### 用例 2：无 Sprint 数据 —— 手动输入回退

**测试夹具：**
- 用户调用 `/retrospective sprint-009`
- `production/sprints/sprint-009.md` 不存在
- 没有会话日志引用 sprint-009

**输入：** `/retrospective sprint-009`

**预期行为：**
1. 技能尝试读取 sprint-009 —— 未找到
2. 技能告知用户未找到 sprint-009 的 Sprint 数据
3. 技能提示用户手动提供回顾输入（做得好、做得不好、行动项）
4. 用户提供输入；技能将其格式化为回顾结构
5. 技能询问 "May I write" 并在批准后写入文档

**断言：**
- [ ] 当 Sprint 文件不存在时，技能不会崩溃或生成空文档
- [ ] 提示用户提供手动输入
- [ ] 手动输入被格式化为三类别结构
- [ ] "May I write" 提示仍在文件写入前出现

---

### 用例 3：已存在先前的回顾 —— 提供追加或替换选项

**测试夹具：**
- `production/retrospectives/retro-sprint-005.md` 已存在并包含内容
- 用户在变更后重新运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能检测到 `retro-sprint-005.md` 已存在
2. 技能向用户展示选择：追加新观察结果或替换现有文件
3. 用户选择"替换"；技能编译新的回顾
4. 技能询问"我可以写入 `production/retrospectives/retro-sprint-005.md` 吗？"（确认覆盖）
5. 文件被覆盖；裁决为 COMPLETE

**断言：**
- [ ] 技能在编译前检查现有回顾文件
- [ ] 向用户提供追加或替换选择 —— 不是静默覆盖
- [ ] "May I write" 提示反映了覆盖场景
- [ ] 无论追加还是替换，写入后裁决为 COMPLETE

---

### 用例 4：边界情况 —— 先前回顾中未解决的行动项

**测试夹具：**
- `production/retrospectives/retro-sprint-004.md` 存在，包含 2 个标记为 `[ ]` 的行动项（未完成）
- 用户运行 `/retrospective sprint-005`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能读取最近的先前回顾（retro-sprint-004）
2. 技能检测到 sprint-004 有 2 个未勾选的行动项
3. 技能在新的回顾中包含一个"来自 Sprint 004 的结转"部分
4. 未解决的条目附带一条注释列出，说明它们未被跟进

**断言：**
- [ ] 技能读取最近的先前回顾以检查未完成的行动项
- [ ] 未解决的行动项出现在新回顾的结转部分下
- [ ] 结转条目与新生成的行动项区分开来
- [ ] 输出记录这些条目在上一个 Sprint 中未被跟进

---

### 用例 5：关卡合规性 —— 在任何模式下都不调用关卡

**测试夹具：**
- `production/sprints/sprint-005.md` 存在，包含已完成的 Story
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/retrospective sprint-005`

**预期行为：**
1. 技能在 full 模式下编译回顾
2. 不调用任何导演关卡（回顾是团队自我反思，而非交付关卡）
3. 技能询问用户批准并在确认后写入文件
4. 裁决为 COMPLETE

**断言：**
- [ ] 无论审查模式如何，都不调用导演关卡
- [ ] 输出不包含任何关卡调用或关卡结果标记
- [ ] 技能直接从编译进入 "May I write" 提示
- [ ] 审查模式文件内容与此技能的行为无关

---

## 协议合规性

- [ ] 在询问写入前始终展示回顾草稿
- [ ] 在写入回顾文件前始终询问 "May I write"
- [ ] 不调用导演关卡
- [ ] 裁决始终为 COMPLETE（不是通过/失败技能）
- [ ] 检查先前回顾中未完成的行动项

---

## 覆盖说明

- 里程碑回顾（与 Sprint 回顾相对）遵循相同的模式，但读取里程碑文件而非 Sprint 文件；此处未单独测试。
- 会话日志为空的情况与用例 2（无数据）类似；技能在两种情况下都回退到手动输入。
