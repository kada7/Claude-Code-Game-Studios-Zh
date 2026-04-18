# 架构可追溯性索引

<!-- 动态文档 — 每次审查运行后由 /architecture-review 更新。
     除非修正错误，否则不要手动编辑。 -->

## 文档状态

- **最后更新**: [YYYY-MM-DD]
- **引擎**: [例如 Godot 4.6]
- **已索引的GDD数量**: [N]
- **已索引的ADR数量**: [M]
- **最近审查**: [指向 docs/architecture/architecture-review-[date].md 的链接]

## 覆盖摘要

| 状态 | 数量 | 百分比 |
|--------|-------|-----------|
| ✅ 已覆盖 | [X] | [%] |
| ⚠️ 部分覆盖 | [Y] | [%] |
| ❌ 缺口 | [Z] | [%] |
| **总计** | **[N]** | |

---

## 可追溯性矩阵

<!-- 每个从GDD中提取的技术需求对应一行。
     "技术需求"指任何暗示特定架构决策的GDD语句：数据结构、性能约束、所需的引擎能力、跨系统通信、状态持久化。 -->

| 需求ID | GDD | 系统 | 需求摘要 | ADR(s) | 状态 | 备注 |
|--------|-----|--------|---------------------|--------|--------|-------|
| TR-[gdd]-001 | [filename] | [system name] | [one-line summary] | [ADR-NNNN] | ✅ | |
| TR-[gdd]-002 | [filename] | [system name] | [one-line summary] | — | ❌ 缺口 | 需要 `/architecture-decision [title]` |

---

## 已知缺口

无ADR覆盖的需求，按层级优先排序（Foundation层优先）：

### Foundation层缺口（阻塞性 — 必须在编码前解决）
- [ ] TR-[id]: [requirement] — GDD: [file] — 建议ADR: "[title]"

### Core层缺口（必须在相关系统构建前解决）
- [ ] TR-[id]: [requirement] — GDD: [file] — 建议ADR: "[title]"

### Feature层缺口（应在功能冲刺前解决）
- [ ] TR-[id]: [requirement] — GDD: [file] — 建议ADR: "[title]"

### Presentation层缺口（可推迟到实现阶段）
- [ ] TR-[id]: [requirement] — GDD: [file] — 建议ADR: "[title]"

---

## 跨ADR冲突

<!-- 做出矛盾声明的ADR对。必须解决。 -->

| 冲突ID | ADR A | ADR B | 类型 | 状态 |
|-------------|-------|-------|------|--------|
| CONFLICT-001 | ADR-NNNN | ADR-MMMM | 数据所有权 | 🔴 未解决 |

---

## ADR → GDD 覆盖（反向索引）

<!-- 对于每个ADR，它解决了哪些GDD需求？ -->

| ADR | 标题 | 已解决的GDD需求 | 引擎风险 |
|-----|-------|---------------------------|-------------|
| ADR-0001 | [title] | TR-combat-001, TR-combat-002 | HIGH |

---

## 已过时的需求

<!-- ADR编写时GDD中存在，但GDD后来发生了变化的需求。ADR可能需要更新。 -->

| 需求ID | GDD | 变更 | 受影响的ADR | 状态 |
|--------|-----|--------|-------------|--------|
| TR-[id] | [file] | [what changed] | ADR-NNNN | 🔴 ADR需要更新 |

---

## 如何使用本文档

**编写新ADR时**: 将其添加到"ADR → GDD 覆盖"表中，并在矩阵中将它满足的需求标记为✅。

**批准GDD变更时**: 扫描矩阵中该GDD的需求，检查变更是否使任何现有ADR失效。如果是，则添加到"已过时的需求"。

**运行 `/architecture-review` 时**: 该技能将自动用当前状态更新此文档。

**门控检查**: Pre-Production阶段门控要求此文档存在且Foundation层缺口为零。