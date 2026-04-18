# 技能测试规范：/team-release

## 技能摘要

通过一个从发布候选到部署和发布后监控的7阶段流水线，协调发布团队。协调 release-manager、qa-lead、devops-engineer、producer、security-engineer（可选，在线/多人游戏需要）、network-programmer（可选，多人游戏需要）、analytics-engineer 和 community-manager。第3阶段 Agent 并行运行。以 go/no-go 决策结束；如果 producer 调用 NO-GO，则跳过部署（第6阶段）。以发布后监控计划结束。

---

## 静态断言（结构）

- [ ] 拥有必需的前言字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 拥有≥2个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 在文件写入协议部分包含"May I write"语言（委托给子代理）
- [ ] 拥有一个文件写入协议部分，声明编排器不直接写入文件
- [ ] 拥有一个错误恢复协议部分，包含四个恢复选项（surface / assess / offer options / partial report）
- [ ] 拥有一个引用发布后监控、`/retrospective` 和 `production/stage.txt` 的下一步交接
- [ ] 在需要用户批准才能继续的阶段转换处使用 `AskUserQuestion`
- [ ] 明确声明第3阶段代理（qa-lead、devops-engineer，以及可选的 security-engineer、network-programmer）并行运行
- [ ] 第6阶段（部署）以第5阶段的GO决策为条件
- [ ] security-engineer 被描述为以在线功能/玩家数据为条件——并非总是生成

---

## 测试用例

### 用例1：顺利路径（单人游戏）——所有阶段完成，版本已部署

**Fixture:**
- `production/stage.txt` 存在且包含 Production 或更高阶段
- 里程碑验收标准全部满足（producer 可确认）
- 无在线功能，无多人游戏，无玩家数据收集
- 当前分支上的所有 CI 构建均为干净
- 无未解决的 S1/S2 bug
- `production/sprints/` 包含此里程碑已完成的冲刺故事

**Input:** `/team-release v1.0.0`

**预期行为:**
1. 阶段1：通过 Task 生成 `producer`；确认所有里程碑验收标准已满足；识别任何延期范围；生成发布授权；呈现给用户；AskUserQuestion：用户在阶段2开始前批准
2. 阶段2：通过 Task 生成 `release-manager`；从约定的提交点切出发布分支；提升版本号；调用 `/release-checklist`；冻结分支；输出：分支名称和检查清单；AskUserQuestion：用户在阶段3开始前批准
3. 阶段3（并行）：同时为 `qa-lead`（回归测试套件、关键路径签核）和 `devops-engineer`（构建工件、CI验证）发出 Task 调用；security-engineer 不被生成（无在线功能）；network-programmer 不被生成（无多人游戏）；两者均成功完成
4. 阶段4：验证本地化字符串全部翻译；`analytics-engineer` 验证遥测在发布构建上正确触发；性能基准测试通过；生成签核
5. 阶段5：通过 Task 生成 `producer`；收集来自 qa-lead、release-manager、devops-engineer 的签核；无未解决的阻塞问题；producer 声明 GO；AskUserQuestion：用户看到 GO 决策并确认部署
6. 阶段6：生成 `release-manager` + `devops-engineer`（并行）；在版本控制中标记发布；调用 `/changelog`；部署到 staging；冒烟测试通过；部署到 production；同时生成 `community-manager`，通过 `/patch-notes v1.0.0` 完成补丁说明并准备发布公告
7. 阶段7：release-manager 生成发布报告；producer 更新里程碑跟踪；qa-lead 开始监控回归；community-manager 发布沟通；analytics-engineer 确认实时仪表板健康
8. 裁决：COMPLETE — 发布已执行并部署

**断言:**
- [ ] 阶段3 qa-lead 和 devops-engineer 的 Task 调用同时发出，而非顺序发出
- [ ] 当游戏没有在线功能、多人游戏或玩家数据时，security-engineer 不被生成
- [ ] 阶段5 producer 在声明 GO 之前收集所有必需方的签核
- [ ] 阶段6 部署仅在用户确认 GO 决策后开始
- [ ] `/changelog` 由 release-manager 在阶段6调用（不直接写入）
- [ ] `/patch-notes v1.0.0` 由 community-manager 在阶段6调用
- [ ] 阶段7 监控计划包含48小时的发布后监控承诺
- [ ] 下一步建议在成功部署后将 `production/stage.txt` 更新为 `Live`
- [ ] 裁决：COMPLETE 出现在最终输出中

---

### 用例2：Go/No-Go: NO — 第3阶段发现S1 bug，部署被跳过

**Fixture:**
- 发布候选分支存在于 v0.9.0
- qa-lead 在第3阶段回归测试期间发现了一个先前未报告的 S1 崩溃（主菜单中）
- devops-engineer 构建干净且工件已就绪
- producer 知晓该 S1 bug

**Input:** `/team-release v0.9.0`

