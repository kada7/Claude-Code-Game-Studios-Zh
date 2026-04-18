---
name: test-setup
description: "为项目引擎搭建测试框架和 CI/CD 流水线。创建 tests/ 目录结构、引擎专属测试运行器配置以及 GitHub Actions 工作流。在第一个 Sprint 开始前的技术设置阶段运行一次。"
argument-hint: "[force]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write
---

# 测试设置

此技能为项目搭建自动化测试基础设施。
它检测已配置的引擎，生成相应的测试运行器
配置，创建标准目录结构，并接入 CI/CD，
使测试在每次推送时自动运行。

在技术设置阶段运行一次，在任何实现开始之前。
Sprint 开始时安装测试框架需要 30 分钟。
在第四个 Sprint 才安装测试框架则需要 3 个 Sprint 的代价。

**输出：** `tests/` 目录结构 + `.github/workflows/tests.yml`

---

## 阶段1：检测引擎和现有状态

1. **读取引擎配置**：
   - 读取 `.claude/docs/technical-preferences.md` 并提取 `Engine:` 值。
   - 如果引擎未配置（`[TO BE CONFIGURED]`），停止：
     "引擎未配置。请先运行 `/setup-engine`，然后重新运行 `/test-setup`。"

2. **检查现有测试基础设施**：
   - Glob `tests/` — 目录是否存在？
   - Glob `tests/unit/` 和 `tests/integration/` — 子目录是否存在？
   - Glob `.github/workflows/` — CI 工作流文件是否存在？
   - Glob `tests/gdunit4_runner.gd`（Godot）、`tests/EditMode/`（Unity）或
     `Source/Tests/`（Unreal）查找引擎专属工件。

3. **报告结果**：
   - "引擎：[引擎]。测试目录：[已找到 / 未找到]。CI 工作流：[已找到 / 未找到]。"
   - 如果所有内容都已存在且未传入 `force` 参数：
     "测试基础设施似乎已就位。使用 `/test-setup force` 重新运行以重新生成。
     继续将不会覆盖现有测试文件。"

如果传入 `force` 参数，跳过"已存在"的提前退出并继续 —
但仍不覆盖给定路径已存在的文件。只创建缺失的文件。

---

## 阶段2：展示计划

根据检测到的引擎和现有状态，展示计划：

```
## 测试设置计划 — [引擎]

我将创建以下内容（跳过已存在的）：

tests/
  unit/           — 用于公式、状态和逻辑的隔离单元测试
  integration/    — 跨系统测试和存档/读档往返测试
  smoke/          — 关键路径测试列表（15分钟手动关卡）
  evidence/       — 截图和手动测试签署记录
  README.md       — 测试框架文档

[引擎专属文件 — 参见下方各引擎详情]

.github/workflows/tests.yml  — CI：每次推送到 main 时运行测试

预计时间：约 5 分钟创建所有文件。
```

询问："我可以创建这些文件吗？我不会覆盖这些路径上已存在的任何测试文件。"

未经批准不得继续。

---

## 阶段3：创建目录结构

批准后，创建以下文件：

### `tests/README.md`

```markdown
# 测试基础设施

**引擎**：[引擎名称 + 版本]
**测试框架**：[GdUnit4 | Unity Test Framework | UE Automation]
**CI**：`.github/workflows/tests.yml`
**设置日期**：[日期]

## 目录结构

```
tests/
  unit/           # 隔离单元测试（公式、状态机、逻辑）
  integration/    # 跨系统和存档/读档测试
  smoke/          # /smoke-check 关卡的关键路径测试列表
  evidence/       # 截图日志和手动测试签署记录
```

## 运行测试

[引擎专属命令 — 参见下文]

## 测试命名

- **文件**：`[system]_[feature]_test.[ext]`
- **函数**：`test_[scenario]_[expected]`
- **示例**：`combat_damage_test.gd` → `test_base_attack_returns_expected_damage()`

## Story 类型 → 测试证据

| Story 类型 | 必需证据 | 位置 |
|---|---|---|
| Logic | 自动化单元测试 — 必须通过 | `tests/unit/[system]/` |
| Integration | 集成测试或游戏测试文档 | `tests/integration/[system]/` |
| Visual/Feel | 截图 + 负责人签署 | `tests/evidence/` |
| UI | 手动走查文档或交互测试 | `tests/evidence/` |
| Config/Data | 冒烟测试通过 | `production/qa/smoke-*.md` |

## CI

每次推送到 `main` 以及每次拉取请求时自动运行测试。
测试套件失败将阻止合并。
```
```

### 引擎专属文件

#### Godot 4（`Engine: Godot`）

创建 `tests/gdunit4_runner.gd`：

```gdscript
# GdUnit4 测试运行器 — 由 CI 和 /smoke-check 调用
# 用法：godot --headless --script tests/gdunit4_runner.gd
extends SceneTree

func _init() -> void:
    var runner := load("res://addons/gdunit4/GdUnitRunner.gd")
    if runner == null:
        push_error("GdUnit4 未找到。通过 AssetLib 或 addons/ 安装。")
        quit(1)
        return
    var instance = runner.new()
    instance.run_tests()
    quit(0)
```

创建 `tests/unit/.gdignore_placeholder`，内容为：
`# 单元测试放在这里 — 每个系统一个子目录（例如 tests/unit/combat/）`

创建 `tests/integration/.gdignore_placeholder`，内容为：
`# 集成测试放在这里 — 每个系统一个子目录`

在 README 中注明：**安装 GdUnit4**
```
1. 打开 Godot → AssetLib → 搜索 "GdUnit4" → 下载并安装
2. 启用插件：Project → Project Settings → Plugins → GdUnit4 ✓
3. 重启编辑器
4. 验证：res://addons/gdunit4/ 存在
```

