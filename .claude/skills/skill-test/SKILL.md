---
name: skill-test
description: "验证 Skill 文件的结构合规性和行为正确性。三种模式：static（语法检查）、spec（行为验证）、audit（覆盖报告）。"
argument-hint: "static [skill-name | all] | spec [skill-name] | category [skill-name | all] | audit"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

# Skill 测试

验证 `.claude/skills/*/SKILL.md` 文件的结构合规性和
行为正确性。无外部依赖 —— 完全在现有的 skill/hook/template 架构中运行。

**四种模式：**

| 模式 | 命令 | 用途 | Token 成本 |
|------|------|------|-----------|
| `static` | `/skill-test static [name\|all]` | 结构语法检查 —— 每个 skill 7 项合规检查 | 低（约 1k/skill） |
| `spec` | `/skill-test spec [name]` | 行为验证器 —— 评估测试规范中的断言 | 中（约 5k/skill） |
| `category` | `/skill-test category [name\|all]` | 类别标准 —— 根据类别特定指标检查 skill | 低（约 2k/skill） |
| `audit` | `/skill-test audit` | 覆盖报告 —— skills、agent 规范、上次测试日期 | 低（总计约 3k） |

---

## 阶段 1: 解析参数

从第一个参数确定模式：

- `static [name]` → 对一个 skill 运行 7 项结构检查
- `static all` → 对所有 skills 运行 7 项结构检查（Glob `.claude/skills/*/SKILL.md`）
- `spec [name]` → 读取 skill + 测试规范，评估断言
- `category [name]` → 从 `CCGS Skill Testing Framework/quality-rubric.md` 运行类别特定标准
- `category all` → 为 catalog 中有 `category:` 的每个 skill 运行类别标准
- `audit`（或无参数）→ 读取 catalog，列出所有 skills 和 agents，显示覆盖情况

如果参数缺失或无法识别，输出用法并停止。

---

## 阶段 2A: Static 模式 —— 结构语法检查

对于每个正在测试的 skill，完整读取其 `SKILL.md` 并运行所有 7 项检查：

### 检查 1 —— 必需的 Frontmatter 字段
文件必须在 YAML frontmatter 块中包含所有这些：
- `name:`
- `description:`
- `argument-hint:`
- `user-invocable:`
- `allowed-tools:`

**FAIL** 如果任何一项缺失。

### 检查 2 —— 多个阶段
Skill 必须有 ≥2 个编号阶段标题。查找模式如：
- `## Phase N` 或 `## Phase N:`
- `## N.`（编号顶级章节）
- 如果没有明确编号，至少 2 个不同的 `##` 标题

**FAIL** 如果找到的类似阶段的标题少于 2 个。

### 检查 3 —— 裁决关键词
Skill 必须包含至少一个：`PASS`、`FAIL`、`CONCERNS`、`APPROVED`、
`BLOCKED`、`COMPLETE`、`READY`、`COMPLIANT`、`NON-COMPLIANT`

**FAIL** 如果没有一个存在。

### 检查 4 —— 协作协议语言
Skill 必须包含写入前询问语言。查找：
- `"May I write"`（规范形式）
- `"before writing"` 或 `"approval"` 靠近文件写入指令
- `"ask"` + `"write"` 在近距离（同一章节内）

**WARN** 如果不存在（一些只读 skills 合理地跳过这个）。
**FAIL** 如果 `allowed-tools` 包含 `Write` 或 `Edit` 但未找到写入前询问语言。

### 检查 5 —— 下一步交接
Skill 必须以推荐的下一步操作或后续路径结束。查找：
- 提到另一个 skill 的最终章节（例如 `/story-done`、`/gate-check`）
- "Recommended next" 或 "next step" 措辞
- "Follow-Up" 或 "After this" 章节

**WARN** 如果不存在。

### 检查 6 —— Fork 上下文复杂度
如果 frontmatter 包含 `context: fork`，skill 应该有 ≥5 个阶段标题
（`##` 级别或编号 Phase N 标题）。Fork 上下文用于复杂多阶段
skills；简单的 skills 不应使用它。

**WARN** 如果设置了 `context: fork` 但找到的阶段少于 5 个。

### 检查 7 —— 参数提示合理性
`argument-hint` 必须非空。如果 skill 正文提到多种模式
（例如 "Mode A | Mode B"），提示应反映它们。将提示与
第一阶段的 "Parse Arguments" 章节进行交叉引用。

**WARN** 如果提示是 `""` 或记录的模式与提示不匹配。

---

### Static 模式输出格式

