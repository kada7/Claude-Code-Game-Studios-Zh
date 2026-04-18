# 技能测试规范：/team-audio

## 技能摘要

通过一个四步流水线协调音频团队：音频方向（audio-director）→ 声音设计 + 无障碍审查并行（sound-designer + accessibility-specialist）→ 技术实现 + 引擎验证并行（technical-artist + 主引擎专家）→ 代码集成（gameplay-programmer）。在生成任何代理前读取相关 GDD、声音圣经（如果存在）和现有音频资产列表。将所有输出编译为一份音频设计文档，保存到 `design/gdd/audio-[feature].md`。在每一步转换时使用 `AskUserQuestion`。当音频设计文档生成时裁决为 COMPLETE。当未配置引擎时优雅地跳过引擎专家生成。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个步骤/阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含"文件写入协议"部分
- [ ] 文件写入被委托给子代理 —— 编排器不直接写入文件
- [ ] 子代理在任何写入前强制执行"May I write to [path]?"
- [ ] 在末尾具有下一步交接（引用 `/dev-story`、`/asset-audit`）
- [ ] 存在错误恢复协议部分
- [ ] 在步骤转换前使用 `AskUserQuestion`
- [ ] 步骤 2 明确并行生成 sound-designer 和 accessibility-specialist
- [ ] 步骤 3 明确并行生成 technical-artist 和引擎专家（当引擎已配置时）
- [ ] 技能在上下文收集期间读取 `design/gdd/sound-bible.md`（如果存在）
- [ ] 输出文档保存到 `design/gdd/audio-[feature].md`

---

## 测试用例

### 用例 1：理想路径 —— 所有步骤完成，音频设计文档已保存

**测试夹具：**
- 目标功能的 GDD 存在于 `design/gdd/combat.md`
- 声音圣经存在于 `design/gdd/sound-bible.md`
- 现有音频资产列在 `assets/audio/` 中
- 引擎配置在 `.claude/docs/technical-preferences.md` 中
- 计划的音频事件列表中不存在无障碍差距

**输入：** `/team-audio combat`

**预期行为：**
1. 上下文收集：编排器在生成任何代理前读取 `design/gdd/combat.md`、`design/gdd/sound-bible.md` 和 `assets/audio/` 资产列表
2. 步骤 1：生成 audio-director；定义战斗的听觉身份、情感基调、自适应音乐方向、混音目标和自适应音频规则
3. `AskUserQuestion` 展示音频方向；用户在步骤 2 开始前批准
4. 步骤 2：并行生成 sound-designer 和 accessibility-specialist；sound-designer 生成 SFX 规格、带触发条件的音频事件列表和混音组；accessibility-specialist 识别关键游戏音频事件并指定视觉回退和字幕需求
5. `AskUserQuestion` 展示 SFX 规格和无障碍需求；用户在步骤 3 开始前批准
6. 步骤 3：并行生成 technical-artist 和主引擎专家；technical-artist 设计总线结构、中间件集成、内存预算和流策略；引擎专家验证集成方法对配置引擎而言是否地道
7. `AskUserQuestion` 展示技术方案；用户在步骤 4 开始前批准
8. 步骤 4：生成 gameplay-programmer；将音频事件连接到游戏触发器、实现自适应音乐、设置遮挡区域、为音频事件触发器编写单元测试
9. 编排器将所有输出编译为一份音频设计文档
10. 子代理在写入前询问"May I write the audio design document to `design/gdd/audio-combat.md`?"
11. 摘要输出列出：音频事件数量、估计资产数量、实现任务和任何未决问题
12. 裁决：COMPLETE

**断言：**
- [ ] 上下文收集时读取声音圣经（步骤 1 之前）当它存在时
- [ ] audio-director 在 sound-designer 或 accessibility-specialist 之前生成
- [ ] `AskUserQuestion` 出现在步骤 1 输出之后和步骤 2 启动之前
- [ ] sound-designer 和 accessibility-specialist 的 Task 调用在步骤 2 中同时发出
- [ ] technical-artist 和引擎专家的 Task 调用在步骤 3 中同时发出
- [ ] gameplay-programmer 直到步骤 3 的 `AskUserQuestion` 被批准后才启动
- [ ] 音频设计文档写入 `design/gdd/audio-combat.md`（不是其他路径）
- [ ] 摘要包含音频事件数量和估计资产数量
- [ ] 编排器不直接写入任何文件
- [ ] 文档交付后裁决为 COMPLETE

