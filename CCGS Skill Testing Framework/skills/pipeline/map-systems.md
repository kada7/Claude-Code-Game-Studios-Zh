# 技能测试规范：/map-systems

## 技能摘要

`/map-systems` 将游戏概念分解为系统索引。它读取已批准的游戏概念和支柱，枚举显式和隐式系统，映射系统间的依赖关系，分配优先级层级（MVP / 垂直切片 / Alpha / 完整愿景），并将系统组织成分层设计顺序（基础层 → 核心层 → 功能层 → 表现层）。输出在用户批准后写入 `design/systems-index.md`。

此技能在游戏概念批准后和每个系统 GDD 创建之前是必需的——它是流水线中的强制关卡。在 `full` 审查模式下，CD-SYSTEMS（创意总监）和 TD-SYSTEM-BOUNDARY（技术总监）在分解草稿完成后并行启动。在 `lean` 或 `solo` 模式下，两个关卡都被跳过。该技能写入 `design/systems-index.md`。

---

## 静态断言（结构性的）

由 `/skill-test static` 自动验证——无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED
- [ ] 包含 "May I write" 协作协议语言（针对 systems-index.md）
- [ ] 末尾有下一步交接（`/design-system`）
- [ ] 记录关卡行为：在完整模式下并行启动 CD-SYSTEMS + TD-SYSTEM-BOUNDARY

---

## 总监关卡检查

在 `full` 模式下：CD-SYSTEMS（创意总监）和 TD-SYSTEM-BOUNDARY（技术总监）在系统分解草稿完成后、写入 `design/systems-index.md` 之前并行启动。

在 `lean` 模式下：两个关卡都被跳过。输出注明：
"CD-SYSTEMS skipped — lean mode" 和 "TD-SYSTEM-BOUNDARY skipped — lean mode"。

在 `solo` 模式下：两个关卡都被跳过，并带有等效的说明。

---

## 测试用例

### 用例 1：正常路径——游戏概念存在，识别出 5-8 个系统

