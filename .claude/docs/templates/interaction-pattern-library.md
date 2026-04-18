# 交互模式库: [Game Title]

> **状态**: Draft | Stable | Under Revision
> **作者**: [ux-designer]
> **最后更新**: [Date]
> **版本**: [1.0]
> **引擎**: [Godot 4.6 / Unity 6 / Unreal Engine 5]
> **UI框架**: [Godot Control nodes / Unity UI Toolkit / Unreal UMG]
> **相关文档**:
> - `docs/art-bible.md` — 视觉标准（颜色、排版、图标）
> - `docs/accessibility-requirements.md` — 每个功能的无障碍设计承诺
> - `docs/ux/ux-spec-[screen].md` — 引用模式的单个屏幕规范

> **本文档存在的原因**: 每个UI屏幕规范都应能说"使用Button (Primary)模式"，而不是从头重新指定悬停状态、按下动画、焦点行为、键盘处理和屏幕阅读器公告。此库是可重用交互行为的唯一可信源。当屏幕规范引用模式名称时，程序员在此查找。当行为更改时，在此更改并应用于所有地方。

> 这是一个动态文档。模式随着新屏幕的设计而添加——不要在设计新交互前不先检查此处。如果需要新模式，在编写使用它的第一个屏幕规范之前，在此添加（或向ux-designer提出）。

> **状态定义**:
> - **草稿**: 已指定交互但尚未实现或验证
> - **稳定**: 已实现、测试并在至少一个已发布的屏幕中验证
> - **已弃用**: 正在逐步淘汰——现有使用将迁移，不要在新屏幕中使用

---

## 如何使用此库

**如果你是屏幕设计师**: 在发明新交互前，先浏览下面的模式目录索引。当标准模式适用时，在屏幕规范中按名称引用它（例如，"确认按钮使用Button (Primary)模式"）。当没有现有模式适用时，提出一个新模式——在此处记录它，与引入它的屏幕规范一起或在之前。

**如果你是屏幕实现者**: 当屏幕规范说"使用[PatternName]模式"时，在本文档中查找它以获取完整规范。实现说明部分包含引擎特定指导。无障碍设计部分包含不可妥协的要求。

**如果你是屏幕规范评审者**: 验证所有交互元素都引用了此库中的模式，或包含它们自己的完整交互规范。"标准按钮"或"通常方式"不是有效引用。

**如果你是模式更新者**: 更改稳定模式会影响使用它的每个屏幕。在更改前，审计所有使用情况（在屏幕规范中搜索模式名称），确定影响，获得UX设计师的批准，并在实施任何更改之前或同时更新本文档。

---

## 模式目录索引

> 每次向本文档添加新模式时，请在此添加一行。
> "Used In"列是使用审计跟踪——当新屏幕采用该模式时更新它。

| 模式名称 | 类别 | 描述 | 使用场景（屏幕） | 状态 |
|-------------|----------|-------------|------------------|--------|
| Button (Primary) | Input | 主要操作调用。高视觉权重。每个屏幕一个。 | [Main Menu, Pause Menu, Settings] | Draft |
| Button (Secondary) | Input | 替代操作或取消。视觉权重低于主要按钮。 | [All modal dialogs, settings screens] | Draft |
| Button (Destructive) | Input | 不可逆操作。执行前需要确认。 | [Delete Save, Reset Settings] | Draft |
| Toggle | Input | 二进制开/关状态选择。 | [Accessibility settings, audio settings] | Draft |
| Slider | Input | 连续值选择。 | [Volume controls, brightness, text size] | Draft |
| Dropdown / Select | Input | 从离散选项列表中选择。 | [Resolution, language, key binding] | Draft |
| List Item | Layout / Input | 垂直可滚动列表中的可选择行。 | [Achievements, quest log, settings list] | Draft |
| Grid Item | Layout / Input | 二维网格中的可选择单元格。 | [Inventory, ability select, item shop] | Draft |
| Modal Dialog | Feedback / Layout | 需要玩家明确决定的阻塞覆盖层。 | [Confirmation dialogs, error prompts] | Draft |
| Confirmation Dialog | Feedback / Layout | 用于危险操作确认的特定模态。 | [Delete Save, Leave Match, Reset] | Draft |
| Toast / Notification | Feedback | 屏幕角落的非阻塞临时消息。 | [Achievement unlock, autosave notification] | Draft |
| Tooltip | Feedback | 悬停或焦点时的上下文信息。 | [Inventory items, ability descriptions, settings] | Draft |
| Progress Bar | Feedback / Layout | 线性进度指示器。 | [Loading screen, XP bar, quest progress] | Draft |
| Input Field | Input | 文本输入控件。 | [Player name, search, key binding entry] | Draft |
| Tab Bar | Navigation | 单个屏幕内的标签页部分导航。 | [Character sheet, settings, crafting] | Draft |
| Scroll Container | Layout | 带有可见滚动指示器的可滚动内容区域。 | [Inventory, lore entries, credits] | Draft |
| Inventory Slot | Game-Specific | 物品栏网格中的物品容器（空、已填充、已装备、已锁定）。 | [Inventory screen, equipment screen] | Draft |
| Ability / Skill Icon | Game-Specific | 带有冷却时间、充能次数和锁定状态的技能按钮。 | [HUD ability bar, skill tree] | Draft |
| Health / Resource Bar | Game-Specific | 带有阈值状态和伤害闪烁的数值条。 | [HUD] | Draft |
| Minimap | Game-Specific | 带有玩家标记和兴趣点的概览地图。 | [HUD] | Draft |
| Quest / Objective Tracker | Game-Specific | 带有接近度和完成状态的活跃目标显示。 | [HUD] | Draft |
| Dialogue Box | Game-Specific | 带有说话者标识的NPC对话UI。 | [All dialogue sequences] | Draft |
| Context Action Prompt | Game-Specific | 可交互对象附近的上下文"按X键[动作]"提示。 | [World interaction] | Draft |
| Damage Number | Game-Specific | 浮动战斗反馈数字。 | [Combat HUD] | Draft |
| Status Effect Icon | Game-Specific | 带有持续时间的增益/减益指示器。 | [HUD status bar, enemy health display] | Draft |
| Notification Banner | Game-Specific | 成就、升级、获得物品的通知。 | [Global overlay] | Draft |
| Screen Push | Navigation | 带有方向动画的前向导航。 | [All menu navigation] | Draft |
| Screen Pop (Back) | Navigation | 带有反向动画的后向导航。 | [All menu navigation] | Draft |
| Screen Replace | Navigation | 替换当前屏幕而不堆叠历史记录。 | [Main Menu to Loading Screen] | Draft |
| Modal Open / Close | Navigation | 使背景屏幕变暗的覆盖层。 | [All modal dialogs] | Draft |
| Tab Switch | Navigation | 同一屏幕内标签页之间的内容切换。 | [All tabbed screens] | Draft |
| Focus Management | Navigation | 屏幕打开、关闭或更改时焦点移动的规则。 | [All screens] | Draft |
| Escape / Cancel | Navigation | 跨平台和输入方法的通用返回行为。 | [All screens] | Draft |
| Loading State | Feedback | 屏幕和组件如何指示加载进行中。 | [All loading states] | Draft |
| Empty State | Feedback | 空列表和空网格如何呈现。 | [Empty inventory, no quests, no saves] | Draft |
| Error State | Feedback | 错误如何传达。 | [Save failed, network error, invalid input] | Draft |
| Success Confirmation | Feedback | 已完成的操作如何确认。 | [Settings saved, item crafted, quest turned in] | Draft |
| Optimistic UI | Feedback | 在系统确认之前显示假设的成功。 | [If online features are present] | Draft |

---

## 标准控件模式

---

