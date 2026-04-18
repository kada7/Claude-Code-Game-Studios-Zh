# 技能测试规范：/architecture-review

## 技能摘要

`/architecture-review` 是一个 Opus-tier 技能，用于根据项目的 8 个必需架构部分验证技术架构文档，并检查其内部一致性、与现有 ADRs 无矛盾，以及正确针对固定的引擎版本。它会产生 APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED 的判定。

在 `full` 审查模式下，该技能并行启动两个导演关口代理：TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）。在 `lean` 或 `solo` 模式下，两个关口都会被跳过并标记。该技能是只读的 —— 不会写入任何文件。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需固定装置。

- [ ] 拥有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 拥有 ≥2 个阶段标题
- [ ] 包含判定关键词：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 不需要 "May I write" 语言（只读技能）
- [ ] 在末尾有下一步交接
- [ ] 记录关口行为：在 full 模式下 TD-ARCHITECTURE + LP-FEASIBILITY；在 lean/solo 模式下跳过

---

## 导演关口检查

在 `full` 模式下：TD-ARCHITECTURE（technical-director）和 LP-FEASIBILITY（lead-programmer）在技能读取架构文档后并行启动。

在 `lean` 模式下：两个关口都被跳过。输出备注：
"TD-ARCHITECTURE skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：两个关口都被跳过，并带有等效的备注。

---

## 测试用例

### 用例 1：成功路径 —— full 模式下的完整架构文档

**固定装置：**
- `docs/architecture/architecture.md` 存在且所有 8 个必需部分都已填充
- 所有部分都引用了来自 `docs/engine-reference/` 的正确引擎版本
- 与 `docs/architecture/` 中现有的已接受 ADRs 无矛盾
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取架构文档
2. 技能读取现有的 ADRs 进行交叉引用
3. 技能读取引擎版本引用
4. TD-ARCHITECTURE 和 LP-FEASIBILITY 关口代理并行启动
5. 两个关口都返回 APPROVED
6. 技能输出逐部分的完整性检查（8/8 个部分存在）
7. 判定：APPROVED

**断言：**
- [ ] 所有 8 个必需部分都经过检查并报告
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 并行启动（非顺序启动）
- [ ] 当所有部分都存在且无冲突时，判定为 APPROVED
- [ ] 技能不会写入任何文件
- [ ] 存在向 `/create-control-manifest` 或 `/create-epics` 的下一步交接

---

### 用例 2：失败路径 —— 缺少必需部分

**固定装置：**
- `docs/architecture/architecture.md` 存在但缺少至少 2 个必需部分
  （例如，无数据模型部分，无错误处理部分）
- `production/session-state/review-mode.txt` 包含 `full`

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取文档并识别缺失的部分
2. 部分完整性显示少于 8/8 个部分存在
3. 缺失的部分按名称列出，并带有具体的补救指导
4. 判定：MAJOR REVISION NEEDED（≥2 个缺失部分）

**断言：**
- [ ] 对于 ≥2 个缺失部分，判定为 MAJOR REVISION NEEDED（不是 APPROVED 或 NEEDS REVISION）
- [ ] 每个缺失的部分在输出中都有明确命名
- [ ] 补救指导是具体的（要添加什么，而不仅仅是"添加缺失部分"）
- [ ] 技能不会通过缺少必需部分的文档

---

### 用例 3：部分路径 —— 架构与现有 ADR 矛盾

**固定装置：**
- `docs/architecture/architecture.md` 存在且所有 8 个部分都已存在
- `docs/architecture/` 中的一个已接受 ADR 建立了一个约束，与架构文档相矛盾
  （例如，ADR-001 强制要求 ECS 模式；architecture.md 为同一系统描述了不同的模式）

**输入：** `/architecture-review docs/architecture/architecture.md`

**预期行为：**
1. 技能读取架构文档和所有现有 ADRs
2. 检测到架构文档与指定的 ADR 之间的冲突
3. 冲突条目命名：ADR 编号/标题、矛盾的部分和影响
4. 判定：NEEDS REVISION（存在冲突但结构在其他方面是合理的）

**断言：**
- [ ] 判定为 NEEDS REVISION（对于单一矛盾，不是 MAJOR REVISION NEEDED）
- [ ] 冲突条目中明确指定了 ADR 编号和标题
- [ ] 两个文档中矛盾的部分都被识别出来
- [ ] 技能不会自动解决矛盾

---

### 用例 4：边界情况 —— 文件未找到

**固定装置：**
- 提供的路径在项目中不存在

**输入：** `/architecture-review docs/architecture/nonexistent.md`

**预期行为：**
1. 技能尝试读取文件
2. 文件未找到
3. 技能输出一个明确的错误，指出缺失的文件
4. 技能建议检查 `docs/architecture/` 或运行 `/create-architecture`
5. 技能不会产生判定

**断言：**
- [ ] 当文件未找到时，技能输出明确的错误
- [ ] 不会产生判定（APPROVED / NEEDS REVISION / MAJOR REVISION NEEDED）
- [ ] 技能建议纠正措施
- [ ] 技能不会崩溃或产生部分报告

---

### 用例 5：导演关口 —— Full 模式启动两个关口；solo 模式下跳过两个

**固定装置（full 模式）：**
- `docs/architecture/architecture.md` 存在且所有 8 个部分都已存在
- `production/session-state/review-mode.txt` 包含 `full`

**Full 模式预期行为：**
1. TD-ARCHITECTURE 关口启动
2. LP-FEASIBILITY 关口与 TD-ARCHITECTURE 并行启动
3. 两个关口都在判定发布前完成

**断言（full 模式）：**
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 在输出中都显示为已完成的关口
- [ ] 两个关口并行启动（非顺序启动）
- [ ] 判定反映了关口的反馈

**固定装置（solo 模式）：**
- 相同的架构文档
- `production/session-state/review-mode.txt` 包含 `solo`

**Solo 模式预期行为：**
1. 技能读取架构文档
2. 关口不会被启动
3. 输出备注："TD-ARCHITECTURE skipped — solo mode" 和 "LP-FEASIBILITY skipped — solo mode"
4. 判定仅基于结构检查

**断言（solo 模式）：**
- [ ] TD-ARCHITECTURE 或 LP-FEASIBILITY 均不作为活动关口出现
- [ ] 两个跳过的关口都在输出中注明
- [ ] 判定仍然仅基于结构检查产生

---

## 协议合规性

- [ ] 不会写入任何文件（只读技能）
- [ ] 在发布判定前呈现部分完整性检查
- [ ] TD-ARCHITECTURE 和 LP-FEASIBILITY 在 full 模式下并行启动
- [ ] 跳过的关口在 lean/solo 输出中按名称和模式注明
- [ ] 判定是以下之一：APPROVED、NEEDS REVISION、MAJOR REVISION NEEDED
- [ ] 以适合判定的下一步交接结束

---

## 覆盖范围说明

- 8 个必需的架构部分是项目特定的；测试使用技能主体中定义的部分列表 —— 此处不再重新列举。
- 引擎版本兼容性检查（交叉引用 `docs/engine-reference/`）是用例 1 成功路径的一部分，但未进行独立的固定装置测试。
- RTM（需求可追溯性矩阵）模式是由 `/architecture-review` 技能自身的 `rtm` 参数模式处理的独立问题，此处未测试。
