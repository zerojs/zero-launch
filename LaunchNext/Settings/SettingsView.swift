import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

struct SettingsView: View {
    @ObservedObject var appStore: AppStore
    @ObservedObject var controllerManager = ControllerInputManager.shared
    @Environment(\.colorScheme) var colorScheme
    enum ShortcutTarget {
        case launchpad
        // case aiOverlay
    }
    enum LayoutModePreviewScope: CaseIterable, Identifiable {
        case fullscreen
        case compact

        var id: String {
            switch self {
            case .fullscreen: return "fullscreen"
            case .compact: return "compact"
            }
        }

        var localizationKey: LocalizationKey {
            switch self {
            case .fullscreen: return .layoutModeScopeFullscreen
            case .compact: return .layoutModeScopeCompact
            }
        }

        var appStoreMode: AppStore.AppearanceLayoutMode {
            switch self {
            case .fullscreen: return .fullscreen
            case .compact: return .compact
            }
        }
    }
    @State var showResetConfirm = false
    /// 退出应用前的二次确认（入口在「关于」页）。
    @State var showQuitConfirm = false
    /// 套用 macOS 26 预设布局前的二次确认（会整体覆盖当前布局）。
    @State var showPresetLayoutConfirm = false
    /// 恢复默认应用图标前的二次确认。
    @State var showResetIconConfirm = false
    /// 「锁定布局」的说明气泡。原本这段说明是一整行 footnote 常驻在卡片下方，
    /// 占了三四行高度却只在第一次看时有用，改成悬停/点击 info 才展开。
    @State var showLockLayoutInfoPopover = false
    /// 备份页里被点了「恢复」的那一条。用可选的 BackupEntry 而不是 Bool：
    /// 行是 ForEach 生成的，每行各挂一个弹窗容易串到别行去。
    @State var pendingBackupRestore: BackupEntry? = nil
    @State var selectedEntry: SettingsEntry = .general
    /// 当前入口内选中的子页；切换入口时重置为该入口的第一个子页。
    @State var selectedSubpage: SettingsSection = .general
    @State var settingsSearchQuery: String = ""
    @State var searchHighlightIndex: Int = 0
    @State var searchKeyMonitor: Any?
    /// 点面板外空白处关闭设置的本地事件监听。
    @State var outsideClickDismissMonitor: Any?
    /// 设置面板自己的 NSWindow。用引用类型而不是 @State 存值：事件监听闭包捕获的是
    /// 安装那一刻的 View 副本，直接读 @State 会读到旧值（onAppear 时窗口可能还没就绪）。
    @State var settingsWindowBox = SettingsWindowBox()
    @FocusState var isSearchFocused: Bool
    @State var titleSearch: String = ""
    @State var hasHiddenAppEntries: Bool = false
    @State var hasNotHiddenAppEntries: Bool = false
    @State var hiddenSearch: String = ""
    @State var notHiddenSearch: String = ""
    @State var hiddenSearchDebounceID: Int = 0
    @State var notHiddenSearchDebounceID: Int = 0
    @State var hasHiddenAppEntriesSearchResult: Bool = false
    @State var hasNotHiddenAppEntriesSearchResult: Bool = false
    @State var cachedHiddenAppEntries: [AppEntry] = []
    @State var cachedNotHiddenAppEntries: [AppEntry] = []
    @State var showHiddenApps = true
    @State var showNotHiddenApps = false
    @State var hiddenVisibleLimit: Int = 10
    @State var notHiddenVisibleLimit: Int = 10
    let listPageSize = 10
    @State var editingDrafts: [String: String] = [:]
    @State var editingEntries: Set<String> = []
    @State var iconImportError: String? = nil
    @State var showAppSourcesResetDialog = false
    @State var showCleanupCommand = false
    @State var cleanupCommandCopied = false
    @State var backupRootPath: String = UserDefaults.standard.string(forKey: "backupRootDirectory") ?? ""
    @State var iconLabelColorFollowSystem = true
    @State var iconLabelColorSelection = Color.white
    @State var backupRefreshToken = UUID()
    @State var selectedBackupIDs: Set<String> = []
    @State var showPerformanceRestartPrompt = false
    @State var capturingShortcutTarget: ShortcutTarget? = nil
    @State var shortcutCaptureMonitor: Any?
    @State var pendingShortcut: AppStore.HotKeyConfiguration?
    @State var cachedAllAppEntries: [AppEntry] = []
    @State var allAppsVisibleLimit: Int = 10
    @State var allAppsSearch: String = ""
    @State var allAppsSearchDebounceID: Int = 0
    @State var hasAllAppEntries:Bool = false
    @State var hasAllAppEntriesSearchResult: Bool = false
    @State var showOnlyEditedTittleApps: Bool = true
    @State var showCLIInfoPopover = false
    @State var showCLIRemoveInfoPopover = false
    @State var showCLIFullPathCommand = false
    @State var showQuarantineRemovalInfoPopover = false
    @State var showHideMenuBarInfoPopover = false
    @State var showFolderQuickLaunchInfoPopover = false
    @State var backgroundImageSourceSelection: AppStore.BackgroundImageSource
    @State var hoveredBackgroundImageSource: AppStore.BackgroundImageSource?
    @State var copiedCLICommand: String? = nil
    @State var cliCommandActionMessage: String? = nil
    @State var layoutModePreviewScope: LayoutModePreviewScope = .fullscreen
    @State var lastUpdatesTabRefreshAt: Date? = nil
    let dockDragSelectableSides: [AppStore.DockDragSide] = [.bottom, .left, .right]