#### Button (Primary)（主要按钮）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: 屏幕上最重要的单个操作。 "Start Game,"
"Confirm," "Accept," "Buy." There should be at most one Primary button visible
at a time. 它回答了"玩家在这里最可能想做什么？"
**When NOT to Use（不应使用场景）**: Alternative or secondary actions; destructive actions that
require confirmation before the consequence is irreversible; any action that is
not the primary intent of the screen.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Full-opacity fill, primary color from art-bible. Label centered. | — | — | — | — |
| Hovered (mouse) | Brightness +15%, subtle scale 1.03x, cursor changes to pointer | Mouse over element | Transition from Default | 80ms ease-out | [UI hover sound — see Sound Standards] |
| Focused (keyboard/gamepad) | Focus ring visible (2px, offset 3px, high contrast color). Same brightness as Hovered. | Tab / D-pad navigation | Transition from Default | 80ms ease-out | [UI focus sound — same as hover] |
| Pressed | Scale 0.97x, brightness -10% | Click / Enter / A (Xbox) / Cross (PS) | Action fires on press-up, not press-down. Scale on press-down. | 60ms ease-in for press; 80ms ease-out on release | [UI confirm sound] |
| Disabled | 40% opacity, no pointer cursor, no hover state | — | No response | — | — |
| Loading (post-press) | Replace label with spinner. Button remains at pressed scale, disabled state. | — | Prevents double-submission | Duration of async operation | — |

**无障碍设计**:
- Keyboard: Tab to focus, Enter or Space to activate. Must be reachable from any other interactive element on screen via Tab sequence.
- Gamepad: D-pad or left stick to navigate focus to button. A (Xbox) / Cross (PS) to activate. Focus must be placed on Primary button by default when screen opens.
- Screen reader: Button must expose accessible name matching visible label. Role: "button." State: "dimmed" when disabled. Activation announcement: "[Label] button — [result of action, if known]."
- Colorblind: Do not rely on color alone to distinguish Primary from Secondary. Primary uses higher visual weight (fill vs. outline, or larger size) in addition to color differentiation.
- Minimum touch target: 44x44pt (iOS HIG) / 48x48dp (Android). Apply even on PC if touch support is possible.

**实现说明**:
[Godot: Extend `Button` control. Override `_draw()` for custom states rather than
modifying themes mid-state. Use `focus_mode = FOCUS_ALL` to ensure keyboard
focusability. Set `mouse_default_cursor_shape = CURSOR_POINTING_HAND`. For the
scale animation, use a Tween on the `scale` property of the button's parent
Control — scaling the Button itself can clip children.]

---

#### Button (Secondary)（次要按钮）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: Alternative or cancel action. "Back," "Cancel," "Skip," "Maybe
Later." Lower visual weight than Primary — it should recede visually, not compete.
**When NOT to Use（不应使用场景）**: Destructive actions (use Button (Destructive)). The most
important action on the screen (use Button (Primary)).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Outlined style (border only, transparent fill), secondary color. Slightly smaller or lower weight than Primary. | — | — | — | — |
| Hovered | Background fill appears at 15% opacity. Border brightens. Scale 1.02x. | Mouse over | Transition from Default | 80ms ease-out | [UI hover sound — softer variant than Primary] |
| Focused | Focus ring, same specification as Primary. | Tab / D-pad | Transition from Default | 80ms ease-out | [UI focus sound] |
| Pressed | Scale 0.97x, fill opacity increases to 30% | Click / Enter / B (Xbox) / Circle (PS) on focused state | Action fires on press-up | 60ms ease-in | [UI cancel/back sound] |
| Disabled | 40% opacity | — | No response | — | — |

**无障碍设计**: Same requirements as Button (Primary). Accessible name must
match visible label. In a dialog with Primary and Secondary buttons, the Secondary
button typically maps to the platform "cancel" input (B / Circle / Escape) as well
as direct focus activation.

**实现说明**: [Same as Button (Primary). Where a Primary and Secondary
appear together, ensure Secondary is always positioned consistently — right/bottom
of Primary on horizontal layouts, or below Primary on vertical layouts. Consistency
across screens is more important than per-screen aesthetic preference.]

---

#### Button (Destructive)（危险按钮）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: Any action that is irreversible and causes loss of player data or
significant progress: "Delete Save File," "Reset All Settings," "Leave Match,"
"Discard Changes." The visual treatment signals danger before the player presses.
**When NOT to Use（不应使用场景）**: Actions that can be undone, or actions that are merely
consequential but reversible.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Outlined or filled with destructive color (typically a desaturated red — confirm colorblind compatibility in accessibility-requirements). Label may include a warning icon. | — | — | — | — |
| Hovered / Focused | Same behavior as Button (Primary) hover/focus but with destructive color | — | — | 80ms | [UI hover sound] |
| Pressed (first press) | Does NOT execute the action. Instead, opens Confirmation Dialog pattern (see below). The button itself shows a brief pulse animation. | Click / Enter | Trigger Confirmation Dialog | 100ms pulse | [UI warning sound — distinct from standard confirm] |
| — | Confirmation Dialog handles the actual execution | — | — | — | — |
| Disabled | 40% opacity | — | No response | — | — |

> **关键规则**: A Button (Destructive) NEVER executes its action directly.
> It always triggers a Confirmation Dialog. There are no exceptions. A player
> who presses it by accident must always have one more opportunity to back out.
> Games that skip confirmation on destructive actions generate the most visible
> negative community sentiment of any UX failure type. See: every "accidentally
> deleted save file" complaint on any game forum.

**无障碍设计**: Screen reader must announce the destructive nature: "[Label] button — this action cannot be undone." In addition to accessible name, use the `description` property if available to add the warning text.

**实现说明**: [Destructive button triggers a separate Confirmation Dialog scene. Pass the action callback to the dialog — the button itself does not hold the execution logic. This separation prevents accidental execution if the confirmation dialog has a bug.]

---

#### Toggle（切换开关）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: Binary on/off settings where both states are equally valid and
the current state must be visible at a glance. "Subtitles: On/Off," "Aim Assist:
On/Off," "Notifications: On/Off."
**When NOT to Use（不应使用场景）**: 从两个以上选项中选择（使用下拉选择器）。 Actions
that happen once rather than representing a persistent state (use Button). Cases
where the consequence of toggling is complex enough to need explanation (show
a description field alongside).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Off / Default | Track: muted fill. Thumb: leftmost position. Label: "Off" or state label. | — | — | — | — |
| Hovered | Track brightens 10%. Cursor: pointer. | Mouse over | Transition | 60ms | [UI hover sound] |
| Focused | Focus ring around entire toggle element (track + thumb). | Tab / D-pad | — | 60ms | [UI focus sound] |
| Pressed / Activated | Thumb slides to right side. Track fill changes to active color. Label changes to "On" or active state label. State persists. | Click / Enter / A / Cross | Toggle state change. Fire onChange event. Persist value. | 150ms ease-in-out for slide | [Toggle ON sound] |
| Pressed / Deactivated | Thumb slides to left. Track reverts to muted fill. | Same inputs | Toggle state change | 150ms ease-in-out | [Toggle OFF sound — subtly different from ON] |
| Disabled | 40% opacity. No interaction. Current state still visible. | — | No response | — | — |

**无障碍设计**:
- Keyboard/Gamepad: Space or Enter to toggle. Avoid requiring directional inputs (left/right) to toggle — some users cannot predict that behavior.
- Screen reader: Role: "switch." State: "on" or "off" — the accessible name should NOT include the state (the screen reader announces state separately). Correct: accessible name "Subtitles," state "on." Incorrect: accessible name "Subtitles On."
- The toggle label (not just the visual thumb position) must change to show current state for players who cannot reliably distinguish left from right positions.

**实现说明**: [Godot: Use a custom Control or a CheckButton. The
built-in CheckButton provides accessibility role but uses a checkbox-style visual;
a custom slide-toggle animation may be needed for the target art style. Ensure
the slide animation is skipped when motion reduction mode is active — in that
case, snap to final state instantly.]

---

#### Slider（滑块）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: Selecting a value from a continuous range where approximate values
are acceptable and the range and relative position matter. Volume (0–100%), brightness,
text size. The visual representation of position is itself useful information.
**When NOT to Use（不应使用场景）**: 精确值输入（使用输入框）。 Selection from a short
discrete list (use Dropdown). 二进制状态（使用切换开关）。

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Track (full width). Fill (left of thumb, shows current value). Thumb (draggable handle). Current value label (right of track or above thumb). | — | — | — | — |
| Hovered | Thumb enlarges slightly (1.2x). Track brightens. | Mouse over | — | 60ms | — |
| Focused | Focus ring on thumb. Track brightens. | Tab / D-pad | — | 60ms | [UI focus sound] |
| Dragging (mouse) | Thumb follows cursor. Fill updates in real time. Value label updates in real time. | Click + drag on thumb | Continuous value update. Fire onChange continuously. | Real time | [Slider adjust sound — subtle, loops while dragging] |
| Keyboard / D-pad adjust | Thumb moves one step (5% of range per press, or 1 discrete unit). | Left/Right arrows or Left/Right D-pad while focused | Step value change. Fire onChange per step. | Instant | [Slider step sound — one click per step] |
| Keyboard fast adjust | Larger step (25% of range). | Page Up / Page Down while focused | Large step value change | Instant | [Same step sound] |
| Released | Value locks. onChange fires final value. | Mouse release | — | — | — |
| Disabled | 40% opacity. No interaction. Value visible. | — | No response | — | — |

