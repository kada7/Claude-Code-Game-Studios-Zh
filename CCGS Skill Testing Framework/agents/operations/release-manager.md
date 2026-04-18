# Agent Test Spec: release-manager

## Agent 摘要
- **领域**: Release pipeline 管理，平台认证清单（Nintendo、Sony、Microsoft、Apple、Google），商店提交流程，平台技术要求合规性，语义版本编号，发布分支管理
- **不负责**: 游戏设计决策，QA 测试策略或测试用例设计（qa-lead），QA 测试执行（qa-tester），构建基础设施（devops-engineer）
- **模型层级**: Sonnet
- **Gate IDs**: 可能在发布阶段通过 `/gate-check` 调用；LAUNCH BLOCKED 裁决是 release-manager 的主要升级输出

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 release pipeline、认证、商店提交）
- [ ] `allowed-tools:` 列表与 agent 角色匹配（对 production/releases/ 目录的 Read/Write 权限；没有游戏源代码或测试工具）
- [ ] 模型层级是 Sonnet（操作专家的默认层级）
- [ ] Agent 定义不声称对 QA 策略、游戏设计或构建基础设施拥有权限

---

## 测试用例

### 用例 1：领域内请求 — Nintendo Switch 的平台认证清单
**输入**: "Generate the certification checklist for our Nintendo Switch submission."
**预期行为**:
- 生成一个结构化的清单，涵盖与游戏类型相关的 Nintendo Lotcheck 要求
- 包含类别：内容评级（适用的 CERO/PEGI/ESRB），保存数据处理，离线模式合规性，错误处理（连接丢失，存储空间满），控制器要求（Joy-Con、Pro Controller 支持），睡眠/唤醒行为，截图/视频捕获合规性
- 将输出格式化为带有通过/失败列的编号清单
- 注明 Nintendo 的完整 Lotcheck 指南需要许可开发者账户才能访问，并标记任何需要根据当前指南文档手动验证的项目
- 不生成虚构的要求 ID — 使用已知的公共要求或明确标记不确定性

### 用例 2：领域外请求 — 设计测试用例
**输入**: "Write test cases for our save system to make sure it passes certification."
**预期行为**:
- 不生成测试用例规范
- 明确声明："测试用例设计由 qa-lead（策略）和 qa-tester（执行）负责；我可以提供保存系统必须满足的认证要求，qa-lead 可以使用这些要求来设计测试"
- 可选地提供保存系统相关的认证要求列表

### 用例 3：领域边界 — 认证失败（评级问题）
**输入**: "Our build was rejected by the ESRB. The rejection cites content not reflected in our rating submission: a hidden profanity string in debug output that appeared in a screenshot."
**预期行为**:
- 发布 LAUNCH BLOCKED 裁决，并引用特定的平台要求（ESRB 提交准确性要求）
- 确定所需的立即行动：在重新提交之前定位并删除所有包含不当内容的调试输出
- 注明重新提交流程：如果需要，必须使用更新的内容描述符重新提交修正后的构建
- 不淡化问题 — 认证拒绝是阻塞事件，不是建议
- 升级给 producer：记录对发布时间线的影响

### 用例 4：版本编号冲突 — hotfix 与发布分支
**输入**: "Our release branch is at v1.2.0. A hotfix was applied directly on main and tagged v1.2.1. Now the release branch also has changes that need to ship as v1.2.1 but they're different changes."
**预期行为**:
- 识别冲突：两个不同的变更集被分配了相同的版本标签
- 应用语义版本解析：必须重新标记其中一个 — 如果 v1.2.1 已经发布，发布分支的变更应变为 v1.2.2；如果 v1.2.1 尚未发布，与 devops-engineer 协调合并或重新标记
- 不接受相同版本号指向两个不同构建的状态
- 注明一旦版本提交到商店，就不能重复使用 — 将此标记为潜在的商店提交阻塞问题

### 用例 5：上下文传递 — 发布日期约束和认证前置时间
**输入上下文**: 目标发布日期是 2026-06-01。当前日期是 2026-04-06。Nintendo Lotcheck 通常需要 4-6 周。
**输入**: "What should we prioritize on the certification checklist given our timeline?"
**预期行为**:
- 计算可用窗口：距离发布日期约 8 周；Nintendo Lotcheck 需要 4-6 周，意味着提交必须在 2026-04-20 至 2026-05-04 左右准备好，以允许潜在的重新提交周期
- 标记单个拒绝周期将消耗缓冲时间 — 优先处理历史上与 Lotcheck 拒绝相关的项目（保存数据、离线模式、错误处理）
- 按认证前置时间影响排序清单，而不是按感知难度排序
- 不生成假设首次认证通过的清单 — 包含重新提交时间

---

## 协议合规性

- [ ] 保持在声明的领域内（release pipeline、认证清单、版本编号、商店提交）
- [ ] 将测试用例设计请求重定向到 qa-lead/qa-tester，不生成测试规范
- [ ] 为认证失败发布 LAUNCH BLOCKED 裁决 — 不降级为建议
- [ ] 正确应用语义版本控制，并将版本冲突标记为商店阻塞问题
- [ ] 使用提供的时间线数据，按认证前置时间优先处理清单项目

---

## 覆盖说明
- 用例 3（LAUNCH BLOCKED 裁决）是最关键的测试 — 此 agent 的主要安全输出是阻止不良发布
- 用例 5 需要当前日期和发布日期上下文；验证 agent 使用实际日期，而不是占位符估计
- 认证要求随时间变化 — 如果 agent 生成可能过时的特定要求 ID，请标记
- 没有自动运行器；通过 `/skill-test` 手动审查或进行