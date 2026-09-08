# Temporal State Snippet

Attach temporal state at the container boundary.

```swift
struct MoneyTransferContainer: View {
    @StateObject private var state = MoneyTransfer.State()

    var body: some View {
        content
            .reluxTemporal(state: state)
    }
}
```

`.reluxTemporal` resolves Relux from the SwiftUI environment, so the view does
not need a runtime property or parameter. Do not use `onConnect` to obtain a
runtime/dispatcher or inject the connected state into a flow. Dispatch
primary-runtime view events through top-level `action` / `actions` or
`performAsync`.

The container owns the state through `@StateObject`; the store keeps only a
weak reference. When the view dies, the state can die with it, with no explicit
cleanup or disconnect.

Do not inject this state into a flow for later reads. Relux does not currently
expose a stable temporal-state lookup accessor, and a flow-held reference would
escape the view lifecycle. Pass an immutable `Sendable` snapshot in the
triggering effect/action or use a lifecycle-stable business/service dependency.

A future runtime state accessor may materialize connected temporal state once
lookup, absence, lifetime, and actor-isolation semantics are defined. Do not
emulate that future API with direct runtime access today.
