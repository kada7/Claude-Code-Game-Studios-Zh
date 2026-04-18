# 目录结构

```text
/
├── CLAUDE.md                    # 主配置
├── .claude/                     # Agent 定义、skills、hooks、规则、文档
├── src/                         # 游戏源代码（核心、游戏玩法、ai、网络、ui、工具）
├── assets/                      # 游戏资产（美术、音频、VFX、着色器、数据）
├── design/                      # 游戏设计文档（GDD、叙事、关卡、平衡）
├── docs/                        # 技术文档（架构、API、事后分析）
│   └── engine-reference/        # 精选的引擎 API 快照（版本固定）
├── tests/                       # 测试套件（单元、集成、性能、游戏测试）
├── tools/                       # 构建和流水线工具（ci、构建、资产流水线）
├── prototypes/                  # 一次性原型（与 src/ 隔离）
└── production/                  # 生产管理（冲刺、里程碑、发布）
    ├── session-state/           # 临时会话状态（active.md — gitignore 忽略）
    └── session-logs/            # 会话审计追踪（gitignore 忽略）
```
