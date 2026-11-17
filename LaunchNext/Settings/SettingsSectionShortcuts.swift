import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    func startShortcutCapture(for target: ShortcutTarget) {
        stopShortcutCapture(cancel: false)
        pendingShortcut = nil
        capturingShortcutTarget = target
        if target == .launchpad {
            // Temporarily disable active hotkey while user is recording a new one.
            AppDelegate.shared?.updateGlobalHotKey(configuration: nil)
        }
        shortcutCaptureMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            handleShortcutCapture(event: event)
        }
    }

    func stopShortcutCapture(cancel: Bool) {
        let hadCaptureTarget = capturingShortcutTarget
        if let monitor = shortcutCaptureMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutCaptureMonitor = nil
        }
        if cancel {
            pendingShortcut = nil
            if capturingShortcutTarget != nil { NSSound.beep() }
        }
        capturingShortcutTarget = nil
        if hadCaptureTarget == .launchpad {
            appStore.syncGlobalHotKeyRegistration()
        }
    }

    func handleShortcutCapture(event: NSEvent) -> NSEvent? {
        let normalizedFlags = event.modifierFlags.normalizedShortcutFlags

        if event.keyCode == 53 && normalizedFlags.isEmpty {
            stopShortcutCapture(cancel: true)
            return nil
        }

        guard !normalizedFlags.isEmpty, !Self.modifierOnlyKeyCodes.contains(event.keyCode) else {
            NSSound.beep()
            return nil
        }

        pendingShortcut = AppStore.HotKeyConfiguration(keyCode: event.keyCode, modifierFlags: normalizedFlags)
        return nil
    }

    func savePendingShortcut() {
        guard let shortcut = pendingShortcut, let target = capturingShortcutTarget else { return }
        switch target {
        case .launchpad:
            appStore.setGlobalHotKey(keyCode: shortcut.keyCode, modifierFlags: shortcut.modifierFlags)
        // case .aiOverlay:
        //     appStore.setAIOverlayHotKey(keyCode: shortcut.keyCode, modifierFlags: shortcut.modifierFlags)
        }
        pendingShortcut = nil
        stopShortcutCapture(cancel: false)
    }

    func shortcutStatusText(for target: ShortcutTarget) -> String {
        if capturingShortcutTarget == target {
            if let shortcut = pendingShortcut {
                let base = shortcut.displayString
                if shortcut.modifierFlags.isEmpty {
                    return base + " • " + appStore.localized(.shortcutNoModifierWarning)
                }
                return base
            }
            return appStore.localized(.shortcutCapturePrompt)
        }
        let placeholder = appStore.localized(.shortcutNotSet)
        switch target {
        case .launchpad:
            return appStore.hotKeyDisplayText(nonePlaceholder: placeholder)
        // case .aiOverlay:
        //     return appStore.aiOverlayHotKeyDisplayText(nonePlaceholder: placeholder)
        }
    }

    func isCapturingShortcut(_ target: ShortcutTarget) -> Bool {
        capturingShortcutTarget == target
    }

    var shortcutsSection: some View {
        let isCapturing = isCapturingShortcut(.launchpad)
        let canSave = isCapturing && pendingShortcut != nil
        let canClear = isCapturing || appStore.globalHotKey != nil

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("ZeroLaunch", systemImage: "keyboard")
                            .font(.headline)
                        Text(appStore.localized(.globalShortcutDescription))
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        if isCapturing {
                            Text(appStore.localized(.shortcutCapturePrompt))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(shortcutStatusText(for: .launchpad))
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .textSelection(.enabled)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12), in: Capsule())

                        if isCapturing {
                            Text(appStore.localized(.shortcutListening))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        if isCapturing {
                            stopShortcutCapture(cancel: true)
                        } else {
                            startShortcutCapture(for: .launchpad)
                        }
                    } label: {
                        Label(isCapturing ? appStore.localized(.cancel) : appStore.localized(.shortcutSetButton),
                              systemImage: isCapturing ? "xmark.circle" : "keyboard")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(appStore.localized(.shortcutSaveButton)) {
                        savePendingShortcut()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canSave)

                    Button(appStore.localized(.shortcutClearButton), role: .destructive) {
                        if isCapturing {
                            stopShortcutCapture(cancel: false)
                            pendingShortcut = nil
                        }
                        appStore.clearGlobalHotKey()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canClear)

                    Spacer(minLength: 0)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(appStore.localized(.dockDragSectionTitle), systemImage: "dock.rectangle")
                            .font(.headline)
                        Text(appStore.localized(.dockDragSectionDescription))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 12)
                    dockDragPreview
                }

                SettingsToggleRow(title: appStore.localized(.dockDragEnabledTitle), isOn: dockDragEnabledBinding)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(appStore.localized(.dockDragSideTitle))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(appStore.localized(appStore.dockDragSide.localizationKey))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.12), in: Capsule())
                    }

                    HStack(spacing: 8) {
                        ForEach(dockDragSelectableSides) { side in
                            dockDragSideButton(for: side)
                        }
                    }
                    .disabled(!appStore.dockDragEnabled)
                    .opacity(appStore.dockDragEnabled ? 1 : 0.45)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(appStore.localized(.dockDragTriggerDistanceTitle))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(appStore.dockDragTriggerDistance)) px")
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: dockDragTriggerDistanceBinding,
                               in: AppStore.dockDragTriggerDistanceRange,
                               step: 1)
                        .disabled(!appStore.dockDragEnabled)
                        .opacity(appStore.dockDragEnabled ? 1 : 0.45)

                        HStack {
                            Text("\(Int(AppStore.dockDragTriggerDistanceRange.lowerBound))")
                            Spacer()
                            Text("\(Int(AppStore.dockDragTriggerDistanceRange.upperBound))")
                        }
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                        .opacity(appStore.dockDragEnabled ? 1 : 0.45)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(appStore.localized(.hotCornerSectionTitle), systemImage: "cursorarrow.motionlines")
                            .font(.headline)
                        Text(appStore.localized(.hotCornerSectionDescription))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 12)
                    hotCornerPreview
                }

                SettingsToggleRow(title: appStore.localized(.hotCornerEnabledTitle), isOn: hotCornerEnabledBinding)
                SettingsToggleRow(title: appStore.localized(.hotCornerToggleWhenOpenTitle), isOn: hotCornerToggleWhenOpenBinding)
                    .settingsEnabled(appStore.hotCornerEnabled, dimmedOpacity: 0.45)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(appStore.localized(.hotCornerPositionTitle))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(appStore.localized(appStore.hotCornerPosition.localizationKey))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.12), in: Capsule())
                    }

                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            hotCornerPositionButton(for: .topLeft)
                            hotCornerPositionButton(for: .topRight)
                        }
                        HStack(spacing: 8) {
                            hotCornerPositionButton(for: .bottomLeft)
                            hotCornerPositionButton(for: .bottomRight)
                        }
                    }
                    .disabled(!appStore.hotCornerEnabled)
                    .opacity(appStore.hotCornerEnabled ? 1 : 0.45)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(appStore.localized(.hotCornerTriggerDelayTitle))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int((appStore.hotCornerTriggerDelay * 1000).rounded())) ms")
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: hotCornerTriggerDelayBinding,
                               in: AppStore.hotCornerTriggerDelayRange,
                               step: 0.05)
                        .disabled(!appStore.hotCornerEnabled)
                        .opacity(appStore.hotCornerEnabled ? 1 : 0.45)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(appStore.localized(.hotCornerHitboxSizeTitle))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(appStore.hotCornerHitboxSize.rounded())) px")
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: hotCornerHitboxSizeBinding,
                               in: AppStore.hotCornerHitboxSizeRange,
                               step: 1)
                        .disabled(!appStore.hotCornerEnabled)
                        .opacity(appStore.hotCornerEnabled ? 1 : 0.45)

                        HStack {
                            Text("\(Int(AppStore.hotCornerHitboxSizeRange.lowerBound))")
                            Spacer()
                            Text("\(Int(AppStore.hotCornerHitboxSizeRange.upperBound))")
                        }
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                        .opacity(appStore.hotCornerEnabled ? 1 : 0.45)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(appStore.localized(.reverseWheelDirectionCardTitle), systemImage: "arrow.up.arrow.down")
                        .font(.headline)
                    Text(appStore.localized(.reverseWheelDirectionCardDescription))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                SettingsToggleRow(title: appStore.localized(.reverseWheelPagingTitle), isOn: $appStore.reverseWheelPagingDirection)
                SettingsToggleRow(title: appStore.localized(.reverseWheelVerticalTitle), isOn: $appStore.reverseWheelVerticalDirection)
                    .settingsEnabled(appStore.useCAGridRenderer, dimmedOpacity: 0.45)

                VStack(alignment: .leading, spacing: 10) {
                    Label(appStore.localized(.trackpadVerticalDirectionTitle), systemImage: "arrow.left.arrow.right")
                        .font(.subheadline.weight(.semibold))

                    HStack(spacing: 8) {
                        ForEach(AppStore.TrackpadVerticalDirection.allCases) { direction in
                            trackpadVerticalDirectionButton(for: direction)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label(appStore.localized(.gestureSectionTitle), systemImage: "hand.raised")
                            .font(.headline)
                        Text(appStore.localized(.gestureSectionDescription))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 12)
                    gesturePreview
                }

                SettingsToggleRow(title: appStore.localized(.gestureEnabledTitle), isOn: gestureEnabledBinding)
                SettingsToggleRow(title: appStore.localized(.gestureCloseOnPinchOutTitle), isOn: gestureCloseOnPinchOutBinding)
                    .settingsEnabled(appStore.gestureEnabled, dimmedOpacity: 0.45)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(appStore.localized(.gestureTapActionTitle))
                        Spacer()
                        Text(appStore.localized(appStore.gestureTapAction.localizationKey))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        ForEach(AppStore.GestureTapAction.allCases) { action in
                            gestureTapActionButton(for: action)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(appStore.localized(.gestureFingerCountTitle))
                        Spacer()
                        Text(appStore.localized(appStore.gestureFingerCount.localizationKey))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 8) {
                        ForEach(AppStore.GestureFingerCount.allCases) { count in
                            gestureFingerCountButton(for: count)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(appStore.localized(.gestureInputDeviceTitle))
                        .font(.headline)

                    HStack(spacing: 10) {
                        gestureDeviceModeButton(for: .automatic)
                        gestureDeviceModeButton(for: .selected)
                    }

                    if appStore.gestureDeviceSelectionMode == .selected {
                        VStack(alignment: .leading, spacing: 8) {
                            let visibleDevices = appStore.visibleGestureDevices
                            let showUnavailableMessage = appStore.availableGestureDevices.isEmpty || appStore.gestureUnavailableSelectionCount > 0

                            Toggle(appStore.localized(.gestureInputDeviceShowAllTitle), isOn: gestureShowAllInputDevicesBinding)
                                .font(.subheadline.weight(.semibold))
                                .toggleStyle(.switch)

                            if visibleDevices.isEmpty {
                                Text(appStore.localized(appStore.gestureShowAllInputDevices ? .gestureInputDeviceUnavailableDescription : .gestureInputDeviceNoRecommendedDescription))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                ForEach(visibleDevices) { device in
                                    gestureDeviceRow(for: device)
                                }
                            }

                            if appStore.gestureSelectedDeviceIDs.isEmpty {
                                Text(appStore.localized(.gestureInputDeviceManualEmpty))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if showUnavailableMessage && !appStore.availableGestureDevices.isEmpty {
                                Text(appStore.localized(.gestureInputDeviceUnavailableDescription))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(appStore.localized(.gestureSystemHintTitle))
                        .font(.footnote.weight(.semibold))
                    Text(appStore.localized(.gestureSystemHintBody))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(colorScheme == .dark ? 0.14 : 0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onAppear {
                appStore.refreshGestureDeviceInventory()
            }

            SettingsResetFooter(
                appStore: appStore,
                sectionTitle: appStore.localized(.globalShortcutTitle)
            ) {
                appStore.resetShortcutSettings()
            }
        }
    }

    var dockDragPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.28 : 0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .padding(16)
                .overlay(dockDragPreviewHighlight.padding(16))
        }
        .frame(width: 118, height: 82)
    }

    @ViewBuilder
    var dockDragPreviewHighlight: some View {
        if !appStore.dockDragEnabled {
            Image(systemName: "slash.circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.secondary)
        } else {
            switch appStore.dockDragSide {
            case .disabled:
                EmptyView()
            case .bottom:
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.accentColor.opacity(0.95))
                        .frame(width: 54, height: 6)
                        .padding(.bottom, 4)
                }
            case .left:
                HStack {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.accentColor.opacity(0.95))
                        .frame(width: 6, height: 34)
                        .padding(.leading, 4)
                    Spacer()
                }
            case .right:
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.accentColor.opacity(0.95))
                        .frame(width: 6, height: 34)
                        .padding(.trailing, 4)
                }
            }
        }
    }

    var dockDragEnabledBinding: Binding<Bool> {
        Binding(
            get: { appStore.dockDragEnabled },
            set: { newValue in
                guard appStore.dockDragEnabled != newValue else { return }
                DispatchQueue.main.async {
                    appStore.dockDragEnabled = newValue
                }
            }
        )
    }

    var hotCornerEnabledBinding: Binding<Bool> {
        Binding(
            get: { appStore.hotCornerEnabled },
            set: { newValue in
                guard appStore.hotCornerEnabled != newValue else { return }
                DispatchQueue.main.async {
                    appStore.hotCornerEnabled = newValue
                }
            }
        )
    }

    func dockDragSideButton(for side: AppStore.DockDragSide) -> some View {
        let isSelected = appStore.dockDragSide == side

        return Button {
            dockDragSideBinding.wrappedValue = side
        } label: {
            HStack(spacing: 6) {
                Image(systemName: dockDragSideSymbol(for: side))
                    .font(.caption.weight(.semibold))
                Text(appStore.localized(side.localizationKey))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func gestureTapActionButton(for action: AppStore.GestureTapAction) -> some View {
        let isSelected = appStore.gestureTapAction == action

        return Button {
            gestureTapActionBinding.wrappedValue = action
        } label: {
            HStack(spacing: 6) {
                Image(systemName: gestureTapActionSymbol(for: action))
                    .font(.caption.weight(.semibold))
                Text(appStore.localized(action.localizationKey))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func trackpadVerticalDirectionButton(for direction: AppStore.TrackpadVerticalDirection) -> some View {
        let isSelected = appStore.trackpadVerticalDirection == direction

        return Button {
            appStore.trackpadVerticalDirection = direction
        } label: {
            HStack(spacing: 6) {
                Image(systemName: direction == .natural ? "arrow.down" : "arrow.up")
                    .font(.caption.weight(.semibold))
                Text(appStore.localized(direction.localizationKey))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func gestureFingerCountButton(for count: AppStore.GestureFingerCount) -> some View {
        let isSelected = appStore.gestureFingerCount == count

        return Button {
            gestureFingerCountBinding.wrappedValue = count
        } label: {
            HStack(spacing: 6) {
                Image(systemName: count == .four ? "hand.raised" : "hand.raised.fill")
                    .font(.caption.weight(.semibold))
                Text(appStore.localized(count.localizationKey))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func gestureDeviceModeButton(for mode: GestureDeviceSelectionMode) -> some View {
        let isSelected = appStore.gestureDeviceSelectionMode == mode
        let symbolName = mode == .automatic ? "sparkles" : "list.bullet.circle"
        let title = appStore.localized(mode == .automatic ? .gestureInputDeviceModeAuto : .gestureInputDeviceModeSelected)
        let subtitle = mode == .automatic ? appStore.localized(.gestureInputDeviceAutoDescription) : gestureSelectedDeviceSummary

        return Button {
            gestureDeviceSelectionModeBinding.wrappedValue = mode
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: symbolName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    var gestureSelectedDeviceSummary: String {
        if appStore.gestureSelectedDeviceIDs.isEmpty {
            return appStore.localized(.gestureInputDeviceManualEmpty)
        }

        let selectedNames = appStore.availableGestureDevices
            .filter { appStore.gestureSelectedDeviceIDs.contains($0.id) }
            .map(\.name)

        if selectedNames.isEmpty {
            return appStore.localized(.gestureInputDeviceUnavailableDescription)
        }

        return selectedNames.prefix(2).joined(separator: ", ")
    }

    func gestureDeviceRow(for device: GestureInputDevice) -> some View {
        let isSelected = appStore.gestureSelectedDeviceIDs.contains(device.id)

        return Button {
            let updatedSelection: [String]
            if isSelected {
                updatedSelection = appStore.gestureSelectedDeviceIDs.filter { $0 != device.id }
            } else {
                updatedSelection = Array(Set(appStore.gestureSelectedDeviceIDs + [device.id])).sorted()
            }
            DispatchQueue.main.async {
                appStore.gestureSelectedDeviceIDs = updatedSelection
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(device.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(gestureDeviceMetadata(for: device))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !device.isRecommended {
                        Text(appStore.localized(.gestureInputDeviceUnverifiedWarning))
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func gestureDeviceMetadata(for device: GestureInputDevice) -> String {
        var parts = [
            appStore.localized(device.isBuiltIn ? .gestureInputDeviceBuiltInBadge : .gestureInputDeviceExternalBadge),
            appStore.localized(device.isRecommended ? .gestureInputDeviceRecommendedBadge : .gestureInputDeviceUnverifiedBadge)
        ]
        if device.familyID > 0 {
            parts.append(String(format: appStore.localized(.gestureInputDeviceFamilyIDFormat), device.familyID))
        }
        return parts.joined(separator: " • ")
    }

    func dockDragSideSymbol(for side: AppStore.DockDragSide) -> String {
        switch side {
        case .disabled: return "nosign"
        case .bottom: return "arrow.down.to.line"
        case .left: return "arrow.left.to.line"
        case .right: return "arrow.right.to.line"
        }
    }

    func gestureTapActionSymbol(for action: AppStore.GestureTapAction) -> String {
        switch action {
        case .off: return "nosign"
        case .open: return "arrow.up.forward.app"
        case .toggle: return "arrow.triangle.2.circlepath"
        }
    }

    var hotCornerPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.28 : 0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .padding(16)
                .overlay(hotCornerPreviewHighlight.padding(16))
        }
        .frame(width: 118, height: 82)
    }

    var gesturePreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.28 : 0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .padding(16)
                .overlay(gesturePreviewHighlight.padding(16))
        }
        .frame(width: 118, height: 82)
    }

    @ViewBuilder
    var gesturePreviewHighlight: some View {
        if !appStore.gestureEnabled && appStore.gestureTapAction == .off {
            Image(systemName: "slash.circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.secondary)
        } else {
            GeometryReader { proxy in
                let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                let points = [
                    CGPoint(x: center.x - 22, y: center.y - 12),
                    CGPoint(x: center.x + 22, y: center.y - 12),
                    CGPoint(x: center.x - 22, y: center.y + 12),
                    CGPoint(x: center.x + 22, y: center.y + 12)
                ]

                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(Color.accentColor.opacity(0.95))
                        .frame(width: 10, height: 10)
                        .position(point)
                }

                if appStore.gestureEnabled {
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        Path { path in
                            path.move(to: point)
                            path.addLine(to: CGPoint(
                                x: center.x + ((point.x - center.x) * 0.42),
                                y: center.y + ((point.y - center.y) * 0.42)
                            ))
                        }
                        .stroke(Color.accentColor.opacity(0.45), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    }
                }

                Circle()
                    .fill(Color.accentColor.opacity(appStore.gestureTapAction != .off ? 0.22 : 0.16))
                    .frame(width: appStore.gestureTapAction != .off ? 26 : 18, height: appStore.gestureTapAction != .off ? 26 : 18)
                    .position(center)

                if appStore.gestureTapAction != .off {
                    Circle()
                        .stroke(Color.accentColor.opacity(0.55), lineWidth: 2)
                        .frame(width: 34, height: 34)
                        .position(center)
                }
            }
        }
    }

    @ViewBuilder
    var hotCornerPreviewHighlight: some View {
        if !appStore.hotCornerEnabled {
            Image(systemName: "slash.circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.secondary)
        } else {
            GeometryReader { proxy in
                let markerSize: CGFloat = 12
                let inset: CGFloat = 4

                Circle()
                    .fill(Color.accentColor.opacity(0.95))
                    .frame(width: markerSize, height: markerSize)
                    .position(hotCornerPreviewPoint(in: proxy.size, inset: inset))
            }
        }
    }

    func hotCornerPreviewPoint(in size: CGSize, inset: CGFloat) -> CGPoint {
        switch appStore.hotCornerPosition {
        case .topLeft:
            return CGPoint(x: inset + 6, y: inset + 6)
        case .topRight:
            return CGPoint(x: size.width - inset - 6, y: inset + 6)
        case .bottomLeft:
            return CGPoint(x: inset + 6, y: size.height - inset - 6)
        case .bottomRight:
            return CGPoint(x: size.width - inset - 6, y: size.height - inset - 6)
        }
    }

    func hotCornerPositionButton(for position: AppStore.HotCornerPosition) -> some View {
        let isSelected = appStore.hotCornerPosition == position

        return Button {
            hotCornerPositionBinding.wrappedValue = position
        } label: {
            HStack(spacing: 6) {
                Image(systemName: hotCornerPositionSymbol(for: position))
                    .font(.caption.weight(.semibold))
                Text(appStore.localized(position.localizationKey))
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(colorScheme == .dark ? 0.18 : 0.12)
                                     : Color(nsColor: .windowBackgroundColor).opacity(colorScheme == .dark ? 0.25 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.65) : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func hotCornerPositionSymbol(for position: AppStore.HotCornerPosition) -> String {
        switch position {
        case .topLeft: return "arrow.up.left"
        case .topRight: return "arrow.up.right"
        case .bottomLeft: return "arrow.down.left"
        case .bottomRight: return "arrow.down.right"
        }
    }

}
