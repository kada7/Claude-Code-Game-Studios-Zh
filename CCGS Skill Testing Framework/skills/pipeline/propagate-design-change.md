# Skill Test Spec: /propagate-design-change

## Skill Summary

`/propagate-design-change` 处理 GDD 修订的级联影响。当 GDD 更新时，该技能追踪所有引用它的下游工件：ADRs、TR-registry 条目、stories 和 epics。它生成一个结构化影响报告，显示需要更改的内容及原因。该技能不会自动应用更改——它会为每个受影响的工件提出编辑建议，并在进行任何修改前针对每个工件询问"我可以写入吗"。

该技能在分析阶段是只读的，在更新阶段针对每个工件进行写入门控。它没有 director gates——分析本身是机械追踪，而非创意审查。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证——无需 fixture。

- [ ] 具有必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 具有 ≥2 个阶段标题
- [ ] 包含裁决关键词：COMPLETE、BLOCKED、NO IMPACT
- [ ] 包含"我可以写入吗"协作协议语言（针对每个工件的批准）
- [ ] 在末尾有下一步交接
- [ ] 记录更改是提议的，而非自动应用

---

## Director Gate Checks

没有 director gates——该技能在分析期间不会生成任何 director gate agents。影响报告是机械追踪操作；在分析阶段不需要创意或技术 director 审查。

---

## Test Cases

### Case 1: Happy Path — GDD revision affects 2 stories and 1 epic

**Fixture:**
- `design/gdd/[system].md` 存在且最近已修订（git diff 显示更改）
- `production/epics/[layer]/EPIC-[system].md` 引用此 GDD
- 2 个 story 文件引用此 GDD 的 TR-IDs
- 更改的 GDD 部分影响两个 story 的验收标准

**Input:** `/propagate-design-change design/gdd/[system].md`

**Expected behavior:**
1. 技能读取修订后的 GDD 并识别更改内容（git diff 或内容比较）
2. 技能扫描 ADRs、TR-registry、epics 和 stories 中对此 GDD 的引用
3. 技能生成影响报告：1 个 epic 受影响，2 个 stories 受影响
4. 技能显示每个工件的建议更改
5. 针对每个工件：单独询问"我可以更新 [filepath] 吗？"
6. 仅在获得每个工件的批准后应用更改

**Assertions:**
- [ ] Impact report identifies all 3 affected artifacts (1 epic + 2 stories)
- [ ] Each affected artifact's proposed change is shown before asking to write
- [ ] "May I write" is asked per artifact (not once for all artifacts)
- [ ] Skill does NOT apply any changes without per-artifact approval
- [ ] Verdict is COMPLETE after all approved changes are applied

---

### Case 2: No Impact — Changed GDD has no downstream references

**Fixture:**
- `design/gdd/[system].md` exists and has been revised
- No ADRs, stories, or epics reference this GDD's TR-IDs or GDD path

**Input:** `/propagate-design-change design/gdd/[system].md`

**Expected behavior:**
1. 技能读取修订后的 GDD
2. 技能扫描所有 ADRs、stories 和 epics 中的引用
3. 未找到引用
4. 技能输出："No downstream impact found for [system].md — no artifacts reference this GDD."
5. 不执行任何写入操作

**Assertions:**
- [ ] Skill outputs the "No downstream impact found" message
- [ ] Verdict is NO IMPACT
- [ ] No "May I write" asks are issued (nothing to update)
- [ ] Skill does NOT error or crash when no references are found

---

### Case 3: In-Progress Story Warning — Referenced story is currently being developed

**Fixture:**
- A story referencing this GDD has `Status: In Progress`
- The developer has already started implementing this story

**Input:** `/propagate-design-change design/gdd/[system].md`

**Expected behavior:**
1. 技能将 In Progress story 识别为受影响的工件
2. 技能输出提升的警告："CAUTION: [story-file] is currently In Progress — a developer may be working on this. Coordinate before updating."
3. 警告出现在该 story 的"我可以写入吗"询问之前的影响报告中
4. 用户仍然可以批准或跳过该 story 的更新

**Assertions:**
- [ ] In Progress story is flagged with an elevated warning (distinct from regular affected-artifact entries)
- [ ] Warning appears before the "May I write" ask for that story
- [ ] Skill still offers to update the story — the warning does not block the option
- [ ] Other (non-In-Progress) artifacts are not affected by this warning

---

### Case 4: Edge Case — No argument provided

**Fixture:**
- Multiple GDDs exist in `design/gdd/`

**Input:** `/propagate-design-change` (no argument)

**Expected behavior:**
1. 技能检测到未提供参数
2. 技能输出使用错误："No GDD specified. Usage: /propagate-design-change design/gdd/[system].md"
3. 技能列出最近修改的 GDDs 作为建议（git log）
4. 不执行分析

**Assertions:**
- [ ] Skill outputs a usage error when no argument is given
- [ ] Usage example is shown with the correct path format
- [ ] No impact analysis is performed without a target GDD
- [ ] Skill does NOT silently pick a GDD without user input

---

### Case 5: Director Gate — No gate spawned regardless of review mode

**Fixture:**
- A GDD has been revised with downstream references
- `production/session-state/review-mode.txt` exists with `full`

**Input:** `/propagate-design-change design/gdd/[system].md`

**Expected behavior:**
1. 技能读取 GDD 并追踪下游引用
2. 技能不会读取 `production/session-state/review-mode.txt`
3. 在任何阶段都不会生成 director gate agents
4. 生成影响报告并按工件批准正常进行

**Assertions:**
- [ ] No director gate agents are spawned (no CD-, TD-, PR-, AD- prefixed gates)
- [ ] Skill does NOT read `production/session-state/review-mode.txt`
- [ ] Output contains no "Gate: [GATE-ID]" or gate-skipped entries
- [ ] Review mode has no effect on this skill's behavior

---

## Protocol Compliance

- [ ] 在生成影响报告前读取修订后的 GDD 和所有可能受影响的工件
- [ ] 在任何"我可以写入吗"询问前完整显示影响报告
- [ ] 针对每个工件询问"我可以写入吗"——从不一次性询问整个集合
- [ ] 在批准询问前标记 In Progress stories 并显示提升的警告
- [ ] 没有 director gates——不读取 review-mode.txt
- [ ] 以适合裁决（COMPLETE 或 NO IMPACT）的下一步交接结束

---

## Coverage Notes

- ADR 影响（当 GDD 更改需要 ADR 更新或新 ADR 时）遵循与 story/epic 更新相同的按工件批准模式——未独立进行 fixture 测试。
- TR-registry 影响（当更改的 GDD 需要新的或更新的 TR-IDs 时）是分析阶段的一部分，但未独立进行 fixture 测试。
- git diff 比较方法（检测 GDD 中的更改内容）是运行时关注点——fixtures 使用预先安排的内容差异。