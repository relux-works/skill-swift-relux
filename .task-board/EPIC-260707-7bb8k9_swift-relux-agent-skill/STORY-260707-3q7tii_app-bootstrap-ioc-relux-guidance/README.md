# STORY-260707-3q7tii: app-bootstrap-ioc-relux-guidance

## Description
Document production Relux app bootstrapping patterns from Swipe2Cash: scaffolded IoC registry, AppDelegate/App init bootstrap, Relux.Resolver, state propagation, and dispatcher helper usage.

## Scope
Add reference documentation to the swift-relux agent skill so future agents build SwiftUI Relux apps through the established scaffolded composition pattern instead of ad hoc App.body wiring. The guidance must be based on Swipe2Cash demo and swiftui-relux implementation details.

## Acceptance Criteria
- Skill docs describe scaffolded IoC/Registry setup for Relux runtime and modules.
- Skill docs explain why app init/AppDelegate-style bootstrap configures synchronous platform/SDK concerns and starts the registry before Relux.Resolver runs.
- Skill docs explain Relux.Resolver behavior, including async waiting, .relux(relux), and passing registered observable states into SwiftUI environment objects.
- Skill docs explain await actions, await action, and performAsync usage boundaries.
- Skill docs include compact code snapshots based on Swipe2Cash and SwiftUIRelux patterns.
- Installed ~/.agents skill copy is refreshed from the source repo setup flow after source changes.
