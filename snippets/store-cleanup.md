# Store Cleanup Snippet

Use `Relux.Store.cleanup(exclusions:)` for app-wide session cleanup.

```swift
await store.cleanup(exclusions: [
    AppRouter.self,
    FeatureManagement.Business.State.self,
    NetworkMonitor.Business.State.self,
])
```

Logout should route away from product views before cleanup.

```swift
await dispatcher.actions {
    AppRouter.Action.set([.auth(state: .logoutInProgress)])
}

await sessionService.logout()
await store.cleanup(exclusions: [AppRouter.self])

await dispatcher.actions {
    AppRouter.Action.set([.auth(state: .initial)])
}
```
