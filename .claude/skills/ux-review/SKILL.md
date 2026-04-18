---
name: ux-review
description: "验证 UX 规范、HUD 设计或交互模式库的完整性、无障碍合规性、GDD 对齐和实现准备情况。生成 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 裁决及具体差距。"
argument-hint: "[file-path or 'all' or 'hud' or 'patterns']"
user-invocable: true
allowed-tools: Read, Glob, Grep
agent: ux-designer
---

## Overview

在进入实现管道之前验证 UX 设计文档。作为 `/team-ui` 管道中 UX Design 与 Visual Design/Implementation 之间的质量门。

**运行此 skill：**

- 使用 `/ux-design` 完成 UX 规范后
- 移交给 `ui-programmer` 或 `art-director` 之前
- Pre-Production 到 Production 门检查之前（需要有关键屏幕的已审查 UX 规范）
- UX 规范重大修订后

**裁决等级：**

- **APPROVED** — 规范完整、一致且可实施
- **NEEDS REVISION** — 发现具体差距；移交前修复但不需要完全重新设计
- **MAJOR REVISION NEEDED** — 范围、玩家需求或完整性方面存在根本问题；需要大量返工

---

## Phase 1: 解析参数

- **特定文件路径**（例如 `/ux-review design/ux/inventory.md`）：验证该文档
- **`all`**：查找 `design/ux/` 中的所有文件并验证每个
- **`hud`**：专门验证 `design/ux/hud.md`
- **`patterns`**：专门验证 `design/ux/interaction-patterns.md`
- **无参数**：询问用户要验证哪个规范

对于 `all`，先输出摘要表格（文件 | 裁决 | 主要问题），然后是每个的详细信息。

---

## Phase 2: 加载交叉引用上下文

在验证任何规范之前，加载：

1. **输入和平台配置**：读取 `.claude/docs/technical-preferences.md` 并提取 `## Input & Platform`。这是游戏支持哪些输入方法的权威来源 — 使用它来驱动阶段 3A 中的 Input Method Coverage 检查，而不是规范自己的 header。如果未配置，回退到规范 header。
2. `design/accessibility-requirements.md` 中承诺的无障碍层级（如果存在）
3. `design/ux/interaction-patterns.md` 中的交互模式库（如果存在）
4. 规范 header 中引用的 GDDs（读取它们的 UI Requirements 部分）
5. `design/player-journey.md` 中的玩家旅程图（如果存在）用于上下文到达验证

---

## Phase 3A: UX 规范验证检查清单

针对基于 `ux-spec.md` 的文档运行所有检查。

### 完整性（必需部分）

- [ ] Document header 存在 Status、Author、Platform Target
- [ ] Purpose & Player Need — 有玩家视角的需求陈述（不是开发者视角）
- [ ] Player Context on Arrival — 描述玩家状态和先前活动
- [ ] Navigation Position — 显示屏幕在层次结构中的位置
- [ ] Entry & Exit Points — 所有入口来源和出口目的地已记录
- [ ] Layout Specification — 区域已定义，组件清单表格存在
- [ ] States & Variants — 至少：loading、empty/populated 和 error states 已记录
- [ ] Interaction Map — 覆盖所有目标输入方法（检查 header 中的平台目标）
- [ ] Data Requirements — 每个显示的数据元素都有源系统和所有者
- [ ] Events Fired — 每个玩家操作都有相应的事件或 null 解释
- [ ] Transitions & Animations — 至少 enter/exit 过渡已指定
- [ ] Accessibility Requirements — 屏幕级需求存在
- [ ] Localization Considerations — 文本元素的最大字符数
- [ ] Acceptance Criteria — 至少 5 个具体的可测试标准

### 质量检查

**Player Need Clarity**

- [ ] Purpose 从玩家视角编写，不是系统/开发者视角
- [ ] 到达时的玩家目标明确（"玩家到达时想要___"）
- [ ] 到达时的玩家上下文是具体的（不只是"他们打开了库存"）

**States 的完整性**

- [ ] Error state 已记录（不只是 happy path）
- [ ] Empty state 已记录（无数据场景）
- [ ] 如果屏幕获取异步数据，Loading state 已记录
- [ ] 任何有计时器或自动关闭的 state 已记录持续时间

**Input Method Coverage**

- [ ] 如果平台包含 PC：keyboard-only 导航已完全指定
- [ ] 如果平台包含 console/gamepad：d-pad 导航和 face button mapping 已记录
- [ ] 没有交互需要 gamepad 上的鼠标精度
- [ ] Focus order 已定义（keyboard 的 Tab order，gamepad 的 d-pad order）

**Data Architecture**

- [ ] 没有数据元素将 "UI" 列为所有者（UI 不得拥有游戏状态）
- [ ] 所有实时数据的更新频率已指定（不只是"realtime" — 什么触发更新？）
- [ ] 所有数据元素的 null 处理已指定（数据不可用时显示什么？）

**Accessibility**

- [ ] 与 `accessibility-requirements.md` 中的无障碍层级匹配或超过
- [ ] 如果是 Basic 层级：没有仅颜色信息指示器
- [ ] 如果是 Standard 层级+：focus order 已记录，文本对比度比例已指定
- [ ] 如果是 Comprehensive 层级+：关键状态变化的 screen reader 公告
- [ ] 色盲检查：任何颜色编码元素都有非颜色替代方案

**GDD Alignment**

