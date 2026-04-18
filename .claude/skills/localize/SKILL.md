---
name: localize
description: "完整本地化流水线：扫描硬编码字符串、提取和管理字符串表、验证翻译、生成译者简报、运行文化/敏感性审查、管理配音本地化、测试RTL/平台要求、强制执行字符串冻结，并报告覆盖率。"
argument-hint: "[scan|extract|validate|status|brief|cultural-review|vo-pipeline|rtl-check|freeze|qa]"
user-invocable: true
agent: localization-lead
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion
---

# Localization Pipeline

本地化不仅仅是翻译 — 它是使游戏在每个语言和地区都感觉本地的完整过程。糟糕的本地化会破坏沉浸感，
让玩家困惑，并阻止平台认证。此技能涵盖从字符串提取到文化审查、VO 录音、RTL 布局测试和本地化 QA 签署的完整流水线。

**模式：**
- `scan` — 查找硬编码字符串和本地化反模式（只读）
- `extract` — 提取字符串并生成可翻译的表
- `validate` — 检查翻译的完整性、占位符和长度
- `status` — 所有语言环境的覆盖矩阵
- `brief` — 为外部团队生成译者上下文简报文档
- `cultural-review` — 标记文化敏感内容、符号、颜色、习语
- `vo-pipeline` — 管理 voice-over 本地化：scripts, recording specs, integration
- `rtl-check` — 验证 RTL 语言布局、镜像和字体支持
- `freeze` — 强制执行字符串冻结；在翻译开始前锁定源字符串
- `qa` — 在发布前运行完整的本地化 QA 周期

如果没有提供子命令，输出用法并停止。Verdict: **FAIL** — 缺少必需的子命令。

---

## Phase 2A: Scan Mode

在 `src/` 中搜索硬编码的用户 facing 字符串：

- UI code 中没有包装在本地化函数中的字符串文字（`tr()`, `Tr()`, `NSLocalizedString`, `GetText`, 等）
- 应该参数化的连接字符串
- 带有位置占位符（`%s`, `%d`）而不是命名占位符（`{playerName}`）的字符串
- 混合 locale-sensitive 数据（numbers, dates, currencies）而不使用 locale-aware 格式化的格式字符串

搜索本地化反模式：

- 不使用 locale-aware 函数的 Date/time 格式化
- 没有 locale 意识的 Number 格式化（`1,000` vs `1.000`）
- 嵌入在 images 或 textures 中的文本（标记 `assets/` 中的 asset 文件）
- 假设从左到右文本方向的字符串（positional layout, string assembly order）
- 嵌入字符串逻辑的 Gender/plurality 假设（必须使用复数形式或性别标记）
- 硬编码的标点符号（例如 `"You won!"` — 感叹号样式因语言环境而异）

报告所有带有文件路径和行号的 findings。此模式是只读的 — 不写入文件。

---

## Phase 2B: Extract Mode

- 扫描所有源文件中本地化的字符串引用
- 与 `assets/data/strings/` 中的现有字符串表进行比较
- 为尚未键入的字符串生成新条目
- 遵循约定建议键名：`[category].[subcategory].[description]`
  - 示例：`ui.hud.health_label`, `dialogue.npc.merchant.greeting`, `menu.main.play_button`
- 每个新条目必须包含一个 `context` 字段 — 一个译者注释，解释：
  - 它出现在哪里（哪个 screen，哪个 scene）
  - 最大字符长度
  - 任何占位符含义（`{playerName}` = 玩家选择的显示名称）
- 如果适用，Gender/plurality 上下文

输出要添加到字符串表的新字符串的差异。

向用户展示差异。询问："我可以将这些新条目写入 `assets/data/strings/strings-en.json` 吗？"

如果是，只写入差异（新条目），而不是完整替换。Verdict: **COMPLETE** — 字符串已提取并写入。

---

## Phase 2C: Validate Mode

