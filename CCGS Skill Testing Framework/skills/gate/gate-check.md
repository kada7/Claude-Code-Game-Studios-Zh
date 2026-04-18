# Skill Test Spec: /gate-check

## 技能摘要

`/gate-check` 验证项目是否准备好进入下一开发阶段。它检查必需的工件、运行质量检查、询问用户关于无法验证的项目，并产生 PASS/CONCERNS/FAIL 判定。在获得用户确认的 PASS 情况下，它将新阶段名称写入 `production/stage.txt`。它管理所有6个阶段转换，是流水线中最关键的关卡守卫技能。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——无需 Fixture。

- [ ] 具有必需的前言字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有≥2个阶段标题（编号 Phase N 或 ## 部分）
- [ ] 包含判定关键词：PASS、CONCERNS、FAIL
- [ ] 包含“我可以写入”协作协议语言
- [ ] 末尾有下一步交接（后续行动部分）

---

## 测试用例

### 用例 1：Happy Path —— 所有概念工件存在，推进到系统设计阶段

**Fixture:**
- `design/gdd/game-concept.md` 存在，包含所有必需部分的内容
- `design/gdd/game-pillars.md` 存在（或将支柱定义在概念文档内）
- 尚无系统索引（此阶段正确）

**输入:** `/gate-check systems-design`

**预期行为:**
1. 技能读取 `design/gdd/game-concept.md` 并验证其具有内容
2. 技能检查游戏支柱（在概念文档或单独文件中）
3. 技能检查质量项目（核心循环已描述，目标受众已识别）
4. 技能输出结构化清单，所有项目已标记
5. 技能呈现 PASS/CONCERNS/FAIL 判定
6. 如果 PASS：技能询问“我可以将 `production/stage.txt` 更新为 'Systems Design' 吗？”

**断言:**
- [ ] 技能在标记为已检查前使用 Glob 或 Read 来验证 `design/gdd/game-concept.md` 存在
- [ ] 输出包含“必需工件”部分，每个项目有检查状态
- [ ] 输出包含“质量检查”部分，每个项目有检查状态
.

**断言（续）:**
   - [ ] 输出包含“判定”行，内容为 PASS / CONCERNS / FAIL 之一
   - [ ] 技能询问无法验证的质量项目（例如，“是否已评审过？”）而非直接假定 PASS
   - [ ] 在更新 `production/stage.txt` 前询问“我可以写入”
   - [ ] 未经明确用户确认，技能不写入 `production/stage.txt`

---

### 用例 2：失败路径 —— 概念→系统设计阶段缺少必需工件

**Fixture:**
- `design/gdd/game-concept.md` 不存在
- 无游戏支柱文档存在
- `design/gdd/` 目录为空或不存在

**输入:** `/gate-check systems-design`

**预期行为:**
1. 技能尝试读取 `design/gdd/game-concept.md` —— 文件未找到
2. 技能将必需工件标记为缺失（不存在）
3. 技能输出 FAIL 判定
4. 技能列出阻塞项：“未找到游戏概念文档”
5. 技能建议修复措施：运行 `/brainstorm` 以创建

**断言:**
- [ ] 当必需工件缺失时判定为 FAIL（非 PASS 或 CONCERNS）
- [ ] 输出明确命名 `design/gdd/game-concept.md` 为缺失
- [ ] 输出包含“阻塞项”部分，至少一项
- [ ] 输出推荐 `/brainstorm` 作为修复措施
- [ ] 当判定为 FAIL 时技能不写入 `production/stage.txt`

---

### 用例 3：无参数 —— 自动检测当前阶段

**Fixture:**
- `production/stage.txt` 包含 `Concept`
- `design/gdd/game-concept.md` 存在且具有内容
- 尚无系统索引

**输入:** `/gate-check` （无参数）

**预期行为:**
1. 技能读取 `production/stage.txt` 以确定当前阶段
2. 技能确定下一个关卡是概念→系统设计
3. 技能继续进行系统设计关卡检查
4. 输出清晰说明正在验证哪个转换

**断言:**
- [ ] 技能读取 `production/stage.txt`（或使用项目阶段检测启发式方法）来确定当前阶段
- [ ] 输出头部命名当前和目标阶段（例如，“关卡检查：概念 → 系统设计”）
- [ ] 如果当前阶段可确定，技能不询问用户检查哪个关卡

