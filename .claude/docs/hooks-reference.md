# 激活的钩子

钩子在 `.claude/settings.json` 中配置并自动触发：

| Hook | Event | Trigger | Action |
| ---- | ----- | ------- | ------ |
| `validate-commit.sh` | PreToolUse (Bash) | `git commit` 命令 | 验证设计文档章节、JSON 数据文件、硬编码值、TODO 格式 |
| `validate-push.sh` | PreToolUse (Bash) | `git push` 命令 | 推送到受保护分支（develop/main）时警告 |
| `validate-assets.sh` | PostToolUse (Write/Edit) | 资产文件变更 | 检查 `assets/` 目录下文件的命名约定和 JSON 有效性 |
| `session-start.sh` | SessionStart | 会话开始 | 加载冲刺上下文、里程碑、git 活动；检测并预览活动会话状态文件以供恢复 |
| `detect-gaps.sh` | SessionStart | 会话开始 | 检测新项目（建议 /start）和代码/原型存在时缺失的文档，建议 /reverse-document 或 /project-stage-detect |
| `pre-compact.sh` | PreCompact | 上下文压缩 | 在压缩前将会话状态（active.md、修改的文件、WIP 设计文档）转储到对话中，以便在摘要中保留 |
| `post-compact.sh` | PostCompact | 压缩后 | 提醒 Claude 从 `active.md` 检查点恢复会话状态 |
| `notify.sh` | Notification | 通知事件 | 通过 PowerShell 显示 Windows 通知 |
| `session-stop.sh` | Stop | 会话结束 | 总结成就并更新会话日志 |
| `log-agent.sh` | SubagentStart | 代理启动 | 审计跟踪开始 — 记录带时间戳的子代理调用 |
| `log-agent-stop.sh` | SubagentStop | 代理停止 | 审计跟踪停止 — 完成子代理记录 |
| `validate-skill-change.sh` | PostToolUse (Write/Edit) | 技能文件变更 | 在任何 `.claude/skills/` 文件被写入或编辑后建议运行 `/skill-test` |

钩子参考文档：`.claude/docs/hooks-reference/`
钩子输入模式文档：`.claude/docs/hooks-reference/hook-input-schemas.md`