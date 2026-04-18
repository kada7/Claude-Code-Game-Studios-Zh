# 技能测试规范：/smoke-check

## 技能摘要

`/smoke-check` 是实施与质量保证交接之间的守门员。它检测测试环境，运行自动化测试套件（通过 Bash），扫描针对冲刺故事测试覆盖率，并使用 `AskUserQuestion` 与开发者批量验证手动冒烟检查。在获得用户明确批准后，它将报告写入 `production/qa/smoke-[date].md`。

裁决结果：PASS（测试通过，所有冒烟检查通过，无缺失测试证据）、PASS WITH WARNINGS（测试通过或 NOT RUN，所有关键检查通过，但存在建议性缺失，例如缺失测试覆盖率）或 FAIL（任何自动化测试失败或任何 Batch 1/Batch 2 冒烟检查返回 FAIL）。

无导演关卡适用。此技能不调用任何导演 Agent。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需测试固件。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：PASS、PASS WITH WARNINGS、FAIL
- [ ] 包含在写入报告前的“我可以写入吗”协作协议语言
- [ ] 具有下一步交接（例如，FAIL 时使用 `/bug-report`，PASS 时提供质量保证交接指导）

---

## 导演关卡检查

无。`/smoke-check` 是质量保证预检实用技能。无导演关卡适用。

---

## 测试用例

### 用例 1：理想路径 — 自动化测试通过，手动项确认，PASS

**测试固件：**
- `tests/` 目录存在，包含 GDUnit4 运行脚本
- 从 `technical-preferences.md` 检测到引擎为 Godot
- `production/qa/qa-plan-sprint-005.md` 存在
- 自动化测试运行器报告 12 个测试，12 个通过，0 个失败
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS
- 所有冲刺故事都有匹配的测试文件（无 MISSING 覆盖率）

**输入：** `/smoke-check`

**预期行为：**
1. 技能检测测试目录和引擎，记录质量保证计划已找到
2. 通过 Bash 运行 `godot --headless --script tests/gdunit4_runner.gd`
3. 解析输出：12/12 通过
4. 扫描测试覆盖率 — 所有故事已 COVERED 或 EXPECTED
5. 使用 `AskUserQuestion` 处理 Batch 1（核心稳定性）和 Batch 2（冲刺机制）
6. 开发者为所有项选择 PASS
7. 组装报告：自动化测试 PASS，所有冒烟检查 PASS，无 MISSING 覆盖率
8. 询问“我可以将此冒烟检查报告写入 `production/qa/smoke-[date].md` 吗？”
9. 批准后写入报告
10. 交付裁决：PASS

**断言：**
- [ ] 通过 Bash 调用自动化测试运行器
- [ ] 使用 `AskUserQuestion` 处理手动冒烟检查批次
- [ ] 在写入报告文件前询问“我可以写入吗”
- [ ] 报告写入 `production/qa/smoke-[date].md`
- [ ] 裁决为 PASS

---

### 用例 2：失败路径 — 自动化测试失败，FAIL 裁决

**测试固件：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试运行器报告运行 10 个测试：8 个通过，2 个失败
  - 失败测试：`test_health_clamp_at_zero`、`test_damage_calculation_negative`
- 质量保证计划存在

**输入：** `/smoke-check`

**预期行为：**
1. 技能通过 Bash 运行自动化测试
2. 解析输出 — 检测到 2 个失败
3. 记录失败的测试名称
4. 继续进行手动冒烟检查批次
5. 报告显示自动化测试为 FAIL，并列出失败测试名称
6. 询问是否写入报告；批准后写入
7. 交付 FAIL 裁决并显示消息：“冒烟检查失败。在解决这些失败之前，不要交接给质量保证。”列出失败测试，并建议修复后重新运行 `/smoke-check`

**断言：**
- [ ] 失败的测试名称在报告中列出
- [ ] 裁决为 FAIL
- [ ] 裁决后消息指导开发者在质量保证交接前修复失败
- [ ] 修复后建议重新运行 `/smoke-check`

---

### 用例 3：手动确认 — 使用 AskUserQuestion，PASS WITH WARNINGS