---

### 用例 4：边缘案例 —— 手动检查项目被正确标记

**Fixture:**
- 概念→系统设计所需的所有必需工件都存在
- 无试玩或评审记录存在（无法自动验证质量检查）

**输入:** `/gate-check systems-design`

**预期行为:**
1. 技能验证所有工件事物文件存在
2. 技能遇到质量检查：“游戏概念已评审（非 MAJOR REVISION NEEDED）”
3. 由于无评审记录存在，技能将项目标记为需要手动检查
4. 技能询问用户：“游戏概念是否已进行设计质量评审？”
5. 技能在最终判定前等待用户输入

**断言:**
- [ ] 无法自动验证的项目被标记为 `[?] 需要手动检查` 而非假定为 PASS
If the skill uses a different marking format (e.g., [?], MANUAL CHECK REQUIRED, etc.), adapt accordingly.

**断言（续）:**
   - [ ] 技能对至少一个无法验证的质量项目向用户提问
   - [ ] 技能不将无法验证的项目默认标记为 PASS

---

### 用例 5：导演关卡 —— 精简模式 vs 完全模式 vs 单人模式

**Fixture:**
- `production/session-state/review-mode.txt` 存在（或等效的状态文件）
- 目标关卡的所有必需工件都存在
- `design/gdd/game-concept.md` 存在

**用例 5a — 完全模式:**
- `review-mode.txt` 包含 `full`

**输入:** `/gate-check systems-design` （完全模式激活）

**预期行为:**
1. 技能读取评审模式——确定为 `full`
2. 技能并行生成所有4个阶段关卡导演提示：
   - CD-PHASE-GATE（创意总监）
   - TD-PHASE-GATE（技术总监）
   - PR-PHASE-GATE（制作人）
   - AD-PHASE-GATE（美术总监）
3. 如果一个导演返回 CONCERNS → 整体关卡判定至少为 CONCERNS
4. 在产生最终输出前收集所有4个判定

**断言 (5a):**
- [ ] 技能在决定生成哪些导演前读取评审模式
- [ ] 所有4个阶段关卡导演提示都已生成（非仅1或2个）
- [ ] 导演并行生成（同时，非顺序）
- [ ] 任一导演的 CONCERNS 判定会传播到整体判定
- [ ] 如果任一导演返回 CONCERNS 或 REJECT，判定不会自动通过

**用例 5b — 单人模式:**
- `review-mode.txt` 包含 `solo`

**输入:** `/gate-check systems-design` （单人模式激活）

**预期行为:**
1. 技能读取评审模式——确定为 `solo`
2. 每个导演被注明已跳过：“[CD-PHASE-GATE] 已跳过 —— 单人模式”
3. 关卡判定仅基于工件/质量检查得出
4. 无导演关卡生成

**断言 (5b):**
- [ ] 单人模式下无导演关卡生成
- [ ] 每个跳过的关卡在输出中明确注明：“[关卡ID] 已跳过 —— 单人模式”
- [ ] 判定仅基于工件和质量检查

**关于用例 3 的纠正说明:**
用例 3 的断言先前说明“如果当前阶段可确定，技能不询问用户检查哪个关卡”。这是正确的。然而，技能 DO 在运行完整检查前使用 AskUserQuestion 来确认自动检测的转换——这是一个确认步骤，而非关卡选择。用例 3 的断言不应将此确认视为失败。

---

## 协议合规性

- [ ] 在更新 `production/stage.txt` 前使用“我可以写入”
- [ ] 在请求写入批准前呈现完整清单报告
- [ ] 以“后续行动”部分结束，根据判定列出后续步骤
- [ ] 未经明确用户确认绝不推进阶段
- [ ] 未经询问绝不自动创建 `production/stage.txt`（如果不存在）

---

## 覆盖范围说明

- 生产→润色和润色→发布关卡在此未覆盖，因为它们需要复杂的多工件设置（冲刺计划、试玩数据、QA 签署）；这些被推迟到专门的后续规范中。
- “CONCERNS”判定路径（轻微差距，非阻塞性）在此未明确测试；它介于用例 1 和用例 2 之间，并遵循相同的模式。
- 垂直切片验证块（预生产→生产关卡）未覆盖，因为它需要一个可玩构建的上下文，无法以文档 Fixture 表示。