#### Unity（`Engine: Unity`）

创建 `tests/EditMode/README.md`：
```markdown
# 编辑模式测试
无需进入 Play Mode 即可运行的单元测试。
用于纯逻辑：公式、状态机、数据验证。
需要程序集定义：`tests/EditMode/EditModeTests.asmdef`
```

创建 `tests/PlayMode/README.md`：
```markdown
# 播放模式测试
在真实游戏场景中运行的集成测试。
用于跨系统交互、物理和协程。
需要程序集定义：`tests/PlayMode/PlayModeTests.asmdef`
```

在 README 中注明：**启用 Unity Test Framework**
```
Window → General → Test Runner
（Unity Test Framework 在 Unity 2019+ 中默认包含）
```

#### Unreal Engine（`Engine: Unreal` 或 `Engine: UE5`）

创建 `Source/Tests/README.md`：
```markdown
# Unreal 自动化测试
测试使用 UE 自动化测试框架。
通过以下方式运行：Session Frontend → Automation → 选择 "MyGame." 测试
或无头运行：UnrealEditor -nullrhi -ExecCmds="Automation RunTests MyGame.; Quit"

测试类命名：F[SystemName]Test
测试分类命名："MyGame.[System].[Feature]"
```

---

## 阶段4：创建 CI/CD 工作流

### Godot 4

创建 `.github/workflows/tests.yml`：

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run GdUnit4 Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Run GdUnit4 Tests
        uses: MikeSchulze/gdUnit4-action@v1
        with:
          godot-version: '[VERSION FROM docs/engine-reference/godot/VERSION.md]'
          paths: |
            tests/unit
            tests/integration
          report-name: test-results

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: reports/
```

### Unity

创建 `.github/workflows/tests.yml`：

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Unity Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Run Edit Mode Tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: editmode
          artifactsPath: test-results/editmode

      - name: Run Play Mode Tests
        uses: game-ci/unity-test-runner@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
        with:
          testMode: playmode
          artifactsPath: test-results/playmode

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test-results/
```

注意：Unity CI 需要 `UNITY_LICENSE` Secret。在首次 CI 运行前添加到 GitHub 仓库 Secrets。

### Unreal Engine

创建 `.github/workflows/tests.yml`：

```yaml
name: Automated Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run UE Automation Tests
    runs-on: self-hosted  # UE 需要安装了编辑器的本地运行器

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Run Automation Tests
        run: |
          "$UE_EDITOR_PATH" "${{ github.workspace }}/[ProjectName].uproject" \
            -nullrhi -nosound \
            -ExecCmds="Automation RunTests MyGame.; Quit" \
            -log -unattended
        shell: bash

      - name: Upload Logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-logs
          path: Saved/Logs/
```

注意：UE CI 需要安装了 Unreal Editor 的自托管运行器。
在运行器上设置 `UE_EDITOR_PATH` 环境变量。

---

## 阶段5：创建冒烟测试种子

创建 `tests/smoke/critical-paths.md`：

```markdown
# 冒烟测试：关键路径

**目的**：在任何 QA 交接前，在 15 分钟内运行这 10-15 项检查。
**运行方式**：`/smoke-check`（读取此文件）
**更新**：当实现新的核心系统时添加新条目。

## 核心稳定性（始终运行）

1. 游戏启动至主菜单且不崩溃
2. 可以从主菜单开始新游戏/会话
3. 主菜单响应所有输入且不冻结

## 核心机制（每个 Sprint 更新）

<!-- 实现后在此添加每个 Sprint 的主要机制 -->
<!-- 示例："玩家可以移动、跳跃，且摄像机正确跟随" -->
4. [主要机制 — 实现第一个核心系统时更新]

## 数据完整性

5. 存档完成且无错误（一旦实现存档系统后）
6. 读档恢复正确状态（一旦实现读档系统后）

## 性能

7. 目标硬件上无明显帧率下降（60fps 目标）
8. 5 分钟游戏过程中无内存增长（一旦实现核心循环后）
```

---

## 阶段6：设置后摘要

写入所有文件后，报告：

```
已为 [引擎] 创建测试基础设施。

创建的文件：
- tests/README.md
- tests/unit/（目录）
- tests/integration/（目录）
- tests/smoke/critical-paths.md
- tests/evidence/（目录）
[引擎专属文件]
- .github/workflows/tests.yml

后续步骤：
1. [引擎专属安装步骤，例如"通过 AssetLib 安装 GdUnit4"]
2. 编写你的第一个测试：创建 tests/unit/[first-system]/[system]_test.[ext]
3. 在第一个 Sprint 前运行 `/qa-plan sprint` 以分类 Story 并设置测试证据要求
4. 每次 QA 交接前运行 `/smoke-check`

关卡说明：/gate-check Technical Setup → Pre-Production 现在需要：
- 包含 unit/ 和 integration/ 子目录的 tests/ 目录
- .github/workflows/tests.yml
- 至少一个示例测试文件
在推进前运行 /test-setup 并编写一个示例测试。

裁决：**COMPLETE** — 测试框架已搭建，CI/CD 已接入。
```

---

## 协作协议

- **永不覆盖现有测试文件** — 只创建缺失的文件。
  如果测试运行器文件已存在，保持原样。
- **创建文件前始终询问** — 阶段2需要明确批准。
- **引擎检测是不可协商的** — 如果引擎未配置，
  停止并重定向到 `/setup-engine`。不要猜测。
- **`force` 标志跳过"已存在"的提前退出但永不覆盖。**
  它意味着"即使目录已存在也创建所有缺失的文件。"
- 对于 Unity CI，注意 `UNITY_LICENSE` Secret 必须手动配置。
  不要尝试自动化许可证管理。
