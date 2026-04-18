---
name: setup-engine
description: "配置项目的游戏引擎和版本。在 CLAUDE.md 中固定引擎，检测知识缺口，并在版本超出 LLM 训练数据时通过 WebSearch 填充引擎参考文档。"
argument-hint: "[engine] | [engine version] | refresh | upgrade [old-version] [new-version] | no args for guided selection"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, WebFetch, Task, AskUserQuestion
---

调用此 Skill 时：

## 1. 解析参数

四种模式：

- **完整规格**：`/setup-engine godot 4.6` —— 提供引擎和版本
- **仅引擎**：`/setup-engine unity` —— 提供引擎，将查找版本
- **无参数**：`/setup-engine` —— 完全引导模式（引擎推荐 + 版本）
- **刷新**：`/setup-engine refresh` —— 更新参考文档（见第 10 节）
- **升级**：`/setup-engine upgrade [old-version] [new-version]` —— 迁移到新引擎版本（见第 11 节）

---

## 2. 引导模式（无参数）

如果未指定引擎，运行交互式引擎选择过程：

### 检查现有游戏概念
- 如果存在，读取 `design/gdd/game-concept.md` —— 提取类型、范围、平台
  目标、艺术风格、团队规模和 `/brainstorm` 中的任何引擎推荐
- 如果不存在概念，通知用户：
  > "No game concept found。Consider running `/brainstorm` first to discover what
  > you want to build — it will also recommend an engine。Or tell me about your
  > game and I can help you pick。"

### 如果用户想在没有概念的情况下选择，按此顺序询问：

**问题 1 —— 先前经验**（首先，始终通过 `AskUserQuestion` 询问）：
- 提示："Have you worked in any of these engines before?"
- 选项：`Godot` / `Unity` / `Unreal Engine 5` / `Multiple — I'll explain` / `None of them`
- 如果他们选择特定引擎 → 推荐该引擎。先前经验胜过所有其他因素。与他们确认并跳过矩阵。
- 如果 "None" 或 "Multiple" → 继续以下问题。

**问题 2-6 —— 决策矩阵输入**（仅当没有先前引擎经验时）：

**问题 2 —— 目标平台**（其次，始终通过 `AskUserQuestion` 询问 —— 平台在任何其他因素之前消除或严重加权引擎）：
- 提示："What platforms are you targeting for this game?"
- 选项：`PC (Steam / Epic)` / `Mobile (iOS / Android)` / `Console` / `Web / Browser` / `Multiple platforms`
- 直接输入推荐的规则：
  - 移动 → 强烈推荐 Unity；Unreal 不适合；Godot 对于简单移动是可行的
  - 主机 → Unity 或 Unreal；Godot 主机支持需要第三方发行商或大量额外工作
  - Web → Godot 干净地导出到 web；Unity WebGL 可用；Unreal 的 web 支持差
  - 仅 PC → 所有引擎都可行；其他因素决定
  - 多平台 → Unity 是 PC/移动/主机之间最便携的

