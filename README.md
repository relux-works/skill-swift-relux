# skill-swift-relux

Reusable skill package for Swift codebases built on the relux-works Relux stack:
`swift-relux`, `swiftui-relux`, and `swiftui-reluxrouter`.

## Structure

```text
skill-swift-relux/
├── SKILL.md
├── instructions/
├── references/
├── snippets/
├── .task-board/
└── setup.sh
```

## Setup

```bash
git clone git@github.com:relux-works/skill-swift-relux.git
cd skill-swift-relux
./setup.sh
```

Setup installs the skill runtime into `~/.agents/skills/swift-relux` and links
it from `~/.claude/skills/swift-relux` and `~/.codex/skills/swift-relux`.

## Resource Routing

Use `SKILL.md` as the entrypoint and load only the files needed for the task.

Instruction flows:

- `instructions/app-bootstrap.md`
- `instructions/module-authoring.md`
- `instructions/ui-integration.md`
- `instructions/logout-cleanup.md`

Reference packs:

- `references/core/relux-core.md`
- `references/swiftui/swiftui-relux.md`
- `references/router/relux-router.md`
- `references/modules/module-conventions.md`
- `references/packages/package-conventions.md`
- `references/overview/micro-spec.md`

Reusable snippets:

- `snippets/ioc-registry.md`
- `snippets/modular-projecting-router.md`
- `snippets/store-cleanup.md`
- `snippets/swiftui-container-page.md`
- `snippets/temporal-state.md`
- `snippets/refreshable-perform-async.md`
- `snippets/product-analytics.md`
- `snippets/localization.md`

## Tools

| Tool | Purpose | Command | Outputs |
| --- | --- | --- | --- |
| `setup.sh` | Install the standalone skill runtime and symlink it into Claude/Codex runtime locations | `./setup.sh` | Installed copy under `~/.agents/skills/swift-relux`, symlinks under `~/.claude/skills/` and `~/.codex/skills/` |
| `zsh` | Validate installer shell syntax before release | `zsh -n setup.sh` | No artifact; exits non-zero on syntax errors |