**无障碍设计**:
- Keyboard: Left/Right arrows to adjust by small step. Page Up/Page Down for large step. Home/End to jump to min/max.
- Screen reader: Role: "slider." Accessible name: the label (e.g., "Music Volume"). Current value announced on every change: "Music Volume, 80 percent." Min/max values announced on first focus.
- All sliders must show a numeric value alongside the visual position. Relying only on track fill position excludes players who cannot perceive relative position.

**实现说明**: [Godot `HSlider`: set `step` to appropriate increment.
Override keyboard input to add Page Up/Down support via `_input()`. Bind the
`value_changed` signal to update the displayed numeric label. When motion reduction
mode is enabled, ensure value label updates are the sole feedback — do not suppress
them. Rumble feedback on gamepad slider adjustment is a nice enhancement for
accessibility.]

---

#### Dropdown / Select（下拉选择器）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: Selection from a discrete list of 3-15 options where only the
selected value needs to be visible at rest. Display resolution, language, window
mode, input preset. The closed state shows only the current selection.
**When NOT to Use（不应使用场景）**: Binary choices (use Toggle). More than ~15 options (use a
full List pattern or a scrollable Select). When comparing options matters as much
as selecting one (show options visibly, e.g., as a horizontal selector or list).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Closed / Default | Label (left). Current value (right). Chevron-down icon (far right). | — | — | — | — |
| Hovered | Row background fills at 10% opacity | Mouse over | — | 60ms | — |
| Focused (closed) | Focus ring on entire row. | Tab / D-pad | — | 60ms | [UI focus sound] |
| Opening | Dropdown list appears below (or above if near screen bottom). List items visible. Previously selected item highlighted. Focus moves to selected item inside list. | Click / Enter / A / Cross | Open list | 100ms ease-out (expand) | [UI expand sound] |
| List item hovered/focused | List item highlights | Mouse / D-pad | — | 60ms | [UI hover sound] |
| List item selected | List closes. Closed state shows new value. onChange event fires. | Click / Enter / A / Cross on item | Select value, close list | 80ms ease-in (collapse) | [UI confirm sound] |
| Dismissed without selecting | List closes. Value unchanged. | Escape / B / Circle / click outside | Dismiss | 80ms | [UI cancel sound] |
| Disabled | 40% opacity. No interaction. | — | — | — | — |

**无障碍设计**:
- Keyboard: Up/Down arrows navigate list items while open. Enter selects. Escape dismisses. First letter of an option jumps focus to first matching item.
- Screen reader: Role: "combobox." Accessible name: the field label. Expanded/collapsed state announced. Current value announced when focused. Each list item announces its value and position: "English, 1 of 12."
- The dropdown list must never obscure the current item or the control that opened it — this is a common failure on small screens.

**实现说明**: [Godot: Custom implementation using a `Button` (the
closed state) and a `PopupMenu` or a `VBoxContainer` revealed by animation. Native
`OptionButton` provides accessibility but limited visual customization. Ensure
the popup positions itself above the control if it would be clipped by the screen
bottom. Close the popup on `_input` detecting click outside its rect.]

---

#### List Item（列表项）

**类别**: Layout / Input
**状态**: Draft
**When to Use（使用场景）**: 垂直可滚动列表中的单个可选择行。 Achievements,
quest log entries, settings categories, save file slots. The list is the container;
this is the row within it.
**When NOT to Use（不应使用场景）**: 物品存在于二维的网格布局（使用网格项）。
Non-selectable content rows (remove hover/focus states and the pressed state).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Full-width row. Icon (optional, left). Primary label. Secondary label / metadata (right or below primary). Chevron (right, if navigates deeper). | — | — | — | — |
| Hovered | Row background at 12% opacity highlight. | Mouse over | — | 60ms | — |
| Focused | Focus ring on row OR row background at 20% opacity (consistent with platform convention). | D-pad / Tab | — | 60ms | [UI focus sound] |
| Selected (persistent) | Row background at 25% opacity. May show a selection indicator (left border, checkmark). Distinct from focused state — a row can be selected but not focused. | — | Rendered state | — | — |
| Pressed / Activated | Brief brightness flash, then navigates or performs action | Click / Enter / A / Cross | Navigation or action | 80ms flash | [UI confirm sound] |
| Disabled | 40% opacity. No interaction. | — | — | — | — |

**无障碍设计**:
- Keyboard/Gamepad: Up/Down arrows or D-pad to move between list items. The list must handle focus cycling — reaching the bottom should stop (not wrap) unless wrapping is explicitly designed.
- Screen reader: Role: "listitem." Parent list role: "list." Accessible name: primary label content. Metadata (secondary label) is optionally included in the description. Position announced: "Quest Log, 3 of 12."
- Minimum row height: 44pt / 48dp for touch. For controller-primary platforms, 56px rows are more comfortable.

**实现说明**: [Godot: Use a `VBoxContainer` inside a `ScrollContainer`.
Each row is a custom `Control` or `PanelContainer` with a `_gui_input` override.
For keyboard navigation inside the scroll container, implement custom focus
traversal — Godot's default Tab navigation does not scroll the container to keep
focused items in view. Use `ensure_control_visible()` on the scroll container.]

---

#### Grid Item（网格项）

**类别**: Layout / Input
**状态**: Draft
**When to Use（使用场景）**: 二维网格中的可选择单元格。 Inventory slots,
ability select, crafting ingredient selection, character portrait selection. The
grid is the container; this is the cell.
**When NOT to Use（不应使用场景）**: Single-column content (use List Item). Non-selectable display
cells (remove interactive states).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Empty | Empty slot visual (subtle border or dashed outline). Different from disabled. | — | — | — | — |
| Populated | Item icon fills cell. Stack count (bottom right, if applicable). Quality indicator (border color or icon overlay). | — | — | — | — |
| Hovered | Brightness +15%. Tooltip appears after 400ms delay. | Mouse over | — | 60ms | — |
| Focused | Focus ring (2px, offset 2px). Same brightness as hovered. Tooltip appears after 400ms delay or immediately on gamepad. | D-pad navigation | — | 60ms | [UI focus sound] |
| Selected (persistent) | Distinct border (thicker, contrasting color). May show selection checkmark. | Click / Enter / A / Cross | Select item. Can coexist with focused state on a different cell. | Instant | [UI select sound] |
| Pressed | Brief scale 0.95x, then executes action | Double-click / Enter / A / Cross | Action (equip, use, inspect — defined by context) | 80ms | [UI confirm sound] |
| Locked | Padlock overlay icon on populated content. No hover/focus states. | — | No interaction | — | — |
| Drag source | Cell dims (50% opacity), drag preview appears at cursor. | Click + drag (mouse only) | Begin drag operation | Instant | [UI grab sound] |
| Drop target (valid) | Cell brightens, accepting color indicator | Item dragged over | — | 60ms | — |
| Drop target (invalid) | Red tint or shake animation | Item dragged over invalid slot | — | 60ms | [UI error sound] |

**无障碍设计**:
- Keyboard/Gamepad: D-pad or arrow keys navigate cells. The grid must communicate its dimensions to screen readers. Row/column position announced.
- Screen reader: Role: "gridcell." Parent role: "grid." Accessible name: item name (or "empty slot" for empty cells). State: "selected" when selected, "dimmed" when locked. Position: "row 2, column 3."
- Tooltips must be reachable by keyboard — they must appear when the cell is focused, not only when hovered.

**实现说明**: [Godot: `GridContainer` with fixed column count. Each
cell is a custom `Control`. Implement custom D-pad navigation by overriding
`_gui_input` and calculating the cell to the left/right/above/below based on
index and column count. `GridContainer` does not provide this natively.]

---

#### Modal Dialog（模态对话框）

