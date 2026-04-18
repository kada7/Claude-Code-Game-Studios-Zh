---
name: test-flakiness
description: "通过读取 CI 运行日志或测试结果历史检测非确定性（不稳定）测试。汇总每个测试的通过率，识别间歇性失败，建议隔离或修复，并维护不稳定测试注册表。最好在 Polish 阶段或多次 CI 运行后运行。"
argument-hint: "[ci-log-path | scan | registry]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# Test Flakiness Detection

不稳定测试是指有时通过有时失败而没有任何代码更改的测试。不稳定测试在某些方面比没有测试更糟 — 它们训练团队忽视红色的 CI 运行，掩盖真正的失败。此 skill 识别它们，解释可能的原因，并建议是否隔离或修复每个测试。

**输出：** 更新的 `tests/regression-suite.md` 隔离部分 + 可选的 `production/qa/flakiness-report-[date].md`

**何时运行：**

- Polish 阶段（测试已运行多次；统计信号可靠）
- 当开发人员开始忽视 CI 失败为"可能不稳定"
- 在 `/regression-suite` 识别需要诊断的隔离测试之后

---

## 1. 解析参数

**模式：**

- `/test-flakiness [ci-log-path]` — 分析特定的 CI 运行日志文件
- `/test-flakiness scan` — 扫描 `.github/` 或标准日志输出目录中的所有可用 CI 日志
- `/test-flakiness registry` — 读取现有的 regression-suite.md 隔离部分，并为已知的隔离测试提供修复指导
- 无参数 — 自动检测：如果可访问 CI 日志则运行 `scan`，否则运行 `registry`

---

## 2. 定位 CI 日志数据

### 选项 A — GitHub Actions（首选）

检查测试结果工件：

```bash
ls -t .github/ 2>/dev/null
ls -t test-results/ 2>/dev/null
```

对于 Godot 项目：GdUnit4 输出与 JUnit 格式兼容的 XML 结果。检查 `test-results/` 中的 `.xml` 文件。

对于 Unity 项目：game-ci test runner 默认输出 NUnit XML 到 `test-results/`。

对于 Unreal 项目：自动化日志进入 `Saved/Logs/`。Grep 查找 `Result: Success` 和 `Result: Fail` 模式。

### 选项 B — 本地日志文件

如果提供了路径参数，直接读取该文件。

### 选项 C — 无日志数据可用

如果未找到日志：

> "未找到 CI 日志数据。要检测不稳定测试，此 skill 需要来自多次运行的测试结果历史。选项：
>
> 1. 运行测试套件至少 3 次并收集输出日志
> 2. 检查 CI 管道输出并将日志保存到 `test-results/`
> 3. 运行 `/test-flakiness registry` 审查 `tests/regression-suite.md` 中已标记为不稳定的测试"

停止并询问用户选择哪个选项。

---

## 3. 解析测试结果

对于找到的每个 CI 日志或结果文件，解析：

**JUnit XML 格式** (GdUnit4 / Unity)：

- Grep `<testcase name=` 获取测试名称
- Grep `<failure` 或 `<error` 识别失败
- 解析 `classname` 和 `name` 属性获取完整测试标识符

**纯文本日志**：

- Grep 通过/失败模式：
  - Godot: `PASSED` / `FAILED` 与测试名称相邻
  - Unreal: `Result: Success` / `Result: Fail`
  - Unity: `Test passed` / `Test failed`

构建表格：`test_id → [run1_result, run2_result, run3_result, ...]`

---

## 4. 识别不稳定测试

如果测试在结果历史中出现 **PASS** 和 **FAIL** 结果，且它们之间没有代码更改，则该测试为**不稳定**。

不稳定阈值：

- **高不稳定**：>25% 的运行失败 — 立即隔离
- **中等不稳定**：5-25% 的运行失败 — 尽快调查并修复
- **低/疑似不稳定**：1-5% 的运行失败 — 监控；可能是真正的罕见失败

对于每个不稳定测试，分类可能的原因：

### 原因分类

