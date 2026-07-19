# Rerun comparison: sol/max orchestrator before vs after mitigations

Date: 2026-07-15. Same spec (`.spec/wordstats.md`), same board config (codex pinned
`gpt-5.6-sol`/`max`, criterion `equal`), same orchestrator task description/AC/DoD.
Only variable: the project-management skill + task-board tool with the 8 mitigations from
`EPIC-260715-3sfe9t spawn-token-efficiency` (skill-project-management board) installed.

## Headline

| Metric | Baseline (v1) | Rerun (v2) |
| --- | ---: | ---: |
| Outcome | **aborted at 44 min** (capture point), 4/14 tasks done, extrapolated ~250M+ to finish | **delivered end-to-end**: epic done, 5/5 tasks, 4/4 stories |
| Total tokens (incl. cached) | 110.3M — for go.mod + 3 unreviewed files | 110.0M — for the whole reviewed project |
| Uncached input | 2.83M | 2.13M |
| Output tokens | 435k | 304k |
| Tracked board runs | 17 Codex sessions observed at capture | 13 run directories: 12 completed, 1 failed root run |
| Board size | 7 stories / 14 tasks | 4 stories / 5 tasks |
| Invented-scope research tasks | 2 (answered by the spec) | 0 |
| Meta-delegated decomposition | yes (architect + reviewer, 2 sessions, 25 min) | no — orchestrator decomposed inline |
| First real code | ~37 min | ~10 min |
| Paperwork rework loops | go.mod saga: 5 sessions on a 3-line file | 0 |
| Product-bug rework loops | 0 (never got that far) | 1 — reviewer caught a real double-Usage bug, fixed, re-reviewed |
| "Spawn selection assessment" note spam | before all 17 spawns | 0 occurrences |
| Deliverable quality gates | none passed | go test + go vet green, README with Tools section, all tasks reviewer-accepted |

Effective cost per delivered task: baseline burned 110M for 4 mostly-meta tasks
(~27.5M/task, none of them product code); v2 delivered 5 real tasks including tests,
docs, and review cycles for ~22M/task — and, unlike baseline, actually finished.

## Which mitigation showed up where

1. **Inline decomposition mandate** — v2 orchestrator laid out the board itself in the
   first ~7 minutes; no architect meta-task, no decomposition review cycle.
2. **Decomposition budget + justified gaps** — 4 stories / 5 tasks proportional to a
   5-requirement spec; zero contract-research tasks; the one beyond-spec addition
   (README/docs task) carried an explicit justification (global instructions mandate a
   README Tools section) — the justified-gap rule working as intended, not invented scope.
3. **Task-class-aware DoD** — tasks created with `task_class` (code/docs/metadata); the
   docs task did not inherit "tests passing" DoD; no unsatisfiable-DoD evidence stretching.
4. **Evidence honesty contract** — no exit-code masking incidents; the only rework was a
   genuine product defect (duplicate usage block on invalid flags), caught by review and
   fixed in one cycle.
5. **Completion-hook fix** — no handoff blocked over outcome-resource technicalities.
6. **Selection-assessment skip under equal ceiling** — 0 assessment paragraphs (17 in v1).
7. **Review policy field** — available (`review` on all elements); v2 board had no trivial
   standalone tasks left after the compact decomposition, so `review=none` was never
   needed — the trivial-task problem was eliminated upstream by better decomposition.
8. **Per-role ceilings** — available in config; not exercised in this run (single pinned
   pair), useful for future reviewer-effort tuning.

## Wall-clock note

The operator observed v2 from approximately 14:07–16:13 (~2h06m) vs baseline's
44-minute capture window. These wall-clock boundaries and the token totals above were
calculated from local Codex rollout/session logs at capture time; those provider-runtime
logs are intentionally not preserved in this repository. The durable evidence ledger
therefore treats them as externally calculated observations, not reproducible counters.
V2 ran
tasks strictly sequentially through full producer→reviewer cycles and lost a window to an
external Cloudflare 403 that killed the first orchestrator session (restarted, no state
lost — board-driven recovery worked). Baseline extrapolated wall time to completion was
~2.5–3h with ~2.3× the tokens.

## Residual observations

- Sequential producer scheduling: v2 orchestrator never ran two producers in parallel even
  where the DAG allowed it (docs/verify could overlap CLI). Cheap potential improvement,
  costs wall-clock only, not tokens.
- Cloudflare 403 transport failures kill long codex sessions; board-driven restart
  recovers cleanly, but an auto-retry in the spawn runner would remove the manual step.
  (Candidate for the board-functionality-audit findings.)

## Artifacts

- Durable v2 run ledger and final board snapshot:
  `TASK-260715-16civq_durable-evidence-ledger.md` outcome resource.
- Preserved v2 profiler prefix: `TASK-260715-16civq_profiler-v2-samples.log` outcome
  resource. It ends before final delivery and must be read together with the ledger.
- Baseline evidence and profiler prefix: `TASK-260715-1wqpkq` outcome resources.
- Token totals and wall-clock boundaries: externally calculated from local provider session
  logs at capture time; raw provider logs are deliberately not retained.
