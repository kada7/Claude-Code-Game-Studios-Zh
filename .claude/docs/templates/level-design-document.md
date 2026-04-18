# 关卡: [Level Name]

## 快速参考

- **地区/区域**: [Where in the game world]
- **类型**: [Combat / Exploration / Puzzle / Hub / Boss / Mixed]
- **预计游玩时间**: [X-Y minutes]
- **难度**: [1-10 relative scale]
- **先决条件**: [What the player must have done to reach this level]
- **状态**: [Concept | Layout | Graybox | Art Pass | Polish | Final]

## 叙事语境

- **故事时刻**: [Where in the narrative arc does this level occur]
- **叙事目的**: [What story beat this level delivers]
- **情感目标**: [What the player should feel during this level]
- **背景发现**: [What world-building the player can find here]

## 布局

### 概览地图

```
[ASCII diagram of the level layout. Use these symbols:]
[S] = 起点
[E] = 终点/出口
[C] = 战斗遭遇
[P] = 谜题
[R] = 奖励/战利品
[!] = 故事节点
[?] = 秘密/可选内容
[>] = 单向通道
[=] = 双向通道
[@] = NPC
[B] = Boss遭遇
```

### 关键路径

[通过关卡的强制路线，逐步说明。]

1. 玩家从 [S] 进入
2. [路径上发生的事件描述]
3. 玩家从 [E] 退出

### 可选路径

| 路径 | 访问要求 | 奖励 | 发现提示 |
|------|-------------------|--------|---------------|

### 兴趣点

| 位置 | 类型 | 描述 | 目的 |
|----------|------|-------------|---------|

## 遭遇

### 战斗遭遇

| ID | 位置 | 敌人组成 | 难度 | 场景备注 |
|----|----------|------------------|-----------|-------------|
| E-01 | [Map ref] | [2x Grunt, 1x Ranged] | 3/10 | 开放区域，两侧有掩体 |
| E-02 | [Map ref] | [1x Elite, 3x Grunt] | 5/10 | 狭窄走廊，无法撤退 |

### 非战斗遭遇

| ID | 位置 | 类型 | 描述 | 解决提示 |
|----|----------|------|-------------|---------------|

## 节奏图表

```
Intensity
10 |                              *
 8 |                         *   * *
 6 |            *  *        * * *   *
 4 |     *  *  * ** *   *  *
 2 | * ** ** *        * * *          *
 0 |S-----------------------------------------E
     [Start]    [Mid]              [Climax] [Exit]
```

[描述预期节奏：高峰、低谷、休息点在哪里？]

## 音频指导

| 区域/时刻 | 音乐轨道 | 环境音 | 关键音效 |
|-------------|------------|----------|---------|
| [Entry] | [Track] | [Ambient sounds] | [Door opening] |
| [Combat] | [Combat music] | [Muted ambience] | [Combat SFX] |
| [Post-combat] | [Calm transition] | [Return to ambience] | |

## 视觉指导

- **光照**: [Key, fill, ambient description]
- **调色板**: [Dominant colors and why]
- **情绪板参考**: [Description of visual references]
- **地标**: [Visible navigation aids and their locations]
- **视线**: [What the player should see from key positions]

## 收藏品与秘密

| 物品 | 位置 | 可见性 | 提示 | 用于 |
|------|----------|-----------|------|-------------|

## 技术备注

- **预计对象数量**: [N]
- **流式区域**: [Where to break the level for streaming]
- **性能考虑**: [Any known heavy areas]
- **必需系统**: [What game systems are active in this level]