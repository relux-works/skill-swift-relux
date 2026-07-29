# SwiftUIRelux Temporal-State Evidence

## Scope

- `swiftui-relux` commit:
  `69fbc12f8f79a15930d78570df6fa608b0847b61`
- `swift-relux` commit:
  `17efec6d94190ab318ea57cc76dabaad1fc3cf2c`
- `relux-sample` commit:
  `47236f2cea66a9ef7b72569d95383abf1b7d2c7d`
- Swipe2Cash app commit:
  `bb93fe4772b0543428f484bdd791923c5d728a7e`
- Swipe2Cash package commit:
  `d21e95c8c02480a146993cb94bf9277ad89ec989`

## Connector behavior

- `swiftui-relux/Sources/View+ReluxEnvironment.swift` exposes
  `.reluxTemporal(state:onConnect:)`.
- `ReluxTemporalStateConnector` reads `Relux` internally from
  `@Environment(\.relux)` and calls
  `relux.store.connectTemporally(state:)` from its view task.
- `onConnect` is optional. A call site can and should use
  `.reluxTemporal(state: state)` when it only needs declarative connection; the
  view does not need to read or retain `Relux`.
- The connector does not dispatch anything. Primary-runtime view events remain
  top-level `action` / `actions` calls.

## Ownership and current access limitation

- `Relux.Store.tempStates` stores weak `StateRef` entries. The runtime connects
  a temporal state but does not own its lifetime; the presenting SwiftUI view
  or container must own the state strongly.
- `Relux.Store.connectTemporally(state:)` returns the same state instance after
  registering its weak reference.
- The current public `getState(HybridState.Type)` implementation reads
  `businessStates`, not `tempStates`. No public temporal-state lookup accessor
  exists in the inspected `swift-relux` source.
- Inference: a view-owned temporal state is not currently a stable injectable
  `Flow` dependency. Injecting the object directly would let the flow retain
  presentation-scoped state and would bypass the runtime's weak lifecycle
  boundary.
- Current flow inputs should be immutable `Sendable` values carried by an
  effect/action or obtained from a stable business/service dependency.
- A future runtime state accessor may materialize temporal state for a flow
  when lookup, lifetime, absence, and actor-isolation semantics are designed.
  This is a possible API direction, not an existing capability.

## Sample comparison

- Focused searches found no `.reluxTemporal` call sites in `relux-sample` or
  the inspected Swipe2Cash app/package snapshots.
- Their existing `HybridState` implementations are main-actor classes; where
  a presentation owns one temporally, SwiftUI `@StateObject` is the compatible
  ownership model for current `ObservableObject` implementations.
- This absence means the skill's temporal example must follow the connector
  implementation directly rather than presenting an unverified product sample
  as precedent.

## Evidence commands

```bash
git -C /Users/alexis/src/relux-works/swiftui-relux rev-parse HEAD
git -C /Users/alexis/src/relux-works/swift-relux rev-parse HEAD
git -C /Users/alexis/src/relux-works/relux-sample rev-parse HEAD
git -C /Users/alexis/src/x-platform-airdrop/ios/swipe2cash/app rev-parse HEAD
git -C /Users/alexis/src/x-platform-airdrop/ios/swipe2cash/packages/Swipe2Cash rev-parse HEAD

rg -n --glob '*.swift' \
  'reluxTemporal|connectTemporally|tempStates|getState' \
  /Users/alexis/src/relux-works/swiftui-relux/Sources \
  /Users/alexis/src/relux-works/swift-relux/Sources

rg -n --glob '*.swift' \
  '\.reluxTemporal|connectTemporally' \
  /Users/alexis/src/relux-works/relux-sample \
  /Users/alexis/src/x-platform-airdrop/ios/swipe2cash/app \
  /Users/alexis/src/x-platform-airdrop/ios/swipe2cash/packages/Swipe2Cash
```
