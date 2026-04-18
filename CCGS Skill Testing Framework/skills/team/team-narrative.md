# 技能测试规范：/team-narrative

## 技能摘要

通过一个五阶段流水线协调叙事团队：叙事方向（narrative-director）→ 世界基础 + 对话起草（world-builder 和 writer 并行）→ 关卡叙事集成（level-designer）→ 一致性审查（narrative-director）→ 润色 + 本地化合规（writer、localization-lead 和 world-builder 并行）。在每个阶段转换时使用 `AskUserQuestion` 将提案作为可选项展示。生成叙事摘要报告，并通过子代理交付叙事文档，每个子代理都强制执行"May I write?"协议。当所有阶段成功时裁决为 COMPLETE，当依赖项未解决时裁决为 BLOCKED。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含"文件写入协议"部分
- [ ] 文件写入被委托给子代理 —— 编排器不直接写入文件
- [ ] 子代理在任何写入前强制执行"May I write to [path]?"
- [ ] 在末尾具有下一步交接（引用 `/design-review`、`/localize extract`、`/dev-story`）
- [ ] 存在错误恢复协议部分
- [ ] 在阶段转换前使用 `AskUserQuestion`
- [ ] 阶段 2 明确并行生成 world-builder 和 writer
- [ ] 阶段 5 明确并行生成 writer、localization-lead 和 world-builder

---

## 测试用例

### 用例 1：理想路径 —— 所有五个阶段完成，叙事文档已交付

**测试夹具：**
- 目标功能（例如，`design/gdd/faction-intro.md`）存在游戏概念和 GDD
- 角色语音档案存在（例如，`design/narrative/characters/`）
- 现有背景故事条目存在用于交叉引用（例如，`design/narrative/lore/`）
- 现有条目与新内容之间不存在背景故事矛盾

**输入：** `/team-narrative faction introduction cutscene for the Ironveil faction`

**预期行为：**
1. 阶段 1：生成 narrative-director；输出定义故事节拍、涉及的角色、情感基调和背景故事依赖关系的叙事简报
2. `AskUserQuestion` 展示叙事简报；用户在阶段 2 开始前批准
3. 阶段 2：并行生成 world-builder 和 writer；world-builder 为 Ironveil 派系生成背景故事条目；writer 使用角色语音档案起草对话行
4. `AskUserQuestion` 展示世界基础和对话草稿；用户在阶段 3 开始前批准
5. 阶段 3：生成 level-designer；生成环境叙事布局、触发器放置和节奏计划
6. `AskUserQuestion` 展示关卡叙事计划；用户在阶段 4 开始前批准
7. 阶段 4：narrative-director 审查所有对话是否符合语音档案，验证背景故事一致性，确认节奏；批准或标记问题
8. `AskUserQuestion` 展示审查结果；用户在阶段 5 开始前批准
9. 阶段 5：并行生成 writer、localization-lead 和 world-builder；writer 执行最终自我审查；localization-lead 验证 i18n 合规性；world-builder 最终确定正典层级
10. 展示最终摘要报告；子代理在写入前询问"May I write the narrative document to [path]?"
11. 裁决：COMPLETE

**断言：**
- [ ] narrative-director 在阶段 1 中在任何其他代理之前生成
- [ ] `AskUserQuestion` 出现在阶段 1 输出之后和阶段 2 启动之前
- [ ] world-builder 和 writer 的 Task 调用在阶段 2 中同时发出（不是顺序的）
- [ ] 直到阶段 2 的 `AskUserQuestion` 被批准后才启动 level-designer
- [ ] narrative-director 在阶段 4 中为一致性审查重新生成
- [ ] 阶段 5 同时生成所有三个代理（writer、localization-lead、world-builder）
- [ ] 摘要报告包含：叙事简报状态、创建/更新的背景故事条目、编写的对话行、关卡叙事集成点、一致性审查结果
- [ ] 编排器不直接写入任何文件
- [ ] 交付后裁决为 COMPLETE

---

