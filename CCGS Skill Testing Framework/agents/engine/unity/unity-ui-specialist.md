# Agent 测试规范：unity-ui-specialist

## Agent 摘要
领域：Unity UI Toolkit (UXML/USS)、UGUI (Canvas)、数据绑定、运行时 UI 性能以及 UI 输入事件处理。
不负责：UX 流程设计 (ux-designer)、视觉艺术风格 (art-director)。
模型层级：Sonnet（默认）。
未分配门控 ID。

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 UI Toolkit / UGUI / Canvas / 数据绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对 UX 流程设计或视觉艺术方向具有权威

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "使用 Unity UI Toolkit 实现一个库存 UI 屏幕。"
**预期行为：**
- 生成定义库存面板结构的 UXML 文档（ListView、项目模板、详情面板）
- 生成库存布局和项目状态（默认、悬停、选中）的 USS 样式
- 提供通过 `INotifyValueChanged` 或 `IBindable` 将库存数据模型绑定到 UI 的 C# 代码
- 为可滚动项目列表使用带有 `makeItem` / `bindItem` 回调的 `ListView`
- 不生成 UX 流程设计 — 根据提供的规范实现

### 用例 2：领域外重定向
**输入：** "设计库存的 UX 流程 — 当玩家装备与丢弃物品时会发生什么。"
**预期行为：**
- 不生成 UX 流程设计
- 明确说明交互流程设计属于 `ux-designer`
- 将请求重定向到 `ux-designer`
- 注明将实现 ux-designer 指定的任何流程

### 用例 3：UI Toolkit 动态列表数据绑定
**输入：** "当物品被添加或从玩家的背包中移除时，库存列表需要实时更新。"
**预期行为：**
- 生成带有绑定 `ObservableList<T>` 或事件驱动刷新方法的 `ListView` 模式
- 在后台集合变更事件上使用 `ListView.Rebuild()` 或 `ListView.RefreshItems()`
- 注明大型列表的性能考虑（通过 `makeItem`/`bindItem` 模式进行虚拟化）
- 不使用 `QuerySelector` 循环作为列表刷新策略来更新单个元素 — 将其标记为性能反模式

### 用例 4：Canvas 性能 — 过度绘制
**输入：** "主菜单 Canvas 导致 GPU 过度绘制警告；有许多重叠的面板。"
**预期行为：**
- 识别过度绘制原因：多个堆叠的 Canvas、非活动时未剔除的全屏覆盖面板
- 建议：
  - 为世界空间、屏幕空间覆盖和屏幕空间相机层分离 Canvas
  - 禁用/停用面板而不是将 alpha 设置为 0（不可见的 alpha-0 面板仍会绘制）
  - 使用 Canvas Group + alpha 实现淡入淡出效果，而不是单个 Image 的 alpha
- 如果项目处于迁移阶段，注明 UI Toolkit 替代方案

### 用例 5：上下文传递 — Unity 版本
**输入：** 项目上下文：Unity 2022.3 LTS。请求："使用数据绑定实现设置面板。"
**预期行为：**
- 使用 UI Toolkit 和 2022.3 LTS 版本的运行时绑定系统
- 注明 Unity 2022.3 引入了运行时数据绑定（与早期版本中仅编辑器绑定相对）
- 如果 Unity 6 增强的绑定 API 功能在 2022.3 中不可用，则不使用
- 生成与声明的 Unity 版本兼容的代码，并包含版本特定的 API 说明

---

## 协议合规性

- [ ] 保持在声明的领域内（UI Toolkit、UGUI、数据绑定、UI 性能）
- [ ] 将 UX 流程设计重定向到 ux-designer
- [ ] 返回结构化输出（UXML、USS、C# 绑定代码）
- [ ] 为项目的 Unity 版本使用正确的 Unity UI 框架版本
- [ ] 将 Canvas 过度绘制标记为性能反模式并提供具体的修复方案
- [ ] 不使用 alpha-0 作为显示/隐藏模式 — 使用 SetActive() 或 VisualElement.style.display

---

## 覆盖范围说明
- 库存 UI（用例 1）应在 `production/qa/evidence/` 中有一个手动演练文档
- 动态列表绑定（用例 3）应有一个集成测试或自动化交互测试
- Canvas 过度绘制（用例 4）验证 Agent 了解正确的 Unity UI 性能模式