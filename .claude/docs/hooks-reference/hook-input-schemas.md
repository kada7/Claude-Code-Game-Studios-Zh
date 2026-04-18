# Hook 输入/输出模式

本文档记录了每个 Claude Code 钩子针对每种事件类型在 stdin 上接收到的 JSON 载荷。

## PreToolUse

在执行工具前触发。可以**允许**（退出码 0）或**阻止**（退出码 2）。

### PreToolUse: Bash

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git commit -m 'feat: add player health system'",
    "description": "Commit changes with message",
    "timeout": 120000
  }
}
```

### PreToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "content": "extends Node\n..."
  }
}
```

### PreToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "src/gameplay/health.gd",
    "old_string": "var health = 100",
    "new_string": "var health: int = 100"
  }
}
```

### PreToolUse: Read

```json
{
  "tool_name": "Read",
  "tool_input": {
    "file_path": "src/gameplay/health.gd"
  }
}
```

## PostToolUse

在工具完成后触发。**无法阻止**（退出码对于阻止操作被忽略）。Stderr 消息显示为警告。

### PostToolUse: Write

```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "content": "{\"goblin\": {\"health\": 50}}"
  },
  "tool_output": "File written successfully"
}
```

### PostToolUse: Edit

```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "assets/data/enemy_stats.json",
    "old_string": "\"health\": 50",
    "new_string": "\"health\": 75"
  },
  "tool_output": "File edited successfully"
}
```

## SubagentStart

当通过 Task 工具生成 subagent 时触发。

```json
{
  "agent_name": "game-designer",
  "model": "sonnet",
  "description": "Design the combat healing mechanic"
}
```

## SessionStart

当 Claude Code 会话开始时触发。**没有 stdin 输入** —— 钩子仅运行，其 stdout 作为上下文显示给 Claude。

## PreCompact

在上下文窗口压缩前触发。**没有 stdin 输入** —— 钩子运行以在压缩前保存状态。

## Stop

当 Claude Code 会话结束时触发。**没有 stdin 输入** —— 钩子运行进行清理和日志记录。

## 退出码参考

| 退出码 | 含义 | 适用事件 |
|-----------|---------|-------------------|
| 0 | 允许 / 成功 | 所有事件 |
| 2 | 阻止（stderr 显示给 Claude） | 仅 PreToolUse |
| 其他 | 视为错误，工具继续执行 | 所有事件 |

## 备注

- 钩子在 **stdin**（管道）上接收 JSON。使用 `INPUT=$(cat)` 来捕获。
- 如果可用，使用 `jq` 解析，否则回退到 `grep` 以保证跨平台兼容性。
- 在 Windows 上，`grep -P`（Perl 正则表达式）通常不可用。改用 `grep -E`（POSIX 扩展）。
- 路径分隔符在 Windows 上可能是 `\`。在比较路径时使用 `sed 's|\\\\|/|g'` 进行标准化。