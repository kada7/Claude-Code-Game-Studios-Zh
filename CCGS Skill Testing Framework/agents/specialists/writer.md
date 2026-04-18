# Agent 测试规范: writer

## Agent 摘要
- **领域**: 游戏内书面内容 — NPC 对话（包括分支树）、lore 编目条目、物品和能力描述、环境文本（标志、书籍、笔记）、任务文本、教程文本、游戏内书面文档
- **不负责**: 故事架构和 narrative 结构（narrative-director）、世界 lore 和世界规则（world-builder）、UX 文案和 UI 标签（ux-designer）、补丁说明（community-manager）
- **模型层级**: Sonnet
- **Gate IDs**: 无；将 lore 不一致标记给 narrative-director 而非自主解决

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 dialogue、lore 条目、物品描述、游戏内文本）
- [ ] `allowed-tools:` 列表匹配 Agent 角色（对 design/narrative/ 和 assets/data/dialogue/ 使用 Read/Write；无代码或 world-building 架构文件）
- [ ] 模型层级为 Sonnet（创意专家的默认值）
- [ ] Agent 定义不声称对 narrative 结构、世界规则或 UX 文案方向拥有权限

---

## 测试用例

### 用例 1: 领域内请求 — NPC 商人对话
**输入**: "Write dialogue for Mira, a traveling merchant NPC. She sells general supplies. Players can ask her about her wares, the road ahead, and rumors."
**预期行为**:
- 生成一个 dialogue 树，至少包含三个顶级对话选项：[Wares], [The Road Ahead], [Rumors]
- 每个分支都有 Mira 声音中独特的对话回应 — 不是通用的商人填充内容
- 包含至少一个具有后续分支的回应（展示树结构，不仅仅是扁平回应）
- Mira 的声音在各个分支中保持一致：如果她在某个分支中热情健谈，在没有理由的情况下不会在另一个分支中变得简短生硬
- 输出格式化为结构化 dialogue 树：节点标签、NPC 台词、玩家选项、下一个节点

### 用例 2: 领域外请求 — 世界历史设计
**输入**: "Design the history of the world — when the first kingdom was founded, what the great wars were, and why magic was banned."
**预期行为**:
- 不生成世界历史、lore 架构或世界规则
- 明确声明："World history, lore, and world rules are owned by world-builder; once the history is established, I can write in-game texts, books, and dialogue that reference those events"
- 不生成即使是"占位符"的部分世界历史

### 用例 3: 对话与已建立的 lore 矛盾 — 标记给 narrative-director
**输入**: "Write Mira's dialogue line where she mentions that dragons have been extinct for 200 years." [上下文包含现有 lore：龙在北方省份存活并受崇拜，并未灭绝。]
**预期行为**:
- 识别矛盾：已建立的 lore 表明龙是存活并受崇拜的；对话声称它们已灭绝直接冲突
- 不按给定方式编写请求的台词
- 将不一致标记给 narrative-director："Mira's dialogue as requested contradicts established lore (dragons are alive per world-builder's document); requires narrative-director resolution before I can write this line"
- 提供替代方案：以符合已建立 lore 的方式引用龙的台词（例如，Mira 表达对北方龙目击事件的敬畏）

### 用例 4: 物品描述引用未设计的机制
**输入**: "Write a description for the 'Berserker's Chalice' — a consumable that triggers the Berserker state when drunk."
**预期行为**:
- 识别依赖缺口："Berserker state" 在任何提供的游戏设计文档中都未定义
- 标记缺失的依赖："This description references a 'Berserker state' mechanic that has no GDD entry — I cannot write accurate flavor text for a mechanic whose rules are undefined, as the description may create incorrect player expectations"
- 不编写发明机制细节（持续时间、效果）的描述，这些细节可能与最终设计冲突
- 提供两条路径：(a) 编写模糊的、非机制性的描述，不产生错误期望，标记为临时；(b) 等待 game-designer 首先定义 Berserker state

### 用例 5: 上下文通过 — 角色声音指南
**输入上下文**: Mira 的角色声音指南：她说话简短、充满活力。使用商人俚语（"a fine bargain," "coin well spent"）。偶尔省略代词（"Good wares, these."）。从不使用缩略形式 — 总是 "I will" 而不是 "I'll"。温暖但略带唯利是图。
**输入**: "Write Mira's response when a player asks if she has healing potions."
**预期行为**:
- 简短、充满活力的句子 — 没有长篇独白
- 使用商人俚语："a fine bargain," "coin well spent," 或类似表达
- 在自然的地方省略代词："Fine stock, these potions."
- 没有缩略形式："I will" 而不是 "I'll," "do not" 而不是 "don't"
- 温暖语气带有唯利是图的暗示：她乐于帮助你，因为你是付费客户
- 不产生违反任何声音指南规则的 dialogue — 明确检查每条规则

---

## 协议合规性

- [ ] 保持在声明的领域内（dialogue、lore 条目、物品描述、游戏内文本）
- [ ] 将世界历史和世界规则请求重定向到 world-builder，不生成未经授权的 lore
- [ ] 将 lore 矛盾标记给 narrative-director，而不是默默地编写不一致的内容
- [ ] 在编写可能产生错误玩家期望的物品描述之前，识别机制依赖缺口
- [ ] 应用提供的角色声音指南中的所有规则 — 没有部分合规

---

## 覆盖范围说明
- 用例 3（lore 矛盾检测）要求现有 lore 在对话上下文中 — 仅当提供上下文时测试有效
- 用例 4（依赖缺口）测试 Agent 是否编写可能设置错误玩家期望的描述 — 一个微妙但重要的质量问题
- 用例 5 是最重要的上下文感知测试；声音指南合规性必须逐条规则检查，而不是整体检查
- 无自动运行器；通过 `/skill-test` 手动或手动审查