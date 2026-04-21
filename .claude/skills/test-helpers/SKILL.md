---
name: test-helpers
description: "为项目的测试套件生成引擎特定的测试辅助库。读取现有测试模式并生成包含断言工具、工厂函数和 mock 对象的 tests/helpers/，这些对象根据项目系统量身定制。减少新测试文件中的样板代码。"
argument-hint: "[system-name | all | scaffold]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

# 测试辅助函数

编写测试用例在常见设置、拆卸和断言模式被抽象到辅助函数中时更快更一致。此 skill 生成针对项目实际引擎、语言和系统量身定制的 `tests/helpers/` 库 — 这样每个开发人员编写的样板代码更少，断言更多。

**输出：** `tests/helpers/` 目录，包含引擎特定的辅助文件

**何时运行：**

- 在 `/test-setup` 脚手架框架之后（首次）
- 当多个测试文件重复相同的设置样板时
- 当开始为新系统编写测试时

---

## 1. 解析参数

**模式：**

- `/test-helpers [system-name]` — 为特定系统生成辅助函数（例如 `/test-helpers combat`）
- `/test-helpers all` — 为所有有测试文件的系统生成辅助函数
- `/test-helpers scaffold` — 仅生成基础辅助库（无系统特定辅助函数）；首次运行时使用
- 无参数 — 如果辅助函数不存在则运行 `scaffold`，否则运行 `all`

---

## 2. 检测引擎和语言

读取 `.claude/docs/technical-preferences.md` 并提取：

- `Engine:` 值
- `Language:` 值
- Testing 部分的 `Framework:`

如果引擎未配置："Engine not configured. Run `/setup-engine` first."

---

## 3. 加载现有测试模式

扫描测试目录中已使用的模式：

```
Glob pattern="tests/**/*_test.*" (所有测试文件)
```

对于代表性样本（最多 5 个文件），读取测试文件并提取：

- Setup 模式（如何编写 `before_each` / `setUp` / fixtures）
- 常见断言模式（最常断言的内容）
- 对象创建模式（如何在测试中实例化游戏对象或场景）
- Mock/stub 模式（如何替换依赖项）

这确保生成的辅助函数匹配项目现有风格，而不是通用模板。

同时读取：

- `design/gdd/systems-index.md` — 了解存在哪些系统
- 范围内的 GDD(s) — 了解需要测试的数据类型和值
- `docs/architecture/tr-registry.yaml` — 将需求映射到测试系统

---

## 4. 生成引擎特定的辅助函数

### Godot 4 (GDUnit4 / GDScript)

**基础辅助函数** (`tests/helpers/game_assertions.gd`)：

```gdscript
## 针对 [项目名称] 测试的游戏专用断言工具。
## 使用领域特定的辅助函数扩展 GdUnitAssertions。
##
## 用法：
##   var assert = GameAssertions.new()
##   assert.health_in_range(entity, 0, entity.max_health)

class_name GameAssertions
extends RefCounted

## 断言值在包含范围 [min_val, max_val] 内。
## 用于 GDD 中定义了边界的任何公式输出。
static func assert_in_range(
    value: float,
    min_val: float,
    max_val: float,
    label: String = "value"
) -> void:
    assert(
        value >= min_val and value <= max_val,
        "%s %.2f is outside expected range [%.2f, %.2f]" % [label, value, min_val, max_val]
    )

## 断言在可调用块期间发出了信号。
## 用法：assert_signal_emitted(entity, "health_changed", func(): entity.take_damage(10))
static func assert_signal_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    var emitted := false
    obj.connect(signal_name, func(_args): emitted = true)
    action.call()
    assert(emitted, "Expected signal '%s' to be emitted, but it was not." % signal_name)

## 断言可调用块未发出信号。
static func assert_signal_not_emitted(
    obj: Object,
    signal_name: String,
    action: Callable
) -> void:
    var emitted := false
    obj.connect(signal_name, func(_args): emitted = true)
    action.call()
    assert(not emitted, "Expected signal '%s' NOT to be emitted, but it was." % signal_name)

## 断言父节点内指定路径存在节点。
static func assert_node_exists(parent: Node, path: NodePath) -> void:
    assert(
        parent.has_node(path),
        "Expected node at path '%s' to exist." % str(path)
    )
```

