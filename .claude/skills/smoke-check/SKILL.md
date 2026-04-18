---
name: smoke-check
description: "在 QA 交接前运行关键路径 Smoke 测试 Gate。执行自动化测试套件，验证核心功能，并生成 PASS/FAIL 报告。在 Sprint 的 Stories 实现后、手动 QA 开始前运行。失败的 Smoke check 意味着构建尚未准备好进行 QA。"
argument-hint: "[sprint | quick | --platform pc|console|mobile|all]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, AskUserQuestion
---

# Smoke Check

此 Skill 是"实现完成"和"准备好进行 QA
交接"之间的 Gate。它运行自动化测试套件，检查测试覆盖缺口，
与开发者批量验证关键路径，并生成 PASS/FAIL
报告。

规则很简单：**失败 Smoke check 的构建不会交给 QA。**
将损坏的构建交给 QA 会浪费他们的时间并使团队士气低落。

**输出：** `production/qa/smoke-[date].md`

---

## 解析参数

参数可以组合：`/smoke-check sprint --platform console`

**基础模式**（第一个参数，默认：`sprint`）：
- `sprint` —— 针对当前 Sprint Stories 的完整 Smoke check
- `quick` —— 跳过覆盖扫描（阶段 3）和批次 3；用于快速重新检查

**平台标志**（`--platform`，默认：无）：
- `--platform pc` —— 添加 PC 特定检查（键盘、鼠标、窗口模式）
- `--platform console` —— 添加主机特定检查（手柄、电视安全区、
  平台认证要求）
- `--platform mobile` —— 添加移动端特定检查（触摸、竖屏/横屏、
  电池/发热行为）
- `--platform all` —— 添加所有平台变体；输出每个平台的裁决表

如果提供了 `--platform`，阶段 4 添加平台特定批次，
阶段 5 除了总体裁决外，还输出每个平台的裁决表。

---

## 阶段 1: 检测测试设置

在运行任何内容之前，了解环境：

1. **测试框架检查**：验证 `tests/` 目录是否存在。
   如果不存在："No test directory found at `tests/`。Run `/test-setup`
   to scaffold the testing infrastructure，or create the directory manually
   if tests live elsewhere。" 然后停止。

2. **CI 检查**：检查 `.github/workflows/` 是否包含引用测试的工作流文件。
   在报告中注明是否配置了 CI。

3. **引擎检测**：读取 `.claude/docs/technical-preferences.md` 并
   提取 `Engine:` 值。存储此值以供阶段 2 中的测试命令选择。

4. **Smoke 测试列表**：检查 `production/qa/smoke-tests.md` 或
   `tests/smoke/` 是否存在。如果找到 Smoke 测试列表，加载它以供阶段 4 使用。
   如果都不存在，Smoke 测试将从当前 QA 计划中抽取
   （阶段 4 回退）。

5. **QA 计划检查**：glob `production/qa/qa-plan-*.md` 并获取最新
   修改的文件。如果找到，记录路径 —— 它将在阶段 3 和阶段 4 中使用。
   如果未找到，记录："No QA plan found。Run
   `/qa-plan sprint` before smoke-checking for best results。"

在继续前报告发现："Environment: [engine]。Test directory:
[found / not found]。CI configured: [yes / no]。QA plan: [path / not found]。"

---

## 阶段 2: 运行自动化测试

尝试通过 Bash 运行测试套件。根据阶段 1 检测到的引擎选择命令：

**Godot 4：**
```bash
godot --headless --script tests/gdunit4_runner.gd 2>&1
```
如果该路径不存在 GDUnit4 runner 脚本，尝试：
```bash
godot --headless -s addons/gdunit4/GdUnitRunner.gd 2>&1
```
如果两个路径都不存在，记录："GDUnit4 runner not found — confirm the runner
path for your test framework。"

**Unity：**
Unity 测试需要编辑器，在大多数环境中无法通过 shell 无头运行。
检查最近的测试结果产物：
```bash
ls -t test-results/ 2>/dev/null | head -5
```
如果存在测试结果文件（XML 或 JSON），读取最新的一个并解析
PASS/FAIL 计数。如果没有产物："Unity tests must be run from the
editor or CI pipeline。Please confirm test status manually before proceeding。"

