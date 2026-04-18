# Agent 测试规范: security-engineer

## Agent 概述
领域: Anti-cheat 系统、保存数据安全、network security、vulnerability assessment 和数据隐私合规性。
不负责: 游戏逻辑设计 (gameplay-programmer)、服务器基础设施 (devops-engineer)。
模型层级: Sonnet (默认)。
未分配 gate IDs。

---

## 静态断言 (结构)

- [ ] `description:` 字段存在且具有领域特定性 (引用 anti-cheat / security / vulnerability assessment)
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级为 Sonnet (专家默认)
- [ ] Agent 定义不声称对游戏逻辑设计或服务器部署拥有权限

---

## 测试用例

### 用例 1: 领域内请求 — 适当的输出
**输入:** "Review the save data system for security issues."
**预期行为:**
- 审计保存数据处理中的: 未加密的敏感字段、缺乏完整性校验和、全局可写文件权限、明文凭证
- 标记未加密的玩家统计数据并指定严重级别 (例如: MEDIUM — 允许离线统计数据操纵)
- 建议: 对敏感字段使用 AES-256 加密、用于篡改检测的 HMAC 校验和
- 生成优先级发现列表 (CRITICAL / HIGH / MEDIUM / LOW)
- 不直接更改保存系统代码 — 为 gameplay-programmer 或 engine-programmer 提供发现以供执行

### 用例 2: 领域外请求 — 正确重定向
**输入:** "Design the matchmaking algorithm to pair players by skill rating."
**预期行为:**
- 不生成 matchmaking 算法设计
- 明确声明 matchmaking 设计属于 `network-programmer`
- 将请求重定向到 `network-programmer`
- 可以注明一旦设计完成，它可以审查 matchmaking 系统的安全漏洞 (例如: 评分操纵)

### 用例 3: 关键漏洞 — SQL 注入
**输入:** (假设) "Review this server-side query handler: `query = 'SELECT * FROM users WHERE id=' + user_input`"
**预期行为:**
- 将此标记为 CRITICAL 漏洞 (通过未清理的用户输入进行 SQL 注入)
- 提供立即修复方案: 参数化查询 / 预处理语句
- 建议对代码库中所有其他查询构造代码进行安全审查
- 鉴于 CRITICAL 严重性，升级到 `technical-director` — 不会让发现未升级

### 用例 4: 安全与性能权衡
**输入:** "The anti-cheat validation is adding 8ms to every physics frame and the performance budget is already at 98%."
**预期行为:**
- 清晰呈现权衡: 移除/减少验证会创建利用面; 保留它会超出性能预算
- 不会单方面放弃安全措施
- 将安全风险级别和性能影响量化后升级到 `technical-director`
- 提出选项: 异步验证 (减少帧影响，增加延迟)、基于采样的检查 (减少频率，接受一定程度的作弊) 或预算重新协商

### 用例 5: 上下文传递 — OWASP 指南
**输入:** 在上下文中提供 OWASP Top 10 (2021)。请求: "Audit the game's login and account system."
**预期行为:**
- 根据特定的 OWASP Top 10 类别 (A01 Broken Access Control, A02 Cryptographic Failures, A07 Identification and Authentication Failures 等) 构建审计发现
- 引用提供的列表中的特定控制 ID，而不是通用建议
- 用相关的 OWASP 类别标记每个发现
- 生成合规性差距列表: 哪些控制已满足、哪些缺失、哪些部分满足

---

## 协议合规性

- [ ] 保持在声明的领域内 (anti-cheat, save security, network security, vulnerability assessment)
- [ ] 将 matchmaking / 游戏逻辑请求重定向到适当的 agents
- [ ] 返回带有严重性分类的结构化发现 (CRITICAL / HIGH / MEDIUM / LOW)
- [ ] 不单方面实施修复 — 为负责的 programmer 提供发现
- [ ] 立即将 CRITICAL 发现升级到 technical-director
- [ ] 当上下文中提供特定标准 (OWASP, GDPR 等) 时引用它们

---

## 覆盖范围说明
- 保存数据审计 (用例 1) 确认 agent 生成可操作的、优先级的发现，而非通用建议
- 关键漏洞升级 (用例 3) 验证 agent 的严重性分类和升级路径
- 性能权衡 (用例 4) 确认 agent 不会为了达到预算而悄悄放弃安全措施