**工厂辅助函数** (`tests/helpers/game_factory.gd`)：

```gdscript
## 创建测试游戏对象的工厂函数。
## 返回为单元测试配置的最小对象（不需要场景树）。
##
## 用法：var player = GameFactory.make_player(health: 100)

class_name GameFactory
extends RefCounted

## 创建最小化的玩家对象用于测试。
## 根据需要覆盖字段。
static func make_player(health: int = 100) -> Node:
    var player = Node.new()
    player.set_meta("health", health)
    player.set_meta("max_health", health)
    return player
```

**场景辅助函数** (`tests/helpers/scene_runner_helper.gd`)：

```gdscript
## 基于场景的集成测试工具。
## 封装 GdUnitSceneRunner 的常见模式。

class_name SceneRunnerHelper
extends GdUnitTestSuite

## 加载场景并等待一帧以完成 _ready()。
func load_scene_and_wait(scene_path: String) -> Node:
    var scene = load(scene_path).instantiate()
    add_child(scene)
    await get_tree().process_frame
    return scene
```

---

### Unity (NUnit / C#)

**基础辅助函数** (`tests/helpers/GameAssertions.cs`)：

```csharp
using NUnit.Framework;
using UnityEngine;

/// <summary>
/// 针对 [项目名称] 测试的游戏专用断言工具。
/// 使用领域特定的辅助函数扩展 NUnit 的 Assert。
/// </summary>
public static class GameAssertions
{
    /// <summary>
    /// 断言值在包含范围 [min, max] 内。
    /// 用于 GDD Formulas 部分定义的任何公式输出。
    /// </summary>
    public static void AssertInRange(float value, float min, float max, string label = "value")
    {
        Assert.That(value, Is.InRange(min, max),
            $"{label} ({value:F2}) is outside expected range [{min:F2}, {max:F2}]");
    }

    /// <summary>断言在操作期间触发了 UnityEvent 或 C# 事件。</summary>
    public static void AssertEventRaised(ref bool wasCalled, System.Action action, string eventName)
    {
        wasCalled = false;
        action();
        Assert.IsTrue(wasCalled, $"Expected event '{eventName}' to be raised, but it was not.");
    }

    /// <summary>断言 GameObject 上存在组件。</summary>
    public static void AssertHasComponent<T>(GameObject obj) where T : Component
    {
        var component = obj.GetComponent<T>();
        Assert.IsNotNull(component,
            $"Expected GameObject '{obj.name}' to have component {typeof(T).Name}.");
    }
}
```

**工厂辅助函数** (`tests/helpers/GameFactory.cs`)：

```csharp
using UnityEngine;

/// <summary>
/// 用于创建不加载场景的最小测试对象的工厂方法。
/// </summary>
public static class GameFactory
{
    /// <summary>创建带有命名组件的最小 GameObject 用于测试。</summary>
    public static GameObject MakeGameObject(string name = "TestObject")
    {
        var go = new GameObject(name);
        return go;
    }

    /// <summary>
    /// 创建类型为 T 的 ScriptableObject 用于数据驱动测试。
    /// 测试后使用 Object.DestroyImmediate 销毁。
    /// </summary>
    public static T MakeScriptableObject<T>() where T : ScriptableObject
    {
        return ScriptableObject.CreateInstance<T>();
    }
}
```

---

### Unreal Engine (C++)

**基础辅助函数** (`tests/helpers/GameTestHelpers.h`)：

