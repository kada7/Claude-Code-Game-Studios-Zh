# Agent 测试规范：godot-gdextension-specialist

## Agent 摘要
领域：GDExtension API、godot-cpp C++ 绑定、godot-rust 绑定、原生库集成和原生性能优化。
不负责：GDScript 代码（gdscript-specialist）、着色器代码（godot-shader-specialist）。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构性）

- [ ] `description:` 字段存在且具有领域特定性（引用 GDExtension / godot-cpp / 原生绑定）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Bash、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对 GDScript 或着色器编写具有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "通过 GDExtension 将 C++ 刚体物理模拟库暴露给 GDScript。"
**预期行为：**
- 使用 godot-cpp 生成 GDExtension 绑定模式：
  - 继承自 `godot::Object` 或适当的 Godot 基类的类
  - `GDCLASS` 宏注册
  - `_bind_methods()` 实现，将物理 API 暴露给 GDScript
  - `GDExtension` 入口点（`gdextension_init`）设置
- 注明所需的 `.gdextension` 清单文件格式
- 不生成 GDScript 使用代码（这属于 gdscript-specialist）

### 用例 2：领域外重定向
**输入：** "编写调用用例 1 中物理模拟的 GDScript。"
**预期行为：**
- 不生成 GDScript 代码
- 明确说明 GDScript 编写属于 `godot-gdscript-specialist`
- 重定向到 `godot-gdscript-specialist`
- 可以描述 GDScript 应调用的 API 表面（方法名、参数类型）作为交接规范

### 用例 3：ABI 兼容性风险 — 次要版本更新
**输入：** "我们正在从 Godot 4.5 升级到 4.6。我们现有的 GDExtension 还能工作吗？"
**预期行为：**
- 标记 ABI 兼容性问题：GDExtension 二进制文件在次要版本之间可能不兼容 ABI
- 指导检查 4.5→4.6 迁移指南中的 GDExtension API 变更
- 建议针对 4.6 godot-cpp 头文件重新编译扩展，而不是假设二进制兼容性
- 注明 `.gdextension` 清单可能需要更新 `compatibility_minimum` 版本
- 提供重新编译检查清单

### 用例 4：内存管理 — Godot 对象的 RAII
**输入：** "我们应该如何管理在 C++ GDExtension 代码中创建的 Godot 对象的生命周期？"
**预期行为：**
- 为 GDExtension 中的 Godot 对象生成基于 RAII 的生命周期模式：
  - 引用计数对象使用 `Ref<T>`（当 Ref 超出作用域时自动释放）
  - 非引用计数对象使用 `memnew()` / `memdelete()`
  - 警告：不要对 Godot 对象使用 `new`/`delete` — 未定义行为
- 注明对象所有权规则：谁负责释放添加到场景树中的节点
- 提供管理在 C++ 中创建的 `CollisionShape3D` 的具体示例

### 用例 5：上下文传递 — Godot 4.6 GDExtension API 检查
**输入：** 引擎版本上下文：Godot 4.6（从 4.5 升级）。请求："检查从 4.5 到 4.6 是否有任何 GDExtension API 变更。"
**预期行为：**
- 引用已验证来源列表中的 4.5→4.6 迁移指南
- 报告 4.6 版本中任何已记录的 GDExtension API 变更
- 如果 4.6 中没有记录 GDExtension 的破坏性变更，则明确说明并附带警告，建议验证官方变更日志
- 标记 Windows 上的 D3D12 默认设置（4.6 变更）可能与 GDExtension 渲染代码相关
- 提供升级后验证检查清单

---

## 协议合规性

- [ ] 保持在声明的领域内（GDExtension、godot-cpp、godot-rust、原生绑定）
- [ ] 将 GDScript 编写重定向到 godot-gdscript-specialist
- [ ] 将着色器编写重定向到 godot-shader-specialist
- [ ] 返回结构化输出（绑定模式、RAII 示例、ABI 检查清单）
- [ ] 在次要版本升级时标记 ABI 兼容性风险 — 从不假设二进制兼容性
- [ ] 使用 Godot 特定的内存管理（`memnew`/`memdelete`、`Ref<T>`），而非原始 C++ new/delete
- [ ] 在确认兼容性前检查引擎版本参考中的 GDExtension API 变更

---

## 覆盖说明
- 绑定模式（用例 1）应包括烟雾测试，验证扩展加载且方法可从 GDScript 调用
- ABI 风险（用例 3）是关键升级路径 — Agent 不得批准发布未经验证的扩展二进制文件
- 内存管理（用例 4）验证 Agent 应用 Godot 特定模式，而非通用 C++ RAII