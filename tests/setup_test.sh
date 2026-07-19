#!/usr/bin/env zsh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/swift-relux-setup-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

export AGENTS_SKILLS_DIR="$TEST_ROOT/agents"
export CLAUDE_SKILLS_DIR="$TEST_ROOT/claude"
export CODEX_SKILLS_DIR="$TEST_ROOT/codex"
export XDG_CONFIG_HOME="$TEST_ROOT/config"

"$REPO_DIR/setup.sh" >/dev/null

INSTALLED="$AGENTS_SKILLS_DIR/swift-relux"
[[ -f "$INSTALLED/instructions/module-authoring.md" ]]
[[ -f "$INSTALLED/references/router/relux-router.md" ]]
[[ -f "$INSTALLED/snippets/product-analytics.md" ]]
[[ ! -e "$INSTALLED/.git" ]]
[[ ! -e "$INSTALLED/task-board.config.json" ]]
[[ ! -e "$INSTALLED/setup.sh" ]]
[[ ! -e "$INSTALLED/README.md" ]]
[[ ! -e "$INSTALLED/tests" ]]
[[ -L "$CLAUDE_SKILLS_DIR/swift-relux" ]]
[[ -L "$CODEX_SKILLS_DIR/swift-relux" ]]
[[ "$(readlink "$CLAUDE_SKILLS_DIR/swift-relux")" == "$INSTALLED" ]]
[[ "$(readlink "$CODEX_SKILLS_DIR/swift-relux")" == "$INSTALLED" ]]

# Verification must reject a skill entry linked anywhere except the installed copy.
rm "$CLAUDE_SKILLS_DIR/swift-relux"
ln -s "$TEST_ROOT/wrong-target" "$CLAUDE_SKILLS_DIR/swift-relux"
if "$REPO_DIR/setup.sh" --verify-only >/dev/null 2>&1; then
  print -u2 "verification accepted an incorrect Claude symlink target"
  exit 1
fi
"$REPO_DIR/setup.sh" >/dev/null

# Verification must reject an installed copy whose resource graph was damaged.
rm "$INSTALLED/instructions/module-authoring.md"
if "$REPO_DIR/setup.sh" --verify-only >/dev/null 2>&1; then
  print -u2 "verification accepted an incomplete installed copy"
  exit 1
fi
"$REPO_DIR/setup.sh" >/dev/null
[[ -f "$INSTALLED/instructions/module-authoring.md" ]]

print "setup installer test passed"
