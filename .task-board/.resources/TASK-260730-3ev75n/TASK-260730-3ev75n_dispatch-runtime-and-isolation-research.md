# Dispatch Runtime Selection, Temporal Ownership, And Isolation

| Context | Dispatch surface | Ownership rule |
| --- | --- | --- |
| Primary application code | Top-level `action` / `actions` | Uses initialized application dispatcher |
| Saga or Flow | Unqualified instance `action` / `actions` | Uses `self.dispatcher`, including injected harnesses |
| Host-provider lifecycle boundary | Resolved runtime dispatcher | Host contract owns the exact runtime |
| Isolated integration test | Injected `Relux.Dispatcher` | Harness owns the event bus and logger |
| SwiftUI temporal state | `.reluxTemporal(state:)` | View owns state; modifier resolves environment runtime; store holds weak reference |

Primary-runtime view events still use top-level helpers, without reading the
environment runtime. Temporal state is not currently a stable injectable
`Flow` dependency. Pass immutable `Sendable` value snapshots or use a
lifecycle-stable business/service dependency. A future runtime state accessor
may materialize a currently live temporal state once lookup, absence, lifetime,
and actor-isolation semantics are defined, but no such contract exists today.

Concurrency guidance remains actor-first for Flow/Saga and stateful async dependencies, `Sendable` across task boundaries, and narrowly scoped `@MainActor` for UI/platform or synchronous main-thread SDK adapters.
