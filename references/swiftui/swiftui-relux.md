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
Do not dispatch ordinary primary-runtime startup actions/effects from inside
the resolver closure:

```swift
Relux.Resolver(
    splash: Splash.init,
    content: { _ in
        AppContent()
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
    var body: some View {
        RootView()
            .task {
                await actions {
                    App.Effect.start
                    Auth.Effect.restoreSession
                }
            }
    }
}
```

Use the top-level `action`/`actions` helpers for ordinary SwiftUI dispatch,
including rendered startup tasks and containers. `Relux.Resolver` exposing a
concrete runtime does not by itself make `relux.dispatcher` the preferred
dispatch API. Read the runtime from the environment when a view actually needs
runtime-owned facilities such as the store, not merely to choose a dispatch
path.

Runtime identity does matter at explicit boundaries. A host/library lifecycle
adapter must await its `ReluxProvider` and dispatch through the resolved
runtime. When resolving the exact runtime and bootstrapping an embedded library
are one host-owned operation, that bootstrap may dispatch through the resolved
runtime before returning it; do not copy that ordering into an ordinary app
startup task or temporal-state view. See
[../../snippets/dispatch-runtime-selection.md](../../snippets/dispatch-runtime-selection.md).

This ordering matters. If startup actions mutate state or switch navigation
while the resolver is still resolving, SwiftUI has not yet received the Relux
environment object graph for the content hierarchy. Route/state updates can be
missed by views that have not been connected yet.

Views rendered below `Relux.Resolver` can read:

```swift
@Environment(\.relux) private var relux
```

Use that access only for a custom composition/infrastructure surface that
actually owns runtime facilities. Ordinary dispatch and temporal-state
connection do not require it.

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
- defer ordinary startup dispatch until the UI hierarchy is rendered and
  connected to Relux;
- when a host/library lifecycle callback owns a `ReluxProvider` contract, await
  that provider and dispatch through its exact runtime.

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
                content: { _ in AppContent() },
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

See [../../snippets/swiftui-container-page.md](../../snippets/swiftui-container-page.md)
for a concrete container/page example.

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

## Business/UI State Projection

When a feature uses separate `BusinessState` and `UIState`, make the projection
pipeline explicit and one-directional: business state produces renderable UI
state, while UI events still dispatch actions/effects back into Relux.

- Put mapping code near the UI state or a module-local mapper, not in SwiftUI
  view bodies.
- Keep the projection lifecycle owned by the module/container so it is obvious
  when observation starts and stops.
- Avoid ad hoc Combine pipelines that cross actor isolation or make state
  propagation look synchronous.
- Do not write back into business state from the UI projection. Dispatch actions
  and let reducers mutate state.
- If the caller needs to wait for a completed operation, use a `Relux.Flow`
  result instead of assuming the projected `UIState` has already caught up after
  dispatch.

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

Temporal state is presentation-scoped `HybridState`. The SwiftUI container
owns it strongly and connects it declaratively to the `Relux` already present
in the environment:

```swift
struct MoneyTransferContainer: View {
    @StateObject private var state = MoneyTransfer.State()

    var body: some View {
        MoneyTransferPage(
            amount: state.amount,
            onAmountChanged: { amount in
                performAsync {
                    MoneyTransfer.Action.setAmount(amount)
                }
            }
        )
        .reluxTemporal(state: state)
    }
}
```

The `.reluxTemporal(state:)` modifier reads `@Environment(\.relux)` internally
and connects the state to that runtime's store. The call site should not retain
or read `Relux`, call `relux.store.connectTemporally`, or use `onConnect` to
obtain a dispatcher. Primary-runtime view events still use top-level
`action` / `actions` or `performAsync`.

The store holds connected temporal state through a weak reference, so the
view/container remains its lifetime owner. Do not call `cleanup()` or add an
explicit disconnect when the view disappears; releasing the view-owned state
ends that lifetime. Temporal state is not currently a stable injectable `Flow`
dependency:

- injecting the object lets the flow retain presentation-scoped state beyond
  the view lifecycle;
- the current public state lookup reads registered business/UI state and does
  not provide a temporal-state accessor;
- flows that need view input should receive immutable `Sendable` values in
  their effect/action or use a lifecycle-stable business/service dependency.

A future runtime state accessor may materialize the connected temporal state
for effect handling once lookup, absence, lifetime, and actor-isolation
semantics are explicit. Treat that as a future API direction; do not emulate it
today with direct environment-runtime or store access from the view.

See [../../snippets/temporal-state.md](../../snippets/temporal-state.md).

## Pull To Refresh

SwiftUI `.refreshable` can keep its refresh lifecycle stale when the closure
awaits a slow Relux action/effect. Do not bind pull-to-refresh directly to
long-running business work:

- use `performAsync { ... }` inside `.refreshable`;
- let the closure return promptly so SwiftUI can finish the gesture lifecycle;
- represent loading, result, and errors through Relux state observed by the view;
- await inside `.refreshable` only when the work is intentionally short and the
  system spinner should be tied to that exact operation.

See [../../snippets/refreshable-perform-async.md](../../snippets/refreshable-perform-async.md).

## Logout Transition

For logout/session reset, prefer a two-step transition:

- First route to a minimal `logoutInProgress` screen.
- Then perform token/session teardown, service shutdown, store cleanup, and the
  final route to the unauthenticated flow.

The intermediate screen is not cosmetic. It removes active product views from
the hierarchy, which lets SwiftUI cancel view-owned `.task` work and other
presentation-scoped async processes before `Relux.Store.cleanup(exclusions:)`
resets business state. Without this step, late updates from disappearing views
can dispatch actions into states that are already being cleaned, which creates
logout races.

Keep the `logoutInProgress` screen small:

- do not depend on user/session states that cleanup is about to reset;
- it may use `.task` only to dispatch the second-phase logout effect;
- keep long-running teardown work in a saga/flow, not in the view task itself;
- exclude only app-shell states that must survive cleanup, such as routers or
  app configuration.
