# 钩子：pre-commit-code-quality

## 触发

在任何修改 `src/` 目录下文件的提交之前运行。

## 目的

在代码进入版本控制之前强制执行编码标准。捕获样式违规、缺失文档、过于复杂的方法以及应数据驱动的硬编码值。

## 实现

```bash
#!/bin/bash
# 预提交钩子：代码质量检查
# 根据您的语言和工具调整具体检查

CODE_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^src/')

EXIT_CODE=0

if [ -n "$CODE_FILES" ]; then
    for file in $CODE_FILES; do
        # 检查游戏玩法代码中的硬编码魔法数字
        if [[ "$file" == src/gameplay/* ]]; then
            # 查找可能是平衡值的数字字面量
            # 根据您的语言调整模式
            if grep -nE '(damage|health|speed|rate|chance|cost|duration)[[:space:]]*[:=][[:space:]]*[0-9]+' "$file"; then
                echo "WARNING: $file may contain hardcoded gameplay values. Use data files."
                # 仅警告，不阻塞
            fi
        fi

        # 检查没有分配人的 TODO/FIXME
        if grep -nE '(TODO|FIXME|HACK)[^(]' "$file"; then
            echo "WARNING: $file has TODO/FIXME without owner tag. Use TODO(name) format."
        fi

        # 运行语言特定的 linter（取消注释适当的行）
        # 对于 GDScript：gdlint "$file" || EXIT_CODE=1
        # 对于 C#：dotnet format --check "$file" || EXIT_CODE=1
        # 对于 C++：clang-format --dry-run -Werror "$file" || EXIT_CODE=1
    done

    # 为修改的系统运行单元测试
    # 取消注释并根据您的测试框架调整
    # python -m pytest tests/unit/ -x --quiet || EXIT_CODE=1
fi

exit $EXIT_CODE
```

## 代理集成

当此钩子失败时：
1. 对于样式违规：使用您的格式化程序自动修复或调用 `lead-programmer`
2. 对于硬编码值：调用 `gameplay-programmer` 将值外部化
3. 对于测试失败：调用 `qa-tester` 进行诊断并调用 `gameplay-programmer` 修复