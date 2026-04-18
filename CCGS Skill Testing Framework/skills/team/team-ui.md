# 技能测试规范：/team-ui

## 技能摘要

为单个 UI 功能通过完整的 UX 流水线协调 UI 团队。协调 ux-designer、ui-programmer、art-director、引擎 UI 专家和 accessibility-specialist 通过五个结构化阶段：上下文收集 + UX 规范（阶段 1a/1b）→ UX 审查关卡（阶段 1c）→ 视觉设计（阶段 2）→ 实现（阶段 3）→ 并行审查（阶段 4）→ 润色（阶段 5）。在每个阶段转换时使用 `AskUserQuestion`。将所有文件写入委托给子代理和子技能（`/ux-design`、`ui-programmer`）。生成包含裁决 COMPLETE / BLOCKED 的摘要报告，并交接给 `/ux-review`、`/code-review`、`/team-polish`。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题（阶段 1a 到阶段 5 全部存在）
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 或"文件写入协议" —— 写入委托给子代理和子技能，编排器不直接写入文件
- [ ] 在末尾具有下一步交接（引用 `/ux-review`、`/code-review`、`/team-polish`）
- [ ] 存在包含所有四个恢复步骤的错误恢复协议部分
- [ ] 在阶段转换时使用 `AskUserQuestion` 获取用户批准
- [ ] 阶段 4 被明确标记为并行（ux-designer、art-director、accessibility-specialist）
- [ ] UX 审查关卡（阶段 1c）被定义为阻塞关卡 —— 没有 APPROVED 裁决，技能不得进入阶段 2
- [ ] 团队组成列出所有五个角色（ux-designer、ui-programmer、art-director、引擎 UI 专家、accessibility-specialist）
- [ ] 引用交互模式库（`design/ux/interaction-patterns.md`） —— ui-programmer 必须使用现有模式
- [ ] 阶段 1a 在设计开始前读取 `design/accessibility-requirements.md`

---

## 测试用例

### 用例 1：理想路径 —— 从 UX 规范到润色的完整流水线成功

**测试夹具：**
- `design/gdd/game-concept.md` 存在并包含平台目标和目标受众
- `design/player-journey.md` 存在
- `design/ux/interaction-patterns.md` 存在并包含相关模式
- `design/accessibility-requirements.md` 存在并包含提交的层级（例如，Enhanced）
- 引擎 UI 专家配置在 `.claude/docs/technical-preferences.md` 中

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a —— 编排器读取 game-concept.md、player-journey.md、相关 GDD UI 部分、interaction-patterns.md、accessibility-requirements.md；为 ux-designer 总结简报
2. 阶段 1b —— 调用 `/ux-design inventory-screen`（或直接生成 ux-designer）；使用 `ux-spec.md` 模板生成 `design/ux/inventory-screen.md`；`AskUserQuestion` 在审查前确认规范
3. 阶段 1c —— 调用 `/ux-review design/ux/inventory-screen.md`；返回 APPROVED；关卡通过，进入阶段 2
4. 阶段 2 —— 生成 art-director；审查完整 UX 规范（不仅仅是线框图）；应用视觉处理；验证颜色对比度；生成包含资产清单的视觉设计规范；`AskUserQuestion` 在阶段 3 前确认
5. 阶段 3 —— 首先生成引擎 UI 专家（从 technical-preferences.md 读取）；为 ui-programmer 生成实现说明；使用 UX 规范 + 视觉规范 + 引擎说明生成 ui-programmer；生成实现；如果引入了新模式，则更新 interaction-patterns.md
6. 阶段 4 —— 并行生成 ux-designer、art-director、accessibility-specialist；所有三个在阶段 5 前返回结果
7. 阶段 5 —— 处理审查反馈；验证动画可跳过；通过音频事件系统确认 UI 声音；interaction-patterns.md 最终检查；裁决：COMPLETE
8. 摘要报告：UX 规范 APPROVED、视觉设计 COMPLETE、实现 COMPLETE、无障碍 COMPLIANT、支持所有输入方法、模式库已更新，裁决：COMPLETE

