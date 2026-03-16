#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/commands"
HOOKS_DIR="$SCRIPT_DIR/hooks"

# --- Agent configuration ---
# Format: agent_name:target_dir
# Bash 3.2 compatible (no associative arrays)

agent_dir() {
    case "$1" in
        claude)  echo ".claude/commands" ;;
        codex)   echo ".codex/prompts" ;;
        gemini)  echo ".gemini/commands" ;;
        cursor)  echo ".cursor/commands" ;;
        copilot) echo ".github/agents" ;;
        *)       return 1 ;;
    esac
}

needs_args_transform() {
    case "$1" in
        gemini) return 0 ;;
        *)      return 1 ;;
    esac
}

# --- Functions ---

usage() {
    echo "Usage: ./init.sh <agent>"
    echo ""
    echo "Supported agents:"
    echo "  claude   .claude/commands/"
    echo "  codex    .codex/prompts/"
    echo "  gemini   .gemini/commands/"
    echo "  cursor   .cursor/commands/"
    echo "  copilot  .github/agents/"
    echo ""
    echo "Run without arguments for an interactive menu."
}

select_agent() {
    echo "Select your AI coding agent:"
    echo ""
    echo "  1) claude   (Claude Code)"
    echo "  2) codex    (OpenAI Codex CLI)"
    echo "  3) gemini   (Gemini CLI)"
    echo "  4) cursor   (Cursor)"
    echo "  5) copilot  (GitHub Copilot)"
    echo ""
    read -rp "Enter number (1-5): " choice

    case "$choice" in
        1) echo "claude" ;;
        2) echo "codex" ;;
        3) echo "gemini" ;;
        4) echo "cursor" ;;
        5) echo "copilot" ;;
        *) echo ""; return 1 ;;
    esac
}

install_commands() {
    local agent="$1"
    local rel_dir
    rel_dir="$(agent_dir "$agent")"
    local target_dir="$SCRIPT_DIR/$rel_dir"

    mkdir -p "$target_dir"

    # Find all .md files in commands/, including subdirectories
    while IFS= read -r cmd_file; do
        [ -f "$cmd_file" ] || continue

        # Preserve directory structure: commands/git/ship.md -> target/git/ship.md
        local rel_path="${cmd_file#"$COMMANDS_DIR"/}"
        local dest_dir="$target_dir/$(dirname "$rel_path")"
        mkdir -p "$dest_dir"

        if needs_args_transform "$agent"; then
            sed 's/\$ARGUMENTS/{{args}}/g' "$cmd_file" > "$dest_dir/$(basename "$cmd_file")"
        else
            cp "$cmd_file" "$dest_dir/$(basename "$cmd_file")"
        fi
    done < <(find "$COMMANDS_DIR" -name '*.md' -type f | sort)

    echo "  Commands installed to $rel_dir/"
}

install_hooks() {
    local git_hooks_dir="$SCRIPT_DIR/.git/hooks"

    if [ ! -d "$SCRIPT_DIR/.git" ]; then
        echo "  Not a git repo — skipping hook installation"
        return
    fi

    mkdir -p "$git_hooks_dir"

    for hook_file in "$HOOKS_DIR"/*; do
        [ -f "$hook_file" ] || continue
        local filename
        filename="$(basename "$hook_file")"
        cp "$hook_file" "$git_hooks_dir/$filename"
        chmod +x "$git_hooks_dir/$filename"
    done

    echo "  Git hooks installed to .git/hooks/"
}

# --- Main ---

agent=""

if [ $# -ge 1 ]; then
    agent="$1"
else
    agent=$(select_agent) || true
fi

if [ -z "$agent" ] || ! agent_dir "$agent" > /dev/null 2>&1; then
    echo "Error: unknown agent '${agent:-}'"
    echo ""
    usage
    exit 1
fi

echo ""
echo "Setting up ai-dev for $agent..."
echo ""

install_commands "$agent"
install_hooks

echo ""
echo "Done! You're set up for $agent."
echo ""
echo "Available slash commands:"
while IFS= read -r cmd_file; do
    [ -f "$cmd_file" ] || continue
    # Turn commands/git/ship.md into git:ship, commands/docs.md into docs
    local_rel="${cmd_file#"$COMMANDS_DIR"/}"
    local_name="$(echo "$local_rel" | sed 's/\.md$//' | sed 's|/|:|g')"
    echo "  /$local_name"
done < <(find "$COMMANDS_DIR" -name '*.md' -type f | sort)
