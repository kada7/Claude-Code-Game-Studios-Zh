# Skill Test Spec: /help

## Skill Summary

`/help` 分析项目工作流中已完成的内容和接下来的步骤。它在 Haiku 模型（只读，格式化任务）上运行，读取 `production/stage.txt`、活动 sprint 文件和最近的会话状态，以生成简洁的情境指导摘要。该技能可选地接受上下文查询（例如 `/help testing`）来显示特定主题的相关技能。

输出始终是信息性的 — 不写入任何文件，不调用任何导演关卡。裁决始终是 HELP COMPLETE。该技能用作工作流导航器，根据当前项目状态建议 2-3 个后续技能。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：HELP COMPLETE
- [ ] 不包含 “May I write” 语言（技能是只读的）
- [ ] 具有下一步交接（根据状态建议 2-3 个相关技能）

---

## Director Gate Checks

无。`/help` 是一个只读导航技能。没有导演关卡适用。

---

## Test Cases

### Case 1: Happy Path — 生产阶段，有活动 sprint

**Fixture:**
- `production/stage.txt` 包含 `Production`
- `production/sprints/sprint-004.md` 存在，具有进行中的故事
- `production/session-state/active.md` 有最近的检查点

**Input:** `/help`

**Expected behavior:**
1. 技能读取 stage.txt 和活动 sprint
2. 技能识别当前 sprint 编号和进行中故事数量
3. 技能输出：当前阶段、sprint 摘要和 3 个建议的后续技能
   （例如 `/sprint-status`、`/dev-story`、`/story-done`）
4. 建议根据当前 sprint 状态的相关性排名
5. 裁决是 HELP COMPLETE

**Assertions:**
- [ ] 显示当前阶段 (Production)
- [ ] 提及活动 sprint 编号和故事数量
- [ ] 恰好给出 2-3 个后续技能建议（不是所有技能的列表）
- [ ] 建议适用于生产阶段
- [ ] 裁决是 HELP COMPLETE
- [ ] 不写入任何文件

---

### Case 2: Concept Stage — 显示从概念到系统设计的工作流路径

**Fixture:**
- `production/stage.txt` 包含 `Concept`
- 没有 sprint 文件，没有 GDD 文件
- `technical-preferences.md` 已配置（引擎已选择）

**Input:** `/help`

**Expected behavior:**
1. 技能读取 stage.txt — 检测到 Concept 阶段
2. 技能输出 Concept 阶段工作流：brainstorm → map-systems → design-system
3. 建议的技能是：`/brainstorm`、`/map-systems`（如果概念存在）
4. 记录当前进度：“Engine configured, concept not yet created”

**Assertions:**
- [ ] 阶段被识别为 Concept
- [ ] 工作流路径显示此阶段的预期序列
- [ ] 建议不包含生产阶段技能（例如 `/dev-story`）
- [ ] 裁决是 HELP COMPLETE

---

### Case 3: No stage.txt — 显示完整工作流概览

**Fixture:**
- 没有 `production/stage.txt`
- 没有 sprint 文件
4. `technical-preferences.md` 具有占位符

**Input:** `/help`

**Expected behavior:**
1. 技能无法从 stage.txt 确定阶段
2. 技能运行 project-stage-detect 逻辑以从工件推断阶段
3. 如果无法推断阶段：输出从概念到发布的完整工作流概览作为参考图
4. 主要建议是 `/start` 以开始配置

**Assertions:**
- [ ] stage.txt 不存在时技能不会崩溃
- [ ] 阶段无法确定时显示完整工作流概览
- [ ] `/start` 或 `/project-stage-detect` 是首要建议
- [ ] 裁决是 HELP COMPLETE

---

### Case 4: Context Query — 用户请求有关测试的帮助

**Fixture:**
- `production/stage.txt` 包含 `Production`
- 活动 sprint 有一个带有 `Status: In Review` 的故事

**Input:** `/help testing`

**Expected behavior:**
1. 技能读取上下文查询：“testing”
2. 技能显示与测试相关的技能：`/qa-plan`、`/smoke-check`、`/regression-suite`、`/test-setup`、`/test-evidence-review`
3. 输出专注于测试工作流，而非通用 sprint 导航
4. 当前审查中的故事被突出显示为测试候选

**Assertions:**
- [ ] 输出中确认上下文查询（“Help topic: testing”）
- [ ] 至少列出 3 个与测试相关的技能
- [ ] 通用 sprint 技能（例如 `/sprint-plan`）不是主要建议
- [ ] 裁决是 HELP COMPLETE

---

### Case 5: Director Gate Check — 无关卡；help 是只读导航

**Fixture:**
- 任何项目状态

**Input:** `/help`

**Expected behavior:**
1. 技能生成工作流指导摘要
2. 不生成导演 Agent
3. 输出中不出现关卡 ID
4. 不调用写入工具

**Assertions:**
- [ ] 不调用导演关卡
- [ ] 不调用写入工具
- [ ] 不出现关卡跳过消息
- [ ] 裁决是 HELP COMPLETE，没有任何关卡检查

---

## Protocol Compliance

- [ ] 在生成建议前读取阶段、sprint 和会话状态
- [ ] 建议针对当前项目状态（不是通用的）
- [ ] 上下文查询（如果提供）缩小建议集
- [ ] 不写入任何文件
- [ ] 在所有情况下裁决都是 HELP COMPLETE

---

## Coverage Notes

- 活动 sprint 完成（所有故事 Done）的情况不单独测试；技能将建议 `/sprint-plan` 用于下一个 sprint。
- `/help` 技能不验证建议的技能是否可用 — 它假定标准技能目录可用。
- 阶段检测回退（当 stage.txt 不存在时）委托给与 `/project-stage-detect` 相同的逻辑，在此不详细重新测试。