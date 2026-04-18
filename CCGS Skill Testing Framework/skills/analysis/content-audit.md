# Skill Test Spec: /content-audit

## 技能概述

`/content-audit` 读取 `design/gdd/` 中的 GDD 文件，检查其中指定的所有内容项（敌人、物品、关卡等）是否在 `assets/` 中都有对应。它生成一个差距表：内容类型 → 指定数量 → 找到数量 → 缺失项。不调用任何 director gate。该技能在未经用户批准的情况下不会写入文件。裁决结果：COMPLETE、GAPS FOUND 或 MISSING CRITICAL CONTENT。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT
- [ ] 不需要 "May I write" 语言（只读输出；写入是可选的报告）
- [ ] 具有下一步交接（差距表审查后要做什么）

---

## Director Gate 检查

无。Content audit 是一个只读分析技能；不调用任何 gate。

---

## 测试用例

### 用例 1：理想路径 — 所有指定内容都存在

**测试夹具：**
- `design/gdd/enemies.md` 指定 4 种敌人类型：Grunt、Sniper、Tank、Boss
- `assets/art/characters/` 包含文件夹：`grunt/`、`sniper/`、`tank/`、`boss/`
- `design/gdd/items.md` 指定 3 种物品类型；所有 3 种都在 `assets/data/items/` 中找到

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 `design/gdd/` 中的所有 GDD 文件
2. 技能扫描 `assets/` 中的每个指定内容项
3. 找到所有 4 种敌人类型和 3 种物品类型
4. 差距表显示：所有行的找到数量 = 指定数量，无缺失项
5. 裁决结果为 COMPLETE

**断言：**
- [ ] 差距表涵盖 GDD 中找到的所有内容类型
- [ ] 每行显示指定数量和找到数量
- [ ] 当数量匹配时无缺失项
- [ ] 裁决结果为 COMPLETE
- [ ] 未写入任何文件

---

### 用例 2：发现差距 — 敌人类型在 assets 中缺失

**测试夹具：**
- `design/gdd/enemies.md` 指定 3 种敌人类型：Grunt、Sniper、Boss
- `assets/art/characters/` 包含：仅 `grunt/`、`sniper/`（Boss 文件夹缺失）

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD — 找到 3 种指定的敌人类型
2. 技能扫描 `assets/art/characters/` — 仅找到 2 种
3. 敌人行的差距表：指定 3，找到 2，缺失：Boss
4. 裁决结果为 GAPS FOUND

**断言：**
- [ ] 差距表行通过名称标识 "Boss" 为缺失项
- [ ] 显示指定数量（3）和找到数量（2）
- [ ] 当任何内容项缺失时，裁决结果为 GAPS FOUND
- [ ] 技能不假设资产稍后会添加 — 立即标记

---

### 用例 3：未找到 GDD 内容规范 — 提供指导

**测试夹具：**
- `design/gdd/` 仅包含 `core-loop.md`，其中没有内容清单部分
- 不存在其他包含内容规范的 GDD 文件

**输入：** `/content-audit`

**预期行为：**
1. 技能读取所有 GDD — 未找到内容清单部分
2. 技能输出："No content specifications found in GDDs — run /design-system first to define content lists"
3. 不生成差距表
4. 裁决结果为 GAPS FOUND（没有规范无法确认完整性）

**断言：**
- [ ] 当不存在 GDD 内容规范时，技能不生成差距表
- [ ] 输出建议运行 `/design-system`
- [ ] 裁决反映无法确认完整性

---

### 用例 4：边界情况 — 资产格式与目标平台不匹配

**测试夹具：**
- `design/gdd/audio.md` 指定音频资产为 OGG 格式
- `assets/audio/sfx/jump.wav` 存在（WAV 格式，非 OGG）
- `assets/audio/sfx/land.ogg` 存在（正确格式）
- `technical-preferences.md` 指定音频格式：OGG

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 音频规范和格式要求的技术偏好
2. 技能找到 `jump.wav` — 存在但格式错误
3. 音频行的差距表：指定 2，找到 2（按名称），但 `jump.wav` 标记为 FORMAT ISSUE
4. 裁决结果为 GAPS FOUND（格式合规性是内容完整性的一部分）

**断言：**
- [ ] 当指定格式时，技能根据 GDD 或技术偏好检查资产格式
- [ ] `jump.wav` 标记为 FORMAT ISSUE，并注明预期格式（OGG）
- [ ] 格式问题在差距表中与缺失内容区分开
- [ ] 当存在格式问题时，裁决结果为 GAPS FOUND

---

### 用例 5：Gate 合规性 — 只读；无 gate；差距表供人工审查

**测试夹具：**
- GDD 指定 10 个内容项；在 assets 中找到 9 个；缺失 1 个
- `review-mode.txt` 包含 `full`

**输入：** `/content-audit`

**预期行为：**
1. 技能读取 GDD 并扫描 assets；生成差距表
2. 无论审查模式如何，都不调用 director gate
3. 技能将差距表作为只读输出呈现给用户
4. 裁决结果为 GAPS FOUND
5. 技能提供写入审计报告的选项，但不自动写入

**断言：**
- [ ] 在任何审查模式下都不调用 director gate
- [ ] 差距表呈现时不自动写入任何文件
- [ ] 提供可选报告写入但不强制
- [ ] 技能不修改任何资产文件

---

## 协议合规性

- [ ] 在生成差距表之前读取 GDD 和资产目录
- [ ] 差距表显示内容类型、指定数量、找到数量、缺失项
- [ ] 未经明确用户批准不写入文件
- [ ] 不调用任何 director gate
- [ ] 裁决结果为以下之一：COMPLETE、GAPS FOUND、MISSING CRITICAL CONTENT

---

## 覆盖范围说明

- MISSING CRITICAL CONTENT 裁决（相对于 GAPS FOUND）在缺失项在 GDD 中被标记为关键时触发；这未明确测试但遵循相同的检测路径。
- 未测试 `assets/` 目录不存在的情况；技能将为所有指定项生成 MISSING CRITICAL CONTENT 裁决。