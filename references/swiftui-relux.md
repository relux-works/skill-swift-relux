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

