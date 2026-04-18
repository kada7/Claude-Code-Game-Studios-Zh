# 技能测试规范：/team-level

## 技能摘要

为单个关卡或区域协调完整的关卡设计团队。协调 narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist 和 qa-tester 通过五个顺序步骤和一个并行阶段（步骤 4）。将所有团队输出编译为一份保存到 `design/levels/[level-name].md` 的关卡设计文档。在每一步转换时使用 `AskUserQuestion`。将所有文件写入委托给子代理。生成包含裁决 COMPLETE / BLOCKED 的摘要报告，并交接给 `/design-review`、`/dev-story`、`/qa-plan`。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段/步骤标题（步骤 1 到步骤 5 全部存在）
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 或"文件写入协议" —— 写入委托给子代理，编排器不直接写入文件
- [ ] 在末尾具有下一步交接（引用 `/design-review`、`/dev-story`、`/qa-plan`）
- [ ] 存在包含所有四个恢复步骤的错误恢复协议部分
- [ ] 在步骤转换时使用 `AskUserQuestion` 获取用户批准
- [ ] 步骤 4 被明确标记为并行（art-director 和 accessibility-specialist 同时运行）
- [ ] 上下文收集读取：`design/gdd/game-concept.md`、`design/gdd/game-pillars.md`、`design/levels/`、`design/narrative/` 和相关世界构建文档
- [ ] 团队组成列出所有七个角色（narrative-director、world-builder、level-designer、systems-designer、art-director、accessibility-specialist、qa-tester）
- [ ] accessibility-specialist 输出包含严重等级（BLOCKING / RECOMMENDED / NICE TO HAVE）
- [ ] 最终关卡设计文档保存到 `design/levels/[level-name].md`

---

## 测试用例

### 用例 1：理想路径 —— 所有团队成员生成输出，文档被编译并保存

**测试夹具：**
- `design/gdd/game-concept.md` 存在并已填充
- `design/gdd/game-pillars.md` 存在
- `design/levels/` 目录存在（可能包含其他关卡文档）
- `design/narrative/` 目录存在并包含相关叙事文档

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集 —— 编排器读取 game-concept.md、game-pillars.md、`design/levels/` 中的现有关卡文档、`design/narrative/` 中的叙事文档以及森林区域的世界构建文档
2. 步骤 1 —— 生成 narrative-director：定义叙事目的、关键角色、对话触发器、情感弧线；生成 world-builder：提供背景故事上下文、环境叙事机会、世界规则；`AskUserQuestion` 在步骤 2 开始前确认步骤 1 的输出
3. 步骤 2 —— 生成 level-designer：设计空间布局（关键路径、可选路径、秘密）、节奏曲线、遭遇、谜题、入口/出口点以及与相邻区域的连接；`AskUserQuestion` 在步骤 3 开始前确认布局
4. 步骤 3 —— 生成 systems-designer：指定敌人组成、战利品表、难度平衡、区域特定机制、资源分布；`AskUserQuestion` 在步骤 4 开始前确认系统
5. 步骤 4 —— 并行生成 art-director 和 accessibility-specialist；art-director：视觉主题、调色板、光照、资产列表、VFX 需求；accessibility-specialist：导航清晰度、色盲安全、认知负荷检查 —— 每个顾虑都被评定为 BLOCKING / RECOMMENDED / NICE TO HAVE；`AskUserQuestion` 在步骤 5 前展示两个输出
6. 步骤 5 —— 生成 qa-tester：关键路径的测试用例、边界/边界情况（序列中断、软锁）、游戏测试清单、验收标准
7. 编排器将所有团队输出编译为关卡设计文档格式；子代理被询问"May I write the level design document to `design/levels/forest-dungeon.md`?"；文件保存
8. 摘要报告：区域概述、遭遇数量、估计资产列表、叙事节拍、跨团队依赖关系，裁决：COMPLETE
9. 列出后续步骤：`/design-review design/levels/forest-dungeon.md`、`/dev-story`、`/qa-plan`

