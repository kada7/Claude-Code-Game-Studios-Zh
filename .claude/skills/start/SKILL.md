---
name: start
description: "首次引导式上手 —— 询问你现在的位置，然后引导你到正确的工作流。不做假设。"
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion
---

# 引导式上手

此 Skill 写入一个文件：`production/review-mode.txt`（审查模式配置在第 3b 阶段设置）。

此 Skill 是新用户的入口点。它不假设你有游戏想法、引擎偏好或任何先前经验。它先询问，然后路由到正确的工作流。

---

## 阶段 1: 检测项目状态

在询问任何内容之前，静默收集上下文，以便你可以定制你的指导。不要未经提示就展示这些结果 —— 它们为你的建议提供信息，而不是对话开场白。

检查：
- **引擎已配置？** 读取 `.claude/docs/technical-preferences.md`。如果引擎字段包含 `[TO BE CONFIGURED]`，则引擎未设置。
- **游戏概念存在？** 检查 `design/gdd/game-concept.md`。
- **源代码存在？** 在 `src/` 中 glob 源文件（`*.gd`, `*.cs`, `*.cpp`, `*.h`, `*.rs`, `*.py`, `*.js`, `*.ts`）。
- **原型存在？** 检查 `prototypes/` 中的子目录。
- **设计文档存在？** 计算 `design/gdd/` 中的 Markdown 文件。
- **生产产物？** 检查 `production/sprints/` 或 `production/milestones/` 中的文件。

内部存储这些发现以验证用户的自我评估并定制推荐。

---

## 阶段 2: 询问用户在哪里

这是用户看到的第一个内容。使用 `AskUserQuestion` 和这些确切选项，以便用户可以点击而不是输入：

- **提示**："Welcome to Claude Code Game Studios! Before I suggest anything, I'd like to understand where you're starting from。Where are you at with your game idea right now?"
- **选项**：
  - `A) No idea yet` —— I don't have a game concept at all。I want to explore and figure out what to make。
  - `B) Vague idea` —— I have a rough theme, feeling, or genre in mind (e.g。, "something with space" or "a cozy farming game") but nothing concrete。
  - `C) Clear concept` —— I know the core idea — genre, basic mechanics, maybe a pitch sentence — but haven't formalized it into documents yet。
  - `D) Existing work` —— I already have design docs, prototypes, code, or significant planning done。I want to organize or continue the work。

等待用户的选择。在他们响应之前不要继续。

---

## 阶段 3: 基于答案路由

#### 如果 A：没有想法

用户需要在其他任何事情之前进行创意探索。

