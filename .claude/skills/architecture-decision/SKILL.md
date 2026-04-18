---
name: architecture-decision
description: "创建架构决策记录(ADR)，记录重大技术决策、其背景、考虑的替代方案及后果。每个重大技术选择都应有ADR。"
argument-hint: "[title] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task, AskUserQuestion
---

当此 Skill 被调用时：

## 0. 解析参数 — 检测 Retrofit 模式

解析审查模式（仅解析一次，在本次运行的所有 gate 生成中复用）：
1. 如果传入了 `--review [full|lean|solo]` → 使用该值
2. 否则读取 `production/review-mode.txt` → 使用该值
3. 否则 → 默认使用 `lean`

完整的检查模式请参阅 `.claude/docs/director-gates.md`。

**如果参数以 `retrofit` 开头，后跟一个文件路径**
（例如 `/architecture-decision retrofit docs/architecture/adr-0001-event-system.md`）：

进入 **retrofit 模式**：

1. 完整读取现有 ADR 文件。
2. 通过扫描标题识别哪些模板章节已存在：
   - `## Status` — **缺失则阻塞**：`/story-readiness` 无法检查 ADR 验收状态
   - `## ADR Dependencies` — 缺失则高风险：依赖排序会中断
   - `## Engine Compatibility` — 缺失则高风险：截止日后的风险未知
   - `## GDD Requirements Addressed` — 缺失则中风险：可追溯性丢失
3. 向用户展示：
   ```
   ## Retrofit: [ADR 标题]
   File: [path]

   已存在的章节（不会被修改）：
   ✓ Status: [当前值，或 "缺失 — 将添加"]
   ✓ [section]

   待添加的缺失章节：
   ✗ Status — BLOCKING（stories 无法在没有此字段的情况下验证 ADR 验收状态）
   ✗ ADR Dependencies — HIGH
   ✗ Engine Compatibility — HIGH
   ```
4. 询问："是否添加这 [N] 个缺失章节？我不会修改任何现有内容。"
5. 如果同意：
   - 对于 **Status**：询问用户 — "此决策的当前状态是什么？"
     选项："Proposed"、"Accepted"、"Deprecated"、"Superseded by ADR-XXXX"
   - 对于 **ADR Dependencies**：询问 — "此决策是否依赖于其他 ADR？
     它是否启用或阻塞了其他 ADR 或 epic？" 每个字段均可接受 "None"。
   - 对于 **Engine Compatibility**：读取引擎参考文档（与下方 Step 0 相同）
     并请用户确认领域。然后生成带有已验证数据的表格。
   - 对于 **GDD Requirements Addressed**：询问 — "哪些 GDD 系统推动了此决策？
     此 ADR 解决了每个 GDD 中的哪些具体需求？"
   - 使用 Edit 工具将每个缺失章节追加到 ADR 文件末尾。
   - **绝不修改任何现有章节。** 仅追加或填充缺失的章节。
6. 添加完所有缺失章节后，如果 ADR 的 `## Date` 字段缺失，则更新它。
7. 建议："现在此 ADR 已具备 Status 和 Dependencies 字段，请运行 `/architecture-review` 重新验证覆盖率。"

如果**不**处于 retrofit 模式，则继续执行下方的 Step 0（正常 ADR 编写流程）。

**无参数保护**：如果未提供任何参数（title 为空），则在运行 Phase 0 之前先询问：

> "您要记录什么技术决策？请提供一个简短的标题
> （例如 `event-system-architecture`、`physics-engine-choice`）。"

使用用户的回复作为标题，然后继续执行 Step 0。

---

## 0. 加载引擎上下文（始终优先）

在做任何其他事情之前，先建立引擎环境：

1. 读取 `docs/engine-reference/[engine]/VERSION.md` 以获取：
   - 引擎名称和版本
   - LLM 知识截止日期
   - 截止日后版本的风险等级（LOW / MEDIUM / HIGH）

