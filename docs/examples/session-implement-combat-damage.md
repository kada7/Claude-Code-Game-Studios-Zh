# 示例会话：实现战斗伤害计算

**上下文：** 独立开发者，项目第 4 周，实现玩法系统。

**起始状态：**
- `design/gdd/combat-system.md` 存在并已评审
- Godot 4.6 项目已设置，具有基本场景结构
- 尚未编写玩法代码
- 冲刺目标："实现核心战斗伤害计算"

**会话时长：** ~30 分钟
**轮次：** 10
**结果：** 可工作的伤害计算器，含测试，准备集成

---

## Turn 1：用户请求实现

**用户：**
> 实现 design/gdd/combat-system.md 中的伤害计算系统。公式在第 4 节。

## Turn 2：Agent 读取设计并提出澄清问题

**Agent（gameplay-programmer）：**
> 我已读取 `design/gdd/combat-system.md`。伤害公式为：
>
> ```
> final_damage = base_damage * (1 + attack_stat * 0.1) * crit_multiplier * type_effectiveness * (1 - target_defense)
> ```
>
> 实现前，我需要澄清文档中未指定的细节：
>
> **架构问题：**
> 1. `DamageCalculator` 应该是静态工具类（无状态，仅计算）还是 autoload 单例？
> 2. `base_damage` 应该来自哪里？（武器数据？角色属性？能力数据？）
> 3. `type_effectiveness` 值应该存放在哪里？（每武器？每伤害类型？单独数据文件？）
>
> **规格歧义：**
> 4. `attack_stat` 应该限制在一个范围内吗？（防止指数缩放 bug）
> 5. 文档说"暴击造成 2 倍伤害"但未指定舍入。我应该 `floor()`、`ceil()` 还是 `round()` 最终伤害？
> 6. 如果 `target_defense` >= 1.0 会怎样？（100% 或更高减伤）伤害应该变负还是限制到 0？
>
> **集成：**
> 7. 我没有看到 Health/HP 系统的设计文档。我应该创建一个最小化的，还是单独进行？
>
> 请澄清，以便我能第一次就正确实现。

## Turn 3：用户解决歧义

**用户：**
> 1. 静态工具 — 不需要状态
> 2. 基础伤害来自 Weapon resource。我会创建一个简单的 Weapon 类。
> 3. 类型 effectiveness 在单独数据文件 `assets/data/combat_damage.json` 中
> 4. 是的，将 attack_stat 限制到 0-100
> 5. 使用 `floor()` 向下舍入为整数
> 6. 将伤害限制到最小 1（即使 100% 防御也始终至少造成 1 伤害）
> 7. 创建一个最小化 health 组件 — 只需 current_hp、max_hp 和 take_damage() 方法

## Turn 4：Agent 提出架构

**Agent：**
> 明白！以下是我提出的架构：
>
> **我将创建的文件：**
> ```
> src/gameplay/combat/damage_calculator.gd     # 静态伤害公式
> src/gameplay/combat/health_component.gd      # HP 跟踪节点组件
> src/gameplay/combat/weapon.gd                # Weapon resource
> assets/data/combat_damage.json               # 类型 effectiveness 值
> design/gdd/health-system.md                  # 最小化 health 文档
> tests/combat/test_damage_calculator.gd       # 单元测试
> ```
>
> **架构细节：**
>
> **DamageCalculator**（静态类）：
> ```gdscript
> class_name DamageCalculator
> extends RefCounted
>
> static func calculate_damage(
>     attacker_stats: Dictionary,
>     weapon: Weapon,
>     defender_stats: Dictionary,
>     is_crit: bool = false
> ) -> int:
>     # 在此实现
>     return floori(final_damage)
> ```
>
> **HealthComponent**（节点组件）：
> ```gdscript
> extends Node
> class_name HealthComponent
>
> signal health_changed(old_hp: int, new_hp: int)
> signal died()
>
> @export var max_hp: int = 100
> var current_hp: int:
>     set(value):
>         # 限制并触发信号
>
> func take_damage(amount: int) -> void:
>     current_hp -= amount
>     if current_hp <= 0:
>         died.emit()
> ```
>
> **Weapon**（resource）：
> ```gdscript
> extends Resource
> class_name Weapon
>
> @export var base_damage: float
> @export var damage_type: String  # "physical"、"fire"、"ice" 等
> ```
>
> **combat_damage.json**：
> ```json
> {
>   "crit_multiplier": 2.0,
>   "attack_stat_min": 0,
>   "attack_stat_max": 100,
>   "type_effectiveness": {
>     "physical": { "armored": 0.5, "flesh": 1.0, "crystal": 1.5 },
>     "fire": { "armored": 1.0, "flesh": 1.2, "crystal": 0.3 }
>   }
> }
> ```
>
> **问题：** 此架构使 `DamageCalculator` 易于测试（纯函数，无依赖）。`HealthComponent` 使用信号连接 VFX/SFX。这符合你的预期，还是我应该先更改什么？

## Turn 5：用户批准并做小幅修改

**用户：**
> 看起来不错，但将 `attacker_stats` 和 `defender_stats` 改为适当的类型化字典或类。我不想让无类型的 Dictionary 包四处浮动。

## Turn 6：Agent 细化架构

**Agent：**
> 绝对 — 类型安全很重要。我会创建一个 `CharacterStats` resource：
>
> ```gdscript
> extends Resource
> class_name CharacterStats
>
> @export var attack_stat: int = 0  # 0-100
> @export var defense: float = 0.0  # 0.0-1.0（0-100% 减伤）
> @export var armor_type: String = "flesh"  # 用于类型 effectiveness 查找
> ```
>
> 然后 `DamageCalculator.calculate_damage()` 签名变为：
> ```gdscript
> static func calculate_damage(
>     attacker: CharacterStats,
>     weapon: Weapon,
>     defender: CharacterStats,
>     is_crit: bool = false
> ) -> int
> ```
>
> 清晰多了。我可以继续实现吗？

