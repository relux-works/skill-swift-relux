## Status
done

## Review
none

## Task Class
docs

## Estimate
estimated(fibonacci(2))

## Blocked By
- (none)

## Blocks
- (none)

## Checklist
- [x] Inspect relux-sample dispatch call sites and persist focused evidence
- [x] Replace runtime-availability guidance with canonical action/actions priority and narrow exceptions
- [x] Align SwiftUI and temporal-state examples with the canonical helper API
- [x] Validate source and installed skill copies
- [x] Docs updated and consistent with current code
- [x] No discrepancies between code and description
- [x] Result linked as a new task-scoped outcome resource
- [x] Important findings, decisions, anomalies, or regressions recorded in logbook when relevant
- [x] Add actor-first guidance for flows, sagas, and stateful async services, fetchers, and storage adapters
- [x] Inspect Swipe2Cash runtime-identity and concurrency call sites and persist focused evidence
- [x] Document explicit Relux/Dispatcher use for host-library integrations and isolated integration tests
- [x] Add actor-first guidance for flows, sagas, and stateful async services/fetchers/storage with immutable/stateless value-type exceptions
- [x] Audit every affected dispatch and concurrency example for the expanded contract
- [x] Document MainActor as an isolation boundary for UI/platform and synchronous third-party main-thread APIs
- [x] Document @MainActor for UI/platform and synchronous third-party main-thread contracts alongside actor-first and value-type branches
- [x] Inspect current swiftui-relux resolver, environment, temporal connector, and weak-store implementation
- [x] Remove temporal connection from explicit runtime/dispatcher exceptions and view examples
- [x] Document view-owned temporal lifecycle, no explicit cleanup, and current Flow injection limitation
- [x] Reinstall and validate corrected source and installed skill copies
- [x] Inspect swiftui-relux temporal connector/store behavior and persist pinned evidence
- [x] Remove temporal callbacks from direct Relux/Dispatcher exceptions and view examples
- [x] Document view-owned declarative temporal state and current non-injectable Flow dependency limitation with future runtime accessor direction
- [x] Re-audit all dispatch/temporal examples and source-installed parity against the refined objective

## Notes
spawn selection rationale tuple: {"role":"doc-writer","pair":"gpt-5.6-sol/high","text":"The owner requires canonical Relux dispatch guidance and sample-backed validation at the configured project policy pair."}
spawn selection rationale for gpt-5.6-sol/high: The owner requires canonical Relux dispatch guidance and sample-backed validation at the configured project policy pair.
spawn agent resolution: Agent selection: codex via explicit_override (preferred_agentic_system: mixed[claude,codex], config: spawn.preferred_agentic_system)
spawn launch composition: empty; contract=agents-infra.child-launch-composition; provider=codex; schema=1; producer=v1.6.0-36-g24f10ed; diagnostic=launch_composition_empty; no project MCP servers enabled
spawn queued: [implementer] doc-writer (codex) (run=RUN-260730-603dc2, max_parallel=20)
spawn run started: [implementer] doc-writer (codex) (run=RUN-260730-603dc2)
agent completed: [implementer] doc-writer (codex) (exit=0)
spawn run completed: codex (run=RUN-260730-603dc2, pid=22483, exit=0)
Orchestrator review reopened the task: correct the Swipe2Cash package commit evidence, classify S2CDemo.Content direct primary-runtime dispatch as local drift rather than an exception, and reconcile ordinary resolver ordering with the host/provider bootstrap exception before final parity validation.
Owner refined the objective: temporal state is declarative view-owned state, not a direct-runtime dispatch exception. Evidence must now include swiftui-relux source behavior and explicitly distinguish current Flow-access limitations from a possible future runtime accessor.
Orchestrator final acceptance passed for the refined owner objective: callback-free declarative temporal attachment, no direct runtime at temporal view call sites, explicit current Flow injection limitation/future accessor direction, two exact dispatcher exception classes, three pinned evidence sources, preserved actor/MainActor/Sendable guidance, and green source/installed validation.

## Precondition Resources
(none)

## Outcome Resources
- [TASK-260730-3ev75n_spawn-log_-implementer--doc-writer--codex-_RUN-260730-603dc2.log](file://TASK-260730-3ev75n/TASK-260730-3ev75n_spawn-log_-implementer--doc-writer--codex-_RUN-260730-603dc2.log) — System spawn log captured by task-board
- [TASK-260730-3ev75n_relux-sample-dispatch-evidence.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_relux-sample-dispatch-evidence.md) — Pinned relux-sample/swift-relux dispatch evidence with canonical callback-free temporal attachment
- [TASK-260730-3ev75n_swipe2cash-runtime-isolation-evidence.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_swipe2cash-runtime-isolation-evidence.md) — Pinned Swipe2Cash runtime/isolation evidence with primary-runtime drift and absence of temporal call sites classified accurately
- [TASK-260730-3ev75n_dispatch-runtime-and-isolation-research.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_dispatch-runtime-and-isolation-research.md) — Consolidated dispatch, declarative temporal ownership, current Flow limitation, future accessor direction, and concurrency research
- [TASK-260730-3ev75n_validation.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_validation.md) — Final source/install parity and callback-free temporal ownership contract validation with real exit codes
- [TASK-260730-3ev75n_results.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_results.md) — Final corrected handoff after declarative temporal-state refinement
- [TASK-260730-3ev75n_orchestrator-review-validation.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_orchestrator-review-validation.md) — Superseded prior acceptance; points to final callback-free temporal ownership evidence
- [TASK-260730-3ev75n_swiftui-relux-temporal-evidence.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_swiftui-relux-temporal-evidence.md) — Pinned SwiftUIRelux connector/store evidence for declarative view ownership, current Flow dependency limitation, and future accessor direction
- [TASK-260730-3ev75n_temporal-state-ownership-evidence.md](file://TASK-260730-3ev75n/TASK-260730-3ev75n_temporal-state-ownership-evidence.md) — Pinned environment connection, weak view-owned lifetime, current Flow access limitation, and callback-free canonical call site evidence

## Created
2026-07-30T08:55:05Z

## Last Update
2026-07-30T09:29:58Z

## Assigned To
[implementer] doc-writer (codex)