**预期行为:**
1. 阶段1-2 正常完成；发布候选被切出
2. 阶段3（并行）：devops-engineer 返回干净的构建签核；qa-lead 返回时标识出一个 S1 bug 且回归测试套件失败；qa-lead 声明质量门：NOT PASSED
3. 编排器立即呈现 qa-lead 的结果："QA-LEAD: 发现 S1 bug — [崩溃描述]。质量门：NOT PASSED。"
4. 阶段4 谨慎进行或暂停（AskUserQuestion：继续阶段4还是跳过到阶段5进行 go/no-go？）
5. 阶段5：通过 Task 生成 `producer`；producer 收到 qa-lead 的 NOT PASSED 裁决；无 S1 签核可用；producer 声明 NO-GO，理由："S1 bug [ID] 未解决且未关闭。发布不安全。"
6. AskUserQuestion：向用户呈现 NO-GO 决策和 S1 bug 详情；选项：修复 bug 并重新运行、延期发布、或覆盖（需记录理由）
7. 阶段6（部署）完全跳过 — 无分支标记、无部署到 staging、无部署到 production
8. community-manager 不在阶段6生成（无部署可公告）
9. 技能以部分报告结束，总结已完成的内容（阶段1-5）和跳过的内容（阶段6）及原因
10. 裁决：BLOCKED — 发布未部署

**断言:**
- [ ] qa-lead 的 S1 bug 发现在阶段3完成后立即呈现给用户 — 不会等到阶段5才显示
- [ ] producer 的 NO-GO 决策明确引用 S1 bug 和质量门结果
- [ ] 当 producer 声明 NO-GO 时，阶段6 部署完全跳过
- [ ] community-manager 不会为补丁说明或发布公告在 NO-GO 时生成
- [ ] 部分报告清楚说明哪些阶段已完成、哪些被跳过，并附有原因
- [ ] 当部署因 NO-GO 被跳过时，裁决：BLOCKED（非 COMPLETE）
- [ ] AskUserQuestion 向用户提供解决选项（修复并重新运行 / 延期 / 覆盖并记录理由）
- [ ] 覆盖路径（如果选择）要求用户在进行阶段6前提供记录的理由

---

### 用例3：在线游戏的安全审计 — security-engineer 在第3阶段被生成

**Fixture:**
- 游戏具有多人游戏功能并存储玩家账户数据
- 发布候选存在于 v2.1.0
- qa-lead 和 devops-engineer 均返回干净的签核
- 根据团队组成规则需要 security-engineer 审计

**Input:** `/team-release v2.1.0`

**预期行为:**
1. 阶段1-2 正常完成
2. 阶段3（并行）：编排器检测到游戏具有在线/多人游戏功能和玩家数据；同时为 `qa-lead`、`devops-engineer` 和 `security-engineer` 发出 Task 调用；同时生成 `network-programmer` 以获取网络代码稳定性签核
3. security-engineer 进行发布前安全审计：审查认证流程、反作弊存在性、数据隐私合规性；返回签核
4. network-programmer 验证延迟补偿、重连处理、负载下的带宽；返回签核
5. 所有四个阶段3代理完成；在阶段4开始前收集它们的结果
6. 阶段5：producer 在做出 go/no-go 决策前，收集所有四个阶段3代理（qa-lead、devops-engineer、security-engineer、network-programmer）的签核
7. 剩余阶段正常进行至 COMPLETE

**断言:**
- [ ] 当游戏具有在线功能、多人游戏或玩家数据时，security-engineer 会在阶段3被生成 — 不会跳过
- [ ] 当游戏具有多人游戏时，network-programmer 会在阶段3被生成
- [ ] 所有四个阶段3 Task 调用（qa-lead、devops-engineer、security-engineer、network-programmer）同时发出
- [ ] security-engineer 审计涵盖认证、反作弊和数据隐私合规性
- [ ] 阶段5 producer 的签核收集包括 security-engineer（四方，而非两方）
- [ ] 阶段6 部署在 security-engineer 签核前不会开始
- [ ] 技能不会将 security-engineer 视为具有玩家数据的游戏的可选项

---

### 用例4：本地化缺失 — 未翻译字符串阻碍发布

**Fixture:**
- 发布候选存在于 v1.2.0
- 阶段3（qa-lead、devops-engineer）以干净的签核完成
- 阶段4：本地化验证检测到法语语言环境中的47个未翻译字符串（游戏本地化范围内支持的语言）
- localization-lead 可作为可委托代理使用

**Input:** `/team-release v1.2.0`

**预期行为:**
1. 阶段1-3 以干净的签核完成
2. 阶段4：本地化验证步骤检测到未翻译字符串；识别出法语语言环境中的47个字符串；生成 localization-lead（如果可用）以评估严重性
3. 编排器呈现："LOCALIZATION MISS: 在法语语言环境中发现47个未翻译字符串。发布前需要本地化签核。"
4. AskUserQuestion：呈现选项 — (a) 修复翻译并重新运行阶段4, (b) 从本次发布中移除法语语言环境, (c) 按原样发布并添加已知问题说明
5. 如果用户选择 (a)：在提供翻译后重新运行阶段4；技能等待本地化签核
6. 当本地化签核未完成时，阶段5 go/no-go 不会进行
7. 在本地化问题解决或明确豁免之前，发布被阻止（不进入阶段6）

