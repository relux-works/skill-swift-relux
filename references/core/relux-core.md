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

Relux intentionally differs from classic Redux in a few places:

- `Relux.Store` connects and stores registered states; it is not where feature
  transition logic lives.
- Relux states are mutable runtime objects, and a reducer is part of the state
  object instead of a detached pure function returning a new state value.
- `Relux.Dispatcher` is a separate event bus for actions and effects. Logging
  and middleware observe the dispatcher path.
- Middleware is the effect side of the same event stream: `RootSaga` routes
  effects to sagas/flows, sagas/flows call services, then dispatch follow-up
  actions or effects.

In an app architecture, Relux is the product-state and business-event boundary:

- it owns shared app/product state;
- it helps define feature module boundaries;
- it hosts business orchestration in sagas and flows;
- it talks to service-oriented/API layers from sagas and flows;
- it talks to SwiftUI only through containers and environment injection.

Keep private one-view presentation details out of Relux unless they need a
longer lifetime, cross-view sharing, or business observation.

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
- The projection from `BusinessState` to `UIState` is the module's
  responsibility. Keep it one-way and explicit.
- Do not use Combine subscriptions as an escape hatch around actor isolation.
  They can hide concurrency boundaries and make writes look synchronous when
  they are not.
- Treat `AsyncChannel`/`Channel`-style bridges from `swift-async-algorithms` as
  a specialized integration choice, not the default state binding pattern.
- Structured concurrency does not guarantee that a SwiftUI-facing `UIState` has
  already observed a `BusinessState` change immediately after an action
  dispatch. Use `HybridState` for simple cases, or `Relux.Flow` when the caller
  needs an operation result.

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

## IoC Composition

For real apps, do not build Relux infrastructure directly inside SwiftUI view
bodies. Use the app scaffold to create an IoC registry/composition root, then
register Relux infrastructure and feature modules there.

See [../../snippets/ioc-registry.md](../../snippets/ioc-registry.md) for a
concrete registry and Relux builder example.

This keeps dependency ownership explicit:

- the app chooses concrete implementations;
- feature modules receive protocol dependencies through constructors;
- `Relux.Resolver` waits for the runtime but does not know how dependencies are
  built;
- previews/tests can replace registry builders or construct modules directly.

## Reducers

- `State.reduce(with:)` should type-match the module action and delegate to an
  internal reducer method.
- Reducers must switch exhaustively over the module `Action`.
- `cleanup()` must reset every mutable/published field once the state has real
  data.
- Do not mutate state directly from a `Flow`; dispatch `Action` and let the
  reducer own mutation.
- Keep reducer implementations in a dedicated namespace-named file, for
  example `<Module>+Business+State+Reducer.swift`, so state declaration files
  stay focused on stored data, initial values, and lifecycle hooks.

## Store Cleanup

Use `Relux.Store.cleanup(exclusions:)` for app-wide session cleanup, especially
on logout. See [../../snippets/store-cleanup.md](../../snippets/store-cleanup.md)
for a concrete cleanup example.

The exclusions list takes `Relux.BusinessState.Type` values. Use it for states
that must survive session reset, such as routers, feature flags, network
monitoring, app configuration, or other app-shell state that should not be
cleared with user data.

Rules:

- `cleanup(exclusions:)` calls `cleanup()` on registered business/hybrid states
  that are not excluded.
- State `cleanup()` implementations should reset mutable user/session data to
  initial values.
- Keep excluded states intentional and short. Exclusions are for app-shell
  continuity, not for avoiding correct cleanup work.
- Do not run store cleanup while active product views still own tasks that can
  dispatch into soon-to-be-cleaned states. Route out of those views first; see
  the SwiftUI logout transition guidance.

## Actions And Effects

- `Action: Relux.Action` is for pure state transitions.
- `Effect: Relux.Effect` is for side-effect requests handled by middleware.
- Keep actions and effects domain-named. Remove `testAction`,
  `placeholderEffect`, and similar scaffolding before review.

## Dispatch Helpers

Use `await actions { ... }` when async code needs to dispatch one or more
actions/effects and observe the reduced result:

```swift
await actions {
    Auth.Effect.restoreSession
    Router.Action.set([.home])
}
```

Use `await action { ... }` for a single action/effect when the singular form is
clearer:

```swift
await action {
    Auth.Action.logoutCompleted
}
```

Both helpers route through `Relux.shared.dispatcher` by default. When a concrete
runtime is already in hand, prefer its dispatcher to avoid hidden global
coupling:

```swift
await relux.dispatcher.actions {
    App.Effect.start
}
```

Use `performAsync { ... }` from synchronous call sites such as SwiftUI `Button`
actions, gesture handlers, `.refreshable`, or view helper closures. It creates a
`Task` and dispatches through the Relux dispatcher without forcing the caller to
become `async`:

```swift
Button("Track") {
    performAsync {
        Analytics.Effect.trackTap
    }
}
```

Do not use `performAsync` when the surrounding code is already async and the
result matters; use `await action` or `await actions` instead so ordering and
failures remain observable. The important SwiftUI exception is `.refreshable`:
do not tie SwiftUI pull-to-refresh to a slow awaited Relux action; see
[../swiftui/swiftui-relux.md](../swiftui/swiftui-relux.md) and
[../../snippets/refreshable-perform-async.md](../../snippets/refreshable-perform-async.md).

## Flow And Saga

- Prefer `Relux.Flow` when a specific effect behaves like an operation and the
  caller may need success/failure, navigation, dismissal, retry, or inline error
  handling from the result.
- Use `Relux.Saga` for fire-and-forget reactions, subscriptions, background
  loops, startup orchestration, fan-out work, or cross-domain coordination where
  no caller waits for a typed operation result.
- Define a module-local protocol, for example `protocol IFlow: Relux.Flow {}`.
- Define the actor separately, then conform in an extension:
  `extension Auth.Flow: Auth.IFlow`.
- Give flows an explicit `let dispatcher: Relux.Dispatcher`.
- Accept `dispatcher: Relux.Dispatcher? = nil` in initializers for tests; fall
  back to `await Self.defaultDispatcher` only as the runtime default.
- Flows and sagas may receive dependencies on business states when they need
  read-only snapshots or queries. This is a read dependency, not a mutation
  channel.
- `apply(_:)` should switch on `effect as? <Module>.Effect`.
- Return `.success` for foreign effects.
- Delegate real effect cases to private methods once logic appears.
- Dispatch follow-up state changes via `await actions { <Module>.Action... }`.
- Never mutate `BusinessState`, `HybridState`, or `UIState` directly from a flow
  or saga. Direct writes bypass reducers and break Relux's unidirectional data
  flow; emit actions and let reducers own all state transitions.
- Return `.failure(error)` only when the flow outcome itself should be
  observable by the caller.
