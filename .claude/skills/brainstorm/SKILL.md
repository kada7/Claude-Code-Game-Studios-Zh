---
name: brainstorm
description: "引导式游戏概念构思 — 从零想法到结构化游戏概念文档。使用专业工作室构思技巧、玩家心理学框架和结构化创意探索。"
argument-hint: "[genre or theme hint, or 'open'] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, WebSearch, Task, AskUserQuestion
---

当此 Skill 被调用时：

1. **解析参数**以获取可选的题材/主题提示（例如 `roguelike`、
   `space survival`、`cozy farming`）。如果参数为 `open` 或未提供，则从零开始。
   同时解析审核模式（只需解析一次，在本次运行的所有 gate 生成中复用）：
   1. 如果传入了 `--review [full|lean|solo]` → 使用该值
   2. 否则读取 `production/review-mode.txt` → 使用该值
   3. 否则 → 默认为 `lean`

   完整的检查模式请参阅 `.claude/docs/director-gates.md`。

2. **检查现有的概念工作**：
   - 如果 `design/gdd/game-concept.md` 存在则读取（继续已有工作，不要重新开始）
   - 如果 `design/gdd/game-pillars.md` 存在则读取（在已确立的支柱基础上构建）

3. **交互式运行构思阶段**，在每个阶段向用户提问。
   不要静默生成所有内容 —— 目标是**协作式探索**，AI 扮演创意促进者，
   而非替代人类的愿景。

   **在头脑风暴的关键决策点使用 `AskUserQuestion`**：
   - 受约束的品味问题（题材偏好、范围、团队规模）
   - 概念选择（"哪 2-3 个概念引起共鸣？"）在展示选项后
   - 方向选择（"深入开发、探索更多，还是制作原型？"）
   - 概念细化后的支柱排序
   先在对话文本中写出完整的创意分析，然后使用
   `AskUserQuestion` 以简洁的标签捕获决策。

   遵循专业工作室头脑风暴原则：
   - 暂缓评判 —— 探索阶段没有坏主意
   - 鼓励非常规想法 —— 跳出框架的思考能激发更好的概念
   - 相互构建 —— 使用"是的，而且..."回应，而非"但是..."
   - 将约束作为创意燃料 —— 限制往往产生最佳创意
   - 每个阶段限时 —— 保持势头，不要过早过度斟酌

---

### 阶段 1：创意发现

从了解人开始，而非游戏。以对话方式（而非清单式）提出这些问题：

**情感锚点**：
- 游戏中有没有哪个时刻真正打动了你、让你兴奋，或让你忘记了时间？
  具体是什么创造了那种感觉？
- 有没有哪种幻想或权力快感是你一直想在游戏中体验却从未找到的？

**品味画像**：
- 你花时间最多的 3 款游戏是什么？是什么让你不断回归？
  *（以纯文本形式提问 —— 用户必须能够自由输入具体的游戏名称。
  不要将其放入带有预设选项的 AskUserQuestion 中。）*
- 有没有你喜欢的题材？有没有你避开的题材？为什么？
- 你更喜欢挑战你的游戏、让你放松的游戏、给你讲故事的游戏，
  还是让你自我表达的游戏？*（对此使用 `AskUserQuestion` —— 受限选择。）*

**实际约束**（在头脑风暴前先划定沙盒范围）。
将这些打包到一个多标签页的 `AskUserQuestion` 中，使用以下精确的标签名称：
- 标签 "Experience" —— "你最希望玩家获得什么样的体验？"（Challenge & Mastery / Story & Discovery / Expression & Creativity / Relaxation & Flow）
- 标签 "Timeline" —— "你现实的开发时间线是什么？"（Weeks / Months / 1-2 years / Multi-year）
- 标签 "Dev level" —— "你在开发旅程中处于什么阶段？"（First game / Shipped before / Professional background）

请完全使用这些标签名称 —— 不要重命名或重复它们。