**Unreal Engine：**
```bash
ls -t Saved/Logs/ 2>/dev/null | grep -i "test\|automation" | head -5
```
如果未找到匹配的日志："UE automation tests must be run via the Session
Frontend or CI pipeline。Please confirm test status manually。"

**未知引擎 / 未配置：**
"Engine not configured in `.claude/docs/technical-preferences.md`。Run
`/setup-engine` to specify the engine，then re-run `/smoke-check`。"

**如果此环境中测试运行器不可用**（引擎二进制文件不在 PATH 上，
runner 脚本未找到等），清楚地报告：

"Automated tests could not be executed — engine binary not found on PATH。
Status will be recorded as NOT RUN。Confirm test results from your local IDE
or CI pipeline。Unconfirmed NOT RUN is treated as PASS WITH WARNINGS，not
FAIL — the developer must manually confirm results。"

不要将 NOT RUN 视为自动 FAIL。将其记录为警告。开发者
在阶段 4 的手动确认可以解决它。

解析 runner 输出并提取：
- 运行总测试数
- 通过计数
- 失败计数
- 任何失败测试的名称（最多 10 个；如果更多，记录计数）
- runner 本身的任何崩溃或错误输出

---

## 阶段 3: 检查测试覆盖

按优先顺序从以下获取 Story 列表：
1. 阶段 1 中找到的 QA 计划（其测试摘要表列出每个 Story 的预期测试
   文件路径）
2. `production/sprints/` 中的当前 Sprint 计划（最新修改的文件）
3. 如果传入了 `quick` 参数，完全跳过此阶段并注明：
   "Coverage scan skipped — run `/smoke-check sprint` for full coverage
   analysis。"

对于范围内的每个 Story：

1. 从 Story 的文件路径提取系统 slug
   （例如 `production/epics/combat/story-001.md` → `combat`）
2. Glob `tests/unit/[system]/` 和 `tests/integration/[system]/` 查找名称包含
   Story slug 或密切相关术语的文件
3. 检查 Story 文件本身是否有 `Test file:` 标题字段或
   "Test Evidence" 章节

为每个 Story 分配覆盖状态：

| 状态 | 含义 |
|--------|---------|
| **COVERED** | 找到匹配此 Story 系统和范围的测试文件 |
| **MANUAL** | Story 类型是视觉/感觉或 UI；找到测试证据文档 |
| **MISSING** | 逻辑或集成 Story 无匹配测试文件 |
| **EXPECTED** | 配置/数据 Story —— 不需要测试文件；抽查即可 |
| **UNKNOWN** | Story 文件缺失或无法读取 |

MISSING 条目是建议性缺口。它们不会导致 FAIL 裁决，但必须
在报告中突出显示，并且必须在 `/story-done` 可以完全关闭这些 Stories 之前解决。

---

## 阶段 4: 运行手动 Smoke 检查

按优先顺序从以下获取 Smoke 测试检查清单：
1. QA 计划的 "Smoke Test Scope" 章节（如果阶段 1 中找到了 QA 计划）
2. `production/qa/smoke-tests.md`（如果存在）
3. `tests/smoke/` 目录内容（如果存在）
4. 以下标准回退列表（仅在以上都不存在时使用）

根据 Sprint 或 QA 计划中确定的实际系统定制批次 2 和 3。
用当前 Sprint Stories 中的真实机制名称替换括号占位符。

使用 `AskUserQuestion` 进行批量验证。最多 3 次调用。

**批次 1 —— 核心稳定性（始终运行）：**
```
question: "Smoke check — Batch 1: Core stability。Please verify each:"
options:
  - "Game launches to main menu without crash — PASS"
  - "Game launches to main menu without crash — FAIL"
  - "New game / session starts successfully — PASS"
  - "New game / session starts successfully — FAIL"
  - "Main menu responds to all inputs — PASS"
  - "Main menu responds to all inputs — FAIL"
```

