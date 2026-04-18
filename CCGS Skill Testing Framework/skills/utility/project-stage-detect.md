# 技能测试规范：/project-stage-detect

## 技能摘要

`/project-stage-detect` 自动分析项目工件以确定当前的开发阶段。它在 Haiku 模型上运行（只读），检查 `production/stage.txt`（如果存在）、`design/` 中的设计文档、`src/` 中的源代码、`production/` 中的 Sprint 和里程碑文件，以及引擎配置的存在，将项目分类为七个阶段之一：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish 或 Release。

该技能是咨询性的 —— 它从不写入 `stage.txt`。该文件仅在 `/gate-check` 通过且用户确认推进时更新。技能报告其置信度（如果直接读取了 stage.txt 则为 HIGH，如果从工件推断则为 MEDIUM，如果找到冲突信号则为 LOW）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含所有七个阶段名称：Concept、Systems Design、Technical Setup、Pre-Production、Production、Polish、Release
- [ ] 不包含 "May I write" 语言（技能仅为检测）
- [ ] 具有下一步交接（例如，`/gate-check` 以正式推进阶段）

---

## 总监关卡检查

无。`/project-stage-detect` 是只读检测工具。不适用总监关卡。

---

## 测试用例

### 用例 1：stage.txt 存在 —— 直接读取并交叉检查工件

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 4 个 GDD 文件
- `src/` 有源代码文件
- `production/sprints/sprint-002.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能读取 `production/stage.txt` —— 检测到 `Production` 阶段
2. 技能交叉检查工件：GDD 存在、源代码存在、Sprint 存在
3. 工件与 Production 阶段一致
4. 技能报告：Stage = Production, Confidence = HIGH（来自 stage.txt，经工件确认）
5. 下一步：继续 `/sprint-plan` 或 `/dev-story`

**断言：**
- [ ] 检测到的阶段是 Production
- [ ] 当 stage.txt 存在时，置信度报告为 HIGH
- [ ] 注明了交叉检查结果（一致 vs. 不符）
- [ ] 未写入任何文件
- [ ] 裁决明确声明了检测到的阶段

---

### 用例 2：无 stage.txt 但存在 GDD 和 Epic —— 推断为 Production

**测试夹具：**
- 无 `production/stage.txt`
- `design/gdd/` 有 3 个 GDD 文件
- `production/epics/` 有 2 个 epic 文件
- `src/` 有源代码文件
- `production/sprints/sprint-001.md` 存在

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能未找到 stage.txt —— 切换到工件推断模式
2. 技能找到 GDD（Systems Design 完成）、epic（Pre-Production 完成）、源代码和 Sprint（Production 进行中）
3. 技能推断：Stage = Production
4. 置信度为 MEDIUM（从工件推断，非来自 stage.txt）
5. 技能建议运行 `/gate-check` 以正式确定并写入 stage.txt

**断言：**
- [ ] 推断的阶段是 Production
- [ ] 置信度为 MEDIUM（非 HIGH，因为 stage.txt 缺失）
- [ ] 存在运行 `/gate-check` 的建议
- [ ] 此技能未写入 stage.txt

---

### 用例 3：无 stage.txt、无文档、无源代码 —— 推断为 Concept

**测试夹具：**
- 无 `production/stage.txt`
- `design/` 目录存在但为空
- `src/` 存在但无代码文件
- `technical-preferences.md` 仅有占位符

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能未找到 stage.txt
2. 工件扫描：无 GDD、无源代码、无 epic、无 Sprint、引擎未配置
3. 技能推断：Stage = Concept
4. 置信度为 MEDIUM
5. 技能建议 `/start` 以开始入职工作流

**断言：**
- [ ] 推断的阶段是 Concept
- [ ] 输出列出了已检查的工件（及未找到的）
- [ ] `/start` 被建议为下一步
- [ ] 未写入任何文件

---

### 用例 4：差异 —— stage.txt 显示 Production 但无源代码

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `design/gdd/` 有 GDD 文件
- `src/` 目录存在但无源代码文件
- 无 Sprint 文件存在

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能读取 stage.txt —— 检测到 `Production`
2. 交叉检查发现：无源代码、无 Sprint —— 与 Production 不一致
3. 技能标记差异："stage.txt says Production but no source code or sprints found"
4. 技能将检测到的阶段报告为 Production（尊重 stage.txt），但由于工件不匹配，置信度降至 LOW
5. 技能建议手动审查 stage.txt 或运行 `/gate-check`

**断言：**
- [ ] 输出中明确标记了差异
- [ ] 当工件与 stage.txt 矛盾时，置信度为 LOW
- [ ] stage.txt 值未被静默覆盖
- [ ] 建议用户手动验证差异

---

### 用例 5：总监关卡检查 —— 无关卡；检测是咨询性的

**测试夹具：**
- 任何有或没有 stage.txt 的项目状态

**输入：** `/project-stage-detect`

**预期行为：**
1. 技能完成完整的阶段检测
2. 任何时刻都不生成总监代理
3. 输出中不出现关卡 ID
4. 未调用 Write 工具

**断言：**
- [ ] 未调用总监关卡
- [ ] 未调用 Write 工具
- [ ] 检测输出纯粹是咨询性的
- [ ] 裁决命名检测到的阶段而不触发任何关卡

---

## 协议合规性

- [ ] 如果存在则读取 stage.txt；如果不存在则回退到工件推断
- [ ] 始终报告置信度（HIGH / MEDIUM / LOW）
- [ ] 将 stage.txt 与工件交叉检查并标记差异
- [ ] 不写入 stage.txt（这是 `/gate-check` 的职责）
- [ ] 以适合检测到的阶段的下一步建议结束

---

## 覆盖说明

- Technical Setup 阶段（引擎已配置，尚无 GDD）和 Pre-Production 阶段（GDD 完成，尚无 epic）遵循与用例 2 和 3 相同的工件推断模式，未单独使用夹具测试。
- Polish 和 Release 阶段未在此处使用夹具测试；它们遵循相同的 stage.txt 存在时的高置信度或推断逻辑。
- 置信度是咨询性的 —— 技能不会根据置信度对任何操作进行关卡限制。
