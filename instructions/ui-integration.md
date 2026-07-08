# UI Integration Workflow

Use this workflow when connecting Relux state/effects to SwiftUI.

- Read [../references/swiftui/swiftui-relux.md](../references/swiftui/swiftui-relux.md)
  for containers, pages, local SwiftUI state, temporal state, logout transition,
  and `.refreshable` rules.
- Read [../references/router/relux-router.md](../references/router/relux-router.md)
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
- In `.refreshable`, start long Relux work with `performAsync`; do not bind the
  SwiftUI refresh lifecycle to a slow awaited action.
