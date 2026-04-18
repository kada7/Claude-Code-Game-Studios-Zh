# 技能测试规范：/skill-test

## 技能摘要

`/skill-test` 验证技能文件的结构正确性、行为合规性和分类评分标准评分。它以三种模式运行：

- **static**：检查单个技能文件的结构要求（前置元数据字段、阶段标题、裁决关键词、“我可以写入吗”语言、下一步交接），无需测试固件。生成逐项检查的 PASS/FAIL 表格。
- **spec**：从 `tests/skills/` 读取测试规范文件，并根据每个测试用例断言评估技能，生成逐用例裁决。
- **audit**：生成 `.claude/skills/` 中所有技能和 `.claude/agents/` 中所有 Agent 的覆盖率表格，显示哪些具有规范文件，哪些没有。

另外的 **category** 模式读取技能分类（例如，关卡技能）的质量评分标准，并根据评分标准准则对技能进行评分。裁决系统因模式而异。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需测试固件。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决：COMPLIANT、NON-COMPLIANT、WARNINGS（静态模式）；PASS、FAIL、PARTIAL（规范模式）；COMPLETE（审计模式）
- [ ] 不包含“我可以写入吗”语言（技能在所有模式下均为只读）
- [ ] 具有下一步交接（例如，`/skill-improve` 以修复发现的问题）

---

## 导演关卡检查

无。`/skill-test` 是元实用技能。无导演关卡适用。

---

## 测试用例

### 用例 1：静态模式 — 格式良好的技能，所有 7 项检查通过，COMPLIANT

**测试固件：**
- `.claude/skills/brainstorm/SKILL.md` 存在且格式良好：
  - 具有所有必需的前置元数据字段
  - 具有 ≥2 个阶段标题
  - 具有裁决关键词
  - 具有“我可以写入吗”语言
  - 具有下一步交接
  - 记录导演关卡
  - 记录关卡模式行为（精简/单人跳过）

**输入：** `/skill-test static brainstorm`

**预期行为：**
1. 技能读取 `.claude/skills/brainstorm/SKILL.md`
2. 技能运行所有 7 项结构检查
3. 所有 7 项检查通过
4. 技能输出一个 PASS/FAIL 表格，所有 7 项检查标记为 PASS
5. 裁决为 COMPLIANT

**断言：**
- [ ] 准确报告 7 项结构检查
- [ ] 所有 7 项标记为 PASS
- [ ] 裁决为 COMPLIANT
- [ ] 未写入任何文件

---

### 用例 2：静态模式 — 技能缺少“我可以写入吗”，尽管 allowed-tools 中包含 Write 工具

**测试固件：**
- `.claude/skills/some-skill/SKILL.md` 的前置元数据 `allowed-tools` 中包含 `Write`
- 技能主体中没有“我可以写入吗”或“我可以更新吗”语言

**输入：** `/skill-test static some-skill`

**预期行为：**
1. 技能读取 `some-skill/SKILL.md`
2. 检查 4（协作写入协议）失败：`allowed-tools` 中包含 `Write` 但未找到“我可以写入吗”语言
3. 所有其他检查可能通过
4. 裁决为 NON-COMPLIANT，检查 4 为失败断言
5. 输出列出检查 4 为 FAIL 并附带解释

**断言：**
- [ ] 检查 4 标记为 FAIL
- [ ] 解释明确指出具体的不匹配（具有 Write 工具但缺少“我可以写入吗”语言）
- [ ] 裁决为 NON-COMPLIANT
- [ ] 显示其他通过的检查（不仅仅是失败项）

---

### 用例 3：规范模式 — 根据规范评估 gate-check 技能

**测试固件：**
- `tests/skills/gate-check.md` 存在，包含 5 个测试用例
- `.claude/skills/gate-check/SKILL.md` 存在

**输入：** `/skill-test spec gate-check`

**预期行为：**
1. 技能读取技能文件和规范文件
2. 技能根据规范断言评估每个测试用例的行为
3. 对于每个用例：如果技能行为与规范断言匹配则为 PASS，否则为 FAIL
4. 技能生成逐用例结果表格
5. 总体裁决：PASS（全部 5 个）、PARTIAL（部分通过）或 FAIL（大多数失败）

**断言：**
- [ ] 评估规范中的所有 5 个测试用例
- [ ] 每个用例具有单独的 PASS/FAIL 结果
- [ ] 总体裁决基于用例结果确定：PASS、PARTIAL 或 FAIL
- [ ] 未写入任何文件

---

### 用例 4：审计模式 — 所有技能和 Agent 的覆盖率表格

**测试固件：**
- `.claude/skills/` 包含 72+ 个技能目录
- `.claude/agents/` 包含 49+ 个 Agent 文件
- `tests/skills/` 包含部分技能的规范文件

**输入：** `/skill-test audit`

**预期行为：**
1. 技能枚举 `.claude/skills/` 中的所有技能和 `.claude/agents/` 中的所有 Agent
2. 技能检查 `tests/skills/` 中每个技能/Agent 的对应规范文件
3. 技能生成覆盖率表格：
   - 列出每个技能/Agent
   - “具有规范”列：YES 或 NO
   - 摘要：“Y 个技能中的 X 个具有规范；B 个 Agent 中的 A 个具有规范”
4. 裁决为 COMPLETE

**断言：**
- [ ] 枚举所有技能目录（不仅仅是样本）
- [ ] “具有规范”列对每个条目准确
- [ ] 摘要计数正确
- [ ] 裁决为 COMPLETE

---

### 用例 5：分类模式 — 根据质量评分标准评估关卡技能

**测试固件：**
- `tests/skills/quality-rubric.md` 存在，包含“关卡技能”部分，定义准则 G1-G5（例如，G1：具有模式保护，G2：具有裁决表等）
- `.claude/skills/gate-check/SKILL.md` 是一个关卡技能

**输入：** `/skill-test category gate-check`

**预期行为：**
1. 技能读取 `quality-rubric.md` 并识别“关卡技能”部分
2. 技能根据准则 G1-G5 评估 `gate-check/SKILL.md`
3. 每个准则评分：PASS、PARTIAL 或 FAIL
4. 计算总体分类分数（例如，5 个准则中 4 个通过）
5. 裁决为 COMPLIANT（全部通过）、WARNINGS（部分通过）或 NON-COMPLIANT（有失败）

**断言：**
- [ ] 评估 quality-rubric.md 中的所有关卡准则（G1-G5）
- [ ] 每个准则具有单独分数
- [ ] 总体裁决反映分数分布
- [ ] 未写入任何文件

---

## 协议合规性

- [ ] 静态模式准确检查 7 项结构断言
- [ ] 规范模式单独评估规范文件中的每个测试用例
- [ ] 审计模式覆盖所有技能和 Agent（不仅仅是单个分类）
- [ ] 分类模式读取 quality-rubric.md 获取准则（非硬编码）
- [ ] 在任何模式下都不写入任何文件
- [ ] 发现问题时建议 `/skill-improve` 作为下一步

---

## 覆盖率说明

- skill-test 技能是自引用的（可以测试自身）。为避免测试设计中的无限递归，skill-test 自身 SKILL.md 的静态模式用例未单独进行固件测试。
- 具体的 7 项结构检查在技能主体中定义；此处仅单独测试检查 4（我可以写入吗），因为其逻辑最为复杂。
- 审计模式计数是近似的 — 技能和 Agent 的确切数量会随着系统增长而变化；断言使用“所有”而非固定计数。