# 技能测试规范：/regression-suite

## 技能摘要

`/regression-suite` 将测试覆盖映射到 GDD 需求：它读取当前迭代（或指定史诗）中故事文件的验收标准，然后扫描 `tests/` 目录以查找相应的测试文件，并检查每个 AC 是否有匹配的断言。它生成一个覆盖报告，识别哪些 AC 被完全覆盖、部分覆盖或未测试，以及哪些测试文件没有匹配的 AC（孤立测试）。

该技能可能在"是否允许写入"询问后将覆盖报告写入 `production/qa/`。不适用导演关口。裁决结果：FULL COVERAGE（所有 AC 都有测试）、GAPS FOUND（某些 AC 未测试）或 CRITICAL GAPS（关键优先级的 AC 没有测试）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：FULL COVERAGE、GAPS FOUND、CRITICAL GAPS
- [ ] 包含"是否允许写入"语言（技能可能写入覆盖报告）
- [ ] 具有下一步交接（例如，如果框架缺失则为 `/test-setup`，如果计划缺失则为 `/qa-plan`）

---

## 导演关口检查

无。`/regression-suite` 是一个 QA 分析实用工具。不适用导演关口。

---

## 测试用例

### 案例 1：完全覆盖——迭代中的所有 AC 都有相应的测试

**测试夹具：**
- `production/sprints/sprint-004.md` 列出了 3 个故事，每个故事有 2 个 AC（共 6 个）
- `tests/unit/` 和 `tests/integration/` 包含与所有 6 个 AC 匹配的测试文件（通过系统名称和场景描述）

**输入：** `/regression-suite sprint-004`

**预期行为：**
1. 技能从 sprint-004 故事中读取所有 6 个 AC
2. 技能扫描测试文件并将每个 AC 匹配到至少一个测试断言
3. 所有 6 个 AC 都有覆盖
4. 技能生成覆盖报告："6/6 ACs covered"
5. 技能询问"是否允许写入 `production/qa/regression-sprint-004.md`？"
6. 批准后写入文件；裁决结果为 FULL COVERAGE

**断言：**
- [ ] 所有 6 个 AC 出现在覆盖报告中
- [ ] 每个 AC 标记为已覆盖，并引用匹配的测试文件
- [ ] 裁决结果为 FULL COVERAGE
- [ ] 在写入报告前询问"是否允许写入"

---

### 案例 2：发现缺口——3 个 AC 没有测试

**测试夹具：**
- 迭代有 5 个故事，共 8 个 AC
- 5 个 AC 有测试；3 个 AC 没有相应的测试文件或断言

**输入：** `/regression-suite`

**预期行为：**
1. 技能读取所有 8 个 AC
2. 技能扫描测试——5 个匹配，3 个不匹配
3. 覆盖报告按故事和 AC 文本列出 3 个未测试的 AC
4. 技能询问"是否允许写入 `production/qa/regression-[sprint]-[date].md`？"
5. 写入报告；裁决结果为 GAPS FOUND

**断言：**
- [ ] 3 个未测试的 AC 按名称在报告中列出
- [ ] 匹配的 AC 也显示（不仅仅是缺口）
- [ ] 裁决结果为 GAPS FOUND（不是 FULL COVERAGE）
- [ ] 在"是否允许写入"批准后写入报告

---

### 案例 3：关键 AC 未测试——CRITICAL GAPS 裁决，突出标记

**测试夹具：**
- 迭代有 4 个故事；一个故事是 Priority: Critical，包含 2 个 AC
- 其中一个关键优先级的 AC 没有测试

**输入：** `/regression-suite`

**预期行为：**
1. 技能读取所有故事和 AC，注意哪些故事是关键优先级
2. 技能扫描测试——关键 AC 没有匹配项
3. 报告突出标记："CRITICAL GAP: [AC text] — no test found (Critical priority story)"
4. 技能建议在添加测试前阻止故事完成
5. 裁决结果为 CRITICAL GAPS

**断言：**
- [ ] 裁决结果为 CRITICAL GAPS（不是 GAPS FOUND）
- [ ] 关键优先级的 AC 比普通缺口更突出地标记
- [ ] 包含阻止故事完成的建议
- [ ] 非关键缺口（如果有）也列出

---

### 案例 4：孤立测试——测试文件没有匹配的 AC

**测试夹具：**
- `tests/unit/save_system_test.gd` 存在，包含当前任何故事的 AC 列表中不存在的场景断言
- 当前迭代故事不涉及保存系统

**输入：** `/regression-suite`

**预期行为：**
1. 技能扫描测试并交叉引用 AC
2. `save_system_test.gd` 断言不匹配任何当前 AC
3. 测试文件在覆盖报告中标记为 ORPHAN TEST
4. 报告注明："Orphan tests may belong to a past or future sprint, or AC was renamed"
5. 裁决结果为 FULL COVERAGE 或 GAPS FOUND，取决于整体 AC 覆盖情况（孤立测试不影响裁决，仅为建议性信息）

**断言：**
- [ ] 孤立测试在报告中标记
- [ ] 孤立标记包含文件名和建议（过去迭代 / 重命名 AC）
- [ ] 孤立测试本身不会导致 GAPS FOUND 裁决
- [ ] 整体裁决仅反映 AC 覆盖情况

---

### 案例 5：导演关口检查——无关口；regression-suite 是 QA 实用工具

**测试夹具：**
- 有故事和测试文件的迭代

**输入：** `/regression-suite`

**预期行为：**
1. 技能生成覆盖报告并写入
2. 不生成导演代理
3. 输出中不出现关口 ID

**断言：**
- [ ] 不调用导演关口
- [ ] 不出现关口跳过消息
- [ ] 裁决结果为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS——无关口裁决

---

## 协议合规性

- [ ] 在扫描测试前从迭代文件读取故事 AC
- [ ] 通过系统名称和场景（不仅是文件名）将 AC 匹配到测试
- [ ] 将关键优先级的未测试 AC 标记为 CRITICAL GAPS
- [ ] 标记孤立测试（存在于 tests/ 但没有匹配的 AC）
- [ ] 在持久化覆盖报告前询问"是否允许写入"
- [ ] 裁决结果为 FULL COVERAGE、GAPS FOUND 或 CRITICAL GAPS

---

## 覆盖说明

- 将 AC 匹配到测试的启发式方法（通过系统名称 + 场景关键字）是近似的；精确匹配逻辑在技能主体中定义。
- 集成测试覆盖以与单元测试覆盖相同的方式映射；裁决中不对两者进行区分。
- 此技能不运行测试——它将 AC 文本映射到测试断言。测试执行由 CI 流水线处理。