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
                            //
                            // 确认界面由 importDataFolder(from:) 设到
                            // `pendingImportRequest`，在设置面板底部的页内卡片里呈现。
                            // 这里刻意不用任何 alert：设置面板本身是 sheet，在它上面
                            // 再叠一层弹窗（包括在 SwiftUI alert 回调里同步 beginSheetModal）
                            // 会被 AppKit 静默丢弃，表现为「点了导入没反应」。
                            Button(appStore.localized(.backupImportButton)) {
                                importDataFolder(from: entry.url)
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
        // 「恢复」的覆盖确认与导入范围选择合并成一张页内卡片（SettingsView 底部的
        // importOverlayLayer），这里不再挂任何 alert。
        //
        // 原因：设置面板自身以 .sheet 呈现，SwiftUI alert 也是一层 sheet。在它的
        // 按钮回调里同步调用 NSAlert.beginSheetModal，会因为「窗口上已有 sheet」
        // 被 AppKit 静默拒绝 —— 用户点「导入」后什么都不会发生。页内卡片只是普通
        // 视图，不参与窗口模态管理，必定可见。
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
            dataStorePath = "\(home)/Library/Application Support/\(AppIdentity.displayName)/Data.store"
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

        // 用 app-modal 而不是 beginSheetModal(for: NSApp.keyWindow)：
        // 设置面板本身是 sheet，keyWindow 就是那个 sheet 窗口，AppKit 会静默拒绝
        // 在它上面再挂 sheet —— 表现是点了「删除」完全没有反应。
        handler(alert.runModal())
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

        // 用 app-modal 而不是 beginSheetModal(for: NSApp.keyWindow)：
        // 设置面板本身是 sheet，keyWindow 就是那个 sheet 窗口，AppKit 会静默拒绝
        // 在它上面再挂 sheet —— 表现是点了「删除」完全没有反应。
        handler(alert.runModal())
    }

    func supportDirectoryURL() throws -> URL {
        // 必须与运行时 ModelContainer 的数据目录一致（LaunchpadApp.makePreferredModelContainer
        // 用的是 AppIdentity.appSupportDirectory）。改名后这里曾硬编码 "LaunchNext"，
        // 导致备份写进旧目录、导入也写进旧目录，而应用实际读的是 "ZeroLaunch"，
        // 表现为「点了导入但界面毫无变化」。
        AppIdentity.appSupportDirectory()
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

        // 这里必须用 app-modal 的 runModal，不能 beginSheetModal(for: 设置窗口)：
        // 设置面板自身是一个 sheet，AppKit 拒绝在 sheet 窗口上再挂 sheet，且是
        // 静默失败（面板永远不出现、回调永不触发）。这正是「点导入没有任何变化」
        // 的成因，别改回去。
        if panel.runModal() == .OK, let srcDir = panel.url {
            importDataFolder(from: srcDir)
        }
    }

    /// 把备份 store 里的布局记录（分页/文件夹/排序）迁进当前正在运行的 ModelContext。
    ///
    /// 不能直接替换磁盘上的 Data.store：App 启动时已经打开了这个 SQLite 文件（连同
    /// -wal / -shm，见 LaunchpadApp.makePreferredModelContainer），换掉文件只会让磁盘副本
    /// 变了，运行中的 container 仍从旧连接读数据 —— 这正是「点了导入却没变化」的根因。
    /// 记录级迁移写入的是当前 container 本身，导入后立刻对本会话生效，无需重启。
    func importLayoutRecords(from backupStoreURL: URL) throws -> Int {
        let configuration = ModelConfiguration(url: backupStoreURL)
        let backupContainer = try ModelContainer(for: TopItemData.self, PageEntryData.self, configurations: configuration)
        let backupContext = backupContainer.mainContext

        // 先快照成纯值，避免跨 container 直接持有备份侧的 @Model 对象。
        let pages = try backupContext.fetch(FetchDescriptor<PageEntryData>()).map {
            (slotId: $0.slotId, pageIndex: $0.pageIndex, position: $0.position, kind: $0.kind,
             appPath: $0.appPath, appDisplayName: $0.appDisplayName, folderId: $0.folderId,
             folderName: $0.folderName, appPaths: $0.appPaths, pinnedAppPaths: $0.pinnedAppPaths,
             removableSource: $0.removableSource, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        let topItems = try backupContext.fetch(FetchDescriptor<TopItemData>()).map {
            (id: $0.id, kind: $0.kind, orderIndex: $0.orderIndex, appPath: $0.appPath,
             folderName: $0.folderName, appPaths: $0.appPaths, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
        }
        guard !pages.isEmpty || !topItems.isEmpty else {
            throw NSError(domain: "ZeroLaunchBackup", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Backup contains no layout data."])
        }
        guard let liveContext = appStore.modelContext else {
            throw NSError(domain: "ZeroLaunchBackup", code: 4,
                          userInfo: [NSLocalizedDescriptionKey: "Data context is not available."])
        }

        // 分两次 save：先删空再插入，规避 @Attribute(.unique) 的主键冲突。
        let oldPages = try liveContext.fetch(FetchDescriptor<PageEntryData>())
        oldPages.forEach { liveContext.delete($0) }
        let oldTopItems = try liveContext.fetch(FetchDescriptor<TopItemData>())
        oldTopItems.forEach { liveContext.delete($0) }
        try liveContext.save()

        for p in pages {
            liveContext.insert(PageEntryData(
                slotId: p.slotId, pageIndex: p.pageIndex, position: p.position, kind: p.kind,
                appPath: p.appPath, folderId: p.folderId, folderName: p.folderName,
                appPaths: p.appPaths, pinnedAppPaths: p.pinnedAppPaths,
                appDisplayName: p.appDisplayName, removableSource: p.removableSource,
                createdAt: p.createdAt, updatedAt: p.updatedAt))
        }
        for t in topItems {
            // kind 由快照原样恢复（folder/app/empty/其它历史值），不能用单一构造器代替。
            let item = TopItemData(emptyId: t.id, orderIndex: t.orderIndex,
                                   createdAt: t.createdAt, updatedAt: t.updatedAt)
            item.kind = t.kind
            item.appPath = t.appPath
            item.folderName = t.folderName
            item.appPaths = t.appPaths
            liveContext.insert(item)
        }
        try liveContext.save()
        return pages.count + topItems.count
    }

    // MARK: - 导入（页内卡片，不依赖任何模态窗口）

    /// 把导入全链路写成文件日志。
    ///
    /// 用文件而不是只靠 NSLog：`log show` 默认过滤 info 级消息，出问题的时候一条都
    /// 看不到。文件日志在 `~/Library/Application Support/ZeroLaunch/ImportDebug.log`，
    /// 无论 UI 表现如何都能事后取证。
    func importLog(_ message: String) {
        NSLog("[ZeroLaunchImport] %@", message)
        guard let dir = try? AppIdentity.appSupportDirectory() else { return }
        let url = dir.appendingPathComponent("ImportDebug.log")
        let stamp = ISO8601DateFormatter().string(from: Date())
        guard let data = "\(stamp) \(message)\n".data(using: .utf8) else { return }
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.close()
        } else {
            try? data.write(to: url)
        }
    }

    struct ImportRequest: Identifiable {
        let id = UUID()
        let sourceDir: URL
        var displayName: String { sourceDir.lastPathComponent }
    }

    /// 导入范围。默认全部勾选：与原本 LaunchNext 的行为一致（它那 6 个勾选项
    /// 初始都是 `.on`），备份/恢复的预期就是「整份还原」。
    struct ImportScope {
        var layoutData = true
        var general = true
        var appearance = true
        var appSources = true
        var hiddenApps = true
        var titles = true
    }

    enum ImportBanner {
        case success(title: String)
        case failure(title: String, detail: String?)

        var isSuccess: Bool {
            if case .success = self { return true }
            return false
        }

        var title: String {
            switch self {
            case .success(let title): return title
            case .failure(let title, _): return title
            }
        }

        var detail: String? {
            switch self {
            case .success: return nil
            case .failure(_, let detail): return detail
            }
        }
    }

    /// 备份列表里那条备份的「导入」：先校验，再把确认卡片挂到 `pendingImportRequest`。
    ///
    /// 关键在于**不做任何模态弹窗**。设置面板本身就是 `.sheet`，在它上面再叠一层
    /// alert（SwiftUI 的或 AppKit 的）都可能被系统静默丢弃；设置面板是 SwiftUI
    /// sheet，在它的按钮回调里同步 `beginSheetModal` 尤其容易被悄悄拒掉 —— 用户
    /// 看到的就是「点了导入没有任何变化」。页内卡片只是普通视图，不参与窗口模态
    /// 管理，一定可见、一定可点。
    func importDataFolder(from srcDir: URL) {
        importLog("request src=\(srcDir.path)")
        let storeURL = srcDir.appendingPathComponent("Data.store", isDirectory: false)
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            importLog("validation FAILED: Data.store not found")
            importBanner = .failure(title: appStore.localized(.importFailedTitle),
                                    detail: appStore.localized(.importPanelMessage))
            return
        }
        guard isValidExportFolder(srcDir) else {
            importLog("validation FAILED: store unreadable or contains no layout data")
            importBanner = .failure(title: appStore.localized(.importFailedTitle),
                                    detail: appStore.localized(.importPanelMessage))
            return
        }
        importLog("validation OK")
        importScope = ImportScope()
        importBanner = nil
        pendingImportRequest = ImportRequest(sourceDir: srcDir)
    }

    func cancelPendingImport() {
        importLog("cancelled by user")
        pendingImportRequest = nil
        importBanner = nil
        importScope = ImportScope()
    }

    func confirmPendingImport() {
        guard let request = pendingImportRequest else { return }
        pendingImportRequest = nil
        let keys = prefKeys(for: importScope)
        let importData = importScope.layoutData
        importLog("confirm src=\(request.sourceDir.path) data=\(importData) prefKeys=\(keys.count)")

        guard importData || !keys.isEmpty else {
            importLog("aborted: nothing selected")
            importBanner = .failure(title: appStore.localized(.importFailedTitle), detail: nil)
            importScope = ImportScope()
            return
        }

        do {
            let destDir = try supportDirectoryURL()
            guard request.sourceDir.standardizedFileURL != destDir.standardizedFileURL else {
                importLog("FAILED: source directory == live data directory")
                importBanner = .failure(title: appStore.localized(.importFailedTitle),
                                        detail: appStore.localized(.importPanelMessage))
                importScope = ImportScope()
                return
            }

            var restored = 0
            if importData {
                let storeURL = request.sourceDir.appendingPathComponent("Data.store", isDirectory: false)
                restored = try importLayoutRecords(from: storeURL)
                importLog("restored \(restored) records")
            }

            if !keys.isEmpty {
                importPreferences(from: request.sourceDir, allowedKeys: keys)
                appStore.reloadPreferencesFromDefaults()
                importLog("preferences imported: \(keys.count) keys")
            }

            if importData {
                // 关键：必须走 reloadLayoutAfterImport，不能只 refresh()。
                // refresh() 会去跑应用对账，且不清 items 与网格布局缓存 —— 会出现
                // 「日志说导入成功、数据库也确实是备份内容，但桌面排布还是旧的」。
                appStore.reloadLayoutAfterImport()

                let store = appStore
                let source = request.sourceDir
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.importLog("applied, items=\(store.items.count) folders=\(store.folders.count)")
                    self.importLog("order digest=\(self.layoutDigest(store.items))")
                    self.importLog("backup digest=\(self.backupLayoutDigest(source))")
                }
            }

            importBanner = .success(title: importData
                                    ? "\(appStore.localized(.importSuccessfulTitle)) (\(restored))"
                                    : appStore.localized(.importSuccessfulTitle))
        } catch {
            importLog("FAILED: \(String(describing: error))")
            importBanner = .failure(title: appStore.localized(.importFailedTitle),
                                    detail: error.localizedDescription)
        }
        importScope = ImportScope()
    }

    /// 内存里前 12 个槽位的可读摘要，写进日志用来核对「导入后到底按什么顺序渲染」。
    func layoutDigest(_ items: [LaunchpadItem]) -> String {
        items.prefix(12).map { item in
            switch item {
            case .app(let app): return (app.url.path as NSString).lastPathComponent
            case .folder(let folder): return "[\(folder.name)]"
            case .missingApp(let placeholder): return "?\(placeholder.displayName)"
            case .empty: return "_"
            }
        }.joined(separator: ",")
    }

    /// 备份库里同样前 12 个槽位的摘要，用来和 `layoutDigest` 对照。
    func backupLayoutDigest(_ sourceDir: URL) -> String {
        let storeURL = sourceDir.appendingPathComponent("Data.store", isDirectory: false)
        do {
            let container = try ModelContainer(for: TopItemData.self, PageEntryData.self,
                                              configurations: ModelConfiguration(url: storeURL))
            let rows = try container.mainContext.fetch(FetchDescriptor<PageEntryData>(
                sortBy: [SortDescriptor(\.pageIndex, order: .forward),
                         SortDescriptor(\.position, order: .forward)]))
            return rows.prefix(12).map { row -> String in
                switch row.kind {
                case "folder": return "[\(row.folderName ?? "?")]"
                case "app", "missing":
                    return ((row.appPath ?? "") as NSString).lastPathComponent
                default: return "_"
                }
            }.joined(separator: ",")
        } catch {
            return "unavailable"
        }
    }

    /// 偏好设置勾选项 → UserDefaults key 集合。
    func prefKeys(for scope: ImportScope) -> Set<String> {
        var keys = Set<String>()
        if scope.general {
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
        if scope.appearance {
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
        if scope.hiddenApps {
            keys.insert(AppStore.hiddenAppsKey)
        }
        if scope.appSources {
            keys.insert(AppStore.customAppSourcesKey)
        }
        if scope.titles {
            keys.insert(AppStore.customTitlesKey)
        }
        return keys
    }

    /// 确认弹窗与结果弹窗共用的底板：材质 + 细描边 + 大阴影，参数化宽度。
    var importDialogBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 36, y: 14)
    }

    /// 导入确认弹窗：遮罩 + 居中卡片。
    ///
    /// 早期版本把确认界面做成了页面底部的浮动卡片，会盖住备份列表、位置随内容跑；
    /// 改成标准居中弹窗（遮罩 + 固定宽度 + 分区标题/内容/按钮栏）后视觉与 AppKit 的
    /// NSAlert 一致，但仍然是纯 SwiftUI 视图 —— 不参与窗口模态管理，不会被 sheet 吞掉。
    var importConfirmCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.orange)
                Text(appStore.localized(.overwriteLayoutConfirmTitle))
                    .font(.headline)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Text(appStore.localized(.overwriteLayoutConfirmMessage))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 6)

            Divider()
                .padding(.top, 16)

            VStack(alignment: .leading, spacing: 7) {
                Toggle(appStore.localized(.importScopeLayoutData), isOn: $importScope.layoutData)
                Divider()
                    .padding(.vertical, 3)
                Toggle(appStore.localized(.settingsSectionGeneral), isOn: $importScope.general)
                Toggle(appStore.localized(.settingsSectionAppearance), isOn: $importScope.appearance)
                Toggle(appStore.localized(.settingsSectionAppSources), isOn: $importScope.appSources)
                Toggle(appStore.localized(.settingsSectionHiddenApps), isOn: $importScope.hiddenApps)
                Toggle(appStore.localized(.settingsSectionTitles), isOn: $importScope.titles)
            }
            .font(.callout)
            .toggleStyle(.checkbox)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider()

            HStack(spacing: 10) {
                if let request = pendingImportRequest {
                    Text(request.displayName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer(minLength: 12)
                Button(appStore.localized(.cancel)) { cancelPendingImport() }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
                Button(appStore.localized(.backupImportButton)) { confirmPendingImport() }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 440)
        .background(importDialogBackground)
    }

    /// 导入结果弹窗：和确认弹窗同一套底板，成功/失败只换图标与按钮。
    @ViewBuilder
    var importResultCard: some View {
        if let banner = importBanner {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: banner.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(banner.isSuccess ? Color.green : Color.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(banner.title)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)

                        if let detail = banner.detail, !detail.isEmpty {
                            Text(detail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)

                Divider()

                HStack(spacing: 10) {
                    Spacer(minLength: 0)
                    Button(appStore.localized(.okButton)) { importBanner = nil }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.defaultAction)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .frame(width: 380)
            .background(importDialogBackground)
        }
    }

    /// 弹窗挂载层：全屏遮罩 + 居中卡片。
    ///
    /// 挂在 SettingsView 根视图而不是备份页 —— 另一个入口（应用与数据 → 导入）
    /// 也走这套流程，挂在内页会导致「在别的页点导入看不到弹窗」。
    var importOverlayLayer: some View {
        ZStack {
            Color.black.opacity(0.30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    if pendingImportRequest != nil {
                        cancelPendingImport()
                    } else {
                        importBanner = nil
                    }
                }

            if pendingImportRequest != nil {
                importConfirmCard
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else if importBanner != nil {
                importResultCard
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(.easeOut(duration: 0.15), value: pendingImportRequest?.id)
        .animation(.easeOut(duration: 0.15), value: importBanner != nil)
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

        // 同上：设置面板是 sheet，不能往 keyWindow 上挂 sheet。
        alert.runModal()
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
