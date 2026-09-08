---
name: swift-relux
description: >-
  Implement and review Swift features using the relux-works Relux stack:
  swift-relux, SwiftUIRelux, ReluxRouter, state/reducer modules, Saga/Flow,
  runtime composition, temporal state, and Relux analytics integration.
  Use for Relux-based apps (Swift Relux, свифт-релакс, релакс модуль,
  релакс роутер), not generic SwiftUI, analytics, or localization tasks.
---

# Swift Relux

Use this skill for Swift codebases that use the `relux-works` Relux stack:

- `swift-relux` / product `Relux`
- `swiftui-relux` / product `SwiftUIRelux`
- `swiftui-reluxrouter` / product `ReluxRouter`

## Resource Routing

Load only the files needed for the task.

Instruction flows:

- App composition, IoC, root runtime bootstrap:
  read [references/instructions/app-bootstrap.md](references/instructions/app-bootstrap.md).
- Feature module authoring, reducers, flows, tests, analytics:
  read [references/instructions/module-authoring.md](references/instructions/module-authoring.md).
- SwiftUI containers, views, temporal state, pull-to-refresh:
  read [references/instructions/ui-integration.md](references/instructions/ui-integration.md).
- Logout, session reset, store cleanup:
  read [references/instructions/logout-cleanup.md](references/instructions/logout-cleanup.md).

Reference sections:

- Ecosystem package selection, version boundaries, dispatch semantics:
  [references/overview/ecosystem.md](references/overview/ecosystem.md).

- Core state management, actions, effects, reducers, sagas, flows:
  [references/core/relux-core.md](references/core/relux-core.md).
- SwiftUI app/root integration, containers, local UI state, temporal state:
  [references/swiftui/swiftui-relux.md](references/swiftui/swiftui-relux.md).
- Navigation stacks, `Router`, `ProjectingRouter`, route actions:
  [references/router/relux-router.md](references/router/relux-router.md).
- Feature module layout, namespace naming, reducers, tests:
  [references/modules/module-conventions.md](references/modules/module-conventions.md).
- Swift package boundaries, public namespace facades, resources, tests:
  [references/packages/package-conventions.md](references/packages/package-conventions.md).
- Skill scope, target libraries, current non-goals:
  [references/overview/micro-spec.md](references/overview/micro-spec.md).

Reusable snippets:

- [references/snippets/dispatch-runtime-selection.md](references/snippets/dispatch-runtime-selection.md)
- [references/snippets/ioc-registry.md](references/snippets/ioc-registry.md)
- [references/snippets/modular-projecting-router.md](references/snippets/modular-projecting-router.md)
- [references/snippets/store-cleanup.md](references/snippets/store-cleanup.md)
- [references/snippets/swiftui-container-page.md](references/snippets/swiftui-container-page.md)
- [references/snippets/temporal-state.md](references/snippets/temporal-state.md)
- [references/snippets/refreshable-perform-async.md](references/snippets/refreshable-perform-async.md)
- [references/snippets/product-analytics.md](references/snippets/product-analytics.md)
- [references/snippets/localization.md](references/snippets/localization.md)

## Default Workflow

- Inspect the nearest `Package.swift`, app composition root, and existing module
  layout before proposing Relux changes.
- Check the project's resolved package revisions before copying APIs; see the
  ecosystem reference for source evidence and compatibility boundaries.
- Prefer existing package and namespace patterns over creating a new local style.
- Keep state changes in reducers. Do not mutate Relux state directly from flows.
- Model side effects as `Effect` handled by `Flow` or `Saga`.
- Choose dispatch APIs by runtime identity, not reachability. Use top-level
  `action` / `actions` for the initialized primary runtime, use unqualified
  instance helpers inside `Saga` / `Flow`, and target an explicit
  `Relux` / `Dispatcher` only when a host-library lifecycle integration
  supplies the exact runtime or an isolated integration test owns its
  dispatcher/logger event bus.
- Attach SwiftUI temporal state with `.reluxTemporal(state:)`. The modifier
  resolves Relux from the SwiftUI environment; do not pass or use a runtime
  instance at the view call site merely to connect temporal state.
- Do not inject view-owned temporal state into a `Flow`. It is not currently a
  stable runtime-resolvable dependency; carry immutable `Sendable` input until
  a future runtime state accessor defines lookup and lifetime semantics.
- Prefer actor isolation for flows, sagas, and stateful asynchronous
  dependencies such as services, fetchers, repositories, caches, and storage
  adapters. Keep immutable/stateless implementations as value types when they
  own no serialized mutable state.
- Use `@MainActor` for UI/platform ownership and for adapters around synchronous
  third-party APIs that require main-thread access, including specific WebRTC
  or Unity bridges when their contracts demand it. Keep isolation at that
  boundary instead of spreading it through unrelated business code.
- Make cross-task protocols and values `Sendable`; treat
  `@unchecked Sendable`, locks, and shared mutable classes as reviewed
  exceptions rather than defaults.
- Use `HybridState` for simple SwiftUI-observed features; split into
  `BusinessState` plus `UIState` when business data is shared, transformed, or
  aggregated across domains.
- Treat skeleton code as scaffolding only. Do not add fake product state, fake
  SDK contracts, placeholder effects, or test-only behavior that pretends to be
  real domain logic.
- When changing behavior, add focused Swift Testing coverage for reducers,
  flow handling, module registration, or SwiftUI integration as appropriate.
