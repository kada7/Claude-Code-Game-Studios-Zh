# 引擎参考文档

本目录包含为本项目所使用的游戏引擎精心整理的、版本固定的文档快照。这些文件的存在是因为 **LLM 知识具有截止日期** 且游戏引擎更新频繁。

## 存在原因

Claude 的训练数据具有知识截止日期（当前为 2025 年 5 月）。像 Godot、Unity 和 Unreal 这样的游戏引擎会发布更新，引入破坏性的 API 变更、新功能以及废弃的模式。如果没有这些参考文件，Agent 将会建议过时的代码。

## 结构

每个引擎都有其自己的目录：

```
<engine>/
├── VERSION.md              # 固定版本、验证日期、知识差距窗口
├── breaking-changes.md     # 版本间的 API 变更，按风险级别组织
├── deprecated-apis.md      # "不要使用 X → 使用 Y" 查询表
├── current-best-practices.md  # 模型训练数据中未包含的新实践
└── modules/                # 各子系统的快速参考（每篇最多约 150 行）
    ├── rendering.md
    ├── physics.md
    └── ...
```

## Agent 如何使用这些文件

引擎专家 Agent 被指示：

1. 读取 `VERSION.md` 以确认当前引擎版本
2. 在建议任何引擎 API 之前检查 `deprecated-apis.md`
3. 查阅 `breaking-changes.md` 获取版本特定的注意事项
4. 读取相关的 `modules/*.md` 以进行子系统特定工作

## 维护

### 何时更新

- 升级引擎版本后
- 当 LLM 模型更新时（新的知识截止日期）
- 运行 `/refresh-docs` 后（如果可用）
- 当你发现模型出错的 API 时

### 如何更新

1. 使用新的引擎版本和日期更新 `VERSION.md`
2. 为版本过渡添加新条目到 `breaking-changes.md`
3. 将新废弃的 API 移至 `deprecated-apis.md`
4. 使用新模式更新 `current-best-practices.md`
5. 使用 API 变更更新相关的 `modules/*.md`
6. 在所有修改的文件上设置“最后验证”日期

### 质量规则

- 每个文件必须具有“最后验证：YYYY-MM-DD”日期
- 模块文件保持在 150 行以内（上下文预算）
- 包含显示正确/错误模式的代码示例
- 链接至官方文档 URL 以供验证
- 仅记录与模型训练数据不同的内容