# Dispatch Runtime Selection

Choose the dispatch surface by runtime identity, not by whether a `Relux`
instance happens to be easy to reach.

## Primary Application Runtime

Use top-level helpers in ordinary application code that targets the initialized
primary runtime:

```swift
await action {
    Notes.Action.refreshRequested
}

await actions {
    Session.Action.restored(session)
    Router.Action.set([.home])
}
```

Do not replace these calls with `relux.dispatcher.action(s)` merely because a
view, resolver, or composition closure exposes a `Relux` value.

## Saga Or Flow Dispatcher

Use unqualified instance helpers inside a `Relux.Saga` or `Relux.Flow`. They
dispatch through `self.dispatcher`, so an injected test dispatcher is preserved:

```swift
actor RefreshFlow: Relux.Flow {
    let dispatcher: Relux.Dispatcher

    init(dispatcher: Relux.Dispatcher? = nil) async {
        let defaultDispatcher = await Self.defaultDispatcher
        self.dispatcher = dispatcher ?? defaultDispatcher
    }

    func apply(_ effect: any Relux.Effect) async -> Relux.ActionResult {
        await action {
            Notes.Action.refreshCompleted
        }
    }
}
```

An integration test owns the event bus explicitly:

```swift
let logger = Relux.Testing.Logger()
let dispatcher = Relux.Dispatcher(logger: logger)
let flow = await RefreshFlow(dispatcher: dispatcher)

_ = await flow.apply(Notes.Effect.refresh)

#expect(logger.actions.contains { recorded in
    guard let recorded = recorded as? Notes.Action else { return false }
    if case .refreshCompleted = recorded { return true }
    return false
})
```

## Temporal State Is Not A Runtime Exception

`.reluxTemporal(state:)` resolves Relux from the SwiftUI environment. Do not
pass a runtime into the view, use `onConnect` to obtain a dispatcher, or inject
the connected state into a flow:

```swift
content
    .reluxTemporal(state: state)
```

The state remains owned by the view, while the store keeps a weak reference.
Relux does not currently expose a stable temporal-state accessor for flows;
pass immutable `Sendable` input until a future runtime accessor defines the
materialization and lifetime contract.

## Host-Provided Runtime

Use an exact runtime when a host/library integration contract provides it.
Application lifecycle delegates and bootstrap bridges must await the provider
instead of assuming `Relux.shared` is already materialized:

```swift
protocol ReluxProvider: Sendable {
    @MainActor
    func resolveRelux() async -> Relux
}

@MainActor
func handleApplicationOpen(using provider: any ReluxProvider) async {
    let relux = await provider.resolveRelux()

    await relux.dispatcher.action {
        Library.Effect.handleApplicationOpen
    }
}
```

This is a runtime-identity exception, not a convenience shortcut.
`performAsync` targets `Relux.shared`, so do not use it when the provider-owned
runtime must be resolved and targeted explicitly.
