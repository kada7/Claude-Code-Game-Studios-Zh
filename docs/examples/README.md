# 协作会话示例

本目录包含真实、端到端的会话记录，展示游戏工作室 Agent 架构在实际中的运作方式。每个示例演示了**协作工作流**，其中 Agent 提出问题、提供选项并等待用户批准，而非自主生成内容。

---

## 视觉参考

**初次接触本系统？从这里开始：**
[技能流程图](skill-flow-diagrams.md) — 所有 7 个阶段的视觉地图，以及技能如何串联。

---

## 📚 **可用示例**

### 核心工作流

### [技能流程图](skill-flow-diagrams.md)
**类型：** 视觉参考
**复杂度：** 所有级别

完整流程概览（从零到发布），以及以下内容的详细链式图：
design-system、story 生命周期、UX 流程和 brownfield 接入。
**如果你想了解各个部分如何组合在一起，从这里开始。**

---

### [会话：使用 /design-system 编写 GDD](session-design-system-skill.md)
**类型：** 设计（技能驱动）
**技能：** `/design-system`
**时长：** ~60 分钟（14 轮）
**复杂度：** 中等

**场景：**
开发者在 `/map-systems` 生成系统索引后运行 `/design-system movement`。该技能从游戏概念和依赖 GDD 中加载上下文，运行技术可行性预检查，然后逐节引导完成全部 8 个 GDD 章节 —— 每节起草、批准并写入磁盘后再进入下一节。

**关键时刻：**
- 技术可行性预检查标记出 Jolt 物理默认变更（Godot 4.6）
- 增量写入：每节在批准后立即写入磁盘
- 第 5 节期间会话崩溃 → Agent 从第一个空节恢复
- 依赖信号（耐力、库存）在 Dependencies 章节中被呈现
- 以明确的交接结束："运行 `/design-review` 再进入下一个系统"

**学习：**
- `/design-system` 与让 Agent "写一份 GDD" 有何不同
- 逐节循环如何防止 30k token 的上下文膨胀
- 增量文件写入如何在会话崩溃后存活
- 技能如何呈现下游依赖契约

---

### [会话：完整 Story 生命周期](session-story-lifecycle.md)
**类型：** 完整工作流
**技能：** `/story-readiness` → 实现 → `/story-done`
**时长：** ~50 分钟（13 轮）
**复杂度：** 中等

**场景：**
开发者从冲刺待办中选取一个 story。`/story-readiness` 在编写任何代码前捕捉到滚动方向歧义。实现后，`/story-done` 验证 9 个验收标准，识别出 2 个延期标准（库存尚未集成），并关闭 story 附带备注。

**关键时刻：**
- `/story-readiness` 在第 2 轮捕捉到规格歧义 — 在实现开始前解决
- ADR 状态检查：如果 ADR 仍为 Proposed，story 会被 BLOCKED
- 清单版本检查：确认 story 的指导未偏离当前架构
- 当集成尚不可行时，延期标准被跟踪（不会丢失）
- story 关闭时更新 `sprint-status.yaml`，自动呈现下一个就绪 story

**学习：**
- 为什么 `/story-readiness` 能防止实现后期的歧义
- 延期标准如何工作（COMPLETE WITH NOTES vs. BLOCKED）
- TR-ID 引用如何防止错误的偏离标记
- 从待办 → 实现 → 关闭的完整循环

---

### [会话：阶段门检查与阶段过渡](session-gate-check-phase-transition.md)
**类型：** 阶段门
**技能：** `/gate-check`
**时长：** ~20 分钟（7 轮）
**复杂度：** 低

**场景：**
开发者完成系统设计阶段并运行 `/gate-check` 以推进。阶段门发现全部 6 个 MVP GDD 已完成，交叉评审通过并附带一个低严重度关注项。阶段门通过，`stage.txt` 更新，Agent 提供技术设置的特定有序检查清单。

