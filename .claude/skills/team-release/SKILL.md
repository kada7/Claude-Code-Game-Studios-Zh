---
name: team-release
description: "编排发布团队:协调 release-manager、qa-lead、devops-engineer 和 producer，从候选版本执行到部署的发布。"
argument-hint: "[version number or 'next']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
**参数检查:** 如果未提供版本号:
1. 读取 `production/session-state/active.md` 和 `production/milestones/` 中最近的文件 (如果存在) 以推断目标版本。
2. 如果找到版本: 报告 "未提供版本参数 — 从里程碑数据推断出 [version]。继续。" 然后使用 `AskUserQuestion` 确认: "发布 [version]。是否正确?"
3. 如果无法发现版本: 使用 `AskUserQuestion` 询问 "应该发布什么版本号? (例如, v1.0.0)" 并在继续前等待用户输入。不要默认硬编码版本字符串。

调用此 skill 时，通过结构化流程编排发布团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示子代理的建议作为可选项。在对话中写入代理的完整分析，然后使用简洁的标签捕获决策。用户必须批准才能进入下一阶段。

## 团队组成
- **release-manager** — 发布分支、版本控制、更新日志、部署
- **qa-lead** — 测试签署、回归套件、发布质量门
- **devops-engineer** — 构建流程、工件、部署自动化
- **security-engineer** — 预发布安全审计 (如果游戏具有在线/多人游戏功能或玩家数据则调用)
- **analytics-engineer** — 验证遥测事件正确触发且仪表板已上线
- **community-manager** — 补丁说明、发布公告、面向玩家的消息传递
- **producer** — 进行/不进行决策、利益相关者沟通、调度

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: release-manager` — 发布分支、版本控制、更新日志、部署
- `subagent_type: qa-lead` — 测试签署、回归套件、发布质量门
- `subagent_type: devops-engineer` — 构建流程、工件、部署自动化
- `subagent_type: security-engineer` — 在线/多人/数据功能的安全审计
- `subagent_type: analytics-engineer` — 遥测事件验证和仪表板准备就绪
- `subagent_type: community-manager` — 补丁说明和发布沟通
- `subagent_type: producer` — 进行/不进行决策、利益相关者沟通
- `subagent_type: network-programmer` — 网络代码稳定性签署 (如果游戏有多人游戏则调用)

始终在代理的提示中提供完整上下文 (版本号、里程碑状态、已知问题)。在流程允许的情况下并行启动独立代理 (例如，阶段 3 代理可以同时运行)。

## 流程

### 阶段 1: 发布规划
委派给 **producer**:
- 确认所有里程碑验收标准已满足
- 识别此发布中推迟的任何范围项目
- 设定目标发布日期并传达给团队
- 输出: 包含范围确认的发布授权

### 阶段 2: 发布候选
委派给 **release-manager**:
- 从商定的提交中切出发布分支
- 在所有相关文件中提升版本号
- 使用 `/release-checklist` 生成发布清单
- 冻结分支 — 无功能更改，仅 bug 修复
- 输出: 发布分支名称和清单

### 阶段 3: 质量门 (并行)
并行委派:
- **qa-lead**: 执行完整回归测试套件。测试所有关键路径。验证无 S1/S2 bugs。签署质量。
- **devops-engineer**: 为所有目标平台构建发布工件。验证构建干净且可重现。在 CI 中运行自动化测试。
- **security-engineer** *(如果游戏具有在线功能、多人游戏或玩家数据)*: 进行预发布安全审计。审查身份验证、反作弊、数据隐私合规性。签署安全态势。
- **network-programmer** *(如果游戏具有多人游戏)*: 签署网络代码稳定性。验证延迟补偿、重新连接处理和负载下的带宽使用。

### 阶段 4: 本地化、性能和分析
委派 (如果资源可用，可与阶段 3 并行运行):
- 验证所有字符串已翻译 (如果可用则委派给 **localization-lead**)
- 针对目标运行性能基准测试 (如果可用则委派给 **performance-analyst**)
- **analytics-engineer**: 验证所有遥测事件在发布构建上正确触发。确认仪表板正在接收数据。检查关键漏斗 (入职、进度、货币化 (如果适用)) 是否已工具化。
- 输出: 本地化、性能和分析签署

### 阶段 5: 进行/不进行
委派给 **producer**:
- 收集来自以下人员的签署: qa-lead、release-manager、devops-engineer、security-engineer (如果在阶段 3 中生成)、network-programmer (如果在阶段 3 中生成) 和 technical-director
- 评估任何开放问题 — 它们是阻塞性的还是可以发布?
- 做出进行/不进行决定
- 输出: 带有理由的发布决策

**如果 producer 宣布不进行:**
- 立即展示决定: "PRODUCER: 不进行 — [理由，例如在阶段 3 中发现 S1 bug]。"
- 使用 `AskUserQuestion` 提供选项:
  - 修复阻止程序并重新运行受影响阶段
  - 将发布推迟到稍后日期
  - 用记录的正当理由覆盖不进行 (用户必须提供书面理由)
- **完全跳过阶段 6** — 不要标记、部署到暂存、部署到生产或生成 community-manager。
- 生成总结阶段 1-5 的部分报告以及跳过了什么 (阶段 6) 和原因。
- 裁决: **BLOCKED** — 发布未部署。

### 阶段 6: 部署 (如果进行)
委派给 **release-manager** + **devops-engineer**:
- 在版本控制中标记发布
- 使用 `/changelog` 生成更新日志
- 部署到暂存进行最终冒烟测试
- 部署到生产
- 发布后监控 48 小时

并行委派给 **community-manager** (与部署并行):
- 使用 `/patch-notes [version]` 最终确定补丁说明
- 准备发布公告 (商店页面更新、社交媒体、社区帖子)
- 如果有任何 S3+ 问题发布，起草已知问题帖子
- 输出: 所有面向玩家的发布沟通，准备在部署确认时发布

### 阶段 7: 发布后
- **release-manager**: 生成发布报告 (发布了什么、推迟了什么、指标)
- **producer**: 更新里程碑跟踪，传达给利益相关者
- **qa-lead**: 监控传入的 bug 报告以进行回归
- **community-manager**: 发布所有面向玩家的沟通，监控社区情绪
- **analytics-engineer**: 确认实时仪表板健康; 如果任何关键事件缺失则发出警报
- 如果出现问题，安排发布后回顾

## 错误恢复协议

如果任何生成的代理 (通过 Task) 返回 BLOCKED、错误或无法完成:

1. **立即展示**: 在向用户报告 "[AgentName]: BLOCKED — [reason]"，然后继续到依赖阶段
2. **评估依赖关系**: 检查被阻止代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点。
3. **提供选项** 通过 AskUserQuestion 提供选择:
   - 跳过此代理并记录最终报告中的差距
   - 以更窄的范围重试
   - 在此处停止并首先解决阻止程序
4. **始终生成部分报告** — 输出已完成的内容。切勿因为代理被阻止而丢弃工作。

常见阻止程序:
- 输入文件缺失 (story 未找到, GDD 不存在) → 重定向到创建它的 skill
- ADR 状态为 Proposed → 不实现; 先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个 stories
- ADR 和 story 之间的冲突说明 → 展示冲突，不要猜测

## 文件写入协议

所有文件写入 (发布清单、更新日志、补丁说明、部署脚本) 都委派给子代理和子技能。每个都强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要报告: 发布版本、范围、质量门结果、进行/不进行决策、部署状态和监控计划。

裁决: **COMPLETE** — 发布已执行并部署。
裁决: **BLOCKED** — 发布已停止; 进行/不进行为否或硬阻止程序未解决。

## 后续步骤

- 监控发布后仪表板 48 小时。
- 如果发布期间出现重大问题，运行 `/retrospective`。
- 成功部署后更新 `production/stage.txt` 为 `Live`。
