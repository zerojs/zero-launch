import AppKit
import QuartzCore

extension CAGridView {
    // MARK: - Layer Management

    /// 配置变更引起的层重建入口：批量下发期间只记一个「待重建」标记。
    func scheduleLayerRebuild() {
        guard !suppressLayerRebuild else {
            pendingLayerRebuild = true
            return
        }
        rebuildLayers()
    }

    /// 批量配置写完后调用一次，把挂起的重建合并成一次。
    func flushPendingLayerRebuild() {
        guard pendingLayerRebuild else { return }
        pendingLayerRebuild = false
        rebuildLayers()
    }

    /// 槽位身份 key：相同 key 的槽位可复用既有 CALayer。
    /// 包含显示名与文件夹成员路径，保证标签/内容变化时该槽位会被替换刷新。
    private func itemIdentityKey(_ item: LaunchpadItem) -> String {
        switch item {
        case .app(let app):
            return "a:\(app.url.path):\(app.name)"
        case .folder(let folder):
            return "f:\(folder.id):\(folder.name):\(folder.apps.map { $0.url.path }.joined(separator: "|"))"
        case .missingApp(let placeholder):
            return "m:\(placeholder.bundlePath):\(placeholder.displayName)"
        case .empty:
            // 所有空槽视觉上等价，统一身份以最大化复用
            return "e"
        }
    }

    /// items 更新的差量路径：按 (页, 槽位) 对比身份，未变化的槽位复用既有层，
    /// 变化的槽位单独替换；页数变化或首建时回退全量重建。
    /// 避免每次 items 赋值（拖拽、搜索过滤、刷新）都销毁并重建整棵 layer 树。
    func reconcileLayers(previous: [LaunchpadItem]) {
        let ipp = max(itemsPerPage, 1)
        // 列/行数一变，每页槽位数就变了，而 iconLayers 里每页的槽位数还是旧的，
        // 槽位语义对不上 —— 必须全量重建。
        // 以前这里用「新的 ipp」去算旧 items 的页数（previousPageCount），
        // 然后和新的 pageCount 比：两个数字只要碰巧相等就会走进差量路径，
        // 按新槽位索引旧层，把 A 应用的层当成 B 应用复用。
        guard !iconLayers.isEmpty,
              layersItemsPerPage == ipp,
              pageCount == iconLayers.count else {
            rebuildLayers()
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }

        var reused = Set<ObjectIdentifier>()
        var newPageLayers: [[CALayer]] = []
        newPageLayers.reserveCapacity(pageCount)
        var anyReplaced = false
        var idx = 0

        pageLoop: for pageIndex in 0..<pageCount {
            var pageLayers: [CALayer] = []
            pageLayers.reserveCapacity(ipp)
            for slot in 0..<ipp {
                // 只跳出内层。这里以前是 `break pageLoop`，会连带跳过下面那行
                // newPageLayers.append —— 整页的层虽然还挂在 pageContainerLayer 上，
                // 却不再被 iconLayers 记录，从此再也不会被清理：它们停在旧的
                // 位置和旧的尺寸上，下次重建又在上面叠一层新层，
                // 于是出现「两套尺寸的图标同时铺满屏幕」。
                guard idx < items.count else { break }
                let item = items[idx]
                let oldIndex = pageIndex * ipp + slot
                let oldLayer = (oldIndex < previous.count && pageIndex < iconLayers.count && slot < iconLayers[pageIndex].count)
                    ? iconLayers[pageIndex][slot]
                    : nil

                if let oldLayer,
                   oldIndex < previous.count,
                   itemIdentityKey(item) == itemIdentityKey(previous[oldIndex]) {
                    reused.insert(ObjectIdentifier(oldLayer))
                    pageLayers.append(oldLayer)
                } else {
                    anyReplaced = true
                    let layer = createIconLayer(for: item, localIndex: slot, pageIndex: pageIndex)
                    pageContainerLayer.addSublayer(layer)
                    pageLayers.append(layer)
                }
                idx += 1
            }
            newPageLayers.append(pageLayers)
            if idx >= items.count { break pageLoop }
        }

        if !anyReplaced && newPageLayers.count == iconLayers.count {
            // 完全没有变化：保留原结构，不触发布局抖动
            return
        }

        // 移除所有未被复用的旧层（含被替换的和结构缩水的）
        for pageLayers in iconLayers {
            for layer in pageLayers where !reused.contains(ObjectIdentifier(layer)) {
                layer.removeFromSuperlayer()
            }
        }
        iconLayers = newPageLayers
        layersItemsPerPage = ipp

        if bounds.width > 0 && bounds.height > 0 {
            updateLayout()
        }
        navigateToPage(currentPage, animated: false)
    }

