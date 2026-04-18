# UX 规格说明: [Screen / Flow Name]

> **状态**: 草案 | 评审中 | 已批准 | 已实现
> **作者**: [Name or agent — e.g., ui-designer]
> **最后更新**: [Date]
> **屏幕/流程名称**: [Short identifier used in code and tickets — e.g., `InventoryScreen`, `NewGameFlow`]
> **平台目标**: [PC | Console | Mobile | All — list all that this spec covers]
> **相关 GDDs**: [Links to the GDD sections that generated this UI requirement — e.g., `design/gdd/inventory.md § UI Requirements`]
> **相关 ADRs**: [Any architectural decisions that constrain this screen — e.g., `ADR-0012: UI Framework Selection`]
> **相关 UX Specs**: [Sibling and parent screens — e.g., `ux-spec-pause-menu.md`, `ux-spec-settings.md`]
> **无障碍等级**: 基础 | 标准 | 全面 | 典范

> **注意 — 范围边界**: 此模板涵盖离散的屏幕和流程（菜单、对话框、库存、设置、过场动画 UI 等）。对于存在于主动游戏过程中的持久性游戏内覆盖层，请改用 `hud-design.md`。如果屏幕是混合类型（例如，覆盖游戏世界的暂停菜单），则将其视为屏幕规格，并在导航位置中注明覆盖关系。

---

## 1. 目的与玩家需求

> **此章节存在的原因**: 每个屏幕都必须从玩家的角度证明其存在的价值。从开发者视角设计的屏幕（“显示保存数据”）会产生杂乱混乱的界面。从玩家视角设计的屏幕（“让玩家在放下控制器前确信他们的进度是安全的”）会产生有目的、平静的界面。在接触任何布局决策之前撰写此部分——它是评估后续每个选择的过滤器。

**此屏幕满足什么玩家需求？**

[一段话。指明真实的人类需求，而非系统功能。思考：玩家打开此屏幕时会说他们想要什么？如果它不工作，什么会让他们感到沮丧？这种沮丧即描述了需求。

反面示例： “显示玩家当前的物品和装备。”
正面示例： “让玩家理解他们携带了什么，并快速决定在下一次遭遇中带什么，同时不破坏他们对游戏世界的心理模型。库存是玩家在行动间隙的规划工具。”]

**玩家目标**（玩家想要完成什么）：

[一句话。具体到可以为其编写验收标准的程度。
示例： “在三次按键内找到他们想要的物品并装备，无需导航到单独的屏幕。”]

**游戏目标**（游戏需要传达或捕获什么）：

[一句话。这是系统从此交互中需要的内容。示例： “在下次遭遇加载前，记录玩家的装备选择并将其传递给战斗系统。”此部分防止UI看起来不错却无法服务于其所属系统。]

---

## 2. 玩家到达时的情境

> **此章节存在的原因**: 屏幕并非孤立存在。在战斗中途打开库存的玩家，与清理地牢后打开库存的玩家，其认知和情绪状态完全不同。相同的信息架构在一种情境下可能感觉压抑复杂，在另一种情境下却显得简单明了。记录情境以便设计决策——首先显示什么、隐藏什么、动画什么、简化什么——根据实际到达此屏幕的玩家进行校准，而非抽象用户。