**将答案综合**为一份**创意简报** —— 一段 3-5 句话的摘要，
概述此人的情感目标、品味画像和约束条件。
朗读简报并确认它是否准确捕捉了他们的意图。

---

### 阶段 2：概念生成

以创意简报为基础，生成 **3 个不同的概念**，每个概念采用不同的创意方向。
使用以下构思技巧：

**技巧 1：动词优先设计**
从核心玩家动词（建造、战斗、探索、解谜、生存、
创造、管理、发现）开始，并向外扩展。动词就是游戏本身。

**技巧 2：混搭法**
组合两个意想不到的元素：[题材 A] + [主题 B]。两者之间的张力
创造了独特的卖点。（例如，"农场模拟 + 宇宙恐怖"、
"roguelike + 恋爱模拟"、"城市建造 + 即时战斗"）

**技巧 3：体验优先设计（MDA 逆向）**
从期望的玩家情感出发（MDA 框架中的美学目标：
sensation、fantasy、narrative、challenge、fellowship、discovery、expression、
submission），逆向推导出产生它的 dynamics 和 mechanics。

对每个概念，展示：
- **工作标题**
- **电梯演讲**（1-2 句话 —— 必须通过"10 秒测试"）
- **核心动词**（最频繁的玩家动作）
- **核心幻想**（情感承诺）
- **独特卖点**（通过"而且"测试："像 X，而且 Y"）
- **主要 MDA 美学**（哪种情感占主导？）
- **预估规模**（small / medium / large）
- **为什么它能成功**（1 句话说明市场/受众契合度）
- **最大风险**（1 句话说明最难回答的问题）

展示全部三个概念。然后使用 `AskUserQuestion` 捕获选择。

**关键**：这必须是一个普通列表调用 —— 无标签页，无表单字段。请完全使用以下结构：

```
AskUserQuestion(
  prompt: "Which concept resonates with you? You can pick one, combine elements, or ask for fresh directions.",
  options: [
    "Concept 1 — [Title]",
    "Concept 2 — [Title]",
    "Concept 3 — [Title]",
    "Combine elements across concepts",
    "Generate fresh directions"
  ]
)
```

此处不要使用 `tabs` 字段。`tabs` 表单仅用于多字段输入 —— 在此处使用会导致"Invalid tool parameters"错误。这是一个普通的 `prompt` + `options` 调用。

永远不要施压让用户做出选择 —— 让他们自己思考。

---

### 阶段 3：核心循环设计

对于选定的概念，使用结构化提问来构建核心循环。
核心循环是游戏的心脏 —— 如果它在孤立状态下不有趣，
再多的内容或打磨也无法挽救这款游戏。

**30 秒循环**（即时体验）：

将以下问题作为 `AskUserQuestion` 调用提出 —— 从选定的概念中推导出选项，不要硬编码：

1. **核心动作手感** —— 提示："核心动作的主要手感是什么？" 生成 3-4 个符合概念题材和基调的选项，外加一个自由文本逃逸选项（`I'll describe it`）。

2. **关键设计维度** —— 识别此特定概念最重要的设计变量（例如，世界反应性、节奏、玩家能动性）并就此提问。生成符合概念的选项。始终包含一个自由文本逃逸选项。

捕获答案后，分析：这个动作本身是否令人满意？是什么让它感觉良好？（音频反馈、视觉张力、时机满足感、战术深度？）

**5 分钟循环**（短期目标）：
- 什么结构将即时体验组织成循环？
- "再来一局"/"再来一轮"的心理在哪里触发？
- 玩家在这个层级做出什么选择？

**会话循环**（30-120 分钟）：
- 一个完整的会话是什么样的？
- 自然的停止点在哪里？
- 什么"钩子"让他们在不玩游戏时也想着这款游戏？

**进度循环**（天/周）：
- 玩家如何成长？（力量？知识？选项？故事？）
- 长期目标是什么？游戏什么时候算"完成"？

