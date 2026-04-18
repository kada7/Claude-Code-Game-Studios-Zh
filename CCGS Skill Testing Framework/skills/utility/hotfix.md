# 技能测试规范：/hotfix

## 技能摘要

`/hotfix` 管理紧急修复工作流：从 main 创建 hotfix 分支，对识别的文件应用针对性修复，运行 `/smoke-check` 验证修复未引入回归，并提示用户确认合并回 main。每次代码变更都需要 "May I write to [filepath]?" 询问。Git 操作（分支创建、合并）作为 Bash 命令展示，供用户确认后执行。

该技能具有时效性 —— 总监审查是可选的事后审查，而非阻塞关卡。裁决：HOTFIX COMPLETE（修复已应用，冒烟检查通过，已合并）或 HOTFIX BLOCKED（修复引入了回归或用户拒绝）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：HOTFIX COMPLETE、HOTFIX BLOCKED
- [ ] 包含 "May I write" 代码变更语言
- [ ] 具有下一步交接（例如，`/bug-report` 记录问题，或版本升级）

---

## 总监关卡检查

无。Hotfix 具有时效性。总监审查可作为单独的事后步骤进行。此技能内不调用关卡。

---

## 测试用例

### 用例 1：理想路径 —— 关键崩溃错误已修复，冒烟检查通过

**测试夹具：**
- `main` 分支干净
- 错误已识别于 `src/gameplay/arena.gd`（进入 boss 竞技场时崩溃）
- 用户提供了复现步骤

**输入：** `/hotfix`（用户描述了崩溃和受影响的文件）

**预期行为：**
1. 技能提议创建 hotfix 分支：`hotfix/boss-arena-crash`
2. 用户确认；展示并确认分支创建的 Bash 命令
3. 技能识别 `arena.gd` 中的修复位置并起草变更
4. 技能询问 "May I write to `src/gameplay/arena.gd`?" 并在批准后应用修复
5. 技能运行 `/smoke-check` —— PASS
6. 技能展示合并命令并询问用户确认合并到 `main`
7. 用户确认；合并执行；裁决为 HOTFIX COMPLETE

**断言：**
- [ ] 在进行任何代码变更前创建 hotfix 分支
- [ ] 在修改任何源文件前询问 "May I write"
- [ ] 修复应用后运行 `/smoke-check`
- [ ] 合并需要显式用户确认（非自动）
- [ ] 成功合并后裁决为 HOTFIX COMPLETE

---

### 用例 2：冒烟检查失败 —— HOTFIX BLOCKED

**测试夹具：**
- 修复已应用于 `src/gameplay/arena.gd`
- `/smoke-check` 返回 FAIL："Player health clamping regression detected"

**输入：** `/hotfix`

**预期行为：**
1. 技能应用修复并运行 `/smoke-check`
2. 冒烟检查返回 FAIL 并识别出具体的回归
3. 技能报告："HOTFIX BLOCKED — smoke check failed: [regression detail]"
4. 技能展示选项：尝试修订修复、回滚变更，或合并已知回归（用户确认风险）
5. 冒烟检查失败时不自动合并

**断言：**
- [ ] 裁决为 HOTFIX BLOCKED
- [ ] 冒烟检查失败逐字展示给用户
- [ ] 冒烟检查失败时不自动执行合并
- [ ] 用户获得明确的后续选项

---

### 用例 3：对已发布构建的修复 —— 记录版本标签，提示补丁升级

**测试夹具：**
- 最新 git 标签为 `v1.2.0`
- Hotfix 针对 v1.2.0 发布中的错误

**输入：** `/hotfix`

**预期行为：**
1. 技能检测到当前 HEAD 是已标记的发布版本（v1.2.0）
2. 技能记录："Hotfix targeting tagged release v1.2.0"
3. 冒烟检查通过后，技能提示："Should version be bumped to v1.2.1?"
4. 如果用户确认版本升级：技能询问 "May I write to VERSION or equivalent?"
5. 版本更新和合并后：裁决为 HOTFIX COMPLETE 并记录版本

**断言：**
- [ ] 版本标签上下文被检测到并展示给用户
- [ ] 补丁版本升级在合并后被建议（非强制）
- [ ] 版本升级需要单独的 "May I write" 确认
- [ ] 裁决为 HOTFIX COMPLETE

---

### 用例 4：无复现步骤 —— 技能在应用修复前询问

**测试夹具：**
- 用户以模糊描述调用 `/hotfix`："something is broken on level 3"
- 未提供复现步骤

**输入：** `/hotfix`（模糊描述）

**预期行为：**
1. 技能检测到信息不足，无法识别修复位置
2. 技能询问："Please provide reproduction steps and the affected file or system"
3. 在未提供复现步骤前，技能不创建分支或修改任何文件
4. 用户提供复现步骤后：正常的 hotfix 流程开始

**断言：**
- [ ] 未提供复现步骤前不创建分支
- [ ] 未明确识别修复位置前不进行代码变更
- [ ] 复现步骤请求是具体的（非通用的 "please provide more info"）
- [ ] 用户提供复现步骤后恢复正常 hotfix 流程

---

### 用例 5：总监关卡检查 —— 无关卡；hotfix 具有时效性

**测试夹具：**
- 已识别关键错误及复现步骤

**输入：** `/hotfix`

**预期行为：**
1. 技能完成 hotfix 工作流
2. 执行期间不生成总监代理
3. 输出中不出现关卡 ID
4. 事后总监审查（如需要）是手动跟进，不在此处调用

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 HOTFIX COMPLETE 或 HOTFIX BLOCKED —— 无关卡裁决

---

## 协议合规性

- [ ] 在进行任何代码变更前创建 hotfix 分支
- [ ] 在修改任何源文件前询问 "May I write"
- [ ] 应用修复后运行 `/smoke-check`
- [ ] 合并前需要显式用户确认
- [ ] 冒烟检查失败时裁决为 HOTFIX BLOCKED —— 不自动合并
- [ ] 裁决为 HOTFIX COMPLETE 或 HOTFIX BLOCKED

---

## 覆盖说明

- 单个修复需要修改多个文件的情况遵循相同的按文件 "May I write" 模式，未单独测试。
- Hotfix 后的步骤（创建错误报告、更新 changelog）在交接中建议，但不作为该技能执行的一部分进行测试。
- 合并期间的冲突解决（如果 main 已分叉）未测试；技能会展示冲突并要求用户手动解决。
