# 技能测试规范：/localize

## 技能摘要

`/localize` 管理完整的本地化流水线：从源文件中提取所有面向玩家的字符串，管理 `assets/localization/` 中的翻译文件，并验证所有 locale 文件的完整性。对于新语言，它创建一个 locale 文件骨架，包含所有当前字符串作为键和空值。对于现有的 locale 文件，它生成一份差异，展示添加、删除和变更的键。

翻译文件在询问"May I write"后写入 `assets/localization/[locale-code].csv`（或引擎适当的格式）。不适用总监关卡。裁决：LOCALIZATION COMPLETE（所有 locale 完整）或 GAPS FOUND（至少一个 locale 缺少字符串键）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：LOCALIZATION COMPLETE、GAPS FOUND
- [ ] 包含 "May I write" 协作协议语言，在写入 locale 文件前
- [ ] 具有下一步交接（例如，将 locale 骨架发送给翻译人员）

---

## 总监关卡检查

无。`/localize` 是流水线工具。不适用总监关卡。Localization lead agent 可能单独审查，但不在此技能内调用。

---

## 测试用例

### 用例 1：新语言 —— 字符串提取和创建 Locale 骨架

**测试夹具：**
- `src/` 中的源代码包含面向玩家的字符串（UI 文本、教程消息）
- 现有 locale：`assets/localization/en.csv`
- 不存在法语 locale

**输入：** `/localize fr`

**预期行为：**
1. 技能从源文件中提取所有面向玩家的字符串
2. 技能在 `en.csv` 中找到相同的字符串作为参考
3. 技能生成 `fr.csv` 骨架，包含所有字符串键和空值
4. 技能询问"May I write to `assets/localization/fr.csv`?"
5. 文件在批准后写入；裁决为 GAPS FOUND（文件已创建但值为空）
6. 技能记录："fr.csv created — send to translator to fill values"

**断言：**
- [ ] `en.csv` 中的所有字符串键都存在于 `fr.csv` 中
- [ ] `fr.csv` 中的所有值均为空（非从英语复制）
- [ ] 在创建文件前询问 "May I write"
- [ ] 裁决为 GAPS FOUND（文件已创建但未翻译）

---

### 用例 2：现有 Locale 差异 —— 列出添加、删除和变更

**测试夹具：**
- `assets/localization/fr.csv` 存在，包含 20 个已翻译的字符串键
- 源代码已变更：添加了 3 个新字符串，删除了 1 个字符串，2 个字符串的英语源文本已变更

**输入：** `/localize fr`

**预期行为：**
1. 技能从源文件中提取当前字符串
2. 技能与现有的 `fr.csv` 进行差异对比
3. 技能生成差异报告：
   - 3 个新键（需要翻译 —— 在 fr.csv 中列为空）
   - 1 个已删除的键（标记为 obsolete —— 建议删除）
   - 2 个已变更的键（英语源已变更 —— 法语可能需要更新，已标记）
4. 技能询问 "May I update `assets/localization/fr.csv`?"
5. 文件更新，添加了新的空键，标记了 obsolete 键；裁决为 GAPS FOUND

**断言：**
- [ ] 新键在更新的文件中显示为空（非自动翻译）
- [ ] 已删除的键被标记为 obsolete（非静默删除）
- [ ] 已变更的源字符串被标记以供翻译人员审查
- [ ] 裁决为 GAPS FOUND（存在新的空键）

---

### 用例 3：某个 Locale 缺少字符串 —— GAPS FOUND 并列出缺失键

**测试夹具：**
- 3 个 locale 文件存在：`en.csv`、`fr.csv`、`de.csv`
- `de.csv` 缺少 4 个存在于 `en.csv` 和 `fr.csv` 中的键

**输入：** `/localize`

**预期行为：**
1. 技能读取所有 3 个 locale 文件并交叉引用键
2. `de.csv` 缺少 4 个键
3. 技能生成 GAPS FOUND 报告，按 locale 列出 4 个缺失的键：
   "de.csv missing: [key1], [key2], [key3], [key4]"
4. 技能提议将缺失的键作为空值添加到 `de.csv`
5. 批准后：文件已更新；裁决保持 GAPS FOUND（值仍然为空）

**断言：**
- [ ] 缺失的键被明确列出（非仅计数）
- [ ] 缺失的键归因于特定的 locale 文件
- [ ] 裁决为 GAPS FOUND（非 LOCALIZATION COMPLETE）
- [ ] 缺失的键作为空值添加（非从英语自动翻译）

---

### 用例 4：翻译文件存在语法错误 —— 带行引用的错误

**测试夹具：**
- `assets/localization/fr.csv` 在第 47 行有一个格式错误的行（缺少引号闭合）

**输入：** `/localize fr`

**预期行为：**
1. 技能读取 `fr.csv` 并在第 47 行遇到解析错误
2. 技能输出："Parse error in fr.csv at line 47: [error detail]"
3. 技能在错误修复前无法对该文件进行差异对比或验证
4. 技能不尝试覆盖或自动修复格式错误的文件
5. 技能建议手动修复文件并重新运行 `/localize`

**断言：**
- [ ] 错误消息包含行号（第 47 行）
- [ ] 错误详情描述了解析错误的性质
- [ ] 技能不覆盖或修改格式错误的文件
- [ ] 建议手动修复 + 重新运行作为补救措施

---

### 用例 5：总监关卡检查 —— 无关卡；本地化是流水线工具

**测试夹具：**
- 包含面向玩家字符串的源代码

**输入：** `/localize fr`

**预期行为：**
1. 技能提取字符串并管理 locale 文件
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 LOCALIZATION COMPLETE 或 GAPS FOUND —— 无关卡裁决

---

## 协议合规性

- [ ] 在操作 locale 文件前从源文件中提取字符串
- [ ] 创建新的 locale 文件时所有键均为空值（非自动翻译）
- [ ] 将现有的 locale 文件与当前的源字符串进行差异对比
- [ ] 按 locale 和键名标记缺失的键
- [ ] 在创建或更新任何 locale 文件前询问 "May I write"
- [ ] 裁决为 LOCALIZATION COMPLETE（所有 locale 完全翻译）或 GAPS FOUND

---

## 覆盖说明

- LOCALIZATION COMPLETE 仅在所有 locale 文件的所有键都具有非空值时才可实现；新语言骨架创建始终导致 GAPS FOUND。
- 引擎特定的 locale 格式（Godot `.translation`、Unity `.po` 文件）由技能主体处理；测试中 `.csv` 用作规范格式。
- 源字符串变更频率非常高的情况（新 UI 文本的持续集成）未测试；差异逻辑处理这种情况。
