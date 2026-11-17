import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var updatesSection: some View {
        return VStack(alignment: .leading, spacing: 16) {
            updatesHero

            updatesControlCard

            updatesStatusCard

            updateControlButton(
                title: appStore.localized(.openUpdaterConfig),
                systemImage: "doc.text"
            ) {
                appStore.openUpdaterConfigFile()
            }
        }
    }

    var updatesStatusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            let availableNotes: String? = {
                if case .updateAvailable(let release) = appStore.updateState {
                    return release.notes
                }
                return nil
            }()
            let availableNotesModel: MarkdownRenderModel = {
                guard let availableNotes, !availableNotes.isEmpty else { return .empty }
                return SimpleMarkdownParser.parse(availableNotes)
            }()

            Text(appStore.localized(.checkForUpdates))
                .font(.headline)

            switch appStore.updateState {
            case .idle:
                EmptyView()

            case .checking:
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(appStore.localized(.checkingForUpdates))
                        .foregroundStyle(.secondary)
                }

            case .upToDate:
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(appStore.localized(.upToDate))
                        .foregroundStyle(.secondary)
                }

            case .updateAvailable(let release):
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Label(appStore.localized(.updateAvailable), systemImage: "party.popper.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.orange)

                        Text(appStore.localized(.newVersion) + " \(release.version)")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)

                        Spacer(minLength: 0)
                    }

                    if !availableNotesModel.blocks.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Release Notes")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            ReleaseNotesMarkdownView(model: availableNotesModel, mode: .full)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.primary.opacity(0.04))
                        )
                    }
                }

            case .failed(let error):
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text(appStore.localized(.updateCheckFailed))
                            .font(.subheadline.weight(.medium))
                    }

                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }

    var updatesFloatingBar: some View {
        let floatingBarShape = Capsule(style: .continuous)
        return HStack(spacing: 12) {
            updateControlButton(
                title: appStore.updateState == .idle
                    ? appStore.localized(.checkForUpdatesButton)
                    : appStore.localized(.updatesRefreshButton),
                systemImage: "arrow.clockwise",
                isPrimary: true,
                minWidth: 136
            ) {
                appStore.checkForUpdates()
            }
            .disabled(appStore.updateState == .checking)

            if let release = currentAvailableRelease {
                updateControlButton(
                    title: appStore.localized(.downloadUpdate),
                    systemImage: "arrow.down.circle",
                    minWidth: 136
                ) {
                    appStore.launchUpdater(for: release)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .modifier(ClearGlassBackground(shape: floatingBarShape))
        .overlay(
            floatingBarShape
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 8)
    }

    struct ClearGlassBackground<S: Shape>: ViewModifier {
        let shape: S

        @ViewBuilder
        func body(content: Content) -> some View {
            if #available(macOS 26.0, iOS 18.0, *) {
                content
                    .glassEffect(.clear, in: shape)
            } else {
                content
                    .background(.ultraThinMaterial, in: shape)
            }
        }
    }

    var currentAvailableRelease: AppStore.UpdateRelease? {
        if case .updateAvailable(let release) = appStore.updateState {
            return release
        }
        return nil
    }

    var updatesControlCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(appStore.localized(.autoCheckForUpdates))
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $appStore.autoCheckForUpdates)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }

    func updateControlButton(title: String, systemImage: String, isPrimary: Bool = false, minWidth: CGFloat = 160, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(minWidth: minWidth)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .background(
            Capsule()
                .fill(isPrimary ? Color.accentColor.opacity(0.16) : Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            Capsule()
                .stroke(isPrimary ? Color.accentColor.opacity(0.6) : Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    var updatesHero: some View {
        let statusText: String = {
            switch appStore.updateState {
            case .updateAvailable:
                return appStore.localized(.updatesHeroUpdateAvailable)
            case .upToDate:
                return appStore.localized(.updatesHeroUpToDate)
            default:
                return String(format: appStore.localized(.versionLabelFormat),
                              getVersion(fallback: appStore.localized(.versionFallback)))
            }
        }()

        return ZStack(alignment: .center) {
            Image("AboutBackground")
                .resizable()
                .interpolation(.high)
                .aspectRatio(16.0/9.0, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()

            VStack(spacing: 12) {
                headlineGlass

                Text(statusText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 6)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180, maxHeight: 200)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1.4)
        )
        .padding(.bottom, 12)
    }
}
