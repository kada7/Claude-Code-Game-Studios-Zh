# 技能测试规范：/asset-spec

## 技能摘要

`/asset-spec` 根据设计需求生成每项资产的视觉规范文档。它读取相关的 GDD、美术圣经（art bible）和设计系统，生成一份结构化的资产规范表，定义：尺寸、动画状态（如适用）、调色板参考、风格注释、技术约束（格式、文件大小预算）和交付清单。

规范表在询问"May I write"后写入 `assets/specs/[asset-name]-spec.md`。如果规范已存在，技能会提议更新。当单次调用请求多个资产时，每个资产都会单独询问"May I write"。不适用总监关卡。当所有请求的规范都已写入时，裁决为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言（按资产）
- [ ] 具有下一步交接（例如，分配给美术师，或稍后 `/asset-audit`）

---

## 总监关卡检查

无。`/asset-spec` 是设计文档工具。技术美术师可能单独审查规范，但这不是该技能内的关卡。

---

## 测试用例

### 用例 1：理想路径 —— 敌人精灵规范，具有完整的 GDD 和美术圣经

**测试夹具：**
- `design/gdd/enemies.md` 存在并定义了敌人变体
- `design/art-bible.md` 存在并包含调色板和风格注释
- "goblin-enemy" 尚无现有资产规范

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能读取 enemies GDD 和美术圣经
2. 技能生成 goblin 敌人精灵的规范：
   - 尺寸：从引擎默认值或 GDD 显式推断
   - 动画状态：idle、walk、attack、hurt、death
   - 调色板参考：链接到美术圣经调色板部分
   - 风格注释：来自美术圣经角色设计规则
   - 技术约束：格式（PNG）、大小预算
   - 交付清单
3. 技能询问"May I write to `assets/specs/goblin-enemy-spec.md`?"
4. 文件在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 所有 6 个规范组件均存在（尺寸、动画、调色板、风格、技术、清单）
- [ ] 调色板参考链接到美术圣经（未重复）
- [ ] 动画状态取自 GDD（未发明）
- [ ] "May I write" 询问使用了正确的路径
- [ ] 裁决为 COMPLETE

---

### 用例 2：未找到美术圣经 —— 规范使用占位符风格注释，标记依赖差距

**测试夹具：**
- `design/gdd/player.md` 存在
- `design/art-bible.md` 不存在

**输入：** `/asset-spec player-sprite`

**预期行为：**
1. 技能读取 player GDD 但找不到美术圣经
2. 技能生成带有占位符风格注释的规范："DEPENDENCY GAP: art bible not found — style notes are placeholders"
3. 调色板部分使用："TBD — see art bible when created"
4. 技能询问"May I write to `assets/specs/player-sprite-spec.md`?"
5. 文件使用占位符和依赖标记写入；裁决为 COMPLETE with advisory

**断言：**
- [ ] 为缺失的美术圣经标记了 DEPENDENCY GAP
- [ ] 规范仍然生成（未被阻塞）
- [ ] 风格注释包含占位符标记，而非发明的风格
- [ ] 裁决为 COMPLETE with advisory note

---

### 用例 3：资产规范已存在 —— 提议更新

**测试夹具：**
- `assets/specs/goblin-enemy-spec.md` 已存在
- 自规范编写以来 GDD 已更新（添加了新的攻击动画）

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能检测到现有规范文件
2. 技能报告："Asset spec already exists for goblin-enemy — checking for updates"
3. 技能将 GDD 与现有规范进行差异对比并识别：GDD 中添加了新的 "charge-attack" 动画状态，但规范中未包含
4. 技能展示差异："1 new animation state found — offering to update spec"
5. 技能询问"May I update `assets/specs/goblin-enemy-spec.md`?"（非 overwrite）
6. 规范已更新；裁决为 COMPLETE

**断言：**
- [ ] 检测到现有规范并提供 "update" 路径
- [ ] 展示 GDD 与现有规范之间的差异
- [ ] 使用 "May I update" 语言（非 "May I write"）
- [ ] 保留现有规范内容；仅应用差异
- [ ] 裁决为 COMPLETE

---

### 用例 4：请求多个资产 —— 每个资产单独询问 May-I-Write

**测试夹具：**
- GDD 和美术圣经存在
- 用户请求 3 个资产的规范：goblin-enemy、orc-enemy、treasure-chest

**输入：** `/asset-spec goblin-enemy orc-enemy treasure-chest`

**预期行为：**
1. 技能按顺序生成所有 3 个规范
2. 对于每个资产，技能展示草稿并单独询问"May I write to `assets/specs/[name]-spec.md`?"
3. 用户可以批准全部 3 个或跳过单个资产
4. 所有批准的规范均已写入；裁决为 COMPLETE

**断言：**
- [ ] "May I write" 询问 3 次（每个资产一次），非一次性询问全部
- [ ] 用户可以拒绝一个资产而不阻塞其他资产
- [ ] 所有 3 个规范文件均为已批准的资产写入
- [ ] 当所有批准的规范都已写入时，裁决为 COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；asset-spec 是设计工具

**测试夹具：**
- GDD 和美术圣经存在

**输入：** `/asset-spec goblin-enemy`

**预期行为：**
1. 技能生成并写入资产规范
2. 不生成总监代理
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现关卡跳过消息
- [ ] 裁决为 COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 在生成规范前读取 GDD、美术圣经和设计系统
- [ ] 包含所有 6 个规范组件（尺寸、动画、调色板、风格、技术、清单）
- [ ] 使用 DEPENDENCY GAP 注释标记缺失的依赖项（美术圣经、GDD）
- [ ] 按资产询问 "May I write"（或 "May I update"）
- [ ] 使用单独的写入确认处理多个资产
- [ ] 当所有批准的规范都已写入时，裁决为 COMPLETE

---

## 覆盖说明

- 音频资产规范（音效、音乐）遵循相同的结构，但字段不同（时长、采样率、循环），未单独测试。
- UI 资产规范（图标、按钮状态）遵循相同的流程，交互状态需求与 UX 规范对齐。
- GDD 也缺失的情况（GDD 和美术圣经均不存在）未单独测试；规范将生成并标记两个依赖差距。
