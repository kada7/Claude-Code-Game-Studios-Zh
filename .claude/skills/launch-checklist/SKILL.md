---
name: launch-checklist
description: "完整的发布准备验证，涵盖所有部门：代码、内容、商店、营销、社区、基础设施、法律和通过/不通过签署。"
argument-hint: "[launch-date or 'dry-run']"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write
---

> **仅显式调用**: 只有当用户显式使用 `/launch-checklist` 请求时，此技能才应运行。不要基于上下文匹配自动调用。

## Phase 1: Parse Arguments

读取 launch date 或 `dry-run` 模式的参数。Dry-run 模式生成清单而不创建签署条目或写入文件。

---

## Phase 2: Gather Project Context

- 读取 `CLAUDE.md` 获取技术栈、目标平台和团队结构
- 读取 `production/milestones/` 中的最新里程碑
- 读取 `production/releases/` 中的任何现有发布清单
- 如果存在，读取 `design/live-ops/content-calendar.md` 中的内容日历

---

## Phase 3: Scan Codebase Health

- 计数 `TODO`, `FIXME`, `HACK` 注释及其位置
- 检查 production code 中是否有遗留的 `console.log`, `print()`, 或 debug 输出
- 检查 placeholder assets（搜索 `placeholder`, `temp_`, `WIP_`）
- 检查硬编码的 test/dev 值（localhost, test credentials, debug flags）

---

## Phase 4: Generate the Launch Checklist

```markdown
# Launch Checklist: [Game Title]
Target Launch: [Date or DRY RUN]
Generated: [Date]

---

## 1. Code Readiness

### Build Health
- [ ] 在所有目标平台上干净构建
- [ ] 零编译器警告
- [ ] 所有单元测试通过
- [ ] 所有集成测试通过
- [ ] 性能基准在目标范围内
- [ ] 没有内存泄漏（通过 extended soak test 验证）
- [ ] 构建大小在平台限制内
- [ ] 构建版本在源代码控制中正确设置和标记

### Code Quality
- [ ] TODO count: [N] (launch 需要为零，或有记录的例外)
- [ ] FIXME count: [N] (需要为零)
- [ ] HACK count: [N] (每个必须有记录的理由)
- [ ] Production code 中没有 debug 输出
- [ ] 没有硬编码的 dev/test 值
- [ ] 所有功能标志设置为 production 值
- [ ] Error handling 覆盖所有关键路径
- [ ] Crash reporting 集成并验证

### Security
- [ ] 源代码中没有暴露的 API 密钥或凭证
- [ ] Save data 已加密
- [ ] Network communication 已保护 (TLS/DTLS)
- [ ] Anti-cheat measures 激活（如果 multiplayer）
- [ ] 所有服务器端点上的输入验证（如果 multiplayer）
- [ ] Privacy policy compliance 已验证

---

## 2. Content Readiness

### Assets
- [ ] 所有 placeholder art 替换为 final assets
- [ ] 所有 placeholder audio 替换为 final audio
- [ ] Audio mix 最终确定并由 audio director 批准
- [ ] 所有 VFX 经过 polish 和性能验证
- [ ] 没有缺失或损坏的 asset 引用
- [ ] Asset naming conventions 已强制执行

### Text and Localization
- [ ] 所有玩家 facing 文本已校对
- [ ] 没有硬编码字符串（所有外部化用于本地化）
- [ ] 所有支持的语言已翻译和验证
- [ ] 文本适合所有语言的 UI（text fitting pass 完成）
- [ ] 所有支持语言的字体覆盖已验证
- [ ] Credits 完整、准确且最新

### Game Content
- [ ] 所有 levels/maps 从头到尾可玩
- [ ] Tutorial flow 完整并与新玩家一起测试
- [ ] 所有 achievements/trophies 已实现和测试
- [ ] Save/load 对所有游戏状态都正常工作
- [ ] Difficulty settings 平衡和测试
- [ ] End-game/credits 序列完成

---

## 3. Quality Assurance

### Testing
- [ ] Full regression test suite 通过
- [ ] 零打开的 S1 (Critical) bugs
- [ ] 零打开的 S2 (Major) bugs（或有记录的例外）
- [ ] Soak test 通过（连续玩 8+ 小时）
- [ ] Multiplayer stress test 通过（如果适用）
- [ ] 所有 critical user paths 在每个平台上测试
- [ ] Edge cases 测试（full storage, no network, suspend/resume）

### Platform Certification
- [ ] PC: Steam/Epic/GOG SDK 要求已满足
- [ ] Console: TRC/TCR/Lotcheck submission 已准备
- [ ] Mobile: App Store/Play Store 指南合规
- [ ] Accessibility: 达到最低标准（remapping, text scaling, colorblind）
- [ ] Age ratings 已获得（ESRB, PEGI, regional）

### Performance
- [ ] 在最低规格硬件上达到 Target FPS
- [ ] 所有平台上的 Load times 在预算内
- [ ] 所有平台上的 Memory usage 在预算内
- [ ] Network bandwidth 在目标范围内（如果 multiplayer）
- [ ] 关键 gameplay 时刻没有 frame hitches

---

## 4. Store and Distribution

### Store Pages
- [ ] Store page copy 最终确定和校对
- [ ] Screenshots 当前和 per-platform resolution
- [ ] Trailers 当前和已批准
- [ ] Key art 和 capsule images 最终确定
- [ ] System requirements 准确（PC）
- [ ] 所有地区的 Pricing 已配置
- [ ] Pre-purchase/wishlist campaigns 激活（如果适用）

### Legal
- [ ] EULA 最终确定并由 legal 批准
- [ ] Privacy policy 已发布和链接
- [ ] Third-party license attributions 完成
- [ ] Music/audio licensing 已验证
- [ ] Trademark/IP clearance 已确认
- [ ] GDPR/CCPA compliance 已验证（data collection, consent, deletion）

---

## 5. Infrastructure

### Servers (如果 multiplayer/online)
- [ ] Production servers 已配置和 load-tested
- [ ] Auto-scaling 已配置和测试
- [ ] Database backups 已配置
- [ ] CDN 已配置用于 content delivery
- [ ] DDoS protection 激活
- [ ] Monitoring 和 alerting 已配置

### Analytics and Monitoring
- [ ] Analytics pipeline 已验证并接收数据
- [ ] Crash reporting 激活且 dashboard 可访问
- [ ] Server monitoring dashboards 上线
- [ ] Key metrics 跟踪：DAU, session length, retention, crashes
- [ ] Alerts 已配置用于 critical thresholds

---

## 6. Community and Marketing

### Community Readiness
- [ ] Community guidelines 已发布
- [ ] Moderation team 已简报且工具准备就绪
- [ ] Discord/forum/social channels 已设置
- [ ] FAQ 和 known issues page 已准备
- [ ] Support email/ticketing system 激活

### Marketing
- [ ] Launch trailer 已发布
- [ ] Press/influencer review keys 已分发
- [ ] Social media launch posts 已安排
- [ ] Launch day blog post/dev update 已起草
- [ ] Patch notes for launch version 已发布

---

## 7. Operations

### Team Readiness
- [ ] On-call schedule 为 launch 后前 72 小时设置
- [ ] Incident response playbook 已由团队审查
- [ ] Rollback plan 已记录和测试
- [ ] Hotfix pipeline 已测试（可在 4 小时内发布紧急修复）
- [ ] Launch issues 的沟通计划（who posts, where, how fast）

### Day-One Plan
- [ ] Day-one patch 已准备（如果需要）
- [ ] Server unlock/go-live procedure 已记录
- [ ] Launch monitoring dashboard 已被所有 leads 收藏
- [ ] War room/channel 已为 launch day 建立

---

## Go / No-Go Decision

**Overall Status**: [READY / NOT READY / CONDITIONAL]

### Blocking Items
[列出必须在 launch 前解决的项目]

### Conditional Items
[列出有记录解决方法或接受风险的项目]

### Sign-Offs Required
- [ ] Creative Director — Content 和 experience quality
- [ ] Technical Director — Technical health 和 stability
- [ ] QA Lead — Quality 和 test coverage
- [ ] Producer — Schedule 和 overall readiness
- [ ] Release Manager — Build 和 deployment readiness
```

---

## Phase 5: Save Checklist

向用户呈现完成的清单和摘要（总项目数、阻塞项目数、条件项目数、有不完整部分的部门）。

如果不是 dry-run 模式，询问："我可以将此写入 `production/releases/launch-checklist-[date].md` 吗？"

如果是，写入文件，根据需要创建目录。

---

## Phase 6: Next Steps

- 在 launch 前运行 `/gate-check` 获得正式的 PASS/CONCERNS/FAIL 裁决。
- 通过 `/team-release` 协调签署。
