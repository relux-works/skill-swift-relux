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

## Reference Routing

Load only the reference files needed for the task:

- Core state management, modules, actions, effects, reducers, sagas, flows:
  read [references/relux-core.md](references/relux-core.md).
- SwiftUI app/root integration, environment injection, async runtime resolution,
  temporal flow state:
  read [references/swiftui-relux.md](references/swiftui-relux.md).
- Navigation stacks, `Router`, `ProjectingRouter`, route actions:
  read [references/relux-router.md](references/relux-router.md).
- Feature module layout, namespace naming, reducers, flows, tests:
  read [references/module-conventions.md](references/module-conventions.md).
- Swift package boundaries, public namespace facades, resources, tests:
  read [references/package-conventions.md](references/package-conventions.md).
- Skill scope, target libraries, current non-goals:
  read [references/micro-spec.md](references/micro-spec.md).

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
