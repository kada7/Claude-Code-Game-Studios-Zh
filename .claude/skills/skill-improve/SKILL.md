---
name: skill-improve
description: "使用测试-修复-重测循环改进 Skill。运行静态检查，提出针对性修复，重写 Skill，重新测试，并根据分数变化保留或回滚。"
argument-hint: "[skill-name]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
---

# Skill 改进

对单个 Skill 运行改进循环：
测试 → 修复 → 重测 → 保留或回滚。

---

## 阶段 1: 解析参数

从第一个参数读取 Skill 名称。如果缺失，输出用法并停止：

```
Usage: /skill-improve [skill-name]
Example: /skill-improve tech-debt
```

验证 `.claude/skills/[name]/SKILL.md` 是否存在。如果不存在，停止并显示：
"Skill '[name]' not found。"

---

## 阶段 2: 基线测试

运行 `/skill-test static [name]` 并记录基线分数：
- FAIL 计数
- WARN 计数
- 哪些具体检查失败（检查 1-7）

向用户显示：
```
Static baseline:   [N] failures, [M] warnings
Failing: Check 4 (no ask-before-write), Check 5 (no handoff)
```

如果基线是 0 FAIL 和 0 WARN，注明并继续到阶段 2b。

### 阶段 2b: 类别基线

在 `CCGS Skill Testing Framework/catalog.yaml` 中查找 Skill 的 `category:` 字段。

如果未找到 `category:` 字段，显示：
"Category: not yet assigned — skipping category checks。"
并跳到阶段 3。

如果找到类别，运行 `/skill-test category [name]` 并记录类别基线：
- FAIL 计数
- WARN 计数
- 哪些具体类别标准指标失败

向用户显示：
```
Category baseline: [N] failures, [M] warnings  ([category] rubric)
```

如果静态和类别基线都是 0 FAIL 和 0 WARN，停止：
"This skill already passes all static and category checks。No improvements needed。"

---

## 阶段 3: 诊断

完整读取 `.claude/skills/[name]/SKILL.md` 处的 Skill 文件。

对于每个失败或警告的**静态**检查，确定确切差距：

- **检查 1 失败** → 哪个 frontmatter 字段缺失
- **检查 2 失败** → 找到的阶段数 vs. 最低要求
- **检查 3 失败** → Skill 正文中没有裁决关键词
- **检查 4 失败** → allowed-tools 中有 Write 或 Edit 但没有写入前询问语言
- **检查 5 警告** → 结尾没有后续或下一步章节
- **检查 6 警告** → 设置了 `context: fork` 但找到的阶段少于 5 个
- **检查 7 警告** → argument-hint 为空或与记录的模式不匹配

对于每个失败或警告的**类别**检查（如果在阶段 2b 中分配了类别），
确定 Skill 文本中的确切差距。例如：
- 如果 G2 失败（gate 模式，完整 directors 未生成）：Skill 正文从未引用所有 4 个
  PHASE-GATE director 提示
- 如果 A2 失败（编写，没有每个章节的 May-I-write）：Skill 在结尾询问一次，不是
  在每个章节写入之前
- 如果 T3 失败（团队，BLOCKED 未展示）：Skill 在 agent 被阻塞时不停止依赖工作

在向用户提出任何更改之前展示完整的综合诊断。

---

## 阶段 4: 提出修复

为每个失败和警告编写针对性修复。将提议的更改
显示为清晰标记的前后块。仅更改失败的内容 —— 不要
重写通过的部分。

询问："我可以将此改进版本写入 `.claude/skills/[name]/SKILL.md` 吗？"

如果用户说不，在这里停止。

---

## 阶段 5: 写入和重测

记录 Skill 文件的当前内容（以便在需要时回滚）。

将改进的 Skill 写入 `.claude/skills/[name]/SKILL.md`。

重新运行 `/skill-test static [name]` 并记录新的静态分数。
如果分配了类别，也重新运行 `/skill-test category [name]` 并记录新的类别分数。

显示比较：
```
Static:   Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings
Category: Before [N] failures, [M] warnings  →  After [N'] failures, [M'] warnings  (if applicable)
Combined change: improved / no change / worse
```

---

## 阶段 6: 裁决

计算组合失败总数：静态 FAIL + 类别 FAIL + 静态 WARN + 类别 WARN。

**如果组合分数改善（组合失败计数低于基线）：**
报告："Score improved。Changes kept。"
显示在每个维度中修复的内容摘要。

**如果组合分数相同或更差：**
报告："Combined score did not improve。"
显示更改的内容及可能无帮助的原因。
询问："我可以使用 git checkout 回滚 `.claude/skills/[name]/SKILL.md` 吗？"
如果同意：运行 `git checkout -- .claude/skills/[name]/SKILL.md`

---

## 阶段 7: 后续步骤

- 运行 `/skill-test static all` 查找下一个有失败的 Skill。
- 运行 `/skill-improve [next-name]` 在另一个 Skill 上继续循环。
- 运行 `/skill-test audit` 查看整体覆盖进度。
