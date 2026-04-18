# 技能测试规范：/prototype

## 技能摘要

`/prototype` 管理快速原型工作流，用于在投入完整生产实现之前验证游戏机制。原型在 `prototypes/[mechanic-name]/` 中创建，故意设计为一次性使用 —— 编码标准放宽（无需 ADR，AC 可以最小化，硬编码值可接受）。实现后，技能生成一份 findings 文档，总结所学内容并推荐后续步骤。

技能在创建文件前询问"May I write to `prototypes/[name]/`?"。如果原型已存在，技能会提议扩展、替换或归档。不适用总监关卡。裁决：PROTOTYPE COMPLETE（原型已构建且 findings 已记录）或 PROTOTYPE ABANDONED（机制被证明不可行）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：PROTOTYPE COMPLETE、PROTOTYPE ABANDONED
- [ ] 包含 "May I write" 语言，在创建原型文件前
- [ ] 具有下一步交接（例如，`/design-system` 以规范化，或归档）

---

## 总监关卡检查

无。原型是一次性验证工件。不适用总监关卡。

---

## 测试用例

### 用例 1：理想路径 —— 机制概念原型化，findings 已记录

**测试夹具：**
- `prototypes/` 目录存在
- "grapple-hook" 尚无现有原型

**输入：** `/prototype grapple-hook`

**预期行为：**
1. 技能询问"May I write to `prototypes/grapple-hook/`?"
2. 批准后：创建 `prototypes/grapple-hook/` 目录和基本实现骨架（主场景、玩家控制器扩展）
3. 技能实现最小化的 grapple hook 机制（故意粗糙 —— 无需打磨，硬编码值可接受）
4. 技能生成 `prototypes/grapple-hook/findings.md`，包含：
   - What was tested
   - What worked
   - What didn't work
   - Recommendation (proceed / abandon / revise concept)
5. 裁决为 PROTOTYPE COMPLETE

**断言：**
- [ ] 在创建任何文件前询问 "May I write to `prototypes/grapple-hook/`?"
- [ ] 实现隔离在 `prototypes/` 中（非 `src/`）
- [ ] `findings.md` 至少包含：tested/worked/didn't-work/recommendation
- [ ] 裁决为 PROTOTYPE COMPLETE

---

### 用例 2：原型已存在 —— 提供 Extend、Replace 或 Archive 选项

**测试夹具：**
- `prototypes/grapple-hook/` 已从之前的原型会话存在
- 包含基本实现和 findings.md

**输入：** `/prototype grapple-hook`

**预期行为：**
1. 技能检测到现有的 `prototypes/grapple-hook/` 目录
2. 技能报告："Prototype already exists for grapple-hook"
3. 技能展示 3 个选项：
   - Extend：向现有原型添加新功能
   - Replace：重新开始（询问 "May I replace `prototypes/grapple-hook/`?"）
   - Archive：移动到 `prototypes/archive/grapple-hook/` 并重新开始
4. 用户选择；技能继续执行

**断言：**
- [ ] 检测到现有原型并报告
- [ ] 恰好展示 3 个选项（extend、replace、archive）
- [ ] Replace 路径包含 "May I replace" 确认
- [ ] Archive 路径移动（非删除）现有原型

---

### 用例 3：原型验证机制 —— 建议推进到生产

**测试夹具：**
- 原型实现完成
- Findings：grapple hook 机制有趣且技术上可行

**输入：** `/prototype grapple-hook`（原型会话完成）

**预期行为：**
1. 原型构建和测试后，总结 findings
2. findings.md 中的推荐："Mechanic validated — recommend proceeding to `/design-system` for full specification"
3. 技能交接消息明确建议 `/design-system grapple-hook`
4. 裁决为 PROTOTYPE COMPLETE

**断言：**
- [ ] `findings.md` 包含明确的推荐
- [ ] 机制验证后，推荐引用 `/design-system`
- [ ] 交接消息呼应推荐
- [ ] 裁决为 PROTOTYPE COMPLETE（非 PROTOTYPE ABANDONED）

---

### 用例 4：原型揭示机制不可行 —— PROTOTYPE ABANDONED

**测试夹具：**
- 已为 "procedural-dialogue" 实现原型
- 测试后：该机制生成不连贯的对话树，玩起来令人沮丧

**输入：** `/prototype procedural-dialogue`

**预期行为：**
1. 原型已构建
2. Findings 记录失败：不连贯的输出、玩家困惑、技术复杂性
3. findings.md 中的推荐："Mechanic not viable — abandoning"
4. `findings.md` 记录了机制失败的具体原因
5. 技能在交接中建议替代方案（例如，curated dialogue）
6. 裁决为 PROTOTYPE ABANDONED

**断言：**
- [ ] 裁决为 PROTOTYPE ABANDONED（非 PROTOTYPE COMPLETE）
- [ ] `findings.md` 记录了具体的失败原因（非模糊）
- [ ] 交接中建议了替代方法
- [ ] 保留原型文件（未删除）以供参考

---

### 用例 5：总监关卡检查 —— 无关卡；原型是验证工件

**测试夹具：**
- 提供了机制概念

**输入：** `/prototype wall-jump`

**预期行为：**
1. 技能创建并记录原型
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED —— 无关卡裁决

---

## 协议合规性

- [ ] 在创建任何文件前询问 "May I write to `prototypes/[name]/`?"
- [ ] 在 `prototypes/` 下创建所有文件（非 `src/`）
- [ ] 生成包含 tested/worked/didn't-work/recommendation 的 `findings.md`
- [ ] 注明生产编码标准被故意放宽
- [ ] 原型已存在时提供 extend/replace/archive 选项
- [ ] 裁决为 PROTOTYPE COMPLETE 或 PROTOTYPE ABANDONED

---

## 覆盖说明

- 原型实现质量（代码风格）故意不测试 —— 原型是一次性工件，质量标准不适用。
- 用例 2 中提到了归档机制，但未详细断言测试归档格式。
- 引擎特定的原型脚手架（GDScript 场景 vs. C# MonoBehaviour）遵循相同的流程，使用引擎适当的文件类型。
