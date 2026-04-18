# settings.local.json 模板

创建 `.claude/settings.local.json` 用于不应提交到版本控制的个人覆盖设置。将其添加到 `.gitignore`。

## 示例 settings.local.json

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

## 权限模式

Claude Code 支持不同的权限模式。游戏开发推荐：

### 开发期间（默认）
使用**正常模式** — Claude 在运行大多数命令前会询问。这对生产代码最安全。

### 原型开发期间
使用**自动接受模式**，限制范围 — 在废弃代码上迭代更快。仅在 `prototypes/` 目录下工作时使用。

### 代码审查期间
使用**只读**权限 — Claude 可以读取和搜索但不能修改文件。

## 本地自定义钩子

您可以在 `settings.local.json` 中添加个人钩子，这些钩子扩展（不覆盖）项目钩子。例如，添加构建完成时的通知：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'echo Session ended at $(date)'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```