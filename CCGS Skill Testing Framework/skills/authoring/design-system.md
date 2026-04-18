# 技能测试规范：/design-system

## 技能摘要

`/design-system` 引导用户逐节编写单个游戏系统的游戏设计文档（GDD）。必须编写所有8个必需部分：概述、玩家幻想、详细规则、公式、边界情况、依赖关系、调优旋钮和验收标准。该技能采用骨架优先方法——在填充任何内容之前创建包含所有8个节头的GDD文件——并在批准后单独编写每个部分。

CD-GDD-ALIGN 门（creative-director）在 `full` 和 `lean` 模式下运行。仅在 `solo` 模式下跳过。如果找到现有的GDD文件，该技能提供改造模式来更新特定部分，而不是重写整个文档。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——无需夹具。

- [ ] 具有必需的前置字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有≥2个阶段标题
- [ ] 包含裁决关键词：APPROVED、NEEDS REVISION、MAJOR REVISION
- [ ] 包含"May I write"协作协议语言（每节批准）
- [ ] 末尾有下一步交接
- [ ] 记录骨架优先方法（在内容之前创建包含头的文件）
- [ ] 记录CD-GDD-ALIGN门：在full和lean模式下激活；仅在solo模式下跳过
- [ ] 记录现有GDD文件的改造模式

---

## 导演门检查

在 `full` 模式下：CD-GDD-ALIGN（creative-director）门在每个部分起草后、写入前运行。如果返回MAJOR REVISION，必须在继续之前重写该部分。

在 `lean` 模式下：CD-GDD-ALIGN仍然运行（此门在lean模式下不会跳过——它在full和lean模式下都运行）。仅solo模式跳过它。

在 `solo` 模式下：CD-GDD-ALIGN被跳过。输出说明："CD-GDD-ALIGN skipped — solo mode"。部分仅通过用户批准写入。

---

## 测试用例

### 用例1：快乐路径——新GDD，骨架优先，lean模式下的CD-GDD-ALIGN

**夹具：**
- `design/gdd/` 中没有目标系统的现有GDD
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/design-system [system-name]`

**预期行为：**
1. 技能创建骨架文件 `design/gdd/[system-name].md`，包含所有8个节头（空正文）
2. 对于每个部分：与用户讨论，起草内容，显示草稿
3. CD-GDD-ALIGN门在每个部分草稿上运行（lean模式——门激活）
4. 门为每个部分返回APPROVED
5. 门批准后询问"May I write [section]?"
6. 用户批准后将部分写入文件
7. 对所有8个部分重复此过程

**断言：**
- [ ] 在写入任何内容之前创建包含所有8个节头的骨架文件
- [ ] CD-GDD-ALIGN在lean模式下在每个部分上运行（未跳过）
- [ ] 每节询问"May I write"（不是一次为所有部分）
- [ ] 每个部分在门+用户批准后单独写入
- [ ] 所有8个部分都存在于最终的GDD文件中

---

### 用例2：改造模式——现有GDD，更新特定部分

**夹具：**
- `design/gdd/[system-name].md` 已存在并填充了所有8个部分

**输入：** `/design-system [system-name]`

**预期行为：**
1. 技能检测到现有的GDD文件并读取其当前内容
2. 技能提供改造模式："GDD already exists. Which section would you like to update?"
3. 用户选择特定部分（例如，Formulas）
4. 技能仅编写该部分，运行CD-GDD-ALIGN，询问"May I write?"
5. 仅更新选定的部分——其他部分未修改

**断言：**
- [ ] 技能在提供改造模式之前检测并读取现有GDD
- [ ] 询问用户要更新哪个部分——不要求重写整个文档
- [ ] 仅重写选定的部分——其他部分保持不变
- [ ] CD-GDD-ALIGN仍在更新的部分上运行
- [ ] 在更新部分之前询问"May I write"

---

### 用例3：导演门——CD-GDD-ALIGN返回MAJOR REVISION

**夹具：**
- 正在编写新GDD
- `production/session-state/review-mode.txt` 包含 `lean`
- CD-GDD-ALIGN门在Player Fantasy部分返回MAJOR REVISION

**输入：** `/design-system [system-name]`

**预期行为：**
1. Player Fantasy部分被起草
2. CD-GDD-ALIGN门运行并返回带有具体反馈的MAJOR REVISION
3. 技能向用户展示反馈
4. 当MAJOR REVISION未解决时，部分不会写入文件
5. 用户与技能协作重写该部分
6. CD-GDD-ALIGN在修订后的部分上再次运行
7. 如果修订后的部分通过，询问"May I write?"并写入部分

**断言：**
- [ ] 当CD-GDD-ALIGN返回MAJOR REVISION时，部分不会写入
- [ ] 在请求修订之前向用户显示门反馈
- [ ] 部分修订后再次运行CD-GDD-ALIGN
- [ ] 当MAJOR REVISION未解决时，技能不会自动进行到下一部分

---

### 用例4：Solo模式——CD-GDD-ALIGN跳过；部分仅通过用户批准写入

**夹具：**
- 正在编写新GDD
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/design-system [system-name]`

**预期行为：**
1. 创建包含8个节头的骨架文件
2. 对于每个部分：起草，向用户显示
3. CD-GDD-ALIGN被跳过——每节注明："CD-GDD-ALIGN skipped — solo mode"
4. 用户审查草稿后询问"May I write [section]?"
5. 用户批准后写入部分
6. 任何阶段都没有门审查

**断言：**
- [ ] 每节注明"CD-GDD-ALIGN skipped — solo mode"
- [ ] 部分仅通过用户批准写入（无需门）
- [ ] 技能在solo模式下不会生成任何CD-GDD-ALIGN门
- [ ] 在solo模式下仅通过用户批准编写完整的GDD

---

### 用例5：导演门——空部分不会写入文件

**夹具：**
- GDD编写进行中
- 用户和技能讨论一个部分但未产生任何批准内容
  （例如，讨论结束时没有决定，或用户说"skip for now"）

**输入：** `/design-system [system-name]`

**预期行为：**
1. 部分讨论未产生任何批准内容
2. 技能不会向该部分写入空或占位符正文
3. 节头保留在骨架文件中，但正文保持为空
4. 技能移动到下一部分而不写入空的部分
5. 结束时，列出不完整的部分并提醒用户返回处理它们

**断言：**
- [ ] 空或未批准的部分不会写入文件
- [ ] 骨架节头保留（保持结构）
- [ ] 技能在会话结束时跟踪并列出不完整的部分
- [ ] 技能不会在未经用户批准的情况下写入"TBD"或占位符内容

---

## 协议合规性

- [ ] 在写入任何内容之前创建包含所有8个头的骨架文件
- [ ] CD-GDD-ALIGN在full和lean模式下都运行（不仅仅是full）
- [ ] CD-GDD-ALIGN仅在solo模式下跳过——每节注明
- [ ] 每节询问"May I write [section]?"（不是一次为整个文档）
- [ ] 来自CD-GDD-ALIGN的MAJOR REVISION在解决之前阻止部分写入
- [ ] 仅将批准的、非空的部分写入文件
- [ ] 以下一步交接结束：`/review-all-gdds` 或 `/map-systems next`

---

## 覆盖范围说明

- 8个必需部分根据项目的设计文档标准（在`CLAUDE.md`中定义）进行验证——此处不重新枚举。
- 技能的内部部分排序逻辑（首先编写哪个部分）不独立测试——顺序遵循标准的GDD模板。
- CD-GDD-ALIGN内的支柱对齐检查由门代理整体评估——具体的支柱检查不在此处进行夹具测试。