1. **What kind of game?** (2D, 3D, 或两者？)
2. **Primary input method?** (键盘/鼠标、手柄、触摸，或混合？)
3. **Team size and experience?** (单人初学者、单人有经验、小团队？)
4. **Any strong language preferences?** (GDScript, C#, C++, 可视化脚本？)
5. **Budget for engine licensing?** (仅免费，或商业许可可接受？)

### 产生推荐

不要使用简单的评分矩阵来消除引擎。相反，根据以下诚实权衡推理用户画像，然后提出 1-2 个推荐及完整上下文。始终以用户选择结束 —— 从不强制裁决。

**引擎诚实权衡：**

**Godot 4**
- 真正优势：2D（同类最佳）、风格化/独立 3D、快速迭代、永远免费（MIT）、开源、最温和的学习曲线、最适合想要完全控制的单人开发者
- 真正限制：与 Unity/Unreal 相比 3D 生态系统薄弱（教程、资源、3D 特定问题的社区答案较少）；大型开放世界 3D 非常难且在 Godot 中基本未经测试；主机导出需要第三方发行商或大量额外工作；专业就业市场较小
- 许可现实：真正免费，没有收入门槛。MIT 许可意味着你拥有一切。
- 最适合：任何范围的 2D 游戏；风格化/氛围 3D；封闭 3D 世界（非开放世界）；学习曲线重要的第一个游戏项目；预算在任何规模上都是硬约束的项目

**Unity**
- 真正优势：中等范围 3D 和移动的业界标准；庞大的资源商店和教程生态系统；C# 是专业语言；最适合独立开发者的主机认证支持；几乎每个类型的强大社区
- 真正限制：2023 年的许可争议损害了信任（运行时费用被提出然后撤回 —— 政策变化的风险仍然存在）；C# 比 GDScript 有更陡峭的初始曲线；对于简单项目比 Godot 更重的编辑器
- 许可现实：收入低于 20 万美元且安装量低于 20 万时免费（Unity Personal/Plus）。只有当游戏真正成功时才变得昂贵 —— 大多数独立游戏从未达到此门槛。2023 年的争议值得了解，但实际当前条款对于大多数独立开发者是合理的。
- 最适合：移动游戏；中等范围 3D；目标主机的游戏；有 C# 背景的开发者；需要大型资源商店的项目；2-5 人团队

**Unreal Engine 5**
- 真正优势：同类最佳的 3D 视觉效果（Lumen、Nanite、Chaos 物理）；AAA 和照片级真实 3D 的业界标准；大型开放世界支持成熟且经过生产测试；蓝图可视化脚本降低 C++ 门槛；非常适合目标高端 PC 或主机的游戏
- 真正限制：最陡峭的学习曲线；最重的编辑器（编译时间慢、项目文件大）；对于风格化/2D/小范围游戏过度；C++ 确实很难；不适合移动或 web；超过 100 万美元总收入后收取 5% 版税
- 许可现实：5% 版税仅在每款游戏超过 100 万美元总收入后才适用。对于第一款游戏或任何未达到 100 万美元的游戏，它不花费任何东西。这个门槛足够高，大多数独立开发者永远不会支付它。
- 最适合：AAA 质量 3D；大型开放世界游戏；照片级真实视觉效果；有 C++ 经验或愿意使用蓝图的开发者；目标高端 PC/主机的游戏，视觉保真度是核心卖点

**类型特定指导**（将其纳入推荐）：
- 任何风格 2D → 强烈推荐 Godot
- 3D 风格化 / 氛围 / 封闭世界 → Godot 可行，Unity 是可靠的替代方案
- 3D 开放世界（大型、无缝）→ Unity 或 Unreal；Godot 对此未经生产验证
- 3D 照片级真实 / AAA 质量 → Unreal
- 移动优先 → 强烈推荐 Unity
- 主机优先 → Unity 或 Unreal；Godot 主机支持需要额外工作
- 恐怖 / 叙事 / 步行模拟 → 任何引擎；匹配艺术风格和团队经验
- 动作 RPG / 类魂 → Unity 或 Unreal 用于 3D；社区支持和资源在这里很重要
- 2D 平台游戏 → Godot
- 策略 / 俯视 / RTS → Godot 或 Unity 取决于 2D vs 3D

**推荐格式：**
1. 显示比较表，用户的具体因素作为行
2. 给出带有诚实推理的主要推荐
3. 说出最佳替代方案及何时选择它
4. 明确声明："This is a starting point, not a verdict — you can always migrate engines, and many developers switch between projects。"
5. 使用 `AskUserQuestion` 确认："Does this recommendation feel right, or would you like to explore a different engine?"
   - 选项：`[Primary engine] (Recommended)` / `[Alternative engine]` / `[Third engine]` / `Explore further` / `Type something`

**如果用户选择 "Explore further"：**
使用 `AskUserQuestion` 进行概念特定的深入主题。始终从用户的实际概念生成这些选项 —— 不要使用通用选项。始终至少包括：
- 主要引擎对此概念的具体限制（例如 "How far can Godot 3D actually go for [genre]?"）
- 替代引擎对此概念的具体权衡
- 语言选择对此概念技术挑战的影响
- 任何概念特定的技术问题（例如自适应音频、开放世界流、多人网络代码）

用户可以选择多个主题。在返回引擎确认问题之前深入回答每个选择的主题。

---

## 3. 查找当前版本

选择引擎后：

- 如果提供了版本，使用它
- 如果未提供版本，使用 WebSearch 查找最新稳定版本：
  - 搜索：`"[engine] latest stable version [current year]"`
  - 与用户确认："The latest stable [engine] is [version]。Use this?"

---

## 4. 更新 CLAUDE.md 技术栈

### 语言选择（仅限 Godot）

如果选择 Godot，在显示提议的技术栈**之前**询问用户使用哪种语言：

> "Godot supports two primary languages:
>
>   **A) GDScript** —— Python-like, Godot-native, fastest iteration。Best for beginners, solo devs, and teams coming from Python or Lua。
>   **B) C#** —— .NET 8+, familiar to Unity developers, stronger IDE tooling (Rider / Visual Studio), slight performance advantage on heavy logic。
>   **C) Both** —— GDScript for gameplay/UI scripting, C# for performance-critical systems。Advanced setup — requires .NET SDK alongside Godot。
>
> Which will this project primarily use?"

