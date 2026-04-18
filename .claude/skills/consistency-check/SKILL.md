---
name: consistency-check
description: "扫描所有GDD与实体注册表对比，检测跨文档不一致性：同一实体不同属性、同一物品不同数值、同一公式不同变量。优先使用Grep方法 — 读取注册表后仅定位冲突的GDD章节而非完整文档读取。"
argument-hint: "[full | since-last-review | entity:<name> | item:<name>]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# 一致性检查

通过将所有GDD与实体注册表（`design/registry/entities.yaml`）进行对比，检测跨文档不一致性。使用grep优先方法：先读取一次注册表，然后只定位提及注册名称的GDD部分 — 除非冲突需要调查，否则不进行完整文档读取。

**此技能是写入时的安全网。** 它捕获 `/design-system` 的逐节检查可能遗漏的内容，以及 `/review-all-gdds` 的整体审查发现太晚的内容。

**运行时机：**
- 写入每个新GDD后（在转到下一个系统之前）
- 在 `/review-all-gdds` 之前（以便该技能从干净的基线开始）
- 在 `/create-architecture` 之前（不一致性会污染下游ADR）
- 按需：`/consistency-check entity:[name]` 专门检查一个实体

**输出：** 冲突报告 + 可选的注册表更正

---

## 阶段1：解析参数并加载注册表

**模式：**
- 无参数 / `full` — 对照所有GDD检查所有注册条目
- `since-last-review` — 仅检查自上次审查报告以来修改的GDD
- `entity:<name>` — 跨所有GDD检查一个特定实体
- `item:<name>` — 跨所有GDD检查一个特定物品

**加载注册表：**

```
Read path="design/registry/entities.yaml"
```

如果文件不存在或无条目：
> "实体注册表为空。运行 `/design-system` 写入GDD — 每个GDD完成后注册表会自动填充。目前没有内容可检查。"

停止并退出。

从注册表构建四个查找表：
- **entity_map**：`{ name → { source, attributes, referenced_by } }`
- **item_map**：`{ name → { source, value_gold, weight, ... } }`
- **formula_map**：`{ name → { source, variables, output_range } }`
- **constant_map**：`{ name → { source, value, unit } }`

计算注册条目总数。报告：
```
注册表已加载：[N] 个实体，[N] 个物品，[N] 个公式，[N] 个常量
范围：[full | since-last-review | entity:name]
```

---

## 阶段2：定位范围内的GDD

```
Glob pattern="design/gdd/*.md"
```

排除：`game-concept.md`、`systems-index.md`、`game-pillars.md` — 这些不是系统GDD。

对于 `since-last-review` 模式：
```bash
git log --name-only --pretty=format: -- design/gdd/ | grep "\.md$" | sort -u
```
限制为自最近 `design/gdd/gdd-cross-review-*.md` 文件创建日期以来修改的GDD。

扫描前报告范围内的GDD列表。

---

## 阶段3：Grep优先冲突扫描

对于每个注册条目，在每个范围内的GDD中grep该条目的名称。不要进行完整读取 — 只提取匹配行及其直接上下文（-C 3行）。

这是核心优化：不是读取10个GDD × 每个400行（4,000行），而是grep 50个实体名称 × 10个GDD（50次有针对性的搜索，每次命中时返回约10行）。

### 3a：实体扫描

对于entity_map中的每个实体：

```
Grep pattern="[entity_name]" glob="design/gdd/*.md" output_mode="content" -C 3
```

对于每个GDD命中，提取实体名称附近提及的值：
- 任何数字属性（计数、成本、持续时间、范围、比率）
- 任何分类属性（类型、等级、类别）
- 任何派生值（总计、输出、结果）
- entity_map中注册的任何其他属性

将提取的值与注册条目进行比较。

**冲突检测：**
- 注册表说 `[entity_name].[attribute] = [value_A]`。GDD说 `[entity_name] 有 [value_B]`。→ **冲突**
- 注册表说 `[item_name].[attribute] = [value_A]`。GDD说 `[item_name] 是 [value_B]`。→ **冲突**
- GDD提及 `[entity_name]` 但未指定属性。→ **注意**（无冲突，只是不可验证）

### 3b：物品扫描

对于item_map中的每个物品，在所有GDD中grep该物品名称。提取：
- 出售价格/价值/金币值
- 重量
- 堆叠规则（可堆叠/不可堆叠）
- 类别

与注册条目值进行比较。

### 3c：公式扫描

对于formula_map中的每个公式，在所有GDD中grep该公式名称。提取：
- 公式附近提及的变量名
- 提及的输出范围或上限值

与注册条目进行比较：
- 不同的变量名 → **冲突**
- 输出范围表述不同 → **冲突**

### 3d：常量扫描

对于constant_map中的每个常量，在所有GDD中grep该常量名称。提取：
- 常量名附近提及的任何数字值

