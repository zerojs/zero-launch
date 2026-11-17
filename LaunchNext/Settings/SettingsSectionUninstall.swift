import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var uninstallSection: some View {
        let rawPath = appStore.uninstallToolAppPath.trimmingCharacters(in: .whitespacesAndNewlines)
        let toolURL = appStore.uninstallToolAppURL
        let hasSelection = !rawPath.isEmpty
        let isMissing = appStore.uninstallToolConfiguredButMissing
        let fallbackName = rawPath.isEmpty ? "" : URL(fileURLWithPath: rawPath).deletingPathExtension().lastPathComponent
        let displayName = toolURL == nil ? fallbackName : appStore.uninstallToolAppDisplayName

        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Label(appStore.localized(.settingsSectionUninstall), systemImage: "trash.fill")
                        .font(.headline)
                    Text(appStore.localized(.uninstallSectionDescription))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.14), Color.orange.opacity(0.10)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Image(nsImage: appStore.uninstallToolAppIcon)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .frame(width: 38, height: 38)
                            .cornerRadius(10)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(hasSelection ? (displayName.isEmpty ? rawPath : displayName) : appStore.localized(.uninstallToolNotConfigured))
                                .font(.headline)
                                .lineLimit(1)

                            Spacer(minLength: 0)

                            uninstallToolStatusBadge(isMissing: isMissing, hasSelection: hasSelection)
                        }

                        if hasSelection {
                            if !rawPath.isEmpty {
                                Text(rawPath)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .textSelection(.enabled)
                            }

                            HStack(spacing: 8) {
                                if !appStore.uninstallToolBundleIdentifier.isEmpty {
                                    uninstallToolMetaPill(appStore.uninstallToolBundleIdentifier, systemImage: "number")
                                }
                                if !appStore.uninstallToolVersionText.isEmpty {
                                    uninstallToolMetaPill(appStore.uninstallToolVersionText, systemImage: "tag")
                                }
                            }
                        } else {
                            Text(appStore.localized(.uninstallToolPathLabel))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if isMissing {
                            Text(appStore.localized(.uninstallToolMissing))
                                .font(.caption)
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.red.opacity(colorScheme == .dark ? 0.10 : 0.07))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(colorScheme == .dark ? 0.22 : 0.18), lineWidth: 1)
                )

                HStack(spacing: 10) {
                    Button {
                        presentUninstallToolPicker()
                    } label: {
                        Label(appStore.localized(.uninstallToolChooseButton), systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        if !appStore.openConfiguredUninstallTool() {
                            NSSound.beep()
                        }
                    } label: {
                        Label(appStore.localized(.uninstallToolOpenButton), systemImage: "arrow.up.forward.app")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(appStore.uninstallToolAppURL == nil)

                    Button(role: .destructive) {
                        _ = appStore.setUninstallToolApplication(url: nil)
                    } label: {
                        Label(appStore.localized(.uninstallToolClearButton), systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hasSelection)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

        }
    }

    func uninstallToolStatusBadge(isMissing: Bool, hasSelection: Bool) -> some View {
        let title: String
        let symbol: String
        let fillColor: Color
        let foreground: Color

        if isMissing {
            title = appStore.localized(.uninstallToolMissing)
            symbol = "exclamationmark.triangle.fill"
            fillColor = Color.red.opacity(colorScheme == .dark ? 0.22 : 0.14)
            foreground = .red
        } else if hasSelection {
            title = appStore.localized(.uninstallToolOpenButton)
            symbol = "checkmark.circle.fill"
            fillColor = Color.green.opacity(colorScheme == .dark ? 0.20 : 0.12)
            foreground = .green
        } else {
            title = appStore.localized(.uninstallToolChooseButton)
            symbol = "circle.dashed"
            fillColor = Color.primary.opacity(colorScheme == .dark ? 0.16 : 0.08)
            foreground = .secondary
        }

        return Label(title, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(fillColor, in: Capsule())
            .foregroundStyle(foreground)
    }

    func uninstallToolMetaPill(_ text: String, systemImage: String) -> some View {
        return Label(text, systemImage: systemImage)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06), in: Capsule())
            .foregroundStyle(.secondary)
    }
    
    func presentUninstallToolPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.applicationBundle]
        panel.title = appStore.localized(.uninstallToolPanelTitle)
        panel.prompt = appStore.localized(.uninstallToolChooseButton)

        if panel.runModal() == .OK, let url = panel.url {
            if !appStore.setUninstallToolApplication(url: url) {
                NSSound.beep()
            }
        }
    }

}