    func rebuildLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        // 清除旧层
        for pageLayers in iconLayers {
            for layer in pageLayers {
                layer.removeFromSuperlayer()
            }
        }
        iconLayers.removeAll()
        // 兜底：pageContainerLayer 上只挂图标容器层，不会有别的东西。
        // 按 iconLayers 逐层移除只能清「记录在案」的层；一旦历史上出现过
        // 层已上屏但没进 iconLayers 的情况，这里能把残留的幽灵层一并扫掉，
        // 而不是让它们在每次重建后又叠一层。
        pageContainerLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        layersItemsPerPage = max(itemsPerPage, 1)

        guard !items.isEmpty else {
            CATransaction.commit()
            // print("⚠️ [CAGrid] rebuildLayers: no items")
            return
        }

        // 为每页创建图层
        let totalPages = pageCount
        // print("🔧 [CAGrid] rebuildLayers: \(items.count) items, \(totalPages) pages, \(itemsPerPage) per page")

        for pageIndex in 0..<totalPages {
            var pageLayers: [CALayer] = []
            let startIndex = pageIndex * itemsPerPage
            let endIndex = min(startIndex + itemsPerPage, items.count)

            for i in startIndex..<endIndex {
                let localIndex = i - startIndex
                let layer = createIconLayer(for: items[i], localIndex: localIndex, pageIndex: pageIndex)
                pageContainerLayer.addSublayer(layer)
                pageLayers.append(layer)
            }

            iconLayers.append(pageLayers)
        }

        CATransaction.commit()

        // Update layout if bounds are ready, otherwise layout() will handle it later
        if bounds.width > 0 && bounds.height > 0 {
            updateLayout()
        }

