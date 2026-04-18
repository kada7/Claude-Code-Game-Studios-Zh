# 技能测试规范: /create-architecture

## 技能概述

`/create-architecture` 引导用户逐节编写技术架构文档。它采用骨架优先的方法——文件在填充任何内容之前先创建所有必需的章节标题。每个章节经过讨论、草拟，并在用户批准后单独编写。如果架构文档已存在，该技能提供改造模式以更新特定章节。

在 `full` 评审模式下，TD-ARCHITECTURE（技术总监）和 LP-FEASIBILITY（首席程序员）在完整草稿完成后生成。在 `lean` 或 `solo` 模式下，两个关卡都会被跳过。该技能写入 `docs/architecture/architecture.md`。

---

## 静态断言（结构性的）

由 `/skill-test static` 自动验证——无需测试夹具。

- [ ] 具有必需的前言字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 包含 "May I write" 协作协议语言（每章节批准）
- [ ] 在末尾有下一步交接（`/architecture-review` 或 `/create-control-manifest`）
- [ ] 记录骨架优先方法
- [ ] 记录关卡行为：在完整模式下 TD-ARCHITECTURE + LP-FEASIBILITY；在 lean/solo 模式下跳过
- [ ] 记录现有架构文档的改造模式

---

## 总监关卡检查

在 `full` 模式下：TD-ARCHITECTURE（技术总监）和 LP-FEASIBILITY（首席程序员）在所有章节草拟完成后、任何最终批准写入之前并行生成。

在 `lean` 模式下：两个关卡都被跳过。输出注释：
"TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：两个关卡都被跳过，并带有等效注释。

---

## 测试用例

### 用例 1: 正常路径 —— 新建架构文档，骨架优先，完整模式下关卡批准

**测试夹具:**
- 不存在现有的 `docs/architecture/architecture.md`
- `docs/architecture/` 包含已接受的 ADR 供参考
- `production/session-state/review-mode.txt` 包含 `full`

**输入:** `/create-architecture`

**预期行为:**
1. 技能创建骨架 `docs/architecture/architecture.md`，包含所有必需的章节标题
2. 对于每个章节：草拟内容，显示草稿，询问 "May I write [section]?"，批准后写入
3. 所有章节草拟完成后：TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成
4. 两个关卡都返回 APPROVED
5. 最终询问 "May I confirm architecture is complete?"
6. 会话状态更新

**断言:**
- [ ] 骨架文件在所有内容写入之前创建，包含所有章节标题
- [ ] 在编写过程中每个章节都询问 "May I write [section]?"
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成（非顺序）
- [ ] 两个关卡在最终完成确认之前完成
- [ ] 当两个关卡都返回 APPROVED 时，裁决为 APPROVED
- [ ] 存在下一步交接到 `/architecture-review` 或 `/create-control-manifest`

---

### 用例 2: 失败路径 —— TD-ARCHITECTURE 返回 MAJOR REVISION

**测试夹具:**
- 架构文档已完全草拟（所有章节）
- `production/session-state/review-mode.txt` 包含 `full`
- TD-ARCHITECTURE 关卡返回 MAJOR REVISION："[specific structural issue]"

**输入:** `/create-architecture`

**预期行为:**
1. 所有章节草拟并写入
2. TD-ARCHITECTURE 关卡运行并返回 MAJOR REVISION 及具体反馈
3. 技能向用户展示反馈
4. 架构未标记为最终版
5. 询问用户：修订标记的章节，或将文档接受为草稿

**断言:**
- [ ] 当 TD-ARCHITECTURE 返回 MAJOR REVISION 时，架构未标记为最终版
- [ ] 关卡反馈显示给用户，包含具体问题描述
- [ ] 用户获得修订特定章节的选项
- [ ] 尽管有 MAJOR REVISION 反馈，技能不会自动最终化

---

### 用例 3: Lean 模式 —— 两个关卡都被跳过；仅凭用户批准写入架构

**测试夹具:**
- 不存在现有的架构文档
- `production/session-state/review-mode.txt` 包含 `lean`

**输入:** `/create-architecture`

**预期行为:**
1. 创建骨架文件
2. 所有章节在用户批准下逐章节编写
3. 完成后：TD-ARCHITECTURE 和 LP-FEASIBILITY 被跳过
4. 输出注释："TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"
5. 仅基于用户批准，架构被视为完成

**断言:**
- [ ] 两个关卡跳过注释出现在输出中
- [ ] 在 lean 模式下，架构文档仅凭用户批准写入
- [ ] 技能不会因为关卡被跳过而阻塞完成
- [ ] 仍然存在下一步交接

---

### 用例 4: 改造模式 —— 现有架构文档，用户更新一个章节

**测试夹具:**
- `docs/architecture/architecture.md` 已存在，所有章节已填充

**输入:** `/create-architecture`

**预期行为:**
1. 技能检测到现有架构文档并读取其当前内容
2. 技能提供改造模式："Architecture doc already exists. Which section would you like to update?"
3. 用户选择一个章节
4. 技能仅编写该章节，询问 "May I write [section]?"
5. 仅更新选定的章节——其他章节保持不变

**断言:**
- [ ] 技能在提供改造选项之前检测并读取现有架构文档
- [ ] 询问用户要更新哪个章节——不要求重写整个文档
- [ ] 仅更新选定的章节
- [ ] 在改造会话期间，其他章节未被修改

---

### 用例 5: 总监关卡 —— 架构引用 Proposed ADR；标记为风险

**测试夹具:**
- 架构文档正在编写中
- 一个章节引用或依赖于状态为 `Status: Proposed` 的 ADR
- `production/session-state/review-mode.txt` 包含 `full`

**输入:** `/create-architecture`

**预期行为:**
1. 技能编写所有章节
2. 在编写过程中，技能检测到对 Proposed ADR 的引用
3. 技能标记："Note: [section] references ADR-NNN which is Proposed — this is a risk until the ADR is accepted"
4. 风险标记嵌入到相关章节的内容中
5. TD-ARCHITECTURE 和 LP-FEASIBILITY 仍然运行——它们被告知 Proposed ADR 风险

**断言:**
- [ ] 在章节编写过程中检测到 Proposed ADR 引用并进行标记
- [ ] 风险注释嵌入到架构文档章节中
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 仍然生成（风险不会阻塞关卡）
- [ ] 风险标记命名了特定的 ADR 编号和标题

---

## 协议合规性

- [ ] 骨架文件在所有内容写入之前创建，包含所有章节标题
- [ ] 在编写过程中每个章节都询问 "May I write [section]?"
- [ ] 在完整模式下 TD-ARCHITECTURE 和 LP-FEASIBILITY 并行生成
- [ ] 跳过的关卡在 lean/solo 输出中按名称和模式注明
- [ ] Proposed ADR 引用在文档中标记为风险
- [ ] 以下一步交接结束：`/architecture-review` 或 `/create-control-manifest`

---

## 覆盖范围说明

- 架构文档所需的章节列表在技能主体和 `/architecture-review` 技能中定义——此处不再重新枚举。
- 架构文档中的引擎版本标记（与 ADR 标记并行）是编写工作流的一部分——通过用例 1 隐式测试。
- 在一次会话中更新多个章节的改造模式遵循相同的每章节批准模式——未对多章节改造进行独立测试。