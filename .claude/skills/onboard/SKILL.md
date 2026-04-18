---
name: onboard
description: "为新加入项目的贡献者或代理生成情境化的入职文档。总结项目状态、架构、规范以及与指定角色或领域相关的当前优先级。"
argument-hint: "[role|area]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
model: haiku
---

## Phase 1: Load Project Context

读取 CLAUDE.md 获取项目概述和标准。

如果指定了特定角色，从 `.claude/agents/` 读取相关的代理定义。

---

## Phase 2: Scan Relevant Area

- 对于程序员：扫描 `src/` 获取架构、模式、关键文件
- 对于设计师：扫描 `design/` 获取现有的设计文档
- 对于 narrative：扫描 `design/narrative/` 获取 world-building 和 story docs
- 对于 QA：扫描 `tests/` 获取现有的测试覆盖率
- 对于 production：扫描 `production/` 获取当前的 sprint 和 milestone

读取最近的更改（如果可用则使用 git log）以了解当前的 momentum。

---

## Phase 3: Generate Onboarding Document

```markdown
# Onboarding: [Role/Area]

## Project Summary
[2-3 句话的摘要，说明这是什么游戏及其当前状态]

## Your Role
[此角色在此项目中的作用、关键职责、你向谁报告]

## Project Architecture
[与此角色相关的架构概述]

### Key Directories
| Directory | Contents | Your Interaction |
|-----------|----------|-----------------|

### Key Files
| File | Purpose | Read Priority |
|------|---------|--------------|

## Current Standards and Conventions
[来自 CLAUDE.md 和代理定义的与此角色相关的约定摘要]

## Current State of Your Area
[已构建的内容、正在进行的内容、接下来计划的内容]

## Current Sprint Context
[团队现在正在做什么以及对此角色的期望]

## Key Dependencies
[此角色最常交互的其他角色/系统]

## Common Pitfalls
[新贡献者在此领域容易遇到的问题]

## First Tasks
[建议的入门和提高生产力的首批任务]

1. [首先阅读这些文档]
2. [审查此代码/内容]
3. [从这个小任务开始]

## Questions to Ask
[新贡献者应该问的问题以完全适应]
```

---

## Phase 4: Save Document

向用户展示入职文档。

询问："我可以将此写入 `production/onboarding/onboard-[role]-[date].md` 吗？"

如果是，写入文件，如果需要则创建目录。

---

## Phase 5: Next Steps

Verdict: **COMPLETE** — 入职文档已生成。

- 在第一个 session 之前与新贡献者分享入职文档。
- 运行 `/sprint-status` 向新贡献者展示当前进度。
- 如果贡献者需要下一步工作的指导，运行 `/help`。
