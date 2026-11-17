import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var developmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appStore.localized(.developmentPlaceholderTitle))
                .font(.headline)
            Text(appStore.localized(.developmentPlaceholderSubtitle))
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text(appStore.localized(.developmentQuarantineRemovalTitle))
                    .font(.subheadline.weight(.semibold))
                SettingsInfoAffordance(
                    isPresented: $showQuarantineRemovalInfoPopover,
                    iconFont: .subheadline.weight(.regular)
                ) {
                    SettingsInfoTitle(text: appStore.localized(.developmentQuarantineRemovalInfoTitle))
                    SettingsInfoBody(text: appStore.localized(.developmentQuarantineRemovalInfoBody))
                }
                Spacer()
                Toggle("", isOn: $appStore.showQuarantineRemovalAction)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            updateControlButton(
                title: appStore.localized(.developmentForceOnboardingButton),
                systemImage: "rectangle.stack.badge.play",
                isPrimary: true
            ) {
                appStore.forceShowOnboarding()
            }
            .disabled(!appStore.isFullscreenMode)
            .opacity(appStore.isFullscreenMode ? 1 : 0.45)
            Text(appStore.localized(.developmentForceOnboardingHint))
                .font(.caption)
                .foregroundStyle(.secondary)

            updateControlButton(
                title: "Test update notification",
                systemImage: "bell.badge"
            ) {
                appStore.sendTestUpdateNotification()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Screenshot background")
                    .font(.headline)

                updateControlButton(
                    title: "Pure White",
                    systemImage: "sun.max.fill"
                ) {
                    appStore.developmentBackgroundOverride = .solidWhite
                }

                updateControlButton(
                    title: "Pure Black",
                    systemImage: "moon.fill"
                ) {
                    appStore.developmentBackgroundOverride = .solidBlack
                }

                updateControlButton(
                    title: "Clear",
                    systemImage: "arrow.counterclockwise"
                ) {
                    appStore.developmentBackgroundOverride = .none
                }

                Text("Development-only preview override, not persisted.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Image(systemName: "memorychip")
                Text(currentMemoryUsageString())
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

            Toggle(appStore.localized(.showFPSOverlay), isOn: $appStore.showFPSOverlay)
                .toggleStyle(.switch)
            Text(appStore.localized(.showFPSOverlayDisclaimer))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(appStore.localized(.showFPSOverlayWarning))
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(appStore.localized(.importLegacy))
                    .font(.headline)
                Button { importLegacyArchive() } label: {
                    Label(appStore.localized(.importLegacy), systemImage: "clock.arrow.circlepath")
                }
                Text(appStore.localized(.importTip))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text(appStore.localized(.modifiedFrom))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // private var aiOverlaySection: some View {
    //     VStack(alignment: .leading, spacing: 20) {
    //         Toggle(isOn: $appStore.isAIEnabled) {
    //             Text(appStore.localized(.aiFeatureToggleTitle))
    //                 .font(.headline)
    //         }
    //         .toggleStyle(.switch)
    //
    //         Text("AI features are experimental. It’s recommended to keep them off unless you’re testing.")
    //             .font(.footnote)
    //             .foregroundStyle(.secondary)
    //
    //         Text(appStore.localized(.aiOverlayShortcutHint))
    //             .font(.footnote)
    //             .foregroundStyle(.secondary)
    //
    //         Button {
    //             appStore.presentAIOverlayPreview()
    //         } label: {
    //             Label(appStore.localized(.aiOverlayPreviewButtonLabel), systemImage: "sparkles")
    //                 .font(.headline)
    //                 .frame(maxWidth: .infinity)
    //                 .padding(.vertical, 6)
    //         }
    //         .buttonStyle(.borderedProminent)
    //         .tint(Color.accentColor)
    //         .disabled(!appStore.isAIEnabled)
    //     }
    //     .frame(maxWidth: .infinity, alignment: .leading)
    // }

}
