import AppKit
import QuartzCore

// MARK: - 长按卸载(抖动模式)
//
// 交互参考 macOS Launchpad / iOS 主屏:
//   长按图标 ~0.9s → 所有图标开始轻微抖动,可被移除的 app 左上角出现「×」徽标
//   → 点击「×」弹确认框 → 确认后移到废纸篓并从网格移除
//   → 点击空白处 / Esc 退出。
//
// 与批量选择模式的差异:批量选择会把勾选框放在图标右上角并改点击语义,
// 抖动模式只增加一个左上角徽标,点击其余区域仍按普通点击处理(但不启动应用)。

extension CAGridView {

    // MARK: 徽标几何

    /// 删除徽标直径:跟随图标尺寸缩放,并夹在一个可点击的合理区间
    var uninstallBadgeDiameter: CGFloat {
        max(18, min(28, iconSize * 0.3))
    }

    /// 徽标在图层内的位置(相对 containerLayer 的 icon 区域左上角,略微外溢)
    func uninstallBadgeFrame(iconFrame: CGRect) -> CGRect {
        let diameter = uninstallBadgeDiameter
        let overflow = diameter * 0.16
        return CGRect(x: iconFrame.minX - overflow,
                      y: iconFrame.maxY - diameter * 0.84,
                      width: diameter,
                      height: diameter)
    }

    /// 徽标在视图坐标下的可点击区域(带一点扩展,便于点中)
    func uninstallBadgeHitRect(for index: Int) -> CGRect? {
        guard let center = iconCenter(for: index) else { return nil }
        let diameter = uninstallBadgeDiameter
        let overflow = diameter * 0.16
        let rect = CGRect(x: center.x - iconSize / 2 - overflow,
                          y: center.y + iconSize / 2 - diameter * 0.84,
                          width: diameter,
                          height: diameter)
        return rect.insetBy(dx: -4, dy: -4)
    }

    // MARK: 状态应用

    /// 依据 isJiggleMode 统一刷新抖动动画与徽标显隐。幂等,可重复调用。
    func applyJiggleState() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if isJiggleMode {
            clearHover()
            for (pageIndex, pageLayers) in iconLayers.enumerated() {
                let pageStart = pageIndex * itemsPerPage
                for (localIndex, containerLayer) in pageLayers.enumerated() {
                    let globalIndex = pageStart + localIndex
                    guard items.indices.contains(globalIndex) else { continue }
                    let item = items[globalIndex]

                    // 空占位与丢失项不参与抖动
                    if case .empty = item { continue }
                    if case .missingApp = item { continue }

                    addJiggleAnimation(to: containerLayer, seed: globalIndex)

                    let removable: Bool = {
                        guard case .app(let app) = item else { return false }
                        return isAppRemovable?(app) ?? false
                    }()
                    setUninstallBadgeVisible(removable, on: containerLayer)
                }
            }
        } else {
            for pageLayers in iconLayers {
                for containerLayer in pageLayers {
                    containerLayer.removeAnimation(forKey: "jiggle")
                    setUninstallBadgeVisible(false, on: containerLayer)
                }
            }
        }