**断言：**
- [ ] 在生成任何代理前，上下文收集读取所有五个来源
- [ ] narrative-director 和 world-builder 都在步骤 1 中生成（可以是顺序或并行 —— 两者都必须在步骤 2 前完成）
- [ ] 在每个步骤关卡调用 `AskUserQuestion`（至少：步骤 1 后、步骤 2 后、步骤 3 后、步骤 4 后）
- [ ] 步骤 4 代理（art-director、accessibility-specialist）同时启动
- [ ] 所有文件写入委托给子代理 —— 编排器不直接写入
- [ ] 关卡文档保存到 `design/levels/forest-dungeon.md`（从参数 slug 化）
- [ ] 最终摘要报告中存在裁决 COMPLETE
- [ ] 后续步骤包含 `/design-review`、`/dev-story`、`/qa-plan`
- [ ] 摘要报告包含：区域概述、遭遇数量、估计资产列表、叙事节拍

---

### 用例 2：阻塞的代理（world-builder） —— 生成包含差距记录的部分报告

**测试夹具：**
- `design/gdd/game-concept.md` 存在
- 森林区域的 world-building 文档不存在
- world-builder 代理返回 BLOCKED："未找到森林区域的 world-building 文档 —— 无法提供背景故事上下文"

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 上下文收集完成；记录缺失的 world-building 文档
2. 步骤 1 —— narrative-director 成功完成；生成 world-builder 并返回 BLOCKED
3. 触发错误恢复协议："world-builder：BLOCKED —— 没有森林区域的 world-building 文档"
4. `AskUserQuestion` 提供选项：
   - (a) 跳过 world-builder 并在关卡文档中记录背景故事差距
   - (b) 以更小范围重试（world-builder 仅关注可以从 game-concept.md 推断的内容）
   - (c) 在此处停止并先创建 world-building 文档
5. 如果用户选择 (a)：流水线使用 narrative-director 上下文继续步骤 2–5；关卡文档被编译并带有一个清晰标记的差距部分："World-building context：NOT PROVIDED —— see open dependency"
6. 生成最终报告：记录部分输出，world-builder 部分标记为 BLOCKED，整体裁决：BLOCKED

**断言：**
- [ ] 当 world-builder 失败时，BLOCKED 展示消息立即出现 —— 在用户输入前不会开始步骤 2
- [ ] `AskUserQuestion` 至少提供三个选项（跳过 / 重试 / 停止）
- [ ] 生成部分报告 —— narrative-director 已完成的工作不会被丢弃
- [ ] 关卡文档（如果被编译）包含缺失 world-building 上下文的明确差距标记
- [ ] 当 world-builder 仍未解决时，整体裁决为 BLOCKED（不是 COMPLETE）
- [ ] 技能不会静默编造背景故事内容来填补差距

---

### 用例 3：无参数 —— 展示使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-level`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出使用消息解释所需参数（关卡名称或要设计的区域）
3. 提供示例调用：`/team-level tutorial`、`/team-level forest dungeon`、`/team-level final boss arena`
4. 技能退出而不读取任何项目文件或生成任何子代理

**断言：**
- [ ] 未给出参数时，技能不生成任何子代理
- [ ] 使用消息包含来自前置元数据的 argument-hint 格式
- [ ] 展示了至少一个有效调用的示例
- [ ] 失败前不读取 GDD 或关卡文件
- [ ] 不展示裁决（流水线从未启动）

---

### 用例 4：无障碍审查关卡 —— 阻塞性顾虑在签核前被展示

**测试夹具：**
- 步骤 1–3 成功完成
- `design/accessibility-requirements.md` 提交层级：Enhanced
- accessibility-specialist（步骤 4，并行）标记一个 BLOCKING 顾虑：森林地牢的关键路径要求玩家仅使用颜色区分两种环境危害（有毒水池 vs. 浅水） —— 没有形状、图标或音频提示来区分它们

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 1–3 完成；步骤 4 并行阶段开始
2. accessibility-specialist 返回：BLOCKING 顾虑 —— "Critical path hazard distinction relies on color only (toxic pools vs. shallow water). Shape, icon, or audio cue required per Enhanced accessibility tier."
3. art-director 返回步骤 4 输出（完整）
4. 技能通过 `AskUserQuestion` 展示两个步骤 4 结果 —— BLOCKING 顾虑被突出显示
5. `AskUserQuestion` 提供：
   - (a) 返回 level-designer + art-director 以在进入步骤 5 前重新设计危害视觉/音频语言
   - (b) 记录为已知的无障碍差距并在记录顾虑的情况下进入步骤 5
6. 技能不会静默越过 BLOCKING 顾虑
7. 如果用户选择 (a)：生成 level-designer 和 art-director 修订；重新运行步骤 4 无障碍检查
8. 无论用户选择如何，最终报告都包含 BLOCKING 顾虑及其解决状态

