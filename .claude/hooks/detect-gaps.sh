#!/bin/bash
# 钩子：detect-gaps.sh
# 事件：SessionStart
# 目的：当代码/原型存在时检测缺失的文档
# 跨平台：兼容 Windows Git Bash（使用 grep -E，而非 -P）

# 出错时退出以进行调试（但不会使会话失败）
set +e

echo "=== Checking for Documentation Gaps ==="

# --- 检查 0：新项目检测（建议 /start） ---
FRESH_PROJECT=true

# 检查引擎是否已配置
if [ -f ".claude/docs/technical-preferences.md" ]; then
  ENGINE_LINE=$(grep -E "^\- \*\*Engine\*\*:" .claude/docs/technical-preferences.md 2>/dev/null)
  if [ -n "$ENGINE_LINE" ] && ! echo "$ENGINE_LINE" | grep -q "TO BE CONFIGURED" 2>/dev/null; then
    FRESH_PROJECT=false
  fi
fi

# 检查游戏概念是否存在
if [ -f "design/gdd/game-concept.md" ]; then
  FRESH_PROJECT=false
fi

# 检查源代码是否存在
if [ -d "src" ]; then
  SRC_CHECK=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | head -1)
  if [ -n "$SRC_CHECK" ]; then
    FRESH_PROJECT=false
  fi
fi

if [ "$FRESH_PROJECT" = true ]; then
  echo ""
  echo "🚀 NEW PROJECT: No engine configured, no game concept, no source code."
  echo "   This looks like a fresh start! Run: /start"
  echo ""
  echo "💡 To get a comprehensive project analysis, run: /project-stage-detect"
  echo "==================================="
  exit 0
fi

# --- 检查 1：大量代码库但设计文档稀疏 ---
if [ -d "src" ]; then
  # Count source files (cross-platform, handles Windows paths)
  SRC_FILES=$(find src -type f \( -name "*.gd" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l)
else
  SRC_FILES=0
fi

if [ -d "design/gdd" ]; then
  DESIGN_FILES=$(find design/gdd -type f -name "*.md" 2>/dev/null | wc -l)
else
  DESIGN_FILES=0
fi

# 标准化 wc 输出的空白字符
SRC_FILES=$(echo "$SRC_FILES" | tr -d ' ')
DESIGN_FILES=$(echo "$DESIGN_FILES" | tr -d ' ')

if [ "$SRC_FILES" -gt 50 ] && [ "$DESIGN_FILES" -lt 5 ]; then
  echo "⚠️  GAP: Substantial codebase ($SRC_FILES source files) but sparse design docs ($DESIGN_FILES files)"
  echo "    Suggested action: /reverse-document design src/[system]"
  echo "    Or run: /project-stage-detect to get full analysis"
fi

# --- 检查 2：无文档的原型 ---
if [ -d "prototypes" ]; then
  PROTOTYPE_DIRS=$(find prototypes -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  UNDOCUMENTED_PROTOS=()

  if [ -n "$PROTOTYPE_DIRS" ]; then
    while IFS= read -r proto_dir; do
      # Normalize path separators for Windows
      proto_dir=$(echo "$proto_dir" | sed 's|\\|/|g')

      # Check for README.md or CONCEPT.md
      if [ ! -f "${proto_dir}/README.md" ] && [ ! -f "${proto_dir}/CONCEPT.md" ]; then
        proto_name=$(basename "$proto_dir")
        UNDOCUMENTED_PROTOS+=("$proto_name")
      fi
    done <<< "$PROTOTYPE_DIRS"

    if [ ${#UNDOCUMENTED_PROTOS[@]} -gt 0 ]; then
      echo "⚠️  GAP: ${#UNDOCUMENTED_PROTOS[@]} undocumented prototype(s) found:"
      for proto in "${UNDOCUMENTED_PROTOS[@]}"; do
        echo "    - prototypes/$proto/ (no README or CONCEPT doc)"
      done
      echo "    Suggested action: /reverse-document concept prototypes/[name]"
    fi
  fi
fi

# --- 检查 3：无架构文档的核心系统 ---
if [ -d "src/core" ] || [ -d "src/engine" ]; then
  if [ ! -d "docs/architecture" ]; then
    echo "⚠️  GAP: Core engine/systems exist but no docs/architecture/ directory"
    echo "    Suggested action: Create docs/architecture/ and run /architecture-decision"
  else
    ADR_COUNT=$(find docs/architecture -type f -name "*.md" 2>/dev/null | wc -l)
    ADR_COUNT=$(echo "$ADR_COUNT" | tr -d ' ')

    if [ "$ADR_COUNT" -lt 3 ]; then
      echo "⚠️  GAP: Core systems exist but only $ADR_COUNT ADR(s) documented"
      echo "    Suggested action: /reverse-document architecture src/core/[system]"
    fi
  fi
fi

# --- 检查 4：无设计文档的游戏玩法系统 ---
if [ -d "src/gameplay" ]; then
  # Find major gameplay subdirectories (those with 5+ files)
  GAMEPLAY_SYSTEMS=$(find src/gameplay -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

  if [ -n "$GAMEPLAY_SYSTEMS" ]; then
    while IFS= read -r system_dir; do
      system_dir=$(echo "$system_dir" | sed 's|\\|/|g')
      system_name=$(basename "$system_dir")
      file_count=$(find "$system_dir" -type f 2>/dev/null | wc -l)
      file_count=$(echo "$file_count" | tr -d ' ')

      # If system has 5+ files, check for corresponding design doc
      if [ "$file_count" -ge 5 ]; then
        # Check for design doc (allow variations: combat-system.md, combat.md)
        design_doc_1="design/gdd/${system_name}-system.md"
        design_doc_2="design/gdd/${system_name}.md"

        if [ ! -f "$design_doc_1" ] && [ ! -f "$design_doc_2" ]; then
          echo "⚠️  GAP: Gameplay system 'src/gameplay/$system_name/' ($file_count files) has no design doc"
          echo "    Expected: design/gdd/${system_name}-system.md or design/gdd/${system_name}.md"
          echo "    Suggested action: /reverse-document design src/gameplay/$system_name"
        fi
      fi
    done <<< "$GAMEPLAY_SYSTEMS"
  fi
fi

# --- 检查 5：生产计划 ---
if [ "$SRC_FILES" -gt 100 ]; then
  # For projects with substantial code, check for production planning
  if [ ! -d "production/sprints" ] && [ ! -d "production/milestones" ]; then
    echo "⚠️  GAP: Large codebase ($SRC_FILES files) but no production planning found"
    echo "    Suggested action: /sprint-plan or create production/ directory"
  fi
fi

# --- 摘要 ---
echo ""
echo "💡 To get a comprehensive project analysis, run: /project-stage-detect"
echo "==================================="

exit 0
