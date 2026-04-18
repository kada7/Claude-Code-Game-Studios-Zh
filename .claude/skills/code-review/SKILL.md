---
name: code-review
description: "对指定文件或文件集执行架构和质量代码审查。检查编码标准合规性、架构模式遵循、SOLID原则、可测试性和性能问题。"
argument-hint: "[path-to-file-or-directory]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Task
agent: lead-programmer
---

## 阶段 1: 加载目标文件

完整读取目标文件。读取 CLAUDE.md 获取项目编码标准。

---

## 阶段 2: 识别引擎专家

读取 `.claude/docs/technical-preferences.md`，`## Engine Specialists` 部分。记录:

- **Primary** 专家 (用于架构和广泛的引擎问题)
- **Language/Code Specialist** (审查项目主要语言文件时使用)
- **Shader Specialist** (审查着色器文件时使用)
- **UI Specialist** (审查 UI 代码时使用)

如果该部分显示 `[TO BE CONFIGURED]`，则没有固定引擎 — 跳过引擎专家步骤。

---

## 阶段 3: ADR 合规性检查

在 story 文件、提交消息和头部注释中搜索 ADR 引用。查找 `ADR-NNN` 或 `docs/architecture/ADR-` 等模式。

如果未找到 ADR 引用，注意: "未找到 ADR 引用 — 跳过 ADR 合规性检查。"

对于每个引用的 ADR: 读取文件，提取 **Decision** 和 **Consequences** 部分，然后对任何偏差进行分类:

- **ARCHITECTURAL VIOLATION** (阻塞): 使用 ADR 明确拒绝的模式
- **ADR DRIFT** (警告): 与所选方法有显著差异但未使用禁止模式
- **MINOR DEVIATION** (信息): 与 ADR 指导的小差异，不影响整体架构

---

## 阶段 4: 标准合规性

识别系统类别 (engine, gameplay, AI, networking, UI, tools) 并评估:

- [ ] 公共方法和类有文档注释
- [ ] 每个方法的圈复杂度低于 10
- [ ] 没有方法超过 40 行 (不包括数据声明)
- [ ] 依赖被注入 (游戏状态不使用静态单例)
- [ ] 配置值从数据文件加载
- [ ] 系统暴露接口 (而非具体类依赖)

---

## 阶段 5: 架构和 SOLID

**架构:**
- [ ] 正确的依赖方向 (engine <- gameplay, 而非反向)
- [ ] 模块之间没有循环依赖
- [ ] 正确的分层分离 (UI 不拥有游戏状态)
- [ ] 事件/信号用于跨系统通信
- [ ] 与代码库中已建立的模式一致

**SOLID:**
- [ ] Single Responsibility: 每个类只有一个改变的理由
- [ ] Open/Closed: 无需修改即可扩展
- [ ] Liskov Substitution: 子类型可替代基类型
- [ ] Interface Segregation: 没有胖接口
- [ ] Dependency Inversion: 依赖抽象而非具体

---

## 阶段 6: 游戏特定关注点

- [ ] 帧率独立性 (delta time 使用)
- [ ] 热路径中没有分配 (update 循环)
- [ ] 正确的 null/空状态处理
- [ ] 需要时的线程安全
- [ ] 资源清理 (无泄漏)

---

## 阶段 7: 专家审查 (并行)

通过 Task 同时生成所有适用的专家 — 不要等待一个完成再开始下一个。

### 引擎专家

如果配置了引擎，确定哪个专家适用于每个文件并并行生成:

- Primary language files (`.gd`, `.cs`, `.cpp`) → Language/Code Specialist
- Shader files (`.gdshader`, `.hlsl`, shader graph) → Shader Specialist
- UI screen/widget code → UI Specialist
- Cross-cutting 或 unclear → Primary Specialist

对于任何触及引擎架构的文件 (场景结构、节点层次结构、生命周期 hooks)，同时生成 **Primary Specialist**。

### QA 可测试性审查

对于 Logic 和 Integration stories，同时通过 Task 生成 `qa-tester` 与引擎专家并行。传递:
- 正在审查的实现文件
- Story 的 `## QA Test Cases` 部分 (来自 qa-lead 的预写测试规范)
- Story 的 `## Acceptance Criteria`

要求 qa-tester 评估:
- [ ] 所有测试钩子和接口是否暴露 (不隐藏在 private/internal 访问后)?
- [ ] Story 的 `## QA Test Cases` 部分中的 QA 测试用例是否映射到可测试的代码路径?
- [ ] 是否有任何验收标准按实现方式无法测试 (例如，硬编码值，没有注入的 seam)?
- [ ] 实现是否引入了现有 QA 测试用例未涵盖的新边界情况?
- [ ] 是否有任何可观察的副作用应该有测试但没有?

对于 Visual/Feel 和 UI stories: qa-tester 审查 `## QA Test Cases` 中的手动验证步骤对于书面实现是否可实现 — 例如，"手动检查者需要到达的状态实际上是否可达?"

在生成输出前收集所有专家发现。

---

## 阶段 8: 输出审查

```
## 代码审查: [File/System Name]

### 引擎专家发现: [N/A — 未配置引擎 / CLEAN / ISSUES FOUND]
[引擎专家的发现，如果跳过则为 "No engine configured."]

### 可测试性: [N/A — Visual/Feel 或 Config story / TESTABLE / GAPS / BLOCKING]
[qa-tester 发现: 测试钩子、覆盖差距、无法测试的路径、新边界情况]
[如果 BLOCKING: 实现必须暴露 [X] 才能运行 ## QA Test Cases 中的测试]

### ADR 合规性: [NO ADRS FOUND / COMPLIANT / DRIFT / VIOLATION]
[列出每个检查的 ADR、结果和任何偏差及严重度]

### 标准合规性: [X/6 passing]
[列出失败的行引用]

### 架构: [CLEAN / MINOR ISSUES / VIOLATIONS FOUND]
[列出具体架构关注点]

### SOLID: [COMPLIANT / ISSUES FOUND]
[列出具体违规]

### 游戏特定关注点
[列出游戏开发特定问题]

### 积极观察
[做得好的地方 — 始终包含此部分]

### 必需更改
[批准前必须修复的项目 — ARCHITECTURAL VIOLATIONs 始终出现在这里]

### 建议
[不错的改进]

### 裁决: [APPROVED / APPROVED WITH SUGGESTIONS / CHANGES REQUIRED]
```

此 skill 为只读 — 不写入文件。

---

## 阶段 9: 后续步骤

- 如果裁决为 APPROVED: 运行 `/story-done [story-path]` 关闭 story。
- 如果裁决为 CHANGES REQUIRED: 修复问题并重新运行 `/code-review`。
- 如果发现 ARCHITECTURAL VIOLATION: 运行 `/architecture-decision` 记录正确的方法。
