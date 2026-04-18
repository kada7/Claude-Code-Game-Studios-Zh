# 技能测试规范：/team-live-ops

## 技能摘要

通过一个 7 阶段规划流水线协调 live-ops 团队以生成赛季或活动计划。协调 live-ops-designer、economy-designer、analytics-engineer、community-manager、narrative-director 和 writer。阶段 3 和 4（经济设计和分析）同时运行。以需要用户批准的整合赛季计划结束，然后交接给生产。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 在文件写入协议部分包含 "May I write" 语言（委托给子代理）
- [ ] 拥有一个文件写入协议部分，声明编排器不直接写入文件
- [ ] 在末尾具有引用 `/design-review`、`/sprint-plan` 和 `/team-release` 的下一步交接
- [ ] 在需要用户批准才能继续的阶段转换处使用 `AskUserQuestion`
- [ ] 明确声明阶段 3 和 4 可以同时运行（并行生成）
- [ ] 存在错误恢复部分（或通过 BLOCKED 处理隐含）
- [ ] 输出文档部分指定 `design/live-ops/seasons/` 下的路径

---

## 测试用例

### 用例 1：理想路径 —— 所有 7 个阶段完成，生成赛季计划

**测试夹具：**
- `design/live-ops/economy-rules.md` 存在并包含当前经济配置
- `design/live-ops/ethics-policy.md` 存在并包含项目伦理政策
- 游戏概念文档存在于其标准路径
- 正在规划的新赛季名称不存在现有赛季文档

**输入：** `/team-live-ops "Season 2: The Frozen Wastes"`

**预期行为：**
1. 阶段 1：通过 Task 生成 `live-ops-designer`；接收包含范围、内容列表和留存机制的赛季简报；展示给用户
2. AskUserQuestion：用户在阶段 2 开始前批准阶段 1 输出
3. 阶段 2：通过 Task 生成 `narrative-director`；读取阶段 1 赛季简报；生成叙事框架文档（主题、故事钩子、背景故事连接）；展示给用户
4. 阶段 3 和 4（并行）：通过两个 Task 调用在等候任一结果前同时生成 `economy-designer` 和 `analytics-engineer`；economy-designer 读取 `design/live-ops/economy-rules.md`
5. 阶段 5：并行生成 `narrative-director` 和 `writer` 以生成游戏内叙事文本和面向玩家的文案；两者都读取阶段 2 叙事框架文档
6. 阶段 6：通过 Task 生成 `community-manager`；读取赛季简报、经济设计和叙事框架；生成包含草稿文案的沟通日历
7. 阶段 7：收集所有阶段输出；展示整合赛季计划摘要，包括经济健康检查、分析就绪性、伦理审查和未决问题
8. AskUserQuestion：用户批准完整的赛季计划
9. 子代理在写入前询问"May I write to `design/live-ops/seasons/S2_The_Frozen_Wastes.md`?"、`...analytics.md` 和 `...comms.md`
10. 裁决：COMPLETE —— 赛季计划已生成并交接给生产

**断言：**
- [ ] 所有 7 个阶段按顺序执行；阶段 3 和 4 作为并行 Task 调用发出
- [ ] 阶段 7 整合摘要包含所有六个部分（赛季简报、叙事框架、经济设计、分析计划、内容清单、沟通日历）
- [ ] 阶段 7 中的伦理审查部分明确引用 `design/live-ops/ethics-policy.md`
- [ ] 三个输出文档写入 `design/live-ops/seasons/`，命名约定正确
- [ ] 文件写入委托给子代理 —— 编排器不直接写入
- [ ] 最终输出中存在裁决：COMPLETE
- [ ] 后续步骤引用 `/design-review`、`/sprint-plan` 和 `/team-release`

---

### 用例 2：发现伦理违规 —— 奖励元素违反伦理政策

**测试夹具：**
- 所有标准 live-ops 夹具存在（economy-rules.md、ethics-policy.md）
- `design/live-ops/ethics-policy.md` 明确禁止面向 18 岁以下玩家的 loot boxes
- economy-designer（阶段 3）提出一个"Mystery Chest"机制，包含随机高级奖励且没有保底机制

**输入：** `/team-live-ops "Season 3: Shadow Tournament"`

**预期行为：**
1. 阶段 1–4 正常进行；economy-designer 提出 Mystery Chest 机制
2. 阶段 7：编排器根据伦理政策审查阶段 3 输出；将 Mystery Chest 识别为违反伦理政策中"无不透明随机高级奖励"规则
3. 阶段 7 摘要的伦理审查部分明确标记违规："ETHICS FLAG：阶段 3 经济设计中的 Mystery Chest 机制违反 [policy rule]。在解决前批准被阻塞。"
4. 在提供赛季计划批准选项前展示带有解决选项的 AskUserQuestion
5. 在伦理违规解决或被用户明确豁免前，技能不会发出 COMPLETE 裁决或写入输出文档

**断言：**
- [ ] 阶段 7 伦理审查部分明确命名违规元素及其违反的政策规则
- [ ] 当存在伦理违规时，技能不会自动批准赛季计划
- [ ] 使用 AskUserQuestion 展示违规并提供解决选项（修订经济设计、以记录理由覆盖、取消）
- [ ] 在违规未解决时不写入输出文档
- [ ] 如果用户选择修订：技能重新生成 economy-designer 以生成修正后的设计，然后返回阶段 7 审查
- [ ] 仅在伦理标记清除后发出裁决：COMPLETE