记录选择。它确定 CLAUDE.md 模板、命名约定、专家路由和整个项目中为代码文件生成的 agent。

---

读取 `CLAUDE.md` 并向用户显示提议的技术栈更改。
询问："我可以将这些引擎设置写入 `CLAUDE.md` 吗？"

等待确认后再进行任何编辑。

更新技术栈章节，将 `[CHOOSE]` 占位符替换为实际值：

**对于 Godot** —— 使用与上述选择的语言匹配的模板。请参阅本 Skill 底部的 **附录 A** 了解所有三种变体（GDScript、C#、Both）。

**对于 Unity：**
```markdown
- **Engine**: Unity [version]
- **Language**: C#
- **Build System**: Unity Build Pipeline
- **Asset Pipeline**: Unity Asset Import Pipeline + Addressables
```

**对于 Unreal：**
```markdown
- **Engine**: Unreal Engine [version]
- **Language**: C++ (primary), Blueprint (gameplay prototyping)
- **Build System**: Unreal Build Tool (UBT)
- **Asset Pipeline**: Unreal Content Pipeline
```

---

## 5. 填充技术偏好

更新 CLAUDE.md 后，使用引擎适当的默认值创建或更新 `.claude/docs/technical-preferences.md`。首先阅读现有模板，然后填充：

### 引擎和语言章节
- 从步骤 4 中做出的引擎选择填充

### 命名约定（引擎默认）

**对于 Godot** —— 请参阅 **附录 A** 了解 GDScript、C# 和 Both 变体。

