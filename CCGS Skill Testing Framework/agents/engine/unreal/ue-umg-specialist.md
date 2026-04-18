# Agent 测试规范：ue-umg-specialist

## Agent 概述
- **领域**: UMG 控件层级设计、数据绑定模式、CommonUI 输入路由和动作标签、控件样式（WidgetStyle 资源）、UI 优化（控件池、ListView、失效处理）
- **不负责**: UX 流程和屏幕导航设计（ux-designer）、游戏逻辑（gameplay-programmer）、后端数据源（游戏代码）、服务器通信
- **模型层级**: Sonnet
- **阶段门 ID**: 无；将 UX 流程决策委托给 ux-designer

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 UMG、控件层级、CommonUI）
- [ ] `allowed-tools:` 列表与 Agent 角色匹配（UI 资源和蓝图文件的读/写权限；无服务器或游戏逻辑源代码工具）
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对 UX 流程、导航架构或游戏数据逻辑拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 带数据绑定的库存控件
**输入**: "创建一个显示物品槽网格的库存控件。每个槽应显示物品图标、数量和稀有度颜色。当库存变化时需要更新。"
**预期行为**:
- 生成 UMG 控件结构：包含 UniformGridPanel 或 TileView 的父级 WBP_Inventory，每个物品对应一个子级 WBP_InventorySlot 控件
- 描述数据绑定方法：要么是 Inventory Component 上触发刷新的 Event Dispatchers，要么是带有实现 IUserObjectListEntry 的 UObject 物品数据类的 ListView
- 指定稀有度颜色的驱动方式：WidgetStyle 资源或数据表查找，而非硬编码的颜色值
- 输出包括控件层级、绑定模式和刷新触发机制

### 用例 2：领域外请求 — UX 流程设计
**输入**: "设计我们库存系统的完整导航流程 — 玩家如何打开它、过渡到角色状态、以及退出到暂停菜单。"
**预期行为**:
- 不生成导航流程或屏幕过渡架构
- 明确声明："导航流程和屏幕过渡设计由 ux-designer 负责；一旦流程定义完成，我可以实现 UMG 控件结构"
- 在没有 UX 规范的情况下不做出 UX 决策（返回按钮行为、过渡动画、模态与全屏）

### 用例 3：领域边界 — CommonUI 输入动作不匹配
**输入**: "我们的库存控件没有响应控制器返回按钮。我们正在使用 CommonUI。"
**预期行为**:
- 识别可能原因：控件的返回输入动作标签与项目中注册的 CommonUI InputAction 数据资源不匹配
- 解释 CommonUI 输入路由模型：控件通过 `CommonUI_InputAction` 标签声明输入动作；CommonActivatableWidget 处理路由
- 提供修复方案：验证控件的返回动作标签是否与项目中 CommonUI 输入动作数据表中注册的标签匹配
- 将此问题与硬件输入绑定问题（这属于 Enhanced Input 领域）区分开来

### 用例 4：控件性能问题 — 每帧大量控件实例
**输入**: "我们的排行榜控件一次性创建了 500 个独立的 WBP_LeaderboardRow 实例。打开排行榜时游戏卡顿了 300 毫秒。"
**预期行为**:
- 识别根本原因：单帧内 500 个控件实例化导致构造卡顿
- 推荐切换到带虚拟化的 ListView 或 TileView — 仅构造可见行
- 解释 ListView 数据对象所需的 IUserObjectListEntry 接口
- 如果 ListView 不合适，推荐池化：预实例化固定数量的行并用新数据回收使用
- 输出是具体建议，包含要使用的特定 UMG 组件，而非模糊的"优化它"

### 用例 5：上下文传递 — CommonUI 设置已配置
**输入上下文**: 项目使用 CommonUI，包含以下注册的 InputAction 标签：UI.Action.Confirm, UI.Action.Back, UI.Action.Pause, UI.Action.Secondary。
**输入**: "向库存控件添加一个适用于 CommonUI 的'排序库存'按钮。"
**预期行为**:
- 使用 UI.Action.Secondary（或如果 Secondary 已分配，则推荐注册新标签如 UI.Action.Sort）
- 不发明新的 InputAction 标签而不注明其必须在 CommonUI 数据表中注册
- 当 CommonUI 是既定模式时，不使用非 CommonUI 输入绑定方法（例如 Event Graph 中的原始按键）
- 在推荐中明确引用提供的标签列表

---

## 协议合规性

- [ ] 保持在声明的领域内（UMG 结构、数据绑定、CommonUI、控件性能）
- [ ] 将 UX 流程和导航设计请求重定向给 ux-designer
- [ ] 返回结构化发现（控件层级 + 绑定模式）而非自由形式的意见
- [ ] 使用上下文中的现有 CommonUI InputAction 标签；不发明新标签而不标记注册要求
- [ ] 对于大型集合，推荐虚拟化列表（ListView/TileView）优先于控件池

---

## 覆盖范围说明
- 用例 3（CommonUI 输入路由）要求项目已配置 CommonUI；如果项目不使用 CommonUI，则跳过此测试
- 用例 4（性能）是高影响故障模式 — 300 毫秒卡顿会阻碍发布；优先考虑此测试用例
- 用例 5 是 UI 流水线一致性最重要的上下文感知测试
- 无自动化运行器；通过 `/skill-test` 手动审查