import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var selectedAppearanceLayoutMode: AppStore.AppearanceLayoutMode {
        layoutModePreviewScope.appStoreMode
    }

    var selectedScopePerDisplayEnabled: Bool {
        appStore.scopedPageIndicatorPerDisplayEnabled(for: selectedAppearanceLayoutMode)
    }

    func syncLayoutModePreviewScopeToRuntime() {
        let target: LayoutModePreviewScope = appStore.isFullscreenMode ? .fullscreen : .compact
        guard layoutModePreviewScope != target else { return }
        layoutModePreviewScope = target
    }

    func scopedIconScaleBinding() -> Binding<Double> {
        Binding(
            get: { appStore.scopedIconScale(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedIconScale($0, for: selectedAppearanceLayoutMode) }
        )
    }

    func scopedIconLabelFontSizeBinding() -> Binding<Double> {
        Binding(
            get: { appStore.scopedIconLabelFontSize(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedIconLabelFontSize($0, for: selectedAppearanceLayoutMode) }
        )
    }

    func scopedFolderDropZoneScaleBinding() -> Binding<Double> {
        Binding(
            get: { appStore.scopedFolderDropZoneScale(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedFolderDropZoneScale($0, for: selectedAppearanceLayoutMode) }
        )
    }

    func scopedPageIndicatorOffsetBinding() -> Binding<Double> {
        Binding(
            get: { appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedPageIndicatorOffset($0, for: selectedAppearanceLayoutMode) }
        )
    }

    func scopedPageIndicatorTopPaddingBinding() -> Binding<Double> {
        Binding(
            get: { appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedPageIndicatorTopPadding($0, for: selectedAppearanceLayoutMode) }
        )
    }

    func scopedPerDisplayIndicatorBinding() -> Binding<Bool> {
        Binding(
            get: { appStore.scopedPageIndicatorPerDisplayEnabled(for: selectedAppearanceLayoutMode) },
            set: { appStore.setScopedPageIndicatorPerDisplayEnabled($0, for: selectedAppearanceLayoutMode) }
        )
    }

    var dockDragSideBinding: Binding<AppStore.DockDragSide> {
        Binding(
            get: { appStore.dockDragSide },
            set: { newValue in
                guard appStore.dockDragSide != newValue else { return }
                DispatchQueue.main.async {
                    appStore.dockDragSide = newValue
                }
            }
        )
    }

    var dockDragTriggerDistanceBinding: Binding<Double> {
        Binding(
            get: { appStore.dockDragTriggerDistance },
            set: { newValue in
                let clamped = min(max(newValue, AppStore.dockDragTriggerDistanceRange.lowerBound),
                                  AppStore.dockDragTriggerDistanceRange.upperBound)
                guard appStore.dockDragTriggerDistance != clamped else { return }
                DispatchQueue.main.async {
                    appStore.dockDragTriggerDistance = clamped
                }
            }
        )
    }

    var hotCornerPositionBinding: Binding<AppStore.HotCornerPosition> {
        Binding(
            get: { appStore.hotCornerPosition },
            set: { newValue in
                guard appStore.hotCornerPosition != newValue else { return }
                DispatchQueue.main.async {
                    appStore.hotCornerPosition = newValue
                }
            }
        )
    }

    var hotCornerTriggerDelayBinding: Binding<Double> {
        Binding(
            get: { appStore.hotCornerTriggerDelay },
            set: { newValue in
                let clamped = min(max(newValue, AppStore.hotCornerTriggerDelayRange.lowerBound),
                                  AppStore.hotCornerTriggerDelayRange.upperBound)
                guard appStore.hotCornerTriggerDelay != clamped else { return }
                DispatchQueue.main.async {
                    appStore.hotCornerTriggerDelay = clamped
                }
            }
        )
    }

    var hotCornerHitboxSizeBinding: Binding<Double> {
        Binding(
            get: { appStore.hotCornerHitboxSize },
            set: { newValue in
                let clamped = min(max(newValue, AppStore.hotCornerHitboxSizeRange.lowerBound),
                                  AppStore.hotCornerHitboxSizeRange.upperBound)
                guard appStore.hotCornerHitboxSize != clamped else { return }
                DispatchQueue.main.async {
                    appStore.hotCornerHitboxSize = clamped
                }
            }
        )
    }

    var hotCornerToggleWhenOpenBinding: Binding<Bool> {
        Binding(
            get: { appStore.hotCornerToggleWhenOpen },
            set: { newValue in
                guard appStore.hotCornerToggleWhenOpen != newValue else { return }
                DispatchQueue.main.async {
                    appStore.hotCornerToggleWhenOpen = newValue
                }
            }
        )
    }

    // Experimental gesture bindings.
    // These async wrappers keep Settings updates out of the current SwiftUI update pass.
    // If gesture support is removed later, delete these bindings together with the
    // gesture card below, the AppStore gesture fields, LaunchpadApp gesture wiring,
    // and LaunchNext/Gesture/.
    var gestureEnabledBinding: Binding<Bool> {
        Binding(
            get: { appStore.gestureEnabled },
            set: { newValue in
                guard appStore.gestureEnabled != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureEnabled = newValue
                }
            }
        )
    }

    var gestureCloseOnPinchOutBinding: Binding<Bool> {
        Binding(
            get: { appStore.gestureCloseOnPinchOut },
            set: { newValue in
                guard appStore.gestureCloseOnPinchOut != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureCloseOnPinchOut = newValue
                }
            }
        )
    }

    var gestureTapActionBinding: Binding<AppStore.GestureTapAction> {
        Binding(
            get: { appStore.gestureTapAction },
            set: { newValue in
                guard appStore.gestureTapAction != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureTapAction = newValue
                }
            }
        )
    }

    var gestureFingerCountBinding: Binding<AppStore.GestureFingerCount> {
        Binding(
            get: { appStore.gestureFingerCount },
            set: { newValue in
                guard appStore.gestureFingerCount != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureFingerCount = newValue
                }
            }
        )
    }

    var gestureDeviceSelectionModeBinding: Binding<GestureDeviceSelectionMode> {
        Binding(
            get: { appStore.gestureDeviceSelectionMode },
            set: { newValue in
                guard appStore.gestureDeviceSelectionMode != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureDeviceSelectionMode = newValue
                }
            }
        )
    }

    var gestureShowAllInputDevicesBinding: Binding<Bool> {
        Binding(
            get: { appStore.gestureShowAllInputDevices },
            set: { newValue in
                guard appStore.gestureShowAllInputDevices != newValue else { return }
                DispatchQueue.main.async {
                    appStore.gestureShowAllInputDevices = newValue
                }
            }
        )
    }

    // MARK: - 图标文字颜色(hex <-> SwiftUI.Color)

    func iconLabelColorHexValue(from color: Color) -> String {
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .white
        return String(format: "#%02X%02X%02X",
                      Int(round(ns.redComponent * 255)),
                      Int(round(ns.greenComponent * 255)),
                      Int(round(ns.blueComponent * 255)))
    }

    func iconLabelColorFromHex(_ hex: String) -> Color {
        LaunchNextParseHexColor(hex).map { Color(nsColor: $0) } ?? .white
    }

    func layoutModeScopeControl(width: CGFloat = 130) -> some View {
        let outerShape = Capsule(style: .continuous)

        return HStack(spacing: 3) {
            ForEach(LayoutModePreviewScope.allCases) { scope in
                Button {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        layoutModePreviewScope = scope
                    }
                } label: {
                    Text(appStore.localized(scope.localizationKey))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(layoutModePreviewScope == scope ? Color.primary : Color.secondary.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, minHeight: 18)
                        .background {
                            if layoutModePreviewScope == scope {
                                Capsule(style: .continuous)
                                    .fill(
                                        colorScheme == .dark
                                        ? Color.white.opacity(0.12)
                                        : Color.white.opacity(0.34)
                                    )
                                    .liquidGlass(in: Capsule(style: .continuous))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.30), lineWidth: 0.5)
                                    )
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
        }
        .padding(2)
        .frame(width: width, height: 24)
        .background {
            outerShape
                .fill(Color.white.opacity(colorScheme == .dark ? 0.03 : 0.10))
                .liquidGlass(in: outerShape)
        }
        .overlay {
            outerShape
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.16), lineWidth: 0.6)
        }
    }

    /// 侧栏分组：把 14 个入口按「日常 / 应用与数据 / 系统」收拢。
    /// 偏好设置、数据编辑器、运维工具职责不同，平铺在同一层会让用户找不到北。
    @ViewBuilder
    var appearanceModeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text(appStore.localized(.appearanceModeTitle))
                    .font(.headline)
                    .frame(minWidth: 90, alignment: .leading)

                Spacer(minLength: 8)

                HStack(spacing: 16) {
                    appearanceOptionCard(
                        title: appStore.localized(.appearanceModeFollowSystem),
                        imageName: "AppearanceAuto",
                        mode: .system
                    )
                    appearanceOptionCard(
                        title: appStore.localized(.appearanceModeLight),
                        imageName: "AppearanceLight",
                        mode: .light
                    )
                    appearanceOptionCard(
                        title: appStore.localized(.appearanceModeDark),
                        imageName: "AppearanceDark",
                        mode: .dark
                    )
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Divider()

            languageRow
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }

    func appearanceOptionCard(title: String, imageName: String, mode: AppearancePreference) -> some View {
        let isSelected = appStore.appearancePreference == mode
        return Button {
            appStore.appearancePreference = mode
        } label: {
            VStack(spacing: 2) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(minWidth: 52, alignment: .leading)
            // 预览图与文字之间的间隙、文字右侧的空白原本点不到，铺满命中区域。
            .settingsHitArea()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var languageRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(appStore.localized(.languagePickerTitle))
                .font(.headline)
                .frame(minWidth: 90, alignment: .leading)
            Spacer()
            Picker("", selection: $appStore.preferredLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    Text(appStore.localizedLanguageName(for: language)).tag(language)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: 180, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 显示模式选择卡：全屏 / 窗口。
    /// 之前是一行「经典 Launchpad（全屏）」开关——绑定的是 isFullscreenMode，开关形态
    /// 让人以为开着是"经典"、关着是别的什么；双选卡片 + 缩略图把两个模式直接画出来。
    @ViewBuilder
    var displayModeCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(appStore.localized(.displayModeTitle))
                .font(.headline)
                .frame(minWidth: 90, alignment: .leading)

            Spacer(minLength: 8)

            HStack(spacing: 16) {
                displayModeOption(
                    title: appStore.localized(.displayModeFullscreen),
                    isFullscreen: true,
                    preview: { displayModePreviewFullscreen }
                )
                displayModeOption(
                    title: appStore.localized(.displayModeWindow),
                    isFullscreen: false,
                    preview: { displayModePreviewWindow }
                )
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    func displayModeOption(title: String, isFullscreen: Bool, @ViewBuilder preview: () -> some View) -> some View {
        let isSelected = appStore.isFullscreenMode == isFullscreen
        return Button {
            // isFullscreenMode 的 didSet 会同步调 updateWindowMode，切换即时生效（与原开关一致）。
            withAnimation(.easeInOut(duration: 0.15)) {
                appStore.isFullscreenMode = isFullscreen
            }
        } label: {
            VStack(spacing: 2) {
                preview()
                    .frame(width: 60, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            // 预览图与文字之间的间隙原本点不到，铺满命中区域。
            .settingsHitArea()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 全屏模式缩略图：壁纸底 + 满铺图标点阵（示意，不含真实图标）。
    var displayModePreviewFullscreen: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.22, green: 0.42, blue: 0.74), Color(red: 0.36, green: 0.56, blue: 0.86)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            displayModeDotGrid(rows: 3, columns: 5, dotSize: 5, spacing: 4)
                .foregroundStyle(Color.white.opacity(0.85))
        }
    }

    /// 窗口模式缩略图：浅色底 + 居中的小窗口，点阵只在小窗口里。
    var displayModePreviewWindow: some View {
        ZStack {
            Color(nsColor: .quaternarySystemFill)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.18), radius: 1, y: 0.5)
                .frame(width: 46, height: 30)
                .overlay {
                    displayModeDotGrid(rows: 2, columns: 5, dotSize: 3.5, spacing: 3)
                        .foregroundStyle(Color.secondary.opacity(0.75))
                }
        }
    }

    func displayModeDotGrid(rows: Int, columns: Int, dotSize: CGFloat, spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: dotSize * 0.3)
                            .frame(width: dotSize, height: dotSize)
                    }
                }
            }
        }
    }

    /// 作用域切换器：本 tab 内所有「全屏/窗口各存一套值」的设置都跟随它编辑哪一套。
    /// 状态共享（layoutModePreviewScope），tab 顶部放一个，替代以前散在 6 行里的重复控件。
    var appearanceScopeHeader: some View {
        HStack {
            Text(appStore.localized(.layoutScopeHeaderTitle))
                .font(.headline)
            Spacer()
            layoutModeScopeControl(width: 150)
        }
    }

    var appearanceWindowSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 功能相关联的设置用 SettingsGroupBox 框在一起：开关和它的联动滑杆/说明
            // 不再隔着十几行，归属一眼可辨。组内顺序 = 操作顺序（先开关后调参）。

            appearanceScopeHeader

            SettingsGroupBox(title: appStore.localized(.appearanceGroupWindow)) {
                displayModeCard
                SettingsToggleRow(title: appStore.localized(.hideDockOption), isOn: $appStore.hideDock)

                // 隐藏菜单栏只对全屏模式有意义：窗口模式是一个普通窗口，菜单栏本来就不归它管。
                // 单模式设置跟随显示模式显隐——窗口模式下整行隐藏，而不是灰着占位。
                if appStore.isFullscreenMode {
                    SettingsToggleRow(title: appStore.localized(.hideMenuBarOption), isOn: $appStore.hideMenuBar) {
                        SettingsInfoAffordance(isPresented: $showHideMenuBarInfoPopover, width: 280) {
                            SettingsInfoBody(text: appStore.localized(.hideMenuBarInfoBody))
                        }
                    }
                }
            }

            SettingsGroupBox(title: appStore.localized(.appearanceGroupAnimation)) {
                SettingsToggleRow(title: appStore.localized(.enableAnimations), isOn: $appStore.enableAnimations)
                SettingsToggleRow(title: appStore.localized(.windowOpenAnimationTitle), isOn: $appStore.enableWindowOpenAnimation)

                SettingsSliderRow(
                    title: appStore.localized(.windowAnimationDurationLabel),
                    value: $appStore.windowAnimationDuration,
                    range: AppStore.windowAnimationDurationRange,
                    step: 0.05,
                    isEnabled: appStore.enableWindowOpenAnimation
                ) {
                    Text(String(format: "%.2fs", appStore.windowAnimationDuration))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                SettingsSliderRow(
                    title: appStore.localized(.animationDurationLabel),
                    value: $appStore.animationDuration,
                    range: 0.1...1.0,
                    step: 0.05,
                    lowerLabel: "0.1s",
                    centerLabel: String(format: "%.2fs", appStore.animationDuration),
                    upperLabel: "1.0s",
                    // animationDuration 只被 CA 渲染器消费（CAGridViewRepresentable /
                    // CAFolderGridViewRepresentable），传统渲染器路径不读这个值。
                    // 此前禁用条件写反（!useCAGridRenderer），导致 CA 开时滑杆被禁、
                    // CA 关时滑杆可调却毫无效果。
                    isEnabled: appStore.enableAnimations && appStore.useCAGridRenderer,
                    badgeText: appStore.localized(.caRendererBadge)
                )
            }

            SettingsGroupBox(title: appStore.localized(.appearanceGroupScrolling)) {
                // 拖拽预测与滚动翻页由 CA 网格渲染接管，开启时这两项不生效。
                // 徽标把生效条件摆在标题旁边，而不是等用户打开 CA 渲染器后发现开关点不动。
                SettingsToggleRow(title: appStore.localized(.predictDrop), isOn: $appStore.enableDropPrediction) {
                    SettingsModeBadge(text: appStore.localized(.legacyRendererBadge))
                }
                .settingsEnabled(!appStore.useCAGridRenderer)

                SettingsToggleRow(title: appStore.localized(.followScrollPagingTitle), isOn: $appStore.followScrollPagingEnabled) {
                    SettingsModeBadge(text: appStore.localized(.legacyRendererBadge))
                }
                .settingsEnabled(!appStore.useCAGridRenderer)

                VStack(alignment: .leading, spacing: 6) {
                    SettingsSliderRow(
                        title: appStore.localized(.scrollSensitivity),
                        value: $appStore.scrollSensitivity,
                        range: 0.01...0.99,
                        lowerLabel: appStore.localized(.low),
                        upperLabel: appStore.localized(.high)
                    )
                    SettingsHint(appStore.localized(.scrollSensitivityHint))
                }

                VStack(alignment: .leading, spacing: 6) {
                    SettingsToggleRow(title: appStore.localized(.rememberPageTitle), isOn: $appStore.rememberLastPage)
                    SettingsHint(appStore.localized(.rememberPageHint))
                }
            }

            SettingsGroupBox(title: appStore.localized(.appearanceGroupPageIndicator)) {
                // 页码指示器全局位置（下边距/上方间距）设置项已移除，默认贴底、紧贴网格；
                // 需要微调的场合走「按显示器独立设置」的覆盖体系。
                VStack(alignment: .leading, spacing: 8) {
                    let perDisplayBinding = scopedPerDisplayIndicatorBinding()
                    Button {
                        perDisplayBinding.wrappedValue.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Text(appStore.localized(.perDisplayIndicatorPositionTitle))
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: perDisplayBinding)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .allowsHitTesting(false)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PressFeedbackRowButtonStyle(enabled: true, pressScale: 0.98))
                    SettingsHint(appStore.localized(.perDisplayIndicatorPositionDescription))

                    if selectedScopePerDisplayEnabled {
                        HStack {
                            Button(appStore.localized(.applyDefaultsToCurrentDisplay)) {
                                if let screenID = currentIndicatorScreenID {
                                    appStore.applyIndicatorDefaults(to: screenID, mode: selectedAppearanceLayoutMode)
                                }
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(indicatorScreenEntries) { entry in
                                indicatorOverrideCard(for: entry)
                            }
                        }
                    }
                }
            }

            appearanceResetFooter
        }
    }

    var appearanceIconsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            appearanceScopeHeader

            SettingsGroupBox(title: appStore.localized(.appearanceGroupGrid)) {
                SettingsSliderRow(
                    title: appStore.localized(.iconSize),
                    value: scopedIconScaleBinding(),
                    range: 0.8...1.1,
                    lowerLabel: appStore.localized(.smaller),
                    upperLabel: appStore.localized(.larger)
                )

                SettingsStepperRow(
                    title: appStore.localized(.iconsPerRow),
                    value: $appStore.gridColumnsPerPage,
                    range: AppStore.gridColumnRange
                )

                SettingsStepperRow(
                    title: appStore.localized(.rowsPerPage),
                    value: $appStore.gridRowsPerPage,
                    range: AppStore.gridRowRange
                )

                SettingsSliderRow(
                    title: appStore.localized(.iconHorizontalSpacing),
                    value: $appStore.iconColumnSpacing,
                    range: AppStore.columnSpacingRange,
                    step: 1
                ) {
                    Text("\(Int(appStore.iconColumnSpacing)) pt")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                SettingsSliderRow(
                    title: appStore.localized(.iconVerticalSpacing),
                    value: $appStore.iconRowSpacing,
                    range: AppStore.rowSpacingRange,
                    step: 1
                ) {
                    Text("\(Int(appStore.iconRowSpacing)) pt")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text(appStore.localized(.gridSizeChangeWarning))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            SettingsGroupBox(title: appStore.localized(.appearanceGroupIconLabel)) {
                SettingsToggleRow(title: appStore.localized(.showLabels), isOn: $appStore.showLabels)

                SettingsSliderRow(
                    title: appStore.localized(.labelFontSize),
                    value: scopedIconLabelFontSizeBinding(),
                    range: 9...16,
                    step: 0.5,
                    lowerLabel: "9pt",
                    upperLabel: "16pt"
                )

                SettingsSliderRow(
                    title: appStore.localized(.iconLabelFontWeight),
                    value: Binding(
                        get: {
                            let options = AppStore.IconLabelFontWeightOption.allCases
                            return Double(options.firstIndex(of: appStore.iconLabelFontWeight) ?? 0)
                        },
                        set: { newValue in
                            let options = AppStore.IconLabelFontWeightOption.allCases
                            appStore.iconLabelFontWeight = options[Int(newValue.rounded())]
                        }
                    ),
                    range: 0...Double(AppStore.IconLabelFontWeightOption.allCases.count - 1),
                    step: 1
                ) {
                    Text("\(appStore.iconLabelFontWeight.numericWeight)")
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(appStore.localized(.iconLabelColorTitle))
                            .font(.headline)
                        Spacer()
                        Toggle(appStore.localized(.iconLabelColorFollowSystem), isOn: $iconLabelColorFollowSystem)
                            .toggleStyle(.checkbox)
                        if !iconLabelColorFollowSystem {
                            ColorPicker("", selection: $iconLabelColorSelection, supportsOpacity: false)
                                .labelsHidden()
                        }
                    }
                }
                .onAppear { syncIconLabelColorState() }
                .onChange(of: iconLabelColorFollowSystem) { _, followSystem in
                    if followSystem {
                        appStore.iconLabelColorHex = ""
                    } else {
                        appStore.iconLabelColorHex = iconLabelColorHexValue(from: iconLabelColorSelection)
                    }
                }
                .onChange(of: iconLabelColorSelection) { _, newColor in
                    guard !iconLabelColorFollowSystem else { return }
                    appStore.iconLabelColorHex = iconLabelColorHexValue(from: newColor)
                }
            }

            SettingsGroupBox(title: appStore.localized(.appearanceGroupIconInteraction)) {
                SettingsToggleRow(title: appStore.localized(.hoverMagnification), isOn: $appStore.enableHoverMagnification)
                SettingsSliderRow(
                    title: appStore.localized(.hoverMagnificationScale),
                    value: $appStore.hoverMagnificationScale,
                    range: AppStore.hoverMagnificationRange,
                    lowerLabel: String(format: "%.2fx", AppStore.hoverMagnificationRange.lowerBound),
                    centerLabel: String(format: "%.2fx", appStore.hoverMagnificationScale),
                    upperLabel: String(format: "%.2fx", AppStore.hoverMagnificationRange.upperBound),
                    isEnabled: appStore.enableHoverMagnification,
                    dimsWhenDisabled: false
                )
                SettingsToggleRow(title: appStore.localized(.activePressEffect), isOn: $appStore.enableActivePressEffect)
                SettingsSliderRow(
                    title: appStore.localized(.activePressScale),
                    value: $appStore.activePressScale,
                    range: AppStore.activePressScaleRange,
                    lowerLabel: String(format: "%.2fx", AppStore.activePressScaleRange.lowerBound),
                    centerLabel: String(format: "%.2fx", appStore.activePressScale),
                    upperLabel: String(format: "%.2fx", AppStore.activePressScaleRange.upperBound),
                    isEnabled: appStore.enableActivePressEffect,
                    dimsWhenDisabled: false
                )
            }

            appearanceResetFooter
        }
    }

    var appearanceFolderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            appearanceScopeHeader

            SettingsGroupBox(title: appStore.localized(.appearanceGroupFolder)) {
                // 高清文件夹预览只有 CA 渲染器会读取（CAGridViewRepresentable），
                // 传统渲染器路径没有对应实现——不标注的话开关在传统渲染器下是静默无效的。
                VStack(alignment: .leading, spacing: 6) {
                    SettingsToggleRow(
                        title: appStore.localized(.folderPreviewHighResTitle),
                        isOn: $appStore.enableHighResFolderPreviews
                    ) {
                        SettingsModeBadge(text: appStore.localized(.caRendererBadge))
                    }
                    SettingsHint(appStore.localized(.folderPreviewHighResHint))
                }
                .settingsEnabled(appStore.useCAGridRenderer)

                SettingsToggleRow(
                    title: appStore.localized(.folderQuickLaunchTitle),
                    isOn: $appStore.folderQuickLaunchEnabled
                ) {
                    SettingsModeBadge(text: appStore.localized(.caRendererBadge))
                    SettingsInfoAffordance(isPresented: $showFolderQuickLaunchInfoPopover, width: 280) {
                        SettingsInfoBody(text: appStore.localized(.folderQuickLaunchHint))
                    }
                }
                .settingsEnabled(appStore.useCAGridRenderer)
            }

            // 文件夹布局模式卡自带卡片外框，放在组盒外面避免双层嵌套。
            folderLayoutModeCard

            SettingsGroupBox(title: appStore.localized(.appearanceGroupFolderWindow)) {
                // 文件夹窗口宽高只有窗口模式会读：全屏模式下整组隐藏，而不是灰着占位。
                if !appStore.isFullscreenMode {
                    SettingsSliderRow(
                        title: appStore.localized(.folderWindowWidth),
                        value: $appStore.folderPopoverWidthFactor,
                        range: AppStore.folderPopoverWidthRange,
                        lowerLabel: String(format: "%.0f%%", AppStore.folderPopoverWidthRange.lowerBound * 100),
                        upperLabel: String(format: "%.0f%%", AppStore.folderPopoverWidthRange.upperBound * 100)
                    ) {
                        Text(String(format: "%.0f%%", appStore.folderPopoverWidthFactor * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    SettingsSliderRow(
                        title: appStore.localized(.folderWindowHeight),
                        value: $appStore.folderPopoverHeightFactor,
                        range: AppStore.folderPopoverHeightRange,
                        lowerLabel: String(format: "%.0f%%", AppStore.folderPopoverHeightRange.lowerBound * 100),
                        upperLabel: String(format: "%.0f%%", AppStore.folderPopoverHeightRange.upperBound * 100)
                    ) {
                        Text(String(format: "%.0f%%", appStore.folderPopoverHeightFactor * 100))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    SettingsHint(appStore.localized(.folderWindowSizeHint))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(format: appStore.localized(.folderDropZoneSizeWithDefault), AppStore.defaultFolderDropZoneScale))
                    Slider(value: scopedFolderDropZoneScaleBinding(),
                           in: AppStore.folderDropZoneScaleRange,
                           step: 0.05)
                    HStack {
                        Text(String(format: "%.1fx", AppStore.folderDropZoneScaleRange.lowerBound))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.2fx", appStore.scopedFolderDropZoneScale(for: selectedAppearanceLayoutMode)))
                            .font(.footnote.monospacedDigit())
                        Spacer()
                        Text(String(format: "%.1fx", AppStore.folderDropZoneScaleRange.upperBound))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    SettingsHint(appStore.localized(.folderDropZoneSizeHint))
                }
            }

            appearanceResetFooter
        }
    }

    var appearanceBackgroundSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsToggleRow(title: appStore.localized(.backgroundImageTitle), isOn: $appStore.backgroundImageEnabled)

            if appStore.backgroundImageEnabled {
                HStack {
                    Text(appStore.localized(.backgroundImageSourceTitle))
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(AppStore.BackgroundImageSource.allCases) { source in
                            backgroundImageSourceButton(source)
                        }
                    }
                    .onChange(of: backgroundImageSourceSelection) { _, source in
                        handleBackgroundImageSourceSelection(source)
                    }
                }

                if appStore.backgroundImageSource == .customImage {
                    HStack(spacing: 8) {
                        Image(systemName: customBackgroundImageIsReadable ? "photo" : "exclamationmark.triangle")
                            .foregroundStyle(customBackgroundImageIsReadable ? Color.secondary : Color.orange)
                        Text(customBackgroundImageDisplayName)
                            .foregroundStyle(customBackgroundImageIsReadable ? Color.secondary : Color.orange)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(appStore.localized(customBackgroundImagePathIsEmpty ? .chooseBackgroundImage : .changeBackgroundImage)) {
                            chooseCustomBackgroundImage()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            SettingsToggleRow(title: appStore.localized(.backgroundMaskTitle), isOn: $appStore.backgroundMaskEnabled)

            if appStore.backgroundMaskEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    ColorPicker(appStore.localized(.backgroundMaskLightLabel), selection: backgroundMaskColorBinding(isDark: false), supportsOpacity: true)
                    ColorPicker(appStore.localized(.backgroundMaskDarkLabel), selection: backgroundMaskColorBinding(isDark: true), supportsOpacity: true)
                }
            }

            backgroundStyleCard

            appearanceResetFooter
        }
    }

    // MARK: - Reset footer

    /// 外观三个 tab 共用同一个恢复入口：它们改的是同一套外观偏好，
    /// 而 `resetAppearanceSettings` 一直是整包重置，没必要拆成三份。
    /// 入口放在每个 tab 的底部而不是「通用」页，是因为用户是在当前页把设置调乱的。
    var appearanceResetFooter: some View {
        SettingsResetFooter(
            appStore: appStore,
            buttonTitle: appStore.localized(.resetAppearanceSettings),
            hint: appStore.localized(.settingsResetSectionHint),
            confirmMessage: appStore.localized(.resetAppearanceAlertMessage)
        ) {
            appStore.resetAppearanceSettings()
        }
    }

    // MARK: - Icon label color
    func syncIconLabelColorState() {
        let hex = appStore.iconLabelColorHex
        iconLabelColorFollowSystem = hex.isEmpty
        if !hex.isEmpty {
            iconLabelColorSelection = iconLabelColorFromHex(hex)
        }
    }
    var backgroundStyleCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                    Image(systemName: "paintpalette")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(appStore.localized(.backgroundStyleTitle))
                        .font(.headline)
                    Text(appStore.localized(appStore.launchpadBackgroundStyle.localizationKey))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                backgroundStyleOption(.blur, systemImage: "drop")
                backgroundStyleOption(.glass, systemImage: "sparkles")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .quaternarySystemFill))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.28), lineWidth: 0.7)
        )
    }


    func syncBackgroundImageSourceSelection() {
        let source = appStore.backgroundImageSource
        guard backgroundImageSourceSelection != source else { return }
        backgroundImageSourceSelection = source
    }


    func backgroundImageSourceButton(_ source: AppStore.BackgroundImageSource) -> some View {
        let isSelected = backgroundImageSourceSelection == source
        let isHovered = hoveredBackgroundImageSource == source
        let symbolName = source == .desktopWallpaper ? "desktopcomputer" : "photo"
        let shape = RoundedRectangle(cornerRadius: 9, style: .continuous)

        return Button {
            guard backgroundImageSourceSelection != source else { return }
            backgroundImageSourceSelection = source
        } label: {
            HStack(spacing: 7) {
                Image(systemName: symbolName)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 16)
                Text(appStore.localized(source.localizationKey))
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .frame(width: 136, height: 32)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .background {
            shape.fill(
                isSelected
                    ? Color.accentColor.opacity(colorScheme == .dark ? 0.22 : 0.13)
                    : Color.primary.opacity(isHovered ? 0.075 : 0.035)
            )
        }
        .overlay {
            shape.strokeBorder(
                isSelected
                    ? Color.accentColor.opacity(0.48)
                    : Color.primary.opacity(isHovered ? 0.13 : 0.07),
                lineWidth: 0.8
            )
        }
        .onHover { hovering in
            if hovering {
                hoveredBackgroundImageSource = source
            } else if hoveredBackgroundImageSource == source {
                hoveredBackgroundImageSource = nil
            }
        }
        .animation(.easeOut(duration: 0.12), value: isSelected)
        .animation(.easeOut(duration: 0.12), value: isHovered)
        .accessibilityLabel(appStore.localized(source.localizationKey))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }


    func handleBackgroundImageSourceSelection(_ source: AppStore.BackgroundImageSource) {
        guard source != appStore.backgroundImageSource else { return }

        DispatchQueue.main.async {
            guard backgroundImageSourceSelection == source else { return }

            if source == .customImage && customBackgroundImagePathIsEmpty {
                if !chooseCustomBackgroundImage() {
                    syncBackgroundImageSourceSelection()
                }
            } else {
                appStore.backgroundImageSource = source
            }
        }
    }


    var customBackgroundImagePathIsEmpty: Bool {
        appStore.customBackgroundImagePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }


    var customBackgroundImageIsReadable: Bool {
        guard !customBackgroundImagePathIsEmpty else { return false }
        return FileManager.default.isReadableFile(atPath: appStore.customBackgroundImagePath)
    }


    var customBackgroundImageDisplayName: String {
        guard !customBackgroundImagePathIsEmpty else {
            return appStore.localized(.backgroundImageUnavailable)
        }
        guard customBackgroundImageIsReadable else {
            return appStore.localized(.backgroundImageUnavailable)
        }
        return URL(fileURLWithPath: appStore.customBackgroundImagePath).lastPathComponent
    }


    @discardableResult
    func chooseCustomBackgroundImage() -> Bool {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.resolvesAliases = true
        panel.allowedContentTypes = [.image]
        panel.prompt = appStore.localized(.chooseBackgroundImage)

        guard panel.runModal() == .OK, let url = panel.url else { return false }
        appStore.customBackgroundImagePath = url.standardizedFileURL.path
        appStore.backgroundImageSource = .customImage
        backgroundImageSourceSelection = .customImage
        return true
    }


    func backgroundStyleOption(_ style: AppStore.BackgroundStyle, systemImage: String) -> some View {
        let selected = appStore.launchpadBackgroundStyle == style

        return Button {
            appStore.launchpadBackgroundStyle = style
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                Text(appStore.localized(style.localizationKey))
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundStyle(selected ? Color.accentColor : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(selected ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor).opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(selected ? Color.accentColor.opacity(0.42) : Color(nsColor: .separatorColor).opacity(0.22), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }


    var folderLayoutModeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(appStore.localized(.folderLayoutTitle))
                        .font(.headline)
                    Text(appStore.localized(.folderLayoutDescription))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                folderLayoutModeOption(.paged, systemImage: "rectangle.grid.2x2")
                folderLayoutModeOption(.vertical, systemImage: "arrow.up.and.down")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .quaternarySystemFill))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.28), lineWidth: 0.7)
        )
    }


    func folderLayoutModeOption(_ mode: AppStore.FolderLayoutMode, systemImage: String) -> some View {
        let selected = appStore.folderLayoutMode == mode

        return Button {
            appStore.folderLayoutMode = mode
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                Text(appStore.localized(mode.localizationKey))
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .foregroundStyle(selected ? Color.accentColor : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(selected ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor).opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(selected ? Color.accentColor.opacity(0.42) : Color(nsColor: .separatorColor).opacity(0.22), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }

}