**断言：**
- [ ] 阶段 1a 在向 ux-designer 简报前读取所有五个来源
- [ ] 在阶段 2 前检查 UX 审查关卡 —— 在 APPROVED 前阶段 2 不会开始
- [ ] 阶段 2 中的 art-director 审查完整规范，不仅仅是线框图图像
- [ ] 引擎 UI 专家在阶段 3 中的 ui-programmer 之前生成
- [ ] 阶段 4 代理同时启动（ux-designer、art-director、accessibility-specialist）
- [ ] 所有文件写入委托给子代理和子技能
- [ ] 最终摘要报告中存在裁决 COMPLETE
- [ ] 后续步骤包含 `/ux-review`、`/code-review`、`/team-polish`

---

### 用例 2：UX 审查关卡 —— 规范未通过审查；技能在进入实现前停止

**测试夹具：**
- `design/ux/inventory-screen.md` 由阶段 1b 生成
- `/ux-review` 返回裁决 NEEDS REVISION 并标记具体问题（例如，手柄导航流不完整，对比度低于最低值）

**输入：** `/team-ui inventory screen`

**预期行为：**
1. 阶段 1a + 1b 完成 —— 生成 UX 规范
2. 阶段 1c —— `/ux-review design/ux/inventory-screen.md` 返回 NEEDS REVISION
3. 技能不会进入阶段 2
4. `AskUserQuestion` 展示具体标记的顾虑和选项：
   - (a) 返回 ux-designer 以解决问题并重新审查
   - (b) 接受风险并继续进入阶段 2（有意识决策）
5. 如果用户选择 (a)：ux-designer 修订规范，重新运行 `/ux-review`；循环继续直到 APPROVED 或用户覆盖
6. 如果用户选择 (b)：技能继续并在最终报告中附上显式的 NEEDS REVISION 注释
7. 技能不会静默越过关卡

**断言：**
- [ ] 当 UX 审查裁决为 NEEDS REVISION 时，阶段 2 不会开始
- [ ] `AskUserQuestion` 在提供选项前展示具体标记的顾虑
- [ ] 用户必须有意识地选择覆盖 —— 技能不会假设覆盖
- [ ] 如果用户接受风险，NEEDS REVISION 顾虑在最终报告中被记录
- [ ] 提供修订和重新审查循环（不仅仅是单次失败）
- [ ] 技能不会在审查失败时丢弃生成的 UX 规范

---

### 用例 3：无参数 —— 展示使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-ui`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用消息解释所需参数（UI 功能描述）
3. 提供一个示例调用：`/team-ui [UI feature description]`
4. 技能退出而不生成任何子代理或读取任何项目文件

**断言：**
- [ ] 未给出参数时，技能不生成任何子代理
- [ ] 使用消息包含来自前置元数据的 argument-hint 格式
- [ ] 展示了至少一个有效调用的示例
- [ ] 失败前不读取 UX 规范文件或 GDD
- [ ] 不展示裁决（流水线从未启动）

---

### 用例 4：无障碍并行审查 —— 阶段 4 同时运行三个流

**测试夹具：**
- `design/ux/inventory-screen.md` 存在（APPROVED）
- 视觉设计规范完整
- 实现完整
- `design/accessibility-requirements.md` 提交层级：Enhanced

**输入：** `/team-ui inventory screen`（从阶段 3 完成后恢复）

**预期行为：**
1. 阶段 4 在实现被确认完成后开始
2. 同时发出三个 Task 调用：ux-designer、art-director、accessibility-specialist
3. 每个流独立运行：
   - ux-designer：验证实现是否符合线框图，测试仅键盘和仅手柄导航，检查无障碍功能
   - art-director：验证与美术圣经在最小和最大支持分辨率下的视觉一致性
   - accessibility-specialist：根据 `design/accessibility-requirements.md` 中的 Enhanced 无障碍层级进行审计；任何违规都被标记为阻塞项
