# Skill 规范: /[skill-name]

> **类别**: [gate | review | authoring | readiness | pipeline | analysis | team | sprint | utility]
> **优先级**: [critical | high | medium | low]
> **规范编写日期**: [YYYY-MM-DD]

## Skill 总结

[一段描述此 Skill 功能、所需输入及其产生输出的内容。]

---

## 静态断言 (Static Assertions)

在进行任何行为测试前应通过这些检查：

- [ ] Frontmatter 包含所有必需字段 (`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 找到 2 个以上的阶段标题
- [ ] 至少存在一个裁决关键字 (`PASS`, `FAIL`, `CONCERNS`, `APPROVED`, `BLOCKED`, `COMPLETE`, `READY`)
- [ ] 如果 `allowed-tools` 包含 Write/Edit: 存在 `"May I write"` 询问用语
- [ ] 结尾处存在下一步移交部分

---

## Director 关卡检查 (Director Gate Checks)

[描述此 Skill 触发哪些 Director 关卡（如果有），以及在什么评审模式条件下触发。]

- **Full 模式**: [触发的关卡 — 例如 CD-PHASE-GATE, TD-PHASE-GATE, PR-PHASE-GATE, AD-PHASE-GATE]
- **Lean 模式**: [仅阶段关卡 — 例如仅 CD-PHASE-GATE，或无]
- **Solo 模式**: [无关卡 — Skill 运行不经过 Director 评审]
- **N/A**: [如果此 Skill 从不触发关卡，解释原因]

---

## 测试用例

### 用例 1：成功路径 — [简要名称]

**固定装置** (假设的项目状态):
- [文件/条件 1]
- [文件/条件 2]

**预期行为**:
1. [步骤 1]
2. [步骤 2]
3. [步骤 3]

**断言**:
- [ ] [断言 1]
- [ ] [断言 2]
- [ ] [断言 3]

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 2：失败 / 阻塞 — [简要名称]

**固定装置**:
- [缺失或无效条件]

**预期行为**:
1. [Skill 检测到问题]
2. [Skill 报告 FAIL/BLOCKED]
3. [Skill 不继续执行]

**断言**:
- [ ] Skill 提前停止且不产生输出
- [ ] 显示正确的错误/阻塞消息
- [ ] 未经用户批准不写入任何文件

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 3：模式变体 — [简要名称]

**固定装置**:
- [标准项目状态]
- [设置了特定模式或标志]

**预期行为**:
1. [行为因模式而异于成功路径]

**断言**:
- [ ] [模式相关断言]
- [ ] [输出与用例 1 正确区别]

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 4：边缘情况 — [简要名称]

**固定装置**:
- [不寻常或边界条件]

**预期行为**:
1. [Skill 优雅处理]

**断言**:
- [ ] [边缘情况处理得当，无崩溃或静默失败]
- [ ] [正确的输出或消息]

**用例裁决**: PASS / FAIL / PARTIAL

---

### 用例 5：Director 关卡 — [简要名称]

**固定装置**:
- [触发关卡检查的项目状态]
- 评审模式: [full | lean | solo]

**预期行为**:
1. [关卡触发 / 根据模式不触发]
2. [正确派生或跳过 Director Agent]

**断言**:
- [ ] Full 模式下: [具体关卡派生]
- [ ] Lean 模式下: [仅阶段关卡，或跳过]
- [ ] Solo 模式下: 无 Director 关卡派生
- [ ] Skill 不会自动越过 CONCERNS 或 FAIL 裁决

**用例裁决**: PASS / FAIL / PARTIAL

---

## 协议合规性

- [ ] 在写入文件前使用 `"May I write"` (或如果是只读 Skill 则跳过此项)
- [ ] 在请求批准前向用户展示发现/草稿
- [ ] 以推荐的下一步或后续行动结束
- [ ] 未经用户批准不自动创建文件

---

## 覆盖率说明

[任何覆盖率缺口、未测试的已知边缘情况，或需要实际 Skill 运行来验证的条件。]
