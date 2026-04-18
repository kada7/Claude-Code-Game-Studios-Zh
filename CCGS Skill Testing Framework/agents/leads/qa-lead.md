# Agent 测试规范：qa-lead

## Agent 概览
**负责领域：** 测试策略、QL-STORY-READY gate、QL-TEST-COVERAGE gate、bug 严重性分类、发布质量门。
**不负责：** 功能实现（程序员）、游戏设计决策、创意指导、制作调度。
**模型层级：** Sonnet（单个系统分析 —— 故事准备度和覆盖率评估）。
**处理的 Gate ID：** QL-STORY-READY、QL-TEST-COVERAGE。

---

## 静态断言（结构）

通过读取 agent 的 `.claude/agents/qa-lead.md` frontmatter 验证：

- [ ] `description:` 字段存在且是领域特定的（涉及测试策略、故事准备度、覆盖率、bug 分类 —— 非通用描述）
- [ ] `allowed-tools:` 列表是读取导向的；可能包含用于故事文件、测试文件和编码标准的 Read；仅在需要运行测试命令时包含 Bash
- [ ] 模型层级为 `claude-sonnet-4-6`，根据 coordination-rules.md
- [ ] Agent 定义不宣称对实现决策或游戏设计拥有权限

---

## 测试用例

### 用例 1：领域内请求 —— 适当的输出格式
**场景：** 提交一个 "玩家受到危险瓷砖伤害" 的故事进行准备度检查。该故事有三个验收标准：(1) 玩家生命值减少危险瓷砖的伤害值，(2) 播放伤害视觉反馈，(3) 玩家在 0.5 秒内不能再次受到伤害（无敌窗口）。所有三个 AC 都是可测量和具体的。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: ADEQUATE`，并给出理由，确认所有三个 AC 都存在、具体且可测试。
**断言：**
- [ ] 裁决正好是 ADEQUATE / INADEQUATE 之一
- [ ] 裁决标记格式为 `QL-STORY-READY: ADEQUATE`
- [ ] 理由引用特定的 AC 数量（3）并确认每个都是可测量的
- [ ] 输出保持在 QA 范围内 —— 不评论机制是否设计得好

### 用例 2：领域外请求 —— 重定向或升级
**场景：** 开发人员要求 qa-lead 实现新物理系统的自动化测试框架。
**预期：** Agent 拒绝实现测试代码，并重定向到适当的程序员（gameplay-programmer 或 lead-programmer）。
**断言：**
- [ ] 不编写或提议代码实现
- [ ] 明确命名 `lead-programmer` 或 `gameplay-programmer` 为正确的处理者
- [ ] 可以定义测试应该验证什么（测试策略），但将代码编写推迟给程序员

### 用例 3：Gate 裁决 —— 正确的词汇
**场景：** 提交一个 "战斗感觉响应迅速且有冲击力" 的故事进行准备度检查。唯一的验收标准是："战斗应该让玩家感觉良好。" 这是主观且不可测量的。请求标记为 QL-STORY-READY。
**预期：** 返回 `QL-STORY-READY: INADEQUATE`，并具体识别不可测量的 AC，并提供关于如何使其可测试的指导（例如，"输入到命中反馈延迟 ≤ 100ms"）。
**断言：**
- [ ] 裁决正好是 ADEQUATE / INADEQUATE 之一 —— 非自由格式文本
- [ ] 裁决标记格式为 `QL-STORY-READY: INADEQUATE`
- [ ] 理由识别出不符合可测量性要求的特定 AC
- [ ] 提供关于如何重写 AC 使其可测试的可操作指导

### 用例 4：冲突升级 —— 正确的上级
**场景：** gameplay-programmer 和 qa-lead 对于断言 "敌人在 5 秒内访问所有路径点" 的测试是否足够确定性以成为有效的自动化测试存在分歧。gameplay-programmer 认为时间可变性使其不稳定；qa-lead 认为这是可接受的。
**预期：** qa-lead 承认技术上的不稳定性问题，并升级到 lead-programmer，以获取关于什么构成自动化测试可接受的确定性标准的技术裁决。
**断言：**
- [ ] 升级到 `lead-programmer` 以获取关于确定性标准的技术裁决
- [ ] 不单方面覆盖 gameplay-programmer 的不稳定性问题
- [ ] 明确表述升级："这是一个技术标准问题，而不是 QA 覆盖率问题"
- [ ] 不放弃覆盖率要求 —— 如果当前方法被裁定为不稳定，则要求一个确定性的替代方案

### 用例 5：上下文传递 —— 使用提供的上下文
**场景：** Agent 接收一个包含 coding-standards.md 测试标准部分的 gate 上下文块，其中规定：逻辑故事需要阻塞性自动化单元测试，视觉/感觉故事需要截图 + lead 签字（建议性），配置/数据故事需要通过冒烟检查（建议性）。提交一个分类为 "逻辑" 类型的故事，仅提供手动演练文档作为证据。
**预期：** 评估引用 coding-standards.md 中的特定测试证据要求，识别 "逻辑" 故事需要自动化单元测试（不仅仅是手动演练），并返回 INADEQUATE，并引用特定要求。
**断言：**
- [ ] 引用提供的上下文中的特定故事类型分类（"逻辑"）
- [ ] 引用 coding-standards.md 中逻辑故事的特定证据要求（自动化单元测试）
- [ ] 识别提交的证据类型（手动演练）对此故事类型不足
- [ ] 不将建议性级别的要求应用为阻塞性要求

---

## 协议合规性

- [ ] 仅使用 ADEQUATE / INADEQUATE 词汇返回 QL-STORY-READY 裁决
- [ ] 仅使用 ADEQUATE / INADEQUATE 词汇返回 QL-TEST-COVERAGE 裁决（或发布门的 PASS / FAIL）
- [ ] 保持在声明的 QA 和测试策略领域内
- [ ] 将技术标准争议升级到 lead-programmer
- [ ] 在输出中使用 gate ID（例如 `QL-STORY-READY: INADEQUATE`），而非内嵌散文裁决
- [ ] 不做出约束性的实现或游戏设计决策

---

## 覆盖范围说明
- QL-TEST-COVERAGE（冲刺或里程碑的整体覆盖率评估）未覆盖 —— 当覆盖率报告可用时应添加专用用例。
- Bug 严重性分类（P0/P1/P2 分类）在此未覆盖 —— 推迟到 /bug-triage 技能集成。
- 发布质量门行为（PASS / FAIL 词汇变体）未覆盖。
- QL-STORY-READY 与故事完成标准（/story-done 技能）之间的交互未覆盖。