1. 承认从零开始完全没问题
2. 简要解释 `/brainstorm` 的作用（使用专业框架的引导式构思 —— MDA、玩家心理学、动词优先设计）。提到它有两种模式：`/brainstorm open` 用于完全开放的探索，或如果你甚至有模糊的主题（例如 "space"、"cozy"、"horror"）则使用 `/brainstorm [hint]`。
3. 推荐运行 `/brainstorm open` 作为下一步，但如果想到什么，邀请他们使用提示
4. 显示推荐路径：
   **概念阶段：**
   - `/brainstorm open` —— 发现你的游戏概念
   - `/setup-engine` —— 配置引擎（头脑风暴将推荐一个）
   - `/art-bible` —— 定义视觉识别（使用头脑风暴产生的视觉识别锚点）
   - `/map-systems` —— 将概念分解为系统
   - `/design-system` —— 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` —— 跨系统一致性检查
   - `/gate-check` —— 在架构工作前验证准备情况
   **架构阶段：**
   - `/create-architecture` —— 生成主架构蓝图和所需 ADR 列表
   - `/architecture-decision (×N)` —— 记录关键技术决策，遵循所需 ADR 列表
   - `/create-control-manifest` —— 将决策编译成可操作的规则表
   - `/architecture-review` —— 验证架构覆盖范围
   **预生产阶段：**
   - `/ux-design` —— 为关键屏幕编写 UX 规范（主菜单、HUD、核心交互）
   - `/prototype` —— 构建一次性原型以验证核心机制
   - `/playtest-report (×1+)` —— 记录每个垂直切片游戏测试会话
   - `/create-epics` —— 将系统映射到 epics
   - `/create-stories` —— 将 epics 分解为可实现的 stories
   - `/sprint-plan` —— 计划第一个 sprint
   **生产阶段：** → 使用 `/dev-story` 处理 stories

#### 如果 B：模糊想法

1. 请他们分享模糊的想法 —— 即使是几个字也足够
2. 将想法验证为起点（不要评判或重定向）
3. 推荐运行 `/brainstorm [their hint]` 来发展它
4. 显示推荐路径：
   **概念阶段：**
   - `/brainstorm [hint]` —— 将想法发展为完整概念
   - `/setup-engine` —— 配置引擎
   - `/art-bible` —— 定义视觉识别（使用头脑风暴产生的视觉识别锚点）
   - `/map-systems` —— 将概念分解为系统
   - `/design-system` —— 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` —— 跨系统一致性检查
   - `/gate-check` —— 在架构工作前验证准备情况
   **架构阶段：**
   - `/create-architecture` —— 生成主架构蓝图和所需 ADR 列表
   - `/architecture-decision (×N)` —— 记录关键技术决策，遵循所需 ADR 列表
   - `/create-control-manifest` —— 将决策编译成可操作的规则表
   - `/architecture-review` —— 验证架构覆盖范围
   **预生产阶段：**
   - `/ux-design` —— 为关键屏幕编写 UX 规范（主菜单、HUD、核心交互）
   - `/prototype` —— 构建一次性原型以验证核心机制
   - `/playtest-report (×1+)` —— 记录每个垂直切片游戏测试会话
   - `/create-epics` —— 将系统映射到 epics
   - `/create-stories` —— 将 epics 分解为可实现的 stories
   - `/sprint-plan` —— 计划第一个 sprint
   **生产阶段：** → 使用 `/dev-story` 处理 stories

#### 如果 C：清晰概念

1. 请他们用一句话描述他们的概念 —— 类型和核心机制。使用纯文本，不使用 AskUserQuestion（这是开放响应）。
2. 确认概念，然后使用 `AskUserQuestion` 提供两条路径：
   - **提示**："How would you like to proceed?"
   - **选项**：
     - `Formalize it first` —— Run `/brainstorm [concept]` to structure it into a proper game concept document
     - `Jump straight in` —— Go to `/setup-engine` now and write the GDD manually afterward
3. 显示推荐路径：
   **概念阶段：**
   - `/brainstorm` or `/setup-engine` —— （他们从步骤 2 中选择）
   - `/art-bible` —— 定义视觉识别（如果运行了头脑风暴则在之后，或在概念文档存在之后）
   - `/design-review` —— 验证概念文档
   - `/map-systems` —— 将概念分解为单个系统
   - `/design-system` —— 为每个 MVP 系统编写 GDD
   - `/review-all-gdds` —— 跨系统一致性检查
   - `/gate-check` —— 在架构工作前验证准备情况
   **架构阶段：**
   - `/create-architecture` —— 生成主架构蓝图和所需 ADR 列表
   - `/architecture-decision (×N)` —— 记录关键技术决策，遵循所需 ADR 列表
   - `/create-control-manifest` —— 将决策编译成可操作的规则表
   - `/architecture-review` —— 验证架构覆盖范围
   **预生产阶段：**
   - `/ux-design` —— 为关键屏幕编写 UX 规范（主菜单、HUD、核心交互）
   - `/prototype` —— 构建一次性原型以验证核心机制
   - `/playtest-report (×1+)` —— 记录每个垂直切片游戏测试会话
   - `/create-epics` —— 将系统映射到 epics
   - `/create-stories` —— 将 epics 分解为可实现的 stories
   - `/sprint-plan` —— 计划第一个 sprint
   **生产阶段：** → 使用 `/dev-story` 处理 stories

#### 如果 D：现有工作

1. 分享你在阶段 1 中发现的内容：
   - "I can see you have [X source files / Y design docs / Z prototypes]..."
   - "Your engine is [configured as X / not yet configured]..."