**测试固件：**
- `tests/` 目录存在，引擎为 Godot
- 自动化测试运行器报告所有测试通过 (8/8)
- 一个 Logic 故事没有匹配的测试文件（MISSING 覆盖率）
- 开发者确认所有 Batch 1 和 Batch 2 冒烟检查为 PASS

**输入：** `/smoke-check`

**预期行为：**
1. 自动化测试 PASS
2. 覆盖率扫描发现 1 个 Logic 故事的 MISSING 条目
3. 使用 `AskUserQuestion` 处理 Batch 1 和 Batch 2 — 开发者确认所有 PASS
4. 报告显示：自动化测试 PASS，手动检查全部 PASS，1 个 MISSING 覆盖率条目
5. 裁决为 PASS WITH WARNINGS — 构建已准备好进行质量保证，但必须在 `/story-done` 关闭受影响故事前解决 MISSING 条目
6. 询问是否写入报告；批准后写入

**断言：**
- [ ] 使用 `AskUserQuestion` 处理手动冒烟检查批次（而非内联文本提示）
- [ ] 报告中出现 MISSING 测试覆盖率条目
- [ ] 裁决为 PASS WITH WARNINGS（非 PASS，非 FAIL）
- [ ] 建议性说明解释必须在 `/story-done` 前解决 MISSING 条目
- [ ] 报告文件写入 `production/qa/smoke-[date].md`

---

### 用例 4：无测试目录 — 技能停止并提供指导

**测试固件：**
- `tests/` 目录不存在
- 引擎配置为 Godot

**输入：** `/smoke-check`

**预期行为：**
1. 阶段 1 检查 `tests/` 目录 — 未找到
2. 技能输出：“在 `tests/` 未找到测试目录。运行 `/test-setup` 以搭建测试基础设施，或者如果测试位于其他地方，则手动创建目录。”
3. 技能停止 — 未运行自动化测试，未进行手动冒烟检查，未写入报告

**断言：**
- [ ] 错误消息引用缺失的 `tests/` 目录
- [ ] 建议 `/test-setup` 作为修复步骤
- [ ] 在此消息后技能停止（不运行后续阶段）
- [ ] 未写入报告文件

---

### 用例 5：导演关卡检查 — 无关卡；smoke-check 是质量保证预检实用技能

**测试固件：**
- 有效的测试设置，自动化测试通过，手动冒烟检查已确认

**输入：** `/smoke-check`

**预期行为：**
1. 技能运行所有阶段并产生 PASS 或 PASS WITH WARNINGS 裁决
2. 在任何时候都不产生导演 Agent
3. 输出中不出现关卡 ID（CD-*、TD-*、AD-*、PR-*）
4. 不调用 `/gate-check`

**断言：**
- [ ] 不调用导演关卡
- [ ] 不出现关卡跳过消息
- [ ] 裁决为 PASS、PASS WITH WARNINGS 或 FAIL — 不涉及关卡裁决

---

## 协议合规性

- [ ] 对所有手动冒烟检查批次（Batch 1、Batch 2、Batch 3）使用 `AskUserQuestion`
- [ ] 在询问任何手动问题前通过 Bash 运行自动化测试
- [ ] 在创建报告文件前询问“我可以写入吗” — 未经批准绝不写入
- [ ] 裁决词汇严格为 PASS / PASS WITH WARNINGS / FAIL — 无其他裁决
- [ ] 自动化测试失败或 Batch 1/Batch 2 FAIL 响应触发 FAIL
- [ ] 当存在 MISSING 测试覆盖率但无关键失败时触发 PASS WITH WARNINGS
- [ ] NOT RUN（引擎二进制文件不可用）记录为警告，而非 FAIL
- [ ] 在任何时候都不调用导演关卡

---

## 覆盖率说明

- `quick` 参数（跳过阶段 3 覆盖率扫描和 Batch 3）未单独进行固件测试；它遵循与用例 1 相同的模式，并在输出中带有覆盖率跳过说明。
- `--platform` 参数添加特定平台的 AskUserQuestion 批次和每个平台的裁决表；不在此单独测试。
- 引擎二进制文件不在 PATH 上的情况（NOT RUN）遵循 PASS WITH WARNINGS 模式，并由上述协议合规性断言覆盖。