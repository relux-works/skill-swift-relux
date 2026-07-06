# Relux Core

## Mental Model

Relux is a Swift interpretation of Redux-style unidirectional data flow built
around Swift concurrency.

- Actions are the single channel for state changes.
- Reducers own state mutation.
- Effects represent side-effect requests.
- Sagas and flows handle effects and orchestration.
- Modules group states, sagas/flows, and supporting services.
- Actors and structured concurrency are used to avoid data races and keep async
  behavior explicit.

## State Types

Use `HybridState` for simple SwiftUI-observed features.

- Runs on the main actor.
- Combines business logic and UI reactivity in one place.
- Good first choice for small or local feature state.

Use `BusinessState` plus `UIState` when the feature grows.

- `BusinessState` is actor-based and owns core data/business logic.
- `UIState` is the observable SwiftUI-facing wrapper.
- Prefer this split when data is shared across features, transformed for UI, or
  aggregated from multiple domains.

## Modules

- Relux module structs should conform to `Relux.Module`.
- Use `@MainActor` on module structs that construct `HybridState` or other
  SwiftUI-facing state.
- `states` should contain resolved Relux states owned by the module.
- `sagas` may contain concrete flows because `Relux.Flow` conforms to
  `Relux.Saga`.
- Use async module initialization when flow or state construction is async.
- App registries should resolve async modules and register them inside
  `Relux.register { ... }` with `await` where required.

## Reducers

- `State.reduce(with:)` should type-match the module action and delegate to an
  internal reducer method.
- Reducers must switch exhaustively over the module `Action`.
- `cleanup()` must reset every mutable/published field once the state has real
  data.
- Do not mutate state directly from a `Flow`; dispatch `Action` and let the
  reducer own mutation.

## Actions And Effects

- `Action: Relux.Action` is for pure state transitions.
- `Effect: Relux.Effect` is for side-effect requests handled by middleware.
- Keep actions and effects domain-named. Remove `testAction`,
  `placeholderEffect`, and similar scaffolding before review.

## Flow And Saga

- Prefer `Relux.Flow` when the caller may need success/failure, navigation,
  dismissal, or inline error handling from an operation result.
- Use `Relux.Saga` for fire-and-forget background work and cross-domain
  orchestration.
- Define a module-local protocol, for example `protocol IFlow: Relux.Flow {}`.
- Define the actor separately, then conform in an extension:
  `extension Auth.Flow: Auth.IFlow`.
- Give flows an explicit `let dispatcher: Relux.Dispatcher`.
- Accept `dispatcher: Relux.Dispatcher? = nil` in initializers for tests; fall
  back to `await Self.defaultDispatcher` only as the runtime default.
- `apply(_:)` should switch on `effect as? <Module>.Effect`.
- Return `.success` for foreign effects.
- Delegate real effect cases to private methods once logic appears.
- Dispatch follow-up state changes via `await actions { <Module>.Action... }`.
- Return `.failure(error)` only when the flow outcome itself should be
  observable by the caller.

