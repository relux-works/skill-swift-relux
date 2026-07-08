# Swift Relux Skill Micro-Spec

## Purpose

This skill captures agent-facing rules and usage cases for the Relux Swift
architecture stack maintained under the `relux-works` GitHub organization.

The skill should help agents:

- recognize Relux-based Swift and SwiftUI code;
- choose the right Relux state type and module shape;
- integrate Relux runtime objects into SwiftUI roots;
- wire SwiftUI navigation through Relux routers;
- keep module namespaces, reducers, effects, flows, and tests consistent;
- avoid placeholder behavior that hides missing product or architecture
  decisions.

## Target Libraries

- `github.com/relux-works/swift-relux`
  - Swift concurrency-oriented unidirectional data flow library.
  - Product/module: `Relux`.
- `github.com/relux-works/swiftui-relux`
  - SwiftUI integration helpers for Relux runtime resolution, environment
    injection, and temporal state connection.
  - Product/module: `SwiftUIRelux`.
- `github.com/relux-works/swiftui-reluxrouter`
  - SwiftUI navigation routers under `Relux.Navigation`.
  - Product/module: `ReluxRouter`.

## Initial Use Cases

- Add a new feature module with namespace, module entrypoint, state, actions,
  effects, flow, and tests.
- Decide between `HybridState` and `BusinessState` plus `UIState`.
- Add or review a reducer.
- Add or review a flow/saga handling asynchronous effects.
- Connect a SwiftUI root through `Relux.Resolver`.
- Connect modal or wizard state through `reluxTemporal(state:)`.
- Configure navigation through `Relux.Navigation.Router` or
  `Relux.Navigation.ProjectingRouter`.
- Review a Relux package boundary or public namespace facade.

## Non-Goals For The First Version

- Do not encode app-specific product names, Jira IDs, bundle identifiers, or
  one-off workspace paths.
- Do not prescribe one global app composition model for every Relux app.
- Do not duplicate full API docs; keep this skill as a compact agent workflow
  guide with references to local package source when exact signatures matter.

