# Skill Test Spec: /estimate

## 技能摘要

`/estimate` 使用相对规模等级（S / M / L / XL）基于故事复杂度、验收标准数量和过往 sprint 文件中的历史 sprint velocity 来估算任务或故事工作量。估算结果是建议性的，永远不会自动写入。不调用任何 director gate。判定结果是工作量范围，而非通过/失败 —— 每次运行都会产生一个估算。

---

## 静态断言（结构性的）

由 `/skill-test static` 自动验证 —— 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含规模标签：S, M, L, XL（本技能的"判定"等价物）
- [ ] 不要求"我可以写入"语言（仅建议性输出）
- [ ] 具有下一步交接说明（如何在 sprint planning 中使用估算）

---

## Director Gate 检查

无。Estimation 是一个建议性的信息技能；不调用任何 gate。

---

## 测试用例

### 用例 1：Happy Path —— 技术栈已知的清晰故事

**Fixture:**
- `production/epics/combat/story-hitbox-detection.md` 存在，包含：
  - 4 条清晰的验收标准
  - ADR 引用（Accepted 状态）
  - 故事正文中没有"未知"或"待定"语言
- `production/sprints/sprint-003.md` 到 `sprint-005.md` 存在，包含 velocity 数据
- 技术栈是 GDScript（根据 sprint 历史，团队对此很熟悉）

**输入:** `/estimate production/epics/combat/story-hitbox-detection.md`

**预期行为:**
1. 技能读取故事文件 —— 评估清晰度、验收标准数量、技术栈
2. 技能读取 sprint 历史以确定平均 velocity
3. 技能输出估算：M（1–2 天）并附上推理
4. 不写入任何文件

**断言:**
- [ ] 对于清晰、范围明确且技术栈已知的故事，估算为 M
- [ ] 推理引用了验收标准数量、技术栈熟悉度和 velocity 数据
- [ ] 估算以范围形式呈现（例如"1–2 天"），而非单个点
- [ ] 不写入任何文件

---

### 用例 2：高不确定性 —— 未知系统，尚无 ADR

**Fixture:**
- `production/epics/online/story-lobby-matchmaking.md` 存在，包含：
  - 2 条模糊的验收标准（使用"应该"和"待定"）
  - 无 ADR 引用 —— 匹配架构尚未决定
  - 引用新子系统（"online/matchmaking"）且无现有源文件

**输入:** `/estimate production/epics/online/story-lobby-matchmaking.md`

**预期行为:**
1. 技能读取故事 —— 发现模糊的验收标准、无 ADR、无现有源文件
2. 技能标记多个不确定性因素
3. 估算为 L–XL，并附上明确的风险说明："估算范围较宽，原因是架构未知"
4. 技能建议在开发开始前创建 ADR

**断言:**
- [ ] 当存在重大未知因素时，估算为 L 或 XL（非 S 或 M）
- [ ] 风险说明解释了导致范围较宽的具体未知因素
- [ ] 输出建议首先解决架构问题
- [ ] 不写入任何文件

---

### 用例 3：无 Sprint Velocity 数据 —— 使用保守默认值

**Fixture:**
- 故事文件存在且定义明确
- `production/sprints/` 为空 —— 无历史 sprints

**输入:** `/estimate production/epics/core/story-save-load.md`

**预期行为:**
1. 技能读取故事 —— 评估复杂度
2. 技能尝试读取 sprint velocity 数据 —— 未找到
3. 技能说明："未找到 sprint 历史 —— 对 velocity 使用保守默认值"
4. 使用默认假设（例如，1 story point = 1 天）生成估算
5. 不写入任何文件

**断言:**
- [ ] 当无 sprint 历史存在时，技能不会出错
- [ ] 输出明确说明正在使用保守默认值
- [ ] 仍然生成估算（不因缺少 velocity 而被阻止）
- [ ] 保守默认值产生较高（而非较低）的估算范围

---

### 用例 4：多个故事 —— 每个单独估算加上 sprint 总计

**Fixture:**
- 用户提供 sprint 文件：`production/sprints/sprint-007.md`，包含 4 个故事
- 存在 sprint 历史（3 个之前的 sprints）

**输入:** `/estimate production/sprints/sprint-007.md`

**预期行为:**
1. 技能读取 sprint 文件 —— 识别 4 个故事
2. 技能单独估算每个故事：S, M, M, L
3. 技能计算 sprint 总计：约 6–8 story points
4. 技能呈现每个故事的估算，然后是 sprint 总计
5. 不写入任何文件

**断言:**
- [ ] 每个故事获得自己的估算标签
- [ ] sprint 总计在单独估算之后呈现
- [ ] 总计是从单独范围推导出的总和范围
- [ ] 技能处理 sprint 文件（不仅仅是单个故事文件）作为输入

---

### 用例 5：Gate 合规性 —— 无 gate；估算是信息性的

**Fixture:**
- 故事文件存在，具有中等复杂度
- `review-mode.txt` 包含 `full`

**输入:** `/estimate production/epics/core/story-item-pickup.md`

**预期行为:**
1. 技能读取故事和 sprint 历史；计算估算
2. 在任何 review mode 中都不调用 director gate
3. 估算仅作为建议性输出呈现
4. 技能说明："在 /sprint-plan 中为下一个 sprint 选择故事时使用此估算"

**断言:**
- [ ] 无论 review mode 如何，都不调用 director gate
- [ ] 输出纯粹是信息性的 —— 无批准或写入提示
- [ ] 下一步建议引用 `/sprint-plan`
- [ ] 估算不基于 review mode 改变

---

## 协议合规性

- [ ] 在估算前读取故事文件
- [ ] 在可用时读取 sprint velocity 历史
- [ ] 产生工作量范围（S/M/L/XL），而非单个数字
- [ ] 不写入任何文件
- [ ] 不调用任何 director gate
- [ ] 总是产生估算（从不因缺少数据而被阻止；使用默认值代替）

---

## 覆盖范围说明

- 本技能不产生 PASS/FAIL 判定；这里的"判定"是工作量范围本身。测试断言侧重于范围的准确性和推理的质量，而非二元结果。
- 团队特定的 velocity 校准（"M"对该团队意味着什么）是一个实现细节，此处不测试；它通过 sprint 历史配置。