**玩家动机分析**（基于自我决定理论）：
- **自主性**：玩家有多少有意义的选择？
- **胜任感**：玩家如何感受到技能的成长？
- **关联性**：玩家如何感受到连接（与角色、
  其他玩家，或世界）？

---

### 阶段 4：支柱与边界

游戏支柱被真正的 AAA 工作室（God of War、Hades、The Last of
Us）用来让数百名团队成员做出都指向
同一方向的决策。即使对于独立开发者，支柱也能防止范围蔓延并
保持愿景清晰。

协作定义 **3-5 个支柱**：
- 每个支柱有一个**名称**和**一句话定义**
- 每个支柱有一个**设计测试**："如果我们在 X 和 Y 之间争论，
  这个支柱说我们选择 __"
- 支柱之间应该感觉存在张力 —— 如果所有支柱都指向同一方向，
  它们就没有充分发挥作用

然后定义 **3 个以上的反支柱**（这款游戏不是什么）：
- 反支柱防止最常见的范围蔓延形式："如果加入...岂不是很酷"
  这种不服务于核心愿景的功能
- 表述为："我们不做 [某事]，因为它会损害 [支柱]"

**支柱确认**：展示完整支柱集后，使用 `AskUserQuestion`：
- 提示："Do these pillars feel right for your game?"
- 选项：`[A] Lock these in` / `[B] Rename or reframe one` / `[C] Swap a pillar out` / `[D] Something else`

如果用户选择 B、C 或 D，进行修订，然后再次使用 `AskUserQuestion`：
- 提示："Pillars updated. Ready to lock these in?"
- 选项：`[A] Lock these in` / `[B] Revise another pillar` / `[C] Something else`

重复直到用户选择 [A] Lock these in。

**审核模式检查** —— 在生成 CD-PILLARS 和 AD-CONCEPT-VISUAL 之前应用：
- `solo` → 跳过两者。备注："CD-PILLARS skipped — Solo mode. AD-CONCEPT-VISUAL skipped — Solo mode." 进入阶段 5。
- `lean` → 跳过两者（不是 PHASE-GATE）。备注："CD-PILLARS skipped — Lean mode. AD-CONCEPT-VISUAL skipped — Lean mode." 进入阶段 5。
- `full` → 正常生成。

**支柱和反支柱达成一致后，在并行中通过 Task 同时生成 `creative-director` 和 `art-director` —— 不要等待一个完成后再启动另一个。**

- **`creative-director`** —— gate **CD-PILLARS**（`.claude/docs/director-gates.md`）
  传递：完整的支柱集及设计测试、反支柱、核心幻想、独特卖点。

- **`art-director`** —— gate **AD-CONCEPT-VISUAL**（`.claude/docs/director-gates.md`）
  传递：游戏概念电梯演讲、完整的支柱集及设计测试、目标平台（如果已知）、用户提到的任何参考游戏或视觉标杆。

收集两个裁决，然后使用双标签页 `AskUserQuestion` 一起展示：
- 标签 **"Pillars"**：展示 creative-director 的反馈。选项镜像标准 CD-PILLARS 处理方式 —— `Lock in as-is` / `Revise [specific pillar]` / `Discuss further`。
- 标签 **"Visual anchor"**：展示 art-director 的 2-3 个命名视觉方向选项。选项：每个命名方向（每个选项一个）+ `Combine elements across directions` + `Describe my own direction`。

用户选择的视觉锚点（命名方向或他们的自定义描述）被存储为**视觉身份锚点** —— 它将被写入 game-concept 文档，并成为艺术圣经的基础。

如果 creative-director 对支柱返回 CONCERNS 或 REJECT，在请求视觉锚点选择之前先解决支柱问题 —— 视觉方向应从已确认的支柱中自然流淌出来。

---

### 阶段 5：玩家类型验证

使用 Bartle 分类法和 Quantic Foundry 动机模型，验证
这款游戏实际上是为谁打造的：

