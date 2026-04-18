# Agent Test Spec: ue-replication-specialist

## Agent Summary
- **Domain**: Property replication (UPROPERTY Replicated/ReplicatedUsing), RPCs (Server/Client/NetMulticast), client prediction and reconciliation, net relevancy and always-relevant settings, net serialization (FArchive/NetSerialize), bandwidth optimization and replication frequency tuning
- **Does NOT own**: Gameplay logic being replicated (gameplay-programmer), server infrastructure and hosting (devops-engineer), GAS-specific prediction (ue-gas-specialist handles GAS net prediction)
- **Model tier**: Sonnet
- **Gate IDs**: None; escalates security-relevant replication concerns to lead-programmer

---

## Static Assertions (Structural)

- [ ] `description:` 字段存在且特定于领域（引用 replication、RPCs、client prediction、bandwidth）
- [ ] `allowed-tools:` 列表与 agent 角色匹配（用于 C++ 和 Blueprint 源文件的 Read/Write；无基础设施或部署工具）
- [ ] Model tier 为 Sonnet（specialists 的默认值）
- [ ] Agent 定义不声称对 server infrastructure、game server architecture 或 gameplay logic correctness 拥有权限

---

## Test Cases

### Case 1: In-domain request — replicated player health with client prediction
**Input**: "Set up replicated player health that clients can predict locally (e.g., when taking self-inflicted damage) and have corrected by the server."
**Expected behavior**:
- 在适当的 Character 或 AttributeSet 类中生成 UPROPERTY(ReplicatedUsing=OnRep_Health) 声明
- 描述 OnRep_Health 函数：应用视觉/音频反馈，将预测值与服务器权威值协调
- 解释 client prediction 模式：本地客户端立即应用暂定伤害，服务器权威值通过 OnRep 到达并纠正任何差异
- 注意如果使用 GAS，内置的 GAS prediction 会处理此问题 — 建议与 ue-gas-specialist 协调
- 输出是具体的代码结构（属性声明 + OnRep 大纲），而不仅仅是概念描述

### Case 2: Out-of-domain request — game server architecture
**Input**: "Design our game server infrastructure — how many dedicated servers we need, regional deployment, and matchmaking architecture."
**Expected behavior**:
- 不生成 server infrastructure architecture、hosting recommendations 或 matchmaking design
- 明确声明："Server infrastructure and deployment architecture is owned by devops-engineer; I handle the Unreal replication layer within a running game session"
- 不将游戏内 replication 与 server hosting 问题混淆

### Case 3: Domain boundary — RPC without server authority validation
**Input**: "We have a Server RPC called ServerSpendCurrency that deducts in-game currency. The client calls it and the server just deducts without checking anything."
**Expected behavior**:
- 将此标记为关键安全漏洞：未经验证的 server RPCs 可能被作弊者利用发送任意 RPC 调用
- 提供所需的修复：在扣除前进行服务器端验证 — 检查玩家是否实际拥有货币，验证交易是否有效，如果不有效则拒绝并记录
- 使用模式：`if (!HasAuthority()) return;` 守卫加上显式的状态验证再进行变更
- 注意考虑到经济影响，这应该由 lead-programmer 审查
- 不在解释原始代码为何危险的情况下生成"修复后"的代码

### Case 4: Bandwidth optimization — high-frequency movement replication
**Input**: "Our player movement is replicated using a Vector3 position every tick. With 32 players, we're exceeding our bandwidth budget."
**Expected behavior**:
- 识别 tick-rate replication of full-precision Vector3 为带宽消耗大
- 提出量化 replication：使用 FVector_NetQuantize 或 FVector_NetQuantize100 而不是原始 FVector 以减少每次更新的字节数
- 建议通过 SetNetUpdateFrequency() 为非拥有客户端减少 replication 频率
- 注意 Unreal 内置的 Character Movement Component 已有优化的 movement replication — 建议使用或扩展它而不是创建自定义系统
- 如果可能，生成具体的带宽估算比较，或解释权衡

### Case 5: Context pass — designing within a network budget
**Input context**: Project network budget is 64 KB/s per player, with 32 players = 2 MB/s total server outbound. Current movement replication already uses 40 KB/s per player.
**Input**: "We want to add real-time inventory replication so all clients can see other players' equipment changes immediately."
**Expected behavior**:
- 确认现有的 40 KB/s movement 成本为每个玩家仅留下 24 KB/s 用于其他所有内容
- 不设计天真的完整 inventory replication 方法（会超出预算）
- 建议仅增量或事件驱动的方法：仅复制已更改的槽位而不是完整的 inventory 数组
- 使用带有 ReplicatedUsing 的 FGameplayItemSlot 或等效物来触发有针对性的更新
- 明确说明所提议方法相对于剩余 24 KB/s 预算的带宽估算

---

## Protocol Compliance

- [ ] 保持在声明的领域内（property replication、RPCs、client prediction、bandwidth）
- [ ] 将 server infrastructure 请求重定向到 devops-engineer 而不生成 infrastructure design
- [ ] 将未经验证的 server RPCs 标记为安全问题并建议 lead-programmer 审查
- [ ] 返回结构化发现（property declarations、bandwidth estimates、optimization options）而非自由形式的建议
- [ ] 在评估 replication 设计选择时使用项目提供的带宽预算数字

---

## Coverage Notes
- Case 3 (RPC security) 是发布关键测试 — 未经验证的 RPCs 是前十大 multiplayer exploit vector
- Case 5 是最重要的上下文感知测试；agent 必须使用实际的预算数字，而非通用建议
- Case 1 GAS 分支：如果配置了 GAS，agent 应检测到它并委托 ue-gas-specialist 处理 GAS 管理的属性
- 无自动化运行器；手动审查或通过 `/skill-test`