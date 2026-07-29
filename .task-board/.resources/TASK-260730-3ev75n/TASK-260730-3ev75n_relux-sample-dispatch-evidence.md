# Relux Dispatch Evidence

## Scope

- `relux-sample`: `47236f2cea66a9ef7b72569d95383abf1b7d2c7d`
- `swift-relux`: `17efec6d94190ab318ea57cc76dabaad1fc3cf2c`

## Findings

- Top-level `action`, `actions`, and `performAsync` target the primary application dispatcher.
- Saga/Flow instance `action` and `actions` route through `self.dispatcher`, preserving an injected test dispatcher.
- `relux_sample/App.swift` receives the resolved runtime in its composition
  path but still dispatches startup work through top-level `actions`.
- `relux-sample` application and Flow/Saga call sites use those helpers;
  isolated integration tests construct and inject `Relux.Dispatcher(logger:)`.
- Temporal attachment is not a dispatcher exception. The canonical view call site is `.reluxTemporal(state:)`; the modifier resolves the environment runtime internally and the view does not use `onConnect` to obtain a runtime or dispatcher.

See `TASK-260730-3ev75n_swiftui-relux-temporal-evidence.md` for the pinned SwiftUI/store ownership contract.