2. 从标题或用户描述中识别此架构决策的**领域**。
   常见领域：Physics、Rendering、UI、Audio、Navigation、
   Animation、Networking、Core、Input、Scripting。

3. 如果存在，读取对应的模块参考文档：
   `docs/engine-reference/[engine]/modules/[domain].md`

4. 读取 `docs/engine-reference/[engine]/breaking-changes.md` — 标记相关领域中
   发生在 LLM 训练截止日期之后的任何变更。

5. 读取 `docs/engine-reference/[engine]/deprecated-apis.md` — 标记相关领域中
   不应使用的任何 API。

6. 如果该领域具有 MEDIUM 或 HIGH 风险，在继续之前**展示知识差距警告**：

   ```
   ⚠️  引擎知识差距警告
   引擎：[名称 + 版本]
   领域：[domain]
   风险等级：HIGH — 此版本在 LLM 截止日期之后。

   已从引擎参考文档验证的关键变更：
   - [与此领域相关的变更 1]
   - [变更 2]

   此 ADR 将与引擎参考库进行交叉验证。
   仅使用已验证的信息继续 — 不要仅依赖训练数据。
   ```

   如果尚未配置引擎，则提示："未配置引擎。
   请先运行 `/setup-engine`，或告诉我您正在使用哪个引擎。"

---

## 1. 确定下一个 ADR 编号

扫描 `docs/architecture/` 中现有的 ADR，以找到下一个编号。

---

## 2. 收集上下文

读取相关代码、现有 ADR，以及 `design/gdd/` 中的相关 GDD。

### 2a：架构注册表检查（阻塞 gate）

读取 `docs/registry/architecture.yaml`。提取与此 ADR 的
领域和决策相关的条目（按系统名称、领域关键词或被触及的状态进行 grep）。

在协作设计开始**之前**，将任何相关立场作为锁定约束展示给用户：

```
## 现有架构立场（不得与之矛盾）

State Ownership:
  player_health → owned by health-system (ADR-0001)
  Interface: HealthComponent.current_health (read-only float)
  → 如果此 ADR 读取或写入 player health，则必须使用此接口。

Interface Contracts:
  damage_delivery → signal pattern (ADR-0003)
  Signal: damage_dealt(amount, target, is_crit)
  → 如果此 ADR 传递或接收伤害事件，则必须使用此信号。

Forbidden Patterns:
  ✗ autoload_singleton_coupling (ADR-0001)
  ✗ direct_cross_system_state_write (ADR-0000)
  → 提出的方案不得使用这些模式。
```

如果用户提出的决策与任何已注册的立场相矛盾，立即提出冲突：

> "⚠️ 冲突：此 ADR 提议 [X]，但 ADR-[NNNN] 已确立 [Y] 是
> 此用途的接受模式。不解决此冲突就继续将产生
> 矛盾的 ADR 和不一致的 stories。
> 选项：(1) 与现有立场对齐，(2) 以显式替换 Supersede ADR-[NNNN]，
> (3) 解释为什么此情况是例外。"

在冲突得到解决或被显式接受为有意例外之前，不要继续执行 Step 3（协作设计）。

---

## 3. 协作引导决策

在提出任何问题之前，先从已收集的上下文中推导出 Skill 的最佳猜测（已读取的 GDD、已加载的引擎参考、已扫描的现有 ADR）。然后使用 `AskUserQuestion` 展示一个**确认/调整**提示 —— 而不是开放式问题。

**先推导假设：**
- **Problem**：从标题 + GDD 上下文推断需要做出什么决策
- **Alternatives**：从引擎参考 + GDD 需求中提出 2-3 个具体选项
- **Dependencies**：扫描现有 ADR 中的上游依赖；如果不清楚则假设为 None
- **GDD linkage**：提取标题直接相关的 GDD 系统
- **Status**：新 ADR 始终为 `Proposed` —— 绝不询问用户状态是什么

