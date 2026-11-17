import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var appSourcesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(appStore.localized(.scanSourcesIntroTitle))
                        .font(.headline)
                    Text(appStore.localized(.scanSourcesIntroDescription))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 「立即刷新」从「通用」页搬过来：它干的事就是按这里的来源
                // 重新扫描一遍，和来源列表放在同一页才看得出因果关系。
                Button {
                    appStore.refresh()
                } label: {
                    Label(appStore.localized(.refresh), systemImage: "arrow.clockwise")
                }
                .fixedSize()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(appStore.localized(.scanSourcesDefaultListTitle))
                    .font(.subheadline.weight(.semibold))
                ForEach(appStore.builtinAppSourcePaths, id: \.self) { path in
                    appSourceRow(icon: "internaldrive", path: path, isAvailable: true, accessory: { EmptyView() })
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Text(appStore.localized(.scanSourcesCustomListTitle))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Button {
                        presentAppSourcePicker()
                    } label: {
                        Label(appStore.localized(.scanSourcesAddButton), systemImage: "plus.circle")
                            // 图标与文字之间的间隙原本点不到，铺满命中区域。
                            .settingsHitArea()
                    }
                    .buttonStyle(.borderless)

                    Button {
                        showAppSourcesResetDialog = true
                    } label: {
                        Label(appStore.localized(.scanSourcesResetButton), systemImage: "arrow.counterclockwise")
                            // 图标与文字之间的间隙原本点不到，铺满命中区域。
                            .settingsHitArea()
                    }
                    .buttonStyle(.borderless)
                    .disabled(appStore.customAppSourcePaths.isEmpty)
                }

                if appStore.customAppSourcePaths.isEmpty {
                    Text(appStore.localized(.scanSourcesEmptyHint))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                } else {
                    ForEach(appStore.customAppSourcePaths, id: \.self) { path in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                appSourceRow(icon: "folder", path: path, isAvailable: pathExists(path)) {
                                    HStack(spacing: 10) {
                                        Button {
                                            toggleExpandedSource(path)
                                        } label: {
                                            Image(systemName: "ellipsis.circle")
                                                .foregroundStyle(.secondary)
                                        }
                                        .buttonStyle(.borderless)

                                        Button {
                                            appStore.removeCustomAppSource(path: path)
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundStyle(Color.red)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                            }

                            if expandedSource == standardizePath(path) {
                                let apps = appsForSource(path)
                                VStack(alignment: .leading, spacing: 8) {
                                    if apps.isEmpty {
                                        Text(appStore.localized(.scanSourcesEmptyHint))
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .padding(.horizontal, 4)
                                    } else {
                                        ScrollView {
                                            LazyVStack(alignment: .leading, spacing: 8) {
                                                ForEach(apps, id: \.path) { app in
                                                    HStack(spacing: 8) {
                                                        Image(nsImage: app.icon)
                                                            .resizable()
                                                            .interpolation(.high)
                                                            .antialiased(true)
                                                            .frame(width: 24, height: 24)
                                                            .cornerRadius(5)
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(app.name)
                                                                .font(.callout)
                                                                .lineLimit(1)
                                                            Text(app.path)
                                                                .font(.caption2)
                                                                .foregroundStyle(.secondary)
                                                                .lineLimit(1)
                                                        }
                                                        Spacer()
                                                        Button(role: .destructive) {
                                                            removeAppFromLayout(app.path)
                                                        } label: {
                                                            Image(systemName: "trash")
                                                                .foregroundStyle(Color.red)
                                                        }
                                                        .buttonStyle(.borderless)
                                                    }
                                                    .padding(.horizontal, 6)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        .frame(maxHeight: 220)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.secondary.opacity(0.08))
                                )
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "text.magnifyingglass")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.accentColor)
                            Text(appStore.localized(.scanSourcesFuzzySearchTitle))
                                .font(.subheadline.weight(.semibold))
                        }
                        Text(appStore.localized(.scanSourcesFuzzySearchDescription))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 20)

                    Toggle("", isOn: $appStore.fuzzySearchEnabled)
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 14)

                Divider()
                    .padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(appStore.localized(.scanSourcesSearchDelayTitle))
                                .font(.subheadline.weight(.semibold))
                            Text(appStore.localized(.scanSourcesSearchDelayDescription))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 12)

                        Text("\(Int(appStore.searchDebounceMilliseconds.rounded())) ms")
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: $appStore.searchDebounceMilliseconds,
                        in: AppStore.searchDebounceMillisecondsRange,
                        step: 50
                    )

                    HStack {
                        Text("\(Int(AppStore.searchDebounceMillisecondsRange.lowerBound)) ms")
                        Spacer()
                        Text("\(Int(AppStore.searchDebounceMillisecondsRange.upperBound)) ms")
                    }
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .confirmationDialog(appStore.localized(.scanSourcesResetButton), isPresented: $showAppSourcesResetDialog, titleVisibility: .visible) {
            Button(appStore.localized(.scanSourcesResetButton), role: .destructive) {
                appStore.resetCustomAppSources()
            }
            Button(appStore.localized(.cancel), role: .cancel) {}
        }
    }

    // MARK: - Helpers
    struct SourceApp {
        let name: String
        let path: String
        let icon: NSImage
    }

    func appsForSource(_ sourcePath: String) -> [SourceApp] {
        let normalizedSource = standardizePath(sourcePath)
        let prefix = normalizedSource.hasSuffix("/") ? normalizedSource : normalizedSource + "/"
        var apps: [SourceApp] = []
        var seen: Set<String> = []

        func consider(name: String, path: String, icon: NSImage) {
            let normalized = standardizePath(path)
            guard normalized == normalizedSource || normalized.hasPrefix(prefix) else { return }
            if seen.insert(normalized).inserted {
                apps.append(SourceApp(name: name, path: normalized, icon: icon))
            }
        }

        for item in appStore.items {
            switch item {
            case .app(let app):
                consider(name: app.name, path: app.url.path, icon: IconStore.shared.icon(for: app))
            case .missingApp(let placeholder):
                consider(name: placeholder.displayName, path: placeholder.bundlePath, icon: placeholder.icon)
            case .folder(let folder):
                for app in folder.apps {
                    consider(name: app.name, path: app.url.path, icon: IconStore.shared.icon(for: app))
                }
            case .empty:
                break
            }
        }

        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func standardizePath(_ path: String) -> String {
        URL(fileURLWithPath: path).standardized.path
    }

    struct IndicatorScreenEntry: Identifiable {
        let id: String
        let name: String
        let sizeText: String
        let isConnected: Bool
    }

    var currentIndicatorScreenID: String? {
        let screen = NSApp.keyWindow?.screen ?? NSScreen.main
        return screen.map { AppStore.screenIdentifier(for: $0) }
    }

    var indicatorScreenEntries: [IndicatorScreenEntry] {
        let connectedScreens = NSScreen.screens
        var entries: [IndicatorScreenEntry] = []
        var connectedIDs = Set<String>()

        for screen in connectedScreens {
            let id = AppStore.screenIdentifier(for: screen)
            connectedIDs.insert(id)
            entries.append(IndicatorScreenEntry(id: id,
                                                name: screen.localizedName,
                                                sizeText: screenSizeText(screen),
                                                isConnected: true))
        }

        let offlineIDs = appStore.scopedPageIndicatorOverrides(for: selectedAppearanceLayoutMode).keys
            .filter { !connectedIDs.contains($0) }
            .sorted()

        for id in offlineIDs {
            entries.append(IndicatorScreenEntry(id: id,
                                                name: appStore.localized(.indicatorOfflineDisplay),
                                                sizeText: String(format: appStore.localized(.indicatorScreenIDFormat), id),
                                                isConnected: false))
        }

        return entries
    }

    func screenSizeText(_ screen: NSScreen) -> String {
        let width = Int(screen.frame.width.rounded())
        let height = Int(screen.frame.height.rounded())
        return "\(width)×\(height)"
    }

    func indicatorCustomBinding(for screenID: String) -> Binding<Bool> {
        Binding(
            get: { appStore.scopedPageIndicatorOverride(for: screenID, mode: selectedAppearanceLayoutMode) != nil },
            set: { isCustom in
                scheduleIndicatorOverrideUpdate {
                    if isCustom {
                        appStore.applyIndicatorDefaults(to: screenID, mode: selectedAppearanceLayoutMode)
                    } else {
                        appStore.setScopedPageIndicatorOverride(nil, for: screenID, mode: selectedAppearanceLayoutMode)
                    }
                }
            }
        )
    }

    func indicatorOffsetBinding(for screenID: String) -> Binding<Double> {
        Binding(
            get: {
                appStore.scopedPageIndicatorOverride(for: screenID, mode: selectedAppearanceLayoutMode)?.offset
                ?? appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode)
            },
            set: { newValue in
                scheduleIndicatorOverrideUpdate {
                    let current = appStore.scopedPageIndicatorOverride(for: screenID, mode: selectedAppearanceLayoutMode)
                        ?? AppStore.PageIndicatorOverride(offset: appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode),
                                                          topPadding: appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode))
                    appStore.setScopedPageIndicatorOverride(AppStore.PageIndicatorOverride(offset: newValue,
                                                                                           topPadding: current.topPadding),
                                                            for: screenID,
                                                            mode: selectedAppearanceLayoutMode)
                }
            }
        )
    }

    func indicatorTopPaddingBinding(for screenID: String) -> Binding<Double> {
        Binding(
            get: {
                appStore.scopedPageIndicatorOverride(for: screenID, mode: selectedAppearanceLayoutMode)?.topPadding
                ?? appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode)
            },
            set: { newValue in
                scheduleIndicatorOverrideUpdate {
                    let current = appStore.scopedPageIndicatorOverride(for: screenID, mode: selectedAppearanceLayoutMode)
                        ?? AppStore.PageIndicatorOverride(offset: appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode),
                                                          topPadding: appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode))
                    appStore.setScopedPageIndicatorOverride(AppStore.PageIndicatorOverride(offset: current.offset,
                                                                                           topPadding: newValue),
                                                            for: screenID,
                                                            mode: selectedAppearanceLayoutMode)
                }
            }
        )
    }

    func scheduleIndicatorOverrideUpdate(_ action: @escaping () -> Void) {
        DispatchQueue.main.async(execute: action)
    }

    func backgroundMaskColorBinding(isDark: Bool) -> Binding<Color> {
        Binding(
            get: {
                let rgba = isDark ? appStore.backgroundMaskDarkColor : appStore.backgroundMaskLightColor
                return rgba.color
            },
            set: { newValue in
                let updated = AppStore.RGBAColor(newValue)
                let current = isDark ? appStore.backgroundMaskDarkColor : appStore.backgroundMaskLightColor
                guard current != updated else { return }
                if isDark {
                    appStore.backgroundMaskDarkColor = updated
                } else {
                    appStore.backgroundMaskLightColor = updated
                }
            }
        )
    }

    struct PressFeedbackRowButtonStyle: ButtonStyle {
        var enabled: Bool
        var pressScale: CGFloat

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(scale(for: configuration))
                .animation(LNAnimations.springFast,
                           value: configuration.isPressed && enabled)
        }

        private func scale(for configuration: Configuration) -> CGFloat {
            guard enabled else { return 1.0 }
            let clamped = max(min(pressScale, 1.0), 0.5)
            return configuration.isPressed ? clamped : 1.0
        }
    }

    @ViewBuilder
    func indicatorOverrideCard(for entry: IndicatorScreenEntry) -> some View {
        let useCustom = indicatorCustomBinding(for: entry.id)
        let offsetValue = appStore.scopedPageIndicatorOverride(for: entry.id, mode: selectedAppearanceLayoutMode)?.offset
            ?? appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode)
        let topPaddingValue = appStore.scopedPageIndicatorOverride(for: entry.id, mode: selectedAppearanceLayoutMode)?.topPadding
            ?? appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode)

        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(.subheadline.weight(.semibold))
                    Text(entry.sizeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !entry.isConnected {
                    Text(appStore.localized(.indicatorOfflineBadge))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Picker("", selection: useCustom) {
                    Text(appStore.localized(.defaultOption)).tag(false)
                    Text(appStore.localized(.customOption)).tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }

            if useCustom.wrappedValue {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(appStore.localized(.pageIndicatorOffsetLabel))
                            .font(.caption)
                        Spacer()
                        Text(String(format: "%.0f", offsetValue))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: indicatorOffsetBinding(for: entry.id), in: 0...80)

                    HStack {
                        Text("0").font(.footnote)
                        Spacer()
                        Text(String(format: "%.0f", offsetValue)).font(.footnote.monospacedDigit())
                        Spacer()
                        Text("80").font(.footnote)
                    }

                    HStack {
                        Text(appStore.localized(.pageIndicatorTopPaddingLabel))
                            .font(.caption)
                        Spacer()
                        Text(String(format: "%.0f", topPaddingValue))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: indicatorTopPaddingBinding(for: entry.id),
                           in: AppStore.pageIndicatorTopPaddingRange)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }
    
    func toggleExpandedSource(_ path: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            let normalized = standardizePath(path)
            expandedSource = (expandedSource == normalized) ? nil : normalized
        }
    }

    func removeAppFromLayout(_ rawPath: String) {
        let normalized = standardizePath(rawPath)
        // Replace matching top-level items with empty placeholders.
        var updatedItems = appStore.items
        for idx in updatedItems.indices {
            switch updatedItems[idx] {
            case .app(let app) where standardizePath(app.url.path) == normalized:
                updatedItems[idx] = .empty(UUID().uuidString)
            case .missingApp(let placeholder) where standardizePath(placeholder.bundlePath) == normalized:
                updatedItems[idx] = .empty(UUID().uuidString)
            case .folder(var folder):
                let originalCount = folder.apps.count
                folder.apps.removeAll { standardizePath($0.url.path) == normalized }
                if folder.apps.count != originalCount {
                    if folder.apps.isEmpty {
                        updatedItems[idx] = .empty(UUID().uuidString)
                    } else {
                        updatedItems[idx] = .folder(folder)
                    }
                }
            default:
                break
            }
        }
        appStore.items = updatedItems

        // Sync cleanup in the folders list.
        for idx in appStore.folders.indices {
            appStore.folders[idx].apps.removeAll { standardizePath($0.url.path) == normalized }
        }
        // Cleanup in the apps list.
        appStore.apps.removeAll { standardizePath($0.url.path) == normalized }

        appStore.compactItemsWithinPages()
        appStore.removeEmptyPages()
        DispatchQueue.main.async {
            appStore.folderUpdateTrigger = UUID()
            appStore.gridRefreshTrigger = UUID()
        }
        appStore.saveAllOrder()
    }

}
