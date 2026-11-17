import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(appStore.localized(.backupPlaceholderTitle))
                .font(.headline)

            HStack(spacing: 12) {
                updateControlButton(
                    title: appStore.localized(.backupChooseFolderButton),
                    systemImage: "folder"
                ) {
                    chooseBackupFolder()
                }

                updateControlButton(
                    title: appStore.localized(.backupCreateButton),
                    systemImage: "tray.and.arrow.down",
                    isPrimary: true
                ) {
                    createBackupInSelectedFolder()
                }
                .disabled(backupRootURL == nil)

                updateControlButton(
                    title: appStore.localized(.backupDeleteSelectedButton),
                    systemImage: "trash"
                ) {
                    deleteSelectedBackups()
                }
                .disabled(selectedBackupIDs.isEmpty)
            }

            DisclosureGroup(isExpanded: $showCleanupCommand) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(appStore.localized(.backupCleanupIntroPrimary))
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Text(appStore.localized(.backupCleanupIntroSecondary))
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Text(appStore.localized(.backupCleanupWarning))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(appStore.localized(.backupCleanupInstruction))
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    HStack {
                        Spacer()
                        Button {
                            copyCleanupCommand()
                        } label: {
                            Label(cleanupCommandCopied
                                  ? appStore.localized(.backupCleanupCopiedLabel)
                                  : appStore.localized(.backupCleanupCopyButton),
                                  systemImage: cleanupCommandCopied ? "checkmark" : "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }

                    Text(dataStoreCleanupCommand)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(nsColor: .windowBackgroundColor))
                        )

                    Text(appStore.localized(.backupCleanupCommandDetails))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } label: {
                Label(appStore.localized(.backupCleanupDisclosureTitle), systemImage: "wand.and.stars")
                    .font(.callout.weight(.semibold))
            }

            if let backupRootURL {
                Text(backupRootURL.path)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text(appStore.localized(.backupNoFolderSelected))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if backupEntries.isEmpty {
                Text(appStore.localized(.backupNoBackupsFound))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(backupEntries.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Toggle("", isOn: selectionBinding(for: entry.id))
                                .labelsHidden()
                                .toggleStyle(.checkbox)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.displayDate)
                                    .font(.callout.weight(.semibold))
                                Text(entry.displaySize)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            // 「恢复」会用这份备份整体替换当前布局（文件夹、排序、
                            // 偏好都在内），且没有撤销，所以只弹确认、不直接执行。
                            Button(appStore.localized(.backupImportButton)) {
                                pendingBackupRestore = entry
                            }
                            .buttonStyle(.bordered)

                            Button(appStore.localized(.backupDeleteButton)) {
                                deleteBackup(entry)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                        if index < backupEntries.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor))
                )

                Text(appStore.localized(.backupEstimatedSizeHint))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }

            // 「重置布局」从「通用」搬到这里：它清的是文件夹、排序与扫描结果，
            // 正是本页在备份/恢复的那份数据，放在日常设置里既没线索也容易误触。
            // 刻意不用 SettingsResetFooter：那条通用文案写着「不影响文件夹、排序
            // 和已扫描的应用」，对这个动作恰好相反，会误导。
            Divider()
                .padding(.top, 8)

            HStack(spacing: 18) {
                Spacer()
                Button {
                    showResetConfirm = true
                } label: {
                    Label(appStore.localized(.resetLayout), systemImage: "square.grid.3x3")
                        .foregroundStyle(Color.red)
                        // 图标与文字之间的间隙原本点不到，铺满命中区域。
                        .settingsHitArea()
                }
                .buttonStyle(.plain)
            }
            .alert(appStore.localized(.resetAlertTitle), isPresented: $showResetConfirm) {
                Button(appStore.localized(.resetConfirm), role: .destructive) { appStore.resetLayout() }
                Button(appStore.localized(.cancel), role: .cancel) {}
            } message: {
                Text(appStore.localized(.resetAlertMessage))
            }
        }
        // 备份行的「恢复」确认。挂在整页上而不是每一行上：
        // 行是 ForEach 出来的，逐行挂 alert 时 SwiftUI 只保证最后注册的那个生效，
        // 很容易出现「点了第 3 行、却弹出第 1 行的确认」。
        .alert(
            appStore.localized(.overwriteLayoutConfirmTitle),
            isPresented: Binding(
                get: { pendingBackupRestore != nil },
                set: { if !$0 { pendingBackupRestore = nil } }
            )
        ) {
            Button(appStore.localized(.backupImportButton), role: .destructive) {
                guard let entry = pendingBackupRestore else { return }
                pendingBackupRestore = nil
                importDataFolder(from: entry.url)
            }
            Button(appStore.localized(.cancel), role: .cancel) {
                pendingBackupRestore = nil
            }
        } message: {
            Text(appStore.localized(.overwriteLayoutConfirmMessage))
        }
    }

    var backupRootURL: URL? {
        guard !backupRootPath.isEmpty else { return nil }
        return URL(fileURLWithPath: backupRootPath, isDirectory: true)
    }

    var backupEntries: [BackupEntry] {
        _ = backupRefreshToken
        guard let root = backupRootURL else { return [] }
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return []
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'_'HH.mm.ss"

        var entries: [BackupEntry] = []
        for url in contents {
            let name = url.lastPathComponent
            guard name.hasPrefix("LaunchNext_"), name.hasSuffix(".launchnext") else { continue }
            let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            guard isDirectory else { continue }
            let storeURL = url.appendingPathComponent("Data.store")
            guard fm.fileExists(atPath: storeURL.path) else { continue }
            let rawDate = name
                .replacingOccurrences(of: "LaunchNext_", with: "")
                .replacingOccurrences(of: ".launchnext", with: "")
            guard let date = formatter.date(from: rawDate) else { continue }
            let size = dataStoreSize(at: url)
            entries.append(BackupEntry(id: url.path, url: url, date: date, sizeBytes: size))
        }

        return entries.sorted { $0.date > $1.date }
    }

    struct BackupEntry: Identifiable {
        let id: String
        let url: URL
        let date: Date
        let sizeBytes: Int64

        var displayDate: String {
            let formatter = DateFormatter()
            formatter.locale = .current
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }

        var displaySize: String {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return formatter.string(fromByteCount: sizeBytes)
        }
    }

    func dataStoreSize(at url: URL) -> Int64 {
        let storeURL = url.appendingPathComponent("Data.store")
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: storeURL.path),
              let size = attributes[.size] as? NSNumber else {
            return 0
        }
        return size.int64Value
    }

    var dataStoreCleanupCommand: String {
        let dataStorePath: String
        if let supportURL = try? supportDirectoryURL() {
            dataStorePath = supportURL.appendingPathComponent("Data.store").path
        } else {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            dataStorePath = "\(home)/Library/Application Support/LaunchNext/Data.store"
        }
        let escapedPath = dataStorePath.replacingOccurrences(of: "\"", with: "\\\"")
        return """
        DB="\(escapedPath)"
        sqlite3 "$DB" <<'SQL'
        PRAGMA wal_checkpoint(FULL);
        DELETE FROM ACHANGE;
        VACUUM;
        SQL
        """
    }

    func copyCleanupCommand() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(dataStoreCleanupCommand, forType: .string)
        cleanupCommandCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            cleanupCommandCopied = false
        }
    }

    func chooseBackupFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = appStore.localized(.chooseButton)
        if panel.runModal() == .OK, let url = panel.url {
            backupRootPath = url.path
            UserDefaults.standard.set(backupRootPath, forKey: "backupRootDirectory")
            backupRefreshToken = UUID()
            selectedBackupIDs.removeAll()
        }
    }

    func createBackupInSelectedFolder() {
        guard let destParent = backupRootURL else { return }
        do {
            try exportDataFolder(to: destParent)
            backupRefreshToken = UUID()
        } catch {
            showBackupExportError(error)
        }
    }

    func selectionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { selectedBackupIDs.contains(id) },
            set: { isSelected in
                if isSelected {
                    selectedBackupIDs.insert(id)
                } else {
                    selectedBackupIDs.remove(id)
                }
            }
        )
    }

    func deleteSelectedBackups() {
        let targets = backupEntries.filter { selectedBackupIDs.contains($0.id) }
        guard !targets.isEmpty else { return }

        let alert = NSAlert()
        alert.messageText = appStore.localized(.backupDeleteMultipleTitle)
        alert.informativeText = String(format: appStore.localized(.backupDeleteMultipleMessageFormat), targets.count)
        alert.alertStyle = .warning
        let deleteButton = alert.addButton(withTitle: appStore.localized(.backupDeleteButton))
        if #available(macOS 11.0, *) {
            deleteButton.hasDestructiveAction = true
        }
        alert.addButton(withTitle: appStore.localized(.cancel))

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .alertFirstButtonReturn else { return }
            for entry in targets {
                try? FileManager.default.removeItem(at: entry.url)
            }
            selectedBackupIDs.removeAll()
            backupRefreshToken = UUID()
        }

        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window, completionHandler: handler)
        } else {
            handler(alert.runModal())
        }
    }

    func deleteBackup(_ entry: BackupEntry) {
        let alert = NSAlert()
        alert.messageText = appStore.localized(.backupDeleteSingleTitle)
        alert.informativeText = appStore.localized(.backupDeleteSingleMessage)
        alert.alertStyle = .warning
        let deleteButton = alert.addButton(withTitle: appStore.localized(.backupDeleteButton))
        if #available(macOS 11.0, *) {
            deleteButton.hasDestructiveAction = true
        }
        alert.addButton(withTitle: appStore.localized(.cancel))

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .alertFirstButtonReturn else { return }
            do {
                try FileManager.default.removeItem(at: entry.url)
                backupRefreshToken = UUID()
            } catch {
                // ignore for now
            }
        }

        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window, completionHandler: handler)
        } else {
            handler(alert.runModal())
        }
    }

    func supportDirectoryURL() throws -> URL {
        let fm = FileManager.default
        let appSupport = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = appSupport.appendingPathComponent("LaunchNext", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func exportDataFolder() {
        do {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.canCreateDirectories = true
            panel.allowsMultipleSelection = false
            panel.prompt = appStore.localized(.chooseButton)
            panel.message = appStore.localized(.exportPanelMessage)
            if panel.runModal() == .OK, let destParent = panel.url {
                try exportDataFolder(to: destParent)
            }
        } catch {
            showBackupExportError(error)
        }
    }

    func exportDataFolder(to destParent: URL) throws {
        let sourceDir = try supportDirectoryURL()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'_'HH.mm.ss"
        let folderName = "LaunchNext_" + formatter.string(from: Date()) + ".launchnext"
        let destDir = destParent.appendingPathComponent(folderName, isDirectory: true)
        let fm = FileManager.default

        func performExport() throws {
            try copyDirectory(from: sourceDir, to: destDir)
            exportPreferences(to: destDir)
            guard backupExportLooksComplete(destDir) else {
                throw NSError(domain: "LaunchNextBackup",
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Backup export is incomplete."])
            }
        }

        do {
            try performExport()
        } catch {
            try? fm.removeItem(at: destDir)

            guard removeLegacyBackupSocketIfNeeded() else {
                throw error
            }

            do {
                try performExport()
            } catch {
                try? fm.removeItem(at: destDir)
                throw error
            }
        }
    }

    func importDataFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = appStore.localized(.importPrompt)
        panel.message = appStore.localized(.importPanelMessage)
        if panel.runModal() == .OK, let srcDir = panel.url {
            importDataFolder(from: srcDir)
        }
    }

    func importDataFolder(from srcDir: URL) {
        do {
            // Validate this is a valid export folder
            guard isValidExportFolder(srcDir) else { return }

            func performImport(importData: Bool, importPrefs: Bool, allowedPrefKeys: Set<String>) throws {
                let destDir = try supportDirectoryURL()
                if importData {
                    if srcDir.standardizedFileURL != destDir.standardizedFileURL {
                        try replaceDirectory(with: srcDir, at: destDir)
                        appStore.applyOrderAndFolders()
                        appStore.refresh()
                    }
                }
                if importPrefs {
                    importPreferences(from: srcDir, allowedKeys: allowedPrefKeys.isEmpty ? nil : allowedPrefKeys)
                    appStore.reloadPreferencesFromDefaults()
                    appStore.refresh()
                }
            }

            // Ask user what to import (attach as sheet to stay on the same screen)
            let alert = NSAlert()
            alert.messageText = appStore.localized(.importPrompt)
            alert.informativeText = appStore.localized(.importPanelMessage)
            alert.icon = NSApplication.shared.applicationIconImage
            alert.addButton(withTitle: appStore.localized(.importPrompt)) // Confirm
            alert.addButton(withTitle: appStore.localized(.cancel))      // Cancel

            let content = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))

            func makeCheckbox(_ title: String, state: NSControl.StateValue = .on) -> NSButton {
                let button = NSButton(checkboxWithTitle: title, target: nil, action: nil)
                button.state = state
                button.allowsMixedState = false
                button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                button.cell?.wraps = true
                button.cell?.lineBreakMode = .byWordWrapping
                return button
            }

            let dataCheckbox = makeCheckbox("Layout & data")
            let generalCheckbox = makeCheckbox(appStore.localized(.settingsSectionGeneral))
            let appearanceCheckbox = makeCheckbox(appStore.localized(.settingsSectionAppearance))
            let sourcesCheckbox = makeCheckbox(appStore.localized(.settingsSectionAppSources))
            let hiddenCheckbox = makeCheckbox(appStore.localized(.settingsSectionHiddenApps))
            let titlesCheckbox = makeCheckbox(appStore.localized(.settingsSectionTitles))

            let stack = NSStackView(views: [
                dataCheckbox,
                generalCheckbox,
                appearanceCheckbox,
                sourcesCheckbox,
                hiddenCheckbox,
                titlesCheckbox
            ])
            stack.orientation = .vertical
            stack.alignment = .leading
            stack.spacing = 6
            stack.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 4),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: content.trailingAnchor, constant: -8),
                stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 4),
                stack.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor)
            ])

            // Size to fit content (min width 320, min height 160)
            let fitting = stack.fittingSize
            let minWidth: CGFloat = 320
            let minHeight: CGFloat = 160
            content.setFrameSize(NSSize(width: max(minWidth, fitting.width + 16),
                                        height: max(minHeight, fitting.height + 12)))

            alert.accessoryView = content

            func selectedPrefKeys() -> Set<String> {
                var keys = Set<String>()
                if generalCheckbox.state == .on {
                    keys.insert("preferredLanguage")
                    keys.insert("appearancePreference")
                    keys.insert("isStartOnLogin")
                    keys.insert(AppStore.showQuickRefreshButtonKey)
                    keys.insert(AppStore.lockLayoutKey)
                    keys.insert(AppStore.uninstallToolAppPathKey)
                    keys.insert(AppStore.dockDragSideKey)
                    keys.insert(AppStore.dockDragTriggerDistanceKey)
                    keys.insert(AppStore.hotCornerEnabledKey)
                    keys.insert(AppStore.hotCornerPositionKey)
                    keys.insert(AppStore.hotCornerTriggerDelayKey)
                    keys.insert(AppStore.hotCornerHitboxSizeKey)
                    keys.insert(AppStore.hotCornerToggleWhenOpenKey)
                    // Experimental gesture backup keys. Remove these together
                    // with the gesture feature if low-level multitouch support
                    // is dropped later.
                    keys.insert(AppStore.gestureEnabledKey)
                    keys.insert(AppStore.gestureCloseOnPinchOutKey)
                    keys.insert(AppStore.gestureTapActionKey)
                    keys.insert(AppStore.gestureFingerCountKey)
                    keys.insert(AppStore.gestureDeviceSelectionModeKey)
                    keys.insert(AppStore.gestureSelectedDeviceIDsKey)
                    keys.insert(AppStore.gestureShowAllInputDevicesKey)
                }
                if appearanceCheckbox.state == .on {
                    keys.insert(AppStore.sidebarIconPresetKey)
                    keys.insert(AppStore.backgroundStyleKey)
                    keys.insert(AppStore.backgroundImageEnabledKey)
                    keys.insert(AppStore.backgroundImageSourceKey)
                    keys.insert(AppStore.customBackgroundImagePathKey)
                    keys.insert(AppStore.backgroundMaskEnabledKey)
                    keys.insert(AppStore.backgroundMaskLightKey)
                    keys.insert(AppStore.backgroundMaskDarkKey)
                    keys.insert("scrollSensitivity")
                    keys.insert("isFullscreenMode")
                    keys.insert("showLabels")
                    keys.insert("hideDock")
                    keys.insert(AppStore.hideMenuBarKey)
                    keys.insert("enableAnimations")
                    keys.insert(AppStore.windowOpenAnimationKey)
                    keys.insert(AppStore.windowAnimationDurationKey)
                    keys.insert("useLocalizedThirdPartyTitles")
                    keys.insert("enableDropPrediction")
                    keys.insert(AppStore.reverseWheelPagingKey)
                    keys.insert(AppStore.reverseWheelVerticalKey)
                    keys.insert(AppStore.trackpadVerticalDirectionKey)
                    keys.insert(AppStore.rememberPageKey)
                    keys.insert(AppStore.rememberedPageIndexKey)
                    keys.insert("iconScale")
                    keys.insert("iconLabelFontSize")
                    keys.insert(AppStore.iconLabelFontWeightKey)
                    keys.insert("gridColumnsPerPage")
                    keys.insert("gridRowsPerPage")
                    keys.insert("gridColumnSpacing")
                    keys.insert("gridRowSpacing")
                    keys.insert("folderDropZoneScale")
                    keys.insert(AppStore.folderPreviewHighResKey)
                    keys.insert(AppStore.folderQuickLaunchEnabledKey)
                    keys.insert(AppStore.folderLayoutModeKey)
                    keys.insert("pageIndicatorOffset")
                    keys.insert(AppStore.pageIndicatorTopPaddingKey)
                    keys.insert(AppStore.pageIndicatorPerDisplayEnabledKey)
                    keys.insert(AppStore.pageIndicatorPerDisplayOverridesKey)
                    keys.insert(AppStore.dualModeAppearanceSettingsKey)
                    keys.insert(AppStore.dockDragEnabledKey)
                    keys.insert("folderPopoverWidthFactor")
                    keys.insert("folderPopoverHeightFactor")
                    keys.insert(AppStore.hoverMagnificationKey)
                    keys.insert(AppStore.hoverMagnificationScaleKey)
                    keys.insert(AppStore.activePressEffectKey)
                    keys.insert(AppStore.activePressScaleKey)
                    keys.insert("animationDuration")
                    keys.insert("globalHotKeyConfiguration")
                    keys.insert(AppStore.useCAGridRendererKey)
                    keys.insert("showFPSOverlay")
                    keys.insert("gameControllerEnabled")
                    keys.insert(AppStore.gameControllerMenuToggleKey)
                }
                if hiddenCheckbox.state == .on {
                    keys.insert(AppStore.hiddenAppsKey)
                }
                if sourcesCheckbox.state == .on {
                    keys.insert(AppStore.customAppSourcesKey)
                }
                if titlesCheckbox.state == .on {
                    keys.insert(AppStore.customTitlesKey)
                }
                return keys
            }

            if let window = NSApp.keyWindow ?? NSApp.mainWindow {
                alert.beginSheetModal(for: window) { response in
                    guard response == .alertFirstButtonReturn else { return }
                    let importData = dataCheckbox.state == .on
                    let keys = selectedPrefKeys()
                    let importPrefs = !keys.isEmpty
                    do {
                        try performImport(importData: importData, importPrefs: importPrefs, allowedPrefKeys: keys)
                    } catch {
                        // Ignore failed import
                    }
                }
            } else {
                let response = alert.runModal()
                guard response == .alertFirstButtonReturn else { return }
                let importData = dataCheckbox.state == .on
                let keys = selectedPrefKeys()
                let importPrefs = !keys.isEmpty
                try performImport(importData: importData, importPrefs: importPrefs, allowedPrefKeys: keys)
            }
        } catch {
            // Ignore errors or surface a user-facing message if desired
        }
    }

    // MARK: - Preferences export/import
    var currentPrefsDomain: String {
        Bundle.main.bundleIdentifier ?? "LaunchNextAppStore"
    }

    func exportPreferences(to folder: URL) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: folder.path) {
            try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        }

        let domain = currentPrefsDomain
        guard var dict = UserDefaults.standard.persistentDomain(forName: domain), !dict.isEmpty else { return }
        dict.removeValue(forKey: AppStore.showQuarantineRemovalActionKey)
        guard !dict.isEmpty else { return }
        let url = folder.appendingPathComponent("\(domain).plist")
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
            try data.write(to: url)
        } catch {
            // ignore failure
        }
    }

    func importPreferences(from folder: URL, allowedKeys: Set<String>? = nil) {
        let domain = currentPrefsDomain
        let candidateNames = [domain, AppStore.legacyPreferencesDomain]
        guard let url = candidateNames
            .map({ folder.appendingPathComponent("\($0).plist") })
            .first(where: { FileManager.default.fileExists(atPath: $0.path) }) else { return }
        do {
            let data = try Data(contentsOf: url)
            guard var incoming = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { return }

            // Developer quarantine tooling is intentionally local to this Mac.
            incoming.removeValue(forKey: AppStore.showQuarantineRemovalActionKey)

            if let allowedKeys, !allowedKeys.isEmpty {
                incoming = incoming.filter { allowedKeys.contains($0.key) }
            }
            guard !incoming.isEmpty else { return }

            // Merge with existing prefs to avoid wiping unselected keys
            var current = UserDefaults.standard.persistentDomain(forName: domain) ?? [:]
            incoming.forEach { current[$0.key] = $0.value }
            UserDefaults.standard.setPersistentDomain(current, forName: domain)
        } catch {
            // ignore failed domain restore
        }
        UserDefaults.standard.synchronize()
    }

    func copyDirectory(from src: URL, to dst: URL) throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: dst.path) {
            try fm.removeItem(at: dst)
        }
        try fm.createDirectory(at: dst, withIntermediateDirectories: true)
        copyDirectoryMetadata(from: src, to: dst)

        guard let enumerator = fm.enumerator(at: src,
                                             includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
                                             options: [],
                                             errorHandler: { _, _ in true }) else {
            throw NSError(domain: "LaunchNextBackup",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to enumerate backup source directory."])
        }

        for case let itemURL as URL in enumerator {
            if isSocketFile(at: itemURL) {
                continue
            }

            let relativePath = itemURL.path.replacingOccurrences(of: src.path + "/", with: "")
            let targetURL = dst.appendingPathComponent(relativePath, isDirectory: false)
            let values = try itemURL.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])

            if values.isDirectory == true {
                try fm.createDirectory(at: targetURL, withIntermediateDirectories: true)
                copyDirectoryMetadata(from: itemURL, to: targetURL)
                continue
            }

            let parentDirectory = targetURL.deletingLastPathComponent()
            if !fm.fileExists(atPath: parentDirectory.path) {
                try fm.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
            }

            if fm.fileExists(atPath: targetURL.path) {
                try fm.removeItem(at: targetURL)
            }

            if values.isSymbolicLink == true {
                let destination = try fm.destinationOfSymbolicLink(atPath: itemURL.path)
                try fm.createSymbolicLink(atPath: targetURL.path, withDestinationPath: destination)
            } else {
                try fm.copyItem(at: itemURL, to: targetURL)
            }
        }
    }

    func copyDirectoryMetadata(from src: URL, to dst: URL) {
        copyExtendedAttributes(from: src, to: dst)

        let fm = FileManager.default
        guard let attributes = try? fm.attributesOfItem(atPath: src.path) else { return }

        var copied: [FileAttributeKey: Any] = [:]
        if let permissions = attributes[.posixPermissions] {
            copied[.posixPermissions] = permissions
        }
        if let immutability = attributes[.immutable] {
            copied[.immutable] = immutability
        }

        if !copied.isEmpty {
            try? fm.setAttributes(copied, ofItemAtPath: dst.path)
        }
    }

    func copyExtendedAttributes(from src: URL, to dst: URL) {
        let options: Int32 = 0

        src.path.withCString { srcPath in
            dst.path.withCString { dstPath in
                let size = listxattr(srcPath, nil, 0, options)
                guard size > 0 else { return }

                var nameBuffer = [CChar](repeating: 0, count: size)
                let readSize = listxattr(srcPath, &nameBuffer, nameBuffer.count, options)
                guard readSize > 0 else { return }

                var index = 0
                while index < Int(readSize) {
                    let name = nameBuffer.withUnsafeBufferPointer { buffer -> String in
                        String(cString: buffer.baseAddress!.advanced(by: index))
                    }

                    let valueSize = getxattr(srcPath, name, nil, 0, 0, options)
                    if valueSize >= 0 {
                        var valueBuffer = [UInt8](repeating: 0, count: valueSize)
                        let actualSize = getxattr(srcPath, name, &valueBuffer, valueBuffer.count, 0, options)
                        if actualSize >= 0 {
                            valueBuffer.withUnsafeBytes { rawBuffer in
                                _ = setxattr(dstPath, name, rawBuffer.baseAddress, actualSize, 0, options)
                            }
                        }
                    }

                    index += name.utf8.count + 1
                }
            }
        }
    }

    func replaceDirectory(with src: URL, at dst: URL) throws {
        let fm = FileManager.default
        // Ensure parent directory exists
        let parent = dst.deletingLastPathComponent()
        if !fm.fileExists(atPath: parent.path) {
            try fm.createDirectory(at: parent, withIntermediateDirectories: true)
        }
        if fm.fileExists(atPath: dst.path) {
            try fm.removeItem(at: dst)
        }
        try fm.copyItem(at: src, to: dst)
    }

    func backupExportLooksComplete(_ folder: URL) -> Bool {
        let fm = FileManager.default
        let requiredFiles = [
            folder.appendingPathComponent("Data.store"),
            folder.appendingPathComponent("\(currentPrefsDomain).plist")
        ]
        return requiredFiles.allSatisfy { fm.fileExists(atPath: $0.path) }
    }

    func removeLegacyBackupSocketIfNeeded() -> Bool {
        guard let legacySocketURL = try? supportDirectoryURL().appendingPathComponent(LaunchNextCLIIPCConfig.socketFileName, isDirectory: false) as URL else {
            return false
        }
        guard isSocketFile(at: legacySocketURL) else { return false }
        do {
            try FileManager.default.removeItem(at: legacySocketURL)
            return true
        } catch {
            return false
        }
    }

    func isSocketFile(at url: URL) -> Bool {
        var fileStat = stat()
        let result = url.path.withCString { path in
            Darwin.lstat(path, &fileStat)
        }
        guard result == 0 else { return false }
        return (fileStat.st_mode & S_IFMT) == S_IFSOCK
    }

    func showBackupExportError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Backup Failed"
        let message = (error as NSError).localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        alert.informativeText = message.isEmpty ? "ZeroLaunch could not create a complete backup." : message
        alert.alertStyle = .warning
        alert.addButton(withTitle: appStore.localized(.okButton))

        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }

    func isValidExportFolder(_ folder: URL) -> Bool {
        let fm = FileManager.default
        let storeURL = folder.appendingPathComponent("Data.store")
        guard fm.fileExists(atPath: storeURL.path) else { return false }
        // Try opening the store and verify it contains layout data
        do {
            let config = ModelConfiguration(url: storeURL)
            let container = try ModelContainer(for: TopItemData.self, PageEntryData.self, configurations: config)
            let ctx = container.mainContext
            let pageEntries = try ctx.fetch(FetchDescriptor<PageEntryData>())
            if !pageEntries.isEmpty { return true }
            let legacyEntries = try ctx.fetch(FetchDescriptor<TopItemData>())
            return !legacyEntries.isEmpty
        } catch {
            return false
        }
    }

    func importFromLaunchpad() {
        Task {
            let result = await appStore.importFromNativeLaunchpad()

            DispatchQueue.main.async {
                let alert = NSAlert()
                if result.success {
                    alert.messageText = appStore.localized(.importSuccessfulTitle)
                    alert.informativeText = result.message
                    alert.alertStyle = .informational
                } else {
                    alert.messageText = appStore.localized(.importFailedTitle)
                    alert.informativeText = result.message
                    alert.alertStyle = .warning
                }
                alert.addButton(withTitle: appStore.localized(.okButton))
                alert.runModal()
            }
        }
    }

    func applyMacOS26PresetLayout() {
        let success = appStore.applyMacOS26PresetLayout()

        let alert = NSAlert()
        if success {
            alert.messageText = appStore.localized(.layoutPresetAppliedTitle)
            alert.informativeText = appStore.localized(.layoutPresetAppliedMessage)
            alert.alertStyle = .informational
        } else {
            alert.messageText = appStore.localized(.importFailedTitle)
            alert.informativeText = appStore.localized(.layoutPresetApplyFailedMessage)
            alert.alertStyle = .warning
        }
        alert.addButton(withTitle: appStore.localized(.okButton))
        alert.runModal()
    }

    func importLegacyArchive() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = ["lmy", "zip", "db"].compactMap { UTType(filenameExtension: $0) }
        panel.prompt = appStore.localized(.importPrompt)
        panel.message = appStore.localized(.legacyArchivePanelMessage)

        if panel.runModal() == .OK, let url = panel.url {
            Task {
                let result = await appStore.importFromLegacyLaunchpadArchive(url: url)
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    if result.success {
                        alert.messageText = appStore.localized(.importSuccessfulTitle)
                        alert.informativeText = result.message
                        alert.alertStyle = .informational
                    } else {
                        alert.messageText = appStore.localized(.importFailedTitle)
                        alert.informativeText = result.message
                        alert.alertStyle = .warning
                    }
                    alert.addButton(withTitle: appStore.localized(.okButton))
                    alert.runModal()
                }
            }
        }
    }

    // MARK: - Update Check Section
}
