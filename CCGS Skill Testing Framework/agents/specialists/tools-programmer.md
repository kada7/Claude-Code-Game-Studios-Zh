# Agent 测试规范: tools-programmer

## Agent 摘要
领域: Editor extensions, content authoring tools, debug utilities, and pipeline automation scripts.
不负责: 游戏代码 (gameplay-programmer, ui-programmer 等), 引擎核心系统 (engine-programmer).
模型层级: Sonnet (默认).
未分配门禁 ID.

---

## 静态断言 (结构)

- [ ] `description:` 字段存在且具有领域特定性 (引用 editor tools / pipeline / debug utilities)
- [ ] `allowed-tools:` 列表包含 Read, Write, Edit, Bash, Glob, Grep
- [ ] 模型层级为 Sonnet (specialists 的默认值)
- [ ] Agent 定义不声称对游戏源代码或引擎内部系统拥有权限

---

## 测试用例

### 用例 1: 领域内请求 — 适当的输出
**输入:** "Create a custom editor tool for placing enemy patrol waypoints in the level."
**预期行为:**
- 为配置的引擎生成 editor extension spec 和代码脚手架 (例如, Godot EditorPlugin, Unity Editor window, Unreal Detail Customization)
- 工具允许设计师在场景/视口中点击放置 waypoints
- Waypoints 被序列化为引擎原生资源 (非硬编码), 以便 level-designer 无需代码即可编辑
- 包含 undo/redo 支持, 遵循 editor plugin 最佳实践
- 不修改 AI 寻路运行时代码 (这属于 ai-programmer)

### 用例 2: 领域外请求 — 正确重定向
**输入:** "Implement the enemy melee combo system in code."
**预期行为:**
- 不生成 gameplay mechanic 代码
- 明确说明战斗系统实现属于 `gameplay-programmer`
- 将请求重定向至 `gameplay-programmer`
- 可以注明如果需要, 可以构建 debug overlay tool 来可视化 combo 状态

### 用例 3: 运行时数据访问 — 需要协调
**输入:** "The waypoint editor tool needs to read game data at runtime to validate patrol routes against the AI budget."
**预期行为:**
- 识别从 editor plugin 访问运行时数据需要定义安全的接口来访问游戏的运行时系统
- 与 `engine-programmer` 协调建立只读数据访问模式 (例如, 资源验证 API)
- 不直接读取内部引擎或游戏内存结构, 除非有约定的接口
- 在实现工具之前记录所需的接口

### 用例 4: 引擎版本破坏性变更
**输入:** "After the engine upgrade, the waypoint editor tool crashes on startup."
**预期行为:**
- 检查引擎版本参考 (`docs/engine-reference/`) 中 editor plugin API 的破坏性变更
- 识别新版本中更改的特定 API 或信号
- 生成针对破坏性变更的修复方案
- 注明可能受相同 API 变更影响的其他工具

### 用例 5: 上下文传递 — 美术流水线需求
**输入:** 上下文中提供的美术流水线需求: "All texture imports must set compression to VRAM Compressed, generate mipmaps, and tag with a LOD group." 请求: "Build an asset import tool that enforces these settings."
**预期行为:**
- 引用上下文中的所有三个需求: VRAM compression, mipmap generation, LOD group tagging
- 生成在导入时验证并应用所有三个设置的 import tool
- 为不符合指定设置的资源添加警告或错误报告
- 不更改美术流水线需求本身 (这些属于 art-director / technical-artist)

---

## 协议合规性

- [ ] 保持在声明的领域内 (editor tools, pipeline scripts, debug utilities)
- [ ] 将游戏代码请求重定向到适当的 programmer agents
- [ ] 返回结构化发现 (tool specs, editor extension code, pipeline scripts)
- [ ] 在从 editor 上下文访问运行时数据之前与 engine-programmer 协调
- [ ] 在使用 editor plugin API 之前检查引擎版本参考
- [ ] 构建工具来强制执行需求, 而不是编写需求本身

---

## 覆盖范围说明
- Waypoint editor tool (用例 1) 应具有 smoke test, 验证其在 editor 中加载无错误
- Runtime data access (用例 3) 确认 agent 尊重 engine-programmer 对核心 API 的所有权
- Art pipeline context (用例 5) 验证 agent 构建工具以匹配提供的规范, 而不是发明需求