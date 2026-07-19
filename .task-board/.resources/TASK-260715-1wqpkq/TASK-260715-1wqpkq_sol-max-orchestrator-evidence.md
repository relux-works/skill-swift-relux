# Evidence: gpt-5.6-sol (max) as task-board orchestrator — token-burn profile

Date: 2026-07-15. Status at capture time (12:02): experiment still running, 4/14 tasks done.

## Goal

Reproduce and profile the observed pathology: sol in the orchestrator role on a task-board
appears to enter recursive review cycles, burning a huge amount of tokens while producing
almost no product output.

## Setup

- Sandbox: `.temp/orch-loop-probe/demo-project/` (git repo, local board)
- Spec: `.spec/wordstats.md` — tiny Go CLI (line/word/byte counts, `--json`, `--top N`),
  explicitly bounded: stdlib only, single main package + one `internal/stats` package,
  docs/CI/packaging out of scope. Honest estimate: ~150 LOC + tests, one dev-hour.
- Board config ceilings (`model_criterion=equal`): codex → `gpt-5.6-sol` / `max`,
  claude → `claude-fable-5`.
- Board: `EPIC-260715-hb60an` → `STORY-260715-l2vzgc` → `TASK-260715-17r8i9`
  (orchestrate-wordstats-delivery, full description/scope/AC/DoD).
- Root spawn: `RUN-260715-9eb74d`, role orchestrator, codex sol/max, started 11:18.
- Profiling: sampler every 20s (run states, log sizes, board summary) + raw logwork reads +
  token totals from `~/.codex/sessions/2026/07/15/rollout-*.jsonl`.

## Timeline (key events)

| Time | Event |
| --- | --- |
| 11:18 | Orchestrator spawned (RUN-9eb74d) |
| 11:20 | Orchestrator creates META-task `decompose-wordstats-spec` and spawns solution-architect (RUN-91953c) instead of decomposing itself |
| 11:32 | Architect done after ~11.5 min / 350 events: **6 stories, 12 tasks** incl. invented scope (user-documentation, delivery-quality-gates, 2 "contract research" tasks for questions the spec already answers) |
| 11:32 | Orchestrator spawns reviewer for the decomposition (RUN-9b2f39); reviewer itself mutates board links, writes LOGBOOK, renders plan graphs |
| 11:40 | Decomposition accepted. Phase 1 fan-out: 2 researchers (contract tasks) + developer (`initialize-go-module`) |
| 11:45 | `go mod init` saga begins (see below) — 5 sessions total on a 3-line file |
| 11:55 | Phase 2: 3 developers writing actual code (count, top-words, error handling) |
| 12:02 | Capture point: 17 sessions, 4/14 tasks done, 3 small .go files, zero tests in packages |

## The go.mod saga (rework-loop anatomy, TASK-260715-1zix5s)

1. **Developer #1** (RUN-b3fa1a): creates go.mod; pipes validation through `tee`, masking
   exit codes; reports "go test/vet exited 0" (false — exit 1 on a package-less module).
2. **Reviewer #1** (RUN-b8aa0d): artifact itself OK, but rejects over evidence truthfulness
   (caught the tee masking). Changes requested: fix claims and checklist, not code.
3. **Developer #2** (RUN-1d29b1): corrects the paperwork via `update_resource` — but the
   **completion hook blocks handoff**: it demands a NEW task-scoped outcome resource;
   updating an existing one doesn't count.
4. **Developer #3** (RUN-5c1e42): spawned solely to create `_rework-evidence.md` and flip
   status to to-review. Pure bureaucracy session.
5. **Reviewer #2** (RUN-4946b0): accepts.

**Five sol/max sessions for `go mod init`.** No product change after session 1.

## Token accounting (11:18 → 12:02, 44 min)

| Metric | Value |
| --- | ---: |
| Codex sessions (sol/max) | 17 (2 still running) |
| Total tokens (incl. cached input) | **110.3M** |
| Uncached input tokens | 2.83M |
| Output tokens | 435k |
| Board tasks done | 4/14 (decomposition, 2 contract-research, go.mod) |
| Product artifacts | go.mod + 3 small .go files (unreviewed), 0 tests |

Orchestrator session alone: 31M+ cumulative input (long-lived session; every turn re-reads
context; ~97% cache hits but still billed at cached rate).

Extrapolation to completion (~10 remaining tasks × 2–3 sessions each + reviews + final
quality gate): **~250M+ total tokens for a ~150-line utility.**

## Root causes (multiplicative, not a divergent loop)

The cycle **converges** — no infinite recursion observed. The burn is four multiplying factors:

1. **Meta-delegation.** The orchestrator (an analyst role whose job includes decomposition)
   creates a meta-task and spawns a solution-architect for it; the decomposition itself then
   goes through a full producer→reviewer cycle. ~25 min / 2 sessions before the first real task.
2. **Over-decomposition at max effort.** 6 stories / 12 tasks for a 5-requirement toy spec,
   including invented scope (documentation story, quality-gates story, 2 research tasks for
   "ambiguities" the spec explicitly resolves). Every extra task costs ≥2 sol/max sessions
   (producer + reviewer) by contract.
3. **Role baseline DoD doesn't scale down.** Injected DoD ("tests passing", "build green",
   architect's "diagrams attached", "logbook entries") is unsatisfiable on metadata-only
   tasks → producers stretch evidence → a max-effort reviewer digs it out (down to exit-code
   masking in a tee pipe) → rework of paperwork, not code → another review.
4. **Completion-hook trap.** Handoff requires a *newly created* task-scoped outcome resource;
   `update_resource` doesn't qualify. A run that did everything right semantically gets its
   handoff blocked, forcing the orchestrator to spawn another producer purely to create a file.

Amplifiers: verbose per-spawn "Spawn selection assessment" notes (pointless under
`model_criterion=equal` — there is exactly one model to "choose"); reviewers doing their own
deep board exploration (plan graphs, link surgery, LOGBOOK entries); mandatory review with no
triviality threshold (`go mod init` gets the same pipeline as a real feature).

## Mitigation directions (not yet implemented)

- Triviality threshold: allow orchestrator to accept bounded mechanical tasks without a
  spawned reviewer, or batch-review a phase instead of per-task review.
- Scale role DoD by task class (metadata/docs tasks must not inherit "tests passing").
- Fix completion hook: accept `update_resource` as valid outcome evidence on rework handoffs.
- Require the orchestrator to decompose inline (its own role duty) instead of meta-delegating.
- Decomposition budget: cap stories/tasks relative to spec size; forbid inventing scope
  (docs/QA stories) absent from the spec.
- Reconsider `max` effort for reviewer roles on small tasks: max-effort reviewers reliably
  find *something*, and on paperwork that means guaranteed rework cycles.

## Artifacts

- Sandbox board + resources: `.temp/orch-loop-probe/demo-project/.task-board/`
- Run states/events: `.temp/orch-loop-probe/demo-project/.temp/spawn-runs/RUN-*/`
- Raw agent logs: `.temp/orch-loop-probe/demo-project/.temp/logwork/<TASK>/*.log`
- Profiler samples: `.temp/orch-loop-probe/profile.log`
- Rework saga (verbatim verdicts): notes on `TASK-260715-1zix5s`, `TASK-260715-20iwb4`
- Token totals were externally calculated from local Codex rollout/session logs at capture
  time. Raw provider-runtime logs are deliberately not retained; the preserved profiler
  samples support the board/run timeline but cannot independently reproduce token totals.