**对于 Unity (C#)：**
- 类：PascalCase（例如 `PlayerController`）
- 公共字段/属性：PascalCase（例如 `MoveSpeed`）
- 私有字段：_camelCase（例如 `_moveSpeed`）
- 方法：PascalCase（例如 `TakeDamage()`）
- 文件：PascalCase 匹配类（例如 `PlayerController.cs`）
- 常量：PascalCase 或 UPPER_SNAKE_CASE

**对于 Unreal (C++)：**
- 类：带前缀的 PascalCase（`A` 表示 Actor，`U` 表示 UObject，`F` 表示 struct）
- 变量：PascalCase（例如 `MoveSpeed`）
- 函数：PascalCase（例如 `TakeDamage()`）
- 布尔值：`b` 前缀（例如 `bIsAlive`）
- 文件：匹配类不带前缀（例如 `PlayerController.h`）

### 输入和平台章节

使用第 2 节中收集的答案（或从游戏概念中提取）填充 `## Input & Platform`。使用此映射派生值：

| 平台目标 | 手柄支持 | 触摸支持 |
|-----------------|-----------------|---------------|
| 仅 PC | Partial (recommended) | 无 |
| 主机 | Full | 无 |
| 移动 | 无 | Full |
| PC + 主机 | Full | 无 |
| PC + 移动 | Partial | Full |
| Web | Partial | Partial |

对于**主要输入**，使用游戏类型的主导输入：
- 目标主机的动作/RPG/平台游戏 → Gamepad
- 策略/点击/RTS → Keyboard/Mouse
- 移动游戏 → Touch
- 跨平台 → 询问用户

在写入前向用户展示派生值并请求确认或调整。

示例填充章节：
```markdown
## 输入和平台
- **目标平台**: PC, Console
- **输入方法**: Keyboard/Mouse, Gamepad
- **主要输入**: Gamepad
- **手柄支持**: Full
- **触摸支持**: 无
- **平台备注**: 所有 UI 必须支持 d-pad 导航。无仅悬停交互。
```

### 剩余章节
- **性能预算**：使用 `AskUserQuestion`：
  - 提示："Should I set default performance budgets now, or leave them for later?"
  - 选项：`[A] Set defaults now (60fps, 16.6ms frame budget, engine-appropriate draw call limit)` / `[B] Leave as [TO BE CONFIGURED] — I'll set these when I know my target hardware`
  - 如果 [A]：用建议的默认值填充。如果 [B]：保留为占位符。
- **测试**：建议引擎适当的框架（Godot 用 GUT，Unity 用 NUnit 等）—— 添加前询问。
- **禁止模式**：保留为占位符 —— 不要预先填充。
- **允许的库**：保留为占位符 —— 不要预先填充项目当前不需要的依赖。仅在主动集成时才添加库，而不是推测性地。

> **Guardrail**：永远不要向允许的库添加推测性依赖。例如，除非 Steam 集成正在本会话中主动开始，否则不要添加 GodotSteam。发布后集成应在该工作开始时添加到允许的库，而不是在引擎设置期间。

### 引擎专家路由

还在 `technical-preferences.md` 中填充 `## Engine Specialists` 章节，为所选引擎提供正确的路由：

**对于 Godot** —— 请参阅 **附录 A** 了解与所选语言匹配的路由表。

**对于 Unity：**
```markdown
## 引擎专家
- **主要**: unity-specialist
- **语言/代码专家**: unity-specialist (C# review — primary covers it)
- **着色器专家**: unity-shader-specialist (Shader Graph, HLSL, URP/HDRP materials)
- **UI 专家**: unity-ui-specialist (UI Toolkit UXML/USS, UGUI Canvas, runtime UI)
- **附加专家**: unity-dots-specialist (ECS, Jobs system, Burst compiler), unity-addressables-specialist (asset loading, memory management, content catalogs)
- **路由备注**: 为主要架构和通用 C# 代码审查调用 primary。为任何 ECS/Jobs/Burst 代码调用 DOTS specialist。为渲染和视觉效果调用着色器 specialist。为所有界面实现调用 UI specialist。为资源管理系统调用 Addressables specialist。

### 文件扩展名路由

| 文件扩展名 / 类型 | 要生成的 Specialist |
|-----------------------|---------------------|
| 游戏代码 (.cs files) | unity-specialist |
| 着色器 / 材质文件 (.shader, .shadergraph, .mat) | unity-shader-specialist |
| UI / 屏幕文件 (.uxml, .uss, Canvas prefabs) | unity-ui-specialist |
| 场景 / prefab / 关卡文件 (.unity, .prefab) | unity-specialist |
| 原生扩展 / 插件文件 (.dll, native plugins) | unity-specialist |
| 通用架构审查 | unity-specialist |
```

**对于 Unreal：**
```markdown
## 引擎专家
- **主要**: unreal-specialist
- **语言/代码专家**: ue-blueprint-specialist (Blueprint graphs) 或 unreal-specialist (C++)
- **着色器专家**: unreal-specialist (no dedicated shader specialist — primary covers materials)
- **UI 专家**: ue-umg-specialist (UMG widgets, CommonUI, input routing, widget styling)
- **附加专家**: ue-gas-specialist (Gameplay Ability System, attributes, gameplay effects), ue-replication-specialist (property replication, RPCs, client prediction, netcode)
- **路由备注**: 为 C++ 架构和广泛的引擎决策调用 primary。为蓝图图架构和 BP/C++ 边界设计调用 Blueprint specialist。为所有能力和属性代码调用 GAS specialist。为任何多人或网络系统调用 replication specialist。为所有 UI 实现调用 UMG specialist。

### 文件扩展名路由

| 文件扩展名 / 类型 | 要生成的 Specialist |
|-----------------------|---------------------|
| 游戏代码 (.cpp, .h files) | unreal-specialist |
| 着色器 / 材质文件 (.usf, .ush, Material assets) | unreal-specialist |
| UI / 屏幕文件 (.umg, UMG Widget Blueprints) | ue-umg-specialist |
| 场景 / prefab / 关卡文件 (.umap, .uasset) | unreal-specialist |
| 原生扩展 / 插件文件 (Plugin .uplugin, modules) | unreal-specialist |
| 蓝图图 (.uasset BP classes) | ue-blueprint-specialist |
| 通用架构审查 | unreal-specialist |
```

### 协作步骤
向用户展示填充的偏好。对于 Godot，包括所选语言并注明完整命名约定和路由表的位置：
> "Here are the default technical preferences for [engine] ([language if Godot])。The naming conventions and specialist routing are in Appendix A of this skill — I'll apply the [GDScript/C#/Both] variant。Want to customize any of these, or shall I save the defaults?"

对于所有其他引擎，直接呈现默认值而不引用附录。

在写入文件前等待批准。

---

## 6. 确定知识缺口

检查引擎版本是否可能超出 LLM 的训练数据。

**已知近似覆盖范围**（随模型变化更新）：
- LLM 知识截止：**May 2025**
- Godot：训练数据可能覆盖到 ~4.3
- Unity：训练数据可能覆盖到 ~2023.x / 早期 6000.x
- Unreal：训练数据可能覆盖到 ~5.3 / 早期 5.4

将用户选择的版本与这些基线进行比较：

- **在训练数据内** → `LOW RISK` —— 参考文档可选但推荐
- **接近边缘** → `MEDIUM RISK` —— 推荐参考文档
- **超出训练数据** → `HIGH RISK` —— 需要参考文档

告知用户他们属于哪个类别及原因。

---

## 7. 填充引擎参考文档

### 如果在训练数据内（LOW RISK）：

创建最小化 `docs/engine-reference/<engine>/VERSION.md`：

```markdown
# [Engine] —— 版本参考

| 字段 | 值 |
|-------|-------|
| **引擎版本** | [version] |
| **项目固定** | [今天的日期] |
| **LLM 知识截止** | May 2025 |
| **风险级别** | LOW —— 版本在 LLM 训练数据内 |

## 注意

此引擎版本在 LLM 的训练数据内。引擎参考
文档是可选的，但如果 agents 建议不正确的 API，可以稍后添加。

随时运行 `/setup-engine refresh` 以填充完整参考文档。
```

不要创建 breaking-changes.md、deprecated-apis.md 等 —— 它们会
增加上下文成本而价值最小。

### 如果超出训练数据（MEDIUM 或 HIGH RISK）：

通过网络搜索创建完整的参考文档集：

1. **搜索官方迁移/升级指南**：
   - `"[engine] [old version] to [new version] migration guide"`
   - `"[engine] [version] breaking changes"`
   - `"[engine] [version] changelog"`
   - `"[engine] [version] deprecated API"`

2. **从官方文档获取和提取**：
   - 从训练截止点到当前版本之间的每个版本的重大更改
   - 带有替换的已弃用 API
   - 新功能和最佳实践

询问："我可以在 `docs/engine-reference/<engine>/` 下创建引擎参考文档吗？"

在写入任何文件前等待确认。

3. **创建完整的参考目录**：
   ```
   docs/engine-reference/<engine>/
   ├── VERSION.md              # 版本固定 + 知识缺口分析
   ├── breaking-changes.md     # 版本间重大更改
   ├── deprecated-apis.md      # "不要使用 X → 使用 Y" 表
   ├── current-best-practices.md  # 训练截止点以来的新实践
   └── modules/                # 每子系统参考（按需创建）
   ```

4. **使用网络搜索的真实数据填充每个文件**，遵循
   现有参考文档中建立的格式。每个文件必须有
   "Last verified: [date]" 标题。

5. **对于模块文件**：仅为发生重大更改的子系统创建模块。
   不要创建空或最小化的模块文件。

---

## 8. 更新 CLAUDE.md 导入

询问："我可以更新 `CLAUDE.md` 中的 `@` 导入以指向新引擎参考吗？"

等待确认，然后更新 "Engine Version Reference" 下的 `@` 导入以指向
正确的引擎：

```markdown
## 引擎版本参考

@docs/engine-reference/<engine>/VERSION.md
```

如果之前的导入指向不同的引擎（例如从 Godot 切换到 Unity），更新它。

---

## 9. 更新 Agent 指令

询问："我可以在引擎专家 agent 文件中添加版本感知章节吗？" 在进行任何编辑之前。

对于所选引擎的专家 agents，验证他们是否有
"Version Awareness" 章节。如果没有，按照现有 Godot 专家 agents 中的模式添加一个。

该章节应指示 agent 执行以下操作：
1. 读取 `docs/engine-reference/<engine>/VERSION.md`
2. 在建议代码前检查已弃用的 API
3. 检查相关版本转换的重大更改
4. 使用 WebSearch 验证不确定的 API

---

## 10. 刷新子命令

如果以 `/setup-engine refresh` 调用：

1. 读取现有的 `docs/engine-reference/<engine>/VERSION.md` 以获取
   当前引擎和版本
2. 使用 WebSearch 检查：
   - 上次验证以来的新引擎发布
   - 更新的迁移指南
   - 新弃用的 API
3. 用新发现更新所有参考文档
4. 更新所有修改文件上的 "Last verified" 日期
5. 报告更改内容

---

## 11. 升级子命令

如果以 `/setup-engine upgrade [old-version] [new-version]` 调用：

### 步骤 1 —— 读取当前版本状态

读取 `docs/engine-reference/<engine>/VERSION.md` 以确认当前固定的
版本、风险级别和任何已记录的迁移说明 URL。如果
未提供 `old-version` 作为参数，使用此文件中固定的版本。

### 步骤 2 —— 获取迁移指南

使用 WebSearch 和 WebFetch 定位 `old-version` 和 `new-version` 之间的官方迁移指南：

- 搜索：`"[engine] [old-version] to [new-version] migration guide"`
- 搜索：`"[engine] [new-version] breaking changes changelog"`
- 如果 VERSION.md 中已记录，从 VERSION.md 获取迁移指南 URL，
  或使用搜索找到的 URL。

提取：重命名的 API、移除的 API、更改的默认值、行为更改和
任何 "必须迁移" 项。

### 步骤 3 —— 升级前审计

扫描 `src/` 以查找使用目标版本中已知已弃用或更改的 API 的代码：

- 使用 Grep 搜索从迁移指南提取的已弃用 API 名称（例如旧函数名、移除的节点类型、更改的属性名）
- 列出每个匹配的文件，找到的具体 API 引用

将审计结果显示为表格：

```
升级前审计: [engine] [old-version] → [new-version]
==========================================================

需要更改的文件：
  文件                              | 发现已弃用 API       | 工作量
  --------------------------------- | -------------------------- | ------
  src/gameplay/player_movement.gd   | old_api_name               | Low
  src/ui/hud.gd                     | removed_node_type          | Medium

需要注意的重大更改：
  - [来自迁移指南的更改描述]
  - [来自迁移指南的更改描述]

推荐的迁移顺序（按依赖排序）：
  1. [依赖最少的系统/层优先]
  2. [下一个系统]
  ...
```

如果在 `src/` 中未找到已弃用的 API，报告："No deprecated API usage
found in src/ — upgrade may be low-risk。"

### 步骤 4 —— 更新前确认

在进行任何更改前询问用户：

> "升级前审计完成。发现 [N] 个文件使用已弃用 API。
> 继续使用升级到 [new-version] 吗？
> （这将更新固定版本并添加迁移说明 —— 它不会
> 更改任何源文件。源迁移是手动完成或通过 Stories 完成。）"

继续前等待明确确认。

### 步骤 5 —— 更新 VERSION.md

确认后：

1. 更新 `docs/engine-reference/<engine>/VERSION.md`：
   - `Engine Version` → `[new-version]`
   - `Project Pinned` → 今天的日期
   - `Last Docs Verified` → 今天的日期
   - 如果新版本超出 LLM 知识截止点，重新评估并更新 `Risk Level` 和 `Post-Cutoff Version Timeline`
     表
   - 添加包含以下内容的 `## Migration Notes — [old-version] → [new-version]` 章节：
     迁移指南 URL、关键重大更改、本项目中发现的已弃用 API 以及审计中的推荐迁移顺序

2. 如果引擎参考目录中存在 `breaking-changes.md` 或 `deprecated-apis.md`，将新版本的更改附加到这些文件。

### 步骤 6 —— 升级后提醒

更新 VERSION.md 后，输出：

```
VERSION.md 已更新: [engine] [old-version] → [new-version]

后续步骤：
1. 迁移上述 [N] 个文件中列出的已弃用 API 使用
2. 升级实际引擎二进制文件后运行 /setup-engine refresh 以
   验证没有遗漏新的弃用
3. 运行 /architecture-review —— 引擎升级可能使引用特定 API 或引擎能力的 ADR 失效
4. 如果任何 ADR 失效，运行 /propagate-design-change 以更新
   下游 Stories
```

---

## 12. 输出摘要

设置完成后，输出：

```
引擎设置完成
=====================
引擎:          [name] [version]
语言:        [GDScript | C# | GDScript + C# | C# | C++ + Blueprint]
知识风险:  [LOW/MEDIUM/HIGH]
参考文档:  [created/skipped]
CLAUDE.md:       [updated]
技术偏好:      [created/updated]
Agent 配置:    [verified]

后续步骤：
1. Review docs/engine-reference/<engine>/VERSION.md
2. [If from /brainstorm] Run /map-systems to decompose your concept into individual systems
3. [If from /brainstorm] Run /design-system to author per-system GDDs (guided, section-by-section)
4. [If from /brainstorm] Run /prototype [core-mechanic] to test the core loop
5. [If fresh start] Run /brainstorm to discover your game concept
6. Create your first milestone: /sprint-plan new
```

---

裁决: **COMPLETE** —— 引擎已配置，参考文档已填充。

## 护栏

- 永远不要猜测引擎版本 —— 始终通过 WebSearch 或用户确认验证
- 永远不要在不询问的情况下覆盖现有参考文档 —— 追加或更新
- 如果参考文档已针对不同的引擎存在，在替换前询问
- 在编辑 CLAUDE.md 之前始终向用户展示要更改的内容
- 如果 WebSearch 返回不明确的结果，向用户展示并让他们决定
- 当用户选择 **GDScript** 时：完全从附录 A1 复制 GDScript CLAUDE.md 模板。永远不要向语言字段添加 "C++ via GDExtension"。GDScript 项目可能使用 GDExtension，但它不是主要项目语言。路由表中的 `godot-gdextension-specialist` 在需要原生扩展时可用 —— 它不会使 C++ 成为项目语言。

---

## 附录 A —— Godot 语言配置

语言相关配置的所有 Godot 特定变体。从第 4 和第 5 节引用 —— 仅当 Godot 是所选引擎时相关。使用与第 4 节中所选语言匹配的子章节。

---

### A1. CLAUDE.md 技术栈模板

**GDScript:**
```markdown
- **Engine**: Godot [version]
- **Language**: GDScript
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

> **Guardrail**：使用此 GDScript 模板时，将语言字段完全写为 "`GDScript`" —— 不要添加。不要附加 "C++ via GDExtension" 或任何其他语言。下面的 C# 模板包括 GDExtension，因为 C# 项目通常包装原生代码；GDScript 项目不这样做。

**C#:**
```markdown
- **Engine**: Godot [version]
- **Language**: C# (.NET 8+, primary), C++ via GDExtension (native plugins only)
- **Build System**: .NET SDK + Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

**Both —— GDScript + C#:**
```markdown
- **Engine**: Godot [version]
- **Language**: GDScript (gameplay/UI scripting), C# (performance-critical systems), C++ via GDExtension (native only)
- **Build System**: .NET SDK + Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline
```

---

### A2. 命名约定

**GDScript:**
- 类：PascalCase（例如 `PlayerController`）
- 变量/函数：snake_case（例如 `move_speed`）
- 信号：snake_case 过去时（例如 `health_changed`）
- 文件：snake_case 匹配类（例如 `player_controller.gd`）
- 场景：PascalCase 匹配根节点（例如 `PlayerController.tscn`）
- 常量：UPPER_SNAKE_CASE（例如 `MAX_HEALTH`）

**C#:**
- 类：PascalCase（`PlayerController`）—— 也必须是 `partial`
- 公共属性/字段：PascalCase（`MoveSpeed`, `JumpVelocity`）
- 私有字段：`_camelCase`（`_currentHealth`, `_isGrounded`）
- 方法：PascalCase（`TakeDamage()`, `GetCurrentHealth()`）
- 信号委托：PascalCase + `EventHandler` 后缀（`HealthChangedEventHandler`）
- 文件：PascalCase 匹配类（`PlayerController.cs`）
- 场景：PascalCase 匹配根节点（`PlayerController.tscn`）
- 常量：PascalCase（`MaxHealth`, `DefaultMoveSpeed`）

**Both —— GDScript + C#:**
对 `.gd` 文件使用 GDScript 约定，对 `.cs` 文件使用 C# 约定。混合语言文件不存在 —— 边界是按文件。当不确定新系统应该使用哪种语言时，询问用户并在 `technical-preferences.md` 中记录决策。

---

### A3. 引擎专家路由

**GDScript:**
```markdown
## 引擎专家
- **主要**: godot-specialist
- **语言/代码专家**: godot-gdscript-specialist (所有 .gd 文件)
- **着色器专家**: godot-shader-specialist (.gdshader 文件, VisualShader resources)
- **UI 专家**: godot-specialist (无专用 UI 专家 —— primary 覆盖所有 UI)
- **附加专家**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **路由备注**: 为架构决策、ADR 验证和跨领域代码审查调用 primary。为代码质量、信号架构、静态类型强制和 GDScript 习惯用法调用 GDScript specialist。为材质设计和着色器代码调用着色器 specialist。仅在涉及原生扩展时调用 GDExtension specialist。

### 文件扩展名路由

| 文件扩展名 / 类型 | 要生成的 Specialist |
|-----------------------|---------------------|
| 游戏代码 (.gd 文件) | godot-gdscript-specialist |
| 着色器 / 材质文件 (.gdshader, VisualShader) | godot-shader-specialist |
| UI / 屏幕文件 (Control nodes, CanvasLayer) | godot-specialist |
| 场景 / prefab / 关卡文件 (.tscn, .tres) | godot-specialist |
| 原生扩展 / 插件文件 (.gdextension, C++) | godot-gdextension-specialist |
| 通用架构审查 | godot-specialist |
```

**C#:**
```markdown
## 引擎专家
- **主要**: godot-specialist
- **语言/代码专家**: godot-csharp-specialist (所有 .cs 文件)
- **着色器专家**: godot-shader-specialist (.gdshader 文件, VisualShader resources)
- **UI 专家**: godot-specialist (无专用 UI 专家 —— primary 覆盖所有 UI)
- **附加专家**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **路由备注**: 为架构决策、ADR 验证和跨领域代码审查调用 primary。为代码质量、[Signal] 委托模式、[Export] 属性、.csproj 管理和 C# 特定的 Godot 习惯用法调用 C# specialist。为材质设计和着色器代码调用着色器 specialist。仅在涉及原生 C++ 插件时调用 GDExtension specialist。

### 文件扩展名路由

| 文件扩展名 / 类型 | 要生成的 Specialist |
|-----------------------|---------------------|
| 游戏代码 (.cs 文件) | godot-csharp-specialist |
| 着色器 / 材质文件 (.gdshader, VisualShader) | godot-shader-specialist |
| UI / 屏幕文件 (Control nodes, CanvasLayer) | godot-specialist |
| 场景 / prefab / 关卡文件 (.tscn, .tres) | godot-specialist |
| 项目配置 (.csproj, NuGet) | godot-csharp-specialist |
| 原生扩展 / 插件文件 (.gdextension, C++) | godot-gdextension-specialist |
| 通用架构审查 | godot-specialist |
```

**Both —— GDScript + C#:**
```markdown
## 引擎专家
- **主要**: godot-specialist
- **GDScript 专家**: godot-gdscript-specialist (.gd 文件 —— gameplay/UI 脚本)
- **C# 专家**: godot-csharp-specialist (.cs 文件 —— performance-critical systems)
- **着色器专家**: godot-shader-specialist (.gdshader 文件, VisualShader resources)
- **UI 专家**: godot-specialist (无专用 UI 专家 —— primary 覆盖所有 UI)
- **附加专家**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **路由备注**: 为跨语言架构决策和哪些系统属于哪种语言调用 primary。为 .gd 文件调用 GDScript specialist。为 .cs 文件和 .csproj 管理调用 C# specialist。在边界上优先选择信号而不是直接跨语言方法调用。

### 文件扩展名路由

| 文件扩展名 / 类型 | 要生成的 Specialist |
|-----------------------|---------------------|
| 游戏代码 (.gd 文件) | godot-gdscript-specialist |
| 游戏代码 (.cs 文件) | godot-csharp-specialist |
| 跨语言边界决策 | godot-specialist |
| 着色器 / 材质文件 (.gdshader, VisualShader) | godot-shader-specialist |
| UI / 屏幕文件 (Control nodes, CanvasLayer) | godot-specialist |
| 场景 / prefab / 关卡文件 (.tscn, .tres) | godot-specialist |
| 项目配置 (.csproj, NuGet) | godot-csharp-specialist |
| 原生扩展 / 插件文件 (.gdextension, C++) | godot-gdextension-specialist |
| 通用架构审查 | godot-specialist |
```
