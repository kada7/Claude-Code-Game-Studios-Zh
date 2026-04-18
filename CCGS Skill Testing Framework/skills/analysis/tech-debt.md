# Skill Test Spec: /tech-debt

## Skill Summary

`/tech-debt` 跟踪、分类和优先处理代码库中的 technical debt。它读取 `docs/tech-debt-register.md` 以获取现有的债务登记，并扫描 `src/` 中的源文件以查找内联的 `TODO` 和 `FIXME` 注释。它合并并按严重程度排序项目。不调用任何 director gates。该技能在更新前会询问“我可以写入 `docs/tech-debt-register.md` 吗？”。裁决结果：REGISTER UPDATED 或 NO NEW DEBT FOUND。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：REGISTER UPDATED, NO NEW DEBT FOUND
- [ ] 包含“我可以写入”语言（技能写入债务登记）
- [ ] 具有下一步交接（登记更新后要做什么）

---

## Director Gate Checks

无。Technical debt 跟踪是内部代码库分析技能；不调用任何 gates。

---

## Test Cases

### Case 1: Happy Path — 内联 TODOs 加上现有登记项目合并

**Fixture:**
- `docs/tech-debt-register.md` 存在，包含 2 个项目（LOW 和 MEDIUM 严重程度）
- `src/gameplay/combat.gd` 有 2 个 `# TODO` 注释和 1 个 `# FIXME` 注释
- `src/ui/hud.gd` 有 0 个内联债务注释

**Input:** `/tech-debt`

**Expected behavior:**
1. 技能读取 `docs/tech-debt-register.md` — 找到 2 个现有项目
2. 技能扫描 `src/` — 找到 3 个内联注释（2 个 TODOs，1 个 FIXME）
3. 技能检查内联注释是否已存在于登记中（去重）
4. 技能呈现按严重程度排序的组合列表（默认 FIXME 在 TODO 之前）
5. 技能询问“我可以写入 `docs/tech-debt-register.md` 吗？”
6. 用户批准；登记更新；裁决 REGISTER UPDATED

**Assertions:**
- [ ] 通过递归扫描 `src/` 找到内联注释
- [ ] 现有登记项目不被重复
- [ ] 组合列表按严重程度排序
- [ ] “我可以写入”提示出现在任何写入之前
- [ ] 裁决是 REGISTER UPDATED

---

### Case 2: 登记不存在 — 提供创建选项

**Fixture:**
- `docs/tech-debt-register.md` 不存在
- `src/` 包含 4 个内联 TODO/FIXME 注释

**Input:** `/tech-debt`

**Expected behavior:**
1. 技能尝试读取 `docs/tech-debt-register.md` — 未找到
2. 技能通知用户：“未找到 tech-debt-register.md”
3. 技能提供创建登记并包含找到的内联项目
4. 技能询问“我可以写入 `docs/tech-debt-register.md` 吗？”（创建）
5. 用户批准；登记创建并包含 4 个项目；裁决 REGISTER UPDATED

**Assertions:**
- [ ] 当登记文件不存在时，技能不会崩溃
- [ ] 向用户提供登记创建选项（不是静默跳过）
- [ ] “我可以写入”提示反映文件创建（不是更新）
- [ ] 创建后裁决是 REGISTER UPDATED

---

### Case 3: 检测到已解决的项目 — 在登记中标记为已解决

**Fixture:**
- `docs/tech-debt-register.md` 有 3 个项目；其中一个引用 `src/gameplay/legacy_input.gd`
- `src/gameplay/legacy_input.gd` 已被删除（重构移除）
- 引用的 TODO 注释在源代码中不再存在

**Input:** `/tech-debt`

**Expected behavior:**
1. 技能读取登记 — 找到 3 个项目
2. 技能扫描 `src/` — 未找到项目 2 引用的源代码位置
3. 技能将项目 2 标记为 RESOLVED（源代码已不存在）
4. 技能向用户呈现已解决的项目以进行确认
5. 批准后，登记更新，项目 2 标记为 `Status: Resolved`

**Assertions:**
- [ ] 技能检查每个登记项目的源代码引用是否仍然存在
- [ ] 缺失的源代码位置导致项目被标记为 RESOLVED
- [ ] 在写入已解决项目之前，用户进行确认
- [ ] RESOLVED 项目保留在登记中（不删除）以供审计历史

---

### Case 4: Edge Case — CRITICAL 债务项目突出显示

**Fixture:**
- `src/core/network_sync.gd` 有一个注释：`# FIXME(CRITICAL): race condition in sync buffer — can corrupt save data`
- `docs/tech-debt-register.md` 存在，包含 5 个较低严重程度的项目

**Input:** `/tech-debt`

**Expected behavior:**
1. 技能扫描源代码并找到 CRITICAL 标记的 FIXME
2. 技能在输出顶部呈现 CRITICAL 项目 — 在完整表格之前
3. 技能要求用户在继续之前确认关键项目
4. 确认后，技能呈现完整的债务表格并询问是否写入
5. 登记更新，CRITICAL 项目在顶部；裁决 REGISTER UPDATED

**Assertions:**
- [ ] CRITICAL 项目出现在输出顶部，而不是埋在表格中
- [ ] 技能在询问写入之前突出显示 CRITICAL 项目
- [ ] 要求用户确认 CRITICAL 项目
- [ ] CRITICAL 严重程度在写入的登记条目中保留

---

### Case 5: Gate Compliance — 无 gate；仅经批准后更新登记

**Fixture:**
- 内联扫描找到 2 个新的 TODOs；登记有 3 个现有项目
- `review-mode.txt` 包含 `full`

**Input:** `/tech-debt`

**Expected behavior:**
1. 技能扫描源代码并读取登记；编译组合的债务列表
2. 无论 review mode 如何，都不调用 director gate
3. 技能向用户呈现排序后的债务表格
4. 技能询问“我可以写入 `docs/tech-debt-register.md` 吗？”
5. 用户批准；登记更新；裁决 REGISTER UPDATED

**Assertions:**
- [ ] 在任何 review mode 下都不调用 director gate
- [ ] 在任何写入提示之前呈现债务表格
- [ ] “我可以写入”提示出现在文件更新之前
- [ ] 仅在获得明确用户批准后才进行写入

---

## Protocol Compliance

- [ ] 在编译之前读取 `docs/tech-debt-register.md` 并扫描 `src/`
- [ ] 针对现有登记项目对内联注释进行去重
- [ ] 按严重程度排序组合列表
- [ ] 在更新登记之前总是询问“我可以写入”
- [ ] 不调用任何 director gates
- [ ] 裁决是 REGISTER UPDATED 或 NO NEW DEBT FOUND

---

## Coverage Notes

- 未测试 `src/` 为空或不存在的场景；行为遵循内联扫描的 NO NEW DEBT FOUND 路径，但登记项目仍将被读取和呈现。
- 没有严重程度标签的 TODO 注释默认被视为 LOW 严重程度；此分类细节是实施关注点，不在此测试。