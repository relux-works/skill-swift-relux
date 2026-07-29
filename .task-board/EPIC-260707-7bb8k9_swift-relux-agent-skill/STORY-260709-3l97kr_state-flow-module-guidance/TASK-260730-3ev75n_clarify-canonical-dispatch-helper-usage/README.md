# TASK-260730-3ev75n: clarify-canonical-dispatch-helper-usage

## Description
Correct dispatch and temporal-state guidance around runtime identity: ordinary primary-application code uses top-level await action/actions; explicit Relux/Dispatcher is limited to host-library lifecycle integrations and isolated integration tests. Model SwiftUI temporal state as a view-owned HybridState connected declaratively through .reluxTemporal(state:) to the environment runtime, without direct runtime access at view call sites. Document that temporal state is not currently a stable injectable Flow dependency and may later be materialized through a runtime state accessor. Align evidence with swiftui-relux, relux-sample, and Swipe2Cash while retaining actor-first, MainActor, and Sendable guidance.

## Scope
Swift Relux runtime-identity dispatch, declarative SwiftUI temporal-state ownership, current Flow dependency limitation/future accessor direction, three-repository evidence, and installed-copy validation.

## Acceptance Criteria
Primary-runtime examples use top-level await action/actions; explicit Relux/Dispatcher examples exist only for host-library lifecycle and isolated integration tests; temporal-state examples use view-owned state with .reluxTemporal(state:) and no direct runtime at view call sites; current lack of stable temporal-state Flow injection and possible future runtime accessor are explicit; evidence pins swiftui-relux, relux-sample, and Swipe2Cash; actor-first/MainActor/Sendable guidance remains intact; source and installed validation pass.
