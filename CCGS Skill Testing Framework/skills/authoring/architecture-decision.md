# Skill Test Spec: /architecture-decision

## Skill Summary

`/architecture-decision` 引导用户逐节编写新的 Architecture Decision Record (ADR)。必需的部分包括：Status、Context、Decision、Consequences、Alternatives 和 Related ADRs。该技能还会从 `docs/engine-reference/` 中提取引擎版本参考并加盖到 ADR 中，以便追溯。

在 `full` 审查模式下，ADR 草案完成后会生成 TD-ADR (technical-director) 和 LP-FEASIBILITY (lead-programmer) 门控代理。如果两个门控都返回 APPROVED，ADR 状态将设置为 Accepted。在 `lean` 或 `solo` 模式下，两个门控都会被跳过，ADR 将以 Status: Proposed 写入。该技能在编写过程中会按节询问 "May I write"。ADR 被写入 `docs/architecture/adr-NNN-[name].md`。

---

## Static Assertions (Structural)

由 `/skill-test static` 自动验证 — 无需夹具。

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keywords: ACCEPTED, PROPOSED, CONCERNS
- [ ] Contains "May I write" collaborative protocol language (per-section approval)
- [ ] Has a next-step handoff at the end
- [ ] Documents gate behavior: TD-ADR + LP-FEASIBILITY in full mode; skipped in lean/solo
- [ ] Documents that ADR status is Accepted (full, gates approve) or Proposed (otherwise)
- [ ] Mentions engine version stamp from `docs/engine-reference/`

---

## Director Gate Checks

在 `full` 模式下：ADR 草案完成后会生成 TD-ADR (technical-director) 和 LP-FEASIBILITY (lead-programmer)。如果两者都返回 APPROVED，ADR 状态将设置为 Accepted。如果任一返回 CONCERNS 或 FAIL，ADR 保持 Proposed。

在 `lean` 模式下：两个门控都被跳过。ADR 以 Status: Proposed 写入。输出注释："TD-ADR skipped — lean mode" 和 "LP-FEASIBILITY skipped — lean mode"。

在 `solo` 模式下：两个门控都被跳过。ADR 以 Status: Proposed 写入。

---

## Test Cases

### Case 1: Happy Path — New ADR for rendering approach, full mode, gates approve

**Fixture:**
- `docs/architecture/` 存在，没有现有的渲染 ADR
- `docs/engine-reference/[engine]/VERSION.md` 存在
- `production/session-state/review-mode.txt` 包含 `full`

**Input:** `/architecture-decision rendering-approach`

**Expected behavior:**
1. Skill guides user through each required section (Status, Context, Decision, Consequences, Alternatives, Related ADRs)
2. Engine version is stamped into the ADR from `docs/engine-reference/`
3. For each section: draft shown, "May I write this section?" asked, approved
4. After all sections: TD-ADR and LP-FEASIBILITY gates spawn in parallel
5. Both gates return APPROVED
6. ADR Status is set to Accepted
7. Skill writes `docs/architecture/adr-NNN-rendering-approach.md`
8. `docs/architecture/tr-registry.yaml` updated if new TR-IDs are defined

**Assertions:**
- [ ] All 6 required sections are authored and written
- [ ] Engine version reference is stamped in the ADR
- [ ] TD-ADR and LP-FEASIBILITY spawn in parallel (not sequentially)
- [ ] ADR Status is Accepted when both gates return APPROVED in full mode
- [ ] "May I write" is asked per section during authoring
- [ ] File is written to `docs/architecture/adr-NNN-[name].md`

---

### Case 2: Failure Path — TD-ADR returns CONCERNS

**Fixture:**
- ADR draft is complete (all sections filled)
- `production/session-state/review-mode.txt` contains `full`
- TD-ADR gate returns CONCERNS: "The decision does not address [specific concern]"

**Input:** `/architecture-decision [topic]`

**Expected behavior:**
1. TD-ADR gate spawns and returns CONCERNS with specific feedback
2. Skill surfaces the concerns to the user
3. ADR Status remains Proposed (not Accepted)
4. User is asked: revise the decision to address concerns, or accept as Proposed
5. ADR is written with Status: Proposed if concerns are not resolved