    init(appStore: AppStore) {
        self.appStore = appStore
        _backgroundImageSourceSelection = State(initialValue: appStore.backgroundImageSource)
        _hoveredBackgroundImageSource = State(initialValue: nil)
    }

    // Sidebar sizing presets
    var sidebarIconFrame: CGFloat {
        switch appStore.sidebarIconPreset {
        case .large: return 26
        case .medium: return 24
        }
    }

    var sidebarIconFontSize: CGFloat {
        switch appStore.sidebarIconPreset {
        case .large: return 13
        case .medium: return 12
        }
    }

    /// 侧栏条目使用的字号。改这里要同步 `sidebarWidthForFullLabels` 里的测量，
    /// 否则算出来的宽度会和实际排版对不上。
    static let sidebarLabelFontSize: CGFloat = 13.5
    /// 侧栏列宽的下限：中文这类短文案也要有基本留白。
    /// 230 是在最小窗口（820）下给侧栏留出的约 28%，再窄就会显得局促。
    static let sidebarMinWidth: CGFloat = 230

    /// 「完整显示当前语言的侧栏文字」所需列宽。
    ///
    /// 以前是写死的 `ideal: 205 / max: 250`。中文 6 个字只要 88pt，够用；
    /// 但英语 "Appearance & Performance" 实测 173pt、法语
    /// "Disposition / Sauvegarde des données" 要 239pt —— 叠加图标与行内边距后
    /// 已经超过 250 的硬上限，就算把分隔条拖到最宽也只能截断成「…données」。
    /// 各语言需求相差 2.7 倍，所以按当前语言实测，而不是换一个更大的固定值：
    /// 中文用户不会白白多出一条空白，切到法语/俄语时也不会再被截掉。
    var sidebarWidthForFullLabels: CGFloat {
        let font = NSFont.systemFont(ofSize: Self.sidebarLabelFontSize)
        let widestLabel = SettingsEntry.allCases.reduce(CGFloat.zero) { widest, entry in
            let width = (appStore.localized(entry.localizationKey) as NSString)
                .size(withAttributes: [.font: font]).width
            return max(widest, width)
        }
        // 图标 + HStack 间距 + List 行左右内边距，末尾 +12 是呼吸余量，
        // 避免文字正好顶到行尾、被选中胶囊压住。
        let chrome = sidebarIconFrame + 8 + 30 + 12
        return widestLabel + chrome
    }

    /// `ideal` 是初始宽度，`max` 必须不小于实测需求，否则用户拖也拖不出完整文字。
    var sidebarIdealWidth: CGFloat {
        max(sidebarWidthForFullLabels, Self.sidebarMinWidth)
    }

    var sidebarMaxWidth: CGFloat {
        max(sidebarWidthForFullLabels, 340)
    }

    var sidebarRowVerticalPadding: CGFloat {
        switch appStore.sidebarIconPreset {
        case .large: return 2
        case .medium: return 1
        }
    }

    var sidebarHeaderIconFrame: CGFloat {
        return 36
    }