读取 `assets/data/strings/` 中的所有字符串表文件。对于每个语言环境，检查：

- **Completeness** — 键存在于源（en）中但没有此语言环境的翻译
- **Placeholder mismatches** — 源有 `{name}` 但翻译省略了它或添加了额外的
- **String length violations** — 翻译超过源 `context` 字段中记录的字符限制
- **Plural form count** — 语言环境需要 N 种复数形式；翻译提供的较少
- **Orphaned keys** — 翻译存在但 `src/` 中没有引用该键
- **Stale translations** — 源字符串在翻译写入后更改（标记为重新翻译）
- **Encoding** — 存在非 ASCII 字符且字体 atlas 支持它们（如果不确定则标记）

按语言环境和严重性分组报告验证结果。此模式是只读的 — 不写入文件。

---

## Phase 2D: Status Mode

- 计数源表中的总可本地化字符串
- 每种语言环境：计数已翻译、未翻译、陈旧（自翻译以来源更改）
- 生成覆盖矩阵：

```markdown
## Localization Status
Generated: [Date]
String freeze: [Active / Not yet called / Lifted]

| Locale | Total | Translated | Missing | Stale | Coverage |
|--------|-------|-----------|---------|-------|----------|
| en (source) | [N] | [N] | 0 | 0 | 100% |
| [locale] | [N] | [N] | [N] | [N] | [X]% |

### Issues
- [N] 源代码中找到的硬编码字符串（运行 /localize scan）
- [N] 超过字符限制的字符串
- [N] 占位符不匹配
- [N] 孤立键
- [N] freeze 调用后添加的字符串（freeze violations）
```

此模式是只读的 — 不写入文件。

---

## Phase 2E: Brief Mode

生成译者上下文简报文档。此文档与字符串表导出一起发送给外部翻译团队或本地化供应商。

读取：
- `design/gdd/` — 提取游戏 genre, tone, setting, character names
- `assets/data/strings/strings-en.json` — 源字符串表
- `design/narrative/` 中的任何现有 lore 或 narrative 文档

生成 `production/localization/translator-brief-[locale]-[date].md`：

```markdown
# Translator Brief — [Game Name] — [Locale]

## Game Overview
[2-3 段落的游戏摘要、genre、tone 和 audience]

## Tone and Voice
- **Overall tone**: [例如，"Darkly comic, not slapstick — think Terry Pratchett, not Looney Tunes"]
- **Player address**: [例如，"Second person, informal. Never formal 'vous' — always 'tu' for French"]
- **Profanity policy**: [例如，"Mild — PG-13 equivalent. Match intensity to source, do not soften or escalate"]
- **Humour**: [例如，"Wordplay exists — if a pun cannot translate, invent an equivalent local joke; do not translate literally"]

## Character Glossary
| Name | Role | Personality | Notes |
|------|------|-------------|-------|
| [Name] | [Role] | [Personality] | [Do not translate / transliterate as X] |

## World Glossary
| Term | Meaning | Notes |
|------|---------|-------|
| [Term] | [What it means] | [Keep in English / translate as X] |

## Do Not Translate List
以下必须原样出现在所有语言环境中：
- [Game name]
- [与引擎内标签匹配的 UI terms]
- [Brand 或 trademark names]

## Placeholder Reference
| Placeholder | What it represents | Example |
|-------------|-------------------|---------|
| `{playerName}` | Player's chosen display name | "Shadowblade" |
| `{count}` | Integer quantity | "3" |

## Character Limits
紧的 UI fields 带有硬限制在字符串表 `context` 字段中标记。
如果没有说明限制，目标为英语长度的 ±30% 作为指导原则。

## Contact
问题直接联系：[placeholder for user/team contact]
Delivery format: JSON, same schema as strings-en.json
```

询问："我可以将此译者简报写入 `production/localization/translator-brief-[locale]-[date].md` 吗？"

---

