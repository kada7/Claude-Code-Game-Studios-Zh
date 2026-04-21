# Agent 测试规范：ue-replication-specialist

## Agent 摘要
- **领域**：属性复制（UPROPERTY Replicated/ReplicatedUsing）、RPC（Server/Client/NetMulticast）、客户端预测与调和、网络相关性和始终相关设置、网络序列化（FArchive/NetSerialize）、带宽优化和复制频率调优
- **不拥有**：被复制的游戏玩法逻辑（gameplay-programmer）、服务器基础设施和托管（devops-engineer）、GAS 特定预测（ue-gas-specialist 处理 GAS 网络预测）
- **模型层级**：Sonnet
- **门控 ID**：无；将安全相关的复制问题上报给 lead-programmer

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且特定于领域（引用 replication、RPCs、client prediction、bandwidth）
- [ ] `allowed-tools:` 列表与 agent 角色匹配（用于 C++ 和 Blueprint 源文件的 Read/Write；无基础设施或部署工具）
- [ ] Model tier 为 Sonnet（specialists 的默认值）
- [ ] Agent 定义不声称对 server infrastructure、game server architecture 或 gameplay logic correctness 拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 带客户端预测的玩家生命值复制
**输入**："设置客户端可以在本地预测的玩家生命值复制（例如，在受到自伤时），并由服务器进行纠正。"
**预期行为**：
- 在适当的 Character 或 AttributeSet 类中生成 UPROPERTY(ReplicatedUsing=OnRep_Health) 声明
- 描述 OnRep_Health 函数：应用视觉/音频反馈，将预测值与服务器权威值协调
- 解释 client prediction 模式：本地客户端立即应用暂定伤害，服务器权威值通过 OnRep 到达并纠正任何差异
- 注意如果使用 GAS，内置的 GAS prediction 会处理此问题 — 建议与 ue-gas-specialist 协调
- 输出是具体的代码结构（属性声明 + OnRep 大纲），而不仅仅是概念描述

### 用例 2：领域外请求 — 游戏服务器架构
**输入**："设计我们的游戏服务器基础设施——我们需要多少专用服务器、区域部署和匹配架构。"
**预期行为**：
- 不生成 server infrastructure architecture、hosting recommendations 或 matchmaking design
- 明确声明："Server infrastructure and deployment architecture is owned by devops-engineer; I handle the Unreal replication layer within a running game session"
- 不将游戏内 replication 与 server hosting 问题混淆

### 用例 3：领域边界 — 未经服务器权威验证的 RPC
**输入**："我们有一个名为 ServerSpendCurrency 的 Server RPC，用于扣除游戏内货币。客户端调用它，服务器直接扣除而不做任何检查。"
**预期行为**：
- 将此标记为关键安全漏洞：未经验证的 server RPCs 可能被作弊者利用发送任意 RPC 调用
- 提供所需的修复：在扣除前进行服务器端验证 — 检查玩家是否实际拥有货币，验证交易是否有效，如果不有效则拒绝并记录
- 使用模式：`if (!HasAuthority()) return;` 守卫加上显式的状态验证再进行变更
- 注意考虑到经济影响，这应该由 lead-programmer 审查
- 不在解释原始代码为何危险的情况下生成"修复后"的代码

### 用例 4：带宽优化 — 高频移动复制
**输入**："我们的玩家移动每 tick 使用 Vector3 位置进行复制。有 32 名玩家时，我们超出了带宽预算。"
**预期行为**：
- 识别 tick-rate replication of full-precision Vector3 为带宽消耗大
- 提出量化 replication：使用 FVector_NetQuantize 或 FVector_NetQuantize100 而不是原始 FVector 以减少每次更新的字节数
- 建议通过 SetNetUpdateFrequency() 为非拥有客户端减少 replication 频率
- 注意 Unreal 内置的 Character Movement Component 已有优化的 movement replication — 建议使用或扩展它而不是创建自定义系统
- 如果可能，生成具体的带宽估算比较，或解释权衡

### 用例 5：上下文传递 — 在网络预算内设计
**输入上下文**：项目网络预算为每名玩家 64 KB/s，32 名玩家 = 2 MB/s 服务器总出站流量。当前移动复制已使用每名玩家 40 KB/s。
**输入**："我们希望添加实时库存复制，以便所有客户端可以立即看到其他玩家的装备变化。"
**预期行为**：
- 确认现有的 40 KB/s movement 成本为每个玩家仅留下 24 KB/s 用于其他所有内容
- 不设计天真的完整 inventory replication 方法（会超出预算）
- 建议仅增量或事件驱动的方法：仅复制已更改的槽位而不是完整的 inventory 数组
- 使用带有 ReplicatedUsing 的 FGameplayItemSlot 或等效物来触发有针对性的更新
- 明确说明所提议方法相对于剩余 24 KB/s 预算的带宽估算

---

## 协议合规性

- [ ] 保持在声明的领域内（property replication、RPCs、client prediction、bandwidth）
- [ ] 将 server infrastructure 请求重定向到 devops-engineer 而不生成 infrastructure design
- [ ] 将未经验证的 server RPCs 标记为安全问题并建议 lead-programmer 审查
- [ ] 返回结构化发现（property declarations、bandwidth estimates、optimization options）而非自由形式的建议
- [ ] 在评估 replication 设计选择时使用项目提供的带宽预算数字

---

## 覆盖说明
- 用例 3（RPC 安全性）是发布关键测试 — 未经验证的 RPCs 是前十大 multiplayer 攻击向量
- 用例 5 是最重要的上下文感知测试；agent 必须使用实际的预算数字，而非通用建议
- 用例 1 GAS 分支：如果配置了 GAS，agent 应检测到它并委托 ue-gas-specialist 处理 GAS 管理的属性
- 无自动化运行器；手动审查或通过 `/skill-test`
