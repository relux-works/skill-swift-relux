# Flight Logbook

> Institutional memory. Concise, factual, high-signal.
> Newest entries first. One block per insight.

## 2026-07-30

### 1222 — Temporal attachment is view-owned, not a runtime exception
- CORRECTION: `.reluxTemporal(state:)` reads Relux from `\.relux`; ordinary view call sites do not pass or dispatch through a runtime instance.
- FINDING: `Relux.Resolver` attaches `.relux(relux)` to root content, while `Relux.Store` retains temporal state through a weak `StateRef`.
- DECISION: The SwiftUI container owns temporal state through `@StateObject`; view dismissal releases it without explicit cleanup or disconnect.
- FINDING: Current public state access does not materialize live temporal state for Flow/Saga injection; pass immutable `Sendable` snapshots or use a lifecycle-stable dependency until a future runtime accessor defines lookup and lifetime semantics.
- SCOPE: `SKILL.md`, `instructions/ui-integration.md`, `references/core/relux-core.md`, `references/swiftui/swiftui-relux.md`, `snippets/temporal-state.md`, `snippets/dispatch-runtime-selection.md`.

### 1211 — Main-thread SDKs are isolation boundaries
- FINDING: `swiftui-relux/Sources/View+ReluxEnvironment.swift` registers temporal state through its environment runtime, so the canonical view call site needs no direct runtime access.
- DECISION: Temporal state is connected declaratively; direct runtime dispatch remains limited to host-library lifecycle and isolated integration-test boundaries.
- DECISION: `@MainActor` also protects narrow adapters around synchronous third-party main-thread contracts, including specific WebRTC and Unity bridges; it is not restricted to UI types.
- SCOPE: `SKILL.md`, `references/core/relux-core.md`, `references/modules/module-conventions.md`, `references/packages/package-conventions.md`, `references/swiftui/swiftui-relux.md`, `snippets/dispatch-runtime-selection.md`.

### 1200 — Dispatch helper choice follows ownership, not runtime reachability
- FINDING: `relux-sample` application call sites use `action`, `actions`, or `performAsync`; its explicit dispatcher references are the `Notes.Business.Flow` injection seam and standalone dispatchers created by isolated flow tests.
- FINDING: Top-level helpers route through `Relux.shared.dispatcher`, while `Relux.Saga` instance helpers route through `self.dispatcher`, so ordinary flow code preserves injected dispatchers without spelling `dispatcher.actions`.
- FINDING: Swipe2Cash uses explicit runtime providers at host lifecycle boundaries, injected dispatcher/logger pairs in integration tests, actors for flows and mutable async services/fetchers, `Sendable` protocols across task boundaries, and immutable structs where mutable ownership is delegated.
- DECISION: Canonical application guidance now prefers `action`/`actions` even when a concrete runtime is available; direct dispatcher calls are limited to explicit host-library lifecycle and isolated integration-test boundaries. Actor-first guidance retains immutable/stateless value types and narrow `@MainActor` third-party adapters as explicit branches.
- SCOPE: `SKILL.md`, `instructions/app-bootstrap.md`, `instructions/ui-integration.md`, `references/core/relux-core.md`, `references/swiftui/swiftui-relux.md`, `references/modules/module-conventions.md`, `references/packages/package-conventions.md`, `snippets/dispatch-runtime-selection.md`, `snippets/temporal-state.md`, `snippets/store-cleanup.md`, `TASK-260730-3ev75n`.

### 1149 — Project model ceilings now use explicit v3 admission
- FINDING: The legacy v2 ceiling for the requested `gpt-5.6-sol/high` and `claude-opus-5` policy projected a mandatory migration warning and copy-ready v3 allow sets.
- DECISION: Migrated `task-board.config.json` to `spawn-policy-v3` using those exact projected sets, with `gpt-5.6-sol` and `claude-opus-5` as the only configured fallback models.
- FIX: Regenerated the ignored project Codex config through `agents-infra`; its stale `service_tier = "fast"` override is now `service_tier = "default"`.
- SCOPE: `.agents/.configs/project-config.toml`, `task-board.config.json`, ignored `.codex/config.toml`, `TASK-260730-2dsegd`.

## 2026-07-20

### 1542 — Installed skill copies could remain incomplete
- ROOT CAUSE: `swift-relux` and `ios-app-manager` source trees contain the reported resources, but their installers only verified `SKILL.md` or symlink presence; stale or damaged installed copies were not diagnosed as a resource-graph failure.
- FIX: `swift-relux/setup.sh` now verifies source-to-installed runtime parity and every local resource linked from `SKILL.md`; `--verify-only` detects drift without repair.
- FINDING: Current source and installed copies match for `instructions/module-authoring.md` and the referenced `ios-app-manager` PlantUML diagrams.
- SCOPE: `setup.sh`, `tests/setup_test.sh`, `README.md`, `BUG-260720-pveoba`.
- STATUS: `swift-relux` fixed and reinstalled; equivalent fail-loud verification remains pending in the `skill-ios-app-manager` source repository.
