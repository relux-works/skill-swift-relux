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

The installed copy is degitized and independent of the source checkout. Setup
repairs stale or incomplete copies and verifies source-to-installed parity plus
every local resource linked from `SKILL.md`. Run `./setup.sh --verify-only` to
detect drift without repairing it.

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

- `snippets/dispatch-runtime-selection.md`
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
| Installer regression test | Exercise setup in isolated temporary directories | `./tests/setup_test.sh` | Temporary files under `${TMPDIR:-/tmp}`; removed on exit |
| Skill validator | Validate skill metadata and structure | `python3 -m venv .temp/skill-validator && .temp/skill-validator/bin/pip install pyyaml && .temp/skill-validator/bin/python "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-creator/scripts/quick_validate.py" .` | Validation result on stdout; environment under `.temp/skill-validator/` |
| `task-board` | Track implementation and review work | `task-board q --format compact 'summary()'` | `.task-board/` |
| `agents-infra` | Install project-local agent runtime and preserve primary-session policy | `agents-infra setup local --project-dir "$PWD" --source-dir /path/to/relux-agents-infra` | Runtime under `.agents/`, `.claude/`, `.codex/`, and `.local/`; tracked policy in `.agents/.configs/project-config.toml` |
