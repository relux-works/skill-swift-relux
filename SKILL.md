---
name: swift-relux
description: >
  Swift Relux architecture guidance for the relux-works Swift libraries. Use when
  working with swift-relux, SwiftUIRelux, swiftui-reluxrouter, Relux modules,
  HybridState, BusinessState, UIState, Saga, Flow, Effect, Action, reducers,
  Relux.Resolver, reluxTemporal, SwiftUI Relux environment injection, Relux
  navigation routers, typed product analytics metric trees, typed localization
  access trees, or module/package conventions for Relux-based Swift apps.
  Russian triggers: релакс, свифт-релакс, релакс модуль, релакс роутер,
  метрики, продуктовая аналитика, локализация, SwiftUI Relux, relux state,
  relux flow, relux saga.
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
  read [instructions/app-bootstrap.md](instructions/app-bootstrap.md).
- Feature module authoring, reducers, flows, tests, analytics:
  read [instructions/module-authoring.md](instructions/module-authoring.md).
- SwiftUI containers, views, temporal state, pull-to-refresh:
  read [instructions/ui-integration.md](instructions/ui-integration.md).
- Logout, session reset, store cleanup:
  read [instructions/logout-cleanup.md](instructions/logout-cleanup.md).

Reference sections:

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

- [snippets/ioc-registry.md](snippets/ioc-registry.md)
- [snippets/modular-projecting-router.md](snippets/modular-projecting-router.md)
- [snippets/store-cleanup.md](snippets/store-cleanup.md)
- [snippets/swiftui-container-page.md](snippets/swiftui-container-page.md)
- [snippets/temporal-state.md](snippets/temporal-state.md)
- [snippets/refreshable-perform-async.md](snippets/refreshable-perform-async.md)
- [snippets/product-analytics.md](snippets/product-analytics.md)
- [snippets/localization.md](snippets/localization.md)

## Default Workflow

- Inspect the nearest `Package.swift`, app composition root, and existing module
  layout before proposing Relux changes.
- Prefer existing package and namespace patterns over creating a new local style.
- Keep state changes in reducers. Do not mutate Relux state directly from flows.
- Model side effects as `Effect` handled by `Flow` or `Saga`.
- Use `HybridState` for simple SwiftUI-observed features; split into
  `BusinessState` plus `UIState` when business data is shared, transformed, or
  aggregated across domains.
- Treat skeleton code as scaffolding only. Do not add fake product state, fake
  SDK contracts, placeholder effects, or test-only behavior that pretends to be
  real domain logic.
- When changing behavior, add focused Swift Testing coverage for reducers,
  flow handling, module registration, or SwiftUI integration as appropriate.
