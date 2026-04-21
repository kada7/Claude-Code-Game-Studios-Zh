# Hook: post-merge-asset-validation

## 触发条件

在合并到 `develop` 或 `main` 分支后运行，并且合并包含对 `assets/` 目录的更改。

## 目的

验证合并分支中的所有资产是否符合命名规范、大小预算和格式要求。防止不合规资产在集成分支上积累。

## 实现

```bash
#!/bin/bash
# 合并后钩子：资产验证
# 根据项目标准检查合并的资产

MERGED_ASSETS=$(git diff --name-only HEAD@{1} HEAD | grep -E '^assets/')

if [ -z "$MERGED_ASSETS" ]; then
    exit 0
fi

EXIT_CODE=0
WARNINGS=""

for file in $MERGED_ASSETS; do
    filename=$(basename "$file")

    # 检查命名约定（小写，下划线）
    if echo "$filename" | grep -qE '[A-Z[:space:]-]'; then
        WARNINGS="$WARNINGS\n命名: $file -- 必须为小写下划线格式"
        EXIT_CODE=1
    fi

    # 检查纹理尺寸（必须是 2 的幂）
    if [[ "$file" == *.png || "$file" == *.jpg ]]; then
        # 需要 ImageMagick
        if command -v identify &> /dev/null; then
            dims=$(identify -format "%w %h" "$file" 2>/dev/null)
            if [ -n "$dims" ]; then
                w=$(echo "$dims" | cut -d' ' -f1)
                h=$(echo "$dims" | cut -d' ' -f2)
                if (( (w & (w-1)) != 0 || (h & (h-1)) != 0 )); then
                    WARNINGS="$WARNINGS\n尺寸: $file -- 尺寸 ${w}x${h} 不是2的幂"
                fi
            fi
        fi
    fi

    # 检查文件大小预算
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ -n "$size" ]; then
        # 纹理：最大 4MB
        if [[ "$file" == assets/art/* ]] && [ "$size" -gt 4194304 ]; then
            WARNINGS="$WARNINGS\n预算: $file -- ${size} 字节超出 4MB 纹理预算"
            EXIT_CODE=1
        fi
        # 音频：音乐最大 10MB，SFX 最大 512KB
        if [[ "$file" == assets/audio/sfx* ]] && [ "$size" -gt 524288 ]; then
            WARNINGS="$WARNINGS\n预算: $file -- ${size} 字节超出 512KB SFX 预算"
        fi
    fi
done

if [ -n "$WARNINGS" ]; then
    echo "=== 资产验证报告 ==="
    echo -e "$WARNINGS"
    echo "================================"
    echo "运行 /asset-audit 获取完整报告。"
fi

exit $EXIT_CODE
```

## Agent 集成

当此钩子报告问题时：
1. 对于命名违规：手动修复或调用 `art-director` 寻求指导
2. 对于大小违规：调用 `technical-artist` 寻求优化建议
3. 对于完整审计：运行 `/asset-audit` skill