---

### 用例 2：无障碍差距 —— 关键游戏音频事件没有视觉回退

**测试夹具：**
- 目标功能的 GDD 存在
- 步骤 1 和步骤 2 正在进行中
- sound-designer 的音频事件列表包含 "EnemyNearbyAlert" —— 一个空间音频提示，警告玩家敌人正从屏幕外接近
- accessibility-specialist 审查事件列表并发现 "EnemyNearbyAlert" 没有视觉回退（没有屏幕指示器、没有字幕、没有指定控制器震动）

**输入：** `/team-audio stealth`（步骤 2 场景）

**预期行为：**
1. 步骤 1–2 进行；accessibility-specialist 和 sound-designer 并行生成
2. accessibility-specialist 返回其审查并附带 BLOCKING 顾虑："`EnemyNearbyAlert` 是一个关键游戏音频事件（警告玩家屏幕外威胁）且没有视觉回退 —— 听力受损的玩家无法检测到此威胁。这是一个 BLOCKING 无障碍差距。"
3. 编排器在展示 `AskUserQuestion` 前立即在对话中展示该顾虑
4. `AskUserQuestion` 将无障碍差距作为 BLOCKING 问题展示，并提供选项：
   - 为 EnemyNearbyAlert 添加视觉指示器（例如，HUD 上的方向箭头）并继续
   - 添加控制器触觉反馈作为回退并继续
   - 在此处停止并在进入步骤 3 前解决所有无障碍差距
5. 在用户解决或明确接受该差距前，不启动步骤 3（technical-artist + 引擎专家）
6. 如果未解决，该无障碍差距在最终音频设计文档的"未解决无障碍问题"下被包含

**断言：**
- [ ] 无障碍差距在报告中被标记为 BLOCKING（不是建议性）
- [ ] 具体的事件名称（"EnemyNearbyAlert"）和差距性质被说明
- [ ] `AskUserQuestion` 在步骤 3 启动前展示该差距
- [ ] 至少提供一个解决选项（添加视觉回退、添加触觉回退）
- [ ] 在差距未解决且无明确用户授权时不启动步骤 3
- [ ] 如果差距被继续携带未解决，它被记录在音频设计文档中作为未决问题

---

### 用例 3：无参数 —— 使用指南或设计文档推断

**测试夹具：**
- 任何项目状态

**输入：** `/team-audio`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用指南：例如，"用法：`/team-audio [feature or area]` —— 指定要设计音频的功能或区域（例如，`combat`、`main menu`、`forest biome`、`boss encounter`）"
3. 技能退出而不生成任何代理

**断言：**
- [ ] 未提供参数时，技能不生成任何代理
- [ ] 使用消息包含带参数示例的正确调用格式
- [ ] 技能不会在没有用户方向的情况下从现有设计文档推断功能
- [ ] 不使用 `AskUserQuestion` —— 输出是直接指导

---

### 用例 4：缺少声音圣经 —— 技能记录差距并在没有它的情况下继续

**测试夹具：**
- 目标功能的 GDD 存在于 `design/gdd/main-menu.md`
- `design/gdd/sound-bible.md` 不存在
- 引擎已配置；其他上下文文件存在

**输入：** `/team-audio main menu`

**预期行为：**
1. 上下文收集：编排器读取 `design/gdd/main-menu.md` 并检查 `design/gdd/sound-bible.md`
2. 未找到声音圣经；编排器在对话中记录差距："注意：`design/gdd/sound-bible.md` 未找到 —— 音频方向将在没有项目范围听觉身份参考的情况下进行。如果这是正在进行的项目，考虑创建声音圣经。"
3. 流水线在所有四个步骤中正常进行，不使用声音圣经作为输入
4. 步骤 1 中的 audio-director 被告知不存在声音圣经，必须仅从功能 GDD 建立听觉身份
5. 最终摘要中将缺失的声音圣经作为推荐的后续步骤提及