**断言:**
- [ ] 阶段4 中的本地化验证检测未翻译字符串并进行计数（不仅仅是“某些字符串缺失”）
- [ ] 支持的语言环境的未翻译字符串会在阶段5之前阻塞流水线
- [ ] 使用 AskUserQuestion 向用户提供解决选项 — 技能不会自动豁免
- [ ] 当本地化签核待定时，不会调用阶段5 go/no-go
- [ ] 如果用户选择重新运行阶段4：技能不需要从阶段1重新开始
- [ ] 如果用户明确豁免（按原样发布）：豁免情况在发布报告（阶段7）中作为已知问题记录
- [ ] 技能不会伪造翻译字符串以解除阻塞

---

### 用例5：无参数 — 技能推断版本或询问

**Fixture (variant A — milestone data present):**
- `production/milestones/` 存在且包含里程碑文件；最近的里程碑是 "v1.1.0 — Gold"
- `production/session-state/active.md` 引用版本或里程碑

**Fixture (variant B — no discoverable version):**
- `production/milestones/` 不存在
- `production/session-state/active.md` 不引用版本
- 不存在可用于推断版本的 git 标签

**Input:** `/team-release` (no argument)

**预期行为 (variant A):**
1. 阶段1：未提供参数；读取 `production/session-state/active.md`；读取 `production/milestones/` 中最新的里程碑文件
2. 推断 v1.1.0 为目标版本；报告"未提供版本参数 — 从里程碑数据推断为 v1.1.0。继续。"
3. 在正式进入阶段1前通过 AskUserQuestion 确认："发布 v1.1.0。是否正确？"
4. 如同输入 `/team-release v1.1.0` 一样进行

**预期行为 (variant B):**
1. 阶段1：未提供参数；读取可用的状态文件 — 未发现版本
2. 使用 AskUserQuestion："应发布哪个版本号？（例如，v1.0.0）"
3. 等待用户输入后再继续

**断言:**
- [ ] 当未提供参数时，技能不会默认为硬编码的版本字符串
- [ ] 技能在询问前读取 `production/session-state/active.md` 和里程碑文件（variant A）
- [ ] 推断的版本在继续前通过 AskUserQuestion 与用户确认（variant A）
- [ ] 当无法发现版本时，使用 AskUserQuestion — 技能不会猜测（variant B）
- [ ] 当里程碑文件不存在时，技能不会报错 — 它会回退到询问（variant B）

---

## 协议合规性

- [ ] `AskUserQuestion` 在每个阶段转换关口使用（阶段1后、阶段2后、如果有问题则在阶段3/4后、阶段5 go/no-go后）
- [ ] 阶段3代理始终作为并行 Task 调用发出 — qa-lead 和 devops-engineer 从不顺序执行
- [ ] security-engineer 根据游戏功能有条件地生成 — 当功能存在时从不静默跳过
- [ ] 文件写入协议：编排器从不直接调用 Write/Edit — 所有写入都委托给子代理或子技能
- [ ] 阶段6 部署严格以阶段5的GO裁决为条件 — 从不自动触发
- [ ] 错误恢复：任何 BLOCKED 代理在继续到依赖阶段之前立即呈现
- [ ] 如果任何阶段失败或流水线停止，始终生成部分报告（用例2）
- [ ] 裁决：仅在部署完成时为 COMPLETE；当 go/no-go 为 NO 或硬阻塞未解决时为 BLOCKED
- [ ] 下一步始终包含48小时发布后监控、`/retrospective` 推荐，以及将 `production/stage.txt` 更新为 `Live`

---

## 覆盖范围说明

- 阶段7 发布后动作（发布报告、里程碑跟踪、社区发布、仪表板监控）通过用例1隐式验证。由于阶段7非门控且没有阻塞性故障模式，不需要单独的边界用例。
- "devops-engineer 构建失败"路径未单独测试 — 它将作为阶段3的BLOCKED结果呈现，并遵循标准错误恢复协议（surface → assess → AskUserQuestion options）。这通过静态断言错误恢复检查在结构上验证。
- 并行阶段4路径（本地化+性能+分析与阶段3同时进行）是技能中记录的选项（"如果资源可用，可以与阶段3并行运行"）。用例4将阶段4作为顺序门进行测试；并行变体留给技能的实现判断。
- 多人游戏的 `network-programmer` 签核路径作为用例3的一部分进行验证，而非单独用例，因为它遵循与 security-engineer 相同的并行生成模式。
- 用例2中的"覆盖 NO-GO 并记录理由"路径被引用但未详尽测试 — 它是一个逃生舱口，技能必须支持，其存在通过用例2中的 AskUserQuestion 选项断言验证。