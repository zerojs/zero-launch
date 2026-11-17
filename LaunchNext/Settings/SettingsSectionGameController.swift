import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var gameControllerSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Experimental gesture UI.
            // Remove this card together with the gesture AppStore fields,
            // LaunchpadApp gesture wiring, and LaunchNext/Gesture/ if the
            // low-level multitouch feature is removed later.
            VStack(alignment: .leading, spacing: 12) {
                Text(appStore.localized(.gameControllerPlaceholderTitle))
                    .font(.headline.weight(.semibold))

                Toggle(isOn: $appStore.gameControllerEnabled) {
                    Text(appStore.localized(.gameControllerToggleTitle))
                        .font(.subheadline.weight(.semibold))
                }
                .toggleStyle(.switch)

                Toggle(isOn: $appStore.gameControllerMenuTogglesLaunchpad) {
                    Text(appStore.localized(.gameControllerMenuToggleTitle))
                        .font(.subheadline.weight(.semibold))
                }
                .toggleStyle(.switch)
                .disabled(!appStore.gameControllerEnabled)
                .opacity(appStore.gameControllerEnabled ? 1 : 0.5)

                Text(appStore.localized(.gameControllerMenuToggleSubtitle))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .opacity(appStore.gameControllerEnabled ? 1 : 0.6)

                VStack(alignment: .leading, spacing: 6) {
                    Text(gameControllerStatusText)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.primary)

                    Text(appStore.localized(.gameControllerPlaceholderSubtitle))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(nsColor: .quaternarySystemFill))
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(appStore.localized(.gameControllerQuickGuideTitle))
                    .font(.footnote.weight(.semibold))

                VStack(alignment: .leading, spacing: 6) {
                    guideRow(icon: "dpad", text: appStore.localized(.gameControllerQuickGuideDirection))
                    guideRow(icon: "a.circle.fill", text: appStore.localized(.gameControllerQuickGuideSelect))
                    guideRow(icon: "b.circle.fill", text: appStore.localized(.gameControllerQuickGuideCancel))
                    if appStore.gameControllerMenuTogglesLaunchpad {
                        guideRow(icon: "line.3.horizontal", text: appStore.localized(.gameControllerQuickGuideMenuToggle))
                    }
                }
            }

            SettingsResetFooter(
                appStore: appStore,
                sectionTitle: appStore.localized(.settingsSectionGameController)
            ) {
                appStore.resetGameControllerSettings()
            }
        }
    }

    func guideRow(icon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.accentColor)
                .frame(width: 18)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    var gameControllerStatusText: String {
        if !appStore.gameControllerEnabled {
            return appStore.localized(.gameControllerStatusDisabled)
        }

        let names = controllerManager.connectedControllerNames
        guard !names.isEmpty else {
            return appStore.localized(.gameControllerStatusNoController)
        }

        let joined = names.joined(separator: ", ")
        return String(format: appStore.localized(.gameControllerStatusConnectedFormat), joined)
    }

}
