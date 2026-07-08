# Relux Module Conventions

These conventions apply to app-local and package-local Relux modules.

## Module Shape

- Model each feature as one namespace under the owning root, for example
  `App.Auth` or `Payments.Transfer`.
- Put the namespace in `<Module>/<Module>+Namespace.swift`.
- Keep the Relux module entrypoint in `<Module>/<Module>+Module.swift`.
- Keep state transitions in `Business/`.
- Keep side-effect middleware in `Business/Middleware/`.
- Keep module-local errors in `Error/`.
- Add `Data/API/Model` and `Business/Model` namespaces up front when the feature
  is expected to grow into API and domain models.
- Do not add fake product state, fake SDK contracts, or placeholder screens only
  to make the module look complete.

Recommended layout:

```text
<Module>/
  <Module>+Namespace.swift
  <Module>+Module.swift
  Business/
    <Module>+Business+Action.swift
    <Module>+Business+State.swift
    <Module>+State+Business+Reducer.swift
    Middleware/
      <Module>+Business+Effect.swift
      <Module>+Business+Flow.swift
  Error/
    <Module>+Error.swift
```

## Namespaces

- The namespace file owns nested domain namespaces only. Avoid putting behavior
  in the namespace file.
- Use `Data.API.Model` for API DTOs and `Business.Model` for domain models.
- Prefer module-local names inside the namespace: `Action`, `Effect`, `State`,
  `Flow`, `Err`, `Module`.
- File names should follow the namespace path, for example
  `Auth+Business+State.swift`.

## Module Composition

- Relux module structs should conform to `Relux.Module`.
- Use `@MainActor` on module structs that construct `HybridState` or
  SwiftUI-facing state.
- `states` must contain only resolved Relux states owned by the module.
- `sagas` may contain concrete flows because `Relux.Flow` conforms to
  `Relux.Saga`; prefer storing them behind a module-local protocol such as
  `IFlow`.
- Use an async module initializer when any flow/state construction is async.
- App registries must resolve async modules with `await` and register them with
  `await` inside `Relux.register { ... }`.
- When the feature grows dependencies, move construction into explicit builders
  or module-local IoC setup instead of hiding dependencies in global singletons.

## State

- For simple SwiftUI-observed features, use
  `@MainActor final class State: Relux.HybridState, ObservableObject`.
- `State.reduce(with:)` should type-match only the module `Action` and delegate
  to an internal reducer method.
- Put the action reducer in `<Module>+State+Business+Reducer.swift`.
- Reducers must switch exhaustively over `Action`.
- `cleanup()` must reset every mutable/published field once the state has real
  data.
- Do not mutate state directly from `Flow`; dispatch `Action` and let the
  reducer own mutation.

## Actions And Effects

- `Action: Relux.Action` is for pure state transitions.
- `Effect: Relux.Effect` is for side-effect requests handled by middleware.
- Keep `Action` under `Business/`.
- Keep `Effect` under `Business/Middleware/`.
- Avoid shipping `testAction`, `placeholderEffect`, or similar names beyond
  temporary local scaffolding.

## Product Metrics

- Keep product analytics definitions in a module-local typed tree, usually
  `<Module>+Analytics.swift`.
- Put raw collector/event construction helpers in the analytics package or
  product analytics facade. Do not build ad hoc event payloads inside SwiftUI
  button bodies, reducers, or flow methods.
- Use `extension <Module> { enum Analytics { ... } }` for app feature modules.
- Add a short module-local typealias when the analytics event type is verbose.
- Mirror product hierarchy with nested enums for screens, widgets, popups,
  cards, or flow steps.
- Centralize screen names in a nested `Screen` enum when a module owns multiple
  surfaces.
- Use `static let` for fixed metrics and `static func` for metrics that need
  runtime context.
- Keep call sites declarative: views and flows should say what happened, not
  how the collector payload is shaped.

Recommended shape:

```swift
extension Profiles {
    enum Analytics {
        typealias Event = ProductAnalytics.Event

        enum Screen: String {
            case profileSelector = "/profiles"
            var name: String { rawValue }
        }

        enum ProfileSelector {
            private static let screenName = Screen.profileSelector.name

            static let screenAppear = Event.screenAppearance(screenName: screenName)

            static func selectProfile(_ profile: String) -> Event {
                Event.tapElement(
                    screenName: screenName,
                    eventCategory: "profiles",
                    eventLabel: profile.analyticsLabel,
                    eventContent: "status"
                )
            }
        }
    }
}
```

Call sites:

```swift
ProfileSelectorView()
    .trackAppearance(event: Profiles.Analytics.ProfileSelector.screenAppear)

Button {
    trackEvent(Profiles.Analytics.ProfileSelector.selectProfile(profile.name))
} label: {
    Text(title)
}
```

For Relux effect-based analytics packages, the typed tree should return the
public event model used by the effect API:

```swift
extension Checkout {
    enum Analytics {
        enum Payment {
            static func started(spanID: AnalyticsSDK.SpanID) -> AnalyticsSDK.Event {
                .continuous(.start(.init(
                    name: "payment_started",
                    finishEventName: "payment_finished",
                    spanID: spanID,
                    staleTimeout: 30,
                    parameters: ["screen": .string("checkout")]
                )))
            }
        }
    }
}
```

## Flow

- Prefer `Relux.Flow` when the caller may need success/failure, navigation,
  dismissal, or inline error handling from the operation result.
- Use `Relux.Saga` for fire-and-forget background work and cross-domain
  orchestration.
- Define a module-local protocol, for example `protocol IFlow: Relux.Flow {}`.
- Define the actor separately, then conform in an extension:
  `extension Auth.Flow: Auth.IFlow`.
- Give flows an explicit `let dispatcher: Relux.Dispatcher`.
- Accept `dispatcher: Relux.Dispatcher? = nil` in the initializer for tests;
  fallback to `await Self.defaultDispatcher` only as the runtime default.
- `apply(_:)` should switch on `effect as? <Module>.Effect`.
- Return `.success` for foreign effects.
- For empty skeleton flows, keep the direct optional switch shape with
  `case .none: .success`; do not introduce `guard` plus `internalApply` until
  real logic exists.
- Delegate real effect cases to private methods once logic appears.
- Dispatch follow-up state changes via `await actions { <Module>.Action... }`.
- Return `.failure(error)` only when the flow outcome itself should be
  observable by the caller.

## Errors

- Keep module-local errors under `<Module>/Error/`.
- Use a short module-local type such as `Err`.
- Prefer typed cases over generic wrappers once a real failure mode exists.

## Tests

- Tests must use the current app/root namespace. If the app type is renamed,
  update tests from the old namespace in the same change.
- Composition tests should assert that the module registers its states and flows
  into Relux.
- Flow tests should cover unknown foreign effects returning `.success`.
- Add reducer tests once actions mutate state.
- Avoid tests that lock in fake SDK/auth/product behavior before the real
  integration contract exists.

