# 技能测试规范：/team-qa

## 技能摘要

通过一个 7 阶段结构化测试周期协调 QA 团队。协调 qa-lead（策略、测试计划、签核报告）和 qa-tester（测试用例编写、错误报告编写）。涵盖范围检测、Story 分类、QA 计划生成、冒烟检查关卡、测试用例编写、带错误提交的手动 QA 执行以及带有 APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED 裁决的最终签核报告。阶段 5 中为独立 Story 使用并行 qa-tester 生成。

---

## 静态断言（结构）

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含签核报告的裁决关键词：APPROVED、APPROVED WITH CONDITIONS、NOT APPROVED
- [ ] 包含 QA 计划和签核报告的 "May I write" 语言
- [ ] 存在错误恢复协议部分
- [ ] 在阶段转换时使用 `AskUserQuestion` 获取用户批准
- [ ] 阶段 4（冒烟检查）是硬关卡：FAIL 停止周期
- [ ] 错误报告写入 `production/qa/bugs/`，命名约定为 `BUG-[NNN]-[short-slug].md`
- [ ] 后续步骤指导因裁决而异（APPROVED / APPROVED WITH CONDITIONS / NOT APPROVED）
- [ ] 阶段 5 中的独立 qa-tester 任务并行生成

---

## 测试用例

### 用例 1：理想路径 —— 所有 Story 通过手动 QA，APPROVED 裁决

**测试夹具：**
- `production/sprints/sprint-03/` 存在并包含 4 个 Story 文件
- Story 混合类型：1 个 Logic、1 个 Integration、2 个 Visual/Feel
- 所有 Story 都填充了验收标准
- `tests/smoke/` 包含冒烟测试列表；所有项目都可验证
- `production/qa/bugs/` 中不存在现有错误

**输入：** `/team-qa sprint-03`

**预期行为：**
1. 阶段 1：读取 `production/sprints/sprint-03/` 中的所有 Story 文件；读取 `production/stage.txt`；报告"找到 4 个 Story。当前阶段：[stage]。准备开始 QA 策略？"
2. 阶段 2：通过 Task 生成 `qa-lead`；生成策略表对所有 4 个 Story 进行分类；未标记阻塞项；展示给用户；AskUserQuestion：用户选择"看起来不错 —— 继续测试计划"
3. 阶段 3：生成 QA 计划文档；询问"May I write the QA plan to `production/qa/qa-plan-sprint-03-[date].md`?"；批准后写入
4. 阶段 4：通过 Task 生成 `qa-lead`；审查 `tests/smoke/`；返回 PASS；报告"冒烟检查通过。继续编写测试用例。"
5. 阶段 5：通过 Task 为每个 Visual/Feel 和 Integration Story（2–3 个 Story）生成 `qa-tester`；并行运行；按 Story 分组展示测试用例；每组 AskUserQuestion；用户批准
6. 阶段 6：遍历每个已批准的 Story；用户将所有标记为 PASS；结果摘要："Stories PASS：4，FAIL：0，BLOCKED：0"
7. 阶段 7：通过 Task 生成 `qa-lead` 以生成签核报告；报告显示所有 Story PASS；未提交错误；裁决：APPROVED；询问"May I write this QA sign-off report to `production/qa/qa-signoff-sprint-03-[date].md`?"；批准后写入
8. 裁决：COMPLETE —— QA 周期完成

**断言：**
- [ ] 阶段 1 正确计数并报告 4 个 Story 及当前阶段
- [ ] 阶段 2 中的策略表对所有 4 个 Story 进行正确类型分类
- [ ] QA 计划仅在 "May I write?" 批准后写入
- [ ] 冒烟检查 PASS 允许流水线无需用户干预即可继续
- [ ] 阶段 5 中独立 Story 的 qa-tester 任务并行发出
- [ ] 签核报告包含测试覆盖摘要表和裁决：APPROVED
- [ ] 签核报告仅在 "May I write?" 批准后写入
- [ ] 最终输出中存在裁决：COMPLETE
- [ ] 后续步骤："运行 `/gate-check` 以验证推进。"

---

### 用例 2：冒烟检查失败 —— QA 周期在阶段 4 停止

**测试夹具：**
- `production/sprints/sprint-04/` 存在并包含 3 个 Story 文件
- `tests/smoke/` 存在并包含 5 个冒烟测试项目；2 个项目无法验证（例如，构建不稳定，核心导航损坏）

**输入：** `/team-qa sprint-04`

**预期行为：**
1. 阶段 1–3 正常完成；QA 计划已写入
2. 阶段 4：通过 Task 生成 `qa-lead`；冒烟检查返回 FAIL；识别出两个具体失败
3. 技能报告："冒烟检查失败。在解决这些问题前无法开始 QA：[2 个失败列表]。修复它们并重新运行 `/smoke-check`，或解决后重新运行 `/team-qa`。"
4. 技能在阶段 4 后立即停止 —— 不执行阶段 5、6 或 7
5. 不生成签核报告；不发出签核的 "May I write"

