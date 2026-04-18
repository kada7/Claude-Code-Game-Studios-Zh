# 示例会话：UX 流程 — /ux-design → /ux-review → /team-ui

**上下文：** 独立开发者，预生产阶段。HUD 和库存界面是首批要设计的 UI。游戏有玩家旅程文档以及库存和战斗的 GDD。

**起始状态：**
- `design/gdd/inventory-system.md` — 完整
- `design/gdd/combat-system.md` — 完整
- `design/player-journey.md` — 完整（定义了 6 阶段弧线）
- 尚无 UX 规格
- `design/ux/` 目录不存在

**会话时长：** ~90 分钟，跨两个会话（HUD 设计，然后库存界面）
**轮次：** 16
**结果：** `design/ux/hud.md` 和 `design/ux/screens/inventory.md` 已创建并评审；team-ui 已交接进行视觉实现

---

## Part 1：使用 /ux-design 进行 HUD 设计

### Turn 1：用户开始 HUD 设计

**用户：**
> /ux-design hud

### Turn 2：Agent 加载上下文并呈现方案

**Agent（ux-designer，通过 /ux-design）：**
> 开始 HUD 设计。加载上下文...
>
> - 读取 `design/player-journey.md` — 关键状态：平静探索、紧张（检测到威胁）、危机（低 HP/耐力）、战斗
> - 读取 `design/gdd/combat-system.md` — HUD 需要：HP 条、耐力条、主动技能冷却时间（最多 3 个）、伤害数字
> - 读取 `design/gdd/inventory-system.md` — HUD 需要：快捷栏（4 个槽位）、当前物品指示器
>
> **HUD 理念问题：** 游玩期间玩家的主要注意力焦点是什么？
>
> 这决定了 HUD 应该有多强势：
> - **选项 A：Diegetic（低存在感）** — 仅在受伤时显示 HP，仅在消耗时显示耐力。世界优先，HUD 除非紧急否则退后。
> - **选项 B：Persistent minimal（持续最小化）** — HP 和耐力始终可见，小而不起眼。快速参考，无需模式切换。
> - **选项 C：Full tactical（全战术）** — 所有信息始终可见（HP、耐力、冷却时间、地图、库存槽位）。玩家始终拥有完全感知。
>
> 鉴于你的生存游戏和"孤独幸存者"幻想，A 或 B 与类型最一致。

**用户：**
> B — 我希望它始终在那里但最小化。玩家始终在管理资源。

### Turn 3：Agent 起草 HUD 理念章节

**Agent：**
> **HUD 理念草稿：**
>
> > **方案：Persistent Minimal**
> > HUD 始终可见但占据最小屏幕空间。玩家是一名资源管理的幸存者 — 隐藏 HP/耐力可见性会造成挫败感，而非紧张感。所有关键状态一目了然，不会打断探索焦点。当元素变得紧急时，视觉权重会缩放（HP 低于 30% 时脉动，耐力为 0 时闪烁），然后返回最小状态。
>
> 我可以将此作为 Philosophy 章节写入 `design/ux/hud.md` 吗？

**用户：**
> 是

**Agent 创建 `design/ux/hud.md` 并写入 Philosophy 章节。**

*（第 4-7 轮继续逐节进行 HUD 编写：Info Architecture、Zones、Element Specs、State Machine、Visual Budget、Platform Adaptation — 每个都起草、批准并写入文件。）*

---

**所有章节完成后的最终 HUD 结构：**

```
design/ux/hud.md
  - Philosophy: Persistent Minimal
  - Info Architecture: HP（左上）、Stamina（HP 下方左上）、Quick Slots（底部居中）、
    Ability Cooldowns（右下）、Damage Numbers（世界空间）
  - Zones: 4 个已定义（左上生命体征、底部居中交互、右下能力、世界空间）
  - Element Specs: 6 个元素，含尺寸、字体大小、不透明度规则
  - State Machine: Calm / Tension / Crisis / Combat（4 个状态，过渡触发器）
  - Visual Budget: 最大 8% 屏幕覆盖，3 个同时动画
  - Platform Adaptation: Controller（添加瞄准准星）、Mobile（v1 范围外）
```

---

## Part 2：使用 /ux-design 进行库存界面设计

### Turn 8：用户开始库存界面

**用户：**
> /ux-design screen inventory

### Turn 9：Agent 扫描 GDD 和玩家旅程

**Agent：**
> 为库存界面加载上下文...
>
> 来自 `design/gdd/inventory-system.md`：
> - 网格库存，6×8 槽位
> - 物品有重量（影响移动）和堆叠大小
> - 玩家可以装备、丢弃、检查、拆分堆叠
>
> 来自 `design/player-journey.md`：
> - 库存经常在平静探索期间打开
> - 玩家打开库存时应感到"有条理且掌控"
> - 焦虑时刻："我需要决定丢弃什么" — 应该清晰，不恐慌
>
> **玩家需求（来自旅程）：** *我需要快速评估携带了什么，决定保留或丢弃什么，然后回到世界中。*
>
> **关键设计问题：** 玩家如何导航到库存操作？
> - **选项 A：右键上下文菜单** — 悬停物品 → 右键 → 菜单出现（Escape/常见）
> - **选项 B：拖拽式** — 拖拽到丢弃区以丢弃；拖拽到装备槽以装备（Stardew Valley）
> - **选项 C：检查面板** — 点击物品 → 右侧出现详情面板，带操作按钮

