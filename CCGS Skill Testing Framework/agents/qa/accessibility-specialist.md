# Agent 测试规范: accessibility-specialist

## Agent 摘要
领域: 输入重映射、文本缩放、色盲模式、屏幕阅读器支持以及无障碍标准合规性 (WCAG, 平台认证)。
不负责: 整体用户体验流程设计 (ux-designer)、视觉艺术风格指导 (art-director)。
模型层级: Sonnet (默认)。
未分配门禁 ID。

---

## 静态断言 (结构)

- [ ] `description:` 字段存在且具有领域特定性 (引用无障碍/包容性设计/WCAG)
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级为 Sonnet (专家默认)
- [ ] Agent 定义不声称对用户体验流程或视觉艺术风格拥有权限

---

## 测试用例

### 用例 1: 领域内请求 — 适当的输出
**输入:** "Review the player HUD for accessibility."
**预期行为:**
- 审核 HUD 规范或截图以检查:
  - 对比度比率 (标记任何低于 4.5:1 用于 AA 或 7:1 用于 AAA 的文本)
  - 颜色编码信息的替代表示 (例如，敌人血条仅使用颜色，没有形状区分)
  - 文本大小 (标记任何在 1080p 分辨率下低于 16px 等效值的文本)
  - 关键状态元素的屏幕阅读器或 TTS 注释可用性
- 生成一个按优先级排序的发现列表，包含特定元素名称及其不符合的标准
- 不重新设计 HUD — 生成供 ux-designer 和 ui-programmer 处理的发现

### 用例 2: 领域外请求 — 正确重定向
**输入:** "Design the overall game flow: main menu → character select → loading → gameplay → pause → results."
**预期行为:**
- 不生成用户体验流程架构
- 明确说明整体游戏流程设计属于 `ux-designer`
- 将请求重定向至 `ux-designer`
- 可以注明一旦流程设计完成，它可以审核流程的无障碍问题 (例如，时间限制、认知负荷)

### 用例 3: 色盲模式冲突
**输入:** "The proposed colorblind mode for deuteranopia replaces the enemy red health bars with orange, but the art palette already uses orange for friendly units."
**预期行为:**
- 识别冲突: 色盲模式与已建立的友方单位调色板之间的橙色冲突
- 不单方面更改艺术调色板 (这属于 art-director)
- 向 `art-director` 标记冲突，并描述具体的视觉重叠
- 提出不需要调色板更改的替代区分策略 (例如，形状/图标叠加、图案填充、图标设计)

### 用例 4: 无障碍功能的 UI 状态要求
**输入:** "Screen reader support for the inventory requires the system to expose item names and quantities as accessible text nodes."
**预期行为:**
- 生成无障碍需求规范，定义每个库存元素所需的无障碍文本属性
- 识别实现无障碍文本节点需要 UI 系统更改
- 与 `ui-programmer` 协调以实现所需的无障碍文本节点暴露
- 不自行实现 UI 系统更改

### 用例 5: 上下文传递 — WCAG 2.1 目标
**输入:** 在上下文中提供项目无障碍目标: WCAG 2.1 AA 合规性。请求: "Review the dialogue system for accessibility."
**预期行为:**
- 引用与对话相关的特定 WCAG 2.1 AA 成功标准 (例如，1.4.3 对比度最小值、1.4.4 文本大小调整、2.2.1 可调节时间用于自动推进对话)
- 使用标准中的确切标准编号和名称，而非释义
- 用其不符合的具体标准标记每个发现
- 注明哪些标准超出 AA 范围 (仅限 AAA)，以免被错误标记为失败

---

## 协议合规性

- [ ] 保持在声明的领域内 (重映射、文本缩放、色盲模式、屏幕阅读器、标准合规性)
- [ ] 将用户体验流程设计重定向至 ux-designer，艺术调色板决策重定向至 art-director
- [ ] 返回结构化发现，包含特定元素名称、对比度比率和标准引用
- [ ] 不实现 UI 更改 — 与 ui-programmer 协调实现
- [ ] 当提供合规目标时，引用具体的 WCAG 标准编号
- [ ] 向 art-director 标记无障碍需求与艺术决策之间的冲突

---

## 覆盖范围说明
- HUD 审核 (用例 1) 应生成可作为冲刺待办事项中无障碍故事追踪的发现
- 色盲冲突 (用例 3) 确认 Agent 尊重 art-director 对调色板的权限
- WCAG 标准 (用例 5) 验证 Agent 精确使用标准，而非泛泛而谈