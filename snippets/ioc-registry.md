# IoC Registry Snippet

Use an app registry/composition root to construct Relux infrastructure and
feature modules.

```swift
extension DemoApp {
    @MainActor
    enum Registry {
        static let ioc = IoC()

        static func configure() {
            ioc.register(Relux.self, lifecycle: .container, resolver: Self.buildRelux)
            ioc.register(Relux.Store.self, lifecycle: .container, resolver: Self.buildReluxStore)
            ioc.register(Relux.RootSaga.self, lifecycle: .container, resolver: Self.buildReluxRootSaga)
            ioc.register((any Relux.Logger).self, lifecycle: .container, resolver: Self.buildReluxLogger)

            ioc.register(Feature.Module.self, lifecycle: .container, resolver: Self.buildFeatureModule)
            ioc.register((any Feature.Service).self, lifecycle: .container, resolver: Self.buildFeatureService)
        }

        static func resolve<T>(_ type: T.Type) -> T {
            ioc.get(by: type)!
        }

        static func resolveAsync<T>(_ type: T.Type) async -> T {
            await ioc.getAsync(by: type)!
        }
    }
}
```

Register modules inside the Relux builder.

```swift
extension DemoApp.Registry {
    private static func buildRelux() async -> Relux {
        await Relux(
            logger: resolve((any Relux.Logger).self),
            appStore: resolve(Relux.Store.self),
            rootSaga: resolve(Relux.RootSaga.self)
        )
        .register { @MainActor in
            await resolveAsync(Feature.Module.self)
            resolve(AnotherFeature.Module.self)
        }
    }
}
```