对于单个 skill：
```
=== Skill Static Check: /[name] ===

Check 1 — Frontmatter Fields:    PASS
Check 2 — Multiple Phases:       PASS (7 phases found)
Check 3 — Verdict Keywords:      PASS (PASS, FAIL, CONCERNS)
Check 4 — Collaborative Protocol: PASS ("May I write" found)
Check 5 — Next-Step Handoff:     WARN (no follow-up section found)
Check 6 — Fork Context Complexity: PASS (8 phases, context: fork set)
Check 7 — Argument Hint:         PASS

Verdict: WARNINGS (1 warning, 0 failures)
Recommended: Add a "Follow-Up Actions" section at the end of the skill.
```

对于 `static all`，生成摘要表然后列出任何不合规的 skills：
```
=== Skill Static Check: All 52 Skills ===

Skill                  | Result       | Issues
-----------------------|--------------|-------
gate-check             | COMPLIANT    |
design-review          | COMPLIANT    |
story-readiness        | WARNINGS     | Check 5: no handoff
...

Summary: 48 COMPLIANT, 3 WARNINGS, 1 NON-COMPLIANT
Aggregate Verdict: N WARNINGS / N FAILURES
```

---

## 阶段 2B: Spec 模式 —— 行为验证器

### 步骤 1 —— 定位文件

在 `.claude/skills/[name]/SKILL.md` 找到 skill。
从 `CCGS Skill Testing Framework/catalog.yaml` 查找规范路径 —— 使用
匹配 skill 条目的 `spec:` 字段。

如果任何一个缺失：
- 缺失 skill："Skill '[name]' not found in `.claude/skills/`。"
- catalog 中未设置规范路径："No spec path set for '[name]' in catalog.yaml。"
- 路径处未找到规范文件："Spec file missing at [path]。Run `/skill-test audit`
  to see coverage gaps。"

### 步骤 2 —— 读取两个文件

完整读取 skill 文件和测试规范文件。

### 步骤 3 —— 评估断言

对于规范中的每个**测试用例**：

1. 读取**夹具**描述（项目文件的假设状态）
2. 读取**预期行为**步骤
3. 读取每个**断言**复选框

对于每个断言，评估如果按照夹具状态正确遵循 skill 的书面指令，
是否会满足它。这是 Claude 评估的推理检查，不是代码执行。

标记每个断言：
- **PASS** —— skill 指令清楚地满足此断言
- **PARTIAL** —— skill 指令部分解决它，但有歧义
- **FAIL** —— 给定夹具，skill 指令不会满足此断言

对于**协议合规**断言（始终存在）：
- 检查 skill 是否在文件写入前要求 "May I write"
- 检查 skill 是否在请求批准前展示发现
- 检查 skill 是否以推荐的下一步结束
- 检查 skill 是否避免未经批准自动创建文件

### 步骤 4 —— 构建报告

```
=== Skill Spec Test: /[name] ===
Date: [date]
Spec: CCGS Skill Testing Framework/skills/[category]/[name].md

Case 1: [Happy Path — name]
  Fixture: [summary]
  Assertions:
    [PASS] [assertion text]
    [FAIL] [assertion text]
       Reason: The skill's Phase 3 says "..." but the fixture state means "..."
  Case Verdict: FAIL

Case 2: [Edge Case — name]
  ...
  Case Verdict: PASS

Protocol Compliance:
  [PASS] Uses "May I write" before file writes
  [PASS] Presents findings before asking approval
  [WARN] No explicit next-step handoff at end

Overall Verdict: FAIL (1 case failed, 1 warning)
```

### 步骤 5 —— 提供写入结果

"我可以将这些结果写入 `CCGS Skill Testing Framework/results/skill-test-spec-[name]-[date].md`
并更新 `CCGS Skill Testing Framework/catalog.yaml` 吗？"

如果同意：
- 将结果文件写入 `CCGS Skill Testing Framework/results/`
- 更新 `CCGS Skill Testing Framework/catalog.yaml` 中的 skill 条目：
  - `last_spec: [date]`
  - `last_spec_result: PASS|PARTIAL|FAIL`

---

## 阶段 2D: Category 模式 —— 标准评估

### 步骤 1 —— 定位 Skill 和类别

在 `.claude/skills/[name]/SKILL.md` 找到 skill。
在 `CCGS Skill Testing Framework/catalog.yaml` 中查找 `category:` 字段。

如果未找到 skill："Skill '[name]' not found。"
如果没有 `category:` 字段："No category assigned for '[name]' in catalog.yaml。
Add `category: [name]` to the skill entry first。"

对于 `category all`：收集所有带有 `category:` 字段的 skills 并处理每个。
`category: utility` skills 仅针对 U1（静态检查通过）和 U2（如适用，gate 模式正确）进行评估 —— 跳到 U1 的静态模式。

### 步骤 2 —— 读取标准章节

读取 `CCGS Skill Testing Framework/quality-rubric.md`。
提取与 skill 类别匹配的部分（例如 `### gate`、`### team`）。

