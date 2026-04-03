#!/bin/bash
set -e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$SKILLS_DIR/claude-skills"

# If running from a downloaded release (script is inside the archive)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/tdd/SKILL.md" ]; then
    echo "Installing from local archive..."
    mkdir -p "$SKILLS_DIR"
    cp -r "$SCRIPT_DIR" "$REPO_DIR" 2>/dev/null || true
else
    echo "Cloning claude-skills..."
    mkdir -p "$SKILLS_DIR"
    if [ -d "$REPO_DIR/.git" ]; then
        cd "$REPO_DIR" && git pull
    else
        git clone https://github.com/cestercian/claude-skills.git "$REPO_DIR"
    fi
fi

# Create symlink for each skill
ln -sf "$REPO_DIR/tdd" "$SKILLS_DIR/tdd"

echo ""
echo "Installed skills:"
echo "  /tdd  — Test-driven development workflow"
echo ""
echo "Restart Claude Code to activate. Then use: /tdd <your feature spec>"
