# CCGS Skill Testing Framework（技能测试框架）— Claude 使用说明

本文件夹是 Claude Code Game Studios skill/agent 框架的质量保证层。它是自包含的，与任何游戏项目分离。

## 关键文件

| 文件 | 用途 |
|------|---------|
| `catalog.yaml` | 所有 72 个 skills 和 49 个 agents 的主注册表。包含分类、spec 路径和上次测试跟踪字段。运行任何测试命令时始终首先读取此文件。 |
| `quality-rubric.md` | 特定分类的通过/失败指标。运行 `/skill-test category` 时，读取对应技能分类的 `###` 节。 |
| `skills/[category]/[name].md` | 技能的行为规范 — 5个测试用例 + 协议合规性断言。 |
| `agents/[tier]/[name].md` | Agent 的行为规范 — 5个测试用例 + 协议合规性断言。 |
| `templates/skill-test-spec.md` | 用于编写新技能规范文件的模板。 |
| `templates/agent-test-spec.md` | 用于编写新 Agent 规范文件的模板。 |
| `results/` | 由 `/skill-test spec` 在保存结果时写入。Git 忽略。 |

## 路径约定

- 技能规范：`CCGS Skill Testing Framework/skills/[category]/[name].md`
- Agent 规范：`CCGS Skill Testing Framework/agents/[tier]/[name].md`
- 目录：`CCGS Skill Testing Framework/catalog.yaml`
- 评分标准：`CCGS Skill Testing Framework/quality-rubric.md`

`catalog.yaml` 中的 `spec:` 字段是每个 skill/agent 规范的权威路径。始终读取此字段，而不是猜测路径。

## 技能分类

```
gate        → gate-check
review      → design-review, architecture-review, review-all-gdds
authoring   → design-system, quick-design, architecture-decision, art-bible,
              create-architecture, ux-design, ux-review
readiness   → story-readiness, story-done
pipeline    → create-epics, create-stories, dev-story, create-control-manifest,
              propagate-design-change, map-systems
analysis    → consistency-check, balance-check, content-audit, code-review,
              tech-debt, scope-check, estimate, perf-profile, asset-audit,
              security-audit, test-evidence-review, test-flakiness
team        → team-combat, team-narrative, team-audio, team-level, team-ui,
              team-qa, team-release, team-polish, team-live-ops
sprint      → sprint-plan, sprint-status, milestone-review, retrospective,
              changelog, patch-notes
utility     → all remaining skills
```

## Agent 层级

```
directors   → creative-director, technical-director, producer, art-director
leads       → lead-programmer, narrative-director, audio-director, ux-designer,
              qa-lead, release-manager, localization-lead
specialists → gameplay-programmer, engine-programmer, ui-programmer,
              tools-programmer, network-programmer, ai-programmer,
              level-designer, sound-designer, technical-artist
godot       → godot-specialist, godot-gdscript-specialist, godot-csharp-specialist,
              godot-shader-specialist, godot-gdextension-specialist
unity       → unity-specialist, unity-ui-specialist, unity-shader-specialist,
              unity-dots-specialist, unity-addressables-specialist
unreal      → unreal-specialist, ue-gas-specialist, ue-replication-specialist,
              ue-umg-specialist, ue-blueprint-specialist
operations  → devops-engineer, security-engineer, performance-analyst,
              analytics-engineer, community-manager
creative    → writer, world-builder, game-designer, economy-designer,
              systems-designer, prototyper
```

## 测试技能的工作流程

1.  读取 `catalog.yaml` 以获取技能的 `spec:` 路径和 `category:`
2.  读取位于 `.claude/skills/[name]/SKILL.md` 的技能
3.  在 `spec:` 路径读取规范
4.  逐条评估断言
5.  提议将结果写入 `results/` 并更新 `catalog.yaml`

## 改进技能的工作流程

使用 `/skill-improve [name]`。它处理完整的循环：测试 → 诊断 → 提出修复 → 重写 → 重新测试 → 保留或回滚。

## 规范有效性说明

此文件夹中的规范描述的是**当前行为**，而非理想行为。它们是通过读取技能编写的，因此可能编码了错误。当技能在实际中行为不当时，首先纠正技能，然后更新规范以匹配修复后的行为。将规范失败视为“需要调查”，而非“技能明确错误”。

## 此文件夹可删除

`.claude/` 中的内容不会从此处导入。删除此文件夹对 CCGS skills 或 agents 本身没有影响。`/skill-test` 和 `/skill-improve` 将报告 `catalog.yaml` 缺失，并引导用户初始化它。