**断言：**
- [ ] 冒烟检查 FAIL 导致流水线在阶段 4 停止 —— 不执行阶段 5、6、7
- [ ] 失败列表被明确展示给用户（不是模糊总结）
- [ ] 技能建议 `/smoke-check` 和 `/team-qa` 重新运行作为修复步骤
- [ ] 不写入或提供 QA 签核报告
- [ ] 技能不产生 COMPLETE 裁决
- [ ] 阶段 3 中已写入的任何 QA 计划被保留（不会被删除）

---

### 用例 3：发现错误 —— Visual/Feel Story 未通过手动 QA，提交错误报告

**测试夹具：**
- `production/sprints/sprint-05/` 存在并包含 2 个 Story 文件：1 个 Logic（通过自动化测试）、1 个 Visual/Feel
- `tests/smoke/` 冒烟检查通过
- Visual/Feel Story 的动画时间明显错误（未达到验收标准）
- `production/qa/bugs/` 目录存在（空或包含现有错误）

**输入：** `/team-qa sprint-05`

**预期行为：**
1. 阶段 1–5 正常完成；为 Visual/Feel Story 编写测试用例
2. 阶段 6：用户将 Visual/Feel Story 标记为 FAIL；AskUserQuestion 收集失败描述："动画以 2 倍速播放 —— 每次循环都可见抖动"
3. 阶段 6：通过 Task 生成 `qa-tester` 以编写正式错误报告；错误报告写入 `production/qa/bugs/BUG-001-animation-speed-jitter.md`（如果存在错误则为下一个递增）；报告包含严重等级字段
4. 结果摘要："Stories PASS：1，FAIL：1 —— 提交错误：BUG-001"
5. 阶段 7：生成 `qa-lead` 以生成签核报告；发现的错误表列出 BUG-001 及严重等级和状态 Open；裁决：NOT APPROVED（S1/S2 错误开放，或 FAIL 无记录变通方法）
6. 提供签核报告写入；批准后写入
7. 后续步骤："解决 S1/S2 错误并重新运行 `/team-qa` 或针对性手动 QA 后再推进。"

**断言：**
- [ ] 阶段 6 中的 FAIL 结果在编写错误报告前触发 AskUserQuestion 以收集失败描述
- [ ] `qa-tester` 通过 Task 生成以编写错误报告 —— 编排器不直接编写
- [ ] 错误报告遵循命名约定：`production/qa/bugs/` 中的 `BUG-[NNN]-[short-slug].md`
- [ ] 错误报告 NNN 根据目录中的现有错误正确递增
- [ ] 阶段 7 签核报告中的发现的错误表包含错误 ID、Story 名称、严重等级和状态
- [ ] 签核报告中的裁决为 NOT APPROVED
- [ ] 后续步骤明确提及重新运行 `/team-qa`
- [ ] 编排器仍发出裁决：COMPLETE（QA 周期已完成 —— 裁决是 NOT APPROVED，但技能完成了其流水线）

---

### 用例 4：无参数 —— 技能推断活动 Sprint 或询问用户

**测试夹具（变体 A —— 状态文件存在）：**
- `production/session-state/active.md` 存在并包含对 `sprint-06` 的引用
- `production/sprint-status.yaml` 存在并将 `sprint-06` 标识为活动状态

**测试夹具（变体 B —— 状态文件缺失）：**
- `production/session-state/active.md` 不存在
- `production/sprint-status.yaml` 不存在

**输入：** `/team-qa`（无参数）

**预期行为（变体 A）：**
1. 阶段 1：未提供参数；读取 `production/session-state/active.md`；读取 `production/sprint-status.yaml`
2. 从两个来源检测到 `sprint-06` 为活动 Sprint
3. 如同输入 `/team-qa sprint-06` 一样进行；报告"未提供 Sprint 参数 —— 从会话状态推断为 sprint-06。找到 [N] 个 Story。"

**预期行为（变体 B）：**
1. 阶段 1：未提供参数；尝试读取 `production/session-state/active.md` —— 文件缺失；尝试读取 `production/sprint-status.yaml` —— 文件缺失
2. 无法推断 Sprint；使用 AskUserQuestion："QA 应覆盖哪个 Sprint 或功能？"并提供输入 Sprint 标识符或取消的选项