**关键时刻：**
- 阶段门验证工件存在性 AND 内部完整性（每个 GDD 8 个章节）
- CONCERNS ≠ FAIL：低严重度交叉评审备注通过阶段门
- stage.txt 更新改变了 `/help`、`/sprint-status` 以及所有技能后续看到的内容
- Agent 将交叉评审关注项作为具体 ADR 呈现
- 下一阶段检查清单是具体且有序的，不是通用的

**学习：**
- 阶段门实际验证什么（不仅仅是"文件存在吗？"）
- PASS/CONCERNS/FAIL 裁决如何工作
- 为什么 stage.txt 是阶段跟踪的权威来源
- 阶段过渡后会有什么变化

---

### [会话：UX 流程 — /ux-design → /ux-review → /team-ui](session-ux-pipeline.md)
**类型：** UX 设计流程
**技能：** `/ux-design`, `/ux-review`, `/team-ui`
**时长：** ~90 分钟（16 轮）
**复杂度：** 中高

**场景：**
开发者设计 HUD 和库存界面。`/ux-design` 读取玩家旅程和 GDD 以将决策扎根于玩家情绪状态。`/ux-review` 捕获一个阻塞性无障碍缺陷（拖放没有键盘替代方案）和一个建议性色盲问题。修复后，`/team-ui` 接受交接。

**关键时刻：**
- HUD 理念选择（diegetic vs. persistent vs. tactical）扎根于生存类型惯例
- `/ux-review` 区分 BLOCKING（阻止交接）vs. ADVISORY（可在视觉阶段修复）
- 无障碍在实现前被捕获，而非在 QA 期间
- 键盘替代方案在一轮内添加；评审重新运行并通过
- `/team-ui` 在开始视觉设计前检查是否有通过的 `/ux-review`

**学习：**
- `/ux-design` 如何使用玩家旅程上下文来支撑 UI 决策
- `/ux-review` 实际检查什么（不仅仅是"规格存在吗？"）
- HUD 文档（`design/ux/hud.md`）和每屏规格之间的区别
- 无障碍问题在设计时与实现时分别如何处理

---

### [会话：使用 /adopt 接入 Brownfield 项目](session-adopt-brownfield.md)
**类型：** Brownfield 接入
**技能：** `/adopt`
**时长：** ~30 分钟（8 轮）
**复杂度：** 低-中

**场景：**
开发者有 3 个月的现有代码和粗略设计笔记，但没有任何正确格式的内容。`/adopt` 审计格式合规性（不仅仅是文件存在性），按严重度分类 4 个差距，构建一个有序的 7 步迁移计划，并通过从代码库推断立即修复 BLOCKING 差距（缺失系统索引）。

**关键时刻：**
- FORMAT 审计区分"文件存在"和"文件具有必需的内部结构"
- BLOCKING 差距被识别：缺失系统索引阻止 4+ 个技能运行
- 迁移计划是有序的：阻塞差距优先，然后高、中
- 系统索引从代码结构自举 — brownfield 代码包含答案
- Retrofit 模式 vs. 新编写：`/design-system retrofit` 填补差距而不覆盖

**学习：**
- `/adopt` 与 `/project-stage-detect` 的区别
- 格式合规性如何检查（章节检测，不仅仅是文件存在性）
- Brownfield 项目如何接入而不会丢失现有工作
- 何时使用 retrofit 模式 vs. 完整编写

---

### 基础示例

### [会话：设计制作系统](session-design-crafting-system.md)
**类型：** 设计
**Agent：** game-designer
**时长：** ~45 分钟（12 轮）
**复杂度：** 中等

**场景：**
独立开发者需要设计一个服务于 Pillar 2（"通过实验的涌现发现"）的制作系统。Agent 通过问答引导他们，呈现 3 个带有游戏理论分析的设计选项，融入用户修改，并在每一步获得批准后迭代起草 GDD。

