# 技能测试规范：/launch-checklist

## 技能摘要

`/launch-checklist` 生成并评估完整的发布准备清单，涵盖：法律合规（EULA、隐私政策、ESRB/PEGI 分级）、平台认证状态、商店页面完整性（截图、描述、元数据）、构建验证（版本标签、可复现构建）、分析和崩溃报告配置，以及首次运行体验验证。

该技能生成清单报告，在询问"May I write"后写入 `production/launch/launch-checklist-[date].md`。如果存在之前的发布清单，它会将新结果与旧结果进行比较，突出显示新解决和新阻塞的项目。不适用总监关卡 —— `/team-release` 负责完整的发布流水线。裁决：LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：LAUNCH READY、LAUNCH BLOCKED、CONCERNS
- [ ] 包含 "May I write" 协作协议语言，在写入清单前
- [ ] 具有下一步交接（例如，`/team-release` 或 `/day-one-patch`）

---

## 总监关卡检查

无。`/launch-checklist` 是准备情况审计工具。完整的发布流水线由 `/team-release` 管理。

---

## 测试用例

### 用例 1：理想路径 —— 所有清单项目已验证，LAUNCH READY

**测试夹具：**
- 法律文档存在：`production/legal/` 中有 EULA、隐私政策
- 平台认证：在生产备注中标记为已提交并已批准
- 商店页面资产：`production/store/` 中有截图、描述、元数据
- 构建：版本标签 `v1.0.0` 存在，可复现构建已确认
- 崩溃报告：在 `technical-preferences.md` 中已配置

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有清单类别
2. 所有项目均通过验证检查
3. 技能生成所有项目标记为 PASS 的清单报告
4. 技能询问"May I write to `production/launch/launch-checklist-2026-04-06.md`?"
5. 报告在批准后写入；裁决为 LAUNCH READY

**断言：**
- [ ] 检查了所有清单类别（法律、平台、商店、构建、分析、UX）
- [ ] 报告中所有项目均显示 PASS 标记
- [ ] 裁决为 LAUNCH READY
- [ ] "May I write" 询问了正确的带日期文件名

---

### 用例 2：平台认证未提交 —— LAUNCH BLOCKED

**测试夹具：**
- 所有其他清单项目通过
- 平台认证部分："not submitted"（未找到提交记录）

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有项目
2. 平台认证检查失败：无提交记录
3. 技能报告："LAUNCH BLOCKED — Platform certification not submitted"
4. 指定缺失认证的具体平台
5. 裁决为 LAUNCH BLOCKED

**断言：**
- [ ] 裁决为 LAUNCH BLOCKED（非 CONCERNS）
- [ ] 平台认证被识别为阻塞项
- [ ] 指定了缺失的平台名称
- [ ] 报告中仍显示所有其他通过的项目

---

### 用例 3：需要手动检查 —— CONCERNS 裁决

**测试夹具：**
- 所有关键清单项目通过
- 首次运行体验项目："MANUAL CHECK NEEDED — human must play the first 5 minutes and verify tutorial completion flow"
- 商店截图项目："MANUAL CHECK NEEDED — art team must verify screenshot quality matches current build"

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有项目
2. 2 个项目被标记为需要人工验证
3. 技能报告："CONCERNS — 2 items require manual verification before launch"
4. 两个项目均列出需要手动验证的内容说明
5. 裁决为 CONCERNS（非 LAUNCH BLOCKED，因为这些是咨询性的）

**断言：**
- [ ] 裁决为 CONCERNS（非 LAUNCH READY 或 LAUNCH BLOCKED）
- [ ] 两个手动检查项目均列出验证说明
- [ ] 技能不会在 MANUAL CHECK 项目上自动阻塞

---

### 用例 4：存在之前的清单 —— 差异对比

**测试夹具：**
- `production/launch/launch-checklist-2026-03-25.md` 存在，包含之前的结果：
  - 2 个项目为 BLOCKED（平台认证、崩溃报告）
  - 1 个项目为 MANUAL CHECK
- 新清单：平台认证现为 PASS，崩溃报告现为 PASS，手动检查仍然开放；标记 1 个新问题（EULA 最后更新日期）

**输入：** `/launch-checklist`

**预期行为：**
1. 技能找到之前的清单并加载以进行比较
2. 技能生成新清单并进行比较：
   - 新解决："Platform cert — was BLOCKED, now PASS"
   - 新解决："Crash reporting — was BLOCKED, now PASS"
   - 仍然开放：手动检查（未变更）
   - 新问题：EULA 最后更新日期（之前的清单中不存在）
3. 差异在报告中醒目展示
4. 裁决为 CONCERNS（手动检查 + 新的 EULA 问题）

**断言：**
- [ ] 差异部分展示新解决的项目
- [ ] 差异部分展示新问题（之前的清单中不存在）
- [ ] 之前清单中仍然开放的项目被标记为持续存在
- [ ] 裁决反映当前状态（非之前状态）

---

### 用例 5：总监关卡检查 —— 无关卡；launch-checklist 是审计工具

**测试夹具：**
- 所有清单依赖项存在

**输入：** `/launch-checklist`

**预期行为：**
1. 技能运行完整的清单并写入报告
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS —— 无关卡裁决

---

## 协议合规性

- [ ] 检查所有必需类别（法律、平台、商店、构建、分析、UX）
- [ ] 对于硬失败（未完成的认证、缺失的法律文档）裁决为 LAUNCH BLOCKED
- [ ] 对于需要人工验证的咨询项裁决为 CONCERNS
- [ ] 存在之前的清单时进行对比
- [ ] 在创建清单报告前询问 "May I write"
- [ ] 裁决为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS

---

## 覆盖说明

- 区域特定合规（GDPR 数据处理、COPPA 面向 13 岁以下受众）已检查，但具体需求未在测试断言中枚举。
- 商店页面完整性检查（截图、描述）依赖 `production/store/` 中文件的存在；它无法验证视觉质量。
- 构建可复现性检查验证版本标签和构建配置的存在，但不执行构建过程。
