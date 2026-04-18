# 技能测试规范：/team-combat

## 技能摘要

从头到尾协调完整战斗团队流水线以完成单个战斗功能。协调 game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、主引擎专家和 qa-tester 通过六个结构化阶段：设计 → 架构（含引擎专家验证）→ 实现（并行）→ 集成 → 验证 → 签核。在每个阶段转换时使用 `AskUserQuestion`。将所有文件写入委托给子代理。生成包含裁决 COMPLETE / NEEDS WORK / BLOCKED 的摘要报告，并交接给 `/code-review`、`/balance-check` 和 `/team-polish`。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题（阶段 1 到阶段 6 全部存在）
- [ ] 包含裁决关键词：COMPLETE、NEEDS WORK、BLOCKED
- [ ] 包含 "May I write" 或"文件写入协议" —— 写入委托给子代理，编排器不直接写入文件
- [ ] 在末尾具有下一步交接（引用 `/code-review`、`/balance-check`、`/team-polish`）
- [ ] 存在包含所有四个恢复步骤的错误恢复协议部分
- [ ] 在阶段转换时使用 `AskUserQuestion` 获取用户批准
- [ ] 阶段 3 被明确标记为并行（gameplay-programmer、ai-programmer、technical-artist、sound-designer）
- [ ] 阶段 2 包含生成主引擎专家（从 `.claude/docs/technical-preferences.md` 读取）
- [ ] 团队组成列出所有七个角色（game-designer、gameplay-programmer、ai-programmer、technical-artist、sound-designer、引擎专家、qa-tester）

---

## 测试用例

### 用例 1：理想路径 —— 所有代理成功，完整流水线运行至完成

**测试夹具：**
- `design/gdd/game-concept.md` 存在并已填充
- 引擎配置在 `.claude/docs/technical-preferences.md` 中（引擎专家部分已填充）
- 请求的 combat 功能不存在现有 GDD

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 1 —— 生成 game-designer；生成 `design/gdd/parry-riposte.md`，涵盖所有 8 个必需部分（概述、玩家幻想、规则、公式、边界情况、依赖关系、可调参数、验收标准）；要求用户批准设计文档
2. 阶段 2 —— 并行生成 gameplay-programmer + ai-programmer；生成包含类结构、接口和文件列表的架构草图；然后生成主引擎专家以验证惯用法；引擎专家输出被纳入；在阶段 3 开始前用 `AskUserQuestion` 展示架构选项
3. 阶段 3 —— 并行生成 gameplay-programmer、ai-programmer、technical-artist、sound-designer；所有四个在阶段 4 开始前返回输出
4. 阶段 4 —— 集成将所有阶段 3 的输出连接在一起；可调参数被验证为数据驱动；`AskUserQuestion` 在阶段 5 前确认集成
5. 阶段 5 —— 生成 qa-tester；根据验收标准编写测试用例；验证边界情况；根据预算检查性能影响
6. 阶段 6 —— 生成摘要报告：设计 COMPLETE，所有团队成员 COMPLETE，列出测试用例，裁决：COMPLETE
7. 列出后续步骤：`/code-review`、`/balance-check`、`/team-polish`

**断言：**
- [ ] 在每个阶段关卡调用 `AskUserQuestion`（至少在阶段 3 前和阶段 5 前）
- [ ] 阶段 3 代理同时启动 —— gameplay-programmer、ai-programmer、technical-artist、sound-designer 之间没有顺序依赖
- [ ] 引擎专家在阶段 3 开始前在阶段 2 中运行（输出被纳入架构）
- [ ] 所有文件写入委托给子代理（编排器从不直接调用 Write/Edit）
- [ ] 最终报告中存在裁决 COMPLETE
- [ ] 后续步骤包含 `/code-review`、`/balance-check`、`/team-polish`
- [ ] 设计文档涵盖所有 8 个必需的 GDD 部分

---

### 用例 2：阻塞的代理 —— 一个子代理在流水线中期返回 BLOCKED

**测试夹具：**
- `design/gdd/parry-riposte.md` 存在（阶段 1 已完成）
- ai-programmer 代理返回 BLOCKED，因为不存在 AI 系统架构 ADR（ADR 状态为 Proposed）

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 1 —— 找到设计文档；game-designer 确认其有效；阶段被批准
2. 阶段 2 —— gameplay-programmer 完成架构草图；ai-programmer 返回 BLOCKED："AI behavior system 的 ADR 为 Proposed —— 在 ADR 被接受前无法实现"
3. 触发错误恢复协议："ai-programmer：BLOCKED —— AI behavior ADR 为 Proposed"
4. `AskUserQuestion` 提供选项：(a) 跳过 ai-programmer 并记录差距；(b) 以更小范围重试；(c) 在此处停止并先运行 `/architecture-decision`
5. 如果用户选择 (a)：阶段 3 仅使用 gameplay-programmer、technical-artist、sound-designer 进行；ai-programmer 差距在部分报告中被记录
6. 生成最终报告：记录部分实现，ai-programmer 部分标记为 BLOCKED，整体裁决：BLOCKED