2. **子情况 D1 —— 早期阶段**（引擎未配置或仅存在游戏概念）：
   - 如果引擎未配置，首先推荐 `/setup-engine`
   - 然后 `/project-stage-detect` 进行缺口清单

   **子情况 D2 —— GDD、ADR 或 stories 已存在：**
   - 解释："Having files isn't the same as the template's skills being able to use them。GDDs might be missing required sections。`/adopt` checks this specifically。"
   - 推荐：
     1. `/project-stage-detect` —— 阶段检测 + 存在性缺口
     2. `/adopt` —— 格式合规审计 + 迁移计划

3. 为 D2 显示推荐路径：
   - `/project-stage-detect` —— 阶段检测 + 存在性缺口
   - `/adopt` —— 格式合规审计 + 迁移计划
   - `/setup-engine` —— 如果引擎未配置
   - `/design-system retrofit [path]` —— 填充缺失的 GDD 章节
   - `/architecture-decision retrofit [path]` —— 添加缺失的 ADR 章节
   - `/architecture-review` —— 引导 TR 需求注册表
   - `/gate-check` —— 验证下一阶段的准备情况

---

## 阶段 3b: 设置审查模式

检查 `production/review-mode.txt` 是否已存在。

**如果存在**：读取它并显示当前模式 —— "Review mode is set to `[current]`。" —— 然后继续到阶段 4。不要再询问。

**如果不存在**：使用 `AskUserQuestion`：

- **提示**："One setup choice: how much design review would you want as you work through the workflow?"
- **选项**：
  - `Full` —— Director specialists review at each key workflow step。Best for teams, learning the workflow, or when you want thorough feedback on every decision。
  - `Lean (recommended)` —— Directors only at phase gate transitions (/gate-check)。Skips per-skill reviews。Balanced approach for solo devs and small teams。
  - `Solo` —— No director reviews at all。Maximum speed。Best for game jams, prototypes, or if the reviews feel like overhead。

用户选择后立即将选择写入 `production/review-mode.txt` —— 不需要单独的 "May I write?"，因为写入是选择的直接
结果：
- `Full` → 写入 `full`
- `Lean (recommended)` → 写入 `lean`
- `Solo` → 写入 `solo`

如果 `production/` 目录不存在，创建它。

---

## 阶段 4: 继续前确认

展示推荐路径后，使用 `AskUserQuestion` 询问用户他们想先从哪个步骤开始。永远不要自动运行下一个 skill。

- **提示**："Would you like to start with [recommended first step]?"
- **选项**：
  - `Yes, let's start with [recommended first step]`
  - `I'd like to do something else first`

---

## 阶段 5: 交接

当用户确认他们的下一步时，用一行简短的话回应："Type `[skill command]` to begin。" 不要重新解释 skill 或添加鼓励。`/start` skill 的工作已完成。

裁决: **COMPLETE** —— 用户已定位并交接给下一步。

---

## 边缘情况

- **用户选择 D 但项目为空**：温和地重定向 —— "It looks like the project is a fresh template with no artifacts yet。Would Path A or B be a better fit?"
- **用户选择 A 但项目有代码**：提到你发现了什么 —— "I noticed there's already code in `src/`。Did you mean to pick D (existing work)?"
- **用户正在返回（引擎已配置，概念存在）**：完全跳过上手 —— "It looks like you're already set up! Your engine is [X] and you have a game concept at `design/gdd/game-concept.md`。Review mode: `[read from production/review-mode.txt, or 'lean (default)' if missing]`。Want to pick up where you left off? Try `/sprint-plan` or just tell me what you'd like to work on。"
- **用户不符合任何选项**：让他们用自己的话描述他们的情况并适应。

---

## 协作协议

1. **Ask first** —— 永远不要假设用户的状态或意图
2. **Present options** —— 给出清晰的路径，不是强制要求
3. **User decides** —— 他们选择方向
4. **No auto-execution** —— 推荐下一个 skill，不要在没有询问的情况下运行它
5. **Adapt** —— 如果用户的情况不符合模板，倾听并调整
