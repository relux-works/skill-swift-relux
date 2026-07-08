# Modular ProjectingRouter Snippet

Use this shape when one app-level stack must host app pages, module pages pushed
through Relux actions, and module pages inserted by native SwiftUI links.

```swift
import Relux
import ReluxRouter
import SwiftUI

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

@MainActor
struct AppContent: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            CatalogModule.Container {
                RootPage()
                    .navigationDestination(for: AppPage.self) { page in
                        AppDestination(page: page)
                    }
            }
        }
    }
}

enum CatalogModule {
    enum Page: Hashable, Sendable {
        case detail(id: String)
        case specs(id: String, openedBy: String)
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
                CatalogDetailPage(id: id)
            case let .specs(id, openedBy):
                CatalogSpecsPage(id: id, openedBy: openedBy)
            }
        }
    }

    @MainActor
    struct LinksSection: View {
        var body: some View {
            Section("Catalog") {
                NavigationLink(page: .detail(id: "item-42")) {
                    Text("Open via Relux")
                }

                SwiftUI.NavigationLink(
                    value: Page.specs(id: "native-specs", openedBy: "root")
                ) {
                    Text("Open via native SwiftUI")
                }
            }
        }
    }
}
```

Keep the projection inspectable, not routable:

```swift
struct ProjectionSection: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ForEach(Array(router.projectedPathStrings.enumerated()), id: \.offset) { _, projection in
            Text(projection)
        }
    }
}
```

If a module page projection should be shorter or more stable, override only the
projection payload:

```swift
extension CatalogModule.Page: Relux.Navigation.PathProjectionRepresentable {
    var navigationPathProjectionDescription: String {
        switch self {
        case let .detail(id):
            "catalog/detail/\(id)"
        case let .specs(id, openedBy):
            "catalog/specs/\(id)?from=\(openedBy)"
        }
    }
}
```

Do not replace module page types with a shared app enum, `AnyPage`, or
`PathProjection` destination type. The concrete module page type is what keeps
SwiftUI destination resolution local to the module container.