## Phase 2F: Cultural Review Mode

通过 Task 生成 `localization-lead`。要求他们审计以下内容的文化敏感性（从 `assets/data/strings/` 和 `assets/` 读取）：

### Content Areas to Review

**Symbols and gestures**
- Thumbs up, OK hand, peace sign — 含义因地区而异
- Art, UI, 或 audio 中的 Religious 或 spiritual symbols
- National flags, map representations, disputed territories

**Colours**
- White（一些亚洲文化中的哀悼），green（一些地区的政治关联），red（luck vs danger）
- 与文化关联冲突的 Alert/warning 颜色

**Numbers**
- 4（日语/中文中的死亡），13，666 — 标记在 UI 中的使用（room numbers, item counts, prices）

**Humour and idioms**
- 在其他语言环境中翻译为冒犯的 Idioms
- 在一些市场（特别是 Japan, Germany, Middle East）不合适的 Toilet/bodily humour
- 在特定地区文化敏感的话题周围的 Dark humour

**Violence and content ratings**
- 在 DE (Germany), AU (Australia), CN (China), 或 AE (UAE) 需要 ratings changes 的内容
- Blood colour, gore level, drug references — 如果需要，标记所有 region-specific asset variants

**Names and representations**
- 在目标语言环境中冒犯、亵渎或带有负面含义的 Character names
- Nationalities, religions, 或 ethnic groups 的刻板印象

将 findings 呈现为表格：

| Finding | Locale(s) Affected | Severity | Recommended Action |
|---------|--------------------|----------|--------------------|
| [Description] | [Locale] | [BLOCKING / ADVISORY / NOTE] | [Change / Flag for review / Accept] |

BLOCKING = 在发布该语言环境之前必须修复。ADVISORY = 建议更改。NOTE = 仅信息。

询问："我可以将此文化审查报告写入 `production/localization/cultural-review-[date].md` 吗？"

---

## Phase 2G: VO Pipeline Mode

管理 voice-over 本地化过程。从参数确定子任务：

- `vo-pipeline scan` — 识别所有需要 VO 录音的对话行
- `vo-pipeline script` — 生成带有 director notes 的录音脚本
- `vo-pipeline validate` — 检查所有录制的 VO 文件是否存在且命名正确
- `vo-pipeline integrate` — 验证 VO 文件在代码/assets 中被正确引用

### VO Pipeline: Scan

读取 `assets/data/strings/` 和 `design/narrative/`。识别：
- 所有对话行（键匹配 `dialogue.*`）带有源文本
- 已录制的行（`assets/audio/vo/` 中存在音频文件）
- 尚未录制的行

输出录音清单：

```
## VO Recording Manifest — [Date]

| Key | Character | Source Line | Status |
|-----|-----------|-------------|--------|
| dialogue.npc.merchant.greeting | Merchant | "Welcome, traveller." | Recorded |
| dialogue.npc.merchant.haggle | Merchant | "That's my final offer." | Needs recording |
```

### VO Pipeline: Script

为每个 character 生成录音脚本文档，按 scene 分组。包括：

- Character name 和 brief personality note
- 带有不寻常专有名词 pronunciation guide 的完整对话行
- 每行的 Emotion/direction note（`[Warm, welcoming]`, `[Annoyed, clipped]`）
- 对话中作为回应的任何行（提供上下文："Player just said X"）

询问："我可以将 VO 录音脚本写入 `production/localization/vo-scripts-[locale]-[date].md` 吗？"

### VO Pipeline: Validate

Glob `assets/audio/vo/[locale]/` 获取所有 `.wav`/`.ogg` 文件。与 VO 清单交叉引用。报告：
- 缺失的文件（脚本中的行，没有音频文件）
- 额外的文件（音频文件存在，没有匹配的字符串键）
- Naming convention violations

### VO Pipeline: Integrate

