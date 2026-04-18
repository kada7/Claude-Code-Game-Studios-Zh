# 技能测试规范：/test-evidence-review

## 技能摘要

`/test-evidence-review` 对 `tests/` 目录中的测试文件执行质量审查，
检查测试命名约定、确定性、隔离性以及是否存在硬编码的魔法数字 —— 所有这些都基于项目在 `coding-standards.md` 中定义的测试标准。发现的问题可能会标记给 qa-lead 审查。不调用任何 director gate。该技能未经用户批准不会写入。裁决结果：PASS、WARNINGS 或 FAIL。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：PASS、WARNINGS、FAIL
- [ ] 不需要 "May I write" 语言（只读；写入是可选的标记报告）
- [ ] 具有下一步交接（审查发现后要做什么）

---

## Director Gate 检查

无。Test evidence review 是一个咨询性质量技能；QL-TEST-COVERAGE gate 是单独的技能调用，此处不触发。

---

## 测试用例

### 用例 1：正常路径 —— 测试遵循所有标准

**测试夹具：**
- `tests/unit/combat/health_system_take_damage_test.gd` 存在，包含：
  - 命名：`test_health_system_take_damage_reduces_health()`（遵循 `test_[system]_[scenario]_[expected]`）
  - 存在 Arrange/Act/Assert 结构
  - 没有 `sleep()`、带时间值的 `await` 或随机种子
  - 没有调用外部 API 或文件 I/O
  - 没有内联魔法数字（使用 `tests/unit/combat/fixtures/` 中的常量）

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能从 `coding-standards.md` 读取测试标准
2. 技能读取测试文件；检查所有 5 个标准
3. 所有检查通过：命名、结构、确定性、隔离性、无硬编码数据
4. 裁决结果为 PASS

**断言：**
- [ ] 检查并报告了 5 个测试标准中的每一个
- [ ] 当标准满足时，所有检查显示 PASS
- [ ] 裁决结果为 PASS
- [ ] 没有写入任何文件

---

### 用例 2：失败 —— 检测到时间依赖

**测试夹具：**
- `tests/unit/ui/hud_update_test.gd` 包含：
  ```gdscript
  await get_tree().create_timer(1.0).timeout
  assert_eq(label.text, "Ready")
  ```
- 使用 1 秒的实时等待，而不是基于模拟或信号的断言

**输入：** `/test-evidence-review tests/unit/ui/hud_update_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测到实时等待（`create_timer(1.0)`）—— 非确定性时间依赖
3. 技能将此标记为 FAIL 级别的发现
4. 裁决结果为 FAIL
5. 技能建议用基于信号的断言或模拟替换计时器

**断言：**
- [ ] 实时等待使用被检测为非确定性时间依赖
- [ ] 发现被分类为 FAIL 严重性（阻塞性 —— 违反确定性标准）
- [ ] 裁决结果为 FAIL
- [ ] 修复建议引用了基于信号或基于模拟的方法
- [ ] 技能不编辑测试文件

---

### 用例 3：失败 —— 测试直接调用外部 API

**测试夹具：**
- `tests/unit/networking/auth_test.gd` 包含：
  ```gdscript
  var result = HTTPRequest.new().request("https://api.example.com/auth")
  ```
- 没有模拟的直接 HTTP 调用外部 API

**输入：** `/test-evidence-review tests/unit/networking/auth_test.gd`

**预期行为：**
1. 技能读取测试文件
2. 技能检测到直接外部 API 调用（HTTPRequest 到实时 URL）
3. 技能将此标记为 FAIL 级别的发现 —— 违反隔离标准
4. 裁决结果为 FAIL
5. 技能建议注入模拟 HTTP 客户端

**断言：**
- [ ] 直接外部 API 调用被检测并标记
- [ ] 发现被分类为 FAIL 严重性（违反隔离标准）
- [ ] 裁决结果为 FAIL
- [ ] 修复建议引用了使用模拟 HTTP 客户端的依赖注入
- [ ] 技能不修改测试文件

---

### 用例 4：边缘情况 —— 未找到测试文件

**测试夹具：**
- 用户调用 `/test-evidence-review tests/unit/audio/`
- `tests/unit/audio/` 目录不存在

**输入：** `/test-evidence-review tests/unit/audio/`

**预期行为：**
1. 技能尝试读取 `tests/unit/audio/` 中的文件 —— 未找到
2. 技能输出："在 `tests/unit/audio/` 未找到测试文件 —— 运行 `/test-setup` 以搭建测试目录"
3. 不发出裁决结果

**断言：**
- [ ] 当路径不存在时，技能不会崩溃
- [ ] 输出在消息中命名了尝试的路径
- [ ] 输出建议使用 `/test-setup` 进行搭建
- [ ] 当没有内容可审查时，不发出裁决结果

---

### 用例 5：Gate 合规性 —— 无 gate；QL-TEST-COVERAGE 是单独的技能

**测试夹具：**
- 测试文件有 1 个 WARNINGS 级别的发现（非边界测试中的魔法数字）
- `review-mode.txt` 包含 `full`

**输入：** `/test-evidence-review tests/unit/combat/`

**预期行为：**
1. 技能审查测试；发现 1 个 WARNINGS 级别的发现
2. 不调用任何 director gate（QL-TEST-COVERAGE 单独调用，不在此处）
3. 裁决结果为 WARNINGS
4. 输出说明："对于完整的测试覆盖率 gate，运行调用 QL-TEST-COVERAGE 的 `/gate-check`"
5. 技能提供可选的报告写入；如果用户选择加入，则询问 "May I write"

**断言：**
- [ ] 在任何审查模式下都不调用 director gate
- [ ] 输出区分此技能与 QL-TEST-COVERAGE gate 调用
- [ ] 可选报告在写入前需要 "May I write"
- [ ] 对于咨询级别的测试质量问题，裁决结果为 WARNINGS

---

## 协议合规性

- [ ] 在审查测试文件之前读取 `coding-standards.md` 测试标准
- [ ] 检查命名、Arrange/Act/Assert 结构、确定性、隔离性、无硬编码数据
- [ ] 不编辑任何测试文件（只读技能）
- [ ] 不调用任何 director gate
- [ ] 裁决结果为以下之一：PASS、WARNINGS、FAIL

---

## 覆盖率说明

- 未明确测试 `tests/` 中所有测试文件的批量审查；假定行为是逐文件应用相同的检查并聚合裁决结果。
- QL-TEST-COVERAGE director gate（检查测试覆盖率百分比）是一个单独的关注点，此技能有意不调用它。