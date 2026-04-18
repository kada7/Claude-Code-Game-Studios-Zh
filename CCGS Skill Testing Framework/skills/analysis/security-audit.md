# Skill Test Spec: /security-audit

## Skill Summary

`/security-audit` 对游戏进行安全审计，检查包括存档数据完整性、网络通信、反作弊暴露和数据隐私在内的安全风险。它读取 `src/` 中的源文件以查找安全模式，并检查敏感数据是否正确处理。不调用任何 director gate。该技能不写入文件（仅生成发现报告）。裁决结果：SECURE、CONCERNS 或 VULNERABILITIES FOUND。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需测试夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：SECURE、CONCERNS、VULNERABILITIES FOUND
- [ ] 不需要 "May I write" 语言（只读；仅生成发现报告）
- [ ] 具有下一步交接（如何处理发现结果）

---

## Director Gate Checks

无。Security audit 是一个只读的咨询技能；不调用任何 gate。

---

## Test Cases

### Case 1: Happy Path — Save data encrypted, no hardcoded credentials

**Fixture:**
- `src/core/save_system.gd` 使用 `Crypto` 类在写入前加密存档数据
- 任何 `src/` 文件中没有硬编码的 API 密钥、密码或凭证
- 面向客户端的输出中没有暴露版本号或内部构建 ID

**Input:** `/security-audit`

**Expected behavior:**
1. 技能扫描 `src/` 以查找安全模式：加密使用情况、硬编码凭证、暴露的内部信息
2. 所有检查通过：存档数据已加密、未找到凭证、未暴露内部信息
3. 发现报告显示所有检查 PASS
4. 裁决结果为 SECURE

**Assertions:**
- [ ] 技能检查存档数据处理是否使用加密
- [ ] 技能扫描硬编码凭证（API 密钥、密码、令牌）
- [ ] 技能检查是否向玩家暴露版本/构建号
- [ ] 所有检查在发现报告中显示
- [ ] 当所有检查通过时，裁决结果为 SECURE

---

### Case 2: Vulnerabilities Found — Unencrypted save data and exposed version

**Fixture:**
- `src/core/save_system.gd` 将存档数据以纯 JSON 格式写入（无加密）
- `src/ui/debug_overlay.gd` 包含：`label.text = "Build: " + ProjectSettings.get("application/config/version")`
  （向玩家暴露内部构建版本）

**Input:** `/security-audit`

**Expected behavior:**
1. 技能扫描 `src/` — 在 `save_system.gd` 中发现未加密的存档写入
2. 技能在 `debug_overlay.gd` 中发现暴露的版本字符串
3. 两个发现都被标记为 VULNERABILITIES
4. 裁决结果为 VULNERABILITIES FOUND
5. 技能为每个漏洞提供修复建议

**Assertions:**
- [ ] 未加密的存档数据被标记为漏洞，并附带文件和大致行号
- [ ] 暴露的版本字符串被标记为漏洞
- [ ] 为每个漏洞提供修复建议
- [ ] 当检测到任何漏洞时，裁决结果为 VULNERABILITIES FOUND
- [ ] 没有文件被写入或修改

---

### Case 3: Online Features Without Authentication — CONCERNS

**Fixture:**
- `src/networking/lobby.gd` 存在，包含函数：`join_lobby()`、`send_chat()`
- 在 `send_chat()` 之前未找到身份验证检查 — 玩家无需验证即可调用它
- 游戏具有在线多人功能（从文件存在推断）

**Input:** `/security-audit`

**Expected behavior:**
1. 技能扫描 `src/networking/` — 检测到在线功能代码
2. 技能检查网络调用前的身份验证防护 — 在 `send_chat()` 上未找到
3. 标记："Online feature without authentication check — CONCERNS"
4. 裁决结果为 CONCERNS（不是 VULNERABILITIES FOUND，因为这是缺失的控制措施，而非可利用漏洞）

**Assertions:**
- [ ] 技能通过扫描网络源文件检测在线功能
- [ ] 网络操作前缺失的身份验证检查被标记
- [ ] 对于缺失的身份验证防护，裁决结果为 CONCERNS（咨询级别严重性）
- [ ] 输出建议在网络调用前添加身份验证

---

### Case 4: Edge Case — No Source Files to Analyze

**Fixture:**
- `src/` 目录不存在或完全为空

**Input:** `/security-audit`

**Expected behavior:**
1. 技能尝试扫描 `src/` — 未找到文件
2. 技能输出错误："No source files found in `src/` — nothing to audit"
3. 未生成发现报告
4. 未发出裁决结果

**Assertions:**
- [ ] 当 `src/` 为空或不存在时，技能不会崩溃
- [ ] 输出明确说明未找到源文件
- [ ] 未发出裁决结果（没有可评估的内容）
- [ ] 技能建议验证 `src/` 目录路径

---

### Case 5: Gate Compliance — No gate; security-engineer invoked separately

**Fixture:**
- 源文件存在；检测到 1 个 CONCERNS 级别的发现（发布版本中启用了调试日志）
- `review-mode.txt` 包含 `full`

**Input:** `/security-audit`

**Expected behavior:**
1. 技能扫描源文件；发现发布路径中启用了调试日志
2. 无论审查模式如何，都不调用 director gate
3. 裁决结果为 CONCERNS
4. 输出备注："For formal security review, consider engaging a security-engineer agent"
5. 发现结果以只读报告形式呈现；未写入任何文件

**Assertions:**
- [ ] 在任何审查模式下都不调用 director gate
- [ ] 建议（非强制）咨询 security-engineer
- [ ] 未写入任何文件
- [ ] 对于咨询级别的安全发现，裁决结果为 CONCERNS

---

## Protocol Compliance

- [ ] 在审计前读取 `src/` 中的源文件
- [ ] 检查存档数据加密、硬编码凭证、暴露的内部信息、身份验证防护
- [ ] 为每个发现提供修复建议
- [ ] 不写入任何文件（只读技能）
- [ ] 不调用任何 director gate
- [ ] 裁决结果为以下之一：SECURE、CONCERNS、VULNERABILITIES FOUND

---

## Coverage Notes

- 反作弊分析（客户端值验证、服务器权威性）在此未明确测试；它遵循 CONCERNS 或 VULNERABILITIES 模式，取决于严重性。
- 数据隐私合规性（GDPR、COPPA）超出本规范的范畴；这些需要超出代码扫描的法律审查。