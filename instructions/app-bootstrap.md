# App Bootstrap Workflow

Use this workflow when wiring a Swift app to Relux, adding IoC registration, or
reviewing app startup.

- Inspect the app entry point, registry/composition root, and existing
  `Relux.Resolver` usage before changing code.
- Read [../references/core/relux-core.md](../references/core/relux-core.md) for
  `Relux`, `Store`, dispatcher, state, flow, and saga rules.
- Read [../references/swiftui/swiftui-relux.md](../references/swiftui/swiftui-relux.md)
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
