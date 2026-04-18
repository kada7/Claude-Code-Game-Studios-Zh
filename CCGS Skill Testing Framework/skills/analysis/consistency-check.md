# 技能测试规范：/consistency-check

## 技能概述

`/consistency-check` 扫描 `design/gdd/` 中的所有 GDD，并检查文档间的内部冲突。它生成一个结构化的发现表格，包含以下列：System A vs System B、Conflict Type、Severity (HIGH / MEDIUM / LOW)。冲突类型包括：formula mismatch、competing ownership、stale reference 和 dependency gap。

该技能在分析过程中是只读的。它没有 director 关卡。如果用户请求，可以将一致性报告写入 `design/consistency-report-[date].md`，但技能在这样做前会询问"我可以写入吗"。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP
- [ ] 在分析过程中不要求"我可以写入"语言（只读扫描）
- [ ] 末尾具有下一步交接
- [ ] 记录报告写入是可选的且需要批准

---

## Director 关卡检查

没有 director 关卡 — 该技能不生成任何 director 关卡 agent。一致性检查是机械扫描；扫描本身不需要创意或技术总监审查。

---

## 测试用例

### 用例 1：Happy Path — 4 个 GDD 无冲突

**Fixture：**
- `design/gdd/` 包含恰好 4 个系统 GDD
- 所有 GDD 具有一致的公式（没有具有不同值的重叠变量）
- 没有两个 GDD 声称拥有相同的游戏实体或机制
- 所有依赖引用指向存在的 GDD

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取 `design/gdd/` 中的所有 4 个 GDD
2. 运行跨 GDD 一致性检查（公式、所有权、引用）
3. 未发现冲突
4. 输出结构化的发现表格，显示 0 个问题
5. 判定：CONSISTENT

**断言：**
- [ ] 在产生输出前读取所有 4 个 GDD
- [ ] 存在发现表格（即使为空 — 显示"No conflicts found"）
- [ ] 当不存在冲突时判定为 CONSISTENT
- [ ] 没有用户批准的情况下，技能不写入任何文件
- [ ] 存在下一步交接

---

### 用例 2：失败路径 — 两个 GDD 具有冲突的伤害公式

**Fixture：**
- GDD-A 定义伤害公式：`damage = attack * 1.5`
- GDD-B 为相同实体类型定义伤害公式：`damage = attack * 2.0`
- 两个 GDD 引用相同的"attack"变量

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检测到公式不匹配
2. 发现表格包含一个条目：GDD-A vs GDD-B | Formula Mismatch | HIGH
3. 显示具体的冲突公式（不仅仅是"formula conflict exists"）
4. 判定：CONFLICTS FOUND

**断言：**
- [ ] 判定为 CONFLICTS FOUND（不是 CONSISTENT）
- [ ] 冲突条目命名了两个 GDD 文件名
- [ ] 冲突类型为"Formula Mismatch"
- [ ] 对于直接的公式矛盾，严重性为 HIGH
- [ ] 在发现表格中显示两个冲突公式
- [ ] 技能不自动解决冲突

---

### 用例 3：部分路径 — GDD 引用一个没有 GDD 的系统

**Fixture：**
- GDD-A 的依赖部分列出"system-B"作为依赖
- `design/gdd/` 中不存在 system-B 的 GDD
- 所有其他 GDD 一致

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并检查依赖引用
2. GDD-A 对"system-B"的引用无法解析 — 没有其 GDD 存在
3. 发现表格包含：GDD-A vs (missing) | Dependency Gap | MEDIUM
4. 判定：DEPENDENCY GAP（不是 CONSISTENT，也不是 CONFLICTS FOUND）

**断言：**
- [ ] 判定为 DEPENDENCY GAP（与 CONSISTENT 和 CONFLICTS FOUND 不同）
- [ ] 发现条目命名了 GDD-A 和缺失的 system-B
- [ ] 对于未解析的依赖引用，严重性为 MEDIUM
- [ ] 技能建议运行 `/design-system system-B` 以创建缺失的 GDD

---

### 用例 4：边界情况 — 未找到 GDD

**Fixture：**
- `design/gdd/` 目录为空或不存在

**输入：** `/consistency-check`

**预期行为：**
1. 技能尝试读取 `design/gdd/` 中的文件
2. 未找到 GDD 文件
3. 技能输出错误："No GDDs found in `design/gdd/`. Run `/design-system` to create GDDs first."
4. 不产生发现表格
5. 不发布判定

**断言：**
- [ ] 当未找到 GDD 时，技能输出清晰的错误信息
- [ ] 不产生判定（CONSISTENT / CONFLICTS FOUND / DEPENDENCY GAP）
- [ ] 技能推荐正确的下一步操作（`/design-system`）
- [ ] 技能不崩溃或不产生部分报告

---

### 用例 5：Director 关卡 — 没有生成关卡；不读取 review-mode.txt

**Fixture：**
- `design/gdd/` 包含 ≥2 个 GDD
- `production/session-state/review-mode.txt` 存在且包含 `full`

**输入：** `/consistency-check`

**预期行为：**
1. 技能读取所有 GDD 并运行一致性扫描
2. 技能不读取 `production/session-state/review-mode.txt`
3. 在任何时候都不生成 director 关卡 agent
4. 正常产生发现表格和判定

**断言：**
- [ ] 不生成 director 关卡 agent（没有 CD-、TD-、PR-、AD- 前缀的关卡）
- [ ] 技能不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含"Gate: [GATE-ID]"或 gate-skipped 条目
- [ ] 审查模式对此技能的行为没有影响

---

## 协议合规性

- [ ] 在产生发现表格前读取所有 GDD
- [ ] 在任何写入询问前完整显示发现表格（如果请求报告）
- [ ] 判定恰好为以下之一：CONSISTENT、CONFLICTS FOUND、DEPENDENCY GAP
- [ ] 没有 director 关卡 — 不读取 review-mode.txt
- [ ] 报告写入（如果请求）由"我可以写入"批准控制
- [ ] 以适合判定的下一步交接结束

---

## 覆盖范围说明

- 此技能检查 GDD 间的结构一致性。深入的设计理论分析（pillar drift、dominant strategies）由 `/review-all-gdds` 处理。
- 公式冲突检测依赖于 GDD 间一致的公式表示法 — 可能无法检测到相同机制的非正式描述。
- 冲突严重性评分标准（HIGH / MEDIUM / LOW）在技能主体中定义，此处不再枚举。