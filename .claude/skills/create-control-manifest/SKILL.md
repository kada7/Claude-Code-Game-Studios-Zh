---
name: create-control-manifest
description: "架构完成后，为程序员生成一份扁平化的可操作规则表 — 每系统每层必须做什么、绝不能做什么。从所有已接受的ADR、技术偏好和引擎参考文档中提取。比ADR（解释原因）更直接可操作。"
argument-hint: "[update — regenerate from current ADRs]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Task
agent: technical-director
---

# 创建控制清单

控制清单是面向程序员的扁平化可操作规则表。它回答"我该怎么做？"和"我绝对不能做什么？" — 按架构层级组织，从所有已接受的ADR、技术偏好和引擎参考文档中提取。ADR解释*为什么*，清单告诉你*做什么*。

**输出：** `docs/architecture/control-manifest.md`

**运行时机：** `/architecture-review` 通过且ADR处于已接受状态之后。每当新ADR被接受或现有ADR被修改时重新运行。

---

## 1. 加载所有输入

### ADR
- 使用 Glob 匹配 `docs/architecture/adr-*.md` 并读取所有文件
- 只过滤已接受的ADR（Status: Accepted）— 跳过 Proposed、Deprecated、Superseded 状态
- 记录每条规则来源的ADR编号和标题

### 技术偏好
- 读取 `.claude/docs/technical-preferences.md`
- 提取：命名约定、性能预算、已批准的库/插件、禁止的模式

### 引擎参考
- 读取 `docs/engine-reference/[engine]/VERSION.md` 获取引擎和版本信息
- 读取 `docs/engine-reference/[engine]/deprecated-apis.md` — 这些将成为禁止API条目
- 如果存在，读取 `docs/engine-reference/[engine]/current-best-practices.md`

报告："已加载 [N] 个已接受ADR，引擎：[名称 + 版本]。"

---

## 2. 从每个ADR中提取规则

对于每个已接受的ADR，提取：

### 必须遵循的模式（来自"实现指南"部分）
- 所有包含"必须"、"应该"、"需要"、"始终"的表述
- 所有规定的具体模式或方法

### 禁止的方式（来自"已考虑的替代方案"部分）
- 所有被明确拒绝的替代方案 — *被拒绝的原因*变成规则（"永远不要用X，因为Y"）
- 所有被明确指出的反模式

### 性能护栏（来自"性能影响"部分）
- 预算约束："此系统每帧最多 N ms"
- 内存限制："此系统不得超过 N MB"

### 引擎API限制（来自"引擎兼容性"部分）
- 需要验证的截止日期后API
- 与默认LLM假设不同的已验证行为
- 在固定引擎版本中行为有所不同的API字段或方法

### 层级分类
按规则所管理系统的架构层级进行分类：
- **Foundation（基础层）**：场景管理、事件架构、存档/读档、引擎初始化
- **Core（核心层）**：核心游戏循环、主要玩家系统、物理/碰撞
- **Feature（功能层）**：次要系统、次要机制、AI
- **Presentation（表现层）**：渲染、音频、UI、VFX、着色器

如果一个ADR跨越多个层级，将规则复制到每个相关层级。

---

## 3. 添加全局规则

合并适用于所有层级的规则：

### 来自 technical-preferences.md：
- 命名约定（类、变量、信号/事件、文件、常量）
- 性能预算（目标帧率、帧预算、绘制调用限制、内存上限）

### 来自 deprecated-apis.md：
- 所有已弃用API → 禁止API条目

### 来自 current-best-practices.md（如果存在）：
- 引擎推荐模式 → 必须遵循条目

### 来自 technical-preferences.md 中的禁止模式：
- 直接复制任何"禁止模式"条目

---

## 4. 写入前展示规则摘要

写入清单之前，向用户展示摘要：

```
## 控制清单预览
引擎：[名称 + 版本]
涵盖的ADR：[ADR编号列表]
已提取的规则总数：
  - Foundation层：[N] 必须, [M] 禁止, [P] 护栏
  - Core层：[N] 必须, [M] 禁止, [P] 护栏
  - Feature层：...
  - Presentation层：...
  - 全局：[N] 命名约定, [M] 禁止API, [P] 已批准库
```

询问："内容是否完整？在我写入清单之前，需要添加或删除任何规则吗？"

---

## 4b. 总监阶段门 — 技术审查

**审查模式检查** — 在生成 TD-MANIFEST 之前执行：
- `solo` → 跳过。记录："TD-MANIFEST 已跳过 — Solo 模式。"继续进行第5阶段。
- `lean` → 跳过。记录："TD-MANIFEST 已跳过 — Lean 模式。"继续进行第5阶段。
- `full` → 正常生成。