        // Navigate to current page (will be handled by layout() if bounds not ready)
        navigateToPage(currentPage, animated: false)
        logIfMismatch("rebuildLayers")
    }
    
    // Track if layout needs refresh after bounds become valid

    func createIconLayer(for item: LaunchpadItem, localIndex: Int, pageIndex: Int) -> CALayer {
        _ = localIndex
        _ = pageIndex
        let containerLayer = CALayer()
        containerLayer.masksToBounds = false
        containerLayer.drawsAsynchronously = true

        // For folders, add a glass background layer
        if case .folder = item {
            let glassLayer = CALayer()
            glassLayer.name = "glass"
            let glassStyle = currentFolderGlassStyle()
            glassLayer.backgroundColor = glassStyle.background.cgColor
            glassLayer.borderColor = glassStyle.border.cgColor
            glassLayer.borderWidth = 0.5
            glassLayer.masksToBounds = false
            // Subtle shadow
            glassLayer.shadowColor = NSColor.black.cgColor
            glassLayer.shadowOffset = glassStyle.shadowOffset
            glassLayer.shadowRadius = glassStyle.shadowRadius
            glassLayer.shadowOpacity = glassStyle.shadowOpacity
            containerLayer.addSublayer(glassLayer)
        }

        // Icon layer
        let iconLayer = CALayer()
        iconLayer.name = "icon"
        iconLayer.contentsGravity = .resizeAspect
        iconLayer.contentsScale = iconBackingScale
        iconLayer.masksToBounds = false
        iconLayer.shouldRasterize = true
        iconLayer.rasterizationScale = iconBackingScale
        iconLayer.drawsAsynchronously = true
        iconLayer.shadowOpacity = 0

        containerLayer.addSublayer(iconLayer)

        // 文字标签层 - 匹配原 SwiftUI 样式
        let textLayer = CATextLayer()
        textLayer.name = "label"
        textLayer.contentsScale = iconBackingScale
        textLayer.fontSize = labelFontSize
        textLayer.font = NSFont.systemFont(ofSize: labelFontSize, weight: labelFontWeight)
        textLayer.isHidden = !showLabels
        textLayer.alignmentMode = .center
        textLayer.truncationMode = .end
        textLayer.isWrapped = false

        // 性能优化：栅格化文字层
        textLayer.shouldRasterize = true
        textLayer.rasterizationScale = iconBackingScale

        // Match system label color for light/dark
        textLayer.foregroundColor = currentLabelColor().cgColor
        textLayer.shadowOpacity = 0

        // 设置文字内容
        switch item {
        case .app(let app):
            textLayer.string = app.name
        case .folder(let folder):
            textLayer.string = folder.name
        case .missingApp(let placeholder):
            textLayer.string = placeholder.displayName
        case .empty:
            textLayer.string = ""
        }

        containerLayer.addSublayer(textLayer)

        // 设置图标
        setIcon(for: iconLayer, item: item)

        if case .app = item {
            // 长按卸载模式的删除徽标(左上角「×」),默认隐藏
            let badgeLayer = CALayer()
            badgeLayer.name = "uninstallBadge"
            badgeLayer.isHidden = true
            badgeLayer.zPosition = 30
            badgeLayer.contentsScale = iconBackingScale
            badgeLayer.backgroundColor = NSColor(white: 0.93, alpha: 0.98).cgColor
            badgeLayer.borderColor = NSColor.black.withAlphaComponent(0.12).cgColor
            badgeLayer.borderWidth = 0.5
            badgeLayer.shadowColor = NSColor.black.cgColor
            badgeLayer.shadowOpacity = 0.28
            badgeLayer.shadowRadius = 2
            badgeLayer.shadowOffset = CGSize(width: 0, height: -1)

            let badgeMark = CAShapeLayer()
            badgeMark.name = "uninstallBadgeMark"
            badgeMark.fillColor = NSColor.clear.cgColor
            badgeMark.strokeColor = NSColor(white: 0.28, alpha: 1).cgColor
            badgeMark.lineCap = .round
            badgeMark.contentsScale = iconBackingScale
            badgeLayer.addSublayer(badgeMark)
            containerLayer.addSublayer(badgeLayer)
        }

        return containerLayer
    }

    func setIcon(for layer: CALayer, item: LaunchpadItem) {
        switch item {
        case .app(let app):
            let path = app.url.path
            layer.setValue(path, forKey: "iconPath")
            if let cgImage = getCachedIcon(for: app.url.path) {
                layer.contents = cgImage
            } else {
                // 异步加载 - 直接从系统获取图标
                DispatchQueue.global(qos: .userInitiated).async { [weak self, weak layer] in
                    guard let self = self, let layer = layer else { return }
                    guard layer.value(forKey: "iconPath") as? String == path else { return }
                    // 使用 IconStore 获取图标（CA 模式走 Next Engine 逻辑）
                    let icon = IconStore.shared.icon(forPath: path)
                    if let cgImage = self.loadIcon(for: path, icon: icon) {
                        DispatchQueue.main.async {
                            guard layer.value(forKey: "iconPath") as? String == path else { return }
                            CATransaction.begin()
                            CATransaction.setDisableActions(true)
                            layer.contents = cgImage
                            CATransaction.commit()
                        }
                    }
                }
            }
        case .folder(let folder):
            // 异步加载文件夹图标
            let folderIconSize = iconSize
            let previewScale = folderPreviewScale
            DispatchQueue.global(qos: .userInitiated).async { [weak layer] in
                let icon = folder.icon(of: folderIconSize, scale: previewScale)
                if let cgImage = icon.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                    DispatchQueue.main.async {
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        layer?.contents = cgImage
                        CATransaction.commit()
                    }
                }
            }
        case .missingApp(let placeholder):
            if let cgImage = placeholder.icon.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                layer.contents = cgImage
            }
        case .empty:
            layer.contents = nil
        }
    }

    func getCachedIcon(for path: String) -> CGImage? {
        iconCacheLock.lock()
        defer { iconCacheLock.unlock() }
        return iconCache[iconCacheKey(for: path)]
    }

    func loadIcon(for path: String, icon: NSImage) -> CGImage? {
        let cacheKey = iconCacheKey(for: path)
        iconCacheLock.lock()
        if let cached = iconCache[cacheKey] {
            iconCacheLock.unlock()
            return cached
        }
        iconCacheLock.unlock()

        // 渲染为 CGImage（按窗口真实后备缩放，避免固定 2x 在高分屏发糊、1x 屏浪费内存）
        let scale = iconBackingScale
        let size = NSSize(width: iconSize * scale, height: iconSize * scale)
        let image = NSImage(size: size)
        image.lockFocus()
        icon.draw(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        iconCacheLock.lock()
        if iconCache.count >= Self.iconCacheCountLimit {
            iconCache.removeAll()
        }
        iconCache[cacheKey] = cgImage
        iconCacheLock.unlock()

        return cgImage
    }

    func preloadIcons() {
        guard enableIconPreload else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for item in self.items {
                if case .app(let app) = item {
                    let icon = IconStore.shared.icon(forPath: app.url.path)
                    _ = self.loadIcon(for: app.url.path, icon: icon)
                }
            }
            // print("✅ [CAGrid] Icons preloaded")
        }
    }

    // MARK: - Layout

    func updateLayout() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let pageWidth = bounds.width
        let pageHeight = bounds.height
        let pageStride = pageWidth + pageSpacing

        let availableWidth = max(0, pageWidth - contentInsets.left - contentInsets.right)
        let availableHeight = max(0, pageHeight - contentInsets.top - contentInsets.bottom)

        let totalColumnSpacing = columnSpacing * CGFloat(max(columns - 1, 0))
        let totalRowSpacing = rowSpacing * CGFloat(max(rows - 1, 0))
        let usableWidth = max(0, availableWidth - totalColumnSpacing)
        let usableHeight = max(0, availableHeight - totalRowSpacing)
        let cellWidth = usableWidth / CGFloat(max(columns, 1))
        let cellHeight = usableHeight / CGFloat(max(rows, 1))
        let strideX = cellWidth + columnSpacing

        let actualIconSize = iconSize
        let labelHeight: CGFloat = showLabels ? (labelFontSize + 8) : 0
        let labelTopSpacing: CGFloat = showLabels ? 6 : 0

        for (pageIndex, pageLayers) in iconLayers.enumerated() {
            for (localIndex, containerLayer) in pageLayers.enumerated() {
                let col = localIndex % columns
                let row = localIndex / columns

                let cellOriginX = contentInsets.left + CGFloat(col) * strideX
                let cellOriginY = pageHeight - contentInsets.top - CGFloat(row + 1) * cellHeight - CGFloat(row) * rowSpacing

                let totalHeight = actualIconSize + labelTopSpacing + labelHeight
                let containerX = CGFloat(pageIndex) * pageStride + cellOriginX
                let containerY = cellOriginY + (cellHeight - totalHeight) / 2

                containerLayer.frame = CGRect(x: containerX, y: containerY, width: cellWidth, height: totalHeight)

                if let iconLayer = containerLayer.sublayers?.first(where: { $0.name == "icon" }) {
                    let iconX = (cellWidth - actualIconSize) / 2
                    let iconY = labelHeight + labelTopSpacing
                    let iconFrame = CGRect(x: iconX, y: iconY, width: actualIconSize, height: actualIconSize)
                    iconLayer.frame = iconFrame
                }
                
                // Update glass background for folders
                if let glassLayer = containerLayer.sublayers?.first(where: { $0.name == "glass" }) {
                    let glassSize = actualIconSize * 0.8
                    let glassX = (cellWidth - glassSize) / 2
                    let glassY = labelHeight + labelTopSpacing + (actualIconSize - glassSize) / 2
                    glassLayer.frame = CGRect(x: glassX, y: glassY, width: glassSize, height: glassSize)
                    glassLayer.cornerRadius = glassSize * 0.25  // Larger corner radius
                }

                if let textLayer = containerLayer.sublayers?.first(where: { $0.name == "label" }) as? CATextLayer {
                    let labelWidth = cellWidth - 8
                    textLayer.isHidden = !showLabels
                    textLayer.frame = CGRect(x: 4, y: 0, width: labelWidth, height: labelHeight)
                }

                // 长按卸载徽标:贴在图标左上角,略微外溢(masksToBounds=false,不会被裁)
                if let badgeLayer = containerLayer.sublayers?.first(where: { $0.name == "uninstallBadge" }),
                   let iconLayer = containerLayer.sublayers?.first(where: { $0.name == "icon" }) {
                    let badgeFrame = uninstallBadgeFrame(iconFrame: iconLayer.frame)
                    badgeLayer.frame = badgeFrame
                    badgeLayer.cornerRadius = badgeFrame.width / 2
                    if let markLayer = badgeLayer.sublayers?.first(where: { $0.name == "uninstallBadgeMark" }) as? CAShapeLayer {
                        markLayer.frame = badgeLayer.bounds
                        markLayer.lineWidth = max(1.6, badgeFrame.width * 0.11)
                        markLayer.path = uninstallBadgeMarkPath(in: badgeLayer.bounds)
                    }
                }
            }
        }

        let totalWidth = pageWidth * CGFloat(max(1, pageCount)) + pageSpacing * CGFloat(max(pageCount - 1, 0))
        // Avoid setting frame on a transformed layer; reset to identity, update frame, then re-apply translation.
        // This prevents visual/data misalignment caused by frame updates under non-identity transforms.
        pageContainerLayer.transform = CATransform3DIdentity
        pageContainerLayer.frame = CGRect(x: 0, y: 0, width: totalWidth, height: bounds.height)
        pageContainerLayer.transform = CATransform3DMakeTranslation(scrollOffset, 0, 0)

        CATransaction.commit()

        logIfMismatch("updateLayout")
        // print("📐 [CAGrid] Layout: \(columns)x\(rows), iconSize=\(actualIconSize), cell=\(cellWidth)x\(cellHeight)")
    }

    /// 删除徽标上的「×」
    func uninstallBadgeMarkPath(in bounds: CGRect) -> CGPath {
        let path = CGMutablePath()
        let inset = bounds.width * 0.30
        path.move(to: CGPoint(x: bounds.minX + inset, y: bounds.minY + inset))
        path.addLine(to: CGPoint(x: bounds.maxX - inset, y: bounds.maxY - inset))
        path.move(to: CGPoint(x: bounds.minX + inset, y: bounds.maxY - inset))
        path.addLine(to: CGPoint(x: bounds.maxX - inset, y: bounds.minY + inset))
        return path
    }

    override func viewWillDraw() {
        super.viewWillDraw()
        // 确保视图是第一响应者和滚轮监听器已安装
        if window != nil {
            makeFirstResponderIfAvailable()
            // 确保滚轮监听器存在
            if scrollEventMonitor == nil {
                setupScrollEventMonitor()
            }
        }
    }

    override func layout() {
        super.layout()

        guard bounds.width > 0, bounds.height > 0 else { return }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerLayer.frame = bounds
        CATransaction.commit()

        // Force layout update, especially important when bounds become valid after items were set
        updateLayout()
        needsLayoutRefresh = false

        // Clamp currentPage to valid range after items/pageCount might have changed
        let validPage = max(0, min(pageCount - 1, currentPage))
        if validPage != currentPage {
            currentPage = validPage
        }

        // Reposition to current page without animation
        let pageStride = bounds.width + pageSpacing
        scrollOffset = -CGFloat(currentPage) * pageStride
        targetScrollOffset = scrollOffset
        isScrollAnimating = false

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pageContainerLayer.transform = CATransform3DMakeTranslation(scrollOffset, 0, 0)
        CATransaction.commit()
        logIfMismatch("layout")
    }

}