**用户：**
> B — 拖拽式。我想要触感。

*（第 10-12 轮继续逐节进行库存界面规格编写：Player Need、Layout Zones、States、Interaction Map、Data Requirements、Events Fired、Accessibility、Localization。）*

---

## Part 3：/ux-review

### Turn 13：用户运行评审

**用户：**
> /ux-review design/ux/

### Turn 14：Agent 评审两份文档

**Agent（通过 /ux-review）：**
> 评审 `design/ux/` 中的所有 UX 规格...
>
> ---
> **HUD 评审（`hud.md`）：**
>
> | 检查 | 状态 | 备注 |
> |-------|--------|-------|
> | GDD 对齐 — 所有必需元素已存在 | ✅ | HP、耐力、快捷槽、冷却时间都已规格化 |
> | 状态机覆盖 | ✅ | 覆盖所有 4 个游玩状态 |
> | 无障碍层级 | ⚠️ | HP/耐力条未指定色盲模式（红/黄惯例） |
> | 视觉预算 | ✅ | 8% 屏幕覆盖，在预算内 |
> | 平台备注 | ✅ | Controller 变体已记录 |
>
> **库存界面评审（`screens/inventory.md`）：**
>
> | 检查 | 状态 | 备注 |
> |-------|--------|-------|
> | Player Need 已声明 | ✅ | |
> | 所有 GDD 操作已覆盖 | ✅ | Equip、drop、inspect、split 都在交互地图中 |
> | 拖放交互已完全规格化 | ⚠️ | 库存已满时的放置目标行为未定义 — 会发生什么？ |
> | 无障碍：拖拽的键盘替代方案 | ❌ | 缺失 — 仅有拖拽无键盘路径，违反运动无障碍 |
> | 本地化：所有字符串已标记 | ✅ | |
> | 数据事件已触发 | ✅ | `item_equipped`、`item_dropped`、`stack_split` 都已映射 |
>
> ---
> **裁决：需要修改**
>
> 两个问题必须在交接给 /team-ui 前解决：
>
> 1. **阻塞（无障碍）：** 库存界面没有拖拽的键盘替代方案。运动无障碍需要非拖拽交互路径。添加"按 X 拾取 / 再按 X 放置"切换，或带键盘可操作按钮的详情面板。
>
> 2. **建议（HUD）：** HP/耐力条仅使用颜色传达状态。添加次要指示器（形状、图标或图案）供色盲用户使用。可在视觉阶段解决。
> 3. **建议（库存）：** 库存已满时的丢弃行为未指定。在实现前在 GDD 中解决，或记录为范围外。

### Turn 15：用户解决阻塞问题

**用户：**
> 对于键盘：按 F 拾取光标处的物品，再按 F 在目标槽位放置。添加到库存规格中。

**Agent：**
> 在 Interaction Map 的"Keyboard / Controller Path"下添加：
>
> > 按 F（或 South 按钮）拾取光标处的物品。物品进入"持有"状态，带视觉指示器。在目标槽位再次按 F 放置。按 Escape 取消并返回物品。
>
> 我可以将此写入 `design/ux/screens/inventory.md` 并重新运行无障碍检查吗？

**用户：**
> 是

**Agent 写入更新。重新检查无障碍 — 现在通过。**

---

## Part 4：交接给 /team-ui

### Turn 16：用户启动 Team UI

**用户：**
> /team-ui

**Agent（通过 /team-ui）：**
> 运行 UX 流程上下文检查...
>
> - `design/ux/hud.md` — 已评审 ✅
> - `design/ux/screens/inventory.md` — 已评审 ✅
> - `/ux-review` 裁决：需要修改 已解决 — 当前状态：已批准 ✅
>
> 进入 **Phase 2：视觉设计**
>
> 交接给 `art-director` 进行视觉规格（色彩调色板、字体、图标与 art bible 对齐）...
>
> *（team-ui 继续通过视觉设计 → 布局实现 → 无障碍审计 → 最终评审）*

---

## 此示例演示了什么

- **上下文驱动设计**：Agent 读取 player-journey.md 以将 HUD 决策扎根于玩家情绪状态，而非仅仅是功能列表
- **UX 评审是硬门槛**：`/team-ui` 在进入视觉设计前检查是否有通过的 `/ux-review`
- **无障碍提前捕获**：缺失的键盘替代方案被评审标记，而非在最后一周被 QA 测试员发现
- **阻塞 vs. 建议**：缺失的键盘路径是阻塞（阻止交接）；色盲颜色是建议（可在视觉阶段修复）
- **逐节 UX 编写**：与 `/design-system` 相同的增量模式 — 每节在继续前写入文件
- **分开的 HUD 和界面文件**：`design/ux/hud.md` 是全游戏 HUD；每屏规格存放在 `design/ux/screens/`
- **/team-ui 强制执行的模式库**：此会话后，库存拖放成为 `design/ux/interaction-patterns.md` 中的文档化模式，供所有未来界面引用
