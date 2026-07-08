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

## IoC Composition

For real apps, do not build Relux infrastructure directly inside SwiftUI view
bodies. Use the app scaffold to create an IoC registry/composition root, then
register Relux infrastructure and feature modules there.

Typical registry shape:

```swift
extension DemoApp {
    @MainActor
    enum Registry {
        static let ioc = IoC()

        static func configure() {
            ioc.register(Relux.self, lifecycle: .container, resolver: Self.buildRelux)
            ioc.register(Relux.Store.self, lifecycle: .container, resolver: Self.buildReluxStore)
            ioc.register(Relux.RootSaga.self, lifecycle: .container, resolver: Self.buildReluxRootSaga)
            ioc.register((any Relux.Logger).self, lifecycle: .container, resolver: Self.buildReluxLogger)

            ioc.register(Feature.Module.self, lifecycle: .container, resolver: Self.buildFeatureModule)
            ioc.register((any Feature.Service).self, lifecycle: .container, resolver: Self.buildFeatureService)
        }

        static func resolve<T>(_ type: T.Type) -> T {
            ioc.get(by: type)!
        }

        static func resolveAsync<T>(_ type: T.Type) async -> T {
            await ioc.getAsync(by: type)!
        }
    }
}
```

Build `Relux` from IoC-resolved infrastructure and register modules inside the
Relux builder:

```swift
extension DemoApp.Registry {
    private static func buildRelux() async -> Relux {
        await Relux(
            logger: resolve((any Relux.Logger).self),
            appStore: resolve(Relux.Store.self),
            rootSaga: resolve(Relux.RootSaga.self)
        )
        .register { @MainActor in
            await resolveAsync(Feature.Module.self)
            resolve(AnotherFeature.Module.self)
        }
    }
}
```

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
actions, gesture handlers, or view helper closures. It creates a `Task` and
dispatches through the Relux dispatcher without forcing the caller to become
`async`:

```swift
Button("Track") {
    performAsync {
        Analytics.Effect.trackTap
    }
}
```

Do not use `performAsync` when the surrounding code is already async and the
result matters; use `await action` or `await actions` instead so ordering and
failures remain observable.

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
