# Setup Requirements

此模板需要安装一些工具才能发挥完整功能。如果工具缺失，所有 hooks 都会优雅地失败 — 不会破坏任何东西，但你会失去验证功能。

## Required

| Tool | Purpose | Install |
| ---- | ---- | ---- |
| **Git** | 版本控制，分支管理 | [git-scm.com](https://git-scm.com/) |
| **Claude Code** | AI agent CLI | `npm install -g @anthropic-ai/claude-code` |

## Recommended

| Tool | Used By | Purpose | Install |
| ---- | ---- | ---- | ---- |
| **jq** | Hooks (4 of 8) | commit/push/asset/agent hooks 中的 JSON 解析 | 见下方 |
| **Python 3** | Hooks (2 of 8) | 数据文件的 JSON 验证 | [python.org](https://www.python.org/) |
| **Bash** | All hooks | Shell 脚本执行 | Git for Windows 已包含 |

### Installing jq

**Windows** (以下任一)：

```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**：

```
brew install jq
```

**Linux**：

```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## Platform Notes

### Windows

- Git for Windows 包含 **Git Bash**，它提供了 `settings.json` 中所有 hooks 使用的 `bash` 命令
- 确保 Git Bash 在你的 PATH 上（如果通过 Git 安装程序安装则为默认）
- Hooks 使用 `bash .claude/hooks/[name].sh` — 这在 Windows 上有效，因为 Claude Code 通过可以找到 `bash.exe` 的 shell 调用命令

### macOS / Linux

- Bash 原生可用
- 通过你的包管理器安装 `jq` 以获得完整的 hook 支持

## Verifying Your Setup

运行这些命令检查先决条件：

```bash
git --version          # 应显示 git version
bash --version         # 应显示 bash version
jq --version           # 应显示 jq version（可选）
python3 --version      # 应显示 python version（可选）
```

## What Happens Without Optional Tools

| Missing Tool | Effect |
| ---- | ---- |
| **jq** | commit 验证、push 保护、asset 验证和 agent audit hooks 静默跳过它们的检查。Commits 和 pushes 仍然有效。 |
| **Python 3** | commit 和 asset hooks 中的 JSON 数据文件验证被跳过。Invalid JSON 可以在没有警告的情况下被提交。 |
| **Both** | 所有 hooks 仍然执行且无错误（exit 0）但不提供验证。你在没有安全网的情况下飞行。 |

## Recommended IDE

Claude Code 可与任何编辑器配合使用，但此模板针对以下环境优化：

- **VS Code** with the Claude Code extension
- **Cursor** (Claude Code compatible)
- Terminal-based Claude Code CLI
