# Relux Router

`swiftui-reluxrouter` provides SwiftUI navigation routers under
`Relux.Navigation`.

## ProjectingRouter

Use `ProjectingRouter` when the app needs both a SwiftUI navigation path and a
projected/inspectable path.

```swift
@MainActor
public final class ProjectingRouter<Page>: Relux.Navigation.RouterProtocol, ObservableObject
where Page: PathComponent, Page: Sendable
```

Actions:

```swift
public enum Action: Relux.Action {
    case push(page: Page, allowingDuplicates: Bool = false)
    case set(pages: [Page])
    case removeLast(count: Int = 1)
}
```

Use this router with SwiftUI reference-semantics environment patterns such as
`@EnvironmentObject`.

## Router

Use `Router` for simpler modern SwiftUI navigation.

```swift
@Observable @MainActor
public final class Router<Page>: Relux.Navigation.RouterProtocol
where Page: PathComponent, Page: Sendable
```

Actions:

```swift
public enum Action: Relux.Action {
    case push(page: Page)
    case set(pages: [Page])
    case removeLast(count: Int = 1)
}
```

## Page Types

Define app pages as `Relux.Navigation.PathComponent` under a domain namespace:

```swift
extension UI.Dashboard { enum Navigation {} }

extension UI.Dashboard.Navigation {
    enum Page: Relux.Navigation.PathComponent {
        case info
        case details
    }
}
```

## Registration

Resolve concrete page types at app/module composition boundaries:

```swift
routers: [
    Relux.Navigation.Router<UI.Dashboard.Navigation.Page>(),
    Relux.Navigation.Router<UI.Profile.Navigation.Page>()
]
```

## Dispatching Navigation

Dispatch router actions like regular Relux actions:

```swift
Button {
    Task {
        await action {
            Relux.Navigation.ProjectingRouter.Action.push(
                page: UI.Dashboard.Navigation.Page.info
            )
        }
    }
} label: {
    Text("Info Page")
}
```

Keep navigation mutations in route actions. Avoid mixing direct
`NavigationPath` mutation with Relux router dispatch in the same flow unless the
code is explicitly bridging legacy navigation.

