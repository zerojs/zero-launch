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

    var appearanceBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsToggleRow(title: appStore.localized(.classicMode), isOn: $appStore.isFullscreenMode)
            SettingsToggleRow(title: appStore.localized(.showLabels), isOn: $appStore.showLabels)
            SettingsToggleRow(title: appStore.localized(.useLocalizedThirdPartyTitles), isOn: $appStore.useLocalizedThirdPartyTitles)

            // 拖拽预测与滚动翻页由 CA 网格渲染接管，开启时这两项不生效。
            SettingsToggleRow(title: appStore.localized(.predictDrop), isOn: $appStore.enableDropPrediction)
                .settingsEnabled(!appStore.useCAGridRenderer)

            SettingsToggleRow(title: appStore.localized(.enableAnimations), isOn: $appStore.enableAnimations)

            SettingsToggleRow(title: appStore.localized(.followScrollPagingTitle), isOn: $appStore.followScrollPagingEnabled)
                .settingsEnabled(!appStore.useCAGridRenderer)

            SettingsToggleRow(title: appStore.localized(.hideDockOption), isOn: $appStore.hideDock)

            // 隐藏菜单栏只对全屏模式有意义：紧凑模式是一个普通窗口，菜单栏本来就不归它管。
            SettingsToggleRow(title: appStore.localized(.hideMenuBarOption), isOn: $appStore.hideMenuBar) {
                SettingsModeBadge(text: appStore.localized(.appearanceScopeFullscreenOnly))
                SettingsInfoAffordance(isPresented: $showHideMenuBarInfoPopover, width: 280) {
                    SettingsInfoBody(text: appStore.localized(.hideMenuBarInfoBody))
                }
            }
            .settingsEnabled(appStore.isFullscreenMode, dimmedOpacity: 0.45)

            SettingsToggleRow(title: appStore.localized(.rememberPageTitle), isOn: $appStore.rememberLastPage)
            SettingsToggleRow(title: appStore.localized(.hoverMagnification), isOn: $appStore.enableHoverMagnification)
            SettingsToggleRow(title: appStore.localized(.activePressEffect), isOn: $appStore.enableActivePressEffect)

            VStack(alignment: .leading, spacing: 6) {
                SettingsToggleRow(
                    title: appStore.localized(.folderPreviewHighResTitle),
                    isOn: $appStore.enableHighResFolderPreviews
                )
                SettingsHint(appStore.localized(.folderPreviewHighResHint))
            }

            SettingsToggleRow(
                title: appStore.localized(.folderQuickLaunchTitle),
                isOn: $appStore.folderQuickLaunchEnabled
            ) {
                SettingsInfoAffordance(isPresented: $showFolderQuickLaunchInfoPopover, width: 280) {
                    SettingsInfoBody(text: appStore.localized(.folderQuickLaunchHint))
                }
            }
            .settingsEnabled(appStore.useCAGridRenderer)

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
                isEnabled: appStore.enableAnimations && !appStore.useCAGridRenderer
            )

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

            SettingsSliderRow(
                title: appStore.localized(.labelFontSize),
                value: scopedIconLabelFontSizeBinding(),
                range: 9...16,
                step: 0.5,
                lowerLabel: "9pt",
                upperLabel: "16pt"
            ) {
                layoutModeScopeControl()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(appStore.localized(.iconLabelFontWeight))
                    .font(.headline)
                Picker("", selection: $appStore.iconLabelFontWeight) {
                    ForEach(AppStore.IconLabelFontWeightOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
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

            SettingsSliderRow(
                title: appStore.localized(.scrollSensitivity),
                value: $appStore.scrollSensitivity,
                range: 0.01...0.99,
                lowerLabel: appStore.localized(.low),
                upperLabel: appStore.localized(.high)
            )

            appearanceResetFooter
        }
    }

    var appearanceLayoutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(appStore.localized(.sidebarIconSizeTitle))
                    .font(.headline)
                Picker("", selection: $appStore.sidebarIconPreset) {
                    Text(appStore.localized(.sidebarIconSizeLarge)).tag(AppStore.SidebarIconPreset.large)
                    Text(appStore.localized(.sidebarIconSizeMedium)).tag(AppStore.SidebarIconPreset.medium)
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }

            SettingsSliderRow(
                title: appStore.localized(.iconSize),
                value: scopedIconScaleBinding(),
                range: 0.8...1.1,
                lowerLabel: appStore.localized(.smaller),
                upperLabel: appStore.localized(.larger)
            ) {
                layoutModeScopeControl()
            }

            // 两个步进器行以前套了一层只有单个子视图的 VStack，顺手压平。
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

            VStack(alignment: .leading, spacing: 4) {
                Text(appStore.localized(.gridSizeChangeWarning))
                Text(appStore.localized(.pageIndicatorHint))
                    .foregroundStyle(.tertiary)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 2)

            SettingsSliderRow(
                title: appStore.localized(.folderWindowWidth),
                value: $appStore.folderPopoverWidthFactor,
                range: AppStore.folderPopoverWidthRange,
                lowerLabel: String(format: "%.0f%%", AppStore.folderPopoverWidthRange.lowerBound * 100),
                upperLabel: String(format: "%.0f%%", AppStore.folderPopoverWidthRange.upperBound * 100),
                isEnabled: !appStore.isFullscreenMode,
                badgeText: appStore.localized(.appearanceScopeCompactOnly)
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
                upperLabel: String(format: "%.0f%%", AppStore.folderPopoverHeightRange.upperBound * 100),
                isEnabled: !appStore.isFullscreenMode,
                badgeText: appStore.localized(.appearanceScopeCompactOnly)
            ) {
                Text(String(format: "%.0f%%", appStore.folderPopoverHeightFactor * 100))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            SettingsHint(appStore.localized(.folderWindowSizeHint))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(String(format: appStore.localized(.folderDropZoneSizeWithDefault), AppStore.defaultFolderDropZoneScale))
                    Spacer()
                    layoutModeScopeControl()
                }
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

            SettingsSliderRow(
                title: appStore.localized(.pageIndicatorOffsetLabel),
                value: scopedPageIndicatorOffsetBinding(),
                range: 0...80,
                lowerLabel: "0",
                centerLabel: String(format: "%.0f", appStore.scopedPageIndicatorOffset(for: selectedAppearanceLayoutMode)),
                upperLabel: "80",
                isEnabled: !selectedScopePerDisplayEnabled
            ) {
                if !selectedScopePerDisplayEnabled {
                    layoutModeScopeControl()
                }
            }

            SettingsSliderRow(
                title: appStore.localized(.pageIndicatorTopPaddingLabel),
                value: scopedPageIndicatorTopPaddingBinding(),
                range: AppStore.pageIndicatorTopPaddingRange,
                lowerLabel: String(format: "%.0f", AppStore.pageIndicatorTopPaddingRange.lowerBound),
                centerLabel: String(format: "%.0f", appStore.scopedPageIndicatorTopPadding(for: selectedAppearanceLayoutMode)),
                upperLabel: String(format: "%.0f", AppStore.pageIndicatorTopPaddingRange.upperBound),
                isEnabled: !selectedScopePerDisplayEnabled
            ) {
                if !selectedScopePerDisplayEnabled {
                    layoutModeScopeControl()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                let perDisplayBinding = scopedPerDisplayIndicatorBinding()
                Button {
                    perDisplayBinding.wrappedValue.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Text(appStore.localized(.perDisplayIndicatorPositionTitle))
                            .font(.headline)
                        Spacer()
                        layoutModeScopeControl(width: 116)
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

            folderLayoutModeCard

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