**类别**: Feedback / Layout
**状态**: Draft
**When to Use（使用场景）**: A decision or acknowledgment that must be resolved before the
player can continue. The dialog is blocking — background content is dimmed and
non-interactive. "Are you sure?", "Your progress will be saved.", error states.
**When NOT to Use（不应使用场景）**: 非阻塞通知（使用Toast通知）。 Information
that can wait until the player is ready (add it to a persistent help system instead).
Dialogs that should allow the player to continue playing behind them.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Opening | Background overlay animates from 0 to 60% opacity. Dialog panel scales from 0.9 to 1.0. Dialog enters from center (not from an edge). | Triggered by code | Focus moves to first interactive element in dialog (or the Primary button) | 200ms ease-out | [UI modal open sound] |
| Active | Background non-interactive. Dialog has all input focus. Player cannot interact with background. | Keyboard / gamepad navigates within dialog only | — | — | — |
| Dismissing (confirmed) | Dialog panel scales to 1.1 then fades. Overlay fades to 0%. | Primary button pressed | Execute action, return focus to trigger element | 180ms | [UI confirm sound] |
| Dismissing (cancelled) | Dialog panel scales to 0.9 then fades. Overlay fades to 0%. | Secondary button / Escape / B / Circle | No action, return focus to trigger element | 150ms | [UI cancel sound] |
| Cannot dismiss | If the dialog represents a blocking error, do not provide a cancel path. Provide only resolution options. | — | — | — | — |

> **焦点捕获规则**: While a modal dialog is open, Tab and D-pad navigation
> must cycle within the dialog's interactive elements only. It must not be possible
> to navigate focus outside the dialog to the background content. This is both
> an accessibility requirement (WCAG 2.1 SC 2.1.2) and a UX integrity requirement.
> When the dialog closes, focus must return to the element that triggered it,
> not to the top of the page.

**无障碍设计**:
- Screen reader: Dialog container role: "dialog." Accessible name: dialog title (required — every dialog must have a title, even if visually hidden). On open, screen reader announces dialog title and first focusable element. Focus trap active.
- Keyboard: Escape key always maps to the cancel/dismiss action (same as Secondary button or close button). Enter always maps to the primary/confirm action.
- Motion reduction: Scale animation replaced with instant appear/disappear. Overlay fade retained at 100ms (faster).

**实现说明**: [Godot: Implement as a `CanvasLayer` with a high layer
value (100+) to ensure it renders above all game content. The background overlay
is a full-screen `ColorRect` at 60% black opacity. Use `grab_focus()` on the
dialog's primary button after the open animation completes. Override `_input()` to
implement the focus trap — intercept Tab navigation and reroute to the dialog's
focusable elements.]

---

#### Confirmation Dialog（确认对话框）

**类别**: Feedback / Layout
**状态**: Draft
**When to Use（使用场景）**: 确认危险操作的具体情况。 Always
triggered by Button (Destructive). Always has exactly two options: confirm (labeled
with the specific action, not "OK") and cancel.
**When NOT to Use（不应使用场景）**: Non-destructive confirmations. Errors or notifications that
do not require a decision. Any dialog with more than two actions.

> **标签规则**: The confirm button must be labeled with the specific action,
> not a generic "OK" or "Yes." "Delete Save File" not "OK." "Leave Match" not
> "Yes." This reduces mistakes for players who have difficulty reading the dialog
> content quickly. The pattern comes from Apple HIG and is validated by decades
> of usability research.

**结构**:
- Title: Brief, action-describing. "Delete save file?" not "Are you sure?"
- Body: One sentence stating the consequence. "This cannot be undone."
- Confirm button: Button (Primary) — labeled with the specific action. "Delete Save File."
- Cancel button: Button (Secondary) — "Cancel."
- Default focus: Cancel (safer default — reduces accidental destructive actions).

**无障碍设计**: Inherits all Modal Dialog accessibility. Additionally: screen
reader announces "Alert dialog, [title]" to signal destructive context. Default
focus on Cancel is a requirement, not a preference.

**实现说明**: [Confirmation Dialog is a specific instance of Modal
Dialog — implement it as a subclass or as a parameterized scene. The default
focus on Cancel is critical: set `grab_focus()` on the Cancel button, not the
Confirm button, after open animation completes.]

---

#### Toast / Notification（Toast通知）

**类别**: Feedback
**状态**: Draft
**When to Use（使用场景）**: Brief, non-blocking information that does not require a player
decision. "Game saved." "Achievement unlocked." "Your inventory is full." The player
can continue playing; the notification disappears on its own.
**When NOT to Use（不应使用场景）**: Information that requires a decision (use Modal Dialog).
Errors that require the player to take action. Critical information that the player
must not miss.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Entering | Slides in from screen edge (typically bottom-right, away from primary action areas). Fades from 0 to 100% opacity. | Triggered by code | — | 200ms ease-out | [Sound matching notification type — see Sound Standards] |
| Displayed | Full opacity. Optional: icon (left), title, body text (optional), dismiss button (X, optional). | Pointer hover pauses auto-dismiss timer | Pause auto-dismiss | — | — |
| Auto-dismiss | Fades from 100 to 0% opacity, slides out | Timer expires (5 seconds default for one-line; 8 seconds for two-line) | Remove from queue | 200ms ease-in | — |
| Manual dismiss | Fades and slides out immediately | Click/tap X button or swipe on touch | Remove | 150ms | [UI cancel sound, quiet] |
| Queue overflow | New notification pushes oldest out early | New notification triggered while previous is displayed | FIFO queue, max 3 simultaneous | — | — |

**无障碍设计**:
- Screen reader: Toasts must be read aloud without requiring focus. In HTML, this uses `role="status"` or `role="alert"`. In game UI, this requires the engine's accessibility notification system. Verify engine support in engine-reference docs.
- Motion reduction: Slide animation replaced with fade only.
- Toasts must never be the sole communication channel for information the player needs to act on. If the information requires action, use a persistent UI element in addition to the toast.
- Auto-dismiss timer: 5 seconds is the minimum. Players with cognitive processing differences may need more time. Consider a setting to extend to 10 or 15 seconds.

**实现说明**: [Godot: Manage a queue of `PanelContainer` scenes in a
`VBoxContainer` anchored to a screen corner. Each toast is instantiated, added to
the container, then auto-removed after a timer. The container should be on a high
`CanvasLayer` (50+) but below modal dialogs (100+). Animate using a `Tween` on
`modulate.a` and `position.x`. When motion reduction is active, skip the position
animation.]

---

#### Tooltip（工具提示）

**类别**: Feedback
**状态**: Draft
**When to Use（使用场景）**: 补充可见标签的上下文信息。 Item
descriptions in inventory. Stat explanations on a character sheet. Setting
descriptions in accessibility options. The player must be able to access this
information or proceed without it.
**When NOT to Use（不应使用场景）**: Information the player MUST read to complete an action — put
that in the label or body text, not a tooltip. Tooltips are not discoverable
on mobile touch without a hover state. On touch-only platforms, use an info button
that opens a description modal instead.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Hidden | — | — | — | — | — |
| Hover trigger | — | Mouse enters element | Begin 400ms delay timer | — | — |
| Gamepad/keyboard trigger | — | Element receives focus | Begin 300ms delay timer (shorter because navigation is intentional) | — | — |
| Appearing | Tooltip panel fades in and scales from 0.95 to 1.0. Positioned near element (prefer above, adjust if near screen edge). | Timer expires | Show tooltip | 120ms ease-out | — |
| Displayed | Tooltip visible. Title (optional). Body text. Max width: 300px. Multiple lines allowed. | — | — | — | — |
| Hiding | Tooltip fades out | Mouse leaves element / focus moves away | Hide tooltip | 80ms ease-in | — |

**无障碍设计**:
- Screen reader: Tooltip content must be accessible without hover. The accessible name of the parent element should include the most critical tooltip information. The full tooltip text is optionally in the `description` property. Screen reader reads tooltip content when element is focused.
- The delay (300-400ms) prevents accidental tooltip display and is required — instant tooltips are disruptive in gamepad navigation.
- Tooltip text must meet the same contrast requirements as body text (4.5:1 minimum).

**实现说明**: [Godot: Attach a custom `TooltipControl` scene as a
child of the trigger element. Show/hide with a `Timer` node. Position the tooltip
using a `CanvasLayer` to ensure it appears above all other UI. For screen edges,
detect if the tooltip rect extends beyond `get_viewport_rect()` and flip the
position to the opposite side.]

---

#### Progress Bar（进度条）