**Assertions:**
- [ ] TD-ADR concerns are shown to the user verbatim
- [ ] ADR Status is Proposed (not Accepted) when TD-ADR returns CONCERNS
- [ ] Skill does NOT set Status: Accepted while CONCERNS are unresolved
- [ ] User is given the option to revise and re-run the gate

---

### Case 3: Lean Mode — Both gates skipped; ADR written as Proposed

**Fixture:**
- `production/session-state/review-mode.txt` contains `lean`
- ADR draft is authored for a new technical decision

**Input:** `/architecture-decision [topic]`

**Expected behavior:**
1. Skill guides user through all 6 sections
2. After draft is complete: both TD-ADR and LP-FEASIBILITY are skipped
3. Output notes: "TD-ADR skipped — lean mode" and "LP-FEASIBILITY skipped — lean mode"
4. ADR is written with Status: Proposed (not Accepted, since gates did not approve)
5. "May I write" is still asked before the final file write

**Assertions:**
- [ ] Both gate skip notes appear in output
- [ ] ADR Status is Proposed (not Accepted) in lean mode
- [ ] "May I write" is still asked before writing the file
- [ ] Skill writes the ADR after user approval

---

### Case 4: Edge Case — ADR already exists for this topic

**Fixture:**
- `docs/architecture/` contains an existing ADR covering the same topic
- The existing ADR has Status: Accepted

**Input:** `/architecture-decision [same-topic]`

**Expected behavior:**
1. Skill detects an existing ADR covering the same topic
2. Skill asks: "An ADR for [topic] already exists ([filename]). Update it, or create a new superseding ADR?"
3. User selects update or supersede
4. Skill does NOT silently create a duplicate ADR

**Assertions:**
- [ ] Skill detects the existing ADR before authoring begins
- [ ] User is offered update or supersede options — no silent duplicate
- [ ] If update: skill opens the existing ADR for section-by-section revision
- [ ] If supersede: new ADR references the superseded one in Related ADRs section

---

### Case 5: Director Gate — Status set correctly based on mode and gate outcome

**Fixture:**
- ADR draft is complete
- Two scenarios: (a) full mode, both gates APPROVED; (b) full mode, one gate CONCERNS

**Full mode, both APPROVED:**
- ADR Status is set to Accepted

**Assertions (both approved):**
- [ ] ADR frontmatter/header shows `Status: Accepted`
- [ ] Both TD-ADR and LP-FEASIBILITY appear as APPROVED in output

**Full mode, one gate returns CONCERNS:**
- ADR Status stays Proposed

**Assertions (CONCERNS):**
- [ ] ADR frontmatter/header shows `Status: Proposed`
- [ ] Concerns are listed in output
- [ ] Skill does NOT set Status: Accepted when any gate returns CONCERNS

**Lean/solo mode:**
- ADR Status is always Proposed regardless of content quality

**Assertions (lean/solo):**
- [ ] ADR Status is Proposed in lean mode
- [ ] ADR Status is Proposed in solo mode
- [ ] No gate output appears in lean or solo mode

---

## Protocol Compliance

- [ ] All 6 required sections authored before gate review
- [ ] Engine version stamped in ADR from `docs/engine-reference/`
- [ ] "May I write" asked per section during authoring
- [ ] TD-ADR and LP-FEASIBILITY spawn in parallel in full mode
- [ ] Skipped gates noted by name and mode in lean/solo output
- [ ] ADR Status: Accepted only when full mode AND both gates APPROVED
- [ ] Ends with next-step handoff: `/architecture-review` or `/create-control-manifest`

---

## Coverage Notes

- ADR numbering (auto-incrementing NNN) is not independently fixture-tested —
  the skill reads existing ADR filenames to assign the next number.
- Related ADRs section linking (supersedes / related-to) is tested structurally
  via Case 4 but not all link types are individually verified.
- The TR-registry update (when new TR-IDs are defined in the ADR) is part of the
  write phase — tested implicitly via Case 1.