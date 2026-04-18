---
name: security-audit
description: "审计游戏的安全漏洞：存档篡改、作弊向量、网络漏洞、数据暴露和输入验证缺口。生成带修复指导的优先安全报告。在任何公开发布或多人游戏上线前运行。"
argument-hint: "[full | network | save | input | quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task
agent: security-engineer
---

# 安全审计

对于任何发布的游戏，安全都不是可选项。即使是单机游戏也有
存档篡改向量。多人游戏有作弊面、数据暴露
风险和拒绝服务潜力。此 Skill 系统地审计代码库中最常见的游戏安全故障，并生成优先修复计划。

**运行此 Skill：**
- 在任何公开发布之前（Polish → Release gate 必需）
- 在启用任何在线/多人功能之前
- 在实现任何从磁盘或网络读取的系统后
- 当报告安全相关 Bug 时

**输出：** `production/security/security-audit-[date].md`

---

## 阶段 1: 解析参数和范围

**模式：**
- `full` —— 所有类别（发布前推荐）
- `network` —— 仅网络/多人游戏
- `save` —— 仅存档文件和序列化
- `input` —— 仅输入验证和注入
- `quick` —— 仅高严重性检查（最快，用于迭代使用）
- 无参数 —— 运行 `full`

读取 `.claude/docs/technical-preferences.md` 以确定：
- 引擎和语言（影响要搜索的模式）
- 目标平台（影响哪些攻击面适用）
- 多人游戏/网络是否在范围内

---

## 阶段 2: 生成安全工程师

通过 Task 生成 `security-engineer`。传递：
- 审计范围/模式
- 技术偏好中的引擎和语言
- 所有源目录的清单：`src/`、`assets/data/`、任何配置文件

security-engineer 跨 6 个类别运行审计（见阶段 3）。收集他们的完整发现后再继续。

---

## 阶段 3: 审计类别

security-engineer 评估以下每个。跳过不适用于项目范围的类别。

### 类别 1: 存档文件和序列化安全
- 存档文件在加载前是否经过验证？（无不加鉴别的反序列化）
- 存档文件路径是否从用户输入构造？（路径遍历风险）
- 存档文件是否经过校验和或签名？（篡改检测）
- 游戏是否信任存档文件中的数值而不进行边界检查？
- 存档加载附近是否有任何 eval() 或动态代码执行调用？

Grep 模式：`File.open`、`load`、`deserialize`、`JSON.parse`、`from_json`、`read_file` —— 检查每个的验证。

### 类别 2: 网络和多人游戏安全（如果仅单机则跳过）
- 游戏状态在服务器上是权威的，还是客户端决定结果？
- 传入的网络数据包是否经过大小、类型和值范围验证？
- 玩家位置和状态更改是否在服务器端验证？
- 任何网络调用是否有速率限制？
- 认证令牌是否正确处理（绝不清文本发送）？
- 游戏是否在发布版本中暴露任何调试端点？

Grep：`recv`、`receive`、`PacketPeer`、`socket`、`NetworkedMultiplayerPeer`、`rpc`、`rpc_id` —— 检查每个调用点的验证。

### 类别 3: 输入验证
- 任何玩家提供的字符串是否用于文件路径？（路径遍历）
- 任何玩家提供的字符串是否未经清理就记录？（日志注入）
- 数字输入（例如物品数量、角色属性）在使用前是否经过边界检查？
- 成就/统计数据在写入任何后端之前是否经过检查？

Grep：`get_input`、`Input.get_`、`input_map`、面向用户的文本字段 —— 检查验证。

### 类别 4: 数据暴露
- 任何 API 密钥、凭据或机密是否硬编码在 `src/` 或 `assets/` 中？
- 调试符号或详细错误消息是否包含在发布版本中？
- 游戏是否将敏感玩家数据记录到磁盘或控制台？
- 任何内部文件路径或系统信息是否暴露给玩家？

Grep：`api_key`、`secret`、`password`、`token`、`private_key`、`DEBUG`、发布面向代码中的 `print(`。

### 类别 5: 作弊和反篡改向量
- 游戏关键值是否仅存储在内存中，而不是易于编辑的文件中？
- 任何关键游戏进度标志（例如"已购买 DLC"）是否在服务器端验证？
- 对多人游戏是否有任何针对内存编辑工具（Cheat Engine 等）的保护？
- 排行榜/分数提交在接受前是否经过验证？

