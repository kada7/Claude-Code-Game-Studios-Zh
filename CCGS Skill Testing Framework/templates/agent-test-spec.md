# Agent 规范: [agent-name]

> **层级**: [directors | leads | specialists | godot | unity | unreal | operations | creative]
> **类别**: [director | lead | specialist | engine | operations | creative]
> **规范编写日期**: [YYYY-MM-DD]

## Agent 总结

[一段描述此 Agent 的领域、它拥有什么决策权、它委托什么以及直接处理什么的内容。包括它触发的关卡 (如果有)。]

**领域**: [此 Agent 拥有的文件/目录]
**升级至**: [父 Agent — 例如，设计冲突升级至 creative-director]
**委托给**: [此 Agent 通常派生的子 Agent]

---

## 静态断言 (Static Assertions)

- [ ] Agent 文件存在于 `.claude/agents/[name].md`
- [ ] Frontmatter 具有 `name`, `description`, `model`, `tools` 字段
- [ ] 明确声明了领域
- [ ] 记录了升级路径
- [ ] 不在其领域外做决策

---

## 测试用例

### 用例 1：域内请求 — [简要名称]

**场景**: 明确在 Agent 领域内的请求。

**固定装置**:
- [相关项目状态]
- [提供给 Agent 的输入]

**预期行为**:
1. Agent 接受请求
2. Agent 产生 [特定输出类型]
3. Agent 在写入文件前询问 (如果适用)

**断言**:
- [ ] Agent 在其领域内处理请求，无需升级
- [ ] 输出格式匹配预期结构
- [ ] 遵循协作协议 (询问 → 草稿 → 批准)

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 2：域外重定向 — [简要名称]

**场景**: 超出 Agent 领域的请求。

**固定装置**:
- [属于不同 Agent 的请求]

**预期行为**:
1. Agent 识别请求在领域外
2. Agent 重定向到正确的 Agent
3. Agent 不尝试处理该请求

**断言**:
- [ ] Agent 拒绝并重定向 (不会静默处理跨域工作)
- [ ] 重定向中提到了正确的 Agent

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 3：关卡裁决 — [简要名称]

**场景**: Agent 作为 Director 关卡检查的一部分被调用。

**固定装置**:
- [呈现评审的项目状态]
- [关卡 ID: 例如 CD-PHASE-GATE]

**预期行为**:
1. Agent 读取相关文档
2. Agent 产生 PASS / CONCERNS / FAIL 裁决
3. Agent 不会在 CONCERNS 或 FAIL 时自动前进

**断言**:
- [ ] 输出中存在裁决关键字 (PASS, CONCERNS, FAIL)
- [ ] 为裁决提供了理由
- [ ] 在 CONCERNS/FAIL 时：工作被阻塞，没有静默继续

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 4：冲突升级 — [简要名称]

**场景**: 此 Agent 的领域与另一个 Agent 的决策冲突。

**固定装置**:
- [来自同一层级两个 Agent 的冲突决策]

**预期行为**:
1. Agent 识别冲突
2. Agent 升级至共同父级 (或 creative-director / technical-director)
3. Agent 不单方面解决跨域冲突

**断言**:
- [ ] 明确表面化冲突
- [ ] 遵循正确的升级路径
- [ ] 未做出单方面的跨域变更

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 5：上下文透传 — [简要名称]

**场景**: Agent 接收到带有来自父 Agent 完整上下文的任务。

**固定装置**:
- [来自父 Agent 的上下文块]
- [要执行的特定子任务]

**预期行为**:
1. Agent 读取并使用提供的上下文
2. Agent 完成子任务
3. Agent 将结果返回给父级 (不产生不必要的提示用户)

**断言**:
- [ ] Agent 使用提供的上下文而不是重新询问
- [ ] 结果限定在子任务范围内，未超出范围
- [ ] 输出格式适合父 Agent 使用

**用例裁决**: PASS / FAIL / PARTIAL

---

## 协议合规性

- [ ] 保持在声明的领域内 —— 不做单方面的跨域变更
- [ ] 将冲突升级到正确的父级
- [ ] 在写入文件前使用 `"May I write"` (或如果是只读)
- [ ] 在请求批准前展示发现结果
- [ ] 不会在委托层级中跳级

---

## 覆盖率说明

[任何覆盖率缺口、未测试的已知边缘情况，或需要实际 Agent 派生才能验证的行为。]
