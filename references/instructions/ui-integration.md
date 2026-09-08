# UI Integration Workflow

Use this workflow when connecting Relux state/effects to SwiftUI.

- Read [../swiftui/swiftui-relux.md](../swiftui/swiftui-relux.md)
  for containers, pages, local SwiftUI state, temporal state, logout transition,
  and `.refreshable` rules.
- Read [../router/relux-router.md](../router/relux-router.md)
  when UI changes affect navigation stacks or route projections.
- Use [../snippets/swiftui-container-page.md](../snippets/swiftui-container-page.md)
  for a container/page props-reactions-styles-resources example.
- Use [../snippets/temporal-state.md](../snippets/temporal-state.md) for
  `.reluxTemporal` attachment examples.
- Use [../snippets/refreshable-perform-async.md](../snippets/refreshable-perform-async.md)
  for pull-to-refresh dispatch.
- Keep containers as thin Relux integration layers.
- Keep pages and reusable views free from Relux runtime access.
- Use local SwiftUI state for view-only details instead of promoting every bit
  into Relux.
- Use top-level `action`/`actions` for ordinary application dispatch even when
  a resolver or environment happens to expose a concrete `Relux` runtime.
- Attach temporal state with `.reluxTemporal(state:)`. It reads Relux from the
  SwiftUI environment; the view should not receive or pass a runtime merely to
  make the connection.
- Do not use `onConnect` to obtain a runtime/dispatcher or inject the connected
  state into a flow. The canonical view call site is the declarative
  `.reluxTemporal(state:)` form.
- Temporal state is not currently a stable injectable `Flow` dependency. Pass
  immutable `Sendable` values in effects/actions until a future runtime state
  accessor defines materialization and lifetime semantics.
- Preserve exact runtime identity only in host-library lifecycle integrations
  and isolated integration tests that own their dispatcher/logger event bus.
- Read [../snippets/dispatch-runtime-selection.md](../snippets/dispatch-runtime-selection.md)
  before choosing a direct dispatcher call.
- In `.refreshable`, start long Relux work with `performAsync`; do not bind the
  SwiftUI refresh lifecycle to a slow awaited action.