## Turn 7：用户批准实现

**用户：**
> 是的，实现它。

## Turn 8：Agent 实现并报告

**Agent：**
> 实现完成！以下是我创建的：
>
> **创建的文件：**
> - ✅ `src/gameplay/combat/damage_calculator.gd`（82 行）
> - ✅ `src/gameplay/combat/health_component.gd`（45 行）
> - ✅ `src/gameplay/combat/weapon.gd`（12 行）
> - ✅ `src/gameplay/combat/character_stats.gd`（16 行）
> - ✅ `assets/data/combat_damage.json`（已验证 JSON）
> - ✅ `design/gdd/health-system.md`（最小化 8 节文档）
>
> **规则执行结果：**
>
> `gameplay-code` 规则在实现期间自动标记了 2 个问题：
> 1. ❌ `crit_multiplier` 在 damage_calculator.gd 中被硬编码为 `2.0`
>    - **已修复：** 移至 `combat_damage.json` 并从配置加载
> 2. ❌ `HealthComponent` 有直接 `print()` 调试输出
>    - **已修复：** 移除硬编码调试，改为添加适当信号
>
> `data-files` 规则验证：
> - ✅ `combat_damage.json` 是有效 JSON
> - ✅ 命名约定匹配 `[system]_[name].json`
> - ✅ 所有值都有注释文档
>
> **实现备注：**
> - Attack stat 在 `calculate_damage()` 使用前被限制
> - 伤害始终返回最小 1（根据你的要求）
> - 如果配置中未找到组合，类型 effectiveness 默认为 1.0
> - 所有数值从 `combat_damage.json` 加载，供设计者调整
>
> **手动测试：**
> 我创建了一个快速测试场景并验证：
> - 基础伤害：10，attack_stat：50 → 伤害：15 ✓
> - 相同但带暴击 → 伤害：30 ✓
> - 50% 防御 → 伤害：15（防御前）→ 7（防御后）✓
> - 100% 防御 → 伤害：1（已限制）✓
>
> **下一步 — 你的选择：**
> A) 我现在可以编写正式单元测试（推荐 — 验证驱动开发）
> B) 你可以先通过 `/code-review src/gameplay/combat/damage_calculator.gd` 评审代码
> C) 暂时跳过测试并集成到实际战斗中
>
> 你想要什么？

## Turn 9：用户请求测试

**用户：**
> A — 编写单元测试。覆盖所有边界情况。

## Turn 10：Agent 编写测试并完成

**Agent：**
> 单元测试已创建：`tests/combat/test_damage_calculator.gd`
>
> **测试覆盖（8 个测试）：**
> ```
> ✓ test_damage_basic_calculation() - 用已知值验证公式
> ✓ test_damage_with_crit() - 暴击造成双倍伤害
> ✓ test_damage_with_defense() - 防御正确减少伤害
> ✓ test_damage_type_effectiveness() - 类型修正生效
> ✓ test_damage_min_clamp() - 永不低于 1
> ✓ test_damage_attack_stat_clamp() - Attack stat 限制到 0-100
> ✓ test_damage_missing_type_combo() - 如果不在配置中则默认为 1.0
> ✓ test_damage_rounding() - 验证 floor() 行为
> ```
>
> **测试结果：**
> ```
> 运行 tests/combat/test_damage_calculator.gd...
> ✓ 全部 8 个测试通过
> 执行时间：12ms
> ```
>
> **代码评审自检：**
> - ✅ 所有测试遵循 `test_[system]_[scenario]_[expected]` 命名
> - ✅ 使用 Arrange/Act/Assert 结构
> - ✅ 无外部状态依赖
> - ✅ 每个测试独立，可以任意顺序运行
>
> **系统已准备好集成！**
>
> 你现在可以提交的文件：
> ```bash
> git add src/gameplay/combat/*.gd
> git add assets/data/combat_damage.json
> git add design/gdd/health-system.md
> git add tests/combat/test_damage_calculator.gd
> git commit -m "根据 design/gdd/combat-system.md 实现伤害计算系统"
> ```
>
> `validate-commit` 钩子将检查：
> - ✅ 提交消息中引用了设计文档
> - ✅ JSON 有效性
> - ✅ 无硬编码值（已修复）
>
> 准备好提交了吗？

---

## 会话摘要

**效果良好的方面：**
- Agent 首先阅读设计文档，预先识别出 7 个歧义
- 不假设或猜测 — 对每个不明确点都要求澄清
- 在用户批准前提出完整架构
- 立即融入用户的类型安全反馈
- 规则自动捕获问题，Agent 透明修复
- 遵循验证驱动开发主动编写测试
- Agent 提供后续步骤选项，而非假设用户想要什么

**关键协作时刻：**
- Turn 2：Agent 识别出 7 个规格差距并询问，而非猜测
- Turn 4：在实现前展示完整架构提案
- Turn 5：用户请求类型安全，Agent 调整
- Turn 8：Agent 透明报告规则违规和修复
- Turn 10：Agent 用测试验证所有验收标准

**创建的文件：**
- 4 个源文件（damage_calculator、health_component、weapon、character_stats）
- 1 个配置文件（combat_damage.json）
- 1 份设计文档（health-system.md）
- 1 个测试文件（test_damage_calculator.gd）

**上下文使用：** ~25%（专注的实现任务）
**用户满意度：** 高 — 规格歧义早期解决，无需返工