- **主要玩家类型**：谁会爱上这款游戏？（Achievers、Explorers、
  Socializers、Competitors、Creators、Storytellers）
- **次要吸引力**：还有谁可能会喜欢它？
- **这不是为谁打造的**：清楚谁不会喜欢这款游戏，
  与知道谁会喜欢它同样重要
- **市场验证**：有没有成功服务类似
  玩家类型的游戏？我们能从它们的受众规模中学到什么？

---

### 阶段 6：范围与可行性

将概念扎根于现实：

- **目标平台**：使用 `AskUserQuestion` —— "What platforms are you targeting for this game?"
  选项：`PC (Steam / Epic)` / `Mobile (iOS / Android)` / `Console` / `Web / Browser` / `Multiple platforms`
  记录答案 —— 它直接影响引擎推荐，并将传递给 `/setup-engine`。
  如有相关，注明平台影响（例如，移动端意味着强烈推荐 Unity；主机端意味着 Godot 有限制；Web 意味着 Godot 导出干净）。

- **引擎经验**：使用 `AskUserQuestion` —— "Do you already have an engine you work in?"
  选项：`Godot` / `Unity` / `Unreal Engine 5` / `No preference — help me decide`
  - 如果他们选择了一个引擎 → 将其记录为他们的偏好并继续。不要质疑它。
  - 如果选择 "No preference" → 告诉他们："Run `/setup-engine` after this session — it will walk you through the full decision based on your concept and platform target." 不要在此处做出推荐。
- **美术管线**：美术风格是什么，劳动密集度如何？
- **内容范围**：估算关卡/区域数量、物品数量、游戏时长
- **MVP 定义**：测试"核心循环是否有趣？"的绝对最小构建是什么？
- **最大风险**：技术风险、设计风险、市场风险
- **范围层级**：完整愿景是什么 vs 如果时间用完会交付什么？

**审核模式检查** —— 在生成 TD-FEASIBILITY 之前应用：
- `solo` → 跳过。备注："TD-FEASIBILITY skipped — Solo mode." 直接进入范围层级定义。
- `lean` → 跳过（不是 PHASE-GATE）。备注："TD-FEASIBILITY skipped — Lean mode." 直接进入范围层级定义。
- `full` → 正常生成。

**识别最大技术风险后，在定义范围层级之前通过 Task 使用 gate TD-FEASIBILITY（`.claude/docs/director-gates.md`）生成 `technical-director`。**

传递：核心循环描述、目标平台、引擎选择（或 "undecided"）、已识别的技术风险列表。

向用户展示评估。如果是 HIGH RISK，提供在最终确定前重新审视范围的机会。如果是 CONCERNS，记录它们并继续。

**审核模式检查** —— 在生成 PR-SCOPE 之前应用：
- `solo` → 跳过。备注："PR-SCOPE skipped — Solo mode." 进入文档生成。
- `lean` → 跳过（不是 PHASE-GATE）。备注："PR-SCOPE skipped — Lean mode." 进入文档生成。
- `full` → 正常生成。

**定义范围层级后，通过 Task 使用 gate PR-SCOPE（`.claude/docs/director-gates.md`）生成 `producer`。**

传递：完整愿景范围、MVP 定义、时间线估算、团队规模。

向用户展示评估。如果是 UNREALISTIC，提供在撰写文档前调整 MVP 定义或范围层级的机会。

---

4. **使用 `.claude/docs/templates/game-concept.md` 中的模板生成游戏概念文档**。
   填写来自头脑风暴对话的所有章节，包括 MDA 分析、玩家动机
   画像和心流状态设计章节。

   **在游戏概念文档中包含一个视觉身份锚点章节**，包含：
   - 选定的视觉方向名称
   - 一句话视觉规则
   - 2-3 条支持性视觉原则及其设计测试
   - 色彩理念摘要

   此章节是艺术圣经的种子 —— 它在会话之间尚未被遗忘之前，
   就捕捉了"一切必须动起来"的决策。

