# Skill Test Spec: /release-checklist

## Skill Summary

`/release-checklist` 生成内部发布就绪检查清单，涵盖：sprint 故事完成情况、开放 bug 严重程度、QA 签核状态、构建稳定性和变更日志就绪状态。它是一个内部关卡 — 不是平台/商店检查清单（那是 `/launch-checklist`）。当存在先前的发布检查清单时，它会显示已解决和新引入问题的差异。

该技能将其检查清单报告写入 `production/releases/release-checklist-[date].md`，在 “May I write” 询问之后。没有导演关卡适用 — `/gate-check` 处理正式阶段关卡逻辑。裁决：RELEASE READY、RELEASE BLOCKED 或 CONCERNS。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：RELEASE READY、RELEASE BLOCKED、CONCERNS
- [ ] 在写入报告前包含 “May I write” 协作协议语言
- [ ] 具有下一步交接（例如，外部的 `/launch-checklist` 或阶段的 `/gate-check`）

---

## Director Gate Checks

无。`/release-checklist` 是一个内部审计工具。正式阶段推进由 `/gate-check` 管理。

---

## Test Cases

### Case 1: Happy Path — 所有 Sprint 故事完成，QA 通过，RELEASE READY

**Fixture:**
- `production/sprints/sprint-008.md` — 所有故事都是 `Status: Done`
- `production/bugs/` 中没有严重程度为 HIGH 或 CRITICAL 的开放 bug
- `production/qa/qa-plan-sprint-008.md` 具有 QA 签核注释
- 此版本的变更日志条目存在
- `production/stage.txt` 包含 `Polish`

**Input:** `/release-checklist`

**Expected behavior:**
1. 技能读取 sprint-008：所有故事 Done
2. 技能读取 bug：没有 HIGH 或 CRITICAL 开放 bug
3. 技能确认 QA 计划有签核
4. 技能确认变更日志条目存在
5. 所有检查通过；技能询问 “May I write to `production/releases/release-checklist-2026-04-06.md`?”
6. 报告写入；裁决是 RELEASE READY

**Assertions:**
- [ ] 评估所有 4 个检查类别（故事、bug、QA、变更日志）
- [ ] 所有项目带有 PASS 标记出现
- [ ] 裁决是 RELEASE READY
- [ ] 写入前询问 “May I write”

---

### Case 2: Open HIGH Severity Bugs — RELEASE BLOCKED

**Fixture:**
- 所有 sprint 故事都是 Done
- `production/bugs/` 包含 2 个严重程度为 HIGH 的开放 bug

**Input:** `/release-checklist`

**Expected behavior:**
1. 技能读取 sprint — 故事完成
2. 技能读取 bug — 2 个 HIGH 严重程度 bug 开放
3. 技能报告：“RELEASE BLOCKED — 2 open HIGH severity bugs must be resolved”
4. 两个 bug 文件名在报告中列出
5. 裁决是 RELEASE BLOCKED

**Assertions:**
- [ ] 裁决是 RELEASE BLOCKED（不是 CONCERNS）
- [ ] 两个 bug 文件名明确列出
- [ ] 技能明确说明 HIGH 严重程度 bug 是阻塞性的（不是建议性的）

---

### Case 3: Changelog Not Generated — CONCERNS

**Fixture:**
- 所有故事 Done，没有 HIGH/CRITICAL bug
- 未找到当前版本/sprint 的变更日志条目

**Input:** `/release-checklist`

**Expected behavior:**
1. 技能检查所有项目
2. 变更日志检查失败：未找到变更日志条目
3. 技能报告：“CONCERNS — Changelog not generated for this release”
4. 技能建议运行 `/changelog` 以生成它
5. 裁决是 CONCERNS（建议性 — 不是硬性阻塞）

**Assertions:**
- [ ] 裁决是 CONCERNS（不是 RELEASE BLOCKED — 变更日志是建议性的）
- [ ] 建议 `/changelog` 作为补救措施
- [ ] 报告中显示其他通过的检查
- [ ] 缺少变更日志被描述为建议性，而非阻塞性

---

### Case 4: Previous Release Checklist Exists — Delta From Last Release

**Fixture:**
- `production/releases/release-checklist-2026-03-20.md` 存在
- 先前：1 个故事未完成，1 个 HIGH bug 开放
- 当前：所有故事 Done，HIGH bug 已解决，但出现 1 个 MEDIUM bug

**Input:** `/release-checklist`

**Expected behavior:**
1. 技能找到先前的检查清单并加载它
2. 生成新检查清单并比较：
   - 新解决的：“Story [X] — was open, now Done”
   - 新解决的：“HIGH bug [filename] — was open, now closed”
   - 新项目：“1 MEDIUM bug appeared (advisory)”
3. 差异部分突出显示所有变化
4. 裁决是 CONCERNS（MEDIUM bug 是建议性，不是阻塞性）

**Assertions:**
- [ ] 报告中出现差异部分，包含已解决和新项目
- [ ] 注明先前检查清单中新解决的项目
- [ ] 突出显示先前检查清单中不存在的新项目
- [ ] 裁决反映当前状态（不是先前状态）

---

### Case 5: Director Gate Check — 无关卡；release-checklist 是一个内部审计

**Fixture:**
- 具有故事和 bug 报告的活动 sprint

**Input:** `/release-checklist`

**Expected behavior:**
1. 技能运行完整检查清单并写入报告
2. 不生成导演 Agent
3. 输出中不出现关卡 ID

**Assertions:**
- [ ] 不调用导演关卡
- [ ] 不出现关卡跳过消息
- [ ] 裁决是 RELEASE READY、RELEASE BLOCKED 或 CONCERNS — 无关卡裁决

---

## Protocol Compliance

- [ ] 检查 sprint 故事完成状态
- [ ] 检查开放 bug 严重程度（CRITICAL/HIGH = BLOCKED；MEDIUM/LOW = CONCERNS）
- [ ] 检查 QA 计划签核状态
- [ ] 检查变更日志存在性
- [ ] 当存在先前检查清单时进行比较
- [ ] 在写入报告前询问 “May I write”
- [ ] 裁决是 RELEASE READY、RELEASE BLOCKED 或 CONCERNS

---

## Coverage Notes

- 构建稳定性验证（没有失败的 CI 运行）被列为检查类别，但依赖于外部 CI 系统状态；如果未配置 CI 集成，技能将其记为 MANUAL CHECK。
- CRITICAL bug 总是导致 RELEASE BLOCKED，无论其他项目如何；这等效于案例 2 中的 HIGH 严重程度情况。
- 具有 `Status: In Review`（非 Done）的故事被视为未完成，并导致 RELEASE BLOCKED；此边缘情况遵循与 HIGH bug 情况相同的模式。