**批次 2 —— Sprint 机制和回归（始终运行）：**
```
question: "Smoke check — Batch 2: This sprint's changes and regression check:"
options:
  - "[Primary mechanic this sprint] — PASS"
  - "[Primary mechanic this sprint] — FAIL: [describe what broke]"
  - "[Second notable change this sprint, if any] — PASS"
  - "[Second notable change this sprint] — FAIL"
  - "Previous sprint's features still work (no regressions) — PASS"
  - "Previous sprint's features — regression found: [brief description]"
```

**批次 3 —— 数据完整性和性能（除非传入 `quick`，否则运行）：**
```
question: "Smoke check — Batch 3: Data integrity and performance:"
options:
  - "Save / load completes without data loss — PASS"
  - "Save / load — FAIL: [describe what broke]"
  - "Save / load — N/A (save system not yet implemented)"
  - "No new frame rate drops or hitches observed — PASS"
  - "Frame rate drops or hitches found — FAIL: [where]"
  - "Performance — not checked in this session"
```

为阶段 5 的报告逐字记录每个响应。

**平台批次** *（仅在传入 `--platform` 参数时运行）*：

**PC 平台**（`--platform pc` 或 `--platform all`）：
```
question: "Smoke check — PC Platform: Verify platform-specific behaviour:"
options:
  - "Keyboard controls work correctly across all menus and gameplay — PASS"
  - "Keyboard controls — FAIL: [describe issue]"
  - "Mouse input and cursor visibility correct in all states — PASS"
  - "Mouse input — FAIL: [describe issue]"
  - "Windowed and fullscreen modes function without graphical issues — PASS"
  - "Windowed/fullscreen — FAIL: [describe issue]"
  - "Resolution changes apply correctly — PASS"
  - "Resolution changes — FAIL: [describe issue]"
```

**主机平台**（`--platform console` 或 `--platform all`）：
```
question: "Smoke check — Console Platform: Verify platform-specific behaviour:"
options:
  - "Gamepad input works correctly for all actions — PASS"
  - "Gamepad input — FAIL: [describe issue]"
  - "UI fits within TV safe zone margins (no text clipped) — PASS"
  - "TV safe zone — FAIL: [describe what is clipped]"
  - "No keyboard/mouse-only fallbacks shown to gamepad user — PASS"
  - "Input prompt inconsistency — FAIL: [describe]"
  - "Game boots correctly from cold start (no prior save) — PASS"
  - "Cold start — FAIL: [describe issue]"
```

**移动平台**（`--platform mobile` 或 `--platform all`）：
```
question: "Smoke check — Mobile Platform: Verify platform-specific behaviour:"
options:
  - "Touch controls work correctly for all primary actions — PASS"
  - "Touch controls — FAIL: [describe issue]"
  - "Game handles orientation change (portrait ↔ landscape) correctly — PASS"
  - "Orientation change — FAIL: [describe what breaks]"
  - "Background / foreground transitions (home button) handled gracefully — PASS"
  - "Background/foreground — FAIL: [describe issue]"
  - "No visible performance issues on target device (no thermal throttling signs) — PASS"
  - "Mobile performance — FAIL: [describe issue]"
```

---

## 阶段 5: 生成报告

组装完整的 Smoke check 报告：

````markdown
## Smoke Check 报告
**日期**: [date]
**Sprint**: [sprint name / number, or "Not identified"]
**引擎**: [engine]
**QA 计划**: [path, or "Not found — run /qa-plan first"]
**参数**: [sprint | quick | blank]

---

### 自动化测试

**状态**: [PASS ([N] tests, [N] passing) | FAIL ([N] failures) |
NOT RUN ([reason])]

[If FAIL, list failing tests:]
- `[test name]` — [brief failure description from runner output]

[If NOT RUN:]
"Manual confirmation required: did tests pass in your local IDE or CI? This
will determine whether the automated test row contributes to a FAIL verdict。"

---

### 测试覆盖

| Story | Type | Test File | Coverage Status |
|-------|------|-----------|----------------|
| [title] | Logic | `tests/unit/[system]/[slug]_test.[ext]` | COVERED |
| [title] | Visual/Feel | `tests/evidence/[slug]-screenshots.md` | MANUAL |
| [title] | Logic | — | MISSING ⚠ |
| [title] | Config/Data | — | EXPECTED |

