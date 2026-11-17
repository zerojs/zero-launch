import AppKit
import SwiftUI
import LaunchNextContextMenuCore

// MARK: - SwiftUI Wrapper

struct CAGridViewRepresentable: NSViewRepresentable {
    @ObservedObject var appStore: AppStore
    var items: [LaunchpadItem]  // 支持传入过滤后的 items
    var iconSize: CGFloat
    var columnSpacing: CGFloat
    var rowSpacing: CGFloat
    var contentInsets: NSEdgeInsets
    var pageSpacing: CGFloat

    /// 实际生效的内边距:左右各让出一条 edgeGutterWidth,
    /// 供拖到边缘时的翻页提示条占用,避免提示条压住最后一列图标。
    private var effectiveContentInsets: NSEdgeInsets {
        var insets = contentInsets
        insets.left += CAGridView.edgeGutterWidth
        insets.right += CAGridView.edgeGutterWidth
        return insets
    }
    var onOpenApp: ((AppInfo) -> Void)?
    var onOpenFolder: ((FolderInfo, CGPoint?) -> Void)?
    var externalDragSourceIndex: Int?
    var externalDragHoverIndex: Int?
    var selectedIndex: Int?

    // 监听这些触发器来强制刷新
    var gridRefreshTrigger: UUID { appStore.gridRefreshTrigger }
    var folderUpdateTrigger: UUID { appStore.folderUpdateTrigger }
    var iconCacheRefreshTrigger: UUID { appStore.iconCacheRefreshTrigger }

    func makeNSView(context: Context) -> CAGridView {
        let view = CAGridView(frame: .zero)

        // Initialize configuration
        view.columns = appStore.gridColumnsPerPage
        view.rows = appStore.gridRowsPerPage
        view.iconSize = iconSize
        view.columnSpacing = columnSpacing
        view.rowSpacing = rowSpacing
        view.contentInsets = effectiveContentInsets
        view.pageSpacing = pageSpacing
        view.labelFontSize = CGFloat(appStore.iconLabelFontSize)
        view.labelFontWeight = nsFontWeight(for: appStore.iconLabelFontWeight)
        view.labelColorHex = appStore.iconLabelColorHex.isEmpty ? nil : appStore.iconLabelColorHex
        view.showLabels = appStore.showLabels
        view.isLayoutLocked = appStore.isLayoutLocked
        view.folderDropZoneScale = CGFloat(appStore.folderDropZoneScale)
        let preferredScale = nsViewScale(for: view)
        view.folderPreviewScale = appStore.enableHighResFolderPreviews ? preferredScale : 1
        view.enableIconPreload = false
        view.scrollSensitivity = appStore.scrollSensitivity
        view.reverseWheelPagingDirection = appStore.reverseWheelPagingDirection
        view.trackpadVerticalDirection = appStore.trackpadVerticalDirection
        view.hoverMagnificationEnabled = appStore.enableHoverMagnification
        view.hoverMagnificationScale = CGFloat(appStore.hoverMagnificationScale)
        view.activePressEffectEnabled = appStore.enableActivePressEffect
        view.activePressScale = CGFloat(appStore.activePressScale)
        view.animationsEnabled = appStore.enableAnimations
        view.animationDuration = appStore.animationDuration
        view.dockDragEnabled = appStore.dockDragEnabled
        view.dockDragSide = appStore.dockDragSide
        view.externalAppDragTriggerDistance = CGFloat(appStore.dockDragTriggerDistance)
        view.contextMenuConfiguration = makeContextMenuConfiguration()
        
        // Set current page BEFORE items to ensure correct initial position
        view.setInitialPage(appStore.currentPage)
        view.items = items

        let launchApp: (AppInfo) -> Void = { app in
            onOpenApp?(app)
            AppDelegate.shared?.hideWindow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if !NSWorkspace.shared.open(app.url) {
                    NSSound.beep()
                }
            }
        }

        view.onItemClicked = { item, index in
            // 单击打开应用或文件夹
            switch item {
            case .app(let app):
                launchApp(app)
            case .folder(let folder):
                // 带出图标中心点(窗口坐标),供文件夹展开动画作为缩放锚点
                var centerInWindow: CGPoint?
                if let center = view.iconCenter(for: index) {
                    centerInWindow = view.convert(center, to: nil)
                }
                onOpenFolder?(folder, centerInWindow)
            case .missingApp:
                // 丢失的应用，不处理
                break
            case .empty:
                // 空白位置，不做任何操作（和真实Launchpad一致）
                // 只有点击网格外的空白区域才关闭窗口
                break
            }
        }
        view.onItemDoubleClicked = { item, index in
            // 双击也处理（兼容）
        }

