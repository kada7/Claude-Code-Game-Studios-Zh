# 设计目录

在此目录中创建或编辑文件时，请遵循以下标准。

## GDD 文件 (`design/gdd/`)

每个 GDD 必须按顺序包含以下 **8 个必需部分**：
1. 概述 — 一段式的总结
2. 玩家幻想 — 预期的感受和体验
3. 详细规则 — 明确的机制
4. 公式 — 所有数学定义，包含变量
5. 边界情况 — 异常情况的处理
6. 依赖项 — 列出的其他系统
7. 调节参数 — 可配置的数值标识
8. 验收标准 — 可测试的成功条件

**文件命名：** `[系统slug].md`（例如 `movement-system.md`、`combat-system.md`）

**系统索引：** `design/gdd/systems-index.md` — 添加新 GDD 时更新。

**设计顺序：** Foundation → Core → Feature → Presentation → Polish

**验证：** 编写任何 GDD 后，运行 `/design-review [路径]`。
完成一组相关的 GDD 后，运行 `/review-all-gdds`。

## 快速规格 (`design/quick-specs/`)

用于调整更改、次要机制或平衡调整的轻量级规格。
使用 `/quick-design` 进行编写。

## UX 规格 (`design/ux/`)

- 每屏规格：`design/ux/[屏幕名称].md`
- HUD 设计：`design/ux/hud.md`
- 交互模式库：`design/ux/interaction-patterns.md`
- 辅助功能要求：`design/ux/accessibility-requirements.md`

使用 `/ux-design` 进行编写。在传递给 `/team-ui` 之前，使用 `/ux-review` 进行验证。