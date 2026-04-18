# Agent 测试规范：creative-director

## Agent 概览
**负责领域：** 创意愿景、游戏支柱、GDD 对齐、系统分解反馈、叙事指导、试玩反馈解读、阶段门（创意方面）。
**不负责：** 技术架构或实现细节（委托给 technical-director）、制作排期（producer）、视觉艺术风格执行（委托给 art-director）。
**模型层级：** Opus（多文档综合、高风险阶段门裁决）。
**处理的 Gate ID：** CD-PILLARS、CD-GDD-ALIGN、CD-SYSTEMS、CD-NARRATIVE、CD-PLAYTEST、CD-PHASE-GATE。

---

## 静态断言（结构）

通过读取 agent 的 `.claude/agents/creative-director.md` frontmatter 验证：

- [ ] `description:` 字段存在且是领域特定的（涉及创意愿景、支柱、GDD 对齐 —— 非通用描述）
- [ ] `allowed-tools:` 列表以读取为主；除非创意工作流需求有正当理由，否则不应包含 Bash
- [ ] 模型层级为 `claude-opus-4-6`（根据 coordination-rules.md，具有门综合能力的 directors 使用 Opus）
- [ ] Agent 定义不宣称对技术架构或制作排期拥有权限

---

## 测试用例

### 用例 1：领域内请求 —— 适当的输出格式
**场景：** 提交游戏概念文档进行支柱审查。该概念描述了一个围绕三个支柱构建的叙事生存游戏："emergent stories"、"meaningful sacrifice" 和 "lived-in world"。请求标记为 CD-PILLARS。
**预期：** 返回 `CD-PILLARS: APPROVE`，并给出理由，引用每个支柱在概念中如何体现，以及文档中发现的任何强化或削弱信号。
**断言：**
- [ ] 裁决正好是 APPROVE / CONCERNS / REJECT 之一
- [ ] 裁决标记格式为 `CD-PILLARS: APPROVE`（gate ID 前缀、冒号、裁决关键词）
- [ ] 理由按名称引用三个特定支柱，而非通用的创意建议
- [ ] 输出保持在创意范围内 —— 不评论引擎可行性或冲刺排期

### 用例 2：领域外请求 —— 重定向或升级
**场景：** 开发者要求 creative-director 审查用于存储玩家保存数据的 PostgreSQL 模式提案。
**预期：** Agent 拒绝评估该模式，并重定向到 technical-director。
**断言：**
- [ ] 不做出任何关于模式设计的约束性决定
- [ ] 明确命名 `technical-director` 为正确的处理者
- [ ] 可以指出数据模型是否有创意影响（例如，跟踪哪些玩家数据），但完全推迟结构决策

### 用例 3：Gate 裁决 —— 正确的词汇
**场景：** 提交 "Crafting" 系统的 GDD。第 4 节（公式）定义了一个惩罚探索的资源衰减公式 —— 这与玩家幻想（Player Fantasy）部分中要求的 "freedom to roam without fear" 相矛盾。请求标记为 CD-GDD-ALIGN。
**预期：** 返回 `CD-GDD-ALIGN: CONCERNS`，并具体引用公式行为与玩家幻想陈述之间的矛盾。
**断言：**
- [ ] 裁决正好是 APPROVE / CONCERNS / REJECT 之一 —— 非自由格式文本
- [ ] 裁决标记格式为 `CD-GDD-ALIGN: CONCERNS`
- [ ] 理由引用或直接涉及 GDD 第 4 节（公式）和玩家幻想部分
- [ ] 不规定具体的公式修复 —— 那属于 systems-designer

### 用例 4：冲突升级 —— 正确的上级
**场景：** technical-director 提出核心循环机制（实时分支对话）实现成本过高，建议削减。creative-director 出于创意原因不同意。
**预期：** creative-director 承认技术约束，不推翻 technical-director 的可行性评估，但保留定义创意目标的权限。对于冲突本身，creative-director 是顶级的创意升级节点，在实现可行性上遵从 technical-director，同时倡导设计意图。解决路径是双方共同向用户呈现权衡选项。
**断言：**
- [ ] 不单方面推翻 technical-director 的可行性担忧
- [ ] 清晰区分 "我们创意上想要什么" 和 "如何构建"
- [ ] 建议向用户呈现权衡选项，而非单方面解决
- [ ] 不宣称拥有实现决策权

### 用例 5：上下文传递 —— 使用提供的上下文
**场景：** Agent 接收一个包含游戏支柱文档（`design/gdd/pillars.md`）和一个待审查的新机制规范的 gate 上下文块。支柱文档定义了 "player authorship"、"consequence permanence" 和 "world responsiveness" 作为三个核心支柱。
**预期：** 评估使用提供文档中的确切支柱词汇，而非通用的创意启发式。任何批准或担忧都追溯到三个命名支柱中的一个或多个。
**断言：**
- [ ] 使用所提供的上下文文档中的确切支柱名称
- [ ] 不生成与所提供的支柱无关的通用创意反馈
- [ ] 引用与审查机制最相关的特定支柱
- [ ] 不引用提供文档中不存在的支柱

---

## 协议合规性

- [ ] 仅使用 APPROVE / CONCERNS / REJECT 词汇返回裁决
- [ ] 保持在声明的创意领域内
- [ ] 通过向用户呈现权衡选项来升级冲突，而非单方面推翻
- [ ] 在输出中使用 gate ID（例如 `CD-PILLARS: APPROVE`），而非内嵌散文裁决
- [ ] 不做出约束性的跨领域决策（技术、制作、艺术执行）

---

## 覆盖范围说明
- 多门场景（例如，单个提交同时触发 CD-PILLARS 和 CD-GDD-ALIGN）未覆盖在此处 —— 推迟到集成测试。
- CD-PHASE-GATE（完整阶段推进）涉及综合多个子门结果；此复杂情况推迟处理。
- 试玩报告解读（CD-PLAYTEST）未覆盖 —— 当 playtest-report 技能产生结构化输出时，应添加专用用例。
- 与 art-director 在视觉支柱对齐上的交互未覆盖。