**断言：**
- [ ] BLOCKING 无障碍顾虑不会被当作建议性处理 —— 它被展示为阻塞项
- [ ] `AskUserQuestion` 展示具体的顾虑文本（不仅仅是"发现无障碍问题"）
- [ ] 在用户确认 BLOCKING 顾虑前，步骤 5（qa-tester）不会开始
- [ ] 提供修订路径：level-designer + art-director 可以在继续前被送回
- [ ] 最终报告包含无障碍顾虑及其解决状态
- [ ] 当 accessibility-specialist 阻塞时，art-director 已完成的输出不会被丢弃

---

### 用例 5：循环关卡引用 —— 相邻区域依赖被标记

**测试夹具：**
- 步骤 1–3 正在进行中
- level-designer（步骤 2）生成的布局指定连接到"水晶洞穴"（相邻区域）的入口/出口点
- `design/levels/crystal-caves.md` 不存在 —— 水晶洞穴区域尚未设计

**输入：** `/team-level forest dungeon`

**预期行为：**
1. 步骤 2 —— level-designer 生成包含以下内容的布局："West exit connects to crystal-caves entry point A"
2. 编排器（或 level-designer 子代理）检查 `design/levels/` 中的 `crystal-caves.md`；文件未找到
3. 依赖差距被展示："Level references crystal-caves as an adjacent area but `design/levels/crystal-caves.md` does not exist"
4. `AskUserQuestion` 提供选项：
   - (a) 使用占位符引用继续 —— 在关卡文档中将依赖项记录为 UNRESOLVED
   - (b) 暂停并先运行 `/team-level crystal caves` 以建立该区域
5. 技能不会编造水晶洞穴内容来满足引用
6. 如果用户选择 (a)：关卡文档被编译，西出口标记为"→ crystal-caves (UNRESOLVED —— area not yet designed)"；在摘要报告的开放依赖部分被标记
7. 最终报告包含开放跨关卡依赖部分

**断言：**
- [ ] 技能通过检查 `design/levels/` 检测缺失的相邻区域 —— 不会假设它稍后会创建
- [ ] 技能不会编造水晶洞穴内容（背景故事、布局、连接）来解决引用
- [ ] `AskUserQuestion` 提供"先设计水晶洞穴"选项，引用 `/team-level`
- [ ] 如果用户继续使用占位符，关卡文档明确将西出口标记为 UNRESOLVED
- [ ] 摘要报告包含列出未解决引用的开放跨关卡依赖部分
- [ ] 循环或前向引用不会导致技能循环或崩溃

---

## 协议合规性

- [ ] 在每个步骤转换时使用 `AskUserQuestion` —— 用户批准流水线才能推进
- [ ] 所有文件写入通过 Task 委托给子代理 —— 编排器不直接调用 Write 或 Edit
- [ ] 遵循错误恢复协议：展示 → 评估 → 提供选项 → 部分报告
- [ ] 根据技能规范并行启动步骤 4 代理（art-director、accessibility-specialist）
- [ ] 即使代理被 BLOCKED，也始终生成部分报告
- [ ] 无障碍 BLOCKING 顾虑在签核前被展示并需要明确用户确认
- [ ] 裁决为 COMPLETE / BLOCKED 之一
- [ ] 输出末尾呈现后续步骤：`/design-review`、`/dev-story`、`/qa-plan`

---

## 覆盖说明

- 步骤 1 中的 narrative-director 和 world-builder 可以是顺序或并行的 —— 技能规范生成两者但不要求同时启动；步骤 1 的并行覆盖需要显式的时间断言夹具。
- 阻塞的 world-builder 情况（用例 2）中的"以更小范围重试"选项 —— 重试行为本身未深入测试；其完整路径类似于在其他 team-* 规范中覆盖的阻塞代理模式。
- systems-designer（步骤 3）阻塞场景未单独测试；适用相同的错误恢复协议，该模式通过用例 2 验证。
- 步骤 4 并行顺序（art-director 在 accessibility-specialist 之前或之后完成）不影响结果 —— 两者都必须在步骤 5 前返回，无论顺序如何。
- 关卡文档 slug 约定（参数 → 文件名）通过用例 1 隐式测试（`forest dungeon` → `forest-dungeon.md`）；未覆盖多词 slug 化边界情况（特殊字符、非常长的名称）。
