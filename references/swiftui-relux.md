# SwiftUIRelux

## Relux Resolver

Use `Relux.Resolver` when a SwiftUI root must wait for an async `Relux` runtime
before rendering product UI:

```swift
Relux.Resolver(
    splash: ProgressView.init,
    content: { _ in
        AppContent()
    },
    resolver: {
        await makeRelux()
    }
)
```

After resolution, `Relux.Resolver`:

- stores the resolved `Relux` in SwiftUI environment as `\.relux`;
- passes registered Relux UI states to SwiftUI environment objects;
- keeps the splash visible until the runtime exists.

The resolver closure must only build/resolve and return the `Relux` runtime.
Do not dispatch startup actions/effects from inside the resolver closure:

```swift
Relux.Resolver(
    splash: Splash.init,
    content: { relux in
        AppContent(relux: relux)
    },
    resolver: {
        await Registry.resolveAsync(Relux.self)
    }
)
```

Startup dispatch belongs in the rendered content, usually in `.task`, after
`Relux.Resolver` has switched from splash to content and applied both
`.relux(relux)` and `.passingObservableToEnvironment(fromStore:)`:

```swift
struct AppContent: View {
    let relux: Relux

    var body: some View {
        RootView()
            .task {
                await relux.dispatcher.actions {
                    App.Effect.start
                    Auth.Effect.restoreSession
                }
            }
    }
}
```

This ordering matters. If startup actions mutate state or switch navigation
while the resolver is still resolving, SwiftUI has not yet received the Relux
environment object graph for the content hierarchy. Route/state updates can be
missed by views that have not been connected yet.

Views rendered below `Relux.Resolver` can read:

```swift
@Environment(\.relux) private var relux
```

Use the public `.relux(_:)` modifier for custom composition surfaces, previews,
tests, or presentation paths that are not rendered under `Relux.Resolver`:

```swift
AppContent()
    .relux(relux)
```

## App Bootstrap

In SwiftUI apps, keep synchronous platform bootstrap in `App.init` or an
`UIApplicationDelegate` bridge:

- configure UIKit appearance, fonts, SDK global flags, and automation switches;
- call the IoC registry setup, for example `Registry.configure()`;
- avoid async Relux dispatch from `init`/AppDelegate callbacks unless the UI
  hierarchy is already rendered and connected to Relux.

The app entry point should hand runtime construction to `Relux.Resolver`:

```swift
@main
struct DemoApp: App {
    init() {
        Registry.configure()
    }

    var body: some Scene {
        WindowGroup {
            Relux.Resolver(
                splash: Splash.init,
                content: { relux in AppContent(relux: relux) },
                resolver: { await Registry.resolveAsync(Relux.self) }
            )
        }
    }
}
```

Use `UIApplicationDelegateAdaptor` only for platform callbacks that truly belong
to UIKit lifecycle. Keep Relux module composition in the registry and keep
startup state/navigation dispatch in rendered SwiftUI content.

## Temporal State

For wizard-style or modal flows, keep temporal state owned by the SwiftUI
container and connect it to the current `Relux.Store`:

```swift
struct MoneyTransferFlow: View {
    @StateObject private var state = MoneyTransfer.State()

    var body: some View {
        content
            .reluxTemporal(state: state)
    }
}
```

When startup actions need the temporal state to already be registered, use
`onConnect`:

```swift
content
    .reluxTemporal(state: state) { relux, state in
        await relux.dispatch(StartSessionEffect(state: state))
    }
```

Rules:

- `onConnect` runs only after the store registers and returns the connected
  state.
- `Relux.Store` stores temporal states weakly.
- The SwiftUI container must own temporal state, usually with `@StateObject`.
- When the container is dismissed, the temporal state can be released with it.