**假设标签页的范围**：假设仅涵盖：问题框架、替代方案、上游依赖、GDD 关联和状态。Schema 设计问题（例如"生成时机应该如何工作？"、"数据应该是内联还是外部的？"）**不是**假设 —— 它们是属于假设确认后单独步骤的设计决策。不要在假设 AskUserQuestion 控件中包含 schema 设计问题。

**假设确认后**，如果 ADR 涉及 schema 或数据设计选择，请使用单独的多个标签页 `AskUserQuestion` 在起草前独立询问每个设计问题。

**使用 `AskUserQuestion` 展示假设：**

```
起草前，我的假设如下：

Problem: [从上下文推导的一句话问题陈述]
Alternatives I'll consider:
  A) [从引擎参考推导的选项]
  B) [从 GDD 需求推导的选项]
  C) [来自常见模式的选项]
GDD systems driving this: [从上下文推导的列表]
Dependencies: [如有上游 ADR，否则为 "None"]
Status: Proposed

[A] 继续 — 使用这些假设起草
[B] 更改替代方案列表
[C] 调整 GDD 关联
[D] 添加性能预算约束
[E] 有其他需要先更改的内容
```

在用户确认假设或提供更正之前，不要生成 ADR。

**引擎专家和 TD 审查返回后**（Step 4.5/4.6），如果仍有未解决的决策，
将每个决策作为单独的 `AskUserQuestion` 展示，选项为审查提出的方案，外加一个自由文本逃逸选项：

```
Decision: [具体的未解决要点]
[A] [来自专家审查的选项]
[B] [替代选项]
[C] 不同的方法 — 我会描述它
```

**ADR Dependencies** —— 从现有 ADR 推导，然后确认：
- 此决策是否依赖于任何尚未 Accepted 的其他 ADR？
- 它是否解锁或解除阻塞任何其他 ADR 或 epic？
- 它是否阻塞任何特定 epic 的启动？

将答案记录在 **ADR Dependencies** 章节中。如果没有约束适用，每个字段都写 "None"。

---

## 4. 生成 ADR

遵循以下格式：

```markdown
# ADR-[NNNN]: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]

## Date
[决策日期]

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | [例如 Godot 4.6] |
| **Domain** | [Physics / Rendering / UI / Audio / Navigation / Animation / Networking / Core / Input] |
| **Knowledge Risk** | [LOW / MEDIUM / HIGH — 来自 VERSION.md] |
| **References Consulted** | [已读取的引擎参考文档列表，例如 `docs/engine-reference/godot/modules/physics.md`] |
| **Post-Cutoff APIs Used** | [此决策依赖的 LLM 截止日期后版本中的任何 API，或 "None"] |
| **Verification Required** | [发布前需要测试的特定行为，或 "None"] |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN（必须在此实现之前 Accepted），或 "None"] |
| **Enables** | [ADR-NNNN（此 ADR 解锁该决策），或 "None"] |
| **Blocks** | [Epic/Story 名称 — 必须等待此 ADR Accepted 后才能开始，或 "None"] |
| **Ordering Note** | [任何未被上述内容捕获的排序约束] |

## Context

### Problem Statement
[我们要解决什么问题？为什么现在需要做出这个决策？]

### Constraints
- [技术约束]
- [时间线约束]
- [资源约束]
- [兼容性需求]

### Requirements
- [必须支持 X]
- [必须在 Y 预算内运行]
- [必须与 Z 集成]

## Decision

[做出的具体技术决策，描述得足够详细以便
他人能够实现它。]

### Architecture Diagram
[此决策创建的系统架构的 ASCII 图或描述]

### Key Interfaces
[此决策创建的 API 契约或接口定义]

## Alternatives Considered

### Alternative 1: [Name]
- **Description**: [这将如何工作]
- **Pros**: [优势]
- **Cons**: [劣势]
- **Rejection Reason**: [为什么未被选择]

### Alternative 2: [Name]
- **Description**: [这将如何工作]
- **Pros**: [优势]
- **Cons**: [劣势]
- **Rejection Reason**: [为什么未被选择]

## Consequences

### Positive
- [此决策带来的好结果]

### Negative
- [接受的权衡和成本]

### Risks
- [可能出错的事情]
- [每项风险的缓解措施]

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| [system-name].md | [来自该 GDD 的具体规则、公式或性能约束] | [此决策如何满足它] |

## Performance Implications
- **CPU**: [预期影响]
- **Memory**: [预期影响]
- **Load Time**: [预期影响]
- **Network**: [预期影响（如适用）]

## Migration Plan
[如果这会改变现有代码，我们如何从这里迁移到那里？]

## Validation Criteria
[我们如何知道这个决策是正确的？什么指标或测试？]

## Related Decisions
- [相关 ADR 的链接]
- [相关设计文档的链接]
```

