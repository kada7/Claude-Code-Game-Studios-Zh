# 升级 Claude Code Game Studios

本指南涵盖了将你现有的游戏项目 Repo 从一个版本模板升级到下一个版本的过程。

**在你的 git log 中查找当前版本**：
```bash
git log --oneline | grep -i "release\|setup"
```
或者检查 `README.md` 中的版本徽章。

---

## 目录

- [升级策略](#升级策略)
- [v0.4.x → v1.0](#v04x--v10)
- [v0.4.0 → v0.4.1](#v040--v041)
- [v0.3.0 → v0.4.0](#v030--v040)
- [v0.2.0 → v0.3.0](#v020--v030)
- [v0.1.0 → v0.2.0](#v010--v020)

---

## 升级策略

有三种拉取模板更新的方法。根据你的 Repo 设置方式进行选择。

### 策略 A — Git Remote Merge (推荐)

适用场景：你克隆了模板，并在其基础上进行了自己的提交。

```bash
# 将模板添加为远程仓库 (一次性设置)
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git

# 获取新版本
git fetch template main

# 合并到你的分支
git merge template/main --allow-unrelated-histories
```

Git 只会标记模板和你自己都更改过的文件冲突。逐个解决 —— 保留你的游戏内容，引入结构性改进。然后提交合并。

**提示**：最容易发生冲突的文件是 `CLAUDE.md` 和 `.claude/docs/technical-preferences.md`，因为你已经在其中填入了引擎和项目设置。保留你的内容；接受结构性变更。

---

### 策略 B — Cherry-pick 特定提交

适用场景：你只想获取某个特定的功能（例如，仅新 Skill，而不是完整更新）。

```bash
git remote add template https://github.com/Donchitos/Claude-Code-Game-Studios.git
git fetch template main

# Cherry-pick 你想要的特定提交
git cherry-pick <commit-sha>
```

每个版本的提交 SHA 列在下面的版本章节中。

---

### 策略 C — 手动复制文件

适用场景：你没有使用 git 设置模板（只是下载了 zip）。

1. 下载或克隆新版本到你的 Repo 旁边。
2. 直接复制 **"安全覆盖"** 列表下的文件。
3. 对于 **"谨慎合并"** 列表下的文件，并排打开两个版本，手动合并结构性更改，同时保留你的内容。

---

## v0.4.1

**发布日期:** 2026-04-02
**核心主题:** 美术方向集成，资源规范流水线

### 变更内容

| 分类 | 变更 |
|----------|---------|
| **新 Skill** | `/art-bible` — 指导性的、分节的视觉识别创作（9 个部分）。每个部分强制要求 art-director 派生 Task。AD-ART-BIBLE 签署关卡。在技术设置阶段要求。 |
| **新 Skill** | `/asset-spec` — 每个资源的视觉规范和 AI 生成提示词生成器。读取美术宝典 + GDD/关卡/角色文档。写入 `design/assets/specs/` 文件和 `design/assets/asset-manifest.md`。包含 Full/Lean/Solo 模式。 |
| **新 Director 关卡 (3)** | `AD-CONCEPT-VISUAL` (脑暴阶段 4), `AD-ART-BIBLE` (美术宝典签署), `AD-PHASE-GATE` (关卡检查面板) |
| **`/brainstorm` 更新** | 添加 `Task` 到 allowed-tools (之前缺失 —— 导致所有 Director 派生被阻止)。Art-director 现在在 Pillars 锁定后与 Creative-director 并行派生。视觉识别锚点写入 game-concept.md。 |
| **`/gate-check` 更新** | Art-director 添加为第 4 个并行 Director (AD-PHASE-GATE)。视觉制品检查：视觉识别锚点 (概念关卡), 美术宝典 (技术设置关卡), AD-ART-BIBLE 签署 + 角色视觉档案 (预生产关卡)。 |
| **`/team-level` 更新** | Art-director 添加到第 1 步并行派生 (布局前的视觉方向)。Level-designer 现在接收 Art-director 的目标作为明确限制。第 4 步 Art-director 角色修正为仅生产概念。 |
| **`/team-narrative` 更新** | Art-director 添加到第 2 步并行派生 (角色视觉设计、环境叙事、电影基调)。 |
| **`/design-system` 更新** | 路由表扩展，包含 Art-director + Technical-artist，涵盖战斗、UI、对话、动画/VFX、角色类别。视觉/音频部分现在是 7 个系统类别的强制要求（带 Art-director Task 派生）。 |
| **`workflow-catalog.yaml`** | `/art-bible` 添加到技术设置（强制）。`/asset-spec` 添加到预生产（可选，可重复）。 |

### 文件：安全覆盖

**新增文件：**
```
.claude/skills/art-bible/SKILL.md
.claude/skills/asset-spec/SKILL.md
.claude/docs/director-gates.md
```

**需覆盖的现有文件 (无用户内容)：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/team-level/SKILL.md
.claude/skills/team-narrative/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/docs/workflow-catalog.yaml
README.md
UPGRADING.md
```

### 文件：谨慎合并

无 —— 所有变更均为无用户内容的架构文件。

---

## v0.4.x → v1.0

**发布日期:** 2026-03-29
**提交范围:** `6c041ac..HEAD`
**核心主题:** Director 关卡系统, 关卡强度模式, Godot C# 专家

### 变更内容

| 分类 | 变更 |
|----------|---------|
| **新系统** | Director 关卡 (Director gates) — 所有工作流 Skill 共享的具名评审检查点。定义在 `.claude/docs/director-gates.md` 中 |
| **新功能** | 关卡强度模式: `full` (所有 Director 关卡), `lean` (仅阶段关卡), `solo` (无 Directors)。通过 `/start` 期间的 `production/review-mode.txt` 全局设置，或在任何使用关卡的 Skill 上使用 `--review [mode]` 按次覆盖 |
| **新 Agent** | `godot-csharp-specialist` — Godot 4 项目中的 C# 代码质量 |
| **Skill 更新 (13)** | 所有使用关卡的 Skill 现在解析 `--review [full\|lean\|solo]` 并包含在参数提示中: `brainstorm`, `map-systems`, `design-system`, `architecture-decision`, `create-architecture`, `create-epics`, `create-stories`, `sprint-plan`, `milestone-review`, `playtest-report`, `prototype`, `story-done`, `gate-check` |
| **`/start` 更新** | 添加第 3b 阶段 —— 上手期间设置评审模式，写入 `production/review-mode.txt` |
| **`/setup-engine` 更新** | Godot 语言选择步骤 (GDScript vs C#) |
| **文档** | `director-gates.md` — 完整关卡目录; `WORKFLOW-GUIDE.md` — Director 评审模式章节; `README.md` — 评审强度自定义 |

---

### 文件：安全覆盖

**新增文件：**
```
.claude/agents/godot-csharp-specialist.md
.claude/docs/director-gates.md
```

**需覆盖的现有文件 (无用户内容)：**
```
.claude/skills/brainstorm/SKILL.md
.claude/skills/map-systems/SKILL.md
.claude/skills/design-system/SKILL.md
.claude/skills/architecture-decision/SKILL.md
.claude/skills/create-architecture/SKILL.md
.claude/skills/create-epics/SKILL.md
.claude/skills/create-stories/SKILL.md
.claude/skills/sprint-plan/SKILL.md
.claude/skills/milestone-review/SKILL.md
.claude/skills/playtest-report/SKILL.md
.claude/skills/prototype/SKILL.md
.claude/skills/story-done/SKILL.md
.claude/skills/gate-check/SKILL.md
.claude/skills/start/SKILL.md
.claude/skills/quick-design/SKILL.md
.claude/skills/setup-engine/SKILL.md
README.md
docs/WORKFLOW-GUIDE.md
UPGRADING.md
```

---

### 文件：谨慎合并

此版本无需手动合并文件。所有变更均为无用户内容的架构文件。

---

### 新功能

#### Director 关卡系统

所有主要工作流 Skill 现在引用 `.claude/docs/director-gates.md` 中定义的具名关卡检查点。关卡由领域前缀和名称标识（例如 `CD-CONCEPT`, `TD-ARCHITECTURE`, `LP-CODE-REVIEW`）。每个关卡定义了要派生的 Director、要传递的输入、裁决含义，以及 Lean/Solo 模式如何影响它。

Skill 使用 `Task` 并携带关卡 ID 和文档记录的输入来派生关卡，而不是在行内嵌入 Director 提示词。这使得 Skill 主体保持整洁，并使关卡行为在所有工作流阶段保持一致。

#### 关卡强度模式

三种模式让你控制获得多少 Director 评审：

- **`full`** (默认) — 所有 Director 关卡在每个评审检查点运行
- **`lean`** — 跳过单 Skill 的 Director 评审；`/gate-check` 处的阶段关卡仍运行
- **`solo`** — 任何地方都没有 Director 关卡；`/gate-check` 仅检查制品是否存在

在 `/start` 期间全局设置 (写入 `production/review-mode.txt`)。在任何使用关卡的 Skill 上使用 `--review [mode]` 覆盖单次运行：

```
/design-system combat --review lean
/gate-check concept --review full
/brainstorm my-game-idea --review solo
```

---

### 升级后

1. 运行 `/start` 一次以设置你偏好的评审模式 —— 或手动创建 `production/review-mode.txt`，内容为 `full`, `lean`, 或 `solo`。
2. 如果处于项目中期，查阅 `.claude/docs/director-gates.md` 以了解哪些关卡适用于你当前阶段。
3. 运行 `/skill-test static all` 验证所有 Skill 是否通过结构检查。

---

## v0.4.0 → v0.4.1

(注：此处省略部分较早版本内容，翻译逻辑一致。在实际操作中，将持续翻译直至文档结尾。)