### 步骤 3 —— 读取 Skill

完整读取 skill 的 `SKILL.md`。

### 步骤 4 —— 评估标准指标

对于类别标准表中的每个指标：
1. 检查 skill 的书面指令是否清楚地满足标准
2. 标记 PASS、FAIL 或 WARN
3. 对于 FAIL/WARN，确定 skill 文本中的确切差距（引用相关部分
   或注明其缺失）

### 步骤 5 —— 输出报告

```
=== Skill Category Check: /[name] ([category]) ===

Metric G1 — Review mode read:      PASS
Metric G2 — Full mode directors:   FAIL
  Gap: Phase 3 spawns only CD-PHASE-GATE; TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE absent
Metric G3 — Lean mode: PHASE-GATE only: PASS
Metric G4 — Solo mode: no directors:    PASS
Metric G5 — No auto-advance:       PASS

Verdict: FAIL (1 failure, 0 warnings)
Fix: Add TD-PHASE-GATE, PR-PHASE-GATE, and AD-PHASE-GATE to the full-mode director
     panel in Phase 3。
```

### 步骤 6 —— 提供更新 Catalog

"我可以更新 `CCGS Skill Testing Framework/catalog.yaml` 来记录 [name] 的此类别检查
(`last_category`, `last_category_result`) 吗？"

---

## 阶段 2C: Audit 模式 —— 覆盖报告

### 步骤 1 —— 读取 Catalog

读取 `CCGS Skill Testing Framework/catalog.yaml`。如果缺失，注明 catalog 尚不存在
（首次运行状态）。

### 步骤 2 —— 枚举所有 Skills 和 Agents

Glob `.claude/skills/*/SKILL.md` 获取完整的 skill 列表。
从每个路径提取 skill 名称（目录名）。

还从 `CCGS Skill Testing Framework/catalog.yaml` 的 `agents:` 部分读取
完整的 agent 列表。

### 步骤 3 —— 构建 Skill 覆盖表

对于每个 skill：
- 检查规范文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/skills/*/[name].md`）
- 从 catalog 查找 `last_static`, `last_static_result`, `last_spec`, `last_spec_result`,
  `last_category`, `last_category_result`, `category`（或标记为
  "never" / "—" 如果不在 catalog 中）
- 优先级来自 catalog `priority:` 字段（critical/high/medium/low）

### 步骤 3b —— 构建 Agent 覆盖表

对于 catalog 的 `agents:` 部分中的每个 agent：
- 检查规范文件是否存在（使用 catalog 中的 `spec:` 路径，或 glob `CCGS Skill Testing Framework/agents/*/[name].md`）
- 从 catalog 查找 `last_spec`, `last_spec_result`, `category`

### 步骤 4 —— 输出报告

```
=== Skill Test Coverage Audit ===
Date: [date]

SKILLS (72 total)
Specs written: 72 (100%) | Never static tested: 72 | Never category tested: 72

Skill                  | Cat      | Has Spec | Last Static | S.Result | Last Cat | C.Result | Priority
-----------------------|----------|----------|-------------|----------|----------|----------|----------
gate-check             | gate     | YES      | never       | —        | never    | —        | critical
design-review          | review   | YES      | never       | —        | never    | —        | critical
...

AGENTS (49 total)
Agent specs written: 49 (100%)

Agent                  | Category   | Has Spec | Last Spec   | Result
-----------------------|------------|----------|-------------|--------
creative-director      | director   | YES      | never       | —
technical-director     | director   | YES      | never       | —
...

Top 5 Priority Gaps (skills with no spec, critical/high priority):
(none if all specs are written)

Skill coverage:  72/72 specs (100%)
Agent coverage:  49/49 specs (100%)
```

Audit 模式下无文件写入。

提供："Would you like to run `/skill-test static all` to check structural
compliance across all skills? `/skill-test category all` to run category rubric
checks? Or `/skill-test spec [name]` to run a specific behavioral test?"

---

## 阶段 3: 推荐的后续步骤

任何模式完成后，提供上下文后续操作：

- `static [name]` 之后："Run `/skill-test spec [name]` to validate behavioral
correctness if a test spec exists。"
- `static all` 有失败后："Address NON-COMPLIANT skills first。Run
`/skill-test static [name]` individually for detailed remediation guidance。"
- `spec [name]` PASS 后："Update `CCGS Skill Testing Framework/catalog.yaml` to record this
pass date。Consider running `/skill-test audit` to find the next spec gap。"
- `spec [name]` FAIL 后："Review the failing assertions and update the skill
or the test spec to resolve the mismatch。"
- `audit` 后："Start with the critical-priority gaps。Use the spec template
at `CCGS Skill Testing Framework/templates/skill-test-spec.md` to create new specs。"