4.5. **引擎专家验证** —— 在保存之前，通过 Task 生成**主引擎专家**来验证起草的 ADR：
   - 读取 `.claude/docs/technical-preferences.md` 的 `Engine Specialists` 章节以获取主专家
   - 如果尚未配置引擎（`[TO BE CONFIGURED]`），跳过此步骤
   - 生成 `subagent_type: [primary specialist]`，传入：ADR 的 Engine Compatibility 章节、Decision 章节、Key Interfaces，以及引擎参考文档路径。要求他们：
     1. 确认提出的方案对于固定引擎版本是惯用的
     2. 标记任何在训练截止日期之后已弃用或变更的 API 或模式
     3. 识别当前 ADR 草稿中未捕获的引擎特定风险或陷阱
   - 如果专家识别出**阻塞性问题**（错误的 API、已弃用的方法、引擎版本不兼容）：相应地修订 Decision 和 Engine Compatibility 章节，然后在继续前与用户确认更改
   - 如果专家仅发现**次要备注**：将它们纳入 ADR 的 Risks 子章节

**审查模式检查** —— 在生成 TD-ADR 之前应用：
- `solo` → 跳过。备注："TD-ADR 已跳过 — Solo 模式。" 继续执行 Step 4.7（GDD 同步检查）。
- `lean` → 跳过（不是 PHASE-GATE）。备注："TD-ADR 已跳过 — Lean 模式。" 继续执行 Step 4.7（GDD 同步检查）。
- `full` → 正常生成。

4.6. **技术总监战略审查** —— 引擎专家验证之后，通过 Task 使用 gate **TD-ADR**（`.claude/docs/director-gates.md`）生成 `technical-director`：
   - 传入：ADR 文件路径（或草稿内容）、引擎版本、领域、同一领域中的任何现有 ADR
   - TD 验证架构一致性（此决策是否与整个系统一致？）—— 与引擎专家的 API 级别检查不同
   - 如果 CONCERNS 或 REJECT：在继续前相应地修订 Decision 或 Alternatives 章节

4.7. **GDD 同步检查** —— 在展示写入批准之前，扫描 "GDD Requirements Addressed" 章节中引用的所有 GDD，检查与 ADR 的 Key Interfaces 和 Decision 章节的命名不一致（重命名的信号、API 方法或数据类型）。如果发现任何不一致，在写入批准之前将其作为**醒目的警告块**展示 —— 而不是脚注：

```
⚠️ GDD 同步必需
[gdd-filename].md 使用了此 ADR 已重命名的名称：
  [old_name] → [new_name_from_adr]
  [old_name_2] → [new_name_2_from_adr]
必须先更新 GDD，或与写入此 ADR 同时进行更新，以防止
阅读 GDD 的开发者实现错误的接口。
```

如果没有不一致：静默跳过此块。

5. **写入批准** —— 使用 `AskUserQuestion`：

如果发现 GDD 同步问题：
- "ADR 草稿已完成。您希望如何继续？"
  - [A] 同时写入 ADR 并更新 GDD
  - [B] 仅写入 ADR — 我将手动更新 GDD
  - [C] 尚未准备好 — 我需要进一步审查