### 用例 2：发现背景故事矛盾 —— world-builder 在 writer 继续前发现冲突

**测试夹具：**
- `design/narrative/lore/ironveil-history.md` 中的现有背景故事条目说明 Ironveil 派系成立于 200 年前
- 阶段 1 的新叙事简报说明 Ironveil 成立于 50 年前
- writer 已在阶段 2 中与 world-builder 并行生成

**输入：** `/team-narrative ironveil faction introduction cutscene`

**预期行为：**
1. 阶段 1–2 正常开始
2. 阶段 2 world-builder 检测到叙事简报与现有背景故事之间存在事实矛盾：成立日期冲突
3. world-builder 返回 BLOCKED 并说明原因："发现背景故事矛盾 —— 成立日期与 `design/narrative/lore/ironveil-history.md` 冲突"
4. 编排器立即展示矛盾："world-builder：BLOCKED —— 背景故事矛盾：叙事简报中的成立日期（50 年前）与现有正典（ironveil-history.md 中的 200 年前）冲突"
5. 编排器评估依赖关系：writer 的对话依赖于正典背景故事 —— 在解决矛盾前无法最终确定 writer 的草稿
6. `AskUserQuestion` 提供选项：
   - 修订叙事简报以匹配现有正典（200 年前）
   - 更新现有背景故事条目以反映新正典（50 年前）
   - 在此处停止并先在背景故事文档中解决矛盾
7. Writer 输出被保留但标记为等待正典解决 —— 工作不会被丢弃
8. 在矛盾解决或用户明确选择跳过前，编排器不会进入阶段 3

**断言：**
- [ ] 矛盾在阶段 3 开始前被展示
- [ ] 编排器不会通过选择其中一个版本来静默解决矛盾
- [ ] `AskUserQuestion` 至少提供 3 个选项，包括"先停止并解决"
- [ ] Writer 的草稿输出在部分报告中被保留，不会被丢弃
- [ ] 在矛盾解决前不启动阶段 3（level-designer）
- [ ] 如果用户停止解决矛盾，裁决为 BLOCKED（不是 COMPLETE）

---

### 用例 3：无参数 —— 展示使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-narrative`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用指南：例如，"用法：`/team-narrative [narrative content description]` —— 描述要处理的故事内容、场景或叙事区域（例如，`boss encounter cutscene`、`faction intro dialogue`、`tutorial narrative`）"
3. 技能退出而不生成任何代理

**断言：**
- [ ] 未提供参数时，技能不生成任何代理
- [ ] 使用消息包含带参数示例的正确调用格式
- [ ] 技能不会尝试从项目文件猜测或推断叙事主题
- [ ] 不使用 `AskUserQuestion` —— 输出是直接指导

---

### 用例 4：本地化合规 —— localization-lead 标记不可翻译的字符串

**测试夹具：**
- 阶段 1–4 成功完成
- 阶段 5 开始；writer 和 world-builder 无问题完成
- localization-lead 发现一行对话使用了硬编码的格式化日期字符串（例如，`"On March 12th, Year 3"`），如果没有区域感知格式化器，它无法经受区域特定的翻译

**输入：** `/team-narrative ironveil faction introduction cutscene`（阶段 5 场景）

**预期行为：**
1. 阶段 5 并行生成 writer、localization-lead 和 world-builder
2. localization-lead 完成其审查并标记："String key `dialogue.ironveil.intro.003` 包含硬编码日期格式（`March 12th, Year 3`），无法正确本地化 —— 需要区域感知日期占位符"
3. 编排器在摘要报告中展示本地化阻塞项
4. 本地化问题在最终报告中被标记为 BLOCKING（不是建议性）
5. `AskUserQuestion` 提供选项：
   - 现在修复字符串（writer 修订该行）
   - 记录差距并交付带有问题标记的叙事文档
   - 停止并在最终确定前解决
6. 如果用户选择继续并标记问题，裁决为 COMPLETE 并注明本地化债务；如果用户停止，裁决为 BLOCKED

