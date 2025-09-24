#!/usr/bin/env bash
set -euo pipefail

# Install agents, commands, and hooks from this repo to a target repository
# Usage: ./install.sh [TARGET_REPO_PATH]
# Example: ./install.sh ~/projects/my-project

SRC_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DST_BASE="${1:-$PWD}"
RSYNC="${RSYNC:-rsync}"

# Prefer newer rsync on macOS if available
for CAND in /opt/homebrew/bin/rsync /usr/local/bin/rsync; do
  command -v "$CAND" >/dev/null 2>&1 && RSYNC="$CAND"
done

# Validate destination
[[ -d "$DST_BASE" ]] || { echo "Destination not found: $DST_BASE" >&2; exit 1; }
[[ -n "${DST_BASE:-}" && "$DST_BASE" != "/" ]] || { echo "Refusing DST_BASE='$DST_BASE'"; exit 1; }

# Common noise to ignore
EXCLUDES=(--exclude '.git/' --exclude '.DS_Store' --exclude 'Thumbs.db' --exclude '__pycache__/' --exclude '*.pyc')

# Components to sync
COMPONENTS=("agents" "commands" "hooks" "scripts")

echo "🔄 Syncing Claude Code components"
echo "  From: $SRC_BASE"
echo "  To:   $DST_BASE"
echo ""

# Function to sync a component directory
sync_component() {
  local component="$1"
  local src="$SRC_BASE/$component"
  local dst="$DST_BASE/$component"
  
  # Skip if source doesn't exist
  [[ -d "$src" ]] || { echo "⚠️  Skipping $component (not found)"; return 0; }
  
  # Create destination if needed
  mkdir -p "$dst"
  
  # 1) SAFETY CHECK: Abort if destination has files that would be deleted
  local drift
  drift="$("$RSYNC" -ain --delete --itemize-changes \
    "${EXCLUDES[@]}" "$src"/ "$dst"/ 2>/dev/null | grep '^\*deleting' || true)"
  
  if [[ -n "$drift" ]]; then
    echo "❌ Error: $component directory has local files that would be deleted or overwritten:"
    echo "$drift" | head -10
    echo ""
    echo "Please backup or remove these files before running install.sh"
    echo "Or manually merge changes from: $src"
    exit 1
  fi
  
  # 2) SAFE SYNC: SRC -> DST (mirror)
  echo "📦 Syncing $component..."
  "$RSYNC" -av --delete "${EXCLUDES[@]}" "$src"/ "$dst"/
  echo "✅ $component synced"
  echo ""
}

# Sync each component
for component in "${COMPONENTS[@]}"; do
  sync_component "$component"
done

# Special handling for doc-reviewer dependencies
if [[ -d "$SRC_BASE/agents/doc-reviewer" ]]; then
  CLAUDE_HOME="$HOME/.claude/agents/doc-reviewer"
  echo "📦 Installing doc-reviewer dependencies to $CLAUDE_HOME..."
  mkdir -p "$CLAUDE_HOME"
  
  for file in output-template.md markdownlint.jsonc; do
    if [[ -f "$SRC_BASE/agents/doc-reviewer/$file" ]]; then
      cp "$SRC_BASE/agents/doc-reviewer/$file" "$CLAUDE_HOME/"
      echo "  ✅ Installed $file"
    fi
  done
  echo ""
fi

echo "🎉 Sync complete!"
echo ""
echo "Components available in: $DST_BASE"
echo "To use hooks, configure them in Claude Code settings."