Grep `src/` 获取 VO 音频引用。验证每个引用的路径是否存在于 `assets/audio/vo/[locale]/` 中。报告损坏的引用。

---

## Phase 2H: RTL Check Mode

从右到左的语言（Arabic, Hebrew, Persian, Urdu）需要超出
仅仅翻译文本的布局镜像。此模式验证实现。

读取 `.claude/docs/technical-preferences.md` 以确定引擎。然后检查：

**Layout mirroring**
- RTL 布局在引擎中启用吗？（Godot: `Control.layout_direction`, Unity: `RTL Support` package, Unreal: text direction flags）
- 所有 UI 容器设置为 auto-mirror，还是 positions 硬编码？
- Progress bars, health bars, 和 directional indicators 正确镜像吗？

**Text rendering**
- 加载支持 Arabic/Hebrew 字符集的 Fonts 了吗？
- Arabic text 使用正确的 ligatures（连接脚本）渲染吗？
- Numbers 在需要的地方显示为 Eastern Arabic numerals 吗？

**String assembly**
- 有任何假设从左到右阅读顺序的字符串连接吗？
- 当句子结构反转时，句子中的 `{placeholder}` 位置正确工作吗？

**Asset review**
- 有需要镜像变体的带有 directional arrows 或 asymmetric designs 的 UI icons 吗？
- 有需要 RTL 版本的 text-in-image assets 吗？

要检查的 Grep patterns：
- scene/prefab 文件中引擎特定的 RTL flags
- 任何 `HBoxContainer`, `LinearLayout`, `HorizontalBox` 节点 — 验证 layout_direction 设置
- dialogue 或 UI code 附近带有 `+` 的字符串连接

报告 findings。标记 BLOCKING issues（没有修复内容不可读）与 ADVISORY（cosmetic improvements）。

询问："我可以将此 RTL 检查报告写入 `production/localization/rtl-check-[date].md` 吗？"

---

## Phase 2I: Freeze Mode

字符串冻结锁定源（英语）字符串表，以便翻译可以继续
而不会在翻译人员更改源。

### freeze call

在 `production/localization/freeze-status.md` 中检查当前冻结状态（如果存在）。

如果已经冻结：
> "String freeze 当前是 ACTIVE（在 [date] 调用）。自 freeze 以来已添加或修改 [N] 个字符串。这些是 freeze violations — 它们需要重新翻译或批准的 freeze lift。"

如果没有冻结，展示 pre-freeze 清单：

```
Pre-Freeze Checklist
[ ] 所有计划的 UI screens 已实现
[ ] 所有 dialogue lines 是 final（没有进一步的 narrative revisions 计划）
[ ] 所有 system strings（error messages, tutorial text）已完成
[ ] /localize scan 显示零硬编码字符串
[ ] /localize validate 显示源（en）中没有占位符不匹配
[ ] Marketing strings（store description, achievements）是 final
```

使用 `AskUserQuestion`：
- 提示："以上所有项目都确认了吗？调用字符串冻结会锁定源表。"
- 选项：`[A] 是 — 立即调用字符串冻结` / `[B] 否 — 我还有一些字符串要添加`

如果 [A]：写入 `production/localization/freeze-status.md`：

```markdown
# String Freeze Status

**Status**: ACTIVE
**Called**: [date]
**Called by**: [user]
**Total strings at freeze**: [N]

## Post-Freeze Changes
[/localize extract 自动列出的 freeze 后添加或修改的任何字符串]
```

### freeze lift

如果参数包含 `lift`：将 `freeze-status.md` Status 更新为 `LIFTED`，记录原因和日期。警告："Lifting the freeze 需要重新翻译所有修改的字符串。Notify the translation team。"

### freeze check (auto-integrated into extract)

当 `extract` 模式找到新字符串或修改的字符串且 `freeze-status.md` 显示 Status: ACTIVE 时 — 将新键追加到 `## Post-Freeze Changes` 并警告：
> "⚠️ String freeze 是 active。[N] 个新/修改的字符串已添加。这些是 freeze violations。在继续之前通知您的本地化供应商。"

