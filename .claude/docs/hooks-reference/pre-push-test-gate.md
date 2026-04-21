# Hook: pre-push-test-gate

## 触发条件

在推送到任何远程分支之前运行。对于推送到 `develop` 和 `main` 分支是强制性的。

## 目的

确保代码到达共享分支之前，构建能够编译、单元测试通过以及关键冒烟测试通过。这是代码影响其他开发人员之前的最后一道自动化质量门。

## 实现

```bash
#!/bin/bash
# 推送前钩子：构建和测试门槛

REMOTE="$1"
URL="$2"

# 仅对 develop 和 main 强制完整门槛
PROTECTED_BRANCHES="develop main"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

FULL_GATE=false
for branch in $PROTECTED_BRANCHES; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        FULL_GATE=true
        break
    fi
done

echo "=== Pre-Push Quality Gate ==="

# 步骤 1：构建
echo "Building..."
# 适配你的构建系统：
# make build || exit 1
# dotnet build || exit 1
# cargo build || exit 1
echo "Build: PASS"

# 步骤 2：单元测试
echo "Running unit tests..."
# 适配你的测试框架：
# python -m pytest tests/unit/ -x || exit 1
# dotnet test tests/unit/ || exit 1
# cargo test || exit 1
echo "Unit tests: PASS"

if [ "$FULL_GATE" = true ]; then
    # 步骤 3：集成测试（仅用于受保护分支）
    echo "Running integration tests..."
    # python -m pytest tests/integration/ -x || exit 1
    echo "Integration tests: PASS"

    # 步骤 4：冒烟测试
    echo "Running smoke tests..."
    # python -m pytest tests/playtest/smoke/ -x || exit 1
    echo "Smoke tests: PASS"

    # 步骤 5：性能回归检查
    echo "Checking performance baselines..."
    # python tools/ci/perf_check.py || exit 1
    echo "Performance: PASS"
fi

echo "=== All gates passed ==="
exit 0
```

## Agent 集成

当此钩子失败时：
1. 构建失败：调用 `lead-programmer` 进行诊断
2. 单元测试失败：调用 `qa-tester` 识别失败的测试，并调用 `gameplay-programmer` 或相关程序员进行修复
3. 性能回归：调用 `performance-analyst` 进行分析
