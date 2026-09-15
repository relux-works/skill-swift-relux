# App Bootstrap Workflow

Use this workflow when wiring a Swift app to Relux, adding IoC registration, or
reviewing app startup.

- Inspect the app entry point, registry/composition root, and existing
  `Relux.Resolver` usage before changing code.
- Read [../core/relux-core.md](../core/relux-core.md) for
  `Relux`, `Store`, dispatcher, state, flow, and saga rules.
- Read [../swiftui/swiftui-relux.md](../swiftui/swiftui-relux.md)
  for `Relux.Resolver`, SwiftUI environment injection, and startup dispatch
  ordering.
- Use [../snippets/ioc-registry.md](../snippets/ioc-registry.md) when a concrete
  registry example is useful.
- Use [../snippets/dispatch-runtime-selection.md](../snippets/dispatch-runtime-selection.md)
  when startup or application lifecycle code can run before the primary runtime
  is available.
- Keep synchronous platform setup in `App.init` or an app delegate bridge.
- Keep async startup dispatch in rendered SwiftUI content after the Relux runtime
  has been resolved and injected.
- When a host/library integration exposes a `ReluxProvider`, application
  lifecycle delegates must await that provider and dispatch through the resolved
  runtime. Do not replace that boundary with top-level helpers that assume
  `Relux.shared` is already materialized.
- Do not build Relux runtime infrastructure inside view bodies.

## Native macOS menu-bar apps

A `MenuBarExtra` popover may be created and destroyed repeatedly. Own the registry/runtime once at application scope; do not create a runtime per popover or in `body`. Use an `NSApplicationDelegateAdaptor` for the macOS application lifecycle. If background monitoring must start before the popover is opened, bootstrap through the application-owned runtime boundary, retain its task and await runtime registration before dispatching. Keep controls disabled until the first state refresh.

Use a thin SwiftUI container to map `HybridState` into plain page props and callbacks. Keep `Process` and launchd operations in an actor service called by a flow, with observable errors and balanced pending-state actions. Do not call shell commands synchronously on the main actor. Stopping an app's UI and stopping a managed external service are separate operations; make their behavior explicit in the UI.

When a `@MainActor` module conforms to the nonisolated `Relux.Module` protocol, `states` and `sagas` can be `nonisolated` computed properties over immutable `Sendable` actor/state references. Check this against the pinned package instead of suppressing isolation checking.
