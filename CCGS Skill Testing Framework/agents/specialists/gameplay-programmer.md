# Agent Test Spec: gameplay-programmer

## Agent 摘要
领域：游戏机制代码、玩家系统、战斗实现和交互功能。
不负责：UI 实现（ui-programmer）、AI 行为树（ai-programmer）、引擎/渲染系统（engine-programmer）。
模型层级：Sonnet（默认）。
未分配 gate ID。

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用游戏机制/玩家系统）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep — 排除仅由编排代理所需的工具
- [ ] 模型层级为 Sonnet（专家代理默认）
- [ ] Agent 定义不声称对 UI、AI 行为或引擎/渲染代码拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "Implement a melee combo system where three consecutive light attacks chain into a finisher."
**预期行为：**
- 生成遵循项目语言（GDScript/C#）和编码标准的代码或代码框架
- 将连击状态跟踪、输入窗口计时和终结技触发逻辑定义为独立的、可测试的方法
- 如果上下文中提供了相关 GDD 部分，则引用它
- 不实现 UI 反馈（委托给 ui-programmer）或 AI 反应（委托给 ai-programmer）
- 输出包含所有公共方法的文档注释，符合编码标准

### 用例 2：领域外请求 — 正确重定向
**输入：** "Build the main menu screen with pause and settings panels."
**预期行为：**
- 不生成菜单实现代码
- 明确声明这超出其领域范围
- 将请求重定向到 `ui-programmer`
- 可以指出如果暂停菜单需要读取游戏状态，它可以提供状态 API 接口

### 用例 3：领域边界 — 线程标记
**输入：** "The combo system is causing frame stutters; can you add threading to spread the input processing?"
**预期行为：**
- 不单方面实现线程或异步系统
- 将线程问题标记给 `engine-programmer`，并清晰描述热点路径
- 可以生成非线程重构以减少每帧工作量作为安全的临时步骤
- 记录升级过程以便 lead-programmer 知晓

### 用例 4：与已接受的 ADR 冲突
**输入：** "Change the damage calculation to use floating-point accumulation directly instead of the fixed-point formula in ADR-003."
**预期行为：**
- 识别提议的更改违反了 ADR-003（已接受状态）
- 不静默实现违规
- 将冲突标记给 `lead-programmer`，并提供 ADR 引用和权衡描述
- 仅在 lead-programmer 或 technical-director 明确决定覆盖后才会实施

### 用例 5：上下文传递 — 按照 GDD 规范实现
**输入：** GDD for "PlayerCombat" provided in context. Request: "Implement the stamina drain formula from the combat GDD."
**预期行为：**
- 读取所提供 GDD 的公式部分
- 按照书面内容实现确切公式 — 不发明新变量或调整系数
- 使耐力消耗成为数据驱动值（外部配置），而非硬编码常量
- 注意 GDD 边缘情况部分中的任何边缘情况，并在代码中处理它们

---

## 协议合规性

- [ ] 保持在声明的领域内（机制、玩家系统、战斗）
- [ ] 将领域外请求重定向到正确的代理（ui-programmer、ai-programmer、engine-programmer）
- [ ] 返回结构化发现（代码框架、方法签名、内联注释）而非自由形式的意见
- [ ] 未经明确委托，不修改 `src/gameplay/` 或 `src/core/` 之外的文件
- [ ] 标记 ADR 违规，而不是静默覆盖它们
- [ ] 使游戏值数据驱动，从不硬编码

---

## 覆盖范围说明
- 连击系统测试（用例 1）应在 `tests/unit/gameplay/` 中使用单元测试进行验证
- 线程升级（用例 3）验证代理不会过度侵入引擎领域
- ADR 冲突（用例 4）确认代理尊重架构治理流程
- 用例 1 和 5 共同验证代理按照规范实现而非即兴发挥