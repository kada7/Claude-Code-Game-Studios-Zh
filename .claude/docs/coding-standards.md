# 编码标准

- 所有游戏代码必须在公共 API 上包含文档注释
- 每个系统必须在 `docs/architecture/` 中有相应的架构决策记录
- 游戏玩法值必须是数据驱动的（外部配置），永远不要硬编码
- 所有公共方法必须是可单元测试的（依赖注入优于单例模式）
- 提交必须引用相关的设计文档或任务 ID
- **验证驱动开发**：添加游戏玩法系统时先编写测试。
  对于 UI 变更，使用截图验证。在标记工作完成之前，
  比较预期输出与实际输出。每个实现都应该有证明其有效的方法。

# 设计文档标准

- 所有设计文档使用 Markdown
- 每个机制在 `design/gdd/` 中有一个专用文档
- 文档必须包含这 8 个必需部分：
  1. **概述** -- 单段落摘要
  2. **玩家幻想** -- 预期的感受和体验
  3. **详细规则** -- 明确的机制
  4. **公式** -- 所有数学使用变量定义
  5. **边界情况** -- 处理的异常情况
  6. **依赖关系** -- 列出的其他系统
  7. **可调参数** -- 标识的可配置值
  8. **验收标准** -- 可测试的成功条件
- 平衡值必须链接到其来源公式或理由

# 测试标准

## 按 Story 类型的测试证据

所有 story 在标记为完成之前必须有适当的测试证据：

| Story 类型 | 必需证据 | 位置 | 门级别 |
|---|---|---|---|
| **逻辑**（公式、AI、状态机） | 自动化的单元测试 — 必须通过 | `tests/unit/[system]/` | 阻塞 |
| **集成**（多系统） | 集成测试或文档化的游戏测试 | `tests/integration/[system]/` | 阻塞 |
| **视觉/感觉**（动画、VFX、手感） | 截图 + 主管签署 | `production/qa/evidence/` | 建议 |
| **UI**（菜单、HUD、屏幕） | 手动走查文档或交互测试 | `production/qa/evidence/` | 建议 |
| **配置/数据**（平衡调整） | 冒烟测试通过 | `production/qa/smoke-[date].md` | 建议 |

## 自动化测试规则

- **命名**: 文件为 `[system]_[feature]_test.[ext]`；函数为 `test_[scenario]_[expected]`
- **确定性**: 测试必须在每次运行时产生相同的结果 — 没有随机种子，没有时间相关的断言
- **隔离**: 每个测试设置和清理自己的状态；测试不能依赖于执行顺序
- **没有硬编码数据**: 测试夹具使用常量文件或工厂函数，而不是内联的魔术数字
  （例外：边界值测试，其中确切的数字本身就是重点）
- **独立性**: 单元测试不调用外部 API、数据库或文件 I/O — 使用依赖注入

## What NOT to Automate

- Visual fidelity (shader output, VFX appearance, animation curves)
- "Feel" qualities (input responsiveness, perceived weight, timing)
- Platform-specific rendering (test on target hardware, not headlessly)
- Full gameplay sessions (covered by playtesting, not automation)

## CI/CD Rules

- Automated test suite runs on every push to main and every PR
- No merge if tests fail — tests are a blocking gate in CI
- Never disable or skip failing tests to make CI pass — fix the underlying issue
- Engine-specific CI commands:
  - **Godot**: `godot --headless --script tests/gdunit4_runner.gd`
  - **Unity**: `game-ci/unity-test-runner@v4` (GitHub Actions)
  - **Unreal**: headless runner with `-nullrhi` flag