**断言：**
- [ ] 未提供参数时，技能不会默认为硬编码的 Sprint 名称
- [ ] 技能在询问用户前读取 `production/session-state/active.md` 和 `production/sprint-status.yaml`（变体 A）
- [ ] 当两个状态文件都不存在时，技能使用 AskUserQuestion 而不是猜测（变体 B）
- [ ] 推断的 Sprint 在继续前被报告给用户（变体 A 透明度）
- [ ] 当状态文件缺失时，技能不会报错 —— 它会回退到询问（变体 B）

---

### 用例 5：混合结果 —— 一些 PASS，一个 FAIL 含 S1 错误，一个 BLOCKED

**测试夹具：**
- `production/sprints/sprint-07/` 存在并包含 4 个 Story 文件
- 冒烟检查通过
- Story A（Logic）：自动化测试通过 —— PASS
- Story B（UI）：手动 QA —— PASS WITH NOTES（minor text overflow）
- Story C（Visual/Feel）：手动 QA —— FAIL；测试员识别出能力激活时的 S1 崩溃
- Story D（Integration）：无法测试 —— BLOCKED（依赖系统尚未实现）

**输入：** `/team-qa sprint-07`

**预期行为：**
1. 阶段 1–5 进行；阶段 5 测试用例覆盖 Story B、C、D
2. 阶段 6：用户将 Story A 标记为隐式 PASS（自动化）；Story B：PASS WITH NOTES；Story C：FAIL；Story D：BLOCKED
3. Story C FAIL 后：生成 qa-tester 以编写错误报告 `BUG-001-crash-ability-activation.md`，严重等级为 S1
4. 展示结果摘要："Stories PASS：1，PASS WITH NOTES：1，FAIL：1 —— 提交错误：BUG-001（S1），BLOCKED：1"
5. 阶段 7：qa-lead 生成覆盖所有 4 个 Story 的签核报告；BUG-001 列为 S1/Open；Story D 列为 BLOCKED；裁决：NOT APPROVED
6. 在 "May I write?" 批准后写入签核报告
7. 后续步骤："解决 S1/S2 错误并重新运行 `/team-qa` 或针对性手动 QA 后再推进。"

**断言：**
- [ ] 所有 4 个 Story 都出现在阶段 7 签核报告的测试覆盖摘要表中 —— 没有被静默省略
- [ ] Story D（BLOCKED）在报告中以 BLOCKED 状态列出，不是被静默丢弃
- [ ] S1 错误导致裁决：NOT APPROVED，无论其他 Story 是否通过
- [ ] PASS WITH NOTES 的 Story 不会降级为 FAIL —— 它们被单独跟踪
- [ ] BUG-001 严重等级在发现的错误表中列为 S1
- [ ] 保留部分结果 —— 即使有失败和阻塞，仍生成签核报告
- [ ] 编排器发出裁决：COMPLETE（流水线已完成）；签核裁决为 NOT APPROVED

---

## 协议合规性

- [ ] 在阶段 2（策略审查）、阶段 5（每组测试用例批准）和阶段 6（每个 Story 的手动 QA 结果）使用 `AskUserQuestion`
- [ ] 阶段 4 冒烟检查是硬关卡：FAIL 停止流水线，无例外
- [ ] 分别为 QA 计划（阶段 3）和签核报告（阶段 7）询问 "May I write?"
- [ ] 错误报告始终由 `qa-tester` 通过 Task 编写 —— 编排器不直接编写
- [ ] 在可能的情况下，阶段 5 中独立 Story 的 qa-tester 任务并行发出
- [ ] 错误恢复：任何 BLOCKED 代理都立即通过 AskUserQuestion 选项被展示
- [ ] 始终生成部分报告 —— 不会因一个 Story 失败或阻塞而丢弃任何工作
- [ ] 严格应用签核裁决规则：任何开放的 S1/S2 错误 = NOT APPROVED；无例外
- [ ] 编排器级裁决：COMPLETE 与签核报告的 APPROVED/NOT APPROVED 裁决不同

---

## 覆盖说明

- "APPROVED WITH CONDITIONS"裁决路径（S3/S4 错误、PASS WITH NOTES）通过用例 5 的 PASS WITH NOTES Story（Story B）隐式覆盖 —— 如果不存在 S1/S2 错误，该用例将产生 APPROVED WITH CONDITIONS。不需要专用用例，因为裁决逻辑是表驱动的。
- `feature: [system-name]` 参数形式未单独测试 —— 它遵循与 Sprint 形式相同的阶段 1 逻辑，使用 glob 而非目录读取。无参数推断路径（用例 4）提供了检测逻辑的充分覆盖。
- 通过自动化测试的 Logic Story 不需要手动 QA —— 这通过用例 5（Story A）隐式验证，其中 Logic Story 不接受手动 QA 阶段。
- 阶段 5 中的并行 qa-tester 生成通过用例 1（同时发出多个 Visual/Feel Story）隐式验证；除了静态断言检查外，不需要专用的并行用例。
