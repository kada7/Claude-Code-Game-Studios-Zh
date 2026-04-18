# Agent 测试规范：qa-tester

## Agent 概述
- **领域**：详细的测试用例编写、bug 报告（结构化格式）、测试执行文档、回归检查清单、冒烟检查执行文档、根据项目的编码标准记录测试证据
- **不负责**：测试策略和测试计划设计（qa-lead）、对已发现 bug 实施修复（相应程序员）、QA 流程架构（qa-lead）
- **分类**：qa
- **模型层级**：Sonnet
- **关卡 ID**：无；将模糊的验收标准标记给 qa-lead 而不是自行解决

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且具有领域特定性（引用测试用例、bug 报告、测试执行、回归测试）
- [ ] `allowed-tools:` 列表与 agent 的角色匹配（对 tests/ 和 production/qa/evidence/ 具有 Read/Write 权限；无源代码编辑工具）
- [ ] 模型层级为 Sonnet（QA 专家的默认设置）
- [ ] Agent 定义不声称对测试策略、修复实施或验收标准定义具有权威性

---

## 测试用例

### 用例 1：领域内请求 — 保存系统的测试用例
**输入**："Write test cases for our save system. It must save and load player position, inventory, and quest state."
**预期行为**：
- 生成一个测试用例列表，至少包含以下测试用例，每个都包含所有四个必需字段：
  - **TC-SAVE-001**：保存和加载玩家位置
  - **TC-SAVE-002**：保存和加载完整库存（多种物品类型、数量、装备状态）
  - **TC-SAVE-003**：保存和加载任务状态（进行中、已完成和锁定的任务状态）
  - **TC-SAVE-004**：覆盖现有保存文件
  - **TC-SAVE-005**：从先前版本加载保存文件（向后兼容性）
  - **TC-SAVE-006**：损坏保存文件处理（文件存在但无效）
- 每个测试用例包括：**前置条件**（测试前所需的游戏状态）、**步骤**（编号的、明确的）、**预期结果**（具体的、可观察的结果）、**通过标准**（二元通过/失败条件）
- 不将"verify the save works"作为通过标准写入 — 标准必须是可观察且明确的

### 用例 2：领域外请求 — 实施 bug 修复
**输入**："You found a bug where the save system loses inventory data on version mismatch. Please fix it."
**预期行为**：
- 不生成任何实施代码或尝试修复保存系统
- 明确声明："Bug fixes are implemented by the appropriate programmer (gameplay-programmer for save system logic); I document the bug and write regression test cases to verify the fix"
- 提供生成：(a) 一个用于程序员的结构化 bug 报告，(b) 用于 TC-SAVE-005（版本不匹配）的回归测试用例，可在修复后运行

### 用例 3：模糊的验收标准 — 标记给 qa-lead
**输入**："Write test cases for the tutorial. The acceptance criterion in the story says 'tutorial should feel intuitive.'"
**预期行为**：
- 将"should feel intuitive"识别为不可测量的验收标准 — 它是主观的质量陈述，而不是可测试的条件
- 不通过自行定义"intuitive"来针对模糊的标准编写测试用例
- 标记给 qa-lead："The acceptance criterion 'tutorial should feel intuitive' is not testable as written; needs clarification — e.g., 'X% of first-time players complete the tutorial without using the hint button' or 'no tester requires external help to complete the tutorial in session'"
- 为 qa-lead 提供两个或三个具体的、可测量的替代标准以供选择

### 用例 4：热修复后的回归测试
**输入**："A hotfix was applied that changed how the inventory serialization handles nullable item slots. Write a targeted regression checklist for the affected systems."
**预期行为**：
- 识别受影响的系统：库存保存/加载、任何读取库存状态的 UI、任何检查库存内容的任务系统、任何读取库存槽位的制作系统
- 生成一个仅针对这些系统的回归检查清单 — 而不是完整的游戏回归
- 检查清单项针对具体更改：空物品槽位处理（空槽位、混合满/空槽位数组、槽位计数边界条件）
- 每个检查清单项指定：测试什么、如何验证通过、失败的表现
- 不生成通用的"测试所有内容"检查清单 — 针对性回归的价值在于特异性

### 用例 5：上下文传递 — 来自 coding-standards.md 的测试证据格式
**输入上下文**：coding-standards.md 指定：Logic story 需要 `tests/unit/[system]/` 中的自动化单元测试。Visual/Feel story 需要 `production/qa/evidence/` 中的截图 + lead 签字。UI story 需要 `production/qa/evidence/` 中的手动演练文档。
**输入**："Write test cases for the inventory UI (a UI story): grid layout, item tooltip display, and drag-and-drop reordering."
**预期行为**：
- 根据提供的标准正确分类为 UI story
- 生成手动演练测试文档（非自动化单元测试）— 因为编码标准为 UI story 指定了手动演练
- 指定输出位置：`production/qa/evidence/`（非 `tests/unit/`）
- 测试用例包括：网格布局验证（所有物品出现，无溢出）、工具提示显示（正确的物品名称、属性、描述在悬停/聚焦时出现）、以及拖放（物品移动到目标槽位，原始槽位变为空，槽位限制被遵守）
- 注意，根据编码标准，这是 ADVISORY 证据级别，不是 BLOCKING — 明确声明这一点，以便团队了解关卡级别

---

## 协议合规性

- [ ] 保持在声明的领域内（测试用例编写、bug 报告、测试执行文档、回归检查清单）
- [ ] 将 bug 修复请求重定向给相应程序员，并提供记录 bug 和编写回归测试的服务
- [ ] 将模糊的验收标准标记给 qa-lead 而不是自行发明可测试的解释
- [ ] 生成针对性的回归检查清单（系统特定的）而非完整的游戏回归通行
- [ ] 根据 coding-standards.md 使用正确的测试证据格式和输出位置

---

## 覆盖范围说明
- 用例 1（测试用例完整性）是基础质量测试 — 缺少字段（前置条件、步骤、预期结果、通过标准）即为失败
- 用例 3（模糊标准）是协调性测试 — qa-tester 不得静默接受不可测试的标准
- 用例 5 需要将 coding-standards.md 置于带有测试证据表格的上下文中；agent 必须正确应用证据类型和位置
- ADVISORY 与 BLOCKING 的关卡级别（用例 5）是一个影响 story 完成的细节 — 验证 agent 报告了它
- 无自动化运行器；手动审查或通过 `/skill-test`