**关键协作时刻：**
- Agent 预先提出 5 个澄清问题
- 呈现 3 个不同选项，附带优缺点 + MDA 对齐分析
- 用户修改推荐选项，Agent 立即融入
- 主动标记边界情况（"如果非配方组合怎么办？"）
- 每个 GDD 章节在移至下一节前展示以供批准
- 在创建文件前明确询问"我可以写入 [file] 吗？"

**学习：**
- 设计 Agent 如何询问目标、约束、参考
- 如何使用游戏设计理论（MDA、SDT、Bartle）呈现选项
- 如何逐节迭代起草
- 何时委派给专家（systems-designer、economy-designer）

---

### [会话：实现战斗伤害计算](session-implement-combat-damage.md)
**类型：** 实现
**Agent：** gameplay-programmer
**时长：** ~30 分钟（10 轮）
**复杂度：** 低-中

**场景：**
用户有完整的设计文档并希望实现伤害计算。Agent 阅读规格，识别出 7 个歧义/差距，提出澄清问题，在实现前提出架构供批准，按规则强制执行实现，并主动编写测试。

**关键协作时刻：**
- Agent 首先阅读设计文档，识别出 7 个规格歧义
- 在实现前用代码样本提出架构
- 用户请求类型安全，Agent 细化并重新提出
- 规则捕获问题（硬编码值），Agent 透明修复
- 遵循验证驱动开发主动编写测试
- Agent 为下一步提供选项，而非假设

**学习：**
- 实现 Agent 如何在编码前澄清规格
- 如何用代码样本提出架构供批准
- 规则如何自动强制执行标准
- 如何处理规格差距（询问，不要假设）
- 验证驱动开发（测试证明其有效）

---

### [会话：范围危机 — 战略决策制定](session-scope-crisis-decision.md)
**类型：** 战略决策
**Agent：** creative-director
**时长：** ~25 分钟（8 轮）
**复杂度：** 高

**场景：**
独立开发者面临危机：Alpha 里程碑还有 2 周，制作系统需要 3 周，投资者演示是成败关键。创意总监收集上下文，构建决策框架，呈现 3 个带有诚实权衡分析的战略选项，提出建议但交由用户决定，然后用 ADR 和演示脚本记录决策。

**关键协作时刻：**
- Agent 在提出解决方案前阅读上下文文档
- 提出 5 个问题以理解决策约束
- 正确构建决策（利害攸关、评估标准）
- 呈现 3 个选项，附带风险分析和历史先例
- 提出强烈建议但明确："由你决定"
- 记录决策 + 提供演示脚本支持用户

**学习：**
- 领导 Agent 如何构建战略决策
- 如何呈现附带权衡分析的选项
- 如何在建议中使用游戏开发先例和理论
- 如何记录决策（ADR）
- 如何将决策级联到受影响的部门

---

### [反向文档工作流](reverse-document-workflow-example.md)
**类型：** Brownfield 文档
**Agent：** game-designer
**时长：** ~20 分钟
**复杂度：** 低

**场景：**
开发者构建了一个技能树系统但从未编写设计文档。Agent 阅读代码，推断设计意图，就模糊决策提出澄清问题，并生成追溯性 GDD。

---

## 🎯 **这些示例演示了什么**

所有示例遵循**协作工作流模式：**

```
Question → Options → Decision → Draft → Approval
```

> **注意：** 这些示例将协作模式展示为对话文本。
> 在实践中，Agent 现在使用 `AskUserQuestion` 工具在决策点呈现
> 结构化选项选择器（带有标签、描述和多选）。
> 模式是 **Explain → Capture**：Agent 首先在对话中解释其分析，
> 然后呈现结构化 UI 选择器供用户决策。

### ✅ **展示的协作行为：**

1. **Agent 在假设前先询问**
   - 设计 Agent 询问目标、约束、参考
   - 实现 Agent 澄清规格歧义
   - 领导 Agent 在推荐前收集完整上下文