    var sidebarHeaderCornerRadius: CGFloat {
        switch appStore.sidebarIconPreset {
        case .large: return 3
        case .medium: return 3
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationSplitView {
                ScrollViewReader { proxy in
                    List(selection: $selectedEntry) {
                        HStack(alignment: .center, spacing: 2) {
                            Image(nsImage: NSApplication.shared.applicationIconImage)
                                .resizable()
                                .interpolation(.high)
                                .antialiased(true)
                                .frame(width: sidebarHeaderIconFrame, height: sidebarHeaderIconFrame)
                                .cornerRadius(sidebarHeaderCornerRadius)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(appStore.localized(.appTitle))
                                    .font(.headline.weight(.semibold))
                                Text("\(appStore.localized(.versionPrefix))\(getVersion(fallback: appStore.localized(.versionFallback)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.bottom, 10)
                        .listRowInsets(EdgeInsets(top: 0, leading: -4, bottom: 15, trailing: 10))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        sidebarSearchField

                        if isSearchingSettings {
                            Section {
                                if settingsSearchHits.isEmpty {
                                    Text(appStore.localized(.settingsSearchNoResults))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                        .padding(.vertical, 6)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                } else {
                                    ForEach(Array(settingsSearchHits.enumerated()), id: \.element.id) { index, hit in
                                        searchResultRow(hit, index: index, isHighlighted: index == searchHighlightIndex)
                                            .id(hit.id)
                                    }
                                }
                            } header: {
                                Text(appStore.localized(.settingsSearchResultsHeader))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ForEach(SettingsSectionGroup.allCases) { group in
                                Section {
                                    ForEach(group.entries) { entry in
                                        sidebarRow(for: entry)
                                    }
                                } header: {
                                    Text(appStore.localized(group.localizationKey))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.sidebar)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .onChange(of: searchHighlightIndex) { _, index in
                        let hits = settingsSearchHits
                        guard hits.indices.contains(index) else { return }
                        withAnimation(.easeOut(duration: 0.12)) {
                            proxy.scrollTo(hits[index].id, anchor: .center)
                        }
                    }
                }
                // 必须挂在 sidebar 闭包的顶层视图上（ScrollViewReader），
                // 挂到里面那层 List 上会静默失效：列宽退回 NavigationSplitView
                // 的默认比例（约窗口宽度的 20%），文字照样截断，且看不出原因。
                .navigationSplitViewColumnWidth(
                    min: Self.sidebarMinWidth,
                    ideal: sidebarIdealWidth,
                    max: sidebarMaxWidth
                )
            } detail: {
                detailView(for: selectedEntry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)

            Button {
                appStore.isSetting = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .liquidGlass()
                            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.trailing, 16)

            // ⌘F 聚焦搜索框：隐藏按钮只承载快捷键
            Button("") {
                isSearchFocused = true
            }
            .keyboardShortcut("f", modifiers: .command)
            .opacity(0)
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        }
        .frame(minWidth: 820, minHeight: 640)
        .background(SettingsWindowAccessor { settingsWindowBox.window = $0 })
        .alert(appStore.localized(.customIconTitle), isPresented: Binding(get: { iconImportError != nil }, set: { if !$0 { iconImportError = nil } })) {
            Button(appStore.localized(.okButton), role: .cancel) { iconImportError = nil }
        } message: {
            Text(iconImportError ?? "")
        }
        // .onChange(of: appStore.isAIEnabled) { enabled in
        //     if !enabled && isCapturingShortcut(.aiOverlay) {
        //         stopShortcutCapture(cancel: true)
        //     }
        // }
        .onAppear {
            installOutsideClickDismiss()
        }
        .onDisappear {
            stopShortcutCapture(cancel: false)
            removeSearchKeyMonitor()
            removeOutsideClickDismiss()
        }
        .onChange(of: settingsSearchQuery) { _, _ in
            searchHighlightIndex = 0
        }
        .onChange(of: isSearchFocused) { _, focused in
            if focused {
                installSearchKeyMonitor()
            } else {
                removeSearchKeyMonitor()
            }
        }
        .onChange(of: appStore.isFullscreenMode) { _, _ in
            guard currentSubpage(for: selectedEntry) == .appearance else { return }
            syncLayoutModePreviewScopeToRuntime()
        }
        .onChange(of: selectedEntry) { _, newEntry in
            selectedSubpage = newEntry.subpages[0]
            if currentSubpage(for: newEntry) == .updates {
                refreshUpdatesIfStale()
            }
        }
        .onChange(of: selectedSubpage) { _, newSubpage in
            guard newSubpage == .updates else { return }
            refreshUpdatesIfStale()
        }
    }

    /// 进入「更新」子页时，距上次自动检查超过 5 分钟才刷新，避免来回切换反复请求。
    func refreshUpdatesIfStale() {
        guard appStore.updateState != .checking else { return }

        let now = Date()
        if let lastRefresh = lastUpdatesTabRefreshAt,
           now.timeIntervalSince(lastRefresh) < 300 {
            return
        }

        lastUpdatesTabRefreshAt = now
        appStore.checkForUpdates()
    }

    /// 侧栏单行（图标 + 名称）。选中态由所在 List 的 selection + tag 驱动。
    @ViewBuilder
    func sidebarRow(for entry: SettingsEntry) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(entry.iconGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.black.opacity(0.06))
                        .blendMode(.multiply)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.45),
                                    .white.opacity(0.08),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 0.5)
                        .blendMode(.screen)
                }
                .overlay(
                    Image(systemName: entry.iconName)
                        .font(.system(size: sidebarIconFontSize, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .frame(width: sidebarIconFrame, height: sidebarIconFrame)
                .liquidGlass()
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)

            Text(appStore.localized(entry.localizationKey))
                .font(.system(size: 13.5, weight: .regular))
        }
        .padding(.vertical, sidebarRowVerticalPadding)
        .tag(entry)
    }

    // MARK: - 搜索

    var isSearchingSettings: Bool {
        !settingsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var settingsSearchHits: [SettingsSearchHit] {
        makeSettingsSearchHits(for: settingsSearchQuery)
    }

    func moveSearchHighlight(_ delta: Int) {
        let count = settingsSearchHits.count
        guard count > 0 else { return }
        searchHighlightIndex = min(max(0, searchHighlightIndex + delta), count - 1)
    }

    /// 回车或点击结果：跳到对应子页并清空搜索。
    func activateSearchHit(at index: Int? = nil) {
        let hits = settingsSearchHits
        let target = index ?? searchHighlightIndex
        guard hits.indices.contains(target) else { return }
        let hit = hits[target]
        selectedEntry = hit.entry
        selectedSubpage = hit.subpage
        settingsSearchQuery = ""
        searchHighlightIndex = 0
        removeSearchKeyMonitor()
        isSearchFocused = false
    }

    /// TextField 会把 ↑↓ 当成光标移动，这里在搜索框聚焦时用 local monitor 接管方向键。
    func installSearchKeyMonitor() {
        guard searchKeyMonitor == nil else { return }
        searchKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard isSearchFocused, isSearchingSettings else { return event }
            switch event.keyCode {
            case 125: // ↓
                moveSearchHighlight(1)
                return nil
            case 126: // ↑
                moveSearchHighlight(-1)
                return nil
            default:
                return event
            }
        }
    }

    func removeSearchKeyMonitor() {
        guard let monitor = searchKeyMonitor else { return }
        NSEvent.removeMonitor(monitor)
        searchKeyMonitor = nil
    }

    /// 点设置面板外的空白处关闭面板。
    ///
    /// SwiftUI 的 `.sheet` 本身没有这个行为：面板外的点击会被 AppKit 直接吞掉。
    /// 这里用本地事件监听补上，判定条件是「点击落在设置面板的父窗口上」。
    ///
    /// 不用 `NSApp.windows.first { $0.attachedSheet != nil }` 反查父窗口：
    /// 打开文件选择器时，选择器会以 sheet 形式挂在**设置窗口**上，
    /// 那一瞬间「有 attachedSheet 的窗口」就变成了设置窗口自己，
    /// 会把面板内的点击误判成「点外面」并直接关掉设置。
    /// 因此改成持有设置面板自己的窗口，再取它的 `sheetParent`。
    /// 命中后返回 nil 把这次点击吃掉，否则会同时穿透到后面的启动台网格去启动应用。
    func installOutsideClickDismiss() {
        guard outsideClickDismissMonitor == nil else { return }
        outsideClickDismissMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { event in
            guard let parentWindow = settingsWindowBox.window?.sheetParent,
                  event.window === parentWindow else {
                return event
            }
            appStore.isSetting = false
            return nil
        }
    }

    func removeOutsideClickDismiss() {
        guard let monitor = outsideClickDismissMonitor else { return }
        NSEvent.removeMonitor(monitor)
        outsideClickDismissMonitor = nil
    }

    /// 侧栏搜索框。不用 `.searchable`，因为需要 ⌘F 明确聚焦与 Esc 清空。
    var sidebarSearchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(appStore.localized(.settingsSearchPrompt), text: $settingsSearchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($isSearchFocused)
                .onSubmit { activateSearchHit() }
                .onExitCommand {
                    settingsSearchQuery = ""
                    isSearchFocused = false
                }

            if !settingsSearchQuery.isEmpty {
                Button {
                    settingsSearchQuery = ""
                    isSearchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(isSearchFocused ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .padding(.horizontal, 4)
        .padding(.bottom, 10)
        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 10))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    func searchResultRow(_ hit: SettingsSearchHit, index: Int, isHighlighted: Bool) -> some View {
        Button {
            activateSearchHit(at: index)
        } label: {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(hit.entry.iconGradient)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Image(systemName: hit.entry.iconName)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(hit.entryTitle)
                        .font(.system(size: 12.5))
                    Text(hit.detailText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHighlighted ? Color.accentColor.opacity(0.16) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 6))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    func getVersion(fallback: String) -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? fallback
    }

    enum SettingsSectionGroup: CaseIterable, Identifiable {
        case daily
        case appsAndData
        case system

        var id: String {
            switch self {
            case .daily: return "daily"
            case .appsAndData: return "appsAndData"
            case .system: return "system"
            }
        }

        var localizationKey: LocalizationKey {
            switch self {
            case .daily: return .settingsGroupDaily
            // 该分组只剩「应用与数据」一个入口，标题用「应用」避免与入口同名。
            case .appsAndData: return .settingsGroupApps
            case .system: return .settingsGroupSystem
            }
        }

        var entries: [SettingsEntry] {
            switch self {
            case .daily:
                return [.general, .appearanceAndPerformance, .shortcuts, .soundAndController]
            // 「布局/数据备份」归到应用分组：它备份的就是应用列表、文件夹与排序，
            // 和「数据管理」是同一份东西的两个入口。
            case .appsAndData:
                return [.appsAndData, .backup]
            case .system:
                return [.development, .updates, .about]
            }
        }
    }

    /// 侧栏入口。一个入口可包含多个子页，子页在页面顶部用分段控件切换。
    enum SettingsEntry: String, CaseIterable, Identifiable {
        case general
        case appearanceAndPerformance
        case backup
        case shortcuts
        case soundAndController
        case appsAndData
        case development
        // 更新与关于拆成两个入口：一个是「检查更新」这种动作型页面，
        // 一个是版本信息与致谢，合在一个入口里只能靠 tab 区分，反而多一次点击。
        case updates
        case about

        var id: String { rawValue }

        var subpages: [SettingsSection] {
            switch self {
            case .general: return [.general]
            case .appearanceAndPerformance: return [.appearance, .appearanceLayout, .appearanceBackground, .performance]
            case .backup: return [.backup]
            case .shortcuts: return [.shortcuts]
            case .soundAndController: return [.sound, .gameController]
            case .appsAndData: return [.appSources, .titles, .hiddenApps, .dataManagement, .uninstall]
            case .development: return [.development]
            case .updates: return [.updates]
            case .about: return [.about]
            }
        }

        var localizationKey: LocalizationKey {
            switch self {
            case .general: return .settingsSectionGeneral
            case .appearanceAndPerformance: return .settingsEntryAppearanceAndPerformance
            case .backup: return .settingsSectionBackup
            case .shortcuts: return .globalShortcutTitle
            case .soundAndController: return .settingsEntrySoundAndController
            case .appsAndData: return .settingsGroupAppsAndData
            case .development: return .settingsSectionDevelopment
            case .updates: return .settingsSectionUpdates
            case .about: return .settingsSectionAbout
            }
        }

        /// 侧栏图标沿用首个子页的视觉，避免为一个合并入口另造一套配色。
        var iconSection: SettingsSection {
            switch self {
            case .general: return .general
            case .appearanceAndPerformance: return .appearance
            case .backup: return .backup
            case .shortcuts: return .shortcuts
            case .soundAndController: return .sound
            case .appsAndData: return .appSources
            case .development: return .development
            case .updates: return .updates
            case .about: return .about
            }
        }

        var iconName: String { iconSection.iconName }
        var iconGradient: LinearGradient { iconSection.iconGradient }
    }

    enum SettingsSection: String, CaseIterable, Identifiable {
        case general
        case appearance
        // 外观页拆成顶部 tab：显示与行为 / 布局与尺寸 / 背景与效果
        case appearanceLayout
        case appearanceBackground
        case performance
        case titles
        case appSources
        case hiddenApps
        // 数据管理（导出/导入/从系统 Launchpad 导入/预设布局）从「通用」搬到这里：
        // 它动的是布局数据本身，和「应用来源/标题/隐藏」是同一类可导出可迁移的东西。
        case dataManagement
        case uninstall
        case shortcuts
        case backup
        case development
        // case aiOverlay
        case sound
        case gameController
        case updates
        case about

        var id: String { rawValue }

        /// 每个子页的元数据：标题、侧栏图标、配色、搜索关键词。
        /// 新增子页只需在这里加一行（外加 content 分发），不必同步三张 switch。
        struct Meta {
            let title: LocalizationKey
            let iconName: String
            let gradientColors: [Color]
            let keywords: [LocalizationKey]
        }

        var meta: Meta {
            switch self {
            case .general:
                // 关键词要跟着页面实际内容走：数据管理、预设布局、重置布局都已搬去
                // 「应用与数据 / 布局数据备份」，留在这里会让搜索结果跳到一个
                // 根本没有该项的页面。
                return Meta(
                    title: .settingsSectionGeneral,
                    iconName: "gearshape",
                    gradientColors: [Color(red: 0.12, green: 0.52, blue: 0.96), Color(red: 0.22, green: 0.72, blue: 0.94)],
                    keywords: [.launchAtLoginTitle, .lockLayoutTitle, .showQuickRefreshButton, .customIconTitle,
                               .developmentEnableCLICodeTitle, .appearanceModeTitle,
                               .hotCornerEnabledTitle, .gestureEnabledTitle]
                )
            case .appearance:
                return Meta(
                    title: .appearanceGroupDisplayAndBehavior,
                    iconName: "paintbrush",
                    gradientColors: [Color(red: 0.73, green: 0.25, blue: 0.96), Color(red: 0.98, green: 0.43, blue: 0.80)],
                    keywords: [.classicMode, .showLabels, .useLocalizedThirdPartyTitles, .predictDrop,
                               .enableAnimations, .followScrollPagingTitle, .hideDockOption, .hideMenuBarOption,
                               .rememberPageTitle, .hoverMagnification, .activePressEffect, .folderPreviewHighResTitle,
                               .folderQuickLaunchTitle, .windowOpenAnimationTitle, .windowAnimationDurationLabel,
                               .animationDurationLabel, .hoverMagnificationScale, .activePressScale, .labelFontSize,
                               .iconLabelFontWeight, .iconLabelColorTitle, .scrollSensitivity,
                               .resetAppearanceSettings, .appearanceScopeFullscreenOnly]
                )
            case .appearanceLayout:
                return Meta(
                    title: .appearanceGroupLayoutAndSize,
                    iconName: "square.grid.3x3",
                    gradientColors: [Color(red: 0.73, green: 0.25, blue: 0.96), Color(red: 0.98, green: 0.43, blue: 0.80)],
                    keywords: [.sidebarIconSizeTitle, .iconSize, .iconsPerRow, .rowsPerPage, .iconHorizontalSpacing,
                               .iconVerticalSpacing, .folderWindowWidth, .folderWindowHeight, .folderDropZoneSizeWithDefault,
                               .pageIndicatorOffsetLabel, .pageIndicatorTopPaddingLabel, .perDisplayIndicatorPositionTitle,
                               .resetAppearanceSettings, .appearanceScopeCompactOnly]
                )
            case .appearanceBackground:
                return Meta(
                    title: .appearanceGroupBackgroundAndEffect,
                    iconName: "photo",
                    gradientColors: [Color(red: 0.73, green: 0.25, blue: 0.96), Color(red: 0.98, green: 0.43, blue: 0.80)],
                    keywords: [.backgroundImageTitle, .backgroundImageSourceTitle, .backgroundMaskTitle,
                               .backgroundMaskLightLabel, .backgroundMaskDarkLabel, .resetAppearanceSettings]
                )
            case .performance:
                return Meta(
                    title: .settingsSectionPerformance,
                    iconName: "speedometer",
                    gradientColors: [Color(red: 0.02, green: 0.70, blue: 0.46), Color(red: 0.31, green: 0.93, blue: 0.69)],
                    keywords: [.performanceModeTitle, .performanceRendererTitle, .performanceCacheTitle,
                               .performanceCacheClearButton]
                )
            case .titles:
                return Meta(
                    title: .settingsSectionTitles,
                    iconName: "text.badge.plus",
                    gradientColors: [Color(red: 0.95, green: 0.37, blue: 0.32), Color(red: 0.98, green: 0.55, blue: 0.44)],
                    keywords: [.customTitleAddFromFolder, .customTitleOnly, .customTitleDefaultFormat]
                )
            case .appSources:
                return Meta(
                    title: .settingsSectionAppSources,
                    iconName: "externaldrive",
                    gradientColors: [Color(nsColor: .systemGray), Color(nsColor: .lightGray)],
                    keywords: [.scanSourcesIntroTitle, .scanSourcesDefaultListTitle, .scanSourcesCustomListTitle,
                               .scanSourcesAddButton, .scanSourcesFuzzySearchTitle, .scanSourcesSearchDelayTitle]
                )
            case .hiddenApps:
                return Meta(
                    title: .settingsSectionHiddenApps,
                    iconName: "eye.slash",
                    gradientColors: [Color(red: 0.29, green: 0.39, blue: 0.96), Color(red: 0.11, green: 0.67, blue: 0.91)],
                    keywords: [.hiddenAppsAddButton, .hiddenAppsHint, .notHiddenAppsTitle]
                )
            case .dataManagement:
                return Meta(
                    title: .dataManagementTitle,
                    iconName: "arrow.up.arrow.down.circle",
                    gradientColors: [Color(red: 0.13, green: 0.66, blue: 0.62), Color(red: 0.28, green: 0.85, blue: 0.78)],
                    keywords: [.dataManagementTitle, .exportData, .importData, .importSystem,
                               .layoutPresetApplyButton, .refresh]
                )
            case .uninstall:
                return Meta(
                    title: .settingsSectionUninstall,
                    iconName: "trash",
                    gradientColors: [Color(red: 0.94, green: 0.22, blue: 0.27), Color(red: 0.78, green: 0.04, blue: 0.18)],
                    keywords: [.uninstallSectionDescription, .uninstallToolPathLabel, .uninstallToolChooseButton]
                )
            case .shortcuts:
                return Meta(
                    title: .globalShortcutTitle,
                    iconName: "keyboard",
                    gradientColors: [Color(red: 0.22, green: 0.31, blue: 0.43), Color(red: 0.33, green: 0.55, blue: 0.72)],
                    keywords: [.globalShortcutDescription, .dockDragSectionTitle, .dockDragEnabledTitle, .dockDragSideTitle,
                               .dockDragTriggerDistanceTitle, .hotCornerSectionTitle, .hotCornerEnabledTitle,
                               .hotCornerPositionTitle, .hotCornerTriggerDelayTitle, .hotCornerHitboxSizeTitle,
                               .reverseWheelDirectionCardTitle, .reverseWheelPagingTitle, .reverseWheelVerticalTitle,
                               .trackpadVerticalDirectionTitle, .gestureSectionTitle, .gestureEnabledTitle,
                               .gestureTapActionTitle, .gestureFingerCountTitle, .gestureInputDeviceTitle,
                               .settingsResetSectionTitle]
                )
            case .backup:
                return Meta(
                    title: .settingsSectionBackup,
                    iconName: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                    gradientColors: [Color(red: 0.12, green: 0.80, blue: 0.46), Color(red: 0.10, green: 0.62, blue: 0.34)],
                    keywords: [.backupPlaceholderTitle, .backupChooseFolderButton, .backupCreateButton,
                               .backupDeleteSelectedButton, .backupCleanupDisclosureTitle, .backupImportButton]
                )
            case .development:
                return Meta(
                    title: .settingsSectionDevelopment,
                    iconName: "hammer",
                    gradientColors: [Color(red: 0.98, green: 0.58, blue: 0.16), Color(red: 0.96, green: 0.20, blue: 0.24)],
                    keywords: [.developmentQuarantineRemovalTitle, .developmentForceOnboardingButton, .showFPSOverlay,
                               .importLegacy]
                )
            case .sound:
                return Meta(
                    title: .settingsSectionSound,
                    iconName: "speaker.wave.2",
                    gradientColors: [Color(red: 0.92, green: 0.12, blue: 0.12), Color(red: 0.99, green: 0.30, blue: 0.30)],
                    keywords: [.soundToggleTitle, .voiceToggleTitle, .settingsResetSectionTitle]
                )
            case .gameController:
                return Meta(
                    title: .settingsSectionGameController,
                    iconName: "gamecontroller",
                    gradientColors: [Color(red: 0.46, green: 0.34, blue: 0.97), Color(red: 0.31, green: 0.54, blue: 0.99)],
                    keywords: [.gameControllerToggleTitle, .gameControllerMenuToggleTitle, .settingsResetSectionTitle]
                )
            case .updates:
                return Meta(
                    title: .settingsSectionUpdates,
                    iconName: "arrow.down.circle",
                    gradientColors: [Color(red: 0.22, green: 0.78, blue: 0.55), Color(red: 0.10, green: 0.62, blue: 0.91)],
                    keywords: [.checkForUpdates, .autoCheckForUpdates, .openUpdaterConfig]
                )
            case .about:
                return Meta(
                    title: .settingsSectionAbout,
                    iconName: "info.circle",
                    gradientColors: [Color(red: 0.54, green: 0.55, blue: 0.70), Color(red: 0.42, green: 0.44, blue: 0.60)],
                    keywords: [.aboutProjectLink, .aboutReportBug, .aboutContribute, .aboutBlog, .aboutInfoSystemTitle]
                )
            }
        }

        var localizationKey: LocalizationKey { meta.title }
        var iconName: String { meta.iconName }
        var searchKeywords: [LocalizationKey] { meta.keywords }

        var iconGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(colors: meta.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    func detailView(for entry: SettingsEntry) -> some View {
        let section = currentSubpage(for: entry)
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 160)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(1), Color.white.opacity(0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 16) {
                    Text(appStore.localized(entry.localizationKey))
                        .font(.title3.bold())

                    if entry.subpages.count > 1 {
                        subpageTabs(for: entry)
                    }

                    ScrollView(showsIndicators: false) {
                        scrollContent(for: section)
                    }
                    // 每个子页使用独立 ScrollView 身份，切换 tab 时回到顶部而不是沿用上一页的滚动位置
                    .id(section)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollBounceBehavior(.basedOnSize)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                if section == .updates {
                    updatesFloatingBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
            }
        }
    }

    /// 合并入口当前应展示的子页；若状态与入口不匹配，回落到第一个子页。
    func currentSubpage(for entry: SettingsEntry) -> SettingsSection {
        entry.subpages.contains(selectedSubpage) ? selectedSubpage : entry.subpages[0]
    }

    /// 子页切换：胶囊 tab + 横向滚动。
    /// 用自绘 tab 而不是 segmented picker，是因为 4 段以上时德/俄等长文案会被等分宽度截断。
    @ViewBuilder
    func subpageTabs(for entry: SettingsEntry) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(entry.subpages) { subpage in
                    let isSelected = currentSubpage(for: entry) == subpage
                    Button {
                        guard !isSelected else { return }
                        selectedSubpage = subpage
                    } label: {
                        Text(appStore.localized(subpage.localizationKey))
                            .font(.callout.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(isSelected
                                          ? Color.accentColor.opacity(0.16)
                                          : Color.primary.opacity(0.06))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(isSelected ? Color.accentColor.opacity(0.45) : Color.clear, lineWidth: 1)
                            )
                            .contentShape(Capsule(style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func scrollContent(for section: SettingsSection) -> some View {
        switch section {
        case .appearance:
            appearanceBehaviorSection
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear { syncLayoutModePreviewScopeToRuntime() }
        case .appearanceLayout:
            appearanceLayoutSection
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .appearanceBackground:
            appearanceBackgroundSection
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear { syncBackgroundImageSourceSelection() }
                .onChange(of: appStore.backgroundImageSource) { _, _ in
                    syncBackgroundImageSourceSelection()
                }
        default:
            VStack(alignment: .leading, spacing: 24) {
                content(for: section)
                Spacer(minLength: 0)
            }
            .padding(.top, 12)
            .padding(.bottom, section == .updates ? 92 : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func content(for section: SettingsSection) -> some View {
        switch section {
        case .general:
            generalSection
        case .appearance:
            appearanceBehaviorSection
        case .appearanceLayout:
            appearanceLayoutSection
        case .appearanceBackground:
            appearanceBackgroundSection
        case .performance:
            performanceSection
        case .titles:
            titlesSection
        case .appSources:
            appSourcesSection
        case .hiddenApps:
            hiddenAppsSection
        case .dataManagement:
            dataManagementSection
        case .uninstall:
            uninstallSection
        case .shortcuts:
            shortcutsSection
        case .backup:
            backupSection
        case .development:
            developmentSection
        // case .aiOverlay:
        //     aiOverlaySection
        case .sound:
            soundSection
        case .gameController:
            gameControllerSection
        case .updates:
            updatesSection
        case .about:
            aboutSection
        }
    }

    @State var expandedSource: String? = nil
    
}

// MARK: - 设置面板窗口引用

/// 只用来持有设置面板自己的 NSWindow。
///
/// 用引用类型而不是 `@State` 存值，是因为 `NSEvent` 本地监听闭包捕获的是
/// 安装那一刻的 View 副本：闭包里读 `@State` 会永远是旧值
/// （`onAppear` 时窗口往往还没就绪，读到的就是 nil）。存进类实例后，
/// 闭包捕获的是同一个对象的引用，事件发生时能拿到最新窗口。
final class SettingsWindowBox {
    weak var window: NSWindow?
}

/// 把 SwiftUI 视图所在的 NSWindow 回传给调用方。
struct SettingsWindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async { onResolve(view.window) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { onResolve(nsView.window) }
    }
}