- [ ] header 中引用的每个 GDD UI Requirement 在此规范中都有涉及
- [ ] 没有 UI 元素在没有相应 GDD requirement 的情况下显示或修改游戏状态
- [ ] 没有 GDD UI Requirement 缺失于此规范（交叉检查引用的 GDD 部分）

**Pattern Library Consistency**

- [ ] 所有交互组件引用 pattern library（或注明它们是新模式）
- [ ] 如果 pattern 已存在于 pattern library 中，则不会从头开始重新指定 pattern 行为
- [ ] 此规范中发明的任何新模式都标记为需要添加到 pattern library

**Localization**

- [ ] 所有文本繁重元素都有字符限制警告
- [ ] 任何布局关键文本都已标记为需要 40% 扩展容纳

**Acceptance Criteria Quality**

- [ ] Criteria 足够具体，适用于未看过设计文档的 QA tester
- [ ] Performance criterion 存在（屏幕在 Xms 内打开）
- [ ] Resolution criterion 存在
- [ ] 没有 criterion 需要阅读另一个文档来评估

---

## Phase 3B: HUD 验证检查清单

针对基于 `hud-design.md` 的文档运行所有检查。

### 完整性

- [ ] HUD Philosophy 已定义
- [ ] Information Architecture 表格涵盖 GDDs 中所有有 UI Requirements 的系统
- [ ] Layout Zones 已定义，所有目标平台都有 safe zone margins
- [ ] 每个 HUD 元素都有完整规范（区域、可见性触发器、数据源、优先级）
- [ ] HUD States by Gameplay Context 至少涵盖：exploration、combat、dialogue/cutscene、paused
- [ ] Visual Budget 已定义（最大同时元素数、最大屏幕 %）
- [ ] Platform Adaptation 涵盖所有目标平台
- [ ] Tuning Knobs 存在于玩家可调整元素

### 质量检查

- [ ] 没有 HUD 元素在没有隐藏它的可见性规则的情况下覆盖中心游戏区域
- [ ] 任何 GDD 中存在的每个信息项都在 HUD 中或明确归类为 "hidden/demand"
- [ ] 所有颜色编码的 HUD 元素都有色盲变体
- [ ] Feedback & Notification 部分中的 HUD 元素已定义 queue/priority 行为
- [ ] Visual Budget 合规性：总同时元素数在预算内

### GDD Alignment

- [ ] `design/gdd/systems-index.md` 中有 UI category 的所有系统都在 HUD 中有表示（或有合理的缺席理由）

---

## Phase 3C: Pattern Library 验证检查清单

- [ ] Pattern catalog index 是最新的（与文档中的实际模式匹配）
- [ ] 所有标准控件模式都已指定：button variants、toggle、slider、dropdown、list、grid、modal、dialog、toast、tooltip、progress bar、input field、tab bar、scroll
- [ ] 当前 UX 规范所需的所有 game-specific patterns 都存在
- [ ] 每个模式都有：When to Use、When NOT to Use、完整 state specification、accessibility spec、implementation notes
- [ ] Animation Standards 表格存在
- [ ] Sound Standards 表格存在
- [ ] 模式之间没有冲突行为（例如，所有导航模式中 "Back" 行为一致）

---

## Phase 4: 输出裁决

```markdown
## UX Review: [Document Name]
**Date**: [date]
**Reviewer**: ux-review skill
**Document**: [file path]
**Platform Target**: [from header]
**Accessibility Tier**: [from header or accessibility-requirements.md]

### Completeness: [X/Y sections present]
- [x] Purpose & Player Need
- [ ] States & Variants — MISSING: error state not documented

### Quality Issues: [N found]
1. **[Issue title]** [BLOCKING / ADVISORY]
   - What's wrong: [specific description]
   - Where: [section name]
   - Fix: [specific action to take]

### GDD Alignment: [ALIGNED / GAPS FOUND]
- GDD [name] UI Requirements — [X/Y requirements covered]
- Missing: [list any uncovered GDD requirements]

### Accessibility: [COMPLIANT / GAPS / NON-COMPLIANT]
- Target tier: [tier]
- [list specific accessibility findings]

### Pattern Library: [CONSISTENT / INCONSISTENCIES FOUND]
- [findings]

### Verdict: APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
**Blocking issues**: [N] — must be resolved before implementation
**Advisory issues**: [N] — recommended but not blocking

[For APPROVED]: This spec is ready for handoff to `/team-ui` Phase 2
(Visual Design).

[For NEEDS REVISION]: Address the [N] blocking issues above, then re-run
`/ux-review`.

[For MAJOR REVISION NEEDED]: The spec has fundamental gaps in [areas].
Recommend returning to `/ux-design` to rework [sections].
```

---

## Phase 5: Collaborative Protocol

此 skill 为 READ-ONLY — 它从不编辑或写入文件。它只报告发现。

交付裁决后：

- 对于 **APPROVED**：建议运行 `/team-ui` 开始实现协调
- 对于 **NEEDS REVISION**：提供帮助修复具体差距（"您想让我帮助起草缺失的 error state 吗？"）— 但不要自动修复；等待用户指示
- 对于 **MAJOR REVISION NEEDED**：建议返回 `/ux-design` 并指定要返工的章节

永远不要阻止用户继续 — 裁决是建议性的。记录风险，展示发现，让用户决定是否尽管有担忧也要继续。选择继续使用 NEEDS REVISION 规范的用户承担了记录的风险。