---

## Phase 2J: QA Mode

Localization QA 是一个专门的 pass，在翻译交付后运行但在任何语言环境发布之前。这与 `/validate`（检查完整性）不同 — 这是一个基于结构化游戏测试的质量检查。

通过 Task 生成 `localization-lead`：
- 要 QA 的目标语言环境
- 游戏中所有 screens/flows 的列表（来自 `design/gdd/` 或 `/content-audit` 输出）
- 当前的 `/localize validate` 报告
- 文化审查报告（如果存在）

要求 localization-lead 生成一个 QA plan，涵盖：

1. **Functional string check** — 每个字符串都显示在游戏中而没有 truncation, placeholder errors, 或 encoding corruption
2. **UI overflow check** — 超过 UI 边界的翻译字符串（即使在字符限制内，有些语言会扩展）
3. **Contextual accuracy** — 游戏中审查 10% 的字符串样本以确保翻译准确性和自然措辞
4. **Cultural review items** — 验证文化审查中的所有 BLOCKING items 已解决
5. **VO sync check** — 如果 VO 存在，验证 lip sync 或 subtitle timing 在翻译后可接受
6. **Platform cert requirements** — 检查平台特定的本地化要求（age ratings text, legal notices, ESRB/PEGI/CERO text）

每种语言环境的 QA verdict 输出：

```
## Localization QA Verdict — [Locale]

**Status**: PASS / PASS WITH CONDITIONS / FAIL
**Reviewed by**: localization-lead
**Date**: [date]

### Findings
| ID | Area | Description | Severity | Status |
|----|------|-------------|----------|--------|
| LOC-001 | UI Overflow | "Settings" 按钮文本在 [Screen] 上溢出 | BLOCKING | Open |
| LOC-002 | Translation | [Key] 翻译是 literal — 听起来不自然 | ADVISORY | Open |

### Conditions (如果 PASS WITH CONDITIONS)
- [Condition 1 — 必须在发布前解决]

### Sign-Off
[ ] 所有 BLOCKING findings 已解决
[ ] Producer 批准发布 [Locale]
```

询问："我可以将此本地化 QA 报告写入 `production/localization/loc-qa-[locale]-[date].md` 吗？"

**Gate integration**: Polish → Release 关卡要求每个要发布的语言环境都有 PASS 或 PASS WITH CONDITIONS 裁决。FAIL 仅阻止该语言环境的发布 — 如果其 QA 通过，其他语言环境仍可进行。

---

## Phase 3: Rules and Next Steps

### Rules
- English (en) 始终是源语言环境
- 每个字符串表条目必须包含带有译者注释、字符限制和占位符含义的 `context` 字段
- 永远不要直接修改翻译文件 — 生成差异以供审查
- 必须按 UI 元素定义字符限制并在 validate 模式下强制执行
- 在将字符串发送给译者之前必须调用字符串冻结 — 永远不要翻译移动目标
- RTL 支持必须从开始就设计 — 改造 RTL 布局成本高昂
- 任何游戏将商业销售的地区都需要文化审查
- VO 脚本必须包含 director notes — 原始对话行产生平淡的录音

### Recommended Workflow

```
/localize scan            → 查找硬编码字符串
/localize extract         → 构建字符串表
/localize freeze          → 在发送给译者之前锁定源
/localize brief           → 生成译者简报文档
[发送给译者]
/localize validate        → 检查返回的翻译
/localize cultural-review → 标记文化敏感内容
/localize rtl-check       → 如果发布 Arabic / Hebrew / Persian
/localize vo-pipeline     → 如果发布配音 VO
/localize qa              → 完整本地化 QA pass
```

在所有发布的语言环境的 `qa` 返回 PASS 后，在运行 `/gate-check release` 时包含 QA 报告路径。