与注册值进行比较：
- 不同的数字 → **冲突**

---

## 阶段4：深入调查（仅限冲突）

对于阶段3中发现的每个冲突，对冲突的GDD进行有针对性的完整部分读取以获取精确上下文：

```
Read path="design/gdd/[conflicting_gdd].md"
```
（或者如果文件很大，使用更宽上下文的Grep）

用完整上下文确认冲突。确定：
1. **哪个GDD是正确的？** 检查注册表中的 `source:` 字段 — 源GDD是权威所有者。任何与其矛盾的其他GDD都是需要更新的那个。
2. **注册表本身是否过时？** 如果源GDD在注册条目写入后被更新（检查git log），注册表可能已陈旧。
3. **这是真正的设计变更吗？** 如果冲突代表有意的设计决策，解决方案是：更新源GDD、更新注册表，然后修复所有其他GDD。

对于每个冲突，分类：
- **🔴 冲突** — 不同GDD中具有不同值的同名实体/物品/公式/常量。在架构开始之前必须解决。
- **⚠️ 注册表陈旧** — 源GDD值已更改但注册表未更新。注册表需要更新；其他GDD可能已经正确。
- **ℹ️ 不可验证** — 实体被提及但未陈述可比属性。不是冲突；只是注明引用。

---

## 阶段5：输出报告

```
## 一致性检查报告
日期：[日期]
检查的注册条目：[N个实体，N个物品，N个公式，N个常量]
扫描的GDD：[N]（[列出名称]）

---

### 发现的冲突（在架构之前必须解决）

🔴 [实体/物品/公式/常量名称]
   注册表（来源：[gdd]）：[attribute] = [value]
   [other_gdd].md中的冲突：[attribute] = [不同值]
   → 需要解决：[更改哪个文档以及更改为什么]

---

### 陈旧注册条目（注册表落后于GDD）

⚠️ [条目名称]
   注册表显示：[value]（写于[日期]）
   源GDD现在显示：[new value]
   → 更新注册条目以匹配源GDD，然后检查referenced_by文档。

---

### 不可验证引用（无冲突，仅供参考）

ℹ️ [gdd].md提及[entity_name]但未陈述可比属性。
   未检测到冲突。无需操作。

---

### 干净条目（未发现问题）

✅ [N] 个注册条目在所有GDD中经过验证，无冲突。

---

裁决：PASS | CONFLICTS FOUND
```

**裁决：**
- **PASS** — 无冲突。注册表和GDD在所有检查值上一致。
- **CONFLICTS FOUND** — 检测到一个或多个冲突。列出解决步骤。

---

## 阶段6：注册表更正

如果发现陈旧注册条目，询问：
> "我可以更新 `design/registry/entities.yaml` 修复 [N] 个陈旧条目吗？"

对于每个陈旧条目：
- 更新 `value` / 属性字段
- 将 `revised:` 设为今天的日期
- 添加带旧值的YAML注释：`# 之前：[旧值]，[日期]之前`

如果在GDD中发现注册表中没有的新条目，询问：
> "发现 [N] 个在GDD中提及但尚未在注册表中的实体/物品。我可以将它们添加到 `design/registry/entities.yaml` 吗？"

只添加出现在多个GDD中的条目（真正的跨系统事实）。

**永远不要删除注册条目。** 如果一个条目从所有GDD中删除，设置 `status: deprecated`。

写入后：裁决：**COMPLETE** — 一致性检查完成。
如果冲突仍未解决：裁决：**BLOCKED** — [N] 个冲突需要手动解决，然后才能开始架构。

### 6b：追加到反思日志

如果发现任何🔴冲突条目（无论是否已解决），为每个冲突在 `docs/consistency-failures.md` 追加条目：

```markdown
### [YYYY-MM-DD] — /consistency-check — 🔴 冲突
**领域**：[涉及的系统领域]
**涉及的文档**：[源GDD] vs [冲突GDD]
**发生了什么**：[具体冲突 — 实体名称、属性、不同值]
**解决方案**：[如何修复，或"未解决 — 需要手动操作"]
**模式**：[概括性教训，例如"战斗GDD中定义的物品值在编写之前未在经济GDD中引用 — 始终先检查entities.yaml"]
```

只有当 `docs/consistency-failures.md` 存在时才追加。如果文件缺失，静默跳过此步骤 — 不要从此技能创建文件。

---

## 后续步骤

- **如果PASS**：运行 `/review-all-gdds` 进行整体设计理论审查，或者如果所有MVP GDD都完成，运行 `/create-architecture`。
- **如果CONFLICTS FOUND**：修复标记的GDD，然后重新运行 `/consistency-check` 确认解决。
- **如果STALE REGISTRY**：更新注册表（阶段6），然后重新运行以验证。
- 写入每个新GDD后运行 `/consistency-check` 以尽早发现问题，而不是在架构时。
