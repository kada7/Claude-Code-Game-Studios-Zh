# Skill Test Spec: /start

## Skill Summary

`/start` 是新项目的首次上手技能。它引导用户完成项目命名、选择游戏引擎和设置初始目录结构。它创建存根配置文件（CLAUDE.md、technical-preferences.md），然后将控制权路由到 `/setup-engine` 并以所选引擎作为参数。每个创建的文件或目录都在 “May I write” 询问后被把关，遵循协作协议。

该技能检测项目是否已配置以及是否存在部分设置，提供恢复或重新开始的选项。它没有导演关卡 — 它是一个工具设置技能，在任何 Agent 层次结构存在之前运行。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含每个配置文件的 “May I write” 协作协议语言
- [ ] 在末尾有一个下一步交接（路由到 `/setup-engine`）

---

## Director Gate Checks

无。`/start` 是一个工具设置技能。在该技能运行时，导演 Agent 尚不存在。

---

## Test Cases

### Case 1: Happy Path — 全新仓库，无引擎，完整上手流程

**Fixture:**
- 空仓库：没有 CLAUDE.md 覆盖，没有 `production/stage.txt`，`technical-preferences.md` 内容除占位符外为空
- 没有现有设计文档或源代码

**Input:** `/start`

**Expected behavior:**
1. 技能检测到没有现有配置，开始全新的上手流程
2. 技能询问项目名称
3. 技能呈现 3 个引擎选项：Godot 4、Unity、Unreal Engine 5
4. 用户选择一个引擎
5. 技能询问 “May I write the initial directory structure?”
6. 技能创建 `directory-structure.md` 中定义的所有目录
7. 技能询问 “May I write CLAUDE.md stub?” 并在批准后写入
8. 技能路由到 `/setup-engine [chosen-engine]` 以完成技术配置

**Assertions:**
- [ ] 在任何文件写入前捕获项目名称
- [ ] 恰好呈现 3 个引擎选项
- [ ] 为每个配置文件单独询问 “May I write”
- [ ] 未经用户明确批准不写入任何文件
- [ ] 在最后交接给 `/setup-engine` 并带有所选引擎参数
- [ ] 所有文件写入并交接后裁决为 COMPLETE

---

### Case 2: Already Configured — 检测到现有配置，提供跳过或重新配置的选项

**Fixture:**
- `technical-preferences.md` 已设置引擎（不是占位符）
- `production/stage.txt` 存在，包含 `Concept`

**Input:** `/start`

**Expected behavior:**
1. 技能读取 `technical-preferences.md` 并检测到已配置的引擎
2. 技能报告：“This project is already configured with [engine]”
3. 技能呈现选项：跳过（退出）、重新配置引擎，或重新配置特定部分
4. 如果用户选择跳过：技能干净退出，摘要显示当前配置
5. 如果用户选择重新配置：技能进入引擎选择步骤

**Assertions:**
- [ ] 用户未选择重新配置时，技能不会覆盖现有配置
- [ ] 状态消息中向用户显示检测到的引擎名称
- [ ] 至少提供 2 个选项（跳过或重新配置）
- [ ] 无论用户跳过还是重新配置，裁决都为 COMPLETE

---

### Case 3: Engine Choice — 用户选择 Godot 4，路由到 /setup-engine godot

**Fixture:**
- 全新仓库 — 没有现有配置

**Input:** `/start`

**Expected behavior:**
1. 技能呈现引擎选项，用户选择 Godot 4
2. 技能写入初始存根（目录结构、CLAUDE.md）在批准后
3. 技能明确路由到 `/setup-engine godot` 作为下一步
4. 交接消息清晰命名引擎和下一个技能调用

**Assertions:**
- [ ] 交接命令是 `/setup-engine godot`（不是通用的 `/setup-engine`）
- [ ] 交接在所有初始存根写入后发出，不是之前
- [ ] 在开始写入前向用户回显引擎选择

---

### Case 4: Interrupted Setup — 检测到部分配置，提供恢复或重新开始的选项

**Fixture:**
- 目录结构存在（已创建）但 `technical-preferences.md` 仍然是所有占位符（从未选择引擎 — 设置被中断）
- 没有 `production/stage.txt`

**Input:** `/start`

**Expected behavior:**
1. 技能检测到部分状态：目录存在但引擎未配置
2. 技能报告：“A partial setup was detected — directories exist but engine is not configured”
3. 技能提供选项：从引擎选择处恢复，或从零开始重新开始
4. 如果恢复：技能跳过目录创建，进入引擎选择
5. 如果重新开始：技能在继续前询问 “May I overwrite existing structure?”

**Assertions:**
- [ ] 正确识别部分状态（目录存在，引擎缺失）
- [ ] 用户可以选择恢复 vs. 重新开始 — 不强制选择一条路径
- [ ] 恢复路径跳过重新创建目录（没有冗余的 “May I write” 询问结构）
- [ ] 重新开始路径在触及任何文件前请求覆盖许可

---

### Case 5: Director Gate Check — 无关卡；start 是一个工具设置技能

**Fixture:**
- 任何 fixture

**Input:** `/start`

**Expected behavior:**
1. 技能完成完整上手流程
2. 在任何时候都不会生成导演 Agent
3. 输出中不出现任何关卡 ID（CD-*, TD-*, AD-*, PR-*）

**Assertions:**
- [ ] 技能执行期间不调用导演关卡
- [ ] 不出现关卡跳过消息（关卡不存在，不是被抑制）
- [ ] 技能在没有关卡裁决的情况下到达 COMPLETE

---

## Protocol Compliance

- [ ] 在任何文件写入前询问项目名称
- [ ] 以结构化选择（不是自由文本）呈现引擎选项
- [ ] 分别为目录结构和 CLAUDE.md 存根询问 “May I write”
- [ ] 以交接给 `/setup-engine` 并以引擎名称作为参数结束
- [ ] 输出末尾明确说明裁决（COMPLETE 或 BLOCKED）

---

## Coverage Notes

- 用户拒绝所有引擎选项并提供自定义引擎名称的情况未测试 — 该技能仅为三个支持的引擎设计。
- Git 初始化（如果有的话）不在此测试；这是技能边界之外的基础设施问题。
- Solo vs. lean 模式行为不适用 — 该技能没有关卡，模式选择无关。