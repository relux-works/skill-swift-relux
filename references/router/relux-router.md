# Relux Router

`swiftui-reluxrouter` provides SwiftUI navigation routers under
`Relux.Navigation`.

Use the package source and sample when exact API details matter:

- [swiftui-reluxrouter](https://github.com/relux-works/swiftui-reluxrouter)
  for SDK code, Swift Testing coverage, and package README.
- [swiftui-reluxrouter-sample](https://github.com/relux-works/swiftui-reluxrouter-sample)
  for a Tuist/iOS app that wires `ProjectingRouter` through Relux/IoC and
  validates Relux-driven plus native SwiftUI route values in UI tests.

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

`ProjectingRouter` keeps `path` as the source of truth. Its `projectedPath` and
`projectedPathStrings` are computed from the live `NavigationPath`, including
values inserted outside Relux through native `NavigationLink(value:)` or direct
path mutation. Do not maintain a separate synchronized projection list.

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

Module-local pages that are pushed through
`Relux.Navigation.ProjectingRouterAction` or `Relux.NavigationLink` only need to
be `Hashable` and `Sendable`. They do not need to conform to a shared app page
protocol or enum:

```swift
enum CatalogModule {
    enum Page: Hashable, Sendable {
        case detail(id: String)
        case specs(id: String, openedBy: String)
    }
}
```

## Registration

Resolve app-owned routers at app/module composition boundaries:

```swift
routers: [
    Relux.Navigation.Router<UI.Dashboard.Navigation.Page>(),
    Relux.Navigation.Router<UI.Profile.Navigation.Page>()
]
```

For an app-level projected stack, register a single app router as a Relux state
and bind the outer `NavigationStack` to it:

```swift
enum AppPage: Relux.Navigation.PathComponent {
    case about
}

typealias AppRouter = Relux.Navigation.ProjectingRouter<AppPage>

struct NavigationModule: Relux.Module {
    let router: AppRouter
    let sagas: [any Relux.Saga] = []

    var states: [any Relux.AnyState] {
        [router]
    }
}
```

`Relux.Resolver` injects registered observable states into SwiftUI environment,
so the root container can read the router with `@EnvironmentObject`.

## Modular Projected Navigation

Use one outer `NavigationStack(path:)` for the app shell, then let each feature
module attach route handlers for its own concrete `Page` type inside the view
hierarchy. The app handler resolves only app pages. Module handlers refine or
extend navigation for descendants; they do not replace the app stack.

```swift
@MainActor
struct AppContent: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            CatalogModule.Container {
                ProfileModule.Container {
                    RootPage()
                        .navigationDestination(
                            for: AppPage.self,
                            destination: appDestination
                        )
                }
            }
        }
    }
}

enum CatalogModule {
    enum Page: Hashable, Sendable {
        case detail(id: String)
    }

    typealias NavigationLink<Label: View> = Relux.NavigationLink<Page, Label>

    @MainActor
    struct Container<Content: View>: View {
        @ViewBuilder let content: () -> Content

        var body: some View {
            content()
                .navigationDestination(for: Page.self, destination: Self.destination)
        }

        @ViewBuilder
        static func destination(for page: Page) -> some View {
            switch page {
            case let .detail(id):
                DetailPage(id: id)
            }
        }
    }
}
```

Module code can push into the shared projected path in two ways:

```swift
CatalogModule.NavigationLink(page: .detail(id: "item-42")) {
    Text("Open via Relux")
}

SwiftUI.NavigationLink(value: CatalogModule.Page.detail(id: "native-42")) {
    Text("Open via native SwiftUI")
}
```

Both paths append the original concrete `CatalogModule.Page` value to the same
SwiftUI `NavigationPath`. SwiftUI destination lookup still resolves by concrete
type, while `ProjectingRouter.projectedPathStrings` sees both Relux and native
values.

Rules:

- Do not introduce a common cross-module page enum or page protocol only for
  routing. It makes unrelated `navigationDestination` handlers compete for the
  same type and breaks nested module ownership.
- Do not register `navigationDestination` for `PathProjection`,
  `ProjectedPage`, or other projection-only wrappers. Projections are read-only
  fingerprints, not route values.
- Keep route parameters inside page cases. The projection includes parameters
  through reflection by default.
- If reflection is too noisy or a page carries non-renderable payloads, conform
  that page to `Relux.Navigation.PathProjectionRepresentable` and return a
  stable readable route string.
- Do not require `Codable` for projection. Non-codable pages and callback
  payload wrappers can still be projected.

## Subrouters

Use the app-level `ProjectingRouter` for modules that participate in the outer
app stack. A module-local "subrouter" is only appropriate when the module owns
an independent nested navigation stack, such as a wizard, modal flow, or
embedded feature shell.

For a subrouter:

- define the module's own root `Page` type conforming to
  `Relux.Navigation.PathComponent`;
- register `Relux.Navigation.ProjectingRouter<Module.Page>` as a module state;
- bind the nested `NavigationStack(path:)` inside the module container;
- keep that module's `navigationDestination` handlers inside the module
  container;
- expose a module-local `typealias NavigationLink<Label: View> =
  Relux.NavigationLink<Module.Page, Label>` if the module dispatches through
  Relux.

Do not use a subrouter merely to make module pages visible to the outer stack.
For ordinary app navigation, the outer projected path plus module-local
`navigationDestination(for: Module.Page.self)` is the intended pattern.

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

For module-local page types, prefer `Relux.NavigationLink<Page, Label>` or the
generic `Relux.Navigation.ProjectingRouterAction.push(.init(page))`. The
generic action pushes any `Hashable & Sendable` page value into the current
projected path without forcing that module to depend on the app's page type.