**类别**: Feedback / Layout
**状态**: Draft
**When to Use（使用场景）**: 朝着定义端点的线性进度。 Loading screens (time
to completion), XP fill toward next level, quest objectives with countable progress
("3 of 10 enemies defeated"), download progress.
**When NOT to Use（不应使用场景）**: Circular or radial progress (use a separate Radial Progress
pattern if needed). Values that fluctuate up and down rapidly (use Health/Resource
Bar pattern). Values with no defined endpoint.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Track (full width, background color). Fill (left to right, value color). Value label (percentage or N/M, outside or inside fill). | — | — | — | — |
| Value increasing | Fill width animates to new value | Value changes | Smooth fill animation | 300ms ease-out | [Context-dependent — XP gain has a sound; loading has none] |
| Value at maximum | Fill reaches full width. Optional: completion animation (pulse, glow). | Value reaches 100% | Completion event fires | 200ms | [Completion sound if appropriate] |
| Value at zero | Fill hidden (zero width). Track still visible. | — | — | — | — |
| Indeterminate (unknown duration) | Animated loop (fill segment moves left-to-right, repeat). Used for loading of unknown duration. | — | — | Infinite loop | — |

**无障碍设计**:
- Screen reader: Role: "progressbar." Accessible name: what is progressing (e.g., "Experience Points," "Loading"). Value: current numeric value AND percentage AND maximum. "Experience Points, 450 of 1000, 45 percent." Update on significant changes (not every pixel).
- Do not rely only on fill color to communicate value. Include a numeric label.
- Indeterminate progress bars: announce "Loading, in progress" — do not announce changes since the value is unknown.
- Motion reduction: Indeterminate animation is replaced with a static "loading" indicator. Smooth fill animation is replaced with instant jump to new value.

**实现说明**: [Godot: `ProgressBar` built-in with custom theming.
For indeterminate mode, `ProgressBar` does not have a native indeterminate state
in Godot 4.x — implement using a looping `Tween` on a fill element's position.
Ensure the Tween is paused when motion reduction mode is active and a static
indicator is shown instead.]

---

#### Input Field（输入框）

**类别**: Input
**状态**: Draft
**When to Use（使用场景）**: 文本输入。 Player name on a new save, search within a list,
remapping a key binding (special case — shows the key press, not typed text),
entering a numeric value precisely.
**When NOT to Use（不应使用场景）**: 从已知选项中选择（使用下拉选择器或列表）。 On
console-primary platforms, minimize text entry — it requires a virtual keyboard,
which is high friction.

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default | Field border, placeholder text (label-style, muted color), empty input area. | — | — | — | — |
| Hovered | Border brightens slightly | Mouse over | — | 60ms | — |
| Focused | Border brightens fully. Cursor (blinking, 530ms on/530ms off). Placeholder text hidden. | Tab / click | Open virtual keyboard on console/mobile | Instant | [UI focus sound] |
| Typing | Characters appear. Cursor advances. | Keyboard input | Update field value | Immediate | [Subtle keystroke sound, optional] |
| Value present | Field shows typed value. Placeholder hidden. Clear button appears (X, right of field) if value is non-empty. | — | — | — | — |
| Character limit reached | No further input accepted. Optional: brief shake animation and limit indicator changes color. | Input at limit | Reject further characters | 200ms shake | [UI error sound, subtle] |
| Clear | Field empties. Cursor returns. Clear button disappears. | Click X / gamepad clear input | Clear value | Instant | [UI cancel sound, subtle] |
| Validation error | Border turns error color (red — ensure colorblind safe). Error message appears below field. | On submit or on blur | Show error | Instant | [UI error sound] |
| Validated / correct | Border turns success color (green — ensure colorblind safe). Success icon optional. | On validation pass | — | Instant | — |
| Disabled | 40% opacity, no interaction. Value still visible. | — | — | — | — |

**无障碍设计**:
- Keyboard: All standard text editing shortcuts (Home, End, Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+Z).
- Screen reader: Role: "textbox." Accessible name: field label (not placeholder text). Current value announced. Character limit announced when reached. Validation errors announced immediately on occurrence.
- Placeholder text must not be used as the only label — a visible label above or beside the field is required. Placeholder text disappears when the player types, causing confusion for players with cognitive or memory impairments.

**实现说明**: [Godot `LineEdit`: set `placeholder_text` for the hint
but always include a visible `Label` node as the field's accessible name. Bind
`text_changed` signal for real-time validation. Bind `text_submitted` for form
submission on Enter. On console, `LineEdit.call("_popup_keyboard")` or use the OS
virtual keyboard API — verify against engine-reference/godot/ for Godot 4.6
console keyboard API specifics.]

---

#### Tab Bar（标签栏）

**类别**: Navigation
**状态**: Draft
**When to Use（使用场景）**: Dividing a single screen's content into discrete sections where
only one section is visible at a time. Character sheet tabs (Stats / Equipment /
Skills), settings tabs (Gameplay / Graphics / Audio / Accessibility). Maximum
5-6 tabs before the pattern breaks down and a sidebar navigation should be
considered instead.
**When NOT to Use（不应使用场景）**: 超过6个标签页。 Content that benefits from simultaneous
visibility (use a layout pattern instead). Navigation between different screens
(use Screen Push).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Default (inactive tab) | Tab label. No active indicator. | — | — | — | — |
| Active tab | Tab label. Active indicator (underline, fill, or contrasting background). Content area shows this tab's content. | — | — | — | — |
| Hovered (inactive) | Tab background fills slightly | Mouse over | — | 60ms | — |
| Focused (keyboard/gamepad) | Focus ring on tab label. | Tab key (within tab bar) or D-pad left/right on tab row | — | 60ms | [UI focus sound] |
| Activated | Active indicator transitions to this tab. Content area transitions (fade or slide). | Click / Enter / A / Cross | Switch active tab. Content update. | 150ms ease | [UI tab switch sound] |
| Gamepad shoulder button | — | L1/R1 (PS) or LB/RB (Xbox) | Switch to previous/next tab (standard platform convention) | 150ms | [UI tab switch sound] |

**无障碍设计**:
- Keyboard: Arrow keys navigate between tabs within the tab bar (left/right). Tab key moves focus into the content area below. This follows the ARIA tab panel pattern.
- Screen reader: Role: "tab" for individual tabs. Role: "tablist" for the container. Role: "tabpanel" for the content area. Active tab state: "selected." Accessible name: tab label. Tabpanel is labeled by its corresponding tab.
- The active tab must be visually distinguishable by more than color alone (underline, fill pattern, or weight change in addition to color).

**实现说明**: [Godot: `TabContainer` built-in. For custom visual
styling, implement manually with a `HBoxContainer` of tab buttons and a
`MarginContainer` for content. The shoulder button shortcut (LB/RB) must be
implemented in the screen's `_input()` override — it is not built into Godot's
tab system. Check platform conventions: Xbox uses LB/RB; PlayStation uses L1/R1;
both are the same physical button, so a single binding works.]

---

#### Scroll Container（滚动容器）

**类别**: Layout
**状态**: Draft
**When to Use（使用场景）**: 超出容器可见区域的内容。 Inventory
lists, lore entry text, credits, long settings lists. The scroll indicator shows
the player that more content exists.
**When NOT to Use（不应使用场景）**: Content that can be paginated instead (pagination may be
clearer for dense list navigation). Infinite scroll (always provide a loading
state and an end state).

**交互规范**:

| State | Visual | Input | Response | Duration | Audio |
|-------|--------|-------|----------|----------|-------|
| Content fits | No scrollbar visible (or always-visible scrollbar at full height, depending on art direction). | — | — | — | — |
| Scrollable | Scrollbar appears (right edge). Scrollbar thumb size represents viewport vs. content ratio. | — | — | — | — |
| Scrolling (mouse) | Content moves. Scrollbar thumb moves proportionally. | Mouse wheel | Scroll by 3 lines per wheel tick (configurable in OS) | Smooth | — |
| Scrollbar drag | Content moves. Thumb follows pointer. | Click + drag scrollbar thumb | Scroll proportionally | Real time | — |
| Keyboard scroll | Content moves one item height per keypress. | Up/Down arrows when container is focused and no child is focused | Scroll by one unit | Immediate | — |
| Gamepad scroll | Content moves to keep focused item in view. | D-pad navigation to items beyond visible area | Auto-scroll to keep focused item visible | Smooth 150ms | — |
| Scroll top / bottom | Content stops. Scrollbar thumb at end. | Content boundary reached | Stop scrolling | — | — |
| Focus follows scroll | When a child element receives focus, scroll container ensures it is fully visible. | Any child receives focus | Scroll to reveal focused element | 200ms ease | — |

