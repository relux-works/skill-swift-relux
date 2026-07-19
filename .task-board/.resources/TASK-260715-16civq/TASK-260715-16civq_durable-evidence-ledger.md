# Durable evidence ledger: mitigated orchestrator rerun

Date: 2026-07-15. Captured durably on 2026-07-20 from the retained v2 sandbox before cleanup.

## Final board snapshot

- Epic: 1 done / 1 total.
- Stories: 4 done / 4 total.
- Tasks: 5 done / 5 total.
- Active: none.
- Blocked: none.
- Final validation rerun on 2026-07-20: `go test ./...` passed; `go vet ./...` passed.

Final tasks:

- `TASK-260715-2rhbnh` — orchestrate-wordstats-delivery — done.
- `TASK-260715-21fpvo` — implement-stats-library — done.
- `TASK-260715-2uata8` — implement-wordstats-cli — done.
- `TASK-260715-k0ivxq` — document-wordstats-usage-and-tools — done.
- `TASK-260715-a6fnue` — verify-wordstats-delivery — done.

## Tracked run ledger

The retained sandbox contains 13 task-board run directories: 12 completed successfully and
one failed root run. This is the durable session count; any earlier reference to 14 sessions
included an externally observed provider session that did not survive as a tracked run and
must not be treated as a reproducible board counter.

| Run | Task | Status | Completion |
| --- | --- | --- | --- |
| `RUN-260715-374bd8` | `TASK-260715-2rhbnh` | failed | failure |
| `RUN-260715-d8759f` | `TASK-260715-2rhbnh` | completed | success |
| `RUN-260715-f91e16` | `TASK-260715-2rhbnh` | completed | success |
| `RUN-260715-4ba468` | `TASK-260715-21fpvo` | completed | success |
| `RUN-260715-546f09` | `TASK-260715-21fpvo` | completed | success |
| `RUN-260715-07faff` | `TASK-260715-2uata8` | completed | success |
| `RUN-260715-0cdeaa` | `TASK-260715-2uata8` | completed | success |
| `RUN-260715-7d7b8b` | `TASK-260715-2uata8` | completed | success |
| `RUN-260715-a48e9d` | `TASK-260715-2uata8` | completed | success |
| `RUN-260715-25bbcb` | `TASK-260715-k0ivxq` | completed | success |
| `RUN-260715-ac31ff` | `TASK-260715-k0ivxq` | completed | success |
| `RUN-260715-4f2ba5` | `TASK-260715-a6fnue` | completed | success |
| `RUN-260715-ef51a5` | `TASK-260715-a6fnue` | completed | success |

## Token and wall-clock provenance

The comparison's token totals, uncached/output counts, and approximate 14:07–16:13 operator
window were calculated from local Codex rollout/session logs at capture time. Those private
provider-runtime logs are intentionally not copied into the repository. The figures are
retained as externally calculated observations and are not independently reproducible from
the profiler samples. Structural claims—board size, final completion, tracked runs, rework,
and validation—are supported by the durable board/run ledger above.

## Preserved artifact contract

- `TASK-260715-16civq_rerun-comparison.md`: interpreted comparison and caveats.
- `TASK-260715-16civq_profiler-v2-samples.log`: profiler prefix ending before final delivery.
- This ledger: final snapshot, exact tracked-run inventory, and provenance boundaries.
