# Swift Package Conventions

## Manifest

- Keep `Package.swift` as the source of truth.
- Follow the package's existing Swift tools version, language mode, platform
  floor, and concurrency settings unless the task explicitly changes them.
- Declare package layout explicitly in the manifest when the package uses flat
  roots, for example target `path: "Sources"` and resources
  `.process("Resources")`.
- Add a test target for reusable packages and keep tests under `Tests/`.
- Keep generated `.xcodeproj`, `.xcworkspace`, `.swiftpm`, `.build`,
  `Derived*`, and `*.xcresult` artifacts ignored.

## Package Boundaries

- Prefer separate Swift packages for reusable product layers when linkage,
  binary distribution, embedding, or release boundaries matter.
- Do not collapse reusable layers into multiple targets inside one Swift package
  only for convenience.
- Use one package with multiple targets only when those targets are
  implementation details of one deliverable.
- App targets should consume package products through explicit package
  dependencies; package-to-package dependencies should remain explicit in each
  manifest.

## Public Namespaces

- Expose one public root namespace enum matching the package/module name when a
  package uses namespace-style APIs.
- Add public domain namespaces through extensions, for example
  `<Root>.Business` and `<Root>.UI`.
- Public API types should live inside the relevant domain namespace rather than
  as unrelated top-level symbols.
- Name files by namespace path, for example `<Root>+Namespace.swift` and
  `<Root>+UI+EntryView.swift`.
- Internal helper targets in a facade package may extend the facade namespace
  instead of exposing their own module name when the facade deliberately
  re-exports them.

## Localization

- Keep localization access behind an internal `l10n` namespace.
- UI and business code should not use raw localization keys directly.
- Split localization accessors by feature or surface.
- Resolve package strings with `String(localized: ..., bundle: .module)` so
  resources come from the SwiftPM module bundle.
- For app targets, a root `loc` namespace is also acceptable when that is the
  established local convention. Extend it per feature in
  `<Module>+Localization.swift`.
- Mirror the product UI hierarchy with nested enums, not flat key bags.
- Keep the table name near the feature namespace.
- Use `static let` for fixed strings and `static func` for interpolated or
  pluralized strings.
- Views, reducers, and flows should reference typed accessors such as
  `loc.profiles.management.header`, never raw keys like
  `"loc.profiles.management.header"`.

See [../../snippets/localization.md](../../snippets/localization.md) for app
target and SwiftPM localization accessor examples.

## Tests

- Use Swift Testing for unit, integration, package, and snapshot tests when the
  local project supports it: `import Testing`, `@Suite`, `@Test`, and `#expect`.
- Mirror the production namespace tree in tests.
- Keep the test namespace internal to tests, usually with
  `extension <Module> { enum Test {} }`.
- Use `@MainActor` on SwiftUI suites or tests that construct views.
- Do not add platform availability annotations only to silence host test issues.
- For iOS-only package products, verify through Xcode/Tuist iOS builds or iOS
  test plans when `swift test` compiles against the wrong host SDK.
