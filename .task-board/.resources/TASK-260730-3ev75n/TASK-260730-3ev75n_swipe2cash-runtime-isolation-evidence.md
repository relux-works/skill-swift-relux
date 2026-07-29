# Swipe2Cash Runtime And Isolation Evidence

## Scope

- App commit: `bb93fe4772b0543428f484bdd791923c5d728a7e`
- Package commit: `d21e95c8c02480a146993cb94bf9277ad89ec989`

## Findings

- Host/library lifecycle integration uses the host-materialized
  `ReluxProvider` runtime explicitly.
- Isolated integration tests construct `Relux.Dispatcher(logger:)`, inject it
  into Flow/Saga, and assert that exact event bus.
- `S2CDemo.Content` retains the host runtime and dispatches analytics through
  it. Because that is an ordinary primary-runtime SwiftUI task, it is
  call-site drift and a migration candidate, not another explicit-runtime
  exception.
- Ordinary package/UI code otherwise uses top-level helpers; a nearby runtime
  does not justify direct dispatcher access.
- Focused searches found no `.reluxTemporal` call site in this snapshot.
  Temporal guidance therefore follows the pinned `swiftui-relux` connector,
  not an invented Swipe2Cash precedent: the view connects with
  `.reluxTemporal(state:)`, which reads Relux from the environment.
- Flow/Saga and mutable asynchronous dependencies remain actor-first;
  UI/platform and synchronous third-party main-thread adapters use narrow
  `@MainActor` isolation, and cross-task contracts are `Sendable`.
