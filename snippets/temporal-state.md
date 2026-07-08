# Temporal State Snippet

Attach temporal state at the container boundary.

```swift
struct MoneyTransferFlow: View {
    @StateObject private var state = MoneyTransfer.State()

    var body: some View {
        content
            .reluxTemporal(state: state)
    }
}
```

Use `onConnect` when startup actions need the temporal state to be registered
before dispatch.

```swift
content
    .reluxTemporal(state: state) { relux, state in
        await relux.dispatch(StartSessionEffect(state: state))
    }
```
