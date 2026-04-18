# 技能测试规范：/onboard

## 技能摘要

`/onboard` 为团队成员生成针对新成员的上下文项目入职摘要。它读取 CLAUDE.md、`technical-preferences.md`、活动 Sprint 文件、最近的 git 提交和 `production/stage.txt`，生成一份结构化的引导文档。该技能在 Haiku 模型上运行（只读、格式化任务），不产生文件写入 —— 所有输出均为对话式。

该技能可选地接受角色参数（例如，`/onboard artist`）以针对特定学科定制摘要。当项目处于早期阶段或未配置时，输出会适应当前已知的信息。裁决始终为 ONBOARDING COMPLETE —— 该技能纯粹是信息性的。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：ONBOARDING COMPLETE
- [ ] 不包含 "May I write" 语言（技能为只读）
- [ ] 具有下一步交接，建议相关的后续技能

---

## 总监关卡检查

无。`/onboard` 是只读引导技能。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— 配置完成的项目处于 Production 阶段，有活动 Sprint

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `technical-preferences.md` 已填充引擎、语言和专家
- `production/sprints/sprint-005.md` 存在，包含进行中的 Story
- Git 日志包含 5 个最近的提交

**输入：** `/onboard`

**预期行为：**
1. 技能读取 stage.txt、technical-preferences.md、活动 Sprint 和 git 日志
2. 技能生成入职摘要，包含以下部分：Project Overview、Tech Stack、Current Stage、Active Sprint Summary、Recent Activity
3. 摘要格式便于阅读（标题、项目符号）
4. 后续步骤建议适合 Production 阶段（例如，`/sprint-status`、`/dev-story`）
5. 声明裁决 ONBOARDING COMPLETE

**断言：**
- [ ] 输出包含来自 stage.txt 的当前阶段名称
- [ ] 输出包含来自 technical-preferences.md 的引擎和语言
- [ ] 活动 Sprint Story 已总结（非仅 Sprint 文件名）
- [ ] 存在最近的提交上下文
- [ ] 裁决为 ONBOARDING COMPLETE
- [ ] 未写入任何文件

---

### 用例 2：全新项目 —— 无引擎、无 Sprint，建议 /start

**测试夹具：**
- `technical-preferences.md` 仅包含占位符（`[TO BE CONFIGURED]`）
- 无 `production/stage.txt`
- 无 Sprint 文件
- 无超出默认值的 CLAUDE.md 覆盖

**输入：** `/onboard`

**预期行为：**
1. 技能读取所有配置文件并检测到未配置状态
2. 技能生成最小摘要："This project has not been configured yet"
3. 输出解释入职工作流：`/start` → `/setup-engine` → `/brainstorm`
4. 技能建议立即运行 `/start` 作为下一步
5. 裁决为 ONBOARDING COMPLETE（信息性的，非失败）

**断言：**
- [ ] 输出明确提及项目尚未配置
- [ ] `/start` 被推荐为下一步
- [ ] 技能不会报错 —— 它优雅地处理空项目状态
- [ ] 裁决仍为 ONBOARDING COMPLETE

---

### 用例 3：未找到 CLAUDE.md —— 带补救措施的错误

**测试夹具：**
- `CLAUDE.md` 文件不存在（已删除或从未创建）
- 所有其他文件可能存在或不存在

**输入：** `/onboard`

**预期行为：**
1. 技能尝试读取 CLAUDE.md 并失败
2. 技能输出错误："CLAUDE.md not found — cannot generate onboarding summary"
3. 技能提供补救措施："Run `/start` to initialize the project configuration"
4. 未生成部分摘要

**断言：**
- [ ] 错误消息明确将缺失的文件标识为 CLAUDE.md
- [ ] 明确命名了补救步骤（`/start`）
- [ ] 根配置缺失时，技能不会生成部分输出
- [ ] 裁决为 ONBOARDING COMPLETE（带有错误上下文，非崩溃）

---

### 用例 4：角色特定入职 —— 用户指定 "artist" 角色

**测试夹具：**
- 完全配置的项目处于 Production 阶段
- `design/` 中存在 `art-bible.md`
- 活动 Sprint 包含视觉 Story 类型（动画、VFX）

**输入：** `/onboard artist`

**预期行为：**
1. 技能读取所有标准文件以及任何美术相关文档（art bible、asset specs）
2. 摘要针对 artist 角色定制：art bible 概述、asset 流水线、活动 Sprint 中的当前视觉 Story
3. 技术架构详情（代码结构、ADR）被淡化
4. 摘要中突出显示美术/音频的专家代理
5. 裁决为 ONBOARDING COMPLETE

**断言：**
- [ ] 输出中确认了角色参数（"Onboarding for: Artist"）
- [ ] 如果文件存在，则包含 art bible 摘要
- [ ] 展示了活动 Sprint 中的当前视觉 Story
- [ ] 技术实现细节不是主要焦点
- [ ] 裁决为 ONBOARDING COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；onboard 是只读引导

**测试夹具：**
- 任何配置的项目状态

**输入：** `/onboard`

**预期行为：**
1. 技能完成完整的入职摘要
2. 任何时刻都不生成总监代理
3. 输出中不出现关卡 ID
4. 不出现 "May I write" 提示

**断言：**
- [ ] 未调用总监关卡
- [ ] 未调用 Write 工具
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 ONBOARDING COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 在生成输出前读取所有源文件（无虚构的项目状态）
- [ ] 根据项目阶段调整输出（Production ≠ Concept）
- [ ] 提供角色参数时尊重该参数
- [ ] 不写入任何文件
- [ ] 在所有路径中以 ONBOARDING COMPLETE 裁决结束

---

## 覆盖说明

- `technical-preferences.md` 完全缺失（相对于具有占位符）的情况未单独测试；行为遵循用例 3 的优雅错误模式。
- Git 历史读取假定可用；此处未测试离线/无 git 场景。
- 超出 "artist" 的学科角色（例如，programmer、designer、producer）遵循与用例 4 相同的定制模式，未单独测试。
