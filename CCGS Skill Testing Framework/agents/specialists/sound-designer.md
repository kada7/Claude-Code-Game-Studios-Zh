# Agent 测试规范：sound-designer

## Agent 概述
领域：SFX 规范、音频事件、混音参数和声音类别定义。
不负责：音乐创作方向（audio-director）、音频系统的代码实现。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] `description:` 字段存在且领域特定（引用 SFX / 音频事件 / 混音）
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Glob, Grep — 不包含引擎代码执行工具
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对音乐方向或音频代码实现拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "Create an SFX spec for a sword swing attack."
**预期行为：**
- 生成完整的音频事件规范，包括：
  - 事件名称（例如：`sfx_combat_sword_swing`）
  - 变体数量（至少 3 个以避免重复疲劳）
  - 音高范围（例如：±8% 随机化）
  - 音量范围和归一化目标（例如：-12 dBFS）
  - 声音类别（例如：`combat_sfx`）
  - 建议的分层说明（风声层 + 冲击瞬态）
- 如果已建立项目音频命名约定，则输出遵循该约定

### 用例 2：领域外请求 — 正确重定向
**输入：** "Compose a looping ambient music track for the forest level."
**预期行为：**
- 不生成音乐创作方向或音乐简报
- 明确说明音乐方向属于 `audio-director`
- 将请求重定向到 `audio-director`
- 可以注明一旦音乐方向确定，它可以提供 SFX 环境层规范（风声、野生动物声）来补充音乐

### 用例 3：动态参数 — 衰减曲线规范
**输入：** "The sword swing SFX needs distance falloff so it sounds different across the arena."
**预期行为：**
- 生成动态参数规范，包括：
  - 参数名称（例如：`distance` 或 `listener_distance`）
  - 衰减曲线类型（例如：对数、线性、自定义）
  - 近/远距离阈值及相应的音量和高频衰减值
  - 遮挡覆盖行为（如果适用）
- 不编写音频引擎集成代码（委托给适当的程序员）

### 用例 4：命名约定冲突
**输入：** "Add a new SFX event called `SWORD_HIT_1` for the melee system."
**预期行为：**
- 识别 `SWORD_HIT_1` 与已建立的事件命名约定冲突（带类别前缀的 snake_case，例如：`sfx_combat_sword_hit`）
- 不静默注册不符合约定的名称
- 向 `audio-director` 标记冲突并提供建议的合规替代方案
- 一旦 audio-director 确认，将继续使用修正后的名称

### 用例 5：上下文传递 — 使用音频风格指南
**输入：** Audio style guide provided in context specifying: "gritty, grounded, no reverb tails over 1.5s, reference: The Witcher 3 combat audio." Request: "Create SFX specs for the full melee combat suite."
**预期行为：**
- 在规范原理中引用 "gritty, grounded" 音调描述符
- 如所述，将所有混响尾音规范限制在 1.5 秒内
- 将参考材料（The Witcher 3）作为混音电平和瞬态设计的基准
- 不生成与风格指南相矛盾的规范（例如：不生成空灵或重度混响处理的规范）

---

## 协议合规性

- [ ] 保持在声明的领域内（SFX 规范、事件定义、混音参数）
- [ ] 将音乐方向请求重定向到 audio-director
- [ ] 返回结构化的音频事件规范（事件名称、变体、音高、音量、类别）
- [ ] 不生成音频系统实现的代码
- [ ] 标记命名约定违规，而不是静默接受不符合约定的名称
- [ ] 在所有规范输出中引用提供的风格指南和约束

---

## 覆盖范围说明
- SFX 规范格式（用例 1）应匹配音频中间件（Wwise/FMOD/内置）所需的事件模式
- 衰减曲线（用例 3）验证 Agent 生成可立即实现的参数规范
- 风格指南合规性（用例 5）确认 Agent 读取提供的上下文并相应约束输出
