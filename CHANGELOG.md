# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Changed

- Established top-level `action`/`actions` as the canonical application
  dispatch API, narrowed direct dispatcher calls to host-library lifecycle and
  isolated integration-test boundaries, and aligned SwiftUI, temporal-state,
  and logout examples with that rule.
- Documented temporal state as view-owned, weakly connected through the SwiftUI
  environment, requiring neither direct runtime plumbing nor explicit cleanup;
  also documented the current lack of a stable injectable Flow dependency and
  a possible future runtime state accessor.
- Added actor-first concurrency guidance for flows, sagas, and stateful async
  dependencies, with narrowly scoped `@MainActor` adapters for synchronous
  third-party main-thread contracts such as specific WebRTC or Unity bridges,
  while retaining immutable/stateless value types as valid exceptions.

## [v0.1.0] - 2026-07-14

### Added

- Initial standalone Swift Relux skill package with idempotent setup flow and local task board wiring.
- Instruction routing for app bootstrap, module authoring, UI integration, and logout cleanup workflows.
- Reference packs covering Relux core, SwiftUI integration, router patterns, module conventions, package conventions, and scope boundaries.
- Reusable snippets for IoC registries, modular `ProjectingRouter` composition, temporal state, refreshable async flows, store cleanup, localization, and product analytics.

### Changed

- Reorganized the reference tree and expanded guidance for metrics, localization, app bootstrap, state ownership, and modular router usage before the first tagged release.