        view.onPageChanged = { page in
            DispatchQueue.main.async {
                if appStore.currentPage != page {
                    appStore.currentPage = page
                }
            }
        }

        view.onFPSUpdate = { fps in
            // 可以在这里更新 FPS 显示
        }

        view.onEmptyAreaClicked = {
            // 点击空白区域关闭窗口
            AppDelegate.shared?.hideWindow()
        }

        view.onContextMenuAction = { route in
            DispatchQueue.main.async {
                performAppContextMenuRoute(
                    route,
                    appStore: appStore,
                    launchApp: launchApp
                )
            }
        }

        // 拖拽创建文件夹
        view.onCreateFolder = { dragApp, targetApp, insertAt in
            DispatchQueue.main.async {
                _ = appStore.createFolder(with: [dragApp, targetApp], insertAt: insertAt)
            }
        }

        // 拖拽移入文件夹
        view.onMoveToFolder = { app, folder in
            DispatchQueue.main.async {
                appStore.addAppToFolder(app, folder: folder)
            }
        }

        // 拖拽悬停文件夹 2 秒自动展开:记录被拖拽的应用与落点屏幕坐标,
        // 由文件夹视图出现后消费,接力继续拖拽(松手在文件夹内则插入到对应位置)。
        view.onDwellOpenFolder = { app, folder, centerInWindow in
            DispatchQueue.main.async {
                appStore.incomingFolderDragApp = app
                appStore.incomingFolderDragFolderID = folder.id
                appStore.incomingFolderDragScreenLocation = NSEvent.mouseLocation
                onOpenFolder?(folder, centerInWindow)
            }
        }

