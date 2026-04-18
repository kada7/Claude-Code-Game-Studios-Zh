# Claude Code Game Studios -- 游戏工作室 Agent 架构

由 48 个协同的 Claude Code 子 Agent 管理的独立游戏开发。
每个 Agent 拥有特定的领域，负责强制执行关注点分离和质量控制。

## 技术栈

- **引擎**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **语言**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **版本控制**: Git (主干开发模式)
- **构建系统**: [SPECIFY after choosing engine]
- **资源流水线**: [SPECIFY after choosing engine]

> **注意**: 已为 Godot、Unity 和 Unreal 提供了配备专属子专家的引擎专家 Agent。请使用与你的引擎匹配的集。

## 项目结构

@.claude/docs/directory-structure.md

## 引擎版本参考

@docs/engine-reference/godot/VERSION.md

## 技术偏好

@.claude/docs/technical-preferences.md

## 协同规则

@.claude/docs/coordination-rules.md

## 协作协议

**由用户驱动协作，而非自主执行。**
每项任务都遵循：**问题 -> 选项 -> 决策 -> 草稿 -> 批准**

- Agent 在使用 Write/Edit 工具前必须询问：“我可以将其写入 [filepath] 吗？”
- Agent 在请求批准前必须展示草稿或摘要
- 多文件变更需要对整个变更集进行明确批准
- 未经用户指示，不得进行提交 (commits)

详细协议与示例请参阅 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

> **第一次会话？** 如果项目尚未配置引擎且没有游戏概念，
> 请运行 `/start` 开始引导式的上手流程。

## 编码标准

@.claude/docs/coding-standards.md

## 上下文管理

@.claude/docs/context-management.md
