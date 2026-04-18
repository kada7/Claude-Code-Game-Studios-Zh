---
name: content-audit
description: "审核GDD中规定的内容数量与已实现内容对比。识别计划中与实际构建的内容差距。"
argument-hint: "[system-name | --summary | (no arg = full audit)]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
agent: producer
---

调用此 skill 时:

解析参数:
- 无参数 → 所有系统的完整审核
- `[system-name]` → 仅审核该单个系统
- `--summary` → 仅摘要表，不写入文件

---

## 阶段 1 — 上下文收集

1. **读取 `design/gdd/systems-index.md`** 获取系统完整列表、它们的
   类别和 MVP/优先级层级。

2. **L0 预扫描**: 在完整读取任何 GDD 之前，Grep 所有 GDD 文件查找
   `## Summary` 部分加上常见内容计数关键字:
   ```
   Grep pattern="(## Summary|N enemies|N levels|N items|N abilities|enemy types|item types)" glob="design/gdd/*.md" output_mode="files_with_matches"
   ```
   对于单系统审核: 跳过此步骤并直接进行完整读取。
   对于完整审核: 仅完整读取匹配内容计数关键字的 GDD。
   没有内容计数语言的 GDD (纯机制 GDD) 被记录为
   "No auditable content counts" 而无需完整读取。

3. **完整读取范围内的 GDD 文件** (如果给定系统名称，则读取单个系统 GDD)。

4. **对于每个 GDD，提取显式内容计数或列表。** 查找模式
   如:
   - "N enemies" / "enemy types:" / 命名敌人列表
   - "N levels" / "N areas" / "N maps" / "N stages"
   - "N items" / "N weapons" / "N equipment pieces"
   - "N abilities" / "N skills" / "N spells"
   - "N dialogue scenes" / "N conversations" / "N cutscenes"
   - "N quests" / "N missions" / "N objectives"
   - 任何显式枚举列表 (命名内容片段的项目符号列表)

4. **从提取的数据构建内容清单表**:

   | System | Content Type | Specified Count/List | Source GDD |
   |--------|-------------|---------------------|------------|

   注意: 如果 GDD 定性描述内容但未给出计数，记录
   "Unspecified" 并标记 — 未指定计数是值得注意的设计差距。

---

## 阶段 2 — 实现扫描

对于阶段 1 中发现的每个内容类型，扫描相关目录以计算
已实现的内容。使用 Glob 和 Grep 定位文件。

**关卡 / 区域 / 地图:**
- Glob `assets/**/*.tscn`, `assets/**/*.unity`, `assets/**/*.umap`
- Glob `src/**/*.tscn`, `src/**/*.unity`
- 查找 `levels/`, `areas/`, `maps/` 子目录中的场景文件,
  `worlds/`, `stages/`
- 计算显示为关卡/场景定义的唯一文件 (不包括 UI 场景)

**敌人 / 角色 / NPCs:**
- Glob `assets/data/**/enemies/**`, `assets/data/**/characters/**`
- Glob `src/**/enemies/**`, `src/**/characters/**`
- 查找定义实体状态的 `.json`, `.tres`, `.asset`, `.yaml` 数据文件
- 查找角色子目录中的场景/prefab 文件

**物品 / 装备 / 战利品:**
- Glob `assets/data/**/items/**`, `assets/data/**/equipment/**`,
  `assets/data/**/loot/**`
- 查找 `.json`, `.tres`, `.asset` 数据文件

**能力 / 技能 / 法术:**
- Glob `assets/data/**/abilities/**`, `assets/data/**/skills/**`,
  `assets/data/**/spells/**`
- 查找 `.json`, `.tres`, `.asset` 数据文件

**对话 / 对话 / 过场动画:**
- Glob `assets/**/*.dialogue`, `assets/**/*.csv`, `assets/**/*.ink`
- Grep `assets/data/` 中的对话数据文件

**任务 / 使命:**
- Glob `assets/data/**/quests/**`, `assets/data/**/missions/**`
- 查找 `.json`, `.yaml` 定义文件

**引擎特定说明 (在报告中承认):**
- 计数是近似值 — skill 无法完美解析每个引擎
  格式或区分仅编辑器文件与发布内容
- 场景文件可能包括游戏内容以及系统/UI 场景; 扫描
  计算所有匹配并记录此警告

---

## 阶段 3 — 差距报告

生成差距表:

```
| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|
```

**状态类别:**
- `COMPLETE` — Found ≥ Specified (100%+)
- `IN PROGRESS` — Found 是 Specified 的 50–99%
- `EARLY` — Found 是 Specified 的 1–49%
- `NOT STARTED` — Found 是 0

**优先级标志:**
如果满足以下条件，将系统标记为 `HIGH PRIORITY`:
- 状态为 `NOT STARTED` 或 `EARLY`，且
- 系统被标记为 systems index 中的 MVP 或 Vertical Slice，或
- systems index 显示系统阻塞下游系统

**摘要行:**
- 指定的总内容项 (所有 Specified 列值的总和)
- 发现的总内容项 (所有 Found 列值的总和)
- 整体差距百分比: `(Specified - Found) / Specified * 100`

---

## 阶段 4 — 输出

### 完整审核和单系统模式

向用户展示差距表和摘要。询问: "我可以将完整报告写入 `docs/content-audit-[YYYY-MM-DD].md` 吗?"

如果同意，写入文件:

```markdown
# Content Audit — [Date]

## Summary
- **Total specified**: [N] content items across [M] systems
- **Total found**: [N]
- **Gap**: [N] items ([X%] unimplemented)
- **Scope**: [Full audit | System: name]

> 注意: 计数基于文件扫描的近似值。
> 审核无法区分发布内容与编辑器/测试资产。
> 对于任何 HIGH PRIORITY 差距，建议手动验证。

## Gap Table

| System | Content Type | Specified | Found | Gap | Status |
|--------|-------------|-----------|-------|-----|--------|

## HIGH PRIORITY Gaps

[列出标记为 HIGH PRIORITY 的系统及理由]

## Per-System Breakdown

### [System Name]
- **GDD**: `design/gdd/[file].md`
- **审核的内容类型**: [list]
- **Notes**: [关于此系统扫描准确性的任何警告]

## Recommendation

将实施工作重点放在:
1. [Highest-gap HIGH PRIORITY system]
2. [Second system]
3. [Third system]

## Unspecified Content Counts

以下 GDD 描述内容但未给出显式计数。
考虑添加计数以提高可审核性:
[列出带有 "Unspecified" 的 GDD 和内容类型]
```

写入报告后，询问:

> "您想为任何内容差距创建 backlog stories 吗?"

如果同意: 对于用户选择的每个系统，建议一个 story 标题并指向
`/create-stories [epic-slug]` 或 `/quick-design`，取决于差距的大小。

### --summary 模式

将差距表和摘要直接打印到对话。不写入文件。
以: "运行 `/content-audit` 不带 `--summary` 以写入完整报告。" 结束。

---

## 阶段 5 — 后续步骤

审核后，推荐最高价值的后续行动:

- 如果任何系统为 `NOT STARTED` 并标记为 MVP → "运行 `/design-system [name]` 以
  在开始前添加缺失的内容计数到 GDD。"
- 如果总差距 >50% → "运行 `/sprint-plan` 以在即将进行的冲刺中分配内容工作。"
- 如果需要 backlog stories → "为每个 HIGH PRIORITY 差距运行 `/create-stories [epic-slug]`。"
- 如果使用了 `--summary` → "运行 `/content-audit` (无标志) 以将完整报告写入 `docs/`。"

裁决: **COMPLETE** — 内容审核完成。
