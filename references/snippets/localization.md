# Localization Snippet

App target shape:

```swift
enum loc {}

extension loc {
    enum profiles {
        private static let table = "LocalizableProfiles"

        enum management {
            static let header = String(
                localized: "loc.profiles.management.header",
                table: table,
                bundle: nil,
                comment: ""
            )

            static func removeMessage(_ profile: String) -> String {
                String(
                    localized: "loc.profiles.management.remove_message(profile: \(profile))",
                    table: table,
                    bundle: nil,
                    comment: ""
                )
            }
        }
    }
}
```

SwiftPM package shape:

```swift
enum l10n {
    enum onboarding {
        private static let table = "LocalizableOnboarding"

        static let title = String(
            localized: "l10n.onboarding.title",
            table: table,
            bundle: .module,
            comment: ""
        )
    }
}
```
