# Temporal State Ownership Evidence

## Pinned sources

- `swiftui-relux` `main`: `69fbc12f8f79a15930d78570df6fa608b0847b61`.
- `swift-relux`: `17efec6d94190ab318ea57cc76dabaad1fc3cf2c`.

## Observed contract

- `Relux.Resolver` renders root content with `.relux(relux)`, placing the runtime in `EnvironmentValues.relux`.
- `.reluxTemporal(state:)` reads `@Environment(\.relux)` inside its private connector and calls `relux.store.connectTemporally(state:)` from a SwiftUI `.task`. The view call site supplies the state, not a runtime.
- The SwiftUI container owns temporal state through `@StateObject`. `Relux.Store.StateRef` holds the connected `HybridState` weakly, so view dismissal can release the state without cleanup or disconnect.
- The canonical view call site uses `.reluxTemporal(state:)` without
  `onConnect` runtime/dispatcher access. Primary-runtime view events use
  top-level `action` / `actions`.
- Current `Store.getState(HybridState.self)` reads durable `businessStates`,
  not `tempStates`. Temporal state is not currently a stable injectable
  Flow/Saga dependency. Pass an immutable `Sendable` snapshot or use a
  lifecycle-stable dependency.
- A future runtime state accessor that materializes the currently live temporal
  instance is a design direction, not current API.

## Correction

Temporal attachment is not an exact-runtime/direct-dispatch exception. This outcome supersedes earlier task text that classified `.reluxTemporal` that way.