**Summary**: [N] covered, [N] manual, [N] missing, [N] expected。

---

### 手动 Smoke 检查

- [x] Game launches without crash — PASS
- [x] New game starts — PASS
- [x] [Core mechanic] — PASS
- [ ] [Other check] — FAIL: [user's description]
- [x] Save / load — PASS
- [-] Performance — not checked this session

---

### 缺失的测试证据

必须通过 `/story-done` 标记为 COMPLETE 之前具有测试证据的 Stories：

- **[story title]** (`[path]`) —— 逻辑 Story 没有测试文件。
  预期位置: `tests/unit/[system]/[story-slug]_test.[ext]`

[如果没有:] "All Logic and Integration stories have test coverage。"

---

### 平台特定结果 *（仅当传入 `--platform` 时）*

| 平台 | 检查运行 | 通过 | 失败 | 平台裁决 |
|------|---------|------|------|---------|
| PC | [N] | [N] | [N] | PASS / FAIL |
| Console | [N] | [N] | [N] | PASS / FAIL |
| Mobile | [N] | [N] | [N] | PASS / FAIL |

**平台备注**: [任何未在 pass/fail 中捕获的平台特定观察]

任何平台有一个或多个 FAIL 检查都会贡献给总体 FAIL 裁决。

---

### 裁决: [PASS | PASS WITH WARNINGS | FAIL]

[裁决规则 —— 第一个匹配的规则获胜：]

**FAIL** 如果有以下任何一项：
- 自动化测试套件运行并报告一个或多个测试失败
- 任何批次 1（核心稳定性）检查返回 FAIL
- 任何批次 2（主要 Sprint 机制或回归检查）返回 FAIL

**PASS WITH WARNINGS** 如果全部满足：
- 自动化测试 PASS 或 NOT RUN（开发者尚未确认）
- 所有批次 1 和批次 2 Smoke 检查 PASS
- 一个或多个逻辑/集成 Story 有 MISSING 测试证据

**PASS** 如果全部满足：
- 自动化测试 PASS
- 所有批次中所有 Smoke 检查 PASS 或 N/A
- 没有 MISSING 测试证据条目
````

---

## 阶段 6: 写入和 Gate

在对话中展示完整报告，然后询问：

"我可以将此 Smoke check 报告写入 `production/qa/smoke-[date].md` 吗？"

仅在批准后写入。

写入后，交付 gate 裁决：

**如果裁决是 FAIL：**

"Smoke check 失败。在解决这些失败之前不要交给 QA：

[列出每个失败的自动化测试或 Smoke 检查及一行描述]

修复失败并再次运行 `/smoke-check` 以在 QA 交接前重新 gate。"

**如果裁决是 PASS WITH WARNINGS：**

"Smoke check 通过但有警告。构建已准备好进行手动 QA。

在受影响 Stories 上运行 `/story-done` 之前需要解决的建议项：
[list MISSING test evidence entries]

QA 交接：与 qa-tester agent 分享 `production/qa/qa-plan-[sprint].md` 以开始手动验证。"

**如果裁决是 PASS：**

"Smoke check 干净通过。构建已准备好进行手动 QA。

QA 交接：与 qa-tester agent 分享 `production/qa/qa-plan-[sprint].md` 以开始手动验证。"

---

## 协作协议

- **Never treat NOT RUN as automatic FAIL** —— 将其记录为 NOT RUN 并让
  开发者手动确认状态。未确认的 NOT RUN 贡献给
  PASS WITH WARNINGS，不是 FAIL。
- **Never auto-fix failures** —— 报告它们并说明必须解决什么。
  不要尝试编辑源代码或测试文件。
- **PASS WITH WARNINGS does not block QA hand-off** —— 它记录建议性
  缺口供 `/story-done` 跟进。
- **`quick` argument** 跳过阶段 3（覆盖扫描）和阶段 4 批次 3。
  用于修复特定失败后的快速重新检查。
- 对所有手动 Smoke 检查验证使用 `AskUserQuestion`。
- **Never write the report without asking** —— 阶段 6 在创建任何文件前需要明确
  批准。
