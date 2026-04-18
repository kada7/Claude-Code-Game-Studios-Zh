# 技能测试规范：/team-polish

## 技能摘要

通过一个六阶段流水线协调润色团队：性能评估（performance-analyst）→ 优化（performance-analyst，当发现引擎级根本原因时可选与 engine-programmer 协作）→ 视觉润色（technical-artist，与阶段 2 并行）→ 音频润色（sound-designer，与阶段 2 并行）→ 加固（qa-tester）→ 签核（编排器收集所有结果并发出 READY FOR RELEASE 或 NEEDS MORE WORK）。在每个阶段转换时使用 `AskUserQuestion`。仅在阶段 1 识别出引擎级根本原因时才条件生成 engine-programmer。裁决为 READY FOR RELEASE 或 NEEDS MORE WORK。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：READY FOR RELEASE、NEEDS MORE WORK
- [ ] 包含"文件写入协议"部分
- [ ] 文件写入被委托给子代理 —— 编排器不直接写入文件
- [ ] 子代理在任何写入前强制执行"May I write to [path]?"
- [ ] 在末尾具有下一步交接（引用 `/release-checklist`、`/sprint-plan update`、`/gate-check`）
- [ ] 存在错误恢复协议部分
- [ ] 在阶段转换前使用 `AskUserQuestion`
- [ ] 阶段 3（视觉润色）和阶段 4（音频润色）被明确与阶段 2 并行运行
- [ ] 仅在阶段 1 识别出引擎级根本原因时，才在阶段 2 中条件生成 engine-programmer
- [ ] 阶段 6 签核在发出裁决前将指标与预算进行比较

---

## 测试用例

### 用例 1：理想路径 —— 完整流水线完成，READY FOR RELEASE 裁决

**测试夹具：**
- 功能存在且功能完整（例如，`combat` 系统）
- 性能预算在 technical-preferences.md 中定义（例如，目标 60fps，16ms 帧预算）
- 润色开始前不存在帧预算违规
- 不存在缺失的音频事件；VFX 资产完整
- 润色变更未引入任何回归

**输入：** `/team-polish combat`

**预期行为：**
1. 阶段 1：生成 performance-analyst；分析 combat 系统性能，测量帧预算，检查内存使用；输出：显示所有指标在预算内、无违规的性能报告
2. `AskUserQuestion` 展示性能报告；用户在阶段 2、3 和 4 开始前批准
3. 阶段 2：performance-analyst 应用 minor 优化（例如，绘制调用批处理）；不需要 engine-programmer（未识别出引擎级根本原因）
4. 阶段 3 和 4 与阶段 2 并行启动：
   - 阶段 3：technical-artist 审查 VFX 质量，优化粒子系统，添加屏幕震动和视觉表现
   - 阶段 4：sound-designer 审查音频事件完整性，检查混音电平，添加环境音频层
5. 所有三个并行阶段完成；`AskUserQuestion` 展示结果；用户在阶段 5 开始前批准
6. 阶段 5：qa-tester 运行边界情况测试、浸泡测试、压力测试和回归测试；全部通过
7. `AskUserQuestion` 展示测试结果；用户在阶段 6 前批准
8. 阶段 6：编排器收集所有结果；将优化前后的性能指标与预算进行比较；所有指标通过
9. 子代理在写入前询问"May I write the polish report to `production/qa/evidence/polish-combat-[date].md`?"
10. 裁决：READY FOR RELEASE

**断言：**
- [ ] performance-analyst 在阶段 1 中在任何其他代理之前首先生成
- [ ] `AskUserQuestion` 出现在阶段 1 输出之后和阶段 2/3/4 启动之前
- [ ] 阶段 3 和 4 的 Task 调用与阶段 2 同时发出（不是在阶段 2 完成后）
- [ ] 当阶段 1 未发现引擎级根本原因时，不生成 engine-programmer
- [ ] qa-tester（阶段 5）直到并行阶段完成且用户批准后才启动
- [ ] 阶段 6 裁决基于指标与定义预算的比较
- [ ] 摘要报告包含：优化前后性能指标、视觉润色变更、音频润色变更、测试结果
- [ ] 编排器不直接写入任何文件
- [ ] 裁决为 READY FOR RELEASE

---

### 用例 2：性能阻塞项 —— 帧预算违规无法完全解决

**测试夹具：**
- 正在润色的功能：`particle-storm` VFX 系统
- 阶段 1 识别出帧预算违规：particle-storm 在目标硬件上消耗 12ms（该系统预算为 6ms）
- 阶段 2 performance-analyst 应用优化将消耗降至 9ms —— 仍超过 6ms 预算
- 阶段 2 无法在不进行根本性设计变更的情况下完全解决违规

