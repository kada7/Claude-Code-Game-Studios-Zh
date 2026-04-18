# 技能测试规范: /asset-audit

## 技能摘要

`/asset-audit` 审计 `assets/` 目录的命名规范合规性、缺失的元数据以及格式/大小问题。它根据 `technical-preferences.md` 中定义的规范和预算读取资产文件。不调用任何总监关卡。该技能未经用户批准不会写入。裁决结果：COMPLIANT、WARNINGS 或 NON-COMPLIANT。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLIANT、WARNINGS、NON-COMPLIANT
- [ ] 不需要 "May I write" 语言（只读；可选报告需要批准）
- [ ] 具有下一步交接（审计结果后该做什么）

---

## 总监关卡检查

无。资产审计是只读分析技能；不调用任何关卡。

---

## 测试用例

### 用例 1: 理想路径 — 所有资产遵循命名规范

**测试夹具:**
- `technical-preferences.md` 指定命名规范：`snake_case`，例如 `enemy_grunt_idle.png`
- `assets/art/characters/` 包含：`enemy_grunt_idle.png`、`enemy_sniper_run.png`
- `assets/audio/sfx/` 包含：`sfx_jump_land.ogg`、`sfx_item_pickup.ogg`
- 所有文件都在大小预算内（纹理 ≤2MB，音频 ≤500KB）

**输入:** `/asset-audit`

**预期行为:**
1. 技能从 `technical-preferences.md` 读取命名规范和大小预算
2. 技能递归扫描 `assets/` 目录
3. 所有文件匹配 `snake_case` 规范；所有文件都在预算内
4. 审计表格显示所有行 PASS
5. 裁决结果为 COMPLIANT

**断言:**
- [ ] 审计覆盖艺术和音频资产目录
- [ ] 每个文件都根据命名规范和大小预算进行检查
- [ ] 合规时所有行显示 PASS
- [ ] 裁决结果为 COMPLIANT
- [ ] 没有文件被写入

---

### 用例 2: 不合规 — 纹理超出大小预算

**测试夹具:**
- `assets/art/environment/` 包含 5 个纹理文件
- 3 个纹理文件各为 4MB（预算：≤2MB）
- 2 个纹理文件在预算内

**输入:** `/asset-audit`

**预期行为:**
1. 技能从 `technical-preferences.md` 读取大小预算（纹理为 2MB）
2. 技能扫描 `assets/art/environment/` — 发现 3 个过大的纹理
3. 审计表格列出每个过大的文件，包含实际大小和预算
4. 裁决结果为 NON-COMPLIANT
5. 技能为标记的文件推荐压缩或分辨率降低

**断言:**
- [ ] 所有 3 个过大的文件都按名称列出，包含实际大小和预算大小
- [ ] 当任何文件超出其预算时，裁决结果为 NON-COMPLIANT
- [ ] 为过大的文件提供优化建议
- [ ] 预算内的文件也列出（显示 PASS）以确保完整性

---

### 用例 3: 格式问题 — 音频格式错误

**测试夹具:**
- `technical-preferences.md` 指定音频格式：OGG
- `assets/audio/music/theme_main.wav` 存在（WAV 格式）
- `assets/audio/sfx/sfx_footstep.ogg` 存在（正确的 OGG 格式）

**输入:** `/asset-audit`

**预期行为:**
1. 技能读取音频格式要求：OGG
2. 技能扫描 `assets/audio/` — 发现 `theme_main.wav` 格式错误
3. 审计表格将 `theme_main.wav` 标记为 FORMAT ISSUE（预期 OGG，发现 WAV）
4. `sfx_footstep.ogg` 显示 PASS
5. 裁决结果为 WARNINGS（格式问题可纠正）

**断言:**
- [ ] `theme_main.wav` 被标记为 FORMAT ISSUE，并注明预期和实际格式
- [ ] 对于格式问题，裁决结果为 WARNINGS（不是 NON-COMPLIANT），因为格式问题可纠正
- [ ] 正确格式的资产显示为 PASS
- [ ] 技能不修改或转换任何资产文件

---

### 用例 4: 缺失资产 — GDD 引用的资产在 assets/ 中不存在

**测试夹具:**
- `design/gdd/enemies.md` 引用 `enemy_boss_idle.png`
- `assets/art/characters/boss/` 目录为空 — 文件不存在

**输入:** `/asset-audit`

**预期行为:**
1. 技能读取 GDD 引用以查找预期资产（与 `/content-audit` 范围交叉引用）
2. 技能扫描 `assets/art/characters/boss/` — 文件未找到
3. 审计表格将 `enemy_boss_idle.png` 标记为 MISSING ASSET
4. 裁决结果为 NON-COMPLIANT（缺少关键艺术资产）

**断言:**
- [ ] 技能检查 GDD 引用以识别预期资产
- [ ] 缺失的资产被标记为 MISSING ASSET，并注明 GDD 引用
- [ ] 当关键资产缺失时，裁决结果为 NON-COMPLIANT
- [ ] 技能不创建或添加占位符资产

---

### 用例 5: 关卡合规性 — 无关卡；可单独咨询技术美术师

**测试夹具:**
- 2 个文件有命名规范违规（CamelCase 而不是 snake_case）
- `review-mode.txt` 包含 `full`

**输入:** `/asset-audit`

**预期行为:**
1. 技能扫描资产并发现 2 个命名违规
2. 无论审查模式如何，都不调用总监关卡
3. 裁决结果为 WARNINGS
4. 输出注明："考虑让技术美术师审查命名规范"
5. 技能呈现发现结果；提供可选的审计报告写入
6. 如果用户选择："May I write to `production/qa/asset-audit-[date].md`?"

**断言:**
- [ ] 在任何审查模式下都不调用总监关卡
- [ ] 建议技术美术师咨询（非强制）
- [ ] 在任何写入提示之前呈现发现结果表格
- [ ] 可选的审计报告写入在写入前询问 "May I write"

---

## 协议合规性

- [ ] 从 `technical-preferences.md` 读取命名规范、格式和大小预算
- [ ] 递归扫描 `assets/` 目录
- [ ] 审计表格显示文件名、检查类型、预期值、实际值和结果
- [ ] 不修改任何资产文件
- [ ] 不调用任何总监关卡
- [ ] 裁决结果为以下之一：COMPLIANT、WARNINGS、NON-COMPLIANT

---

## 覆盖范围说明

- 元数据检查（例如 Godot `.import` 文件中缺失的纹理导入设置）未在此处明确测试；它们遵循相同的 FORMAT ISSUE 标记模式。
- `/asset-audit` 和 `/content-audit` 之间的交互（两者都检查 GDD 引用与资产）是故意重叠的；`/asset-audit` 侧重于合规性，而 `/content-audit` 侧重于完整性。