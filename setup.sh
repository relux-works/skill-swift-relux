#!/usr/bin/env zsh

set -euo pipefail

SKILL_NAME="swift-relux"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CODEX_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
INSTALL_STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swift-relux-skill"
INSTALL_STATE="$INSTALL_STATE_DIR/install.json"

red() { print -P "%F{red}$1%f" }
green() { print -P "%F{green}$1%f" }
yellow() { print -P "%F{yellow}$1%f" }

json_escape() {
  print -rn -- "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

scrub_git_metadata() {
  local dir="$1"
  local removed=0

  if [[ ! -d "$dir" ]]; then
    return
  fi

  for rel in .git .gitignore .gitattributes .gitmodules; do
    local target="$dir/$rel"
    if [[ -e "$target" || -L "$target" ]]; then
      rm -rf "$target"
      removed=1
      green "Removed installed git metadata: $target"
    fi
  done

  if [[ "$removed" == "0" ]]; then
    green "Installed git metadata already absent: $dir"
  fi
}

install_skill_copy() {
  local agents_dest="$AGENTS_DIR/$SKILL_NAME"

  if [[ -L "$agents_dest" ]]; then
    rm -f "$agents_dest"
    yellow "Removed stale skill symlink: $agents_dest"
  fi

  mkdir -p "$agents_dest"
  rsync -a --delete "$SKILL_DIR/" "$agents_dest/" \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='.gitattributes' \
    --exclude='.gitmodules' \
    --exclude='.task-board' \
    --exclude='.temp' \
    --exclude='task-board.config.json' \
    --exclude='setup.sh' \
    --exclude='.DS_Store'

  scrub_git_metadata "$agents_dest"
  green "Copied skill -> $agents_dest/"
}

install_symlinks() {
  local agents_dest="$AGENTS_DIR/$SKILL_NAME"

  mkdir -p "$CLAUDE_DIR" "$CODEX_DIR"

  if [[ -L "$CLAUDE_DIR/$SKILL_NAME" || -e "$CLAUDE_DIR/$SKILL_NAME" ]]; then
    rm -rf "$CLAUDE_DIR/$SKILL_NAME"
  fi
  ln -s "$agents_dest" "$CLAUDE_DIR/$SKILL_NAME"
  green "Symlink: $CLAUDE_DIR/$SKILL_NAME -> $agents_dest"

  if [[ -L "$CODEX_DIR/$SKILL_NAME" || -e "$CODEX_DIR/$SKILL_NAME" ]]; then
    rm -rf "$CODEX_DIR/$SKILL_NAME"
  fi
  ln -s "$agents_dest" "$CODEX_DIR/$SKILL_NAME"
  green "Symlink: $CODEX_DIR/$SKILL_NAME -> $agents_dest"
}

write_install_state() {
  mkdir -p "$INSTALL_STATE_DIR"

  local repo installed claude codex
  repo="$(json_escape "$SKILL_DIR")"
  installed="$(json_escape "$AGENTS_DIR/$SKILL_NAME")"
  claude="$(json_escape "$CLAUDE_DIR/$SKILL_NAME")"
  codex="$(json_escape "$CODEX_DIR/$SKILL_NAME")"

  cat > "$INSTALL_STATE" <<EOF
{
  "repoPath": "$repo",
  "installedSkillPath": "$installed",
  "claudeSkillPath": "$claude",
  "codexSkillPath": "$codex"
}
EOF
  green "Install state: $INSTALL_STATE"
}

verify_install() {
  local agents_dest="$AGENTS_DIR/$SKILL_NAME"

  if [[ ! -f "$agents_dest/SKILL.md" ]]; then
    red "Install verification failed: missing $agents_dest/SKILL.md"
    exit 1
  fi

  if [[ -e "$agents_dest/.git" || -e "$agents_dest/.gitignore" || -e "$agents_dest/task-board.config.json" ]]; then
    red "Install verification failed: git/project metadata leaked into $agents_dest"
    exit 1
  fi

  if [[ ! -L "$CLAUDE_DIR/$SKILL_NAME" ]]; then
    red "Install verification failed: missing Claude symlink"
    exit 1
  fi

  if [[ ! -L "$CODEX_DIR/$SKILL_NAME" ]]; then
    red "Install verification failed: missing Codex symlink"
    exit 1
  fi

  green "Verified installed skill: $agents_dest"
}

usage() {
  print "Usage: ./setup.sh"
  print ""
  print "Installs $SKILL_NAME as a degitized copy into ~/.agents/skills and"
  print "refreshes ~/.claude/skills and ~/.codex/skills symlinks."
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

print ""
green "=== swift-relux skill setup ==="
print ""
install_skill_copy
install_symlinks
write_install_state
verify_install
print ""
green "=== Done ==="