**无障碍设计**:
- Keyboard/Gamepad: The scroll container itself should not require explicit scrollbar interaction — navigating list items inside it should auto-scroll to keep focused items in view.
- Screen reader: The scroll container announces "scrollable" and the scroll position ("showing items 5 through 15 of 30"). This requires engine accessibility support — verify in engine-reference/godot/.
- Fade edges (content fading at scroll boundaries to indicate more content exists) are a helpful visual affordance but must not be the only indicator that content exists beyond the visible area. Include a scrollbar.

**实现说明**: [Godot `ScrollContainer`: call `ensure_control_visible()`
on the focused child whenever `gui_focus_changed` fires inside the container.
Bind this via a recursive `connect` on the container's `gui_focus_changed` signal.
For smooth scroll animation, use a `Tween` on `scroll_vertical` rather than
setting it directly.]

---

## 游戏特定UI模式

---

#### Inventory Slot（物品栏槽位）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: 物品栏网格中的每个物品容器。 Empty slots, populated
slots, equipped slots, locked slots. The slot is the frame; the item icon is the
content.

**状态**:

| State | Visual | Notes |
|-------|--------|-------|
| Empty | Subtle slot border, no content. Not the same as disabled. Empty slots are interactable (receive items). | Avoid fully invisible empty slots — players lose track of grid dimensions |
| Populated | Item icon fills 80% of slot area. Stack count bottom-right (if applicable). Quality border (colorblind-safe — icon + color). Equipped badge (top-right, if equipped). | |
| Focused | Focus ring. Tooltip appears after 300ms. | |
| Selected | Thicker or contrasting border. Used when multi-select is supported. | |
| Drag source | Slot dims, drag ghost follows pointer. | See Grid Item for full drag spec |
| Locked | Padlock icon overlay. No interaction. May show item at 50% opacity behind lock. | Used for locked loadout slots, DLC content, etc. |
| Highlighted | Animated border glow (pulsing). Used for quest-relevant items or newly acquired items. | Respect motion reduction — replace pulse with a static badge |
| Cooldown overlay | Radial fill overlay from 12 o'clock, clockwise, depleting as cooldown expires. | Only applicable if slots represent active items with cooldowns |

**无障碍设计**: Stack counts and quality tiers must have text or icon alternatives to color coding. Tooltip is the primary accessibility mechanism — ensure it is reachable by keyboard and screen reader. Locked slots must announce "locked" to screen readers.

**实现说明**: [Godot: Custom `Control` node. Quality border implemented as a `StyleBoxFlat` swapped based on rarity — avoid using `modulate` color for quality, as it affects the icon color. Drag and drop implemented via `get_drag_data()` and `can_drop_data()` / `drop_data()` override methods.]

---

#### Ability / Skill Icon（技能图标）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: Ability buttons in the HUD ability bar, skill tree nodes, and
any context where an ability must show availability state.

**状态**:

| State | Visual | Notes |
|-------|--------|-------|
| Available | Full opacity icon. Keybinding label below. | |
| On cooldown | Radial overlay depleting clockwise from 12 o'clock. Remaining time shown as a number in the center when > 2 seconds remain. | |
| Charges remaining | Charge pip indicators below icon (e.g., 3 filled circles = 3 charges). Number alternative for screen readers. | |
| Out of resource | Icon desaturates to ~20%. Border dims. Keybinding label dims. Distinct from cooldown — resource-gated, not time-gated. | |
| Locked / not unlocked | Icon silhouette only (no full art visible). Padlock badge. May show unlock condition in tooltip. | |
| Active / channeling | Pulsing border. Radial fill shows channel duration remaining. | |
| Just activated | Brief scale 0.9x then spring to 1.0x (overshoot to 1.05x). | Example: Guild Wars 2 and Path of Exile both use press-depress animations on ability use to confirm activation. Respect motion reduction. |

**无障碍设计**: All cooldown/charge information must have a numeric value (screen reader cannot parse radial overlays). The cooldown timer number satisfies this. Ability names and descriptions must be exposed to screen readers via tooltip.

**实现说明**: [Godot: Custom `TextureButton` subclass with overlay
`Control` nodes for cooldown radial and charge pips. The cooldown radial uses a
custom shader on a `ColorRect` rotating a mask — or implement with a
`ProgressBar` styled as circular if engine supports it. Verify against
engine-reference/godot/ for Godot 4.6 shader support for this pattern.]

---

#### Health / Resource Bar（生命值/资源条）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: Any continuously varying value in the HUD that represents a
critical player resource. Health, mana, stamina, shield, fuel.

**状态与行为**:

| Event | Visual | Audio | Duration |
|-------|--------|-------|---------|
| Value decrease (damage) | Fill shrinks. Brief "damage flash" on the fill (white or red flash). Ghost bar lingers at previous value and drains to new value over 0.5s ("damage indicator"). | [Damage taken sound — varies by amount] | Instant decrease, 500ms ghost bar drain |
| Value increase (heal) | Fill grows. Brief heal color flash (green — ensure colorblind safe with icon/glow backup). | [Heal sound] | 300ms ease-in |
| Below 25% threshold | Fill changes color to warning state. Border pulses (or static badge in motion reduction mode). Optional: heartbeat audio cue (paired with visual if audio is sole signal). | [Low health sound — loops until above threshold] | Continuous |
| At zero | Bar empty. Optional: bar shakes briefly. Death/depletion event fires. | [Death/depletion sound] | 200ms shake |
| Maximum | Fill at 100%, brief glow. | — | 200ms |
| Overflow (shield) | A separate bar segment appears beyond the natural fill area, in shield color. | [Shield gain sound] | 200ms |

**无障碍设计**: The current value must be accessible as a number (tooltip or persistent display, or both). Color-coded threshold states must have non-color backups (icon, flashing, or audio visual warning). Warning state at 25% must have a visual signal independent of the color change.

**实现说明**: [Godot: Two overlapping `ProgressBar` nodes for ghost
bar effect — back bar holds previous value (drains via Tween), front bar holds
current value (updates instantly). Threshold states trigger `StyleBoxFlat` swaps
on the front bar. Ghost bar Tween duration is tunable as a designer parameter.]

---

#### Dialogue Box（对话框）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: NPC conversation, voiced narrative dialogue, tutorial text
delivered through a character. All dialogue that has a speaker.

**结构**: Speaker portrait or name tag (top of box or left side). Dialogue text body. Continue/advance prompt (bottom right). Optional: skip-all button, voice acting indicator, subtitle indicator.

**状态与行为**:

| State | Visual | Input | Response | Duration |
|-------|--------|-------|----------|---------|
| Line entering | Text reveals character-by-character (typewriter effect). Or: text fades in at full speed if accessibility option set. | — | — | Speed: configurable in accessibility settings |
| Revealing | Text animating in. Continue prompt hidden or pulsing at slow opacity. | [Any advance input] | Skip to end of current line instantly (show full line, stop typewriter) | Immediate |
| Line complete | Full line shown. Continue prompt visible and animated. | — | — | — |
| Advancing to next line | Continue prompt hides. Text fades out or wipes. New line begins. | [Any advance input] — Enter / A / Cross / Space / mouse click | Advance | 100ms transition |
| Choices appearing | Choice buttons appear below dialogue text. Continue prompt hidden. Navigation focus moves to first choice. | D-pad / keyboard to select, Enter / A / Cross to confirm | Select choice | 150ms enter animation |
| Closing | Box fades out | Final line advanced | Return control to player | 200ms |
| Skipping all (if supported) | Brief confirmation prompt: "Skip dialogue?" | Dedicated skip button | Skip to post-dialogue state | — |

**无障碍设计**: Subtitles are always enabled by default for all voiced dialogue. Typewriter animation speed is a user setting (see accessibility-requirements.md). The dialogue box must not auto-advance — players must control pacing. Speaker name is always shown. All choice buttons must be navigable by keyboard and gamepad. Choices must be accessible to screen readers with position announced.

**实现说明**: [Godot: `RichTextLabel` with `bbcode_enabled` for
formatting. Typewriter effect via `visible_characters` property animated by a
`Timer`. Bind the advance input to a function that either skips typewriter
(sets `visible_characters = -1`) or advances the dialogue state. Speaker name
displayed in a separate `Label` above or beside the box. Dialogue data loaded from
JSON or a dedicated dialogue format (e.g., Dialogic, Yarn Spinner for Godot).]

