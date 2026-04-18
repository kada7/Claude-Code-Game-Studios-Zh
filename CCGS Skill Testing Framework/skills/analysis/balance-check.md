# 技能测试规范：/balance-check

## 技能摘要

`/balance-check` 读取平衡数据文件（位于 `assets/data/` 中的 JSON 或 YAML 文件）并
根据在 `design/gdd/` 下的 GDD 中定义的设计公式检查每个值。
它生成一个包含以下列的发现表：值 → 公式 → 偏差 → 严重性。
不调用导演关卡（只读分析）。该技能可以选择性地写入
平衡报告，但在执行前会询问"我可以写入吗"。判定结果：BALANCED（平衡）、
CONCERNS（关注点）或 OUT OF BALANCE（失衡）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：BALANCED、CONCERNS、OUT OF BALANCE
- [ ] 包含 "May I write" 语言（可选报告写入）
- [ ] 具有下一步交接（在审查发现后要做什么）

---

## 导演关卡检查

无。平衡检查是只读分析技能；不调用任何关卡。

---

## 测试用例

### Case 1: 理想路径 — 所有平衡值均在公式容差范围内

**Fixture:**
- `assets/data/combat-balance.json` 存在，包含 6 个统计值
- `design/gdd/combat-system.md` 包含所有 6 个统计值的公式，容差为 ±10%
- 所有 6 个值均在容差范围内

**Input:** `/balance-check`

**Expected behavior:**
1. 技能读取 `assets/data/` 中的所有平衡数据文件
2. 技能从 `design/gdd/` 读取 GDD 公式
3. 技能计算每个值相对于其公式的偏差
4. 所有偏差均在 ±10% 容差范围内
5. 技能输出发现表，所有行显示 PASS
6. 判定结果为 BALANCED

**Assertions:**
- [ ] 为所有检查的值显示发现表
- [ ] 每一行显示：统计名称、公式目标、实际值、偏差百分比
- [ ] 所有行在容差范围内显示 PASS 或等效标识
- [ ] 判定结果为 BALANCED
- [ ] 未经用户批准不写入任何文件

---

### Case 2: 失衡 — 玩家伤害超出公式目标 40%

**Fixture:**
- `assets/data/combat-balance.json` 包含 `player_damage_base: 140`
- `design/gdd/combat-system.md` 公式指定 `player_damage_base = 100` (±10%)
- 所有其他统计值均在容差范围内

**Input:** `/balance-check`

**Expected behavior:**
1. 技能读取 combat-balance.json 并计算 `player_damage_base` 的偏差
2. 偏差为 +40% — 远超出 ±10% 容差范围
3. 技能在发现表中将此行标记为严重性 HIGH
4. 判定结果为 OUT OF BALANCE
5. 技能在表格前突出显示 HIGH 严重性项目

**Assertions:**
- [ ] `player_damage_base` 行显示偏差为 +40%
- [ ] 当偏差超过容差 2 倍以上时，严重性为 HIGH
- [ ] 当任何统计值具有 HIGH 严重性偏差时，判定结果为 OUT OF BALANCE
- [ ] HIGH 严重性项目被明确标注，而非隐藏在表格行中

---

### Case 3: 无 GDD 公式 — 无法验证，提供指导

**Fixture:**
- `assets/data/economy-balance.yaml` 存在，包含 10 个统计值
- `design/gdd/` 中没有 GDD 包含经济统计值的公式定义

**Input:** `/balance-check`

**Expected behavior:**
1. 技能读取平衡数据文件
2. 技能在 GDD 中搜索公式定义 — 未找到经济统计值的公式
3. 技能输出："Cannot validate economy stats — no formulas defined. Run /design-system first."
4. 不为经济统计值生成发现表
5. 判定结果为 CONCERNS（数据存在但无法验证）

**Assertions:**
- [ ] 当 GDD 中不存在公式目标时，技能不会虚构公式目标
- [ ] 输出明确命名缺失的公式来源
- [ ] 输出建议运行 `/design-system` 来定义公式
- [ ] 判定结果为 CONCERNS（非 BALANCED，因为无法验证）

---

### Case 4: 孤儿引用 — 平衡文件引用了未定义的统计值

**Fixture:**
- `assets/data/combat-balance.json` 包含一个统计值 `legacy_armor_mult: 1.5`
- `design/gdd/combat-system.md` 中没有 `legacy_armor_mult` 的公式
- 所有其他统计值都有公式定义并通过验证

**Input:** `/balance-check`

**Expected behavior:**
1. 技能从 combat-balance.json 读取所有统计值
2. 技能在任何 GDD 中都找不到 `legacy_armor_mult` 的公式
3. 技能在发现表中将 `legacy_armor_mult` 标记为 ORPHAN REFERENCE
4. 其他统计值正常评估；在容差范围内的统计值显示 PASS
5. 判定结果为 CONCERNS（孤儿引用阻止了完整验证）

**Assertions:**
- [ ] `legacy_armor_mult` 以状态 ORPHAN REFERENCE 出现在发现表中
- [ ] 孤儿引用在表中与公式偏差区分开来
- [ ] 当发现任何孤儿引用时，判定结果为 CONCERNS
- [ ] 技能不会静默跳过孤儿统计值

---

### Case 5: 关卡合规性 — 只读；无关卡；可选报告需要批准

**Fixture:**
- 存在平衡数据和 GDD 公式；1 个统计值具有 CONCERNS 级别偏差（超出目标 15%）
- `review-mode.txt` 包含 `full`

**Input:** `/balance-check`

**Expected behavior:**
1. 技能读取数据和 GDD；生成发现表
2. 判定结果为 CONCERNS（一个统计值略微超出范围）
3. 不调用任何导演关卡
4. 技能向用户呈现发现表
5. 技能提供写入可选平衡报告的机会
6. 如果用户同意：技能询问 "May I write to `production/qa/balance-report-[date].md`?"
7. 如果用户拒绝：技能结束，不进行写入

**Assertions:**
- [ ] 在任何审查模式下都不调用导演关卡
- [ ] 发现表的呈现不自动写入任何内容
- [ ] 可选报告写入功能被提供但不强制
- [ ] "May I write" 提示仅当用户选择报告时出现

---

## 协议合规性

- [ ] 在分析前读取平衡数据文件和 GDD 公式
- [ ] 发现表显示值、公式、偏差和严重性列
- [ ] 未经明确用户批准不写入任何文件
- [ ] 不调用任何导演关卡
- [ ] 判定结果为以下之一：BALANCED、CONCERNS、OUT OF BALANCE

---

## 覆盖范围说明

- `assets/data/` 完全为空的情况未进行测试；行为
  遵循 CONCERNS 模式，并显示未找到数据文件的消息。
- 容差阈值（±10%、±20%）是技能的实现细节；
  测试验证偏差是否被检测和分类，而非
  确切的阈值数值。
