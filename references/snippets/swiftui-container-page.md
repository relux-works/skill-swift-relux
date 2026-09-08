# SwiftUI Container And Page Snippet

Containers read Relux state and dispatch effects. Pages receive plain inputs.

```swift
struct TransferContainer: Relux.UI.Container {
    @EnvironmentObject private var state: MoneyTransfer.UI.State

    var body: some View {
        TransferPage(
            props: .init(state),
            reactions: .init(
                onSubmit: Relux.UI.ViewCallback { amount in
                    await actions {
                        MoneyTransfer.Effect.submit(amount: amount)
                    }
                },
                onCancel: Relux.UI.ViewCallback {
                    await actions {
                        MoneyTransfer.Action.cancelTapped
                    }
                }
            ),
            styles: .default,
            resources: .localized
        )
    }
}

struct TransferPage: Relux.UI.View {
    let props: Props
    let reactions: Reactions
    let styles: Styles
    let resources: Resources

    var body: some View {
        VStack(spacing: styles.sectionSpacing) {
            TransferHeader(title: resources.title)
            TransferAmountSection(amount: props.amount, onSubmit: reactions.onSubmit)
            TransferFooter(onCancel: reactions.onCancel)
        }
    }

    struct Props: Relux.UI.ViewProps {
        let amount: Decimal?

        init(_ state: MoneyTransfer.UI.State) {
            amount = state.amount
        }
    }

    struct Reactions: Relux.UI.ViewCallbacks {
        let onSubmit: Relux.UI.ViewCallback<Decimal>
        let onCancel: Relux.UI.ViewCallback<Void>
    }

    struct Styles: Equatable, Hashable, Sendable {
        let sectionSpacing: CGFloat

        static let `default` = Styles(sectionSpacing: 16)
    }

    struct Resources: Equatable, Hashable, Sendable {
        let title: String

        static let localized = Resources(title: l10n.transfer.title)
    }
}
```
