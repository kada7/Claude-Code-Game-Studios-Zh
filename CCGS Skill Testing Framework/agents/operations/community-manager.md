# Agent 测试规范: community-manager

## Agent 摘要
- **领域**: 面向玩家的沟通 — 补丁说明文本（玩家友好型）、社交媒体帖子草稿、社区更新公告、危机沟通响应计划、玩家报告中的 Bug 分类和路由（非修复）
- **不负责**: 技术补丁内容（devops-engineer）、QA 验证和测试执行（qa-lead）、Bug 修复（programmers）、品牌策略方向（creative-director）
- **模型层级**: Sonnet
- **Gate IDs**: 无；将品牌声音冲突升级至 creative-director

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用玩家沟通、补丁说明、社区管理）
- [ ] `allowed-tools:` 列表与 Agent 角色匹配（对 production/releases/patch-notes/ 和沟通草稿具有读/写权限；无代码或构建工具）
- [ ] 模型层级为 Sonnet（运营专家的默认层级）
- [ ] Agent 定义不声称对技术内容、QA 策略或 Bug 修复拥有权限

---

## 测试用例

### 用例 1: 领域内请求 — 针对 Bug 修复的补丁说明
**输入**: "Write player-facing patch notes for this fix: 'JIRA-4821: Fixed NullReferenceException in InventoryManager.LoadSave() when save file was created on a previous version without the new equipment slot field.'"
**预期行为**:
- 生成玩家友好的补丁说明 — 无内部工单 ID（移除 JIRA-4821）、无类名（InventoryManager.LoadSave()）、无技术堆栈跟踪语言
- 使用清晰的玩家友好语言：例如，"修复了在加载上次更新前创建的存档文件时可能发生的崩溃问题。"
- 传达用户影响（游戏加载时崩溃）而不暴露内部实现细节
- 输出格式符合项目的补丁说明风格（项目符号或编号，取决于既定格式）

### 用例 2: 领域外请求 — 修复报告的 Bug
**输入**: "A player reported that their save file is corrupted. Can you fix the save system?"
**预期行为**:
- 不生成任何代码或尝试诊断存档系统实现
- 分类报告：将其视为影响玩家数据的潜在 Bug（高严重性）
- 路由报告："这需要由适当的程序员进行调查；我将此路由至 [gameplay-programmer 或 lead-programmer] 进行技术分类"
- 如果请求，可选地起草面向玩家的确认帖子（"我们已注意到有关存档损坏的报告，正在调查中"）

### 用例 3: 社区危机 — 对游戏更改的强烈反对
**输入**: "Players are angry about our latest patch. We nerfed a popular character's damage by 40% and the community is calling for a rollback. Forum posts, tweets, and Discord are all very negative."
**预期行为**:
- 生成危机沟通响应计划（不仅仅是单条推文）
- 计划包括：(1) 立即确认帖子 — 承认反馈而不防御；(2) 开发者响应时间表 — 承诺在特定时间范围内发布设计团队声明；(3) 开发者声明模板 — 解释削弱的原因而不忽视玩家关切；(4) 后续结构 — 如果计划回滚或调整，按时间表沟通
- 不代表设计团队承诺回滚 — 将此标记为 creative-director 的决策
- 语气富有同理心但不为有意的设计决策道歉

### 用例 4: 补丁说明中的品牌声音冲突
**输入**: "Here is our patch note draft: 'We have annihilated the egregious framerate catastrophe that plagued the loading screen.' Our brand voice guide specifies: clear, warm, slightly humorous — not dramatic or hyperbolic."
**预期行为**:
- 识别冲突："annihilated"、"egregious" 和 "catastrophe" 是戏剧性/夸张的 — 与指定的品牌声音不一致
- 不按原样批准草稿
- 生成修订版本：例如，"修复了导致加载屏幕运行缓慢的性能问题 — 现在应该感觉更流畅了。"
- 明确标记不一致性，而不是在不指出问题的情况下静默重写

### 用例 5: 上下文传递 — 使用品牌声音文档
**输入上下文**: Brand voice guide specifies: direct language, second-person ("you"), light humor is encouraged, avoid corporate jargon, game-specific slang from the in-world glossary is appropriate.
**输入**: "Write a social media post announcing a new hero character named Velk, a shadow assassin."
**预期行为**:
- 使用第二人称称呼（"Meet your next favorite assassin"）
- 如果自然合适，融入轻松幽默
- 避免企业语言（"We are pleased to announce" → "Meet Velk"）
- 如果上下文包含词汇表，使用游戏内语言（例如，如果游戏世界中刺客被称为 "Shadowwalkers"，则使用该术语）
- 输出符合指定的语气 — 不是通用的新闻稿公告

---

## 协议合规性

- [ ] 保持在声明的领域内（面向玩家的沟通、补丁说明文本、危机响应、Bug 路由）
- [ ] 从所有面向玩家的输出中移除内部 ID、类名和技术术语
- [ ] 将 Bug 修复请求重定向至适当的程序员，而不是尝试技术解决方案
- [ ] 未经 creative-director 授权，不承诺设计回滚
- [ ] 应用上下文中的品牌声音规范；标记违规而不是静默接受

---

## 覆盖范围说明
- 用例 1（补丁说明清理）是最常用的行为 — 在每个新补丁周期进行测试
- 用例 3（危机沟通）是品牌安全测试 — 验证 Agent 能缓解而非激化危机
- 用例 4 需要上下文中有品牌声音文档；没有它测试不完整
- 用例 5 是语气一致性的最重要的上下文感知测试
- 无自动化运行器；通过 `/skill-test` 手动审查