**断言：**
- [ ] BLOCKED 展示消息在任何依赖阶段继续前出现
- [ ] `AskUserQuestion` 至少提供三个选项：跳过 / 重试 / 停止
- [ ] 生成部分报告 —— 已完成代理的工作不会被丢弃
- [ ] 当任何代理未解决时，整体裁决为 BLOCKED（不是 COMPLETE）
- [ ] 阻塞原因引用 ADR 并建议 `/architecture-decision`
- [ ] 编排器不会静默越过阻塞的依赖项

---

### 用例 3：无参数 —— 展示清晰的使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-combat`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用消息解释所需参数（战斗功能描述）
3. 提供一个示例调用：`/team-combat [combat feature description]`
4. 技能退出而不生成任何子代理

**断言：**
- [ ] 未给出参数时，技能不生成任何子代理
- [ ] 使用消息包含来自前置元数据的 argument-hint 格式
- [ ] 错误消息包含至少一个有效调用的示例
- [ ] 超出检测缺失参数所需的范围不读取文件
- [ ] 不展示裁决（流水线从未运行）

---

### 用例 4：并行阶段验证 —— 阶段 3 代理同时运行

**测试夹具：**
- `design/gdd/parry-riposte.md` 存在且完整
- 架构草图已被批准
- 引擎专家已验证架构

**输入：** `/team-combat parry and riposte system`（从阶段 2 完成后恢复）

**预期行为：**
1. 阶段 3 在架构批准后开始
2. 所有四个 Task 调用 —— gameplay-programmer、ai-programmer、technical-artist、sound-designer —— 在等候任何结果前发出
3. 技能等待所有四个代理完成后再进入阶段 4
4. 如果任何单个代理提前完成，技能不会开始阶段 4 直到所有四个都已返回

**断言：**
- [ ] 四个 Task 调用在单一批次中发出（它们之间没有顺序等待）
- [ ] 阶段 4 直到所有四个阶段 3 代理都已返回结果后才开始
- [ ] 技能不会将一个阶段 3 代理的输出作为另一个阶段 3 代理的输入传递（它们是独立的）
- [ ] 所有四个阶段 3 代理结果在阶段 4 集成步骤中被引用

---

### 用例 5：架构阶段引擎路由 —— 引擎专家接收正确的上下文

**测试夹具：**
- `.claude/docs/technical-preferences.md` 的引擎专家部分已填充（例如，主专家：godot-specialist）
- gameplay-programmer 生成的架构草图可用
- 引擎版本固定在 `docs/engine-reference/godot/VERSION.md`

**输入：** `/team-combat parry and riposte system`

**预期行为：**
1. 阶段 2 —— gameplay-programmer 生成架构草图
2. 技能读取 `.claude/docs/technical-preferences.md` 的引擎专家部分以识别主引擎专家代理类型
3. 引擎专家被生成并附带：架构草图、GDD 路径、`VERSION.md` 中的引擎版本，以及检查已弃用 API 的明确指令
4. 引擎专家输出（惯用法注释、已弃用 API 警告、原生系统推荐）返回给编排器
5. 编排器在向用户展示阶段 2 结果前将引擎注释纳入架构
6. `AskUserQuestion` 包含引擎专家的注释以及架构草图

**断言：**
- [ ] 引擎专家代理类型从 `.claude/docs/technical-preferences.md` 读取 —— 不是硬编码的
- [ ] 引擎专家提示包含架构草图和 GDD 路径
- [ ] 引擎专家根据固定的引擎版本检查已弃用 API
- [ ] 引擎专家输出在阶段 3 开始前被纳入（不是被跳过或单独附加）
- [ ] 如果未配置引擎，引擎专家步骤被跳过并在报告中添加注释

---

## 协议合规性

- [ ] 在每个阶段转换时使用 `AskUserQuestion` —— 用户批准流水线才能推进
- [ ] 所有文件写入通过 Task 委托给子代理 —— 编排器不直接调用 Write 或 Edit
- [ ] 遵循错误恢复协议：展示 → 评估 → 提供选项 → 部分报告
- [ ] 根据技能规范并行启动阶段 3 代理
- [ ] 即使代理被 BLOCKED，也始终生成部分报告
- [ ] 裁决为 COMPLETE / NEEDS WORK / BLOCKED 之一
- [ ] 输出末尾呈现后续步骤：`/code-review`、`/balance-check`、`/team-polish`

---

## 覆盖说明

- NEEDS WORK 裁决路径（qa-tester 在阶段 5 中发现失败）未在此处单独测试；它遵循与用例 2 相同的错误恢复和部分报告协议。
- "以更小范围重试"错误恢复选项在断言中列出，但其完整递归行为（通过 `/create-stories` 拆分）由 `/create-stories` 规范覆盖。
- 阶段 4 集成逻辑（连接游戏玩法、AI、VFX、音频）通过理想路径用例隐式验证；专用集成测试将需要夹具代码文件。
- 引擎专家不可用（未配置引擎）在用例 5 断言中部分覆盖 —— 未配置引擎状态的专用夹具将加强覆盖。