5. 使用 `AskUserQuestion` 获取写入批准：
- 提示："Game concept is ready. May I write it to `design/gdd/game-concept.md`?"
- 选项：`[A] Yes — write it` / `[B] Not yet — revise a section first`

如果选择 [B]：使用 `AskUserQuestion` 询问要修订哪个章节，选项为：`Elevator Pitch` / `Core Fantasy & Unique Hook` / `Pillars` / `Core Loop` / `MVP Definition` / `Scope Tiers` / `Risks` / `Something else — I'll describe`

修订后，以 diff 或清晰的 before/after 展示更新后的章节，然后使用 `AskUserQuestion` —— "Ready to write the updated concept document?"
选项：`[A] Yes — write it` / `[B] Revise another section`
重复直到用户选择 [A]。

如果选择是，使用 `.claude/docs/templates/game-concept.md` 中的模板生成文档，填写来自头脑风暴对话的所有章节，并写入文件，按需创建目录。

**范围一致性规则**：Core Identity 表格中的 "Estimated Scope" 字段必须与 Scope Tiers 章节的完整愿景时间线匹配 —— 不要只写 "Large (9+ months)"。应写为 "Large (X–Y months, solo)" 或 "Large (X–Y months, team of N)"，以便摘要表格准确。

6. **建议后续步骤**（按此顺序 —— 这是专业工作室的
   预生产管线）。列出所有步骤 —— 不要缩写或截断：
   1. "Run `/setup-engine` to configure the engine and populate version-aware reference docs"
   2. "Run `/art-bible` to create the visual identity specification — do this BEFORE writing GDDs. The art bible gates asset production and shapes technical architecture decisions (rendering, VFX, UI systems)."
   3. "Use `/design-review design/gdd/game-concept.md` to validate concept completeness before going downstream"
   4. "Discuss vision with the `creative-director` agent for pillar refinement"
   5. "Decompose the concept into individual systems with `/map-systems` — maps dependencies, assigns priorities, and creates the systems index"
   5. "Author per-system GDDs with `/design-system` — guided, section-by-section GDD writing for each system identified in step 4"
   6. "Plan the technical architecture with `/create-architecture` — produces the master architecture blueprint and Required ADR list"
   7. "Record key architectural decisions with `/architecture-decision (×N)` — write one ADR per decision in the Required ADR list from `/create-architecture`"
   8. "Validate readiness to advance with `/gate-check` — phase gate before committing to production"
   9. "Prototype the riskiest system with `/prototype [core-mechanic]` — validate the core loop before full implementation"
   10. "Run `/playtest-report` after the prototype to validate the core hypothesis"
   11. "If validated, plan the first sprint with `/sprint-plan new`"

7. **输出摘要**，包含选定概念的电梯演讲、支柱、
   主要玩家类型、引擎推荐、最大风险和文件路径。

裁决：**COMPLETE** — 游戏概念已创建并移交后续步骤。

---

## 上下文窗口意识

这是一个多阶段 Skill。如果在任何阶段上下文达到或超过 70%，
在继续之前将以下通知附加到当前响应：

> **Context is approaching the limit (≥70%).** The game concept document is saved
> to `design/gdd/game-concept.md`. Open a fresh Claude Code session to continue
> if needed — progress is not lost.

---

## 推荐的后续步骤

游戏概念撰写完成后，按顺序遵循预生产管线：
1. `/setup-engine` — 配置引擎并填充版本感知的参考文档
2. `/art-bible` — 在撰写任何 GDD 之前建立视觉身份
3. `/map-systems` — 将概念分解为带依赖关系的独立系统
4. `/design-system [first-system]` — 按依赖顺序撰写各系统 GDD
5. `/create-architecture` — 生成主架构蓝图
6. `/gate-check pre-production` — 在投入生产前验证就绪状态
