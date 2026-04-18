# 技能测试规范：/day-one-patch

## 技能摘要

`/day-one-patch` 为已知但在 v1.0 发布时推迟的问题准备首日补丁计划。它读取 `production/bugs/` 中的开放错误报告，从 Story 文件中读取推迟的验收标准（标记为 `Status: Done` 但注明推迟 AC 的 Story），并生成一份按问题划分优先级的补丁计划，附带预计修复时间线。

补丁计划在询问"May I write"后写入 `production/releases/day-one-patch.md`。如果发现 P0（发布后关键）问题，技能会触发运行 `/hotfix` 的引导。不适用总监关卡。裁决始终为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在写入计划前
- [ ] 具有下一步交接（例如，`/hotfix` 处理 P0 问题，`/release-checklist` 进行跟进）

---

## 总监关卡检查

无。`/day-one-patch` 是发布规划工具。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— 3 个已知问题，带修复估计的补丁计划

**测试夹具：**
- `production/bugs/` 包含 3 个开放错误，严重等级为：1 个 MEDIUM，2 个 LOW
- Sprint Story 中无推迟的 AC
- 所有错误都有复现步骤和系统标识

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取所有 3 个开放错误
2. 技能分配修复工作量估计：MEDIUM 错误 = 1-2 天，LOW 错误 = 每个 4 小时
3. 技能生成补丁计划，MEDIUM 错误优先
4. 计划包含：优先级顺序、预计时间线、负责系统、修复描述
5. 技能询问"May I write to `production/releases/day-one-patch.md`?"
6. 文件已写入；裁决为 COMPLETE

**断言：**
- [ ] 计划中出现了所有 3 个错误
- [ ] 错误按严重等级排序（MEDIUM 在 LOW 之前）
- [ ] 每个问题都提供了修复估计
- [ ] 在写入前询问 "May I write"
- [ ] 裁决为 COMPLETE

---

### 用例 2：发现发布后关键问题 —— P0，触发 /hotfix 引导

**测试夹具：**
- 在 `production/bugs/` 中发现一个 CRITICAL 严重等级错误，位于 v1.0 发布后
- 该错误导致所有存档文件数据丢失

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取错误并识别 CRITICAL 严重等级问题
2. 技能升级："P0 ISSUE DETECTED — data loss bug requires immediate hotfix before patch planning can proceed"
3. 技能不将 P0 问题包含在补丁计划时间线中
4. 技能明确引导："Run `/hotfix` to resolve this issue first"
5. 发出 P0 引导后：仍然为剩余的较低严重等级错误生成并写入计划；裁决为 COMPLETE

**断言：**
- [ ] P0 升级消息在补丁计划前醒目出现
- [ ] 针对 P0 问题明确引导 `/hotfix`
- [ ] P0 问题未安排在补丁计划时间线中（它需要立即处理）
- [ ] 仍然计划非 P0 问题；裁决为 COMPLETE

---

### 用例 3：来自 Story-Done 的推迟 AC —— 自动纳入补丁计划

**测试夹具：**
- `production/sprints/sprint-008.md` 有一个 Story，其 `Status: Done` 并附注："DEFERRED AC: Gamepad vibration on damage — deferred to post-launch patch"
- 同一系统无开放错误

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取 Sprint Story 并检测到推迟的 AC 注释
2. 推迟的 AC 自动作为工作项纳入补丁计划
3. 计划条目："Deferred from sprint-008: Gamepad vibration on damage"
4. 分配修复估计；补丁计划在 "May I write" 批准后写入
5. 裁决为 COMPLETE

**断言：**
- [ ] Story 文件中的推迟 AC 自动纳入计划
- [ ] 推迟项按其来源 Story 标记（sprint-008）
- [ ] 推迟的 AC 像错误条目一样获得修复估计
- [ ] 裁决为 COMPLETE

---

### 用例 4：无已知问题 —— 带模板注释的空计划

**测试夹具：**
- `production/bugs/` 为空
- 无 Story 具有推迟的 AC

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取错误 —— 未找到
2. 技能读取 Story 推迟的 AC —— 未找到
3. 技能生成空补丁计划并附注："No known issues at launch"
4. 保留模板结构（标题完整）以供将来使用
5. 技能询问"May I write to `production/releases/day-one-patch.md`?"
6. 文件已写入；裁决为 COMPLETE

**断言：**
- [ ] "No known issues at launch" 注释出现在写入的文件中
- [ ] 空计划中仍存在模板标题
- [ ] 当没有问题可计划时，技能不会报错
- [ ] 裁决为 COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；day-one-patch 是规划工具

**测试夹具：**
- production/bugs/ 中存在已知问题

**输入：** `/day-one-patch`

**预期行为：**
1. 技能生成并写入补丁计划
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 在生成计划前从 `production/bugs/` 读取开放错误
- [ ] 扫描 Story 文件中的推迟 AC 注释
- [ ] 使用明确的 `/hotfix` 引导升级 CRITICAL (P0) 错误
- [ ] 当不存在问题时生成带注释的空计划（非错误）
- [ ] 在写入前询问 "May I write to `production/releases/day-one-patch.md`?"
- [ ] 裁决在所有路径中均为 COMPLETE

---

## 覆盖说明

- 存在多个 CRITICAL 错误的情况与用例 2 相同处理；所有 P0 问题一起升级。
- 补丁的时间线估计（例如，"patch available in 3 days"）需要手动 QA 和构建时间估计；技能使用基于严重等级的粗略估计，而非实际团队速度。
- 补丁说明玩家沟通文档（`/patch-notes`）是在补丁计划执行后调用的单独技能。
