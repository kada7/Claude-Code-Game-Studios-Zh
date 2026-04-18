# 技能测试规范：/dev-story

## 技能摘要

`/dev-story` 读取故事文件，加载所有必需的上下文（引用的 ADR、注册表中的 TR-ID、控制清单、引擎偏好设置），实现故事，验证所有验收标准均已满足，并将故事标记为完成。该技能根据引擎和文件类型将实现路由给正确的专家代理 —— 它不直接编写源代码。

在 `full` 评审模式下，在将故事标记为完成之前会运行 LP-CODE-REVIEW 门。在 `lean` 或 `solo` 模式下，跳过 LP-CODE-REVIEW，并在用户确认所有标准已满足后将故事标记为完成。该技能在更新故事状态和编写代码文件之前会询问“我可以写入吗”。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED、IN PROGRESS、NEEDS CHANGES
- [ ] 包含“我可以写入吗”协作协议语言（故事状态 + 代码文件）
- [ ] 在末尾具有下一步交接（`/story-done`）
- [ ] 记录 LP-CODE-REVIEW 门：在完整模式下激活，在精简/单独模式下跳过
- [ ] 注明实现委托给专家代理（非直接完成）

---

## 总监门检查

在 `full` 模式下：LP-CODE-REVIEW 门在实现完成且所有标准验证通过后运行，然后在将故事标记为完成之前运行。

在 `lean` 模式下：跳过 LP-CODE-REVIEW。输出注明：
"LP-CODE-REVIEW 跳过 —— 精简模式"。在用户确认后将故事标记为完成。

在 `solo` 模式下：跳过 LP-CODE-REVIEW 并附有等效说明。

---

## 测试用例

### 用例 1：快乐路径 —— 故事已实现并标记为完成（完整模式）

**夹具：**
- 故事文件存在于 `production/epics/[layer]/story-[name].md`，且包含：
  - `Status: Ready`
  - 引用已注册需求的 TR-ID
  - 至少 2 个 Given-When-Then 验收标准
  - 测试证据路径
- 引用的 ADR 具有 `Status: Accepted`
- `docs/architecture/control-manifest.md` 存在
- `.claude/docs/technical-preferences.md` 已配置引擎和语言
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事文件及所有引用的上下文
2. 技能验证 ADR 为已接受（无阻碍）
3. 技能将实现路由给正确的专家代理
4. 所有验收标准均被验证为已满足
5. LP-CODE-REVIEW 门被触发并返回 APPROVED
6. 技能询问“我可以将故事状态更新为 Complete 吗？”
7. 故事状态更新为 Complete

**断言：**
- [ ] 技能在触发任何代理之前读取故事
- [ ] 在开始实现之前检查 ADR 状态
- [ ] 实现委托给专家代理（非内联完成）
- [ ] 所有验收标准在 LP-CODE-REVIEW 之前已确认
- [ ] 输出中显示 LP-CODE-REVIEW 作为已完成的门
- [ ] 故事状态仅在门批准和用户同意后更新为 Complete
- [ ] 测试文件作为实现的一部分写入（非延迟）

---

### 用例 2：失败路径 —— 引用的 ADR 处于提议状态

**夹具：**
- 存在一个故事文件，具有 `Status: Ready`
- 故事的 TR-ID 指向一个由具有 `Status: Proposed` 的 ADR 覆盖的需求

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事文件
2. 技能解析 TR-ID 并读取管辖 ADR
3. ADR 状态为 Proposed —— 技能输出一条 BLOCKED 消息
4. 技能指明阻碍故事的特定 ADR
5. 技能建议运行 `/architecture-decision` 以推进 ADR
6. 实现**不**开始

**断言：**
- [ ] 技能**不**在 ADR 为 Proposed 时开始实现
- [ ] BLOCKED 消息指明特定的 ADR 编号和标题
- [ ] 技能建议 `/architecture-decision` 作为下一步操作
- [ ] 故事状态保持不变（未设置为 In Progress 或 Complete）

---

### 用例 3：模糊的验收标准 —— 技能请求澄清