---

#### Context Action Prompt（上下文操作提示）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: A prompt that appears near an interactable game object indicating
what the player can do. "Press [A] to open chest." "Hold [E] to pick up." Appears
when the player enters the interaction zone, disappears when they leave.

**状态**:

| State | Visual | Notes |
|-------|--------|-------|
| Appearing | Fades in and rises 8px from object anchor point. | Respect motion reduction — fade only, no rise |
| Idle | Platform-correct button icon + action label. Icon matches current input method (updates if player switches). | Always show platform-correct icon — do not hardcode "Press A" for all platforms |
| Holding (for hold inputs) | Radial fill on the button icon shows hold progress. Label changes to active verb ("Opening..."). | |
| Cannot interact (blocked) | Icon dims. Label shows reason if known ("Too heavy", "Need key"). | Optional — only show blocked state if the reason is meaningful to the player |
| Disappearing | Fades out. | Triggered when player exits interaction zone |

**无障碍设计**: The button icon must be accompanied by a text label — do not rely on icon alone (some players use custom button labels or adaptive controllers with non-standard icons). The prompt must be positioned to not overlap character health or critical HUD information.

**实现说明**: [Godot: Attach as a `Node3D` child (or `Node2D` child in 2D) of the interactable object. Use a `BillboardMesh` or a `SubViewport` with a UI scene for 3D games — this keeps the prompt facing the camera without code. Update the button icon texture based on `Input.get_joy_name()` or keyboard detection via `InputEventKey` vs `InputEventJoypadButton`. Hold progress implemented as an `AnimationPlayer` or `Tween` on a radial mask shader.]

---

#### Damage Number（伤害数字）

**类别**: Game-Specific
**状态**: Draft
**When to Use（使用场景）**: 战斗参与者上方的浮动反馈数字。 Normal
damage, critical damage, healing, miss.

**变体**:

| Variant | Visual | Notes |
|---------|--------|-------|
| Normal damage | White number, normal weight, medium size. | |
| Critical hit | Larger size (1.5x), bold weight, orange or yellow — verify colorblind safe. Brief scale impact (1.3x → 1.0x on appear). | Example: Path of Exile and Diablo IV both use scale-pop for crits to make them immediately recognizable by size alone, independent of color. |
| Healing | Green (verify colorblind safe — use + prefix and upward trajectory as non-color backups). | |
| Miss / Evade | "MISS" text, grey, italic. Floats at smaller size. | |
| Status damage (DoT) | Smaller size, distinct color matching the status effect. | |

**行为**: Numbers float upward from the hit location over 1.0 second. Numbers fade from 100% to 0% during the last 0.4 seconds. Multiple numbers from rapid hits stagger horizontally to avoid overlap. Maximum simultaneous damage numbers on screen: [define per game — typically 8-12 per character].

**无障碍设计**: Damage numbers are purely supplementary feedback — they must never be the only way to understand combat state. Health bars are the authoritative source. Provide an option to disable damage numbers entirely (some players find them visually overwhelming). When disabled, the game must remain fully playable.

**实现说明**: [Godot: Pool of `Label3D` (3D games) or `Label` (2D games)
instances recycled via an object pool. Each instance is given a random small
horizontal offset on spawn (±20px) to reduce overlap. Float animation via
`Tween` on `position.y` and `modulate.a`. Critical hit scale-pop via Tween
with `EASE_OUT` on scale followed by linear settle.]

---

## 导航模式

---

#### Screen Push / Pop / Replace（屏幕推入/弹出/替换）

**类别**: Navigation
**状态**: Draft

These three patterns define how screens enter and exit the navigation stack.

| Pattern | Trigger | Animation | Stack Behavior | Focus Behavior |
|---------|---------|-----------|---------------|----------------|
| Push | Navigate deeper (open submenu, open detail view) | New screen slides in from right. Previous screen slides left and dims. | Previous screen remains on stack | Focus moves to first interactive element on new screen |
| Pop (Back) | Back button / Escape / B / Circle | Current screen slides right and exits. Previous screen slides in from left and brightens. | Current screen removed from stack | Focus returns to the element that triggered the Push |
| Replace | Navigate to a peer screen (not child, not parent). Loading screen. | Fade out current, fade in new. No directional bias. | Current screen removed. New screen added. | Focus moves to first interactive element on new screen |

**动画持续时间**: Push/Pop: 250ms ease-in-out. Replace: 200ms fade out + 200ms fade in.

**运动简化**: All slide animations become fades. Duration reduces to 100ms.

**实现说明**: [Godot: Implement as a `ScreenManager` singleton managing
a stack of `Control` scenes. `push(screen_scene)` instantiates and animates in.
`pop()` animates out and frees. `replace(screen_scene)` calls pop then push without
the intermediate stack state. Use `CanvasLayer` per screen to isolate input handling.
Store the "return focus" element reference before pushing so it can be restored on pop.]

---

#### Focus Management（焦点管理）

**类别**: Navigation
**状态**: Draft

> 焦点管理是游戏UI中最常见的键盘和游戏手柄无障碍设计失败点。 keyboard and gamepad accessibility failure
> in game UIs. These rules must be implemented consistently. A player should
> never be in a state where they cannot see which element is focused, or where
> Tab/D-pad produces no visible result.

| Rule | Description |
|------|-------------|
| Screen open | Focus is placed on the most logical interactive element — typically the Primary button, the first list item, or the last-focused element if the screen was previously visited. Never on a non-interactive element. |
| Screen close / pop | Focus returns to the element that triggered the navigation (the button that opened the screen, the list item that was selected). If that element no longer exists, focus goes to the nearest preceding interactive element. |
| Modal open | Focus is trapped inside the modal. See Modal Dialog pattern. |
| Modal close | Focus returns to the element that triggered the modal. |
| Element disabled | If the focused element becomes disabled, focus moves to the next available interactive element in the tab order. |
| Element destroyed | If the focused element is removed from the scene, focus moves to the nearest preceding element in the tab order. |
| Screen without interactive elements | Focus management is a no-op. Ensure back/cancel input still works. |
| Tab key (keyboard) | Moves focus forward through interactive elements in document order (left to right, top to bottom). Shift+Tab moves backward. |
| D-pad (gamepad) | Moves focus in the spatial direction pressed. Spatial navigation is preferred over strict tab order for gamepad. Never wrap focus between unrelated regions (e.g., Tab bar and content area should be separate navigation regions). |
| Focus is always visible | Focus ring or equivalent focus indicator must ALWAYS be visible when an element is focused via keyboard or gamepad. Never suppress focus indicators. |

---

#### Escape / Cancel（退出/取消）

**类别**: Navigation
**状态**: Draft

> "返回"操作是所有菜单系统中使用最频繁的导航输入。 the most-used navigation input in all menu systems.
> It must be consistent across every screen with no exceptions.

| Platform | Input | Behavior |
|----------|-------|---------|
| PC (keyboard) | Escape | Close top-most modal / go back one screen in stack / if at root screen (main menu), open "quit?" confirmation |
| PC (gamepad) | B (Xbox layout) / Circle (PS layout) | Same as Escape |
| Xbox | B button | Same as Escape |
| PlayStation | Circle button | Same as Escape |
| Nintendo Switch | B button | Same as Escape (NOTE: Nintendo uses B for confirm in some first-party titles — verify platform convention for this release and document the decision) |

**规则**: This input must never be overridden to do something other than "go back / cancel." If a screen has no back action (e.g., the game is paused and the player must make a choice), Escape does nothing or shows a "you must choose" message — it does not navigate away. Every screen must define its Escape behavior explicitly in its UX spec.

---

## 反馈与加载模式

---

#### Loading State（加载状态）

**类别**: Feedback
**状态**: Draft

| Scope | Pattern | Notes |
|-------|---------|-------|
| Full screen (initial load) | Full-screen loading screen with game art, progress bar (determinate if possible), tip text (optional). | Never use an empty black screen. Give the player something to read or look at. |
| Full screen (level transition) | Fade to black, loading screen, fade from black to new scene. | The fade removes the pop of the previous scene disappearing. |
| Component / inline | Spinner or skeleton placeholder replaces the loading component. Component does not shift layout when content loads. | Skeleton placeholder (grey boxes approximating content shape) is preferable to spinner for layout-heavy content — it prevents layout shift on load. |
| Background / async | No visual indication unless operation exceeds 2 seconds. After 2 seconds, show a small spinner or toast. | Do not show loading indicators for operations that complete in under 2 seconds — the flash of an indicator is more disruptive than waiting. |

