# 文档目录

在此目录中创建或编辑文件时，请遵循以下标准。

## 架构决策记录 (`docs/architecture/`)

使用 ADR 模板：`.claude/docs/templates/architecture-decision-record.md`

**必需部分：** Title, Status, Context, Decision, Consequences,
ADR Dependencies, Engine Compatibility, GDD Requirements Addressed

**状态生命周期：** `Proposed` → `Accepted` → `Superseded`
- 切勿跳过 `Accepted` — 引用 `Proposed` ADR 的故事会被自动阻止
- 使用 `/architecture-decision` 通过引导流程创建 ADR

**TR 注册表：** `docs/architecture/tr-registry.yaml`
- 稳定的需求 ID（例如 `TR-MOV-001`），将 GDD 需求与故事链接
- 切勿重新编号现有 ID — 仅追加新的 ID
- 由 `/architecture-review` 第 8 阶段更新

**控制清单：** `docs/architecture/control-manifest.md`
- 扁平化的程序员规则表：每层的 Required / Forbidden / Guardrails
- 标题中包含日期戳 `Manifest Version:`
- 故事嵌入此版本；`/story-done` 检查是否过时

**验证：** 完成一组 ADR 后，运行 `/architecture-review`。

## 引擎参考 (`docs/engine-reference/`)

版本锁定的引擎 API 快照。**在使用任何引擎 API 之前，务必先检查此处** —
LLM 的训练数据早于锁定的引擎版本。

当前引擎：参见 `docs/engine-reference/godot/VERSION.md`