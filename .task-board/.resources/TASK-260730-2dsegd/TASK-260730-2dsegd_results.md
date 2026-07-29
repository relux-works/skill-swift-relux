# TASK-260730-2dsegd implementation evidence

## Policy changes

- `.agents/.configs/project-config.toml` resolves the primary Codex launcher to
  `gpt-5.6-sol` with `high` reasoning and yolo enabled.
- The same file resolves the primary Claude launcher to `claude-opus-5` with
  yolo enabled.
- `task-board.config.json` now uses `spawn-policy-v3` exact allow sets copied
  from the CLI's read-only v2 migration projection. Its resolution models are
  `gpt-5.6-sol` and `claude-opus-5`; Codex reasoning is bounded at `high`.
- The version-control confirmation policy and its preference for a timestamp
  after 20:00 MSK remain byte-for-byte unchanged.
- `agents-infra setup local` regenerated ignored `.codex/config.toml`; the
  project-local service tier is now `default`, not `fast`.

## Validation

| Command | Exit | Evidence |
| --- | ---: | --- |
| `jq empty task-board.config.json` | 0 | Tracked board config parses as JSON. |
| `agents-infra doctor local /Users/alexis/src/relux-works/skill-swift-relux` | 0 | Both primary policies are valid; Codex is `gpt-5.6-sol/high/yolo=true`, Claude is `claude-opus-5/yolo=true`; generated project config is active. |
| `agents-infra codex --print-config` | 0 | Final argv includes `--model gpt-5.6-sol`, `model_reasoning_effort="high"`, and `--dangerously-bypass-approvals-and-sandbox`. |
| `agents-infra claude --print-config` | 0 | Final argv includes `--model claude-opus-5` and `--dangerously-skip-permissions`. |
| `rg -n '^service_tier' .codex/config.toml` | 0 | The sole match is `service_tier = 'default'`. |
| `task-board q --format compact 'project_config()'` | 0 | Effective ceiling contract is `spawn-policy-v3`, authority is `explicit_allow_set`, migration is not required, and owner commit timing remains after 20:00 MSK. |
| `task-board q --format compact 'project_config(view=spawn-preflight, role=developer, agent=codex)'` | 0 | Resolution model is `gpt-5.6-sol`; reasoning ceiling is `high`. |
| `task-board q --format compact 'project_config(view=spawn-preflight, role=developer, agent=claude)'` | 0 | Resolution model is `claude-opus-5`. |
| `git diff --check` | 0 | No whitespace errors. |

## Expected/recovered failures

- `task-board version` exited 1 because this CLI exposes version output through
  `task-board --version`; the corrected readiness probe exited 0.
- The first `agents-infra setup local` invocation exited 1 because this CLI
  requires an explicit source directory. Re-running with
  `--source-dir /Users/alexis/src/relux-works/relux-agents-infra` exited 0.

## Scope note

No source-code test suite or platform build was run: this task changes only
launcher/board configuration and explicitly calls for narrow effective-config
validation. The config parsers, launch-plan renderers, and role-scoped
spawn-preflight queries above are the relevant gates.
