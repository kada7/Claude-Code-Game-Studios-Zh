# Skill 测试规范：/art-bible

## Skill 摘要

`/art-bible` 是一个引导式的、逐章节创作的 art bible 技能。它生成一份全面的视觉方向文档，涵盖：视觉风格概览、色彩调色板、字体排版、角色设计规则、环境风格和 UI 视觉语言。该技能遵循骨架优先模式：立即创建包含所有章节标题的文件，然后通过讨论填充每个章节，并在用户批准后将每个章节写入磁盘。

在 `full` 评审模式下，AD-ART-BIBLE 导演门（art director）在草稿完成后、任何章节写入之前运行。在 `lean` 和 `solo` 模式下，AD-ART-BIBLE 被跳过，仅需要用户批准。当所有章节都写入后，裁决为 COMPLETE。

---

## 静态断言（结构性）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键字：COMPLETE
- [ ] 每节包含 "May I write" 语言
- [ ] 记录了 AD-ART-BIBLE 导演门及其模式行为
- [ ] 具有下一步移交（例如 `/asset-spec` 或 `/design-system`）

---

## 导演门检查

| 门控 ID      | 触发条件              | 模式守卫            |
|--------------|--------------------------------|-----------------------|
| AD-ART-BIBLE | 草稿完成后        | full only (not lean/solo) |

---

## 测试用例

### 用例 1：正常路径 — Full 模式，art bible 已起草，AD-ART-BIBLE 批准

**测试夹具：**
- 不存在 `design/art-bible.md`
- `production/session-state/review-mode.txt` 包含 `full`
- `design/gdd/game-concept.md` 存在并描述了视觉基调

**输入：** `/art-bible`

**预期行为：**
1. 技能创建包含所有章节标题的骨架 `design/art-bible.md`
2. 技能与用户协作讨论并起草每个章节
3. 所有章节起草完成后，调用 AD-ART-BIBLE 门控（art director 评审）
4. AD-ART-BIBLE 返回 APPROVED
5. 技能询问 "May I write section [N] to `design/art-bible.md`?" 每节
6. 批准后写入所有章节；裁决为 COMPLETE

**断言：**
- [ ] 骨架文件首先创建（在任何章节内容写入之前）
- [ ] AD-ART-BIBLE 门控在 full 模式下草稿完成后调用
- [ ] 门控批准先于 "May I write" 章节询问
- [ ] 最终文件中存在所有章节
- [ ] 裁决为 COMPLETE

---

### 用例 2：AD-ART-BIBLE 返回 CONCERNS — 在写入前修订章节

**测试夹具：**
- Art bible 草稿已完成
- `production/session-state/review-mode.txt` 包含 `full`
- AD-ART-BIBLE 门控返回 CONCERNS："Color palette clashes with the dark
  atmospheric tone described in the game concept"

**输入：** `/art-bible`

**预期行为：**
1. AD-ART-BIBLE 门控返回 CONCERNS，并附带关于调色板的具体反馈
2. 技能向用户呈现反馈："Art director has concerns about the color palette"
3. 技能返回到 Color Palette 章节进行修订
4. 用户和技能修订调色板以与游戏概念基调对齐
5. AD-ART-BIBLE 不会重新调用（用户决定在修订后继续）
6. 在 "May I write" 批准后写入修订后的章节；裁决为 COMPLETE

**断言：**
- [ ] 在任何章节写入前向用户显示 CONCERNS
- [ ] 技能返回到受影响的章节进行修订（不是所有章节）
- [ ] 写入文件的是修订后的内容（不是原始内容）
- [ ] 修订和批准后裁决为 COMPLETE

---

### 用例 3：Lean 模式 — AD-ART-BIBLE 跳过，仅通过用户批准写入

**测试夹具：**
- 不存在 art bible
- `production/session-state/review-mode.txt` 包含 `lean`

**输入：** `/art-bible`

**预期行为：**
1. 技能读取评审模式 — 确定 `lean`
2. 技能与用户协作起草所有章节
3. AD-ART-BIBLE 门控被跳过：输出注明 "[AD-ART-BIBLE] skipped — lean mode"
4. 技能直接向用户请求每节的批准
5. 用户确认后写入章节；裁决为 COMPLETE

**断言：**
- [ ] AD-ART-BIBLE 门控在 lean 模式下未调用
- [ ] 跳过被明确注明："[AD-ART-BIBLE] skipped — lean mode"
- [ ] 每节仍需要用户批准（跳过门控 ≠ 跳过批准）
- [ ] 裁决为 COMPLETE

---

### 用例 4：现有 Art Bible — 改造模式

**测试夹具：**
- `design/art-bible.md` 已存在且所有章节已填充
- 用户希望更新 Character Design Rules 章节

**输入：** `/art-bible`

**预期行为：**
1. 技能读取现有 art bible 并检测到所有章节已填充
2. 技能提供改造选项："Art bible exists — which section would you like to update?"
3. 用户选择 Character Design Rules
4. 技能起草更新后的内容；在 full 模式下，AD-ART-BIBLE 在写入前为修订的章节调用
5. 技能询问 "May I write Character Design Rules to `design/art-bible.md`?"
6. 仅更新该章节；其他章节保留；裁决为 COMPLETE

**断言：**
- [ ] 检测到现有 art bible 并提供改造选项
- [ ] 仅更新选定的章节
- [ ] 在 full 模式下：AD-ART-BIBLE 门控即使对于单节改造也会运行
- [ ] 其他章节被保留
- [ ] 裁决为 COMPLETE

---

### 用例 5：Solo 模式 — AD-ART-BIBLE 跳过，在输出中注明

**测试夹具：**
- 不存在 art bible
- `production/session-state/review-mode.txt` 包含 `solo`

**输入：** `/art-bible`

**预期行为：**
1. 技能读取评审模式 — 确定 `solo`
2. Art bible 仅通过用户批准起草和写入
3. AD-ART-BIBLE 门控被跳过：输出注明 "[AD-ART-BIBLE] skipped — solo mode"
4. 不生成任何 director agent
5. 裁决为 COMPLETE

**断言：**
- [ ] AD-ART-BIBLE 门控在 solo 模式下未调用
- [ ] 跳过被明确注明带有 "solo mode" 标签
- [ ] 不生成任何 director agent
- [ ] 裁决为 COMPLETE

---

## 协议合规性

- [ ] 立即创建包含所有章节标题的骨架文件
- [ ] 一次讨论并起草一个章节
- [ ] AD-ART-BIBLE 门控在 full 模式下所有章节起草后运行
- [ ] AD-ART-BIBLE 在 lean 和 solo 模式下被跳过 —— 按名称注明
- [ ] 每节询问 "May I write section [N]"
- [ ] 所有章节写入后裁决为 COMPLETE

---

## 覆盖说明

- AD-ART-BIBLE 返回 REJECT（不仅仅是 CONCERNS）的情况未单独测试；技能会阻止写入并询问用户如何继续（修订或覆盖）。
- Typography 章节被列为必需的 art bible 章节，但其具体的内容要求未在此处进行断言测试。
- Art bible 输入 `/asset-spec` —— 此关系在移交中注明，但未作为该技能规范的一部分进行测试。
