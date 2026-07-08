# TASK-260707-2glam4: document-ioc-resolver-dispatcher-patterns

## Description
Update swift-relux skill references with IoC-based app bootstrap, AppDelegate/App init nuance, SwiftUIRelux Resolver state propagation, and dispatcher helper guidance.

## Scope
Update /Users/alexis/src/relux-works/skill-swift-relux references, especially relux-core.md and swiftui-relux.md, with concrete guidance from Swipe2Cash demo and SwiftUIRelux source. Do not edit ~/.agents directly; refresh installed runtime copy through the skill repo setup flow after source changes.

## Acceptance Criteria
- relux-core.md documents IoC/Registry-based Relux runtime composition: register Relux infrastructure, register modules/dependencies, build Relux with store/rootSaga/logger from IoC, and register modules inside the Relux builder.
- relux-core.md documents dispatcher helpers: await actions for one or more actions/effects with serial/concurrent execution and result observation, await action for a single action/effect, performAsync for synchronous SwiftUI callbacks that need to fire async Relux work without blocking.
- swiftui-relux.md documents App init/AppDelegate bootstrapping nuance: configure synchronous platform/SDK/global appearance concerns and call Registry.configure() before Relux.Resolver starts async runtime resolution.
- swiftui-relux.md documents Relux.Resolver internals: splash while resolver awaits, content(relux).relux(relux).passingObservableToEnvironment(fromStore: relux.store), and consequences for Environment relux and EnvironmentObject states.
- Docs include compact code snapshots based on Swipe2Cash demo paths: S2CDemo+Registry.swift, S2CDemo+App.swift, View+ReluxResolver.swift, View+ReluxEnvironment.swift, Relux+Dispatcher+Interface.swift.
- Source repo changes are validated and installed copy under ~/.agents/skills/swift-relux reflects the new docs.