| 问题 | 答案 |
|----------|--------|
| 玩家刚才在做什么？ | [e.g., Completed a combat encounter / Pressed Esc from exploration / Triggered a story cutscene] |
| 他们的情绪状态如何？ | [e.g., High tension — just narrowly survived / Calm — exploring between objectives] |
| 他们承受着怎样的认知负荷？ | [e.g., High — actively tracking enemy positions / Low — no active threats] |
| 他们已经掌握了哪些信息？ | [e.g., They know they just picked up an item but haven't seen its stats yet] |
| 他们最可能试图做什么？ | [e.g., Check if the new item is better than their current weapon — primary use case] |
| 他们可能害怕什么？ | [e.g., Missing something, making an irreversible mistake, losing track of where they were] |

**此屏幕的情感设计目标**:

[一句话描述玩家在使用此屏幕时应有的感觉。
示例: “自信且掌控——玩家应感到拥有完整的信息和对自己选择的完全权威，对结果没有模糊性。”]

---

## 3. 导航位置

> **此章节存在的原因**: 不知道自身在导航层级中位置的屏幕无法定义其进入/退出过渡、返回按钮行为或与游戏暂停状态的关系。导航位置还能早期揭示架构问题——如果此屏幕可以从八个不同的位置访问，那就是一个应在设计而非实现中解决的复杂性标志。

**屏幕层级结构**（使用缩进显示父子关系）：

```
[Root — e.g., Main Menu]
  └── [Parent Screen — e.g., Settings]
        └── [This Screen — e.g., Audio Settings]
              ├── [Child Screen — e.g., Advanced Audio Options]
              └── [Child Screen — e.g., Speaker Test Dialog]
```

**模态行为**: [Modal (blocks everything behind it, requires explicit dismiss) | Non-modal (game continues behind it) | Overlay (renders over game world, game paused) | Overlay-live (renders over game world, game continues)]

> 如果此屏幕是模态的：记录关闭行为。是否可以通过按Back/B关闭？按Escape？点击外部？是否可以关闭，还是玩家必须完成它？不可关闭的模态是高摩擦力的——请证明其合理性。

**可达性 — 所有入口点**:

| 入口点 | 触发方式 | 备注 |
|-------------|-------------|-------|
| [e.g., Main Menu → Play] | [Player selects "New Game"] | [Primary entry point] |
| [e.g., Pause Menu → Resume] | [Player presses Start from any gameplay state] | [Secondary entry] |
| [e.g., Game event] | [Tutorial system forces open first time only] | [Systemic entry — must not break if player dismisses] |

---

## 4. 入口与出口点

> **此章节存在的原因**: 入口和出口定义了屏幕与导航系统其余部分的契约。每个入口点必须有一个对应的出口点。未定义的过渡会成为bug——玩家发现自己被卡住，或游戏状态变得不一致。在实现开始前完整填写此表格。空单元格表明设计工作尚未完成。

**入口表**:

| 触发条件 | 源屏幕/状态 | 过渡类型 | 传入数据 | 备注 |
|---------|----------------------|-----------------|----------------|-------|
| [e.g., Player presses Inventory button] | [Gameplay / Exploration state] | [Overlay push — game pauses] | [Current player loadout, inventory contents] | [Works from any non-combat state] |
| [e.g., Item pickup prompt accepted] | [Gameplay / Item Pickup dialog] | [Replace dialog with full inventory] | [Newly acquired item pre-highlighted] | [The new item should be visually distinguished on open] |
| [e.g., Quest system directs player to inventory] | [Gameplay / Quest Update notification] | [Overlay push] | [Quest-relevant item ID for highlight] | [Screen should deep-link to the relevant item] |

**出口表**:

| 退出动作 | 目标 | 过渡类型 | 返回/保存的数据 | 备注 |
|-------------|------------|-----------------|----------------------|-------|
| [e.g., Player closes inventory (Back/B/Esc)] | [Previous state — Exploration] | [Overlay pop — game resumes] | [Updated equipment loadout committed] | [Changes must be committed before transition begins] |
| [e.g., Player selects "Equip" on item] | [Same screen, updated state] | [In-place state change] | [Loadout change event fired] | [No navigation, just a state refresh] |
| [e.g., Player navigates to Map from inventory shortcut] | [Map Screen] | [Replace] | [No data] | [Inventory state is preserved if player returns] |

---

## 5. 布局规范

> **此章节存在的原因**: 布局规范是UX设计和UI编程之间的交接工件。它不需要像素完美——它需要传达层次结构（什么是重要的）、邻近性（什么属于一起）和比例（什么大什么小）。ASCII线框图无需设计软件即可实现这一点。阅读此部分的程序员应该能够构建正确的结构而无需猜测。阅读它的艺术家应该知道视觉重心应集中在哪里。
>
> 在一个标准分辨率（例如1920x1080）下绘制布局。单独注明其他分辨率的适配。

### 5.1 线框图

```
[使用 ASCII 艺术绘制屏幕布局。建议字符：
 ┌ ┐ └ ┘ │ ─    for borders
 ╔ ╗ ╚ ╝ ║ ═    for emphasized/modal borders
 [ ]              for interactive elements (buttons, inputs)
 { }              for content areas (lists, grids, images)
 ...              for scrollable content
 ●                for the focused element on open

示例:
┌──────────────────────────────────────────────┐
│  [← Back]        INVENTORY         [Options] │  ← HEADER ZONE
├──────────────────────────────────────────────┤
│ ┌──────────────┐  ┌─────────────────────────┐│
│ │ CATEGORY NAV │  │  ITEM DETAIL PANEL      ││  ← CONTENT ZONE
│ │  ● Weapons   │  │  Item Name              ││
│ │    Armor     │  │  {item icon}            ││
│ │    Consumable│  │  Stats comparison       ││
│ │    Key Items │  │  Description text...    ││
│ ├──────────────┤  └─────────────────────────┘│
│ │ ITEM GRID    │                             │
│ │ {□}{□}{□}{□} │                             │
│ │ {□}{□}{□}{□} │                             │
│ │ ...          │                             │
│ └──────────────┘                             │
├──────────────────────────────────────────────┤
│   [Equip]     [Drop]     [Compare]  [Close]  │  ← ACTION BAR
└──────────────────────────────────────────────┘
]
```

### 5.2 区域定义

| 区域名称 | 描述 | 大致尺寸 | 可滚动？ | 溢出行为 |
|-----------|-------------|-----------------|-------------|-------------------|
| [e.g., Header Zone] | [Top bar: navigation, screen title, global actions] | [Full width, ~10% height] | [No] | [Truncate long screen names with ellipsis] |
| [e.g., Category Nav] | [Left panel: item category tabs] | [~25% width, ~75% height] | [Yes — vertical if categories exceed panel] | [Scroll indicator appears at bottom of list] |
| [e.g., Item Grid] | [Center: grid of item icons for selected category] | [~45% width, ~75% height] | [Yes — vertical] | [Page-based: 4x4 grid, next page on overflow] |
| [e.g., Detail Panel] | [Right: stats and description for selected item] | [~30% width, ~75% height] | [Yes — vertical for long descriptions] | [Fade at bottom, scroll to reveal] |
| [e.g., Action Bar] | [Bottom: context-sensitive actions for selected item] | [Full width, ~15% height] | [No] | [Actions collapse to icon-only below 4] |

### 5.3 组件清单

> 列出此屏幕上的每个独立UI组件。此表驱动实现任务列表——每一行成为一个要构建或重用的组件。

| 组件名称 | 类型 | 区域 | 用途 | 必需？ | 重用现有组件？ |
|----------------|------|------|---------|-----------|---------------------------|
| [e.g., Back Button] | [Button] | [Header] | [Returns to previous screen] | [Yes] | [Yes — standard NavButton component] |
| [e.g., Screen Title Label] | [Text] | [Header] | [Displays "INVENTORY" or context name] | [Yes] | [Yes — ScreenTitle component] |
| [e.g., Category Tab] | [Toggle Button] | [Category Nav] | [Filters item grid by category] | [Yes] | [No — new component needed] |
| [e.g., Item Slot] | [Icon + Frame] | [Item Grid] | [Represents one inventory slot, empty or filled] | [Yes] | [No — new component] |
| [e.g., Item Name Label] | [Text] | [Detail Panel] | [Shows selected item's name] | [Yes] | [Yes — BodyText component] |
| [e.g., Stat Comparison Row] | [Compound — label + value + delta] | [Detail Panel] | [Shows stat value vs. currently equipped] | [Yes] | [No — new component] |
| [e.g., Equip Button] | [Primary Button] | [Action Bar] | [Equips selected item in appropriate slot] | [Yes] | [Yes — PrimaryAction component] |
| [e.g., Empty State Message] | [Text + Icon] | [Item Grid] | [Shown when category has no items] | [Yes] | [Yes — EmptyState component] |

**打开时的主焦点元素**: [e.g., The first item in the Item Grid — or, if deep-linked, the highlighted item. If the grid is empty, focus lands on the first Category Tab.]

---

## 6. 状态与变体

> **此章节存在的原因**: 屏幕不是单张图片——它是一组状态，每个状态都必须看起来正确且行为正确。仅设计其“快乐路径”状态的屏幕会附带损坏的空状态、不可见的加载指示器以及数据缺失时的崩溃。在实现前记录每个状态。状态表也是QA的测试矩阵。

| 状态名称 | 触发条件 | 视觉变化 | 行为变化 | 备注 |
|------------|---------|----------------------|--------------------------|-------|
| [Loading] | [Screen is opening, data not yet available] | [Item Grid shows skeleton/shimmer placeholders; Action Bar buttons disabled] | [No interactions possible except Close] | [Should not be visible >500ms under normal conditions; if it is, investigate data fetch performance] |
| [Empty — no items in category] | [Player switches to a category with zero items] | [Item Grid replaced by EmptyState component: icon + "Nothing here yet."] | [Action Bar shows no item actions; Drop/Equip/Compare all hidden] | [Do not show disabled buttons — remove them. Disabled buttons with no tooltip are confusing.] |
| [Populated — items present] | [Category has at least one item] | [Item Grid fills with item slots; first slot is auto-focused] | [All item actions available for selected item] | [Default and most common state] |
| [Item Selected] | [Player navigates to an item slot] | [Detail Panel populates; selected slot has focus ring; Action Bar updates to item's valid actions] | [Equip/Drop/Compare enabled based on item type] | [Equip is disabled if item is already equipped — show a "Equipped" badge instead] |
| [Confirmation Pending — Drop] | [Player selects Drop action] | [Confirmation dialog overlays the screen] | [All background interactions suspended until dialog resolves] | [Use a modal confirmation, not an inline toggle. Items cannot be recovered after dropping.] |
| [Error — data load failed] | [Inventory data could not be retrieved] | [Item Grid shows error state: icon + "Couldn't load items." + Retry button] | [Only Retry and Close are available] | [Log the error; do not expose technical details to player] |
| [Item Newly Acquired] | [Screen opened from item pickup deep-link] | [Newly acquired item has a visual "New" badge; Detail Panel pre-populated with that item] | [Same as Item Selected but with badge until player navigates away] | [Badge persists until the player manually navigates off that slot once] |

---

## 7. 交互映射

> **此章节存在的原因**: 此章节是此屏幕上每个输入操作的真相来源。它迫使设计者思考每种输入方法（鼠标、键盘、游戏手柄、触摸）和每个交互状态（悬停、聚焦、按下、禁用）。此表中的空白是等待发生的bug。交互映射也是无障碍审计的输入——如果一个操作只能通过鼠标访问，它将无法通过键盘和游戏手柄列的测试。

### 7.1 导航输入

| 输入 | 平台 | 操作 | 视觉响应 | 音频提示 | 备注 |
|-------|----------|--------|-----------------|-----------|-------|
| [Arrow keys / D-Pad] | [All] | [Move focus within active zone] | [Focus ring moves to adjacent element] | [Soft navigation tick] | [Wrap at edges within zone; do not cross zones with arrows alone] |
| [Tab / R1] | [KB / Gamepad] | [Move focus to next zone (Category → Grid → Detail → Action Bar)] | [Focus ring jumps to first element in next zone] | [Distinct zone-change tone] | [Shift+Tab / L1 goes backward] |
| [Mouse hover] | [PC] | [Show hover state on interactive elements] | [Highlight / underline / color shift] | [None] | [Hover does NOT move focus — only click does] |
| [Mouse click] | [PC] | [Select and focus the clicked element] | [Pressed state flash, then selected/focused] | [Soft click] | [Right-click opens context menu if applicable; otherwise no-op] |
| [Touch tap] | [Mobile] | [Select and activate in one gesture] | [Press ripple] | [Soft click] | [Treat tap as click + confirm for low-risk actions; require explicit confirm for destructive actions] |

### 7.2 操作输入

| 输入 | 平台 | 上下文 | 操作 | 响应 | 动画 | 音频提示 | 备注 |
|-------|----------|-------------------------------|--------|----------|-----------|-----------|-------|
| [Enter / A button / Left click] | [All] | [Item slot focused] | [Select item → populate Detail Panel] | [Detail panel slides in or updates in place] | [Panel fade/slide in, 120ms] | [Soft select tone] | [If item already selected: no-op] |
| [Enter / A button] | [All] | [Equip button focused] | [Equip selected item] | [Button animates press; item badge updates to "Equipped"; previously equipped item loses badge] | [Badge swap, 80ms] | [Equip success sound] | [Fires EquipItem event to Inventory system] |
| [Triangle / Y button / Right-click] | [All] | [Item slot focused] | [Open item context menu] | [Context menu appears adjacent to item slot] | [Popover, 80ms] | [Menu open sound] | [Context menu contains: Equip, Drop, Inspect, Compare] |
| [Square / X button] | [Gamepad] | [Item slot focused] | [Quick-equip without opening detail] | [Equip animation plays inline on slot] | [Slot flash, 80ms] | [Equip success sound] | [Convenience shortcut; does not change screen state] |
| [Esc / B button / Back] | [All] | [Any, screen level] | [Close screen and return to previous state] | [Screen exit transition plays] | [Slide out, 200ms] | [Back/close tone] | [Commits all changes before closing. No discard — inventory is not a draft.] |
| [F / L2] | [KB / Gamepad] | [Any] | [Toggle filter panel] | [Sort/filter overlay opens] | [Slide in from right, 200ms] | [Panel open tone] | [If no items in category, filter is disabled] |

### 7.3 状态特定行为

| 状态 | 输入限制 | 原因 |
|-------|------------------|--------|
| [Loading] | [All item and action inputs disabled] | [No data to act on; prevent race conditions] |
| [Confirmation dialog open] | [Only Confirm and Cancel inputs active] | [Modal — background is locked] |
| [Error state] | [Only Retry and Close active] | [No data available to navigate] |

---

## 8. 数据需求

> **此章节存在的原因**: UI与游戏状态之间的分离是游戏UI系统中最重要的架构边界。UI读取数据；它不拥有数据。UI触发事件；它不直接写入状态。本部分明确定义此屏幕需要显示哪些数据、数据来源以及更新频率。在实现前填写此表可防止两种常见故障模式：(1) UI开发者触及不应接触的系统，(2) 系统在UI构建到一半时才知道需要暴露数据。

| 数据元素 | 来源系统 | 更新频率 | 所有者 | 格式 | 空值/缺失处理 |
|--------------|--------------|-----------------|-------------|--------|------------------------|
| [e.g., Item list] | [Inventory System] | [On screen open; on InventoryChanged event] | [InventorySystem] | [Array of ItemData structs: id, name, icon_path, category, stats, is_equipped] | [Empty array → show Empty State. Never null — system must return array.] |
| [e.g., Equipped loadout] | [Equipment System] | [On screen open; on EquipmentChanged event] | [EquipmentSystem] | [Dict mapping slot_id → item_id] | [Unequipped slot has null value — UI shows empty slot icon] |
| [e.g., Item stat comparisons] | [Stats System] | [On item selection change] | [StatsSystem] | [Dict mapping stat_name → {current, new, delta}] | [If no item selected, detail panel shows placeholder. Stats system must handle this gracefully.] |
| [e.g., Player currency] | [Economy System] | [On screen open only — inventory does not show live currency] | [EconomySystem] | [Int — gold pieces] | [If currency system not active for this game mode, hide the currency row entirely] |
| [e.g., Newly acquired item flag] | [Inventory System] | [On screen open] | [InventorySystem] | [Array of item_ids flagged as new] | [If empty array, no badges shown] |

> **规则**: 此屏幕绝不得直接写入上述任何系统。所有玩家动作都会触发事件（见第9节）。系统更新自身数据并通知UI。

---

## 9. 事件触发

> **此章节存在的原因**: 这是UI/系统边界的另一半。第8节定义了UI读取的内容，而本节定义了UI与游戏通信的内容。在设计时指定事件可防止UI程序员编写游戏逻辑，并防止游戏程序员对UI的行为感到意外。每个破坏性或状态更改的玩家动作都必须出现在此表中。

| 玩家动作 | 触发事件 | 载荷 | 接收系统 | 备注 |
|---------------|-------------|---------|-----------------|-------|
| [Player equips an item] | [EquipItemRequested] | [{item_id: string, target_slot: string}] | [Equipment System] | [Equipment System validates the action and fires EquipmentChanged if successful; UI listens for EquipmentChanged to update its display] |
| [Player drops an item] | [DropItemRequested] | [{item_id: string, quantity: int}] | [Inventory System] | [Fires only after player confirms the drop dialog. Inventory System removes the item and fires InventoryChanged.] |
| [Player opens item compare] | [ItemCompareOpened] | [{item_a_id: string, item_b_id: string}] | [Analytics System] | [No game-state change — analytics event only. Compare view is purely local UI state.] |
| [Player closes screen] | [InventoryScreenClosed] | [{session_duration_ms: int}] | [Analytics System] | [Fires on every close regardless of reason. Used for engagement metrics.] |
| [Player navigates between categories] | [InventoryCategoryChanged] | [{category: string}] | [Analytics System] | [Analytics only. No game state change.] |

---

## 10. 过渡与动画

> **此章节存在的原因**: 过渡不是装饰——它们传达层次结构和因果关系。从右侧滑入的屏幕暗示玩家已向前移动。淡入淡出的屏幕暗示上下文切换。不一致的过渡会使导航感觉中断，即使技术上是正确的。本部分确保过渡是有意指定的，而非留给开发者自行决定，并且无障碍设置（减少运动）从一开始就得到规划。

| 过渡 | 触发条件 | 方向/类型 | 时长(毫秒) | 缓动 | 可中断？ | 减少运动时跳过？ |
|------------|---------|-----------------|--------------|--------|----------------|---------------------------|
| [Screen enter] | [Screen pushed onto stack] | [Slide in from right] | [250] | [Ease out cubic] | [No — must complete before interaction is enabled] | [Yes — instant appear at 0ms] |
| [Screen exit — Back] | [Player presses Back] | [Slide out to right] | [200] | [Ease in cubic] | [No] | [Yes — instant disappear] |
| [Screen exit — Forward] | [Player navigates to child screen] | [Slide out to left] | [200] | [Ease in cubic] | [No] | [Yes — instant] |
| [Detail panel update] | [Player selects a new item] | [Cross-fade content] | [120] | [Linear] | [Yes — if player navigates quickly, previous animation cancels] | [Yes — instant swap] |
| [Loading → Populated] | [Data arrives after load] | [Skeleton shimmer fades out, content fades in] | [180] | [Ease out] | [No] | [Yes — instant reveal] |
| [Action Bar button press] | [Player activates a button] | [Scale down 95% on press, return on release] | [60 down / 60 up] | [Ease out / ease in] | [Yes — if released early, returns to normal] | [No — this is tactile feedback, not decorative motion] |
| [Confirmation dialog open] | [Player initiates destructive action] | [Background dims 60% opacity; dialog scales up from 95%] | [150] | [Ease out] | [No] | [Yes — instant appear, no scale] |
| [New item badge appear] | [Screen opens with newly acquired item] | [Badge pops from 0% to 110% to 100% scale] | [200 total] | [Ease out back] | [No] | [Yes — instant appear at 100% scale] |

---

## 11. 输入方式完整性检查清单

> **此章节存在的原因**: 输入完整性不是可选的——它是游戏机平台的认证要求，也是多个市场无障碍法规的法律风险领域。在将规格标记为“已批准”前填写此检查清单。任何未勾选的项目都会阻止实现开始。

**键盘**
- [ ] 仅使用Tab键和方向键即可访问所有交互元素
- [ ] Tab顺序遵循视觉阅读顺序（从左到右，在每个区域内从上到下）
- [ ] 每个可通过鼠标执行的操作也可通过键盘执行
- [ ] 焦点始终可见（没有焦点环消失的元素）
- [ ] 屏幕打开时焦点不会逃脱（模态窗口的焦点陷阱）
- [ ] Esc键关闭或取消（并且不会从屏幕内退出游戏）

**游戏手柄**
- [ ] 所有交互元素都可通过D-Pad和左摇杆访问
- [ ] 正面按钮映射已记录并与平台惯例一致（见第7.2节）
- [ ] 没有操作需要模拟摇杆精度而无法用D-Pad复制
- [ ] 如果使用，触发器和缓冲器快捷方式已记录
- [ ] 屏幕打开时控制器断开连接得到优雅处理

**鼠标**
- [ ] 为所有交互元素定义了悬停状态
- [ ] 可点击的命中目标最小为32x32像素（推荐44x44像素）
- [ ] 右键单击行为已定义（上下文菜单或无操作——非未定义）
- [ ] 在所有可滚动区域定义了滚轮行为

**触摸（如适用）**
- [ ] 所有触摸目标最小为44x44像素
- [ ] 滑动手势不与系统级滑动导航冲突
- [ ] 所有操作可在纵向方向下用单手完成
- [ ] 如果使用，已定义长按行为

---

## 12. 屏幕级无障碍要求

> **此章节存在的原因**: 无障碍要求必须在设计时指定，因为后期改造成本高昂且通常在架构上不切实际。本节记录此屏幕特定的要求。项目范围的标准位于`docs/accessibility-requirements.md`中——在填写本节前请查阅，以免重复或与项目级承诺冲突。
>
> 此项目的无障碍等级：
> - 基础：WCAG 2.1 AA文本对比度，键盘可导航，无仅靠运动传达的信息
> - 标准：基础 + 屏幕阅读器支持，色盲友好，焦点管理
> - 全面：标准 + 减少运动支持，文本缩放，高对比度模式
> - 典范：全面 + 认知负荷管理，AAA等效，认证

**此屏幕的文本对比度要求**:

| 文本元素 | 背景环境 | 要求比率 | 当前比率 | 通过？ |
|--------------|-------------------|---------------|---------------|-------|
| [e.g., Item name in Detail Panel] | [Dark panel background ~#1a1a1a] | [4.5:1 (WCAG AA normal text)] | [TBD — verify in implementation] | [ ] |
| [e.g., Category tab label — inactive] | [Mid-grey tab background] | [4.5:1] | [TBD] | [ ] |
| [e.g., Category tab label — active] | [Accent color background] | [4.5:1] | [TBD] | [ ] |
| [e.g., Action button label] | [Button color (varies by state)] | [4.5:1] | [TBD] | [ ] |
| [e.g., Stat comparison delta (positive)] | [Detail panel] | [4.5:1 — do NOT rely on green color alone] | [TBD] | [ ] |

**色盲不安全元素及缓解措施**:

| 元素 | 色盲风险 | 缓解措施 |
|---------|----------------|------------|
| [e.g., Stat delta indicators (red/green for worse/better)] | [Red-green colorblindness (Deuteranopia) — most common form] | [Add arrow icons (↑ / ↓) and +/- prefix in addition to color. Color is a redundant, not sole, indicator.] |
| [e.g., Item rarity color coding (grey/green/blue/purple/orange)] | [Multiple types — rarity color is a common industry failure] | [Add rarity name text label below icon. Color is supplemental only.] |

**焦点顺序**（Tab键顺序，编号）：

[e.g.,
1. Back button (Header)
2. Options button (Header)
3. Category Tab 1 — Weapons
4. Category Tab 2 — Armor
5. Category Tab 3 — Consumables
6. Category Tab 4 — Key Items
7. Item Slot [0,0]
8. Item Slot [0,1] ... (grid traverses left-to-right, top-to-bottom)
9. Last item slot
10. Equip button (Action Bar)
11. Drop button (Action Bar)
12. Compare button (Action Bar)
13. Close button (Action Bar)
→ Cycles back to Back button

焦点不进入详情面板——它是一个由物品焦点驱动的显示面板，不能独立导航。]

**屏幕阅读器对关键状态变化的播报**:

| 状态变化 | 播报文本 | 播报时机 |
|--------------|------------------|---------------------|
| [Screen opens] | ["Inventory screen. [N] items. [Active category] selected."] | [On screen focus settle] |
| [Player focuses an item slot] | ["[Item name]. [Category]. [Rarity]. [Key stats summary]. [Equipped / Not equipped]."] | [On focus arrival] |
| [Player equips an item] | ["[Item name] equipped to [slot name]."] | [After EquipmentChanged event confirmed] |
| [Player drops an item] | ["[Item name] dropped."] | [After InventoryChanged event confirmed] |
| [Category changes] | ["[Category name]. [N] items."] | [On category tab focus] |
| [Empty state shown] | ["No items in [category name]."] | [When empty state renders] |

**认知负荷评估**:

[估计玩家在使用此屏幕时同时追踪的信息流数量。对于此屏幕：(1) 物品网格位置，(2) 物品详情属性，
(3) 当前装备配置用于比较，(4) 可用操作，(5) 物品类别。
这是5个并发流——在标准的7±2限制范围内，但处于较高端。
缓解措施：详情面板在导航时自动更新，因此玩家永远不需要
手动检索物品信息。通过自动显示属性比较来减少主动决策。]

---

## 13. 本地化考量

> **此章节存在的原因**: 未考虑本地化的UI会在第一次翻译时崩溃。德文文本通常比英文长30-40%。阿拉伯文和希伯来文需要从右到左的布局镜像。日文和中文文本可能比英文短得多，造成尴尬的空白。这些问题在规划时成本低廉，但在布局构建并发布后修复成本高昂。每个文本元素都应有明确的字符数上限和溢出处理方案。

**此屏幕的通用规则**:
- 所有文本元素必须至少容忍比英文基准长40%的扩展
- RTL布局（阿拉伯文、希伯来文）：需要镜像布局——记录哪些元素镜像，哪些不镜像
- CJK语言（日文、韩文、中文）：文本可能比英文短20-30%——验证布局在文本较少时不会显得破碎
- 不要在图像中使用文本——所有文本必须来自本地化字符串

| 文本元素 | 英文基准长度 | 最大字符数 | 扩展预算 | RTL行为 | 溢出行为 | 风险 |
|--------------|------------------------|----------------|-----------------|--------------|-------------------|------|
| [e.g., Screen title "INVENTORY"] | [9 chars] | [16 chars] | [78%] | [Mirror to right, or center — acceptable] | [Truncate with ellipsis — title is not critical content] | [Low] |
| [e.g., Item name] | [~15 chars avg, max ~35 "Enchanted Dragon Scale Gauntlets"] | [50 chars] | [43%] | [Right-align in RTL layouts] | [Truncate with tooltip showing full name on hover/focus] | [Medium — long fantasy item names are common] |
| [e.g., Item description] | [~80–120 chars] | [200 chars] | [67%] | [Right-align, wrap normally] | [Scroll within Detail Panel — no truncation] | [Low — panel is scrollable] |
| [e.g., Action button "Equip"] | [5 chars] | [14 chars] | [180%] | [Button layout mirrors; text right-aligns] | [Shrink font to 90% minimum, then truncate] | [Medium — "Ausrüsten" in German is 9 chars] |
| [e.g., Category tab "Consumables"] | [11 chars] | [18 chars] | [64%] | [Mirror tab position] | [Abbreviate: "Consum." — define abbreviations per language in loc file] | [High — long localized tab labels are a known problem] |

---

## 14. 验收标准

> **此章节存在的原因**: 验收标准是"完成"的契约定义。没有它们，实现就在开发者说完成时完成。有了它们，实现就在QA测试人员能够验证此列表中的每一项时完成。编写测试人员可以独立验证的标准，而无需询问设计师其含义。每个标准都应是二元的——通过或失败，而非主观的。

**性能**
- [ ] 屏幕在最低规格硬件上在触发后200毫秒内打开（第一帧可见）
- [ ] 屏幕在最低规格硬件上在触发后500毫秒内完全可交互（所有数据已加载）
- [ ] 项目之间的导航不会产生可感知的帧率下降（保持目标帧率±5fps）

**布局与渲染**
- [ ] 屏幕在最低支持分辨率下正确显示（无重叠、无切割、无溢出）[指定]
- [ ] 屏幕在最高支持分辨率下正确显示[指定]
- [ ] 如果面向PC，屏幕在4:3、16:9、16:10和21:9宽高比下正确显示
- [ ] 英文文本在定义的字符数上限内无溢出或截断
- [ ] 最长翻译语言文本无溢出或截断[指定——通常为德文]
- [ ] 所有状态（加载中、空、已填充、错误、确认）正确渲染
- [ ] 当所有物品槽位都已填充时，物品网格滚动平滑无帧率下降

**输入**
- [ ] 所有交互元素仅使用Tab键和方向键即可通过键盘访问
- [ ] 所有交互元素仅使用D-Pad和正面按钮即可通过游戏手柄访问
- [ ] 所有交互元素无需键盘即可通过鼠标访问
- [ ] 没有操作需要第7节中未记录的同时输入
- [ ] 在键盘和游戏手柄导航时，焦点始终可见
- [ ] 焦点在屏幕打开时不会逃脱

**事件与数据**
- [ ] 第9节中的所有事件在所有退出路径上都以正确的载荷触发（通过调试日志验证）
- [ ] 屏幕不直接写入任何游戏系统（验证：没有直接的状态变更调用）
- [ ] 物品栏更改在屏幕关闭并重新打开后正确持久化
- [ ] 屏幕在其打开时正确处理其他系统触发的InventoryChanged事件，不会崩溃

**无障碍**
- [ ] 所有文本通过第12节中指定的最小对比度比率
- [ ] 属性比较不单独依赖颜色作为唯一区分器
- [ ] 屏幕阅读器在获得焦点时播报物品名称和关键属性（通过平台屏幕阅读器验证）
- [ ] 减少运动设置导致瞬时过渡（无动画过渡）
- [ ] 高对比度模式（如果适用于无障碍等级）渲染时无视觉破损

**本地化**
- [ ] 在任何支持的语言中，文本元素均不溢出其容器
- [ ] RTL布局正确渲染（如果RTL是目标语言）
- [ ] 所有文本元素由本地化字符串驱动——无硬编码显示文本

---

## 15. 未决问题

> 在此处跟踪未解决的设计问题。每个问题应有明确的所有者和截止日期。已批准的规格必须没有未决问题——做出决定或明确记录推迟的理由。

| 问题 | 所有者 | 截止日期 | 解决方案 |
|----------|-------|----------|-----------|
| [e.g., Should item comparison be automatic (always showing equipped stats) or player-triggered (press Compare)?] | [ui-designer] | [Sprint 4, Day 3] | [Pending] |
| [e.g., Do we support controller cursor (free aim) in the item grid, or d-pad-only grid navigation?] | [lead-programmer + ui-designer] | [Sprint 4, Day 3] | [Pending — depends on ADR-0015 input model decision] |
| [e.g., What is the game's item drop policy — permanent loss or drop-to-world?] | [systems-designer] | [Requires GDD update] | [Blocked on inventory GDD Edge Cases section] |
| [e.g., Maximum inventory size — does the grid have a hard cap or is it infinite-scroll?] | [economy-designer] | [Sprint 3, Day 5] | [Pending] |
