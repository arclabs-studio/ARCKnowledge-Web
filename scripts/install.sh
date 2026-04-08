#!/usr/bin/env bash
# install.sh — Symlink ARCKnowledge-Web skills and agents into a downstream project
#
# Usage: Run from the downstream project root:
#   bash Tools/ARCKnowledge-Web/scripts/install.sh
#
# Or with a custom path to ARCKnowledge-Web:
#   ARCKNOWLEDGE_WEB_PATH=/custom/path bash scripts/install.sh

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCKNOWLEDGE_WEB_PATH="${ARCKNOWLEDGE_WEB_PATH:-"$SCRIPT_DIR/.."}"
PROJECT_ROOT="${PROJECT_ROOT:-"$(pwd)"}"

SKILLS_SOURCE="$ARCKNOWLEDGE_WEB_PATH/.claude/skills"
AGENTS_SOURCE="$ARCKNOWLEDGE_WEB_PATH/.claude/agents"
SKILLS_TARGET="$PROJECT_ROOT/.claude/skills"
AGENTS_TARGET="$PROJECT_ROOT/.claude/agents"
MCP_SOURCE="$ARCKNOWLEDGE_WEB_PATH/.mcp.json"
MCP_TARGET="$PROJECT_ROOT/.mcp.json"
GITIGNORE="$PROJECT_ROOT/.gitignore"

# ── Helpers ────────────────────────────────────────────────────────────────────

info()    { echo "  ✓ $*"; }
warning() { echo "  ⚠ $*"; }
error()   { echo "  ✗ $*" >&2; }

# ── Validation ─────────────────────────────────────────────────────────────────

if [ ! -d "$SKILLS_SOURCE" ]; then
  error "ARCKnowledge-Web skills not found at: $SKILLS_SOURCE"
  error "Run from a downstream project root with ARCKnowledge-Web as a submodule."
  exit 1
fi

if [ ! -d "$AGENTS_SOURCE" ]; then
  error "ARCKnowledge-Web agents not found at: $AGENTS_SOURCE"
  exit 1
fi

echo ""
echo "Installing ARCKnowledge-Web into: $PROJECT_ROOT"
echo "From: $ARCKNOWLEDGE_WEB_PATH"
echo ""

# ── Create .claude directories ─────────────────────────────────────────────────

mkdir -p "$SKILLS_TARGET"
mkdir -p "$AGENTS_TARGET"

# ── Symlink Skills ─────────────────────────────────────────────────────────────

echo "Linking skills..."
SKILL_COUNT=0

for skill_dir in "$SKILLS_SOURCE"/arc-*/; do
  skill_name=$(basename "$skill_dir")
  target_link="$SKILLS_TARGET/$skill_name"

  if [ -L "$target_link" ]; then
    # Update existing symlink
    rm "$target_link"
  elif [ -d "$target_link" ]; then
    warning "Skipping $skill_name — directory exists (not a symlink). Remove manually to replace."
    continue
  fi

  ln -s "$skill_dir" "$target_link"
  info "Linked skill: $skill_name"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done

# ── Symlink Agents ─────────────────────────────────────────────────────────────

echo ""
echo "Linking agents..."
AGENT_COUNT=0

for agent_file in "$AGENTS_SOURCE"/arc-*.md; do
  agent_name=$(basename "$agent_file")
  target_link="$AGENTS_TARGET/$agent_name"

  if [ -L "$target_link" ]; then
    rm "$target_link"
  elif [ -f "$target_link" ]; then
    warning "Skipping $agent_name — file exists (not a symlink). Remove manually to replace."
    continue
  fi

  ln -s "$agent_file" "$target_link"
  info "Linked agent: $agent_name"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done

# ── Symlink DESIGN.md ─────────────────────────────────────────────────────────

echo ""
echo "Linking DESIGN.md..."
DESIGN_SOURCE="$ARCKNOWLEDGE_WEB_PATH/DESIGN.md"
DESIGN_TARGET="$PROJECT_ROOT/DESIGN.md"

if [ -f "$DESIGN_SOURCE" ]; then
  if [ -L "$DESIGN_TARGET" ]; then
    rm "$DESIGN_TARGET"
  fi

  if [ -f "$DESIGN_TARGET" ] && [ ! -L "$DESIGN_TARGET" ]; then
    warning "DESIGN.md already exists at project root (not a symlink) — not overwritten."
  else
    ln -s "$DESIGN_SOURCE" "$DESIGN_TARGET"
    info "Linked DESIGN.md to project root"
  fi
else
  warning "DESIGN.md not found at $DESIGN_SOURCE — skipping."
fi

# ── Copy .mcp.json (if not present) ───────────────────────────────────────────

echo ""
if [ ! -f "$MCP_TARGET" ]; then
  cp "$MCP_SOURCE" "$MCP_TARGET"
  info "Copied .mcp.json (3 servers: context7, playwright, vitest)"
else
  warning ".mcp.json already exists — not overwritten. Manually merge if needed."
fi

# ── Update .gitignore ──────────────────────────────────────────────────────────

echo ""
if [ -f "$GITIGNORE" ]; then
  GITIGNORE_MARKER="# ARCKnowledge-Web symlinks"
  if grep -q "$GITIGNORE_MARKER" "$GITIGNORE"; then
    info ".gitignore already has ARCKnowledge-Web entries"
  else
    cat >> "$GITIGNORE" << 'EOF'

# ARCKnowledge-Web symlinks
.claude/skills/arc-*
.claude/agents/arc-*.md
DESIGN.md
EOF
    info "Updated .gitignore — arc-* symlinks are not tracked"
  fi
else
  warning "No .gitignore found at project root. Create one and add .claude/skills/arc-* and .claude/agents/arc-*.md"
fi

# ── Summary ────────────────────────────────────────────────────────────────────

echo ""
echo "─────────────────────────────────────────────"
echo "ARCKnowledge-Web installation complete"
echo ""
echo "  Skills linked:  $SKILL_COUNT"
echo "  Agents linked:  $AGENT_COUNT"
echo ""
echo "Available skills (use /skill-name or let agents invoke them):"
for skill_dir in "$SKILLS_TARGET"/arc-*/; do
  echo "  /$(basename "$skill_dir")"
done
echo ""
echo "Next: Update your project's CLAUDE.md to reference ARCKnowledge-Web skills."
echo "─────────────────────────────────────────────"
echo ""
