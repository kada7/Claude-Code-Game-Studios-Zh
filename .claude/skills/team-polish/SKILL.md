---
name: team-polish
description: "Orchestrate the polish team: coordinates performance-analyst, technical-artist, sound-designer, and qa-tester to optimize, polish, and harden a feature or area for release quality."
argument-hint: "[feature or area to polish]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
---
如果没有提供参数，输出使用指南并退出而不生成任何代理:
> Usage: `/team-polish [feature or area]` — 指定要优化的功能或区域 (例如, `combat`, `main menu`, `inventory system`, `level-1`)。不要在此处使用 `AskUserQuestion`; 直接输出指南。

当使用参数调用此 skill 时，通过结构化流程编排优化团队。

**决策点:** 在每个阶段转换时，使用 `AskUserQuestion` 向用户展示
子代理的建议作为可选项。在对话中写入代理的
完整分析，然后使用简洁的标签捕获决策。
用户必须批准才能进入下一阶段。

## 团队组成
- **performance-analyst** — 性能分析、优化、内存分析、帧预算
- **engine-programmer** — 引擎级瓶颈: 渲染管道、内存、资源加载 (当 performance-analyst 识别出低级根本原因时调用)
- **technical-artist** — VFX 优化、着色器优化、视觉质量
- **sound-designer** — 音频优化、混音、环境层、反馈声音
- **tools-programmer** — 内容管道工具验证、编辑器工具稳定性、自动化修复 (当内容创作工具涉及优化区域时调用)
- **qa-tester** — 边界情况测试、回归测试、soak 测试

## 如何委派

使用 Task 工具将每个团队成员生成为子代理:
- `subagent_type: performance-analyst` — 性能分析、优化、内存分析
- `subagent_type: engine-programmer` — 渲染、内存、资源加载的引擎级修复
- `subagent_type: technical-artist` — VFX 优化、着色器优化、视觉质量
- `subagent_type: sound-designer` — 音频优化、混音、环境层
- `subagent_type: tools-programmer` — 内容管道和编辑器工具验证
- `subagent_type: qa-tester` — 边界情况测试、回归测试、soak 测试

始终在代理的提示中提供完整上下文 (目标功能/区域、性能预算、已知问题)。在流程允许的情况下并行启动独立代理 (例如，阶段 3 和 4 可以同时运行)。

## 流程

### 阶段 1: 评估
委派给 **performance-analyst**:
- 使用 `/perf-profile` 分析目标功能/区域
- 识别性能瓶颈和帧预算违规
- 测量内存使用并检查泄漏
- 针对目标硬件规格进行基准测试
- 输出: 包含优先优化列表的性能报告

### 阶段 2: 优化
委派给 **performance-analyst** (根据需要与相关程序员一起):
- 修复阶段 1 中识别的性能热点
- 优化绘制调用、减少过度绘制
- 修复内存泄漏并减少分配压力
- 验证优化不会改变游戏玩法行为
- 输出: 优化代码及前后指标

如果阶段 1 识别出引擎级根本原因 (渲染管道、资源加载、内存分配器)，并行将这些修复委派给 **engine-programmer**:
- 优化引擎系统中的热路径
- 修复核心循环中的分配压力
- 输出: 引擎级修复及分析器验证

### 阶段 3: 视觉优化 (与阶段 2 并行)
委派给 **technical-artist**:
- 审查 VFX 的质量和与艺术圣经的一致性
- 优化粒子系统和着色器效果
- 在适当的地方添加屏幕震动、摄像机效果和视觉冲击力
- 确保效果在较低设置下优雅降级
- 输出: 优化的视觉效果

### 阶段 4: 音频优化 (与阶段 2 并行)
委派给 **sound-designer**:
- 审查音频事件的完整性 (是否有任何动作缺少声音反馈?)
- 检查音频混音级别 — 相对于混音 nothing 太大或太小
- 为氛围添加环境音频层
- 验证音频与空间定位正确播放
- 输出: 音频优化列表和混音说明

### 阶段 5: 强化
委派给 **qa-tester**:
- 测试所有边界情况: 边界条件、快速输入、异常序列
- Soak 测试: 长时间运行功能检查退化
- 压力测试: 最大实体、最坏情况场景
- 回归测试: 验证优化更改没有破坏现有功能
- 在最低规格硬件上测试 (如果可用)
- 输出: 测试结果及任何剩余问题

### 阶段 6: 签署
- 收集所有团队成员的结果
- 将性能指标与预算进行比较
- 报告: READY FOR RELEASE / NEEDS MORE WORK
- 列出任何剩余问题及严重度和建议

## 错误恢复协议

如果任何生成的代理 (通过 Task) 返回 BLOCKED、错误或无法完成:

1. **立即展示**: 在向用户报告 "[AgentName]: BLOCKED — [reason]"，然后继续到依赖阶段
2. **评估依赖关系**: 检查被阻止代理的输出是否被后续阶段需要。如果是，在没有用户输入的情况下不要越过该依赖点。
3. **提供选项** 通过 AskUserQuestion 提供选择:
   - 跳过此代理并记录最终报告中的差距
   - 以更窄的范围重试
   - 在此处停止并首先解决阻止程序
4. **始终生成部分报告** — 输出已完成的内容。切勿因为代理被阻止而丢弃工作。

常见阻止程序:
- 输入文件缺失 (story 未找到, GDD 不存在) → 重定向到创建它的 skill
- ADR 状态为 Proposed → 不实现; 先运行 `/architecture-decision`
- 范围太大 → 通过 `/create-stories` 拆分为两个 stories
- ADR 和 story 之间的冲突说明 → 展示冲突，不要猜测

## 文件写入协议

所有文件写入 (性能报告、测试结果、证据文档) 都通过 Task 委派给子代理。每个子代理强制执行 "May I write to [path]?" 协议。此编排器不直接写入文件。

## 输出

涵盖以下内容的摘要报告: 性能前后指标、视觉优化更改、音频优化更改、测试结果和发布准备评估。

## 后续步骤

- 如果 READY FOR RELEASE: 运行 `/release-checklist` 进行最终发布前验证。
- 如果 NEEDS MORE WORK: 在 `/sprint-plan update` 中安排剩余问题并在修复后重新运行 `/team-polish`。
- 在移交给发布前运行 `/gate-check` 以进行正式阶段门裁决。