通过 Task 生成 `technical-director`，使用阶段门 **TD-MANIFEST**（`.claude/docs/director-gates.md`）。

传递：第4阶段的控制清单预览（每层规则计数、完整提取的规则列表）、涵盖的ADR列表、引擎版本，以及来自 technical-preferences.md 或引擎参考文档的规则。

technical-director 审查以下内容：
- 所有强制ADR模式是否被捕获并准确表述
- 禁止方式是否完整且正确归因
- 是否没有添加缺乏来源ADR或偏好文档的规则
- 性能护栏是否与ADR约束一致

应用裁决：
- **APPROVE** → 进行第5阶段
- **CONCERNS** → 通过 `AskUserQuestion` 提交，选项：`修改标记的规则` / `接受并继续` / `进一步讨论`
- **REJECT** → 不写入清单；修复标记的规则并重新展示摘要

---

## 5. 写入控制清单

询问："我可以将其写入 `docs/architecture/control-manifest.md` 吗？"

格式：

```markdown
# 控制清单

> **引擎**：[名称 + 版本]
> **最后更新**：[日期]
> **清单版本**：[日期]
> **涵盖的ADR**：[ADR-NNNN, ADR-MMMM, ...]
> **状态**：[Active — 当ADR变更时使用 `/create-control-manifest update` 重新生成]

`清单版本` 是此清单生成的日期。Story文件创建时会嵌入此日期。`/story-readiness` 通过将story的嵌入版本与此字段对比，来检测基于过期规则编写的story。始终与 `最后更新` 相同 — 它们是同一日期，服务于不同的使用者。

此清单是从所有已接受的ADR、技术偏好和引擎参考文档中提取的程序员快速参考。关于每条规则背后的原因，请参见引用的ADR。

---

## Foundation层规则

*适用于：场景管理、事件架构、存档/读档、引擎初始化*

### 必须遵循的模式
- **[规则]** — 来源：[ADR-NNNN]
- **[规则]** — 来源：[ADR-NNNN]

### 禁止的方式
- **绝不 [反模式]** — [简要原因] — 来源：[ADR-NNNN]

### 性能护栏
- **[系统]**：每帧最多 [N]ms — 来源：[ADR-NNNN]

---

## Core层规则

*适用于：核心游戏循环、主要玩家系统、物理、碰撞*

### 必须遵循的模式
...

### 禁止的方式
...

### 性能护栏
...

---

## Feature层规则

*适用于：次要机制、AI系统、次要功能*

### 必须遵循的模式
...

### 禁止的方式
...

---

## Presentation层规则

*适用于：渲染、音频、UI、VFX、着色器、动画*

### 必须遵循的模式
...

### 禁止的方式
...

---

## 全局规则（所有层级）

### 命名约定
| 元素 | 约定 | 示例 |
|---------|-----------|---------|
| 类 | [来自 technical-preferences] | [示例] |
| 变量 | [来自 technical-preferences] | [示例] |
| 信号/事件 | [来自 technical-preferences] | [示例] |
| 文件 | [来自 technical-preferences] | [示例] |
| 常量 | [来自 technical-preferences] | [示例] |

### 性能预算
| 目标 | 值 |
|--------|-------|
| 帧率 | [来自 technical-preferences] |
| 帧预算 | [来自 technical-preferences] |
| 绘制调用 | [来自 technical-preferences] |
| 内存上限 | [来自 technical-preferences] |

### 已批准的库/插件
- [库] — 批准用于 [用途]

### 禁止的API（[引擎版本]）
以下API在 [引擎 + 版本] 中已弃用或未经验证：
- `[api名称]` — 自 [版本] 起弃用 / 截止日期后未经验证
- 来源：`docs/engine-reference/[engine]/deprecated-apis.md`

### 横切约束
- [无论哪个层级都适用的约束]
```

---

## 6. 建议后续步骤

写入清单后：

- 如果史诗/story尚不存在："运行 `/create-epics layer: foundation`，然后 `/create-stories [epic-slug]` — 程序员现在可以在编写story实现说明时使用此清单。"
- 如果这是重新生成（清单已存在）："已更新。建议通知团队规则变更 — 特别是任何新的禁止条目。"

---

## 协作协议

1. **静默加载** — 在展示任何内容之前读取所有输入
2. **先展示摘要** — 让用户在写入之前了解范围
3. **写入前询问** — 在创建或覆盖清单之前始终确认。写入时：裁决：**COMPLETE** — 控制清单已写入。拒绝时：裁决：**BLOCKED** — 用户拒绝写入。
4. **为每条规则注明来源** — 不添加任何无法追溯到ADR、技术偏好或引擎参考文档的规则
5. **不进行解读** — 按ADR中的表述提取规则；不以改变含义的方式转述