**夹具：**
- 存在一个故事文件，具有 `Status: Ready`
- 引用的 ADR 为 Accepted
- 一个验收标准模糊（非 Given-When-Then；使用主观语言，如“感觉响应”）

**输入：** `/dev-story production/epics/[layer]/story-[name].md`

**预期行为：**
1. 技能读取故事并识别模糊的标准
2. 在路由给专家之前，技能要求用户澄清该标准
3. 用户提供具体、可测试的重述
4. 技能使用澄清后的标准进行实现
5. 技能**不**猜测预期行为

**断言：**
- [ ] 技能在开始实现前暴露模糊的标准
- [ ] 技能请求用户澄清（非自动解释）
- [ ] 仅在提供澄清后才开始实现
- [ ] 测试中使用澄清后的标准（非原始模糊版本）

---

### 用例 4：边界情况 —— 无参数；从会话状态读取

**夹具：**
- 未提供参数
- `production/session-state/active.md` 引用了一个活跃的故事文件
- 该故事文件存在且具有 `Status: In Progress`

**输入：** `/dev-story`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 技能读取 `production/session-state/active.md`
3. 技能找到活跃的故事引用
4. 技能与用户确认：“继续处理 [故事标题] —— 是否正确？”
5. 确认后，技能继续处理该故事

**断言：**
- [ ] 技能在未提供参数时读取会话状态
- [ ] 技能在继续之前与用户确认活跃故事
- [ ] 技能**不**在未经确认的情况下默默假设活跃故事
- [ ] 如果会话状态无活跃故事，技能询问要实现哪个故事

---

### 用例 5：总监门 —— LP-CODE-REVIEW 返回 NEEDS CHANGES；精简模式跳过门

**夹具（完整模式）：**
- 故事已实现且所有标准似乎已满足
- `production/session-state/review-mode.txt` 包含 `full`
- LP-CODE-REVIEW 门返回 NEEDS CHANGES 及具体反馈

**完整模式预期行为：**
1. LP-CODE-REVIEW 门在实现后触发
2. 门返回 NEEDS CHANGES 及 2 个具体问题
3. 故事状态保持为 In Progress —— **不**标记为 Complete
4. 向用户显示门反馈并询问如何继续

**断言（完整模式）：**
- [ ] 当 LP-CODE-REVIEW 返回 NEEDS CHANGES 时，故事**不**标记为 Complete
- [ ] 向用户逐字显示门反馈
- [ ] 故事状态保持为 In Progress，直到问题解决且门通过

**夹具（精简模式）：**
- 相同故事，`production/session-state/review-mode.txt` 包含 `lean`

**精简模式预期行为：**
1. 实现完成
2. LP-CODE-REVIEW 门被跳过 —— 在输出中注明
3. 用户被要求确认所有标准已满足
4. 用户确认后，故事标记为 Complete

**断言（精简模式）：**
- [ ] 输出中出现“LP-CODE-REVIEW 跳过 —— 精简模式”
- [ ] 用户确认标准后故事标记为 Complete（无需门）
- [ ] 技能**不**在被跳过的门处阻塞

---

## 协议合规性

- [ ] **不**直接编写源代码 —— 委托给专家代理
- [ ] 在实现之前读取所有上下文（故事、TR-ID、ADR、清单、引擎偏好设置）
- [ ] 在更新故事状态和编写代码文件之前询问“我可以写入吗”
- [ ] 被跳过的门在输出中按名称和模式注明
- [ ] 故事完成后更新 `production/session-state/active.md`
- [ ] 以下一步交接结束：`/story-done`

---

## 覆盖范围说明

- 引擎路由逻辑（Godot vs Unity vs Unreal）不按引擎测试 —— 路由模式是一致的；引擎选择是一个配置事实。
- 视觉/感觉和 UI 故事类型（无需自动测试）有不同的证据要求，且未在这些用例中覆盖。
- 集成故事类型遵循与 Logic 相同的模式，但证据路径不同 —— 未独立进行夹具测试。