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

The resolver closure must only build/resolve and return the `Relux` runtime.
Do not dispatch startup actions/effects from inside the resolver closure:

```swift
Relux.Resolver(
    splash: Splash.init,
    content: { relux in
        AppContent(relux: relux)
    },
    resolver: {
        await Registry.resolveAsync(Relux.self)
    }
)
```

Startup dispatch belongs in the rendered content, usually in `.task`, after
`Relux.Resolver` has switched from splash to content and applied both
`.relux(relux)` and `.passingObservableToEnvironment(fromStore:)`:

```swift
struct AppContent: View {
    let relux: Relux

    var body: some View {
        RootView()
            .task {
                await relux.dispatcher.actions {
                    App.Effect.start
                    Auth.Effect.restoreSession
                }
            }
    }
}
```

This ordering matters. If startup actions mutate state or switch navigation
while the resolver is still resolving, SwiftUI has not yet received the Relux
environment object graph for the content hierarchy. Route/state updates can be
missed by views that have not been connected yet.

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

## App Bootstrap

In SwiftUI apps, keep synchronous platform bootstrap in `App.init` or an
`UIApplicationDelegate` bridge:

- configure UIKit appearance, fonts, SDK global flags, and automation switches;
- call the IoC registry setup, for example `Registry.configure()`;
- avoid async Relux dispatch from `init`/AppDelegate callbacks unless the UI
  hierarchy is already rendered and connected to Relux.

The app entry point should hand runtime construction to `Relux.Resolver`:

```swift
@main
struct DemoApp: App {
    init() {
        Registry.configure()
    }

    var body: some Scene {
        WindowGroup {
            Relux.Resolver(
                splash: Splash.init,
                content: { relux in AppContent(relux: relux) },
                resolver: { await Registry.resolveAsync(Relux.self) }
            )
        }
    }
}
```

Use `UIApplicationDelegateAdaptor` only for platform callbacks that truly belong
to UIKit lifecycle. Keep Relux module composition in the registry and keep
startup state/navigation dispatch in rendered SwiftUI content.

## Containers And Views

The Relux world should end at SwiftUI containers. Treat containers like
Redux-style containers: thin integration layers between Relux and plain UI.

Container responsibilities:

- read Relux state through environment/state objects;
- dispatch actions and effects;
- connect temporal state with `.reluxTemporal`;
- map business/UI state into plain view models or value props;
- pass callbacks such as `onAppear`, `onTap`, `onSubmit`, or `onCancel` to the
  UI tree.

Pages and reusable views rendered inside containers should stay Relux-runtime
free. They should not read Relux global state, subscribe to environment objects
directly, or dispatch actions/effects. If the local codebase uses
`Relux.UI.View`, `Relux.UI.ViewProps`, or `Relux.UI.ViewCallbacks`, treat those
as lightweight UI shape protocols only; do not use them as permission to reach
back into the store. Prefer plain SwiftUI inputs and callbacks so pages are
previewable, testable, and reusable without constructing a Relux runtime.

Recommended shape:

```swift
struct TransferContainer: Relux.UI.Container {
    @EnvironmentObject private var state: MoneyTransfer.UI.State

    var body: some View {
        TransferPage(
            props: .init(state),
            reactions: .init(
                onSubmit: Relux.UI.ViewCallback { amount in
                    await actions {
                        MoneyTransfer.Effect.submit(amount: amount)
                    }
                },
                onCancel: Relux.UI.ViewCallback {
                    await actions {
                        MoneyTransfer.Action.cancelTapped
                    }
                }
            ),
            styles: .default,
            resources: .localized
        )
    }
}

struct TransferPage: Relux.UI.View {
    let props: Props
    let reactions: Reactions
    let styles: Styles
    let resources: Resources

    var body: some View {
        VStack(spacing: styles.sectionSpacing) {
            TransferHeader(title: resources.title)
            TransferAmountSection(amount: props.amount, onSubmit: reactions.onSubmit)
            TransferFooter(onCancel: reactions.onCancel)
        }
    }

    struct Props: Relux.UI.ViewProps {
        let amount: Decimal?

        init(_ state: MoneyTransfer.UI.State) {
            amount = state.amount
        }
    }

    struct Reactions: Relux.UI.ViewCallbacks {
        let onSubmit: Relux.UI.ViewCallback<Decimal>
        let onCancel: Relux.UI.ViewCallback<Void>
    }

    struct Styles: Equatable, Hashable, Sendable {
        let sectionSpacing: CGFloat

        static let `default` = Styles(sectionSpacing: 16)
    }

    struct Resources: Equatable, Hashable, Sendable {
        let title: String

        static let localized = Resources(title: l10n.transfer.title)
    }
}
```