4. 技能在阶段 5 开始前等候所有三个结果
5. `AskUserQuestion` 在阶段 5 开始前展示所有三个审查结果

**断言：**
- [ ] 在等候任何结果前发出所有三个 Task 调用（并行，不是顺序）
- [ ] 阶段 5 直到所有三个阶段 4 代理都已返回后才开始
- [ ] accessibility-specialist 明确读取 `design/accessibility-requirements.md` 以获取提交的层级
- [ ] 无障碍违规被标记为 BLOCKING（不仅仅是建议性）
- [ ] `AskUserQuestion` 在阶段 5 批准前一起展示所有三个审查流的结果
- [ ] 阶段 4 代理的输出不会被用作另一个阶段 4 代理的输入

---

### 用例 5：缺少交互模式库 —— 技能记录差距而非发明模式

**测试夹具：**
- `design/ux/interaction-patterns.md` 不存在
- 所有其他必需文件存在

**输入：** `/team-ui settings menu`

**预期行为：**
1. 阶段 1a —— 编排器尝试读取 `design/ux/interaction-patterns.md`；文件未找到
2. 技能展示差距："interaction-patterns.md does not exist —— no existing patterns to reuse"
3. `AskUserQuestion` 提供选项：
   - (a) 先运行 `/ux-design patterns` 以建立模式库，然后继续
   - (b) 在没有模式库的情况下继续 —— ux-designer 将在创建时记录新模式
4. 技能不会从其他来源发明或假设模式
5. 如果用户选择 (b)：ui-programmer 被明确指示将所有创建的模式视为新模式，并在完成时将每个模式添加到新的 `design/ux/interaction-patterns.md`
6. 最终报告记录 interaction-patterns.md 被创建（如果用户跳过则仍为缺失）

**断言：**
- [ ] 技能不会静默忽略缺失的模式库
- [ ] 技能不会仅通过功能名称或 GDD 来猜测发明模式
- [ ] `AskUserQuestion` 提供"先创建模式库"选项（引用 `/ux-design patterns`）
- [ ] 如果用户在没有库的情况下继续，ui-programmer 被告知将所有模式视为新模式
- [ ] 最终报告记录模式库状态（已创建 / 缺失 / 已更新）
- [ ] 技能不会完全失败 —— 差距被记录并向用户提供选择

---

## 协议合规性

- [ ] 在每个阶段转换时使用 `AskUserQuestion` —— 用户批准流水线才能推进
- [ ] UX 审查关卡（阶段 1c）是阻塞性的 —— 没有 APPROVED 或显式用户覆盖，阶段 2 无法开始
- [ ] 所有文件写入委托给子代理和子技能 —— 编排器不直接调用 Write 或 Edit
- [ ] 根据技能规范并行启动阶段 4 代理
- [ ] 遵循错误恢复协议：展示 → 评估 → 提供选项 → 部分报告
- [ ] 即使代理被 BLOCKED，也始终生成部分报告
- [ ] 裁决为 COMPLETE / BLOCKED 之一
- [ ] 输出末尾呈现后续步骤：`/ux-review`、`/code-review`、`/team-polish`

---

## 覆盖说明

- HUD 特定路径（`/ux-design hud` + `hud-design.md` 模板 + 阶段 5 中的视觉预算检查）未在此处单独测试；它共享相同的阶段结构但使用不同的模板。
- interaction-patterns.md 的"就地更新"路径（实现期间添加新模式）通过用例 1 步骤 5 隐式实践 —— 具有已知新模式的专用夹具将加强覆盖。
- 引擎 UI 专家不可用（未配置引擎） —— 技能规范声明"如果未配置引擎则跳过"；此路径在用例 1 中断言但未获得专用夹具。
- NEEDS REVISION 接受风险覆盖（用例 2 选项 b）要求覆盖在报告中明确记录；此断言但未进一步测试下游影响。