**输入：** `/team-polish particle-storm`

**预期行为：**
1. 阶段 1：performance-analyst 识别出 12ms 帧消耗 vs. 6ms 预算；报告"FRAME BUDGET VIOLATION：particle-storm 消耗 12ms，预算为 6ms"
2. `AskUserQuestion` 展示违规；用户选择尝试优化
3. 阶段 2：performance-analyst 应用优化；达到 9ms —— 减少但仍超出预算；报告"优化将消耗降至 9ms（原为 12ms）—— 超出预算 3ms。不进行设计变更就无法进一步获得收益。"
4. 阶段 3 和 4 与阶段 2 并行运行（视觉和音频润色）
5. 阶段 5：qa-tester 运行回归和边界情况测试；全部通过
6. 阶段 6：编排器收集结果；帧预算违规（9ms vs. 6ms 预算）仍未解决
7. 裁决：NEEDS MORE WORK
8. 报告列出具体的未解决问题："particle-storm 帧消耗（9ms）超出预算（6ms）3ms —— 需要设计范围缩减或预算重新协商"
9. 后续步骤：在 `/sprint-plan update` 中安排剩余问题；修复后重新运行 `/team-polish`

**断言：**
- [ ] 帧预算违规在阶段 1 中被标记并包含具体数字（实际 vs. 预算）
- [ ] 阶段 2 明确报告优化后的指标（达到 9ms，仍超出 3ms）
- [ ] 当预算违规仍然存在时，裁决为 NEEDS MORE WORK（不是 READY FOR RELEASE）
- [ ] 具体的未解决问题按名称列出，剩余差距被量化
- [ ] 后续步骤引用 `/sprint-plan update` 来安排剩余修复
- [ ] 阶段 3 和 4 仍然运行（润色工作不会因阶段 2 的部分解决而放弃）
- [ ] 阶段 5 qa-tester 仍然运行（回归测试独立于性能结果）

---

### 用例 3：无参数 —— 展示使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-polish`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用指南：例如，"用法：`/team-polish [feature or area]` —— 指定要润色的功能或区域（例如，`combat`、`main menu`、`inventory system`、`level-1`）"
3. 技能退出而不生成任何代理

**断言：**
- [ ] 未提供参数时，技能不生成任何代理
- [ ] 使用消息包含带参数示例的正确调用格式
- [ ] 技能不会尝试从项目文件猜测功能
- [ ] 不使用 `AskUserQuestion` —— 输出是直接指导

---

### 用例 4：引擎级瓶颈 —— 在阶段 2 中条件生成 engine-programmer

**测试夹具：**
- 正在润色的功能：`open-world` 环境流送
- 阶段 1 识别出性能瓶颈，其根本原因在渲染管线中："绘制调用开销是由引擎的空间索引器中的场景树遍历引起的 —— 这是一个引擎级问题，不是游戏代码问题"
- 性能预算已定义；渲染开销超过目标帧预算

**输入：** `/team-polish open-world`

**预期行为：**
1. 阶段 1：performance-analyst 分析环境；识别帧预算违规；根本原因分析指向引擎级渲染管线（空间索引器遍历开销）
2. 阶段 1 输出明确将根本原因分类为引擎级
3. `AskUserQuestion` 展示包含引擎级根本原因的性能报告；用户在阶段 2 前批准
4. 阶段 2：为游戏代码级优化生成 performance-analyst，并为引擎级渲染修复并行生成 engine-programmer
5. 阶段 3 和 4 也与阶段 2 并行运行（视觉和音频润色）
6. engine-programmer 处理空间索引器遍历；提供显示修复减少开销的剖析器验证
7. 阶段 5：qa-tester 运行回归测试，包含针对引擎级修复的测试
8. 阶段 6：编排器收集所有结果；如果指标现在在预算内，裁决为 READY FOR RELEASE；如果不是，NEEDS MORE WORK

**断言：**
- [ ] 除非阶段 1 明确识别出引擎级根本原因，否则在阶段 2 中不生成 engine-programmer
- [ ] 当阶段 1 识别出引擎级根本原因时，在阶段 2 中生成 engine-programmer
- [ ] 阶段 2 中的 engine-programmer 和 performance-analyst Task 调用同时发出（不是顺序的）
- [ ] 阶段 3 和 4 也与阶段 2 并行运行（不是推迟到阶段 2 完成后）
- [ ] engine-programmer 的输出包含修复的剖析器验证
- [ ] 阶段 5 中的 qa-tester 运行覆盖引擎级变更的回归测试
- [ ] 裁决正确反映所有指标（包括引擎修复）现在是否满足预算

