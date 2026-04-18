# 技能测试规范：/code-review

## 技能摘要

`/code-review` 对 `src/` 中的源文件执行架构代码审查，
检查 `CLAUDE.md` 中的编码标准（公共 API 的文档注释、
依赖注入优于单例、数据驱动值、可测试性）。发现结果
是建议性的。不调用任何导演关卡。不进行任何代码编辑。判定结果：
APPROVED（批准）、CONCERNS（关注点）或 NEEDS CHANGES（需要更改）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：APPROVED、CONCERNS、NEEDS CHANGES
- [ ] 不要求包含 "May I write" 语言（只读；发现结果是建议性输出）
- [ ] 具有下一步交接（如何处理发现结果）

---

## 导演关卡检查

无。代码审查是只读建议性技能；不调用任何关卡。

---

## 测试用例

### Case 1: 理想路径 — 源文件遵循所有编码标准

**Fixture:**
- `src/gameplay/health_component.gd` 存在且包含：
  - 所有公共方法都有文档注释（`##` 表示法）
  - 不使用单例；依赖通过构造函数注入
  - 无硬编码值；所有常量都引用 `assets/data/`
  - 文件头中的ADR引用：`# ADR: docs/architecture/adr-004-health.md`
  - 引用的ADR状态为 `Status: Accepted`

**Input:** `/code-review src/gameplay/health_component.gd`

**Expected behavior:**
1. 技能读取源文件
2. 技能检查所有编码标准：文档注释、DI、数据驱动、ADR状态
3. 所有检查通过
4. 技能输出发现结果摘要，所有检查均为PASS
5. 判定结果为APPROVED

**Assertions:**
- [ ] 输出中列出了每个编码标准检查
- [ ] 符合标准时所有检查显示PASS
- [ ] 技能读取引用的ADR以确认其状态
- [ ] 判定结果为APPROVED
- [ ] 不对任何文件进行编辑

---

### Case 2: 需要更改 — 缺少文档注释和单例使用

**Fixture:**
- `src/ui/inventory_ui.gd` 包含：
  - 2个公共方法缺少文档注释
  - 使用 `GameManager.instance`（单例模式）
  - 满足所有其他标准

**Input:** `/code-review src/ui/inventory_ui.gd`

**Expected behavior:**
1. 技能读取源文件
2. 技能检测到：2个公共方法缺少文档注释
3. 技能检测到：在特定行使用单例（例如，第42行，第87行）
4. 发现结果列出确切的方法名称和行号
5. 判定结果为NEEDS CHANGES

**Assertions:**
- [ ] 缺少的文档注释随方法名称一并列出
- [ ] 单例使用会标记文件和行号
- [ ] 存在BLOCKING级别标准违规时，判定结果为NEEDS CHANGES
- [ ] 技能不编辑文件 — 发现结果供开发人员处理
- [ ] 输出建议用依赖注入替换单例

---

### Case 3: 架构风险 — ADR引用状态为Proposed，而非Accepted

**Fixture:**
- `src/core/save_system.gd` 包含头注释：`# ADR: docs/architecture/adr-010-save.md`
- `adr-010-save.md` 存在但状态为 `Status: Proposed`
- 代码本身遵循所有其他编码标准

**Input:** `/code-review src/core/save_system.gd`

**Expected behavior:**
1. 技能读取源文件
2. 技能读取引用的ADR — 发现 `Status: Proposed`
3. 技能将此标记为ARCHITECTURE RISK（代码正在实现未接受的ADR）
4. 其他编码标准检查通过
5. 判定结果为CONCERNS（风险标记是建议性的，非强制的NEEDS CHANGES）

**Assertions:**
- [ ] 技能读取引用的ADR文件以检查其状态
- [ ] 当ADR状态为Proposed时标记ARCHITECTURE RISK
- [ ] 对于ADR风险，判定结果为CONCERNS（而非NEEDS CHANGES）— 建议性严重程度
- [ ] 输出建议在代码投入生产前解决ADR

---

### Case 4: 边界情况 — 在指定路径未找到源文件

**Fixture:**
- 用户调用 `/code-review src/networking/`
- `src/networking/` 目录不存在

**Input:** `/code-review src/networking/`

**Expected behavior:**
1. 技能尝试读取 `src/networking/` 中的文件
2. 目录或文件未找到
3. 技能输出错误："No source files found at `src/networking/`"
4. 技能建议检查 `src/` 以寻找有效目录
5. 不发出判定结果（未审查任何内容）

**Assertions:**
- [ ] 路径不存在时技能不崩溃
- [ ] 输出在错误消息中注明尝试的路径
- [ ] 输出建议检查 `src/` 以寻找有效文件路径
- [ ] 没有可审查的内容时不发出判定结果

---

### Case 5: 关卡合规性 — 无需关卡；可单独咨询LP

**Fixture:**
- 源文件遵循大多数标准，但有1个CONCERNS级别的发现（一个魔数）
- `review-mode.txt` 包含 `full`

**Input:** `/code-review src/gameplay/loot_system.gd`

**Expected behavior:**
1. 技能读取并审查源文件
2. 不调用导演关卡（代码审查发现结果是建议性的）
3. 技能以CONCERNS判定结果呈现发现结果
4. 输出注明："Consider requesting a Lead Programmer review for architecture concerns"
5. 技能不自动调用任何代理

**Assertions:**
- [ ] 在任何审查模式下都不调用导演关卡
- [ ] 输出中建议（非强制）咨询LP
- [ ] 不进行代码编辑
- [ ] 对于建议性级别的发现，判定结果为CONCERNS

---

## 协议合规性

- [ ] 在审查前读取源文件和编码标准
- [ ] 在发现结果输出中列出每个编码标准检查
- [ ] 不编辑任何源文件（只读技能）
- [ ] 不调用导演关卡
- [ ] 判定结果为以下之一：APPROVED、CONCERNS、NEEDS CHANGES

---

## 覆盖范围说明

- 未明确测试目录中所有文件的批量审查；假定行为是逐文件应用相同的检查并汇总判定结果。
- 测试覆盖率检查（验证对应的测试文件是否存在）是一个延伸目标，不在此处测试；这主要是 `/test-evidence-review` 的领域。