**断言：**
- [ ] 编排器在上下文收集期间（步骤 1 之前）检查声音圣经
- [ ] 缺失的声音圣经在对话中被明确记录 —— 不是静默忽略
- [ ] 流水线不会因为缺失声音圣经而停止
- [ ] audio-director 在其提示上下文中被通知不存在声音圣经
- [ ] 摘要或后续步骤部分建议创建声音圣经
- [ ] 如果所有其他步骤成功，裁决仍为 COMPLETE

---

### 用例 5：引擎未配置 —— 引擎专家步骤被优雅跳过

**测试夹具：**
- 引擎未在 `.claude/docs/technical-preferences.md` 中配置（显示 `[TO BE CONFIGURED]`）
- 目标功能的 GDD 存在
- 声音圣经可能存在也可能不存在

**输入：** `/team-audio boss encounter`

**预期行为：**
1. 上下文收集：编排器读取 `.claude/docs/technical-preferences.md` 并检测到未配置引擎
2. 步骤 1–2 正常进行（audio-director、sound-designer、accessibility-specialist）
3. 步骤 3：正常生成 technical-artist；引擎专家生成被跳过
4. 编排器在对话中记录："引擎专家未生成 —— technical-preferences.md 中未配置引擎。引擎集成验证将延期到选择引擎后。"
5. 步骤 4：gameplay-programmer 继续进行，并记录无法验证引擎特定的音频集成模式
6. 引擎专家差距在音频设计文档的"延期验证"下被包含
7. 裁决：COMPLETE（跳过是优雅的，不是阻塞项）

**断言：**
- [ ] 未配置引擎时不生成引擎专家
- [ ] 技能不会因为缺少引擎配置而报错
- [ ] 跳过在对话中被明确记录 —— 不是静默省略
- [ ] technical-artist 仍在步骤 3 中生成（跳过仅适用于引擎专家）
- [ ] gameplay-programmer 在步骤 4 中进行，并记录了延期验证
- [ ] 延期引擎验证记录在音频设计文档中
- [ ] 裁决为 COMPLETE（引擎未配置是已知的优雅情况）

---

## 协议合规性

- [ ] 上下文收集（GDD、声音圣经、资产列表）在任何代理生成前运行
- [ ] 在每一步输出后使用 `AskUserQuestion`，在下一步启动前
- [ ] 并行生成：步骤 2（sound-designer + accessibility-specialist）和步骤 3（technical-artist + 引擎专家）在等待结果前发出所有 Task 调用
- [ ] 编排器不直接写入任何文件 —— 所有写入都委托给子代理
- [ ] 每个子代理在任何写入前强制执行"May I write to [path]?"协议
- [ ] 任何代理的 BLOCKED 状态立即被展示 —— 不是静默跳过
- [ ] 当某些代理完成而其他代理阻塞时，始终生成部分报告
- [ ] 音频设计文档路径遵循模式 `design/gdd/audio-[feature].md`
- [ ] 裁决严格为 COMPLETE 或 BLOCKED —— 不使用其他裁决值
- [ ] 后续步骤交接引用 `/dev-story` 和 `/asset-audit`

---

## 覆盖说明

- 错误恢复协议中的"以更小范围重试"和"跳过此代理"解决路径未单独测试 —— 它们遵循在用例 2 和 5 中验证的相同 `AskUserQuestion` + 部分报告模式。
- 步骤 4（gameplay-programmer）的理想路径行为通过用例 1 隐式验证。此步骤的故障模式遵循标准错误恢复协议。
- accessibility-specialist 的字幕和标题需求（超出视觉回退）通过用例 1 隐式验证。用例 2 关注更严重的情况，即关键游戏事件完全没有回退。
- 引擎专家验证逻辑（地道集成、版本特定变更）仅针对已配置和未配置状态进行测试。引擎专家输出的具体内容超出此行为规范的范围。
