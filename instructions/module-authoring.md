# Module Authoring Workflow

Use this workflow when adding or reviewing a Relux feature module.

- Read [../references/modules/module-conventions.md](../references/modules/module-conventions.md)
  for module shape, namespace naming, reducers, flow/saga rules, tests, and
  analytics.
- Read [../references/core/relux-core.md](../references/core/relux-core.md) for
  state, action, effect, reducer, dispatch, flow, and saga semantics.
- Read [../references/packages/package-conventions.md](../references/packages/package-conventions.md)
  when the work crosses SwiftPM package boundaries or resources.
- Use [../snippets/product-analytics.md](../snippets/product-analytics.md) for
  typed product analytics tree examples.
- Keep reducers in dedicated reducer files named by namespace path.
- Split models, DTOs, actions, effects, states, reducers, and helpers by
  namespace/type ownership instead of dumping entities into one file.
- Flows and sagas may read business state through dependencies, but must mutate
  state only by dispatching actions.
- Do not inject a view-owned temporal `HybridState` into a flow or saga. Until
  Relux exposes a stable runtime accessor for connected temporal state, carry
  immutable `Sendable` input in the effect/action or use a lifecycle-stable
  business/service dependency.
- Prefer actors for flows, sagas, and stateful asynchronous services, fetchers,
  repositories, storage, and caches. Keep dependencies `Sendable`.
- Use `@MainActor` for UI/platform state and for narrow adapters around
  synchronous third-party APIs whose contract requires the main thread, such
  as specific WebRTC or Unity integrations.
- Add focused Swift Testing coverage for reducer transitions, module
  registration, and flow/saga observable contracts when behavior changes.
