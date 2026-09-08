# Swift Relux agent skill

Architecture and integration guidance for Swift apps using `Relux`,
`SwiftUIRelux`, and `ReluxRouter`, with source-backed ecosystem notes.
The portable skill name is **swift-relux**; the repository is **skill-swift-relux**.
Installed directories must use the skill name.

## Install with Curator

Install [Curator](https://github.com/relux-works/curator#install), then initialize
its machine configuration once if needed:

```sh
curator bootstrap --if-missing --non-interactive --skills-root "$HOME/src/skills"
```

In the application repository, add the following declaration to `Skillfile.json`
(preserve existing skills and project settings):

```json
{
  "schema_version": 1,
  "agents": ["claude_code", "codex_cli", "opencode", "gemini", "cursor", "windsurf"],
  "skills": [
    {
      "name": "swift-relux",
      "git": "https://github.com/relux-works/skill-swift-relux.git",
      "branch": "main"
    }
  ]
}
```

```sh
curator install . --fix-gitignore
curator status . --check
```

For reproducibility, replace `branch` with `revision` containing the full reviewed
commit SHA, or `tag` naming a release containing this migration. Select exactly
one reference field. Older releases predate the context-layout fix.
An existing configured project can also use:

```sh
curator add swift-relux --git https://github.com/relux-works/skill-swift-relux.git --branch main
```

For global installation, use `curator global init` followed by
`curator global add swift-relux --git https://github.com/relux-works/skill-swift-relux.git --branch main`.
Choose global agent adapters in the global manifest/configuration. Do not run the
legacy installer over a Curator-managed copy: choose one owner per install scope.

This is a context-only package using `agent-skill.json` schema 3 with explicit
capabilities. It exports no commands, executable runtime, MCP requirements, or
skill dependencies. Swift libraries belong to the app's SwiftPM dependencies;
they are not Curator skill dependencies. Installation does not run `setup.sh`
or require Xcode. Building app code still requires its native toolchain.

## Agent compatibility

| Environment | Delivery / invocation |
| --- | --- |
| Claude Code | Curator adapter `.claude/skills/swift-relux`; `/swift-relux` |
| Codex | Curator adapter `.codex/skills/swift-relux`; `$swift-relux`; optional UI metadata in `agents/openai.yaml` |
| OpenCode | Native `.agents/skills/swift-relux` discovery; load the `swift-relux` skill |
| Pi | Current upstream supports `.agents/skills`; explicit fallback: `pi --skill .agents/skills/swift-relux` and `/skill:swift-relux` |
| Gemini CLI | Curator adapter `.gemini/skills/swift-relux` |
| Cursor | Curator adapter `.cursor/rules/swift-relux`; delivery is not proof that every Cursor version discovers this layout as a native skill |
| Windsurf | Curator uses native `.agents/skills` discovery; verify discovery in the installed agent version |
| Other Agent Skills clients | Copy the complete `SKILL.md`, `agents/`, and `references/` tree to a supported skill directory named `swift-relux` |

Curator's checked skill-adapter table does not list `pi`; do not add it to the
`agents` array expecting a generated Pi adapter. Pi 0.84.2 was checked with its
real skill loader using an explicit path. Its default loader predates upstream
`.agents/skills` discovery, so use the fallback for that version. Global fallback:
`pi --skill "$HOME/.agents/skills/swift-relux"` when that is the installed context.

These are packaging/delivery checks, not claims of live model execution in every
client. Sources: [Curator adapters](https://github.com/relux-works/curator/blob/main/internal/adapters/adapters.go),
[Pi skills](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md),
[OpenCode skills](https://opencode.ai/docs/skills/), and
[Claude skills](https://code.claude.com/docs/en/skills).

## Package layout

```text
SKILL.md                 Portable entrypoint and task routing
agent-skill.json          Curator package manifest
agents/openai.yaml        Optional Codex display metadata
references/
  instructions/          App bootstrap, module authoring, UI, logout workflows
  snippets/              Dispatch, IoC, routing, temporal state, analytics, localization
  core/ swiftui/ router/  Runtime and integration references
  modules/ packages/     Project conventions
  overview/              Scope and pinned ecosystem evidence
```

Curator selects only standard context roots. The former root-level `instructions/`
and `snippets/` now live under `references/` so all linked resources survive
installation. Repository administration and tests remain outside installed context.
Start with [SKILL.md](SKILL.md); read only references relevant to the task.
See [ecosystem evidence](references/overview/ecosystem.md) for package boundaries
and the reviewed source revisions.

## Legacy manual installation

```sh
git clone https://github.com/relux-works/skill-swift-relux.git
cd skill-swift-relux
./setup.sh
./setup.sh --verify-only
```

This macOS/zsh path copies the skill into `~/.agents/skills/swift-relux` and
creates Claude/Codex symlinks. Use Curator for managed multi-agent delivery.
It preserves the established install path and no longer copies repository-local
agent configuration into the skill. Installed context is independent of the checkout.

## Tools and validation

| Tool | Purpose / exact command | Outputs |
| --- | --- | --- |
| Curator | `curator skill check .` | Package validation on stdout |
| Python 3 | `python3 tests/package_test.py` | Local resource graph validation |
| Curator integration test | `python3 tests/curator_install_test.py` | Signed isolated snapshot, install, content parity, adapter, status and repeat-install evidence in `.temp/curator-test-*/`; requires configured Git signing, Python 3 and Curator |
| Installed context check | `python3 tests/package_test.py /path/to/test-project` | Byte parity and complete Markdown link graph for canonical context and four adapters |
| zsh / rsync | `zsh -n setup.sh` and `./tests/setup_test.sh` | Legacy installation checks; temporary test directory removed on exit |
| Legacy installer | `./setup.sh` or `./setup.sh --verify-only` | Skill copy and Claude/Codex symlinks; install state under `~/.config/swift-relux-skill/` |
| task-board | `task-board q --format compact 'summary()'` | Repository work tracking in `.task-board/` |

Curator resolves git snapshots, including `HEAD` for a local development path
substitution; it does not test uncommitted edits. The integration test therefore
creates and verifies a signed fixture commit before installing. It sets only a
task-local `CURATOR_CONFIG`, preserving the user's home and installed skills.