        // Drag reorder
        view.onReorderItems = { fromIndex, toIndex in
            DispatchQueue.main.async {
                guard fromIndex < appStore.items.count else { return }
                let itemsPerPage = appStore.gridColumnsPerPage * appStore.gridRowsPerPage
                let sourcePage = fromIndex / itemsPerPage
                let targetPage = toIndex / itemsPerPage
                
                if sourcePage == targetPage {
                    // Same page: use simple swap logic
                    let pageStart = sourcePage * itemsPerPage
                    let pageEnd = min(pageStart + itemsPerPage, appStore.items.count)
                    var newItems = appStore.items
                    var pageSlice = Array(newItems[pageStart..<pageEnd])
                    let localFrom = fromIndex - pageStart
                    let localTo = min(toIndex - pageStart, pageSlice.count - 1)
                    
                    if localFrom != localTo && localFrom < pageSlice.count && localTo < pageSlice.count {
                        let moving = pageSlice.remove(at: localFrom)
                        pageSlice.insert(moving, at: localTo)
                        newItems.replaceSubrange(pageStart..<pageEnd, with: pageSlice)
                        appStore.items = newItems
                    }
                    appStore.triggerGridRefresh()
                    appStore.saveAllOrder()
                    
                    // Compact after same-page drag
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appStore.compactItemsWithinPages()
                    }
                } else {
                    // Cross-page: use cascade insert logic
                let item = appStore.items[fromIndex]
                appStore.moveItemAcrossPagesWithCascade(item: item, to: toIndex)
                }
            }
        }

        // 请求创建新页面（拖拽到右边缘时）
        // 由 AppStore 统一把关:一次拖拽会话最多只开一张空白页
        view.onRequestNewPage = {
            DispatchQueue.main.async {
                appStore.requestNewPageForDragAtEdge()
            }
        }

        // 拖拽会话结束(松手/取消):回收本次会话临时开出、没人用的空白页
        view.onDragSessionEnded = {
            DispatchQueue.main.async {
                appStore.finishDragSession()
            }
        }

        // 长按卸载:抖动模式的开关落在 AppStore,视图只负责同步与呈现
        view.isAppRemovable = { app in
            appStore.isAppRemovableByUser(app)
        }
        view.onEnterJiggleMode = {
            DispatchQueue.main.async {
                appStore.isUninstallJiggleMode = true
            }
        }
        view.onExitJiggleMode = {
            DispatchQueue.main.async {
                appStore.isUninstallJiggleMode = false
            }
        }
        view.onRequestUninstallApp = { [weak view] app in
            DispatchQueue.main.async {
                presentUninstallConfirmation(for: app, appStore: appStore, parentWindow: view?.window)
            }
        }
        view.isJiggleMode = appStore.isUninstallJiggleMode

        return view
    }

    func updateNSView(_ nsView: CAGridView, context: Context) {
        // print("🔄 [CAGrid #\(nsView.debugInstanceId)] updateNSView, window=\(nsView.window != nil), isVisible=\(nsView.window?.isVisible ?? false)")
        // 确保滚轮事件监听器已安装（窗口重新显示时需要）
        nsView.ensureScrollMonitorInstalled()

        // 更新配置
        let configChanged = nsView.columns != appStore.gridColumnsPerPage ||
                            nsView.rows != appStore.gridRowsPerPage ||
                            nsView.iconSize != iconSize ||
                            nsView.columnSpacing != columnSpacing ||
                            nsView.rowSpacing != rowSpacing ||
                            nsView.contentInsets.top != effectiveContentInsets.top ||
                            nsView.contentInsets.left != effectiveContentInsets.left ||
                            nsView.contentInsets.bottom != effectiveContentInsets.bottom ||
                            nsView.contentInsets.right != effectiveContentInsets.right ||
                            nsView.pageSpacing != pageSpacing ||
                            nsView.labelFontSize != CGFloat(appStore.iconLabelFontSize) ||
                            nsView.labelFontWeight != nsFontWeight(for: appStore.iconLabelFontWeight) ||
                            nsView.labelColorHex != (appStore.iconLabelColorHex.isEmpty ? nil : appStore.iconLabelColorHex) ||
                            nsView.showLabels != appStore.showLabels ||
                            nsView.isLayoutLocked != appStore.isLayoutLocked ||
                            nsView.folderDropZoneScale != CGFloat(appStore.folderDropZoneScale) ||
                            nsView.folderPreviewScale != (appStore.enableHighResFolderPreviews ? nsViewScale(for: nsView) : 1)

        if configChanged {
            nsView.columns = appStore.gridColumnsPerPage
            nsView.rows = appStore.gridRowsPerPage
            nsView.iconSize = iconSize
            nsView.columnSpacing = columnSpacing
            nsView.rowSpacing = rowSpacing
            nsView.contentInsets = effectiveContentInsets
            nsView.pageSpacing = pageSpacing
            nsView.labelFontSize = CGFloat(appStore.iconLabelFontSize)
            nsView.labelFontWeight = nsFontWeight(for: appStore.iconLabelFontWeight)
            nsView.labelColorHex = appStore.iconLabelColorHex.isEmpty ? nil : appStore.iconLabelColorHex
            nsView.showLabels = appStore.showLabels
            nsView.isLayoutLocked = appStore.isLayoutLocked
            nsView.folderDropZoneScale = CGFloat(appStore.folderDropZoneScale)
            let preferredScale = nsViewScale(for: nsView)
            nsView.folderPreviewScale = appStore.enableHighResFolderPreviews ? preferredScale : 1
        }
        nsView.enableIconPreload = false
        nsView.scrollSensitivity = appStore.scrollSensitivity
        nsView.reverseWheelPagingDirection = appStore.reverseWheelPagingDirection
        nsView.trackpadVerticalDirection = appStore.trackpadVerticalDirection
        nsView.hoverMagnificationEnabled = appStore.enableHoverMagnification
        nsView.hoverMagnificationScale = CGFloat(appStore.hoverMagnificationScale)
        nsView.activePressEffectEnabled = appStore.enableActivePressEffect
        nsView.activePressScale = CGFloat(appStore.activePressScale)
        nsView.animationsEnabled = appStore.enableAnimations
        nsView.animationDuration = appStore.animationDuration
        nsView.isScrollEnabled = appStore.openFolder == nil && !appStore.isSetting
        // 长按卸载的抖动模式状态由 AppStore 下发(视图内 didSet 负责套动画与徽标)
        nsView.isJiggleMode = appStore.isUninstallJiggleMode
        nsView.contextMenuConfiguration = makeContextMenuConfiguration()

        // 检查刷新触发器是否变化（文件夹创建/修改会触发）
        let triggerChanged = context.coordinator.lastGridRefreshTrigger != gridRefreshTrigger ||
                             context.coordinator.lastFolderUpdateTrigger != folderUpdateTrigger

        if context.coordinator.lastIconCacheRefreshTrigger != iconCacheRefreshTrigger {
            context.coordinator.lastIconCacheRefreshTrigger = iconCacheRefreshTrigger
            nsView.clearIconCache()
            nsView.items = items
        }

        var didUpdateItems = false
        if triggerChanged {
            context.coordinator.lastGridRefreshTrigger = gridRefreshTrigger
            context.coordinator.lastFolderUpdateTrigger = folderUpdateTrigger
            // print("🔄 [CAGrid] Trigger changed, forcing refresh")
            nsView.items = items
            didUpdateItems = true
        } else if itemsChanged(nsView.items, items) {
            // 更新 items - 始终检查完整变化（包括文件夹名称等）
            // print("🔄 [CAGrid] Updating items: \(nsView.items.count) -> \(items.count)")
            nsView.items = items
            didUpdateItems = true
        }

        let maxPageIndex = max(nsView.pageCount - 1, 0)
        if appStore.currentPage > maxPageIndex {
            nsView.navigateToPage(maxPageIndex, animated: false)
            DispatchQueue.main.async {
                if appStore.currentPage > maxPageIndex {
                    appStore.currentPage = maxPageIndex
                }
            }
        }

        // 同步页面
        if nsView.currentPage != appStore.currentPage {
            // print("📄 [CAGrid] Page sync: \(nsView.currentPage) -> \(appStore.currentPage)")
            nsView.navigateToPage(appStore.currentPage, animated: appStore.enableAnimations)
        }

        if didUpdateItems {
            nsView.forceSyncPageTransformIfNeeded()
        } else {
            nsView.snapToCurrentPageIfNeeded()
        }

        let safeSelectedIndex: Int? = {
            guard let selectedIndex else { return nil }
            return items.indices.contains(selectedIndex) ? selectedIndex : nil
        }()
        nsView.dockDragEnabled = appStore.dockDragEnabled
        nsView.dockDragSide = appStore.dockDragSide
        nsView.externalAppDragTriggerDistance = CGFloat(appStore.dockDragTriggerDistance)
        nsView.updateSelection(safeSelectedIndex, animated: true)
        nsView.updateExternalDragState(sourceIndex: externalDragSourceIndex,
                                       hoverIndex: externalDragHoverIndex)
        nsView.logIfMismatch("updateNSView", appPage: appStore.currentPage)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func makeContextMenuConfiguration() -> AppContextMenuConfiguration {
        let store = appStore
        return AppContextMenuConfiguration(
            localize: { [weak store] key in store?.localized(key.localizationKey) ?? key.localizationKey.rawValue },
            showQuarantineRemovalAction: appStore.showQuarantineRemovalAction,
            canUseConfiguredUninstallTool: appStore.uninstallToolAppURL != nil,
            folderQuickLaunchEnabled: appStore.folderQuickLaunchEnabled,
            orderedFolderQuickLaunchApps: { [weak store] folder in
                store?.orderedFolderQuickLaunchApps(in: folder) ?? folder.apps
            },
            isFolderQuickLaunchAppPinned: { [weak store] folder, app in
                store?.isFolderQuickLaunchAppPinned(app, inFolderID: folder.id) ?? false
            }
        )
    }

    private func nsFontWeight(for option: AppStore.IconLabelFontWeightOption) -> NSFont.Weight {
        switch option {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }

    private func nsViewScale(for view: NSView) -> CGFloat {
        if let scale = view.window?.backingScaleFactor {
            return scale
        }
        return NSScreen.main?.backingScaleFactor ?? 1
    }

    class Coordinator {
        var lastGridRefreshTrigger: UUID = UUID()
        var lastFolderUpdateTrigger: UUID = UUID()
        var lastIconCacheRefreshTrigger: UUID = UUID()
    }

    // 检查 items 是否变化（完整比较所有 item 的 id 和名称）
    private func itemsChanged(_ old: [LaunchpadItem], _ new: [LaunchpadItem]) -> Bool {
        guard old.count == new.count else { return true }
        guard !old.isEmpty else { return !new.isEmpty }

        // 完整比较每个 item
        for i in 0..<old.count {
            let oldItem = old[i]
            let newItem = new[i]

            // 比较 id
            if oldItem.id != newItem.id { return true }

            // 比较名称（文件夹改名后需要刷新）
            if oldItem.name != newItem.name { return true }

            // 对于文件夹，还要比较内部应用数量
            if case .folder(let oldFolder) = oldItem, case .folder(let newFolder) = newItem {
                if oldFolder.apps.count != newFolder.apps.count { return true }
            }
        }

        return false
    }
}

// MARK: - Preview

#if DEBUG
struct CAGridViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        CAGridViewRepresentable(appStore: AppStore(),
                                items: [],
                                iconSize: 72,
                                columnSpacing: 20,
                                rowSpacing: 14,
                                contentInsets: NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                pageSpacing: 80,
                                externalDragSourceIndex: nil,
                                externalDragHoverIndex: nil)
            .frame(width: 1200, height: 800)
    }
}
#endif
