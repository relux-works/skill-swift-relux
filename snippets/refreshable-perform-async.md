# Refreshable PerformAsync Snippet

Do not await a slow Relux action directly from `.refreshable`.

```swift
List(items) { item in
    ItemRow(item: item)
}
.refreshable {
    performAsync {
        Feed.Effect.refresh
    }
}
```

Use state to render progress, result, or errors from the refresh. Await inside
`.refreshable` only for intentionally short work where SwiftUI's refresh spinner
should be tied to that exact operation.
