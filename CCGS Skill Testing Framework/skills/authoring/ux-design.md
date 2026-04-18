# Skill Test Spec: /ux-design

## Skill Summary

`/ux-design` 是一个引导式的、按部分进行的 UX 规范编写技能。它为指定的屏幕或 HUD 元素生成用户流程图（以文本描述）、交互状态定义、线框图描述和可访问性说明。该技能遵循骨架优先模式：它首先创建包含所有章节标题的文件，然后通过讨论草拟每个章节，并在用户批准后将每个章节写入磁盘。

该技能没有内联的 director gates — `/ux-review` 是独立的审查步骤。每个章节都需要询问"我可以将章节 [N] 写入 [文件路径] 吗？"。如果指定屏幕的 UX 规范已存在，该技能会提供更新单个章节的选项，而不是替换整个文件。当所有章节都写入后，判定为 COMPLETE。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需测试夹具。

- [ ] 具有必需的前置字段：`name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含判定关键词：COMPLETE
- [ ] 包含每个章节的"我可以写入"语言
- [ ] 具有下一步交接（例如，`/ux-review` 用于验证完成的规范）

---

## Director Gate Checks

无。`/ux-design` 没有内联的 director gates。`/ux-review` 是该技能完成后调用的独立审查技能。

---

## Test Cases

### Case 1: Happy Path — New HUD spec, all sections authored and written

**Fixture:**
- `design/ux/` 中没有现有的 HUD UX 规范
- 引擎和渲染偏好已配置

**Input:** `/ux-design hud`

**Expected behavior:**
1. 技能创建骨架文件 `design/ux/hud.md`，包含所有章节标题
2. 技能讨论并草拟每个章节：用户流程、交互状态（正常/悬停/焦点/禁用）、线框图描述、可访问性说明
3. 每个章节草拟完成且用户确认后，技能询问"我可以将章节 [N] 写入 `design/ux/hud.md` 吗？"
4. 每个章节在批准后按顺序写入
5. 所有章节写入后，判定为 COMPLETE
6. 技能建议运行 `/ux-review` 作为下一步

**Assertions:**
- [ ] 首先创建骨架文件（包含空的章节内容）
- [ ] 每个章节都询问"我可以写入章节 [N]"（不是在最后一次性询问）
- [ ] 所有必需章节都存在：用户流程、交互状态、线框图描述、可访问性说明
- [ ] 最后交接给 `/ux-review`
- [ ] 判定为 COMPLETE

---

### Case 2: Existing UX Spec — Retrofit: user picks section to update

**Fixture:**
- `design/ux/hud.md` 已存在且所有章节都已填充
- 用户只想更新可访问性说明章节

**Input:** `/ux-design hud`

**Expected behavior:**
1. 技能读取现有的 `design/ux/hud.md` 并检测到所有章节都已填充
2. 技能报告："HUD 的 UX 规范已存在 — 提供更新选项"
3. 技能列出所有章节并询问要更新哪个
4. 用户选择可访问性说明
5. 技能草拟更新的可访问性内容并询问"我可以将可访问性说明章节写入 `design/ux/hud.md` 吗？"
6. 仅更新该章节；其他章节保持不变；判定为 COMPLETE

**Assertions:**
- [ ] 检测到现有规范并提供更新选项
- [ ] 用户选择要更新的章节
- [ ] 仅更新选定的章节 — 其他章节未更改
- [ ] 为更新的章节询问"我可以写入"
- [ ] 判定为 COMPLETE

---

### Case 3: Dependency Gap — Spec references a system with no design doc

**Fixture:**
- 用户正在编写库存屏幕的 UX 规范
- `design/gdd/inventory.md` 不存在

**Input:** `/ux-design inventory-screen`

**Expected behavior:**
1. 技能开始编写库存屏幕的 UX 规范
2. 在用户流程章节中，技能尝试引用库存系统规则
3. 技能检测到："未找到库存系统的 GDD — UX 规范存在依赖缺口"
4. 依赖缺口在规范中被标记（内联注明："DEPENDENCY GAP: inventory GDD"）
5. 技能继续编写，为缺失的规则使用占位符说明
6. 判定为 COMPLETE，并附带关于依赖缺口的建议说明

**Assertions:**
- [ ] DEPENDENCY GAP 标签出现在规范中，用于缺失的系统文档
- [ ] 技能不会因缺失的 GDD 而阻塞 — 它继续使用占位符
- [ ] 依赖缺口也在技能输出中注明（不仅仅在文件中）
- [ ] 交接建议同时运行 `/ux-review` 和编写缺失的 GDD

---

### Case 4: No Argument Provided — Usage error

**Fixture:**
- 技能调用时未提供参数

**Input:** `/ux-design`

**Expected behavior:**
1. 技能检测到未提供屏幕名称或参数
2. 技能输出使用错误："需要屏幕名称。用法：`/ux-design [screen-name]`"
3. 技能提供示例：`/ux-design hud`, `/ux-design main-menu`, `/ux-design inventory`
4. 未创建文件；未询问"我可以写入"

**Assertions:**
- [ ] 明确说明使用错误
- [ ] 提供调用示例
- [ ] 未创建文件
- [ ] 技能不会尝试在没有参数的情况下继续

---

### Case 5: Director Gate Check — No gate; ux-review is the separate review skill

**Fixture:**
- 新屏幕规范，已提供参数

**Input:** `/ux-design settings-menu`

**Expected behavior:**
1. 技能编写设置菜单 UX 规范的所有章节
2. 未生成 director agents
3. 编写过程中输出中未出现 gate IDs

**Assertions:**
- [ ] 在 ux-design 过程中未调用 director gate
- [ ] 未出现 gate skip 消息
- [ ] 判定为 COMPLETE，无需任何 gate 检查

---

## Protocol Compliance

- [ ] 在讨论内容之前创建包含所有章节标题的骨架文件
- [ ] 一次讨论并草拟一个章节
- [ ] 每个章节批准后询问"我可以写入章节 [N]"
- [ ] 检测现有规范并提供更新路径
- [ ] 最后交接给 `/ux-review`
- [ ] 所有章节写入后判定为 COMPLETE

---

## Coverage Notes

- 交互状态枚举（正常/悬停/焦点/禁用/错误）是每个规范的核心要求；`/ux-review` 技能会检查其完整性。
- 线框图描述仅为文本（无图像）；图像引用可以在之后由设计师手动添加。
- 响应式布局问题（不同屏幕尺寸）被注明为可选内容，此处不进行断言测试。