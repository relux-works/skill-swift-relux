# Relux ecosystem and version boundaries

Source review: 2026-09-09. Links below pin the inspected commits; they are a
research baseline, not a requirement to upgrade an application's dependencies.
Read the target project's `Package.resolved`, `Package.swift`, and Tuist package
configuration before selecting APIs. A README example may lag its implementation.

## Package map

| Repository snapshot | Product / role | When to inspect |
| --- | --- | --- |
| [swift-relux](https://github.com/relux-works/swift-relux/tree/6e401c72a18017e5b52fe326b4872b869580a474) | Relux | Core runtime, dispatcher, store, Saga and Flow |
| [swiftui-relux](https://github.com/relux-works/swiftui-relux/tree/69fbc12f8f79a15930d78570df6fa608b0847b61) | SwiftUIRelux | Resolver, environment injection and temporal attachment |
| [swiftui-reluxrouter](https://github.com/relux-works/swiftui-reluxrouter/tree/cb80d2b5422a2329701d6e450815ba565b396b6d) | ReluxRouter | Router and ProjectingRouter; SDK/Sources |
| [relux-analytics](https://github.com/relux-works/relux-analytics/tree/e182c4c1d24f58f8005535569d33741b255ab36a) | ReluxAnalytics / ReluxAnalyticsAppMetrica | Analytics service, aggregator and optional AppMetrica integration |
| [relux-feature-management](https://github.com/relux-works/relux-feature-management/tree/a9417cb77754af6331f4a1796a9d5cbc98841915) | ReluxFeatureManagement | Feature expressions and Keychain persistence |
| [relux-module_template](https://github.com/relux-works/relux-module_template/tree/a1260ef2fd68e4ef4f345dda89de3e7aafa1c085) | Template | Module naming/layout examples; adapt to the resolved API |
| [relux-sample](https://github.com/relux-works/relux-sample/tree/815a681105ed40c9846ac62c7c123c1250c1eb84) | Sample app | Composition and feature/test examples; inspect its dependency pins |

The inspected core package uses Swift tools 6.0 and declares iOS 13, macOS 10.15,
tvOS 13, and watchOS 6. SwiftUIRelux declares iOS 16 and macOS 13; ReluxRouter
also declares watchOS 9, tvOS 16, and Mac Catalyst 16. These are package manifest
floors, not proof that every API is available on every declared target. Validate
the application's chosen platform and dependency intersection.

SwiftUIRelux and ReluxRouter depend on Relux from 9.2.0. The feature-management
snapshot still declares Relux from 9.0.0. Do not infer a coordinated release
number for the ecosystem or copy package versions between libraries.

## Dispatch ordering and results

`actions` defaults to `.serially` for actions within that call. The dispatcher
notifies subscribers concurrently for each action; RootSaga also invokes handlers
concurrently. Registration order does not establish an ordering between handlers.
A serial batch is not a transaction: it does not roll back or stop automatically
on a failure result. Await one operation and inspect its `Relux.ActionResult`
before dispatching a dependent navigation or state change when success matters.
Separate callers may interleave across actor suspension points.

`Flow.apply` returns `Relux.ActionResult`, whose success and failure cases carry
payload dictionaries; this is not Swift's generic `Result<Value, Error>`. Use the
actual payload API at the resolved version. Saga handlers return `Void`; awaiting
a dispatch waits for their `apply` calls, but not detached work they start.

`Store.getState` force-casts a registered state by type. It is not an optional
lookup and is not a temporal-state accessor. Register stable dependencies before
lookup; retain the existing guidance to carry immutable input into flows rather
than resolving a view-owned temporal state.

## Analytics integration boundary

At the inspected snapshot `Analytics.Module` accepts an `Analytics.Service`, or
aggregators plus a continuous-event manager and context providers. It registers
an `Analytics.Saga` and no states. Its effects are `start`, `identify`,
`resetIdentity`, and `track(Event)`.

The metric namespace in [product-analytics.md](../snippets/product-analytics.md)
is an application convention. Map it to the installed analytics package's event
model; do not assume the illustrative metric types are SDK declarations. Keep
provider-specific products (for example ReluxAnalyticsAppMetrica) at composition
boundaries and use the core service/aggregator abstractions in feature code.

## Evidence priority

Prefer declarations and tests at the application's resolved revision, then
package documentation, then sample/template conventions. Samples illustrate
architecture; copying one is not evidence that it compiles against another
release. SwiftUIRelux's README includes an `onConnect` example using
`relux.dispatch(...)`; the inspected core exposes `action`/`actions` instead.
Use the verified dispatch helpers and the runtime-ownership guidance in this
skill rather than reproducing that README call verbatim.