---

### 用例 5：发现回归 —— 润色变更破坏了现有功能

**测试夹具：**
- 正在润色的功能：`inventory-ui`
- 阶段 1–4 成功完成；性能和润色变更已应用
- 阶段 5：qa-tester 运行回归测试并发现 technical-artist 在阶段 3 中应用的着色器优化破坏了悬停时的物品高亮发光效果 —— 这是润色前正常工作的现有功能

**输入：** `/team-polish inventory-ui`（阶段 5 场景）

**预期行为：**
1. 阶段 1–4 完成；润色变更包含来自 technical-artist 的着色器优化
2. 阶段 5：qa-tester 运行回归测试并检测到"Item highlight glow on hover no longer renders —— regression introduced by shader optimization in Phase 3"
3. qa-tester 返回包含标记回归的测试结果
4. 编排器立即展示回归："qa-tester：REGRESSION FOUND —— `item-highlight-hover` glow broken by Phase 3 shader optimization"
5. 子代理提交错误报告，在写入前询问"May I write the bug report to `production/qa/evidence/bug-polish-inventory-ui-[date].md`?"
6. 批准后写入错误报告；包含：破坏的行为、导致它的润色变更、复现步骤和严重等级
7. `AskUserQuestion` 展示回归并提供选项：
   - 回滚着色器优化并寻找替代方法
   - 修复着色器优化以保留发光效果
   - 接受回归并在下一个 Sprint 中安排修复
8. 裁决：NEEDS MORE WORK（无论用户选择的解决路径如何，回归都存在，除非在当前会话中应用修复）

**断言：**
- [ ] 回归在阶段 6 签核前被展示
- [ ] 具体的破坏行为和负责的变更都在报告中被命名
- [ ] 子代理在提交前询问"May I write the bug report to [path]?"
- [ ] 错误报告包含：破坏的行为、因果变更、复现步骤、严重等级
- [ ] `AskUserQuestion` 提供包括回滚、就地修复和稍后安排的选项
- [ ] 当回归存在且未解决时，裁决为 NEEDS MORE WORK
- [ ] 只有在当前润色会话中修复回归且 qa-tester 重新运行确认后，裁决才可能变为 READY FOR RELEASE

---

## 协议合规性

- [ ] 阶段 1（评估）必须在任何其他阶段开始前完成
- [ ] 在每个阶段输出后使用 `AskUserQuestion`，在下一阶段启动前
- [ ] 阶段 3 和 4 始终与阶段 2 并行启动（不是推迟）
- [ ] 仅在阶段 1 明确识别出引擎级根本原因时才生成 engine-programmer
- [ ] 编排器不直接写入任何文件 —— 所有写入都委托给子代理
- [ ] 每个子代理在任何写入前强制执行"May I write to [path]?"协议
- [ ] 任何代理的 BLOCKED 状态立即被展示 —— 不是静默跳过
- [ ] 当某些代理完成而其他代理阻塞时，始终生成部分报告
- [ ] 裁决严格为 READY FOR RELEASE 或 NEEDS MORE WORK —— 不使用其他裁决值
- [ ] NEEDS MORE WORK 裁决始终列出带有严重等级的具体剩余问题
- [ ] 后续步骤交接引用 `/release-checklist`（成功时）和 `/sprint-plan update` + `/gate-check`（失败时）

---

## 覆盖说明

- tools-programmer 可选代理（用于内容管线工具验证）未单独测试 —— 它遵循与 engine-programmer 相同的条件生成模式，仅在涉及内容创作工具的润色区域被调用。
- 错误恢复协议中的"以更小范围重试"和"跳过此代理"解决路径未单独测试 —— 它们遵循在用例 2 和 5 中验证的相同 `AskUserQuestion` + 部分报告模式。
- 阶段 6 签核逻辑（收集和比较所有指标）通过用例 1 和 2 隐式验证。READY FOR RELEASE 和 NEEDS MORE WORK 之间的区别在这两个用例中都被实践。
- 浸泡测试和压力测试（阶段 5）通过用例 1 的 qa-tester 输出隐式验证。用例 5 关注阶段 5 的回归检测方面。
- 阶段 5 中的"最低规格硬件"测试路径未单独测试 —— 当硬件可用时，它遵循相同的 qa-tester 委托模式。