**无障碍设计**: Loading states must announce to screen readers: "[Context] loading, please wait." Completion must announce "[Context] loaded." For full-screen loading, ensure the loading screen itself is navigable to screen readers — the tips text and any UI elements must be exposed.

---

#### Empty State（空状态）

**类别**: Feedback
**状态**: Draft

> 空状态一直是游戏UI中设计最不充分的部分。 the least-designed parts of game UIs. They are
> the difference between a player feeling "this is where I'll store my items"
> and "why is nothing here? did something break?" Every empty list and grid must
> have a designed empty state. The empty state is not an error — it is a starting
> point.

| Location | Empty State Content | Notes |
|----------|--------------------|----|
| Inventory (no items) | Icon (subtle, large, centered). Message: "Your inventory is empty." Sub-message: "Items you find on your journey will appear here." | Do not say "No items found" — "found" implies a failed search. |
| Quest Log (no active quests) | Icon. Message: "No active quests." Sub-message: "Talk to characters marked with [quest marker icon] to start a quest." | Give the player a clear action. |
| Achievements (none earned) | Icon. Message: "No achievements yet." List of hint achievements: "Try [Action] to earn your first achievement." | Gamified motivation, not just emptiness. |
| Search results (no matches) | Icon. Message: "No results for '[search term]'." Sub-message: "Try a different search or [browse all]." | Mirror the search term back at them. Give an alternative action. |

**规则**: Every empty state must include an icon, a message, and either a sub-message or an action button. A blank container with no explanation is never acceptable.

---

#### Error State（错误状态）

**类别**: Feedback
**状态**: Draft

| Error Type | Pattern | Tone |
|-----------|---------|------|
| Input validation (form field) | Inline error message below the field. Error icon left of message. Red border on field (colorblind-safe with icon). | Neutral and specific — "Username must be 3-20 characters." Not "Invalid input." |
| Operation failed (save error, network error) | Toast notification for non-critical failures. Modal Dialog for critical failures (save file cannot be written). | Calm and actionable — "Save failed. Check storage space." Not "FATAL ERROR." |
| System error (crash, data corruption) | Full-screen error screen with error code, recovery options ("Restart Game," "Load last save"), and support contact. | Reassuring — acknowledge the problem, give the player agency. Never blame the player. |
| Soft error (action cannot be performed) | Toast or inline message. | Explanatory — "Not enough gold" not "Action unavailable." |

**原则**: Error messages are never the player's fault. They are the game telling the player what happened and what to do next. Remove the word "invalid" from all error messages — replace with specific explanations.

---

## 动画标准

> 这些时间值适用于本库中的所有模式。 to ALL patterns in this library. When a pattern says
> "150ms ease-out," the easing function is defined here. Consistency in timing
> makes the UI feel like a single designed system rather than a collection of
> individual decisions.

| Animation Type | Duration (ms) | Easing Function | Notes |
|---------------|--------------|----------------|-------|
| Button hover / focus enter | 80 | ease-out | Fast — snappy, not sluggish |
| Button hover / focus exit | 60 | ease-in | Slightly faster exit than entry |
| Button press scale down | 60 | ease-in | Immediate feedback |
| Button press scale up (release) | 80 | ease-out | Slightly bouncy feel |
| Screen push (enter) | 250 | ease-in-out | Screen slides in from right |
| Screen pop (exit) | 250 | ease-in-out | Screen slides out to right |
| Modal open | 200 | ease-out | Expands from center |
| Modal close | 150 | ease-in | Collapses faster than it opens |
| Toast enter | 200 | ease-out | Slides in from screen edge |
| Toast exit | 200 | ease-in | |
| Tab switch | 150 | ease-in-out | Content cross-fades or slides |
| Tooltip appear | 120 | ease-out | After 300-400ms delay |
| Tooltip disappear | 80 | ease-in | |
| Progress bar fill | 300 | ease-out | Value changes animate smoothly |
| Value flash (damage, gain) | 100ms on + 100ms off | linear | Brief, attention-catching |
| Dialogue text reveal (per character) | 30ms per character | linear | Configurable in accessibility settings |
| HUD damage flash | 80 | linear | White or red overlay, immediate |

**Motion reduction overrides**: When motion reduction mode is enabled (see accessibility-requirements.md), all slide and scale animations are replaced with fades. Fade durations are reduced by 50%. Looping animations (indeterminate spinners, pulsing indicators) are replaced with static equivalents.

---

## 声音标准

> 每个交互事件都应有音频反馈。声音是主要的反馈通道，而不是装饰。这里定义的声音是事件类别——具体的音频资源在`docs/sound-bible.md`中定义。此表将交互事件映射到声音类别，以便声音设计师和UI程序员使用相同的词汇。

| Interaction Event | Sound Category | Notes |
|------------------|---------------|-------|
| Button hover / focus | UI Hover | Subtle, short (< 80ms), non-fatiguing on rapid navigation. Hades uses a very quiet, high-frequency click that disappears into background on rapid nav. |
| Button (Primary) confirm | UI Confirm — Primary | Slightly more prominent than secondary confirm. The "yes, let's go" sound. |
| Button (Secondary) cancel / back | UI Cancel | Subtly downward in pitch. The "going back" sound. Mass Effect uses a clean, distinct swoosh for back navigation. |
| Button (Destructive) — opening confirmation | UI Warning | Distinct from standard confirm. Brief attention-catching sound. |
| Confirmation dialog — confirm destructive | UI Confirm — Destructive | Final, slightly weighted. The action is being taken. |
| Toggle ON | UI Toggle On | Brief, snappy, slightly bright. Celeste's accessibility toggles have a satisfying click-on sound. |
| Toggle OFF | UI Toggle Off | Same click family, slightly flatter. |
| Slider adjust | UI Slider | Subtle continuous sound while dragging. A single click per D-pad step. Never fatiguing. |
| Dropdown open | UI Expand | Brief, directional (opening feel). |
| Dropdown close / select | UI Select | Confirmation feel. |
| Tab switch | UI Tab | Horizontal movement feel. Distinct from vertical navigation. |
| Modal open | UI Modal Open | More prominent than standard navigation — draws attention. |
| Modal close (cancel) | UI Modal Close | Returns to previous context. |
| Toast — informational | UI Notification | Background-level, non-intrusive. |
| Toast — achievement | UI Achievement | Celebratory but not overlong. The player should feel rewarded, not interrupted. |
| Toast — warning | UI Warning — Toast | Distinct from error. Alert, not alarming. |
| Error state | UI Error | Friendly but clear. Not a harsh buzzer. Dark Souls uses a subtle dull thud for failed actions — communicates "no" without being harsh. |
| Success confirmation | UI Success | Clean and satisfying. |
| Ability activate | Gameplay — Ability Activate | In-world feel, distinct from pure UI. Part of game feel, not menu feel. |
| Damage received | Gameplay — Damage | See sound-bible.md for full specification. |
| Item pickup | Gameplay — Item Acquire | Brief, rewarding. |
| Level up / rank up | Gameplay — Progression | Celebratory, appropriately prominent. |
| Dialogue advance | UI Dialogue | Subtle, matches typewriter rhythm if typewriter is active. |

---

## 待解决问题

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| [Does the engine's accessibility node system support screen reader announcements for toast notifications without requiring focus? Verify against engine-reference/godot/ for Godot 4.6.] | [ux-designer] | [Before first menu implementation] | [Unresolved] |
| [What is the platform-correct confirm/cancel button mapping for Nintendo Switch release? Nintendo first-party convention differs from Xbox/PlayStation.] | [producer] | [Before platform certification submission] | [Unresolved] |
| [Should damage numbers be pooled as Label3D nodes or rendered in a SubViewport? Verify performance budget in coordination with technical-director.] | [lead-programmer, ux-designer] | [Before combat HUD implementation] | [Unresolved] |
| [What is the maximum number of simultaneous toast notifications before the queue becomes visually overwhelming? Needs playtesting.] | [ux-designer] | [First playtesting session] | [Unresolved] |
| [Add question] | [Owner] | [Deadline] | [Resolution] |