2. **Agent 呈现选项，而非命令**
   - 2-4 个选项，附带优缺点
   - 基于理论、先例、项目支柱的推理
   - 提出建议，但由用户决定

3. **Agent 在定稿前展示工作**
   - 设计草稿逐节展示
   - 架构提案在实现前展示
   - 战略分析在决策前呈现

4. **Agent 在写入文件前获得批准**
   - 在使用 Write/Edit 工具前明确询问"我可以写入 [file] 吗？"
   - 多文件变更首先列出所有受影响的文件
   - 用户在创建任何文件前说"是"

5. **Agent 根据反馈迭代**
   - 用户修改被立即融入
   - 用户更改推荐时无防御性
   - 当用户改进 Agent 的建议时予以赞赏

---

## 📖 **如何使用这些示例**

### 对于新用户：
在首次会话前阅读这些示例。它们展示了 Agent 如何工作的现实期望：
- Agent 是顾问，而非自主执行者
- 你做出所有创意/战略决策
- Agent 提供专业指导和选项

### 用于理解特定工作流：
- **新接触系统？** → 首先阅读 skill-flow-diagrams.md
- **第一次运行 /design-system？** → 阅读 session-design-system-skill.md
- **选取一个 story？** → 阅读 session-story-lifecycle.md
- **完成一个阶段？** → 阅读 session-gate-check-phase-transition.md
- **开始 UI 工作？** → 阅读 session-ux-pipeline.md
- **有现有项目？** → 阅读 session-adopt-brownfield.md
- **设计系统（Agent 驱动）？** → 阅读 session-design-crafting-system.md
- **实现代码？** → 阅读 session-implement-combat-damage.md
- **做战略决策？** → 阅读 session-scope-crisis-decision.md

### 用于培训：
如果你正在教某人使用本系统，逐步走过一个示例以展示：
- 好问题是什么样的
- 如何评估呈现的选项
- 何时批准 vs. 请求更改
- 如何在利用 AI 专业知识的同时保持创意控制

---

## 🔍 **所有示例中的常见模式**

### 第 1-2 轮：**先理解再行动**
- Agent 读取上下文（设计文档、规格、约束）
- Agent 提出澄清问题
- 无假设或猜测

### 第 3-5 轮：**呈现带推理的选项**
- 2-4 种不同方法
- 每个的优缺点
- 支持分析的理论/先例
- 提出建议，决策交由用户

### 第 6-8 轮：**迭代草稿**
- 增量展示工作
- 立即融入反馈
- 主动标记边界情况或歧义

### 第 9-10 轮：**批准和完成**
- "我可以写入 [file] 吗？"
- 用户："是"
- Agent 写入文件
- Agent 提供下一步（测试、评审、集成）

---

## 🚀 **亲自尝试**

阅读这些示例后，尝试这个练习：

1. 挑选你的一个游戏系统（战斗、库存、进度等）
2. 让相关 Agent 设计或实现它
3. 注意 Agent 是否：
   - ✅ 预先提出澄清问题
   - ✅ 呈现带推理的选项
   - ✅ 定稿前展示草稿
   - ✅ 写入文件前请求批准

如果 Agent 跳过任何这些，提醒它：
> "请遵循 docs/COLLABORATIVE-DESIGN-PRINCIPLE.md 中的协作协议"

---

## 📝 **额外资源**

- **完整原则文档：** [docs/COLLABORATIVE-DESIGN-PRINCIPLE.md](../COLLABORATIVE-DESIGN-PRINCIPLE.md)
- **工作流指南：** [docs/WORKFLOW-GUIDE.md](../WORKFLOW-GUIDE.md)
- **Agent 名册：** [.claude/docs/agent-roster.md](../../.claude/docs/agent-roster.md)
- **CLAUDE.md（协作协议）：** [CLAUDE.md](../../CLAUDE.md#collaboration-protocol)
