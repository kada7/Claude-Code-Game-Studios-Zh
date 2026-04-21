# Hook: pre-commit-design-check

## 触发条件

在提交任何修改 `design/` 或 `assets/data/` 目录下文件的 commit 前运行。

## 目的

确保设计文档和游戏数据文件在进入版本控制之前保持一致性和完整性。在问题传播之前捕获缺失的部分、损坏的交叉引用和无效数据。

## 实现

```bash
#!/bin/bash
# 提交前钩子：设计文档和游戏数据验证
# 放置在 .git/hooks/pre-commit 或通过钩子管理器配置

DESIGN_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^design/')
DATA_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '^assets/data/')

EXIT_CODE=0

# 检查设计文档的必需部分
if [ -n "$DESIGN_FILES" ]; then
    for file in $DESIGN_FILES; do
        if [[ "$file" == *.md ]]; then
            # 检查 GDD 文档的必需部分
            if [[ "$file" == design/gdd/* ]]; then
                for section in "Overview" "Detailed" "Edge Cases" "Dependencies" "Acceptance Criteria"; do
                    if ! grep -qi "$section" "$file"; then
                        echo "ERROR: $file missing required section: $section"
                        EXIT_CODE=1
                    fi
                done
            fi
        fi
    done
fi

# 验证 JSON 数据文件
if [ -n "$DATA_FILES" ]; then
    for file in $DATA_FILES; do
        if [[ "$file" == *.json ]]; then
            # 查找可用的 Python 命令
            PYTHON_CMD=""
            for cmd in python python3 py; do
                if command -v "$cmd" >/dev/null 2>&1; then
                    PYTHON_CMD="$cmd"
                    break
                fi
            done
            if [ -n "$PYTHON_CMD" ] && ! "$PYTHON_CMD" -m json.tool "$file" > /dev/null 2>&1; then
                echo "ERROR: $file is not valid JSON"
                EXIT_CODE=1
            fi
        fi
    done
fi

exit $EXIT_CODE
```

## Agent 集成

当此钩子失败时，提交者应：

1. 对于缺失的设计部分：调用 `game-designer` agent 来完成文档
2. 对于无效的 JSON：调用 `tools-programmer` agent 或手动修复
