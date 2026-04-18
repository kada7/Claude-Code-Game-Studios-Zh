# Skill Test Spec: /design-review

## 技能摘要

`/design-review` 读取游戏设计文档 (GDD) 并根据项目的8部分设计标准（概述、玩家幻想、详细规则、公式、边缘案例、依赖关系、调整旋钮、验收标准）进行评估。它检查内部一致性、可实施性和跨系统冲突。它产生 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED 的判定。它是一个只读技能（无文件写入）并以 `context: fork` 子代理身份运行。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证——无需 Fixture。

- [ ] 具有必需的前言字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有≥2个阶段标题或编号步骤
- [ ] 包含判定关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不要求“我可以写入”语言（只读技能——`allowed-tools` 排除 Write/Edit）
- [ ] 输出格式有文档说明（技能主体中显示评审模板）

---

## 测试用例

### 用例 1：Happy Path —— 完整的 GDD，所有8部分均存在

**Fixture:**
- `design/gdd/light-manipulation.md` 存在（使用 `_fixtures/minimal-game-concept.md` 作为替身——代表包含所有必需内容的完整文档）
- 所有8个必需部分都填充了实质性内容
- 公式部分包含至少一个具有定义变量的公式
- 验收标准部分包含至少3个可测试的标准

**输入:** `/design-review design/gdd/light-manipulation.md`

**预期行为:**
1. 技能完整读取目标文档
2. 技能读取 CLAUDE.md 获取项目上下文和标准
3. 技能评估所有8个必需部分（存在/不存在检查）
4. 技能检查内部一致性（公式与描述行为匹配）
5. 技能检查可实施性（规则足够精确以便编码）
6. 技能输出结构化评审，包含按部分的状态
7. 技能输出 APPROVED 判定

**断言:**
- [ ] 技能在产生任何输出之前读取目标文件
- [ ] 输出包含“完整性”部分，显示 X/8 个部分存在
- [ ] 输出包含“内部一致性”部分
- [ ] 输出包含“可实施性”部分
- [ ] 输出以判定行结束：APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED
- [ ] 当所有8个部分都存在且一致时给出 APPROVED 判定

---

### 用例 2：失败路径 —— 不完整的 GDD（4/8 部分）

**Fixture:**
- `design/gdd/light-manipulation.md` 存在，使用来自 `tests/skills/_fixtures/incomplete-gdd.md` 的内容（8个部分中填充了4个；公式、边缘案例、调整旋钮、验收标准缺失）

**输入:** `/design-review design/gdd/light-manipulation.md`

**预期行为:**
1. 技能读取文档
2. 技能识别出4个缺失的部分
3. 技能输出“完整性：8个部分中已有4个”
4. 技能具体列出缺失的4个部分
5. 技能输出 MAJOR REVISION NEEDED 判定（非 APPROVED 或 NEEDS REVISION）

**断言:**
- [ ] 输出在完整性部分显示“4/8”（非更高数字）
- [ ] 输出明确命名每个缺失的部分（公式、边缘案例、调整旋钮、验收标准）
- [ ] 当≥3个部分缺失时判定为 MAJOR REVISION NEEDED（非 APPROVED 或 NEEDS REVISION）
- [ ] 输出不暗示文档已准备好实施
- [ ] 技能不写入任何文件（只读强制执行）

---

### 用例 3：部分路径 —— 7/8 部分，轻微不一致

**Fixture:**
- GDD 拥有除公式部分外的所有部分
- 描述的行为提及数值但未定义公式
- 验收标准存在但模糊（“感觉良好”而非可测量的）

**输入:** `/design-review design/gdd/[document].md`

**预期行为:**
1. 技能识别出缺失的公式部分
2. 技能将模糊的验收标准标记为可实施性问题
3. 技能输出 NEEDS REVISION 判定（非 APPROVED，非 MAJOR REVISION NEEDED）
4. 技能为每个问题提供具体的修复说明

**断言:**
- [ ] 对于7/8部分存在问题的情况，判定为 NEEDS REVISION（非 APPROVED，非 MAJOR REVISION NEEDED）
- [ ] 输出具体识别缺失的公式部分
- [ ] 输出将模糊的验收标准标记为可实施性差距
- [ ] 每个标记的问题都有具体、可操作的修复说明

---

### 用例 4：边缘案例 —— 文件未找到

**Fixture:**
- 提供的路径在项目中不存在

**输入:** `/design-review design/gdd/nonexistent.md`

**预期行为:**
1. 技能尝试读取文件
2. 文件未找到
3. 技能输出错误消息，指出缺失的文件
4. 技能建议检查路径或列出 `design/gdd/` 中的文件
5. 技能不产生判定

**断言:**
- [ ] 文件未找到时，技能输出清晰的错误
- [ ] 文件缺失时，技能不输出 APPROVED、NEEDS REVISION 或 MAJOR REVISION NEEDED
- [ ] 技能建议纠正措施（检查路径，列出可用的 GDD）

---

### 用例 5：导演关卡 —— 无论评审模式如何，均不生成关卡

**Fixture:**
- `design/gdd/light-manipulation.md` 存在且包含所有8部分
- `production/session-state/review-mode.txt` 存在且内容为 `full`（最宽松的模式）

**输入:** `/design-review design/gdd/light-manipulation.md` （完全评审模式激活）

**预期行为:**
1. 技能读取 GDD 文档
2. 技能不读取 `review-mode.txt` —— 该技能无导演关卡
3. 技能正常产生评审输出
4. 在任何时候均不生成任何导演关卡代理
5. 判定为 APPROVED（Fixture 中所有8部分存在）

**断言:**
- [ ] 技能不生成任何导演关卡代理（无 CD-、TD-、PR-、AD- 前缀的代理）
- [ ] 技能不读取 `review-mode.txt` 或等效的模式文件
- [ ] `--review` 标志或 `full` 模式状态对是否生成导演无影响
- [ ] 输出不包含任何“关卡：[关卡ID]”条目
- [ ] 技能即评审本身——不将评审委托给导演

---

## 协议合规性

- [ ] 不使用 Write 或 Edit 工具（只读技能）
- [ ] 在所有判定前呈现完整发现
- [ ] 不要求批准后再产生输出（无写入需要批准）
- [ ] 以推荐的下一步结束（例如，修复问题并重新运行，或继续进入 `/map-systems`）

---

## 覆盖范围说明

- 跨系统一致性检查（技能自身阶段列表中的用例 3）在此不直接测试，因为它需要多个 GDD 文件进行比较；这由 `/review-all-gdds` 规范覆盖。
- 技能的 `context: fork` 行为（作为子代理运行）在规范级别未测试——这是运行时行为，需手动验证。
- 涉及非常大 GDD 文件的性能和边缘案例不在覆盖范围内。