        CATransaction.commit()
    }

    private func setUninstallBadgeVisible(_ visible: Bool, on containerLayer: CALayer) {
        guard let badge = containerLayer.sublayers?.first(where: { $0.name == "uninstallBadge" }) else { return }
        badge.isHidden = !visible
    }

    private func addJiggleAnimation(to containerLayer: CALayer, seed: Int) {
        guard containerLayer.animation(forKey: "jiggle") == nil else { return }
        // 幅度参考 macOS Launchpad:约 1.3 度,轻微但不至于看不出来。
        // duration 是一个完整往返(-a → +a → -a)的时长,0.3s 约等于每秒 3 次摆动,
        // 接近系统的手感;更快会显得焦躁。
        let angle: CGFloat = 0.022
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.values = [-angle, angle, -angle]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 0.3
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        // 用 seed 打散相位,让图标不是整齐划一地同频摆动
        animation.timeOffset = Double((seed * 37) % 15) / 15.0 * animation.duration
        containerLayer.add(animation, forKey: "jiggle")
    }

    // MARK: 进入 / 退出

    func enterJiggleMode() {
        guard !isJiggleMode else { return }
        onEnterJiggleMode?()
    }

    func exitJiggleMode() {
        guard isJiggleMode else { return }
        onExitJiggleMode?()
    }

    /// 长按计时器触发(按住不动达到 longPressDuration)
    func handleLongPressForUninstall(item: LaunchpadItem, index: Int) {
        guard !isJiggleMode else { return }
        guard case .app = item else { return }
        guard pressedIndex == index, !isDraggingItem else { return }
        // 批量选择与右键菜单跟踪期间不抢长按
        guard !isBatchSelectionMode, !isContextMenuTracking else { return }

        // 这里**不能**清 pressedIndex。
        // mouseDragged 是靠 "if !isDraggingItem, let idx = pressedIndex" 判断是否起拖的,
        // 一旦清掉,进入抖动后的第一次拖动就没有据以起拖的下标,
        // 表现为"第一次长按只抖动、拖不动,必须松手再按第二次"。
        // 松手误启动 app 的问题由 mouseUp 里的 isJiggleMode 分支兜住(抖动模式下不启动)。
        //
        // 先把本地状态打开再通知外部:updateNSView 回填 isJiggleMode 要等下一次
        // SwiftUI 更新,而同一轮事件里的 mouseUp / mouseDragged 需要立刻读到它。
        enterJiggleMode()
        isJiggleMode = true
    }
}

// MARK: - 卸载确认

/// 弹出与 macOS Launchpad 一致的确认框,确认后把应用移到废纸篓。
@MainActor
func presentUninstallConfirmation(for app: AppInfo, appStore: AppStore, parentWindow: NSWindow? = nil) {
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = String(format: appStore.localized(.uninstallConfirmTitle), app.name)
    alert.informativeText = appStore.localized(.uninstallConfirmMessage)
    alert.addButton(withTitle: appStore.localized(.uninstallMoveToTrash))
    alert.addButton(withTitle: appStore.localized(.uninstallCancel))
    // LaunchNext 的窗口可能是 .floating,开启"覆盖菜单栏"时层级更高。
    // NSAlert 默认 .modalPanel 会被压在下面,表现成"点了没反应",这里显式抬高一层。
    alert.window.level = uninstallAlertLevel(above: parentWindow)

    // 弹窗会让主窗口 resign key → 触发"失去焦点即隐藏"。
    // 这里显式声明"正在展示模态弹窗",让自动隐藏逻辑让位。
    let delegate = AppDelegate.shared
    delegate?.beginModalAlertPresentation()
    let response = alert.runModal()
    delegate?.endModalAlertPresentation()

    guard response == .alertFirstButtonReturn else { return }

    appStore.uninstallApp(app) { error in
        guard let error else { return }
        let failure = NSAlert()
        failure.alertStyle = .critical
        failure.messageText = String(format: appStore.localized(.uninstallFailedTitle), app.name)
        // 权限类失败时补一句可执行的引导:告诉用户下一步能做什么,
        // 而不是只丢一个系统错误串。
        // 权限类失败时,人能读的那句话无法区分是 TCC、POSIX 还是别的,
        // 所以把机器可读的 domain / code 一并带上,便于定位。
        let nsError = error as NSError
        let detail = "\(nsError.localizedDescription)（\(nsError.domain) \(nsError.code)）"
        failure.informativeText = "\(detail)\n\n" + appStore.localized(.uninstallFailedHint)
        failure.addButton(withTitle: appStore.localized(.uninstallOK))
        failure.addButton(withTitle: appStore.localized(.contextMenuShowInFinder))
        failure.window.level = uninstallAlertLevel(above: parentWindow)

        delegate?.beginModalAlertPresentation()
        let failureResponse = failure.runModal()
        delegate?.endModalAlertPresentation()

        if failureResponse == .alertSecondButtonReturn {
            NSWorkspace.shared.activateFileViewerSelecting([app.url])
        }
    }
}

private func uninstallAlertLevel(above window: NSWindow?) -> NSWindow.Level {
    let base = window?.level ?? .floating
    return NSWindow.Level(rawValue: base.rawValue + 1)
}