如果没有 GDD 同步问题：
- "ADR 草稿已完成。我可以写入它吗？"
  - [A] 将 ADR 写入 `docs/architecture/adr-[NNNN]-[slug].md`
  - [B] 尚未准备好 — 我需要进一步审查

如果对任何写入选项选择是，则写入文件，如果需要则创建目录。
对于选项 [A] 并更新 GDD：同时更新 GDD 文件以使用新名称。

6. **更新架构注册表**

扫描已写入的 ADR，查找应注册的新架构立场：
- 它声明拥有的状态
- 它定义的接口契约（信号签名、方法 API）
- 它声明的性能预算
- 它明确做出的 API 选择
- 它禁止的模式（Consequences → Negative 或显式的 "do not use X"）

展示候选项：
```
来自此 ADR 的注册表候选：
  NEW state ownership:      player_stamina → stamina-system
  NEW interface contract:   stamina_depleted signal
  NEW performance budget:   stamina-system: 0.5ms/frame
  NEW forbidden pattern:    polling stamina each frame (use signal instead)
  EXISTING (仅更新 referenced_by): player_health → already registered ✅
```

**注册表追加逻辑**：写入 `docs/registry/architecture.yaml` 时，不要假设章节为空。该文件可能已包含本会话中先前 ADR 写入的条目。在每次 Edit 调用之前：
1. 读取 `docs/registry/architecture.yaml` 的当前状态
2. 找到正确的章节（state_ownership、interfaces、forbidden_patterns、api_decisions）
3. 在该章节的最后一个现有条目**之后**追加新条目 —— 不要尝试替换可能已不存在的 `[]` 占位符
4. 如果该章节已有条目，使用最后一个条目的结束内容作为 `old_string` 锚点，并在其后追加新条目

**阻塞 —— 未经用户明确批准，不要写入 `docs/registry/architecture.yaml`。**

使用 `AskUserQuestion` 询问：
- "我可以使用这 [N] 个新立场更新 `docs/registry/architecture.yaml` 吗？"
  - 选项："是 — 更新注册表"、"尚未 — 我想审查候选项"、"跳过注册表更新"

仅在用户选择是时才继续。如果是：追加新条目。永远不要修改现有条目 —— 如果立场正在变更，将旧条目设置为 `status: superseded_by: ADR-[NNNN]` 并添加新条目。

---

## 7. 结束与后续步骤

ADR 写入后（注册表可选更新），使用 `AskUserQuestion` 关闭。

在生成控件之前：
1. 读取 `docs/registry/architecture.yaml` —— 检查是否仍有未编写的高优先级 ADR（查找在 technical-preferences.md 或 systems-index.md 中标记为前置条件的 ADR）
2. 检查所有前置 ADR 是否现已编写。如果是，包含一个 "Start writing GDDs" 选项。
3. 将所有剩余的高优先级 ADR 列为单独的选项 —— 不仅仅是接下来的一两个。

控件格式：
```
ADR-[NNNN] 已写入且注册表已更新。您接下来想做什么？
[1] 编写 [next-priority-adr-name] — [来自前置条件列表的简要描述]
[2] 编写 [another-priority-adr] — [简要描述]  （包含所有剩余的）
[N] 开始编写 GDD — 运行 `/design-system [first-undesigned-system]` （仅在所有前置 ADR 都已编写时显示）
[N+1] 本次会话到此结束
```

如果没有剩余的高优先级 ADR 且没有未设计的 GDD 系统，仅提供 "Stop here" 并建议在新会话中运行 `/architecture-review`。

**始终在结束输出中包含此固定通知（不要省略）：**

> 要针对您的 GDD 验证 ADR 覆盖率，请打开一个**新的 Claude Code 会话**
> 并运行 `/architecture-review`。
>
> **绝不要在同一会话中运行 `/architecture-review` 和 `/architecture-decision`。**
> 审查 Agent 必须独立于编写上下文，以给出无偏见的
> 评估。在此处运行它将使审查失效。

将此 ADR 之前 `Status: Blocked` 的任何 story 更新为 `Status: Ready`。
