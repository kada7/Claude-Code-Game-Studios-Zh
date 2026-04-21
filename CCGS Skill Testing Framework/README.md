# CCGS Skill Testing Framework（技能测试框架）

**Claude Code Game Studios** 框架的质量保证基础设施。
测试 Skill 和 Agent 本身 —— 而非使用它们构建的任何游戏。

> **此文件夹是独立的且可选的。**
> 使用 CCGS 的游戏开发者不需要它。若要完全移除：
> `rm -rf "CCGS Skill Testing Framework"` —— `.claude/` 中没有任何内容依赖它。

---

## 这里面有什么

```
CCGS Skill Testing Framework/
├── README.md              ← 你在这里
├── CLAUDE.md              ← 告诉 Claude 如何使用此框架
├── catalog.yaml           ← 主注册表：所有 72 个 Skill + 49 个 Agent，覆盖率跟踪
├── quality-rubric.md      ← /skill-test category 的类别特定通过/失败指标
│
├── skills/                ← Skill 的行为规范文件 (每个 Skill 一个)
│   ├── gate/              ← gate 类别规范
│   ├── review/            ← review 类别规范
│   ├── authoring/         ← authoring 类别规范
│   ├── readiness/         ← readiness 类别规范
│   ├── pipeline/          ← pipeline 类别规范
│   ├── analysis/          ← analysis 类别规范
│   ├── team/              ← team 类别规范
│   ├── sprint/            ← sprint 类别规范
│   └── utility/           ← utility 类别规范
│
├── agents/                ← Agent 的行为规范文件 (每个 Agent 一个)
│   ├── directors/         ← creative-director, technical-director, producer, art-director
│   ├── leads/             ← lead-programmer, narrative-director, audio-director, 等
│   ├── specialists/       ← 引擎/代码/着色器/UI 专家
│   ├── godot/             ← Godot 专属专家
│   ├── unity/             ← Unity 专属专家
│   ├── unreal/            ← Unreal 专属专家
│   ├── operations/        ← QA, live-ops, 发布, 本地化, 等
│   └── creative/          ← writer, world-builder, game-designer, 等
│
├── templates/             ← 编写新规范的规范文件模板
│   ├── skill-test-spec.md ← Skill 行为规范模板
│   └── agent-test-spec.md ← Agent 行为规范模板
│
└── results/               ← 测试运行输出 (由 /skill-test spec 写入, 被 gitignore)
```

---

## 如何使用

所有测试均由框架中已有的两个 Skill 驱动：

### 检查结构合规性

```
/skill-test static [skill-name]     # 检查一个 Skill (7 项检查)
/skill-test static all              # 检查所有 72 个 Skill
```

### 运行行为规范测试

```
/skill-test spec gate-check         # 根据其编写的规范评估 Skill
/skill-test spec design-review
```

### 根据类别评价指标进行检查

```
/skill-test category gate-check     # 根据类别指标评估一个 Skill
/skill-test category all            # 运行跨所有已分类 Skill 的评价指标检查
```

### 查看全覆盖视图

```
/skill-test audit                   # Skill + Agent: 是否有规范, 最后测试时间, 结果
```

### 改进有缺陷的 Skill

```
/skill-improve gate-check           # 测试 → 诊断 → 提出修复 → 循环重新测试
```

---

## Skill 类别

| 类别 | Skill | 关键指标 |
|----------|--------|-------------|
| `gate` | gate-check | 读取评审模式, full/lean/solo director 面板, 禁止自动前进 |
| `review` | design-review, architecture-review, review-all-gdds | 只读, 8 章节检查, 正确的裁决 |
| `authoring` | design-system, quick-design, art-bible, create-architecture, … | 分节 May-I-write, 先创建骨架 |
| `readiness` | story-readiness, story-done | 表面化阻碍项, full 模式下的 director 关卡 |
| `pipeline` | create-epics, create-stories, dev-story, map-systems, … | 上游依赖检查, 移交路径清晰 |
| `analysis` | consistency-check, balance-check, code-review, tech-debt, … | 只读报告, 裁决关键字, 禁止写入 |
| `team` | team-combat, team-narrative, team-audio, … | 所有必需 Agent 已派生, 表面化阻碍项 |
| `sprint` | sprint-plan, sprint-status, milestone-review, … | 读取 Sprint 数据, 状态关键字存在 |
| `utility` | start, adopt, hotfix, localize, setup-engine, … | 通过静态检查 |

---

## Agent 层级

| 层级 | Agent |
|------|--------|
| `directors` | creative-director, technical-director, producer, art-director |
| `leads` | lead-programmer, narrative-director, audio-director, ux-designer, qa-lead, release-manager, localization-lead |
| `specialists` | gameplay-programmer, engine-programmer, ui-programmer, tools-programmer, network-programmer, ai-programmer, level-designer, sound-designer, technical-artist |
| `godot` | godot-specialist, godot-gdscript-specialist, godot-csharp-specialist, godot-shader-specialist, godot-gdextension-specialist |
| `unity` | unity-specialist, unity-ui-specialist, unity-shader-specialist, unity-dots-specialist, unity-addressables-specialist |
| `unreal` | unreal-specialist, ue-gas-specialist, ue-replication-specialist, ue-umg-specialist, ue-blueprint-specialist |
| `operations` | devops-engineer, security-engineer, performance-analyst, analytics-engineer, community-manager |
| `creative` | writer, world-builder, game-designer, economy-designer, systems-designer, prototyper |

---

## 更新目录

`catalog.yaml` 跟踪每个 Skill 和 Agent 的测试覆盖率。运行测试后：

- `/skill-test spec [name]` 将提示更新 `last_spec` 和 `last_spec_result`
- `/skill-test category [name]` 将提示更新 `last_category` 和 `last_category_result`
- `last_static` 和 `last_static_result` 手动更新或通过 `/skill-improve` 更新

---

## 编写新规范

1. 在 `templates/skill-test-spec.md` 找到规范模板
2. 将其复制到 `skills/[category]/[skill-name].md`
3. 更新 `catalog.yaml` 中的 `spec:` 字段以指向新文件
4. 运行 `/skill-test spec [skill-name]` 进行验证

---

## 移除此框架

此文件夹没有对主项目的 Hook。若要移除：

```bash
rm -rf "CCGS Skill Testing Framework"
```

Skill `/skill-test` 和 `/skill-improve` 仍将发挥作用 —— 它们只会报告 `catalog.yaml` 缺失，并建议运行 `/skill-test audit` 来初始化它。
