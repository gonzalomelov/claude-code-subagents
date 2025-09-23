# Claude Code Subagents

A collection of specialized subagents for Claude Code.

## 📁 Structure

- `agents/` - Specialized Claude subagents for specific tasks
- `commands/` - Custom slash commands for GitHub and product workflows  
- `hooks/` - Event hooks for Claude Code

## 🚀 Installation

To use these components in another Claude Code repository:

```bash
# From this repository
./install.sh /path/to/your/project

# Or from your target project
/path/to/claude-code-subagents/install.sh
```

The script uses `rsync` to:

- Sync agents, commands, and hooks directories
- Preserve file permissions (important for executable hooks)
- Detect and warn about local changes that would be overwritten
- Install doc-reviewer dependencies to `~/.claude/agents/doc-reviewer/`

## 📦 Components

### Agents

- `doc-reviewer` - Documentation review specialist
- `conversation-historian` - Lists recent Claude Code conversations

### Commands

- `/gh-pr-create` - Create GitHub pull requests
- `/gh-issue-create` - Create GitHub issues
- `/plan-github-task` - Plan GitHub task implementation
- `/solve-github-task` - Solve GitHub tasks
- `/implement-github-pr` - Implement GitHub PR requirements
- `/fix-github-issue` - Fix GitHub issues
- `/plan-product-idea` - Plan product ideas

### Hooks

- `inject-time.py` - Injects current time into prompts

### Scripts

- `conversation-jsonl-to-csv/` - Convert Claude Code conversation files (80-97% size reduction)
  - `jsonl-to-csv.py` - Core conversion script with smart trimming
  - `watch-and-convert.sh` - Real-time file watcher
  - `batch-convert-all.sh` - Bulk processor

## ⚙️ Configuration

After syncing, configure hooks in Claude Code settings:

1. Open Claude Code settings
2. Navigate to Hooks section
3. Add hook paths from your project's `hooks/` directory

## 📄 License

MIT © Gonzalo Melo
