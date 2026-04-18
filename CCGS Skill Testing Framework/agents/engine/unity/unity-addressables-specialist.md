# Agent 测试规范：unity-addressables-specialist

## Agent 概述
领域：可寻址资源系统 — 资源组、异步加载/卸载、句柄生命周期管理、内存预算、内容目录和远程内容交付。
不负责：渲染系统（engine-programmer）、使用已加载资源的游戏逻辑（gameplay-programmer）。
模型层级：Sonnet（默认）。
未分配门禁ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且领域特定（引用 Addressables / 资源加载 / 内容目录 / 远程交付）
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声明对渲染系统或使用已加载资源的游戏逻辑的权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "异步加载角色纹理，并在角色销毁时释放它。"
**预期行为：**
- 生成 `Addressables.LoadAssetAsync<Texture2D>()` 调用模式
- 将返回的 `AsyncOperationHandle<Texture2D>` 存储在请求对象中
- 在角色销毁时（`OnDestroy()`），使用存储的句柄调用 `Addressables.Release(handle)`
- 不使用 `Resources.Load()` 作为加载机制
- 注意使用空或未初始化句柄释放会导致错误 — 包含有效性检查
- 注意释放句柄与释放资源之间的区别（句柄释放是正确的）

### 用例 2：领域外重定向
**输入：** "实现将加载的纹理应用到角色网格的渲染系统。"
**预期行为：**
- 不生成渲染或网格材质分配代码
- 明确声明渲染系统实现属于 `engine-programmer`
- 将请求重定向到 `engine-programmer`
- 可以描述它将提供的资源类型和API表面（例如，句柄完成后提供的 `Texture2D` 引用）作为交接规范

### 用例 3：内存泄漏 — 未释放的句柄
**输入：** "每次关卡加载后内存使用量持续攀升。我们使用 Addressables 加载关卡资源。"
**预期行为：**
- 诊断可能原因：使用后未释放 `AsyncOperationHandle` 对象
- 识别句柄泄漏模式：将资源加载到局部变量中，丢失引用，从未调用 `Addressables.Release()`
- 生成审计方法：搜索所有 `LoadAssetAsync` / `LoadSceneAsync` 调用并验证匹配的 `Release()` 调用
- 提供使用跟踪句柄列表（`List<AsyncOperationHandle>`）和 `ReleaseAll()` 清理方法的修正模式
- 没有证据时不假设泄漏在其他地方

### 用例 4：远程内容交付 — 目录版本控制
**输入：** "我们需要支持可下载内容更新，而无需完整的应用重新安装。"
**预期行为：**
- 生成远程目录更新模式：
  - 启动时使用 `Addressables.CheckForCatalogUpdates()`
  - 对检测到的更新使用 `Addressables.UpdateCatalogs()`
  - 使用 `Addressables.DownloadDependenciesAsync()` 预热更新后的内容
- 注意用于变更检测的目录哈希检查
- 处理边缘情况：如果玩家开始会话，目录在会话中途更新 — 定义行为（在旧目录上完成当前会话，下次启动时重新加载）
- 不设计服务器端CDN基础设施（委托给 devops-engineer）

### 用例 5：上下文传递 — 平台内存约束
**输入：** 平台上下文：Nintendo Switch 目标，4GB RAM，实际资源内存上限 512MB。请求："为大型开放世界关卡设计 Addressables 加载策略。"
**预期行为：**
- 引用提供的上下文中的 512MB 内存上限
- 设计流式加载策略：
  - 根据玩家接近度将世界划分为可寻址区域进行加载/卸载
  - 定义每个活动区域的内存预算（例如，128MB，最多4个活动区域）
  - 指定异步预加载触发距离和卸载距离（滞后）
- 注意 Switch 特定约束：从 SD 卡加载时间较慢，建议预热相邻区域
- 不生成会超过声明的 512MB 上限的加载策略，除非标记出来

---

## 协议合规性

- [ ] 保持在声明的领域内（Addressables 加载、句柄生命周期、内存、目录、远程交付）
- [ ] 将渲染和游戏资源使用代码重定向到 engine-programmer 和 gameplay-programmer
- [ ] 返回结构化输出（加载模式、句柄生命周期代码、流式区域设计）
- [ ] 始终将 `LoadAssetAsync` 与相应的 `Release()` 配对 — 将句柄泄漏标记为内存错误
- [ ] 根据提供的内存上限设计加载策略
- [ ] 不设计 CDN/服务器基础设施 — 将服务器端委托给 devops-engineer

---

## 覆盖范围说明
- 句柄生命周期（用例 1）必须包含验证释放后内存是否回收的测试
- 句柄泄漏诊断（用例 3）应生成适合错误工单的发现报告
- 平台内存用例（用例 5）验证 Agent 应用上下文中的硬约束，而非默认假设