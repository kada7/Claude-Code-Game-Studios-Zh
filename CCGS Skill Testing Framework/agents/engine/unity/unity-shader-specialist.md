# Agent 测试规范：unity-shader-specialist

## Agent 概述
领域：Unity Shader Graph、自定义 HLSL、VFX Graph、URP/HDRP 管线定制和后处理效果。
不负责：游戏玩法代码、美术风格指导。
模型层级：Sonnet（默认）。
未分配门禁 ID。

---

## 静态断言（结构）

- [ ] `description:` 字段存在且具有领域特定性（引用 Shader Graph / HLSL / VFX Graph / URP / HDRP）
- [ ] `allowed-tools:` 列表包含 Read、Write、Edit、Glob、Grep
- [ ] 模型层级为 Sonnet（专家默认）
- [ ] Agent 定义不声称对游戏玩法代码或美术指导拥有权限

---

## 测试用例

### 用例 1：领域内请求 — 适当的输出
**输入：** "Create an outline effect for characters using Shader Graph in URP."
**预期行为：**
- 生成 Shader Graph 节点设置描述：
  - 反转外壳方法：在顶点阶段缩放法线 → 顶点偏移，Cull Front
  - 或使用深度/法线边缘检测的屏幕空间后处理轮廓
- 基于 URP 能力推荐适当的方法（URP 兼容性使用反转外壳，HDRP 使用后处理）
- 注意 URP 限制：不支持几何着色器（排除几何着色器轮廓方法）
- 在未确认渲染管线的情况下不生成 HDRP 特定节点

### 用例 2：领域外重定向
**输入：** "Implement the character health bar UI in code."
**预期行为：**
- 不生成 UI 实现代码
- 明确说明 UI 实现属于 `ui-programmer`（或 `unity-ui-specialist`）
- 适当地重定向请求
- 可能指出，如果视觉效果本身是由着色器驱动的，则健康条的着色器填充效果（例如溶解/填充渐变）在其领域内

### 用例 3：HDRP 自定义通道实现轮廓
**输入：** "We're on HDRP and want the outline as a post-process effect."
**预期行为：**
- 生成 HDRP `CustomPassVolume` 模式：
  - 继承 `CustomPass` 的 C# 类
  - 使用 `CoreUtils.SetRenderTarget()` 和全屏着色器 blit 的 `Execute()` 方法
  - 用于边缘检测的深度/法线缓冲区采样
- 指出 CustomPass 需要 HDRP 包且在 URP 中不工作
- 在提供 HDRP 特定代码前确认项目使用 HDRP

### 用例 4：VFX Graph 性能 — GPU 事件批处理
**输入：** "The explosion VFX Graph has 10,000 particles per event and spawning 20 simultaneous explosions is causing GPU frame spikes."
**预期行为：**
- 识别 GPU 粒子生成为成本驱动因素（200,000 个同时存在的粒子）
- 提出 GPU 事件批处理：在多帧上延迟生成事件，错开初始化
- 推荐每个活动爆炸的粒子预算上限（例如，每个爆炸 3,000 个，排队处理超额部分）
- 指出用于跨帧分布的 VFX Graph 事件批处理模式和输出事件 API
- 不更改游戏玩法事件系统 — 提出 VFX 侧的预算解决方案

### 用例 5：上下文传递 — 渲染管线（URP 或 HDRP）
**输入：** 项目上下文：URP 渲染管线，Unity 2022.3。请求："Add depth of field post-processing."
**预期行为：**
- 使用 URP Volume 框架：`DepthOfField` Volume Override 组件
- 不使用 HDRP Volume 组件（例如，具有不同参数名称的 HDRP `DepthOfField`）
- 指出 URP 特定 DOF 限制与 HDRP 的对比（例如，散景质量差异）
- 生成与 Unity 2022.3 URP 包版本兼容的 C# Volume 配置文件设置代码

---

## 协议合规性

- [ ] 保持在声明的领域内（Shader Graph、HLSL、VFX Graph、URP/HDRP 定制）
- [ ] 将游戏玩法和 UI 代码重定向到适当的 Agent
- [ ] 返回结构化输出（节点图描述、HLSL 代码、CustomPass 模式）
- [ ] 区分 URP 和 HDRP 方法 — 从不交叉污染管线特定 API
- [ ] 在相关时将几何着色器方法标记为 URP 不兼容
- [ ] 生成不改变游戏玩法行为的 VFX 优化

---

## 覆盖范围说明
- 轮廓效果（用例 1）应与 `production/qa/evidence/` 中的视觉截图测试配对
- HDRP CustomPass（用例 3）确认 Agent 生成正确的 Unity 模式，而非通用后处理方法
- 管线分离（用例 5）验证 Agent 在没有上下文的情况下从不假设渲染管线