---

### 用例 3：无参数 —— 展示使用指南

**测试夹具：**
- 任何项目状态

**输入：** `/team-live-ops`（无参数）

**预期行为：**
1. 阶段 1：未检测到参数
2. 输出："用法：`/team-live-ops [season name or event description]` —— 提供要规划的赛季或 live event 的名称或描述。"
3. 技能立即退出而不生成任何子代理

**断言：**
- [ ] 技能不会猜测赛季名称或编造范围
- [ ] 错误消息包含来自 argument-hint 的正确使用格式
- [ ] 在参数检查失败前不发出 Task 调用
- [ ] 不读取或写入任何文件

---

### 用例 4：并行阶段验证 —— 阶段 3 和 4 同时运行

**测试夹具：**
- 所有标准 live-ops 夹具存在
- 阶段 1（赛季简报）和阶段 2（叙事框架）已被批准
- 阶段 3（economy-designer）和阶段 4（analytics-engineer）输入相互独立

**输入：** `/team-live-ops "Season 1: The First Thaw"`（在阶段 3/4 转换时观察）

**预期行为：**
1. 在用户批准阶段 2 后，编排器发出两个 Task 调用（economy-designer 和 analytics-engineer），然后等候任一结果
2. 两个代理都接收赛季简报作为上下文；analytics-engineer 不会等候 economy-designer 输出才开始
3. 在阶段 5 开始前一起收集 Economy-designer 输出和 analytics-engineer 输出
4. 如果两个并行代理之一阻塞，另一个继续；报告部分结果

**断言：**
- [ ] 阶段 3 和阶段 4 的两个 Task 调用在等候任一结果前发出 —— 它们不是顺序的
- [ ] Analytics-engineer 提示不包含 economy-designer 输出作为必需输入（输入是独立的）
- [ ] 如果 economy-designer 阻塞但 analytics-engineer 成功，分析输出被保留，阻塞通过 AskUserQuestion 被展示
- [ ] 阶段 5 直到阶段 3 和阶段 4 的结果都被收集后才开始
- [ ] 技能文档明确声明"阶段 3 和 4 可以同时运行"

---

### 用例 5：缺少伦理政策 —— `design/live-ops/ethics-policy.md` 不存在

**测试夹具：**
- `design/live-ops/economy-rules.md` 存在
- `design/live-ops/ethics-policy.md` 不存在
- 所有其他夹具存在

**输入：** `/team-live-ops "Season 4: Desert Heat"`

**预期行为：**
1. 阶段 1–4 进行；economy-designer 和 analytics-engineer 被提供伦理政策路径，但该路径缺失
2. 阶段 7：编排器尝试运行伦理审查；检测到 `design/live-ops/ethics-policy.md` 缺失
3. 阶段 7 摘要包含差距标记："ETHICS REVIEW SKIPPED：`design/live-ops/ethics-policy.md` 未找到。经济设计未经伦理政策审查。建议在生产开始前创建一个。"
4. 技能仍完成赛季计划并达到 COMPLETE 裁决，但差距在输出和赛季设计文档中被突出标记
5. 后续步骤包含建议创建伦理政策文档

**断言：**
- [ ] 当伦理政策文件缺失时，技能不会报错
- [ ] 技能不会在文件缺失时编造伦理政策规则
- [ ] 阶段 7 摘要明确记录伦理审查被跳过及原因
- [ ] 尽管文件缺失，仍可达到裁决：COMPLETE
- [ ] 差距标记出现在赛季设计输出文档中（不仅仅在对话中）
- [ ] 后续步骤建议创建 `design/live-ops/ethics-policy.md`

---

## 协议合规性

- [ ] 在每个阶段转换关卡使用 `AskUserQuestion` —— 用户在下一阶段开始前批准
- [ ] 阶段 3 和 4 始终作为并行调用生成，而非顺序生成
- [ ] 文件写入协议：编排器从不直接调用 Write/Edit —— 所有写入都委托给子代理
- [ ] 每个输出文档从相关子代理获得自己的"May I write to [path]?"询问
- [ ] 阶段 7 中的伦理审查始终明确引用伦理政策文件路径
- [ ] 错误恢复：任何 BLOCKED 代理都立即通过 AskUserQuestion 选项被展示（跳过 / 重试 / 停止）
- [ ] 如果任何阶段阻塞，生成部分报告 —— 工作永远不会被丢弃
- [ ] 仅在用户批准整合赛季计划后裁决：COMPLETE；如果存在任何未解决的伦理违规，则为 BLOCKED
- [ ] 后续步骤始终包含 `/design-review`、`/sprint-plan` 和 `/team-release`

---

## 覆盖说明

- 阶段 5 并行生成（narrative-director + writer）遵循与阶段 3/4 相同的模式，但此处未单独测试 —— 它使用在用例 4 中验证的相同并行 Task 协议。
- "economy-rules.md 缺失"边界情况未单独测试 —— 它将作为 economy-designer 的 BLOCKED 结果被展示，并遵循在用例 4 中隐式测试的标准错误恢复路径。
- 完整的内容编写流水线（阶段 5 输出验证）通过用例 1 的理想路径整合摘要检查隐式验证。
- 社区经理沟通日历格式（发布前、发布日、赛季中期、最后一周）通过用例 1 隐式验证；不需要单独的边界情况。
