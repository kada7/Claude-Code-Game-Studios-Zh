# Agent 测试规范：unity-dots-specialist

## Agent 摘要
领域：ECS 架构 (IComponentData, ISystem, SystemAPI)、Jobs 系统 (IJob, IJobEntity, Burst)、Burst 编译器约束、DOTS 游戏系统以及混合渲染器。
不负责：MonoBehaviour 游戏代码 (gameplay-programmer)、UI 实现 (unity-ui-specialist)。
模型层级：Sonnet (默认)。
未分配门控 ID。

---

## 静态断言 (结构)

- [ ] `description:` 字段存在且具有领域特定性 (引用 ECS / Jobs / Burst / IComponentData)
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级为 Sonnet (专家默认)
- [ ] Agent 定义不声称对 MonoBehaviour 游戏或 UI 系统拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "将玩家移动系统转换为 ECS。"
**预期行为：**
- 生成：
  - `PlayerMovementData : IComponentData` 结构体，包含速度、速度和输入向量字段
  - `PlayerMovementSystem : ISystem`，带有使用 `SystemAPI.Query<>` 或 `IJobEntity` 的 `OnUpdate()`
  - 通过 `IBaker` 从创作 MonoBehaviour 烘焙玩家的初始状态
- 使用 `RefRW<LocalTransform>` 进行位置更新 (而非已弃用的 `Translation`)
- 标记作业为 `[BurstCompile]` 并注明 Burst 兼容性所需的非托管要求
- 不修改输入轮询系统 — 从现有的 `PlayerInputData` 组件读取

### 用例 2：MonoBehaviour 推回
**输入：** "直接使用 MonoBehaviour 处理玩家移动 — 这样更简单。"
**预期行为：**
- 承认简单性论点
- 解释 DOTS 权衡：前期设置更多，但 ECS/Burst 方法提供了项目 ADR 或需求中记录的性能特性
- 如果项目已承诺使用 DOTS，则不实现 MonoBehaviour 版本
- 如果不存在承诺，将架构决策标记给 `lead-programmer` / `technical-director` 解决
- 不单方面做出 MonoBehaviour 与 DOTS 的决策

### 用例 3：Burst 不兼容的托管内存
**输入：** "这个 Burst 作业访问 `List<EnemyData>` 来查找最近的敌人。"
**预期行为：**
- 标记 `List<T>` 为托管类型，与 Burst 编译不兼容
- 不批准带有托管内存访问的 Burst 作业
- 提供正确的替代方案：`NativeArray<EnemyData>`、`NativeList<EnemyData>` 或 `NativeHashMap<>`，取决于用例
- 注明 `NativeArray` 必须显式释放或通过 `[DeallocateOnJobCompletion]`
- 生成使用非托管原生容器的修正后作业

### 用例 4：混合访问 — DOTS 系统需要 MonoBehaviour 数据
**输入：** "DOTS 移动系统需要读取由 MonoBehaviour CameraController 管理的相机变换。"
**预期行为：**
- 将此识别为混合访问场景
- 提供正确的混合模式：将相机变换存储在单例 `IComponentData` 中 (每帧从 MonoBehaviour 端通过 `EntityManager.SetComponentData` 更新)
- 或者建议 `CompanionComponent` / 托管组件方法
- 不从 Burst 作业内部访问 MonoBehaviour — 标记为不安全
- 在 MonoBehaviour 端 (写入 ECS) 和 DOTS 系统端 (从 ECS 读取) 提供桥接代码

### 用例 5：上下文传递 — 性能目标
**输入：** 来自上下文的偏好：60fps 目标，每帧最大 2ms CPU 脚本预算。请求："为 10,000 个敌人实体设计 ECS 块布局。"
**预期行为：**
- 在设计原理中明确引用 2ms CPU 预算
- 为缓存效率设计 `IComponentData` 块布局：
  - 将频繁一起查询的组件分组到同一原型中
  - 将很少使用的数据分离到单独的组件中，以保持热数据紧凑
  - 根据 2ms 预算估算实体迭代时间
- 提供内存布局分析 (每个实体的字节数，16KB 块大小下的每个块实体数)
- 不设计明显超出所述 2ms 预算而不标记的布局

---

## 协议合规性

- [ ] 保持在声明的领域内 (ECS, Jobs, Burst, DOTS 游戏系统)
- [ ] 将仅 MonoBehaviour 的游戏重定向到 gameplay-programmer
- [ ] 返回结构化输出 (IComponentData 结构体, ISystem 实现, IBaker 创作类)
- [ ] 将 Burst 作业中的托管内存访问标记为编译错误并提供非托管替代方案
- [ ] 当 DOTS 系统需要与 MonoBehaviour 系统交互时提供混合访问模式
- [ ] 根据提供的性能预算设计块布局

---

## 覆盖范围说明
- ECS 转换 (用例 1) 必须包含使用 ECS 测试框架 (`World`, `EntityManager`) 的单元测试
- Burst 不兼容性 (用例 3) 是安全关键 — Agent 必须在代码编写前捕获此问题
- 块布局 (用例 5) 验证 Agent 将定量性能推理应用于架构决策