| 原因 | 症状 | 修复方向 |
|------|------|----------|
| **Timing / async** | 在 await signals 或 timers 后失败；通过率与系统负载相关 | 添加显式 await/同步；避免基于时间的延迟 |
| **Order dependency** | 在特定其他测试之后运行时失败；单独运行时通过 | 添加正确的 setup/teardown；确保测试隔离 |
| **Random seed** | 无规律间歇性失败；涉及 RNG | 传递显式 seed；测试中不使用 `randf()` |
| **Resource leak** | 在测试运行后期更频繁失败 | 修复 teardown 中的清理；检查孤儿节点 (Godot) 或对象处置 (Unity) |
| **External state** | 当文件、场景或全局存在前一个测试的内容时失败 | 将测试与文件系统隔离；使用内存 mock |
| **Floating point** | 在 `== 0.5` 等比较上失败 | 使用 epsilon 比较 (`is_equal_approx`, `Assert.AreApproximately`) |
| **Scene/prefab load race** | 场景尚未准备好时失败 | 实例化后 await 一帧；使用 `await get_tree().process_frame` |

使用 Grep 检查测试文件中是否有 timing 调用、randf、全局状态访问或浮点数相等比较，以缩小原因范围。

---

## 5. 建议操作

对于每个不稳定测试：

**隔离（高不稳定）：**

> "立即隔离此测试。通过在 CI 中添加 `@pytest.mark.skip` / `[Ignore]` / `GdUnitSkip` 注解禁用它。将其记录在 `tests/regression-suite.md` 隔离部分。该测试现在是选择性运行的。在移除隔离前修复根本原因。"

**尽快调查并修复（中等）：**

> "此测试间歇性不可靠。根本原因似乎是 [原因]。建议修复：[基于原因分类的具体修复]。不要隔离 — 直接修复测试。"

**监控（低/疑似）：**

> "此测试显示疑似不稳定。在隔离前收集更多运行数据。将其在回归套件中标记为'suspected'。"

---

## 6. 生成报告

### 对话中摘要

```
## Flakiness Detection Results

**Runs analysed**: [N]
**Tests tracked**: [N]

### Flaky Tests Found

| Test | System | Fail Rate | Likely Cause | Recommendation |
|------|--------|-----------|--------------|----------------|
| [test_name] | [system] | [N]% | Timing | Quarantine + fix async |
| [test_name] | [system] | [N]% | Float comparison | Fix: use epsilon compare |
| [test_name] | [system] | [N]% | Order dependency | Investigate teardown |

### Clean Tests (no flakiness detected)

[N] tests ran across [N] runs with consistent results — no flakiness detected.

### Data Limitations

[Note if fewer than 5 runs were available — fewer runs = less statistical confidence]
```

---

## 7. 更新回归套件 + 可选报告文件

询问："我可以更新 `tests/regression-suite.md` 的隔离部分，添加找到的不稳定测试吗？"

如果是：使用 `Edit` 追加条目到 Quarantined Tests 表格。永远不要移除现有的隔离条目 — 只添加新的。

单独询问："我可以将完整的 flakiness 报告写入 `production/qa/flakiness-report-[date].md` 吗？"

完整报告包含带有原因详情和引擎特定修复片段的每个测试分析。

写入后：

- 对于每个隔离测试："添加引擎特定的 skip 注解以在 CI 中禁用此测试。修复根本原因后重新启用。"
- 对于可修复测试："[test] 的修复很简单 — 将第 [N] 行的相等比较更改为使用 `is_equal_approx`。"
- 摘要："应用所有隔离注解后，CI 应运行绿色。在发布门前安排对 [N] 个隔离测试的修复工作。"

---

## Collaborative Protocol

- **永远不要删除测试文件** — 隔离意味着注解 + 列出，不是移除
- **统计置信度很重要** — 少于 3 次运行时，将发现标记为"suspected"而非"confirmed"；询问是否有更多运行数据可用
- **修复始终是目标** — 隔离是临时的；即使在建议隔离时也要提出修复方向
- **写入前询问** — regression-suite 更新和报告文件都需要明确批准。写入时：裁决：**COMPLETE** — flakiness report written。拒绝时：裁决：**BLOCKED** — user declined write。
- **CI 中的不稳定是团队问题** — 清晰展示列表和推荐操作；不要只是默默隔离而不让团队知道