注意：客户端反作弊在很大程度上无法强制执行。专注于竞争性或货币化内容的服务器端验证。

### 类别 6: 依赖和供应链
- 是否使用任何第三方插件或库？列出它们。
- 任何插件在被使用的版本中是否有已知 CVE？
- 插件来源是否经过验证（官方市场、经过审查的仓库）？

Glob：`addons/`、`plugins/`、`third_party/`、`vendor/` —— 列出所有外部依赖。

---

## 阶段 4: 分类发现

对于每个发现，分配：

**严重度：**
| 级别 | 定义 |
|-------|-----------|
| **CRITICAL** | 远程代码执行、数据泄露或易于利用的破坏多人游戏完整性的作弊 |
| **HIGH** | 绕过进度的存档篡改、凭据暴露或服务器端权威绕过 |
| **MEDIUM** | 客户端作弊启用、信息泄露或影响有限的输入验证缺口 |
| **LOW** | 纵深防御改进 —— 减少攻击面但没有直接利用的加固 |

**状态：** 开放 / 接受风险 / 超出范围

---

## 阶段 5: 生成报告

```markdown
# 安全审计报告

**日期**: [date]
**范围**: [full | network | save | input | quick]
**引擎**: [engine + version]
**审计者**: /security-audit 通过 security-engineer
**扫描文件**: [N 源文件, N 配置文件]

---

## 执行摘要

| 严重度 | 计数 | 发布前必须修复 |
|----------|-------|------------------------|
| CRITICAL | [N] | 是 —— 全部 |
| HIGH | [N] | 是 —— 全部 |
| MEDIUM | [N] | 推荐 |
| LOW | [N] | 可选 |

**发布建议**: [CLEAR TO SHIP / FIX CRITICALS FIRST / DO NOT SHIP]

---

## CRITICAL 发现

### SEC-001: [Title]
**类别**: [Save / Network / Input / Data / Cheat / Dependency]
**文件**: `[path]` 第 [N] 行
**描述**: [漏洞是什么]
**攻击场景**: [恶意用户如何利用它]
**修复**: [要应用的具体代码更改或模式]
**工作量**: [Low / Medium / High]

[每个发现重复]

---

## HIGH 发现

[相同格式]

---

## MEDIUM 发现

[相同格式]

---

## LOW 发现

[相同格式]

---

## 接受的风险

[团队明确接受的任何发现及理由]

---

## 依赖清单

| 插件 / 库 | 版本 | 来源 | 已知 CVE |
|-----------------|---------|--------|------------|
| [name] | [version] | [source] | [none / CVE-XXXX-NNNN] |

---

## 修复优先顺序

1. [SEC-NNN] —— [1 行描述] —— 预估工作量: [Low/Medium/High]
2. ...

---

## 重新审计触发器

修复任何 CRITICAL 或 HIGH 发现后再次运行 `/security-audit`。
Polish → Release gate 要求此报告没有开放的 CRITICAL 或 HIGH 项目。
```

---

## 阶段 6: 写入报告

在对话中展示报告摘要（执行摘要 + 仅 CRITICAL/HIGH 发现）。

询问："我可以将完整安全审计报告写入 `production/security/security-audit-[date].md` 吗？"

仅在批准后写入。

---

## 阶段 7: Gate 集成

此报告是 **Polish → Release gate** 所需的产物。

修复发现后，重新运行：`/security-audit quick` 以在运行 `/gate-check release` 前确认 CRITICAL/HIGH 项目已解决。

如果存在 CRITICAL 发现：
> "⛔ CRITICAL 安全发现必须在任何公开发布前解决。在解决这些问题之前不要继续 `/launch-checklist`。"

如果没有 CRITICAL/HIGH 发现：
> "✅ 没有阻塞性安全发现。报告已写入 `production/security/`。运行 `/gate-check release` 时包含此路径。"

---

## 协作协议

- **Never assume a pattern is safe** —— 标记它并让用户决定
- **Accepted risk is a valid outcome** —— 一些 LOW 发现对于单人团队是可接受的权衡；记录决策
- **Multiplayer games have a higher bar** —— 多人游戏中的任何 HIGH 发现应被视为 CRITICAL
- **This is not a penetration test** —— 此审计涵盖常见模式；建议在任何人竞争性或货币化多人游戏上线前由人工安全专业人员进行真正的渗透测试