**断言：**
- [ ] localization-lead 在阶段 5 中与 writer 和 world-builder 同时生成
- [ ] 硬编码日期格式被识别为本地化阻塞项（不是静默通过）
- [ ] 具体字符串键和原因包含在问题报告中
- [ ] `AskUserQuestion` 提供立即修复 vs. 标记并继续的选项
- [ ] 如果用户继续而不修复，裁决注明本地化债务
- [ ] 技能不会在没有用户批准的情况下自动重写违规行

---

### 用例 5：Writer 阻塞 —— 缺少角色语音档案

**测试夹具：**
- 阶段 1 narrative-director 生成引用两个角色的叙事简报：Commander Varek 和 Advisor Selene
- `design/narrative/characters/` 中不存在任何角色的角色语音档案
- 阶段 2 开始；world-builder 正常进行

**输入：** `/team-narrative ironveil surrender negotiation scene`

**预期行为：**
1. 阶段 1 完成；叙事简报将 Commander Varek 和 Advisor Selene 列为角色
2. 阶段 2：writer 与 world-builder 并行生成
3. writer 返回 BLOCKED："无法生成对话 —— 在 `design/narrative/characters/` 中未找到 Commander Varek 或 Advisor Selene 的语音档案。需要语音档案来匹配角色语调和言语模式。"
4. 编排器立即展示阻塞项："writer：BLOCKED —— 缺少先决条件：Commander Varek 和 Advisor Selene 的角色语音档案"
5. world-builder 输出被保留；生成包含背景故事条目的部分报告
6. `AskUserQuestion` 提供选项：
   - 先创建语音档案（重定向到 narrative-director 或设计工作流）
   - 提供最小化的语音方向并以内联方式重试 writer
   - 在此处停止并在继续前创建语音档案
7. 在没有 writer 输出的情况下，编排器不会进入阶段 3（level-designer）

**断言：**
- [ ] Writer 阻塞在阶段 3 开始前被展示
- [ ] world-builder 已完成的背景故事输出在部分报告中被保留
- [ ] 缺失的先决条件（语音档案）被具体命名（角色名称和预期文件路径）
- [ ] `AskUserQuestion` 至少提供一个选项来解决缺失的先决条件
- [ ] 编排器不会编造语音档案或发明角色声音
- [ ] 在 writer 被 BLOCKED 且无明确用户授权时，不启动阶段 3

---

## 协议合规性

- [ ] 在每个阶段输出后使用 `AskUserQuestion`，在下一阶段启动前
- [ ] 并行生成：阶段 2（world-builder + writer）和阶段 5（writer + localization-lead + world-builder）在等待结果前发出所有 Task 调用
- [ ] 编排器不直接写入任何文件 —— 所有写入都委托给子代理
- [ ] 每个子代理在任何写入前强制执行"May I write to [path]?"协议
- [ ] 任何代理的 BLOCKED 状态立即被展示 —— 不是静默跳过
- [ ] 当某些代理完成而其他代理阻塞时，始终生成部分报告
- [ ] 裁决严格为 COMPLETE 或 BLOCKED —— 不使用其他裁决值
- [ ] 后续步骤交接引用 `/design-review`、`/localize extract` 和 `/dev-story`

---

## 覆盖说明

- 阶段 3（level-designer）和阶段 4（narrative-director 审查）的理想路径行为通过用例 1 隐式验证。这些阶段的单独边界情况不需要，因为它们的故障模式遵循标准错误恢复协议。
- 错误恢复协议中的"以更小范围重试"和"跳过此代理"解决路径未单独测试 —— 它们遵循在用例 2 和 5 中验证的相同 `AskUserQuestion` + 部分报告模式。
- 本地化顾虑是建议性（例如，德语/芬兰语 +30% 扩展警告）vs. 阻塞性（硬编码格式）的区别在用例 4 中体现；仅建议性的场景遵循相同模式但不改变裁决。
- Writer 在阶段 5 中的"所有行低于 120 个字符"和"字符串键不是原始字符串"检查通过用例 4 的本地化合规场景隐式覆盖。
