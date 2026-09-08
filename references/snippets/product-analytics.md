# Product Analytics Snippet

Keep product metrics in a module-local typed tree.

```swift
extension Profiles {
    enum Analytics {
        typealias Event = ProductAnalytics.Event

        enum Screen: String {
            case profileSelector = "/profiles"
            var name: String { rawValue }
        }

        enum ProfileSelector {
            private static let screenName = Screen.profileSelector.name

            static let screenAppear = Event.screenAppearance(screenName: screenName)

            static func selectProfile(_ profile: String) -> Event {
                Event.tapElement(
                    screenName: screenName,
                    eventCategory: "profiles",
                    eventLabel: profile.analyticsLabel,
                    eventContent: "status"
                )
            }
        }
    }
}
```

Call sites should stay declarative.

```swift
ProfileSelectorView()
    .trackAppearance(event: Profiles.Analytics.ProfileSelector.screenAppear)

Button {
    trackEvent(Profiles.Analytics.ProfileSelector.selectProfile(profile.name))
} label: {
    Text(title)
}
```

For Relux effect-based analytics packages, return the public event model used by
the effect API.

```swift
extension Checkout {
    enum Analytics {
        enum Payment {
            static func started(spanID: AnalyticsSDK.SpanID) -> AnalyticsSDK.Event {
                .continuous(.start(.init(
                    name: "payment_started",
                    finishEventName: "payment_finished",
                    spanID: spanID,
                    staleTimeout: 30,
                    parameters: ["screen": .string("checkout")]
                )))
            }
        }
    }
}
```