```cpp
#pragma once

#include "CoreMinimal.h"
#include "Misc/AutomationTest.h"

/**
 * 针对 [项目名称] 自动化测试的游戏专用断言宏和辅助函数。
 * 包含在任何需要领域特定断言的测试文件中。
 *
 * 用法：
 *   GAME_TEST_ASSERT_IN_RANGE(TestName, DamageValue, 10.0f, 50.0f, TEXT("Damage"));
 */

// 断言浮点值在包含范围 [Min, Max] 内
#define GAME_TEST_ASSERT_IN_RANGE(TestName, Value, Min, Max, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s (%.2f) in range [%.2f, %.2f]"), Label, Value, Min, Max), \
        (Value) >= (Min) && (Value) <= (Max) \
    )

// 断言 UObject 指针有效（非空，未被垃圾回收）
#define GAME_TEST_ASSERT_VALID(TestName, Ptr, Label) \
    TestTrue( \
        FString::Printf(TEXT("%s is valid"), Label), \
        IsValid(Ptr) \
    )

// 断言 Actor 存在于世界中（生成成功）
#define GAME_TEST_ASSERT_SPAWNED(TestName, ActorPtr, ClassName) \
    TestNotNull( \
        FString::Printf(TEXT("Spawned actor of class %s"), TEXT(#ClassName)), \
        ActorPtr \
    )

/**
 * 创建最小化测试世界的辅助函数。
 * 记得在拆卸时调用 World->DestroyWorld(false)。
 */
namespace GameTestHelpers
{
    inline UWorld* CreateTestWorld(const FString& WorldName = TEXT("TestWorld"))
    {
        UWorld* World = UWorld::CreateWorld(EWorldType::Game, false);
        FWorldContext& WorldContext = GEngine->CreateNewWorldContext(EWorldType::Game);
        WorldContext.SetCurrentWorld(World);
        return World;
    }
}
```

---

## 5. 生成系统特定的辅助函数

对于 `[system-name]` 或 `all` 模式，为每个系统生成一个辅助函数：

读取系统的 GDD 以提取：

- 数据类型（实体类型、组件名称）
- 公式变量及其边界
- Edge Cases 中提到的常见测试场景

生成 `tests/helpers/[system]_factory.[ext]`，包含特定于该系统对象的工厂函数。

`combat` 系统的示例模式（Godot/GDScript）：

```gdscript
## Combat 系统测试的工厂和断言辅助函数。
## 由 /test-helpers combat 于 [日期] 生成。
## 基于：design/gdd/combat.md

class_name CombatTestFactory
extends RefCounted

const DAMAGE_MIN := 0
const DAMAGE_MAX := 999  # From GDD: damage formula upper bound

## 创建最小化的攻击者对象用于伤害公式测试。
static func make_attacker(attack: float = 10.0, crit_chance: float = 0.0) -> Node:
    var attacker = Node.new()
    attacker.set_meta("attack", attack)
    attacker.set_meta("crit_chance", crit_chance)
    return attacker

## 创建最小化的目标对象用于承受伤害测试。
static func make_target(defense: float = 0.0, health: float = 100.0) -> Node:
    var target = Node.new()
    target.set_meta("defense", defense)
    target.set_meta("health", health)
    target.set_meta("max_health", health)
    return target

## 断言伤害输出在 GDD 指定的边界内。
static func assert_damage_in_bounds(damage: float) -> void:
    GameAssertions.assert_in_range(damage, DAMAGE_MIN, DAMAGE_MAX, "damage")
```

---

## 6. 写入输出

展示将要创建的内容摘要：

```
## 待创建的测试辅助函数

基础辅助函数（引擎：[engine]）：
- tests/helpers/game_assertions.[ext]
- tests/helpers/game_factory.[ext]
[引擎特定的额外辅助函数]

系统辅助函数（[mode]）：
- tests/helpers/[system]_factory.[ext]  ← 来自 [system] GDD
```

询问："我可以将这些辅助文件写入 `tests/helpers/` 吗？"

**永远不要覆盖现有文件。** 如果文件已存在，报告："跳过 `[path]` — 已存在。如果要重新生成，请手动删除该文件。"

写入后：裁决：**COMPLETE** — 辅助文件已创建。

"辅助文件已创建。要在测试中使用它们：

- Godot: `class_name` 自动导入 — 不需要显式 import
- Unity: 添加 `using` 指令或引用测试程序集
- Unreal: `#include "tests/helpers/GameTestHelpers.h"`"

---

## 协作协议

- **永远不要覆盖现有辅助函数** — 它们可能包含手写自定义。只生成尚不存在的新文件
- **生成的代码是起点** — 生成的工厂函数使用元数据模式以简化；一旦代码存在，请适应实际的类结构
- **辅助函数应反映 GDD** — 辅助函数中的边界和常量应追溯到 GDD Formulas 部分，而不是虚构的值
- **写入前询问** — 始终在 `tests/` 中创建文件前确认

## 后续步骤

- 如果测试框架尚未脚手架，运行 `/test-setup`。
- 使用 `/dev-story` 实现 stories — 辅助函数减少新测试文件中的样板代码。
- 运行 `/skill-test` 验证其他可能需要辅助函数覆盖的 skills。