**测试夹具：**
- `design/gdd/game-concept.md` 存在，包含核心机制和 MVP 定义部分
- `design/gdd/game-pillars.md` 存在，定义了 ≥1 个支柱
- 尚不存在 `design/systems-index.md`
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/map-systems`

**预期行为：**
1. 技能读取 game-concept.md 和 game-pillars.md
2. 识别 5-8 个系统（显式 + 隐式）
3. 映射系统间的依赖关系并分配层级
4. CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 并行启动并返回 APPROVED
5. 询问 "May I write `design/systems-index.md`?"
6. 批准后写入 systems-index.md
7. 更新 `production/session-state/active.md`

**断言：**
- [ ] 识别出 5 到 8 个系统（不少于，没有解释的情况下不多于）
- [ ] CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 并行启动（非顺序）
- [ ] 两个关卡在 "May I write" 询问前完成
- [ ] 在写入前询问 "May I write `design/systems-index.md`?"
- [ ] 未经批准不写入 systems-index.md
- [ ] 写入后更新会话状态
- [ ] 裁决为 COMPLETE

---

### 用例 2：失败路径——未找到游戏概念

**测试夹具：**
- `design/gdd/game-concept.md` 不存在
- `design/gdd/` 目录可能为空或不存在

**输入：** `/map-systems`

**预期行为：**
1. 技能尝试读取 `design/gdd/game-concept.md`
2. 文件未找到
3. 技能输出："No game concept found. Run `/brainstorm` to create one, then return to `/map-systems`."
4. 技能退出，不创建 systems-index.md

**断言：**
- [ ] 技能输出明确的错误，指明缺失的文件路径
- [ ] 技能推荐 `/brainstorm` 作为下一步操作
- [ ] 不创建 systems-index.md
- [ ] 裁决为 BLOCKED

---

### 用例 3：总监关卡——CD-SYSTEMS 返回 CONCERNS（缺失核心系统）

**测试夹具：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 包含 `full`
- CD-SYSTEMS 关卡返回 CONCERNS："The [core-system] is implied by the concept but not identified"

**输入：** `/map-systems`

**预期行为：**
1. 系统被草拟（识别出 5-8 个初始系统）
2. CD-SYSTEMS 关卡返回 CONCERNS，指明缺失的核心系统
3. TD-SYSTEM-BOUNDARY 返回 APPROVED
4. 技能向用户展示 CD-SYSTEMS 的担忧
5. 询问用户：修订系统列表以添加缺失的系统，或按原样继续
6. 如果修订：在 "May I write" 询问前显示更新后的系统列表

**断言：**
- [ ] 在写入前向用户展示 CD-SYSTEMS 的担忧
- [ ] 当 CONCERNS 未解决时，技能不自动写入 systems-index.md
- [ ] 给用户提供修订或继续的选项
- [ ] 修订后的系统列表在最终 "May I write" 前重新显示

---

### 用例 4：边界情况——systems-index.md 已存在

**测试夹具：**
- `design/gdd/game-concept.md` 存在
- `design/systems-index.md` 已存在，包含 N 个系统

**输入：** `/map-systems`

**预期行为：**
1. 技能读取现有的 systems-index.md 并展示其当前状态
2. 技能询问："systems-index.md already exists with [N] systems. Update with new systems, or review and revise priorities?"
3. 用户选择一个操作
4. 技能不静默覆盖现有索引

**断言：**
- [ ] 技能在继续前检测并读取现有的 systems-index.md
- [ ] 向用户提供更新/审查选项——不自动覆盖
- [ ] 向用户展示现有系统数量
- [ ] 未经用户选择，技能不进行完整的重新分解

---

### 用例 5：总监关卡——Lean 模式和 solo 模式都跳过关卡，并注明

**测试夹具（lean 模式）：**
- 游戏概念存在
- `production/session-state/review-mode.txt` 包含 `lean`

**Lean 模式预期行为：**
1. 系统被分解和草拟
2. CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY 都被跳过
3. 输出注明："CD-SYSTEMS skipped — lean mode" 和 "TD-SYSTEM-BOUNDARY skipped — lean mode"
4. "May I write" 询问直接进行

**断言（lean 模式）：**
- [ ] 两个关卡跳过说明出现在输出中
- [ ] 技能无需关卡批准即进行到 "May I write"
- [ ] 用户批准后写入 systems-index.md

**测试夹具（solo 模式）：**
- 相同的游戏概念，`production/session-state/review-mode.txt` 包含 `solo`

**Solo 模式预期行为：**
1. 相同的分解工作流程
2. 两个关卡被跳过——输出中注明 "solo mode"
3. "May I write" 询问进行

**断言（solo 模式）：**
- [ ] 两个跳过说明都带有 "solo mode" 标签
- [ ] 对于此技能，行为在其他方面与 lean 模式相同

---

## 协议合规性

- [ ] 在任何分解之前读取 game-concept.md 和 game-pillars.md
- [ ] 在写入前询问 "May I write `design/systems-index.md`?"
- [ ] 未经用户批准不写入 systems-index.md
- [ ] 在完整模式下并行启动 CD-SYSTEMS 和 TD-SYSTEM-BOUNDARY
- [ ] 在 lean/solo 输出中按名称和模式注明跳过的关卡
- [ ] 以下一步交接结束：`/design-system [next-system]`

---

## 覆盖范围说明

- 循环依赖检测（系统 A 依赖于系统 B，而系统 B 又依赖于系统 A）是依赖映射阶段的一部分——此处不独立进行测试夹具测试。
- 优先级层级分配（MVP 启发式）作为用例 1 协作工作流程的一部分进行评估，而非独立进行。
- `next` 参数模式（将最高优先级的未设计系统交接给 `/design-system`）不在此处测试——它是索引创建后的便利功能。