# 技能测试规范：/playtest-report

## 技能摘要

`/playtest-report` 根据会话笔记或用户输入生成结构化的试玩测试报告。报告按四个部分组织：Feel/Accessibility、Observed Bugs、Design Feedback 和 Next Steps。当多个测试人员参与时，该技能汇总反馈并区分多数意见和少数意见。当报告的错误与 `production/bugs/` 中的文件匹配时，技能会链接到现有的错误报告。

报告在询问"May I write"后写入 `production/qa/playtest-[date].md`。此处不适用总监关卡 —— 如需 CD-PLAYTEST 总监关卡（如需要），是单独调用。报告写入时裁决为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证 —— 无需夹具。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE
- [ ] 包含 "May I write" 协作协议语言，在写入报告前
- [ ] 具有下一步交接（例如，`/bug-report` 处理发现的新问题，`/design-review` 处理反馈）

---

## 总监关卡检查

无。`/playtest-report` 是文档工具。CD-PLAYTEST 关卡是单独调用，不属于此技能的一部分。

---

## 测试用例

### 用例 1：理想路径 —— 用户提供试玩笔记，生成结构化报告

**测试夹具：**
- 用户提供来自单次会话的打字试玩笔记
- 笔记涵盖：游戏手感、一个错误（帧率下降）和一个设计顾虑（教程太长）
- `production/bugs/` 存在但为空（错误尚未报告）

**输入：** `/playtest-report`（用户粘贴会话笔记）

**预期行为：**
1. 技能读取提供的笔记并将其组织成 4 部分模板
2. Feel/Accessibility：提取手感观察
3. Bugs：记录帧率下降及可用的复现详情
4. Design Feedback：记录教程长度顾虑
5. Next Steps：建议针对帧率问题运行 `/bug-report`，针对教程反馈运行 `/design-review`
6. 技能询问"May I write to `production/qa/playtest-2026-04-06.md`?"
7. 报告在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 报告中存在所有 4 个部分
- [ ] 错误列在 Bugs 部分（非 Design Feedback 部分）
- [ ] Next Steps 适当（崩溃用 bug report，反馈用 design review）
- [ ] 在写入前询问 "May I write"
- [ ] 裁决为 COMPLETE

---

### 用例 2：空输入 —— 引导式提示逐节进行

**测试夹具：**
- 调用时用户未提供笔记

**输入：** `/playtest-report`

**预期行为：**
1. 技能检测到空输入
2. 技能逐节提示：
   a. "Describe the overall feel and any accessibility observations"
   b. "Were any bugs observed? Describe them"
   c. "What design feedback did testers provide?"
3. 用户回答每个提示
4. 技能根据答案编译报告并询问 "May I write"
5. 报告在批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 至少询问 3 个引导问题（每个主要部分一个）
- [ ] 所有部分都有输入后才创建报告（或用户显式跳过）
- [ ] 文件写入后裁决为 COMPLETE

---

### 用例 3：多个测试人员 —— 带多数/少数注释的汇总反馈

**测试夹具：**
- 用户提供来自 3 个测试人员的笔记
- 2/3 的测试人员发现控件"intuitive"
- 1/3 的测试人员发现 UI 字体太小
- 所有 3 个都注意到相同的错误（玩家卡在悬崖上）

**输入：** `/playtest-report`（3 人会话）

**预期行为：**
1. 技能识别输入中的 3 个不同测试人员视角
2. 控件直观性 → 标记为 "Majority (2/3): controls intuitive"
3. 字体大小 → 标记为 "Minority (1/3): UI font size concern"
4. 卡在悬崖上的错误 → 标记为 "All testers: player stuck on ledge (confirmed)"
5. 技能生成带有多数/少数标签的汇总报告
6. 报告在 "May I write" 批准后写入；裁决为 COMPLETE

**断言：**
- [ ] 多数意见 (2/3) 被标记为多数
- [ ] 少数意见 (1/3) 被标记为少数
- [ ] 一致报告的错误被标记为所有测试人员确认
- [ ] 裁决为 COMPLETE

---

### 用例 4：错误匹配现有报告 —— 链接到现有文件

**测试夹具：**
- `production/bugs/bug-2026-03-30-player-stuck-ledge.md` 存在
- 用户的试玩笔记描述了 "player gets stuck on ledges near walls"

**输入：** `/playtest-report`

**预期行为：**
1. 技能组织报告并识别卡在悬崖上的错误
2. 技能扫描 `production/bugs/` 并找到 `bug-2026-03-30-player-stuck-ledge.md`
3. 在 Bugs 部分，报告包含："See existing report: production/bugs/bug-2026-03-30-player-stuck-ledge.md"
4. 技能不建议为此问题创建新的错误报告
5. 报告已写入；裁决为 COMPLETE

**断言：**
- [ ] 试玩报告中找到并链接了现有的错误报告
- [ ] 对于已报告的问题不建议 `/bug-report`
- [ ] Bugs 部分出现了对现有文件的交叉引用
- [ ] 裁决为 COMPLETE

---

### 用例 5：总监关卡检查 —— 无关卡；CD-PLAYTEST 是单独调用

**测试夹具：**
- 提供了试玩笔记

**输入：** `/playtest-report`

**预期行为：**
1. 技能生成并写入试玩报告
2. 不生成总监代理（此处不调用 CD-PLAYTEST）
3. 输出中不出现关卡 ID

**断言：**
- [ ] 未调用总监关卡
- [ ] 未出现 CD-PLAYTEST 关卡跳过消息
- [ ] 裁决为 COMPLETE，无任何关卡检查

---

## 协议合规性

- [ ] 将输出结构化为所有 4 个部分（Feel、Bugs、Design Feedback、Next Steps）
- [ ] 涉及多个测试人员时标记多数 vs. 少数意见
- [ ] 错误匹配时交叉引用现有的错误报告
- [ ] 在写入前询问 "May I write to `production/qa/playtest-[date].md`?"
- [ ] 报告写入时裁决为 COMPLETE

---

## 覆盖说明

- CD-PLAYTEST 总监关卡（creative director 审查试玩洞察以进行设计影响）是单独调用，不在此处测试。
- 视频录制或截图附件未测试；报告是纯文本文档。
- 测试人员身份未知（匿名反馈）的情况遵循与用例 3 相同的汇总模式，但无测试人员标签。