For pages and reusable components, group incoming parameters by role:

- `Props`: values to render, derived state, selection, loading/error flags;
- `Reactions`: callbacks/events emitted by the view;
- `Styles`: visual configuration, spacing, colors, size variants, component
  style knobs;
- `Resources`: externally provided localized strings, images, icons, or other
  assets when the page/component should not hard-code them.

This shape keeps data, behavior, visual customization, and resources from
turning into a long mixed parameter list. Small leaf views may inline one or two
parameters when grouping would add noise, but pages and components with a real
API should prefer the grouped shape.

Some older Relux sample code names the callback group `Actions`. When touching
legacy modules, follow the local convention. For new UI code, prefer
`Reactions` for view callbacks so the type does not get confused with
`Relux.Action`, which is the state-transition action type.

Decompose SwiftUI views by abstraction level, not by accidental line count.
Use a hierarchy such as container -> page -> section -> component/control. Avoid
large SwiftUI "scrolls" where product state mapping, layout, controls, and
business callbacks all live in one `body`.

File naming should follow the same namespace shape:

- `<Module>+UI+TransferContainer.swift`
- `<Module>+UI+TransferPage.swift`
- `<Module>+UI+TransferAmountSection.swift`
- `<Module>+UI+TransferFooter.swift`

## Local SwiftUI State

As with React plus Redux, not every UI bit belongs in Relux. Keep state local to
the SwiftUI view when it only describes that view's immediate presentation and
does not need to be shared, replayed, persisted, observed by flows/sagas, or
restored after the view disappears.

Good local SwiftUI state examples:

- focus, pressed, expanded, selected tab/segment, hover, drag, and animation
  flags;
- a text-field draft that is submitted as a value and has no cross-screen
  lifetime;
- sheet/popover toggles owned by one page;
- purely visual measurement/cache state.

Use `@State`, `@FocusState`, `@GestureState`, or a small view-owned
`@StateObject` for these cases. Do not promote this data to Relux only because
the view is rendered under a Relux container.

Ownership ladder:

- view-local UI detail -> local SwiftUI state;
- presentation/session state shared across views inside one active container ->
  temporal state attached with `.reluxTemporal`;
- product/business state that must be shared, observed by effects, restored, or
  survive presentation changes -> Relux `HybridState`, `BusinessState`, or
  `UIState`.

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

Use temporal state for short-lived interaction state that belongs to the
currently rendered container rather than to durable product state: wizard step
drafts, modal input, active gesture/session UI, camera/call preview controls,
or other data that should disappear with the presentation. This keeps global
Relux modules from accumulating screen-local scratch fields.

Attach temporal state at the container boundary, not inside individual leaf
views:

```swift
struct TransferContainer: View {
    @StateObject private var flowState = MoneyTransfer.UI.FlowState()

    var body: some View {
        TransferContent(state: flowState)
            .reluxTemporal(state: flowState)
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
- Do not pass temporal state into a long-lived `Flow` or `Saga` as a dependency
  for later data reads. The state is weakly registered and presentation-scoped;
  after dismissal, the object may be gone or no longer describe the active
  product flow.
- If a flow needs the value, pass a snapshot in the triggering effect/action or
  promote the data to durable module state (`HybridState` or `BusinessState`).
