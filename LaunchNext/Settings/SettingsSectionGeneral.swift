import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var generalSection: some View {
        // 卡片自带 12pt 内边距，间距统一 14 就够保持原来的疏密。
        // 之前是 spacing 24 再靠负 padding 往回拉（-10 / -20 / -15），
        // 只为了抵消那段常驻在卡片下方的说明文字；说明文字改成气泡后，
        // 这些魔法数字就该一起清掉，否则真实间距没人算得清。
        VStack(alignment: .leading, spacing: 14) {
            appearanceModeCard

            generalPreferencesCard

            applicationIconCard
        }
    }

    /// 通用页的偏好卡：都是「一句话说清、只要一个开关」的项。
    /// 触控角与手势在这里只放总开关，位置、延迟、手指数量等细项仍在「快捷键」页，
    /// 免得同一个开关在两个页面各有一套状态。
    var generalPreferencesCard: some View {
        // 一项一行：这些开关彼此独立，双列并排时右边那列容易被看漏，
        // 长文案（德语/俄语）也会挤成两行。顺序按常用程度排。
        VStack(alignment: .leading, spacing: 12) {
            SettingsToggleRow(title: appStore.localized(.launchAtLoginTitle), isOn: $appStore.isStartOnLogin)
                .disabled(!appStore.canConfigureStartOnLogin)

            Divider()

            SettingsToggleRow(title: appStore.localized(.gestureEnabledTitle), isOn: gestureEnabledBinding)

            Divider()

            SettingsToggleRow(title: appStore.localized(.hotCornerEnabledTitle), isOn: hotCornerEnabledBinding)

            Divider()

            SettingsToggleRow(title: appStore.localized(.showQuickRefreshButton), isOn: $appStore.showQuickRefreshButton)

            Divider()

            SettingsToggleRow(title: appStore.localized(.lockLayoutTitle), isOn: $appStore.isLayoutLocked) {
                SettingsInfoAffordance(isPresented: $showLockLayoutInfoPopover, iconFont: .body) {
                    SettingsInfoTitle(text: appStore.localized(.lockLayoutTitle))
                    SettingsInfoBody(text: appStore.localized(.lockLayoutDescription))
                }
            }

            Divider()

            SettingsToggleRow(title: appStore.localized(.developmentEnableCLICodeTitle),
                              isOn: $appStore.developmentEnableCLICode) {
                cliInfoAffordance
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
    }

    /// 命令行开关旁的 info 气泡：说明 + 示例命令 + 复制/移除入口。
    /// 单独抽出来是因为内容太长（还带一个 DisclosureGroup），
    /// 塞在卡片里会把六行开关的节奏打断，也让 diff 难以阅读。
    @ViewBuilder
    var cliInfoAffordance: some View {
        Button {
            if !showCLIInfoPopover {
                copiedCLICommand = nil
                cliCommandActionMessage = nil
                showCLIRemoveInfoPopover = false
                showCLIFullPathCommand = false
            }
            showCLIInfoPopover.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .settingsInfoPopover(isPresented: $showCLIInfoPopover, width: 360) {
            SettingsInfoTitle(text: appStore.localized(.commandLineInterfaceHelpTitle))
            SettingsInfoBody(text: appStore.localized(.commandLineInterfaceHelpBody))
            Text(appStore.localized(.commandLineInterfaceAgentHint))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            cliCommandRow("launchnext --cli help")
            cliCommandRow("launchnext --tui")
            DisclosureGroup(
                isExpanded: $showCLIFullPathCommand,
                content: {
                    cliCommandRow("/Applications/ZeroLaunch.app/Contents/MacOS/ZeroLaunch --tui")
                        .padding(.top, 4)
                },
                label: {
                    Text(appStore.localized(.commandLineInterfaceShowFullPathCommand))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            )
            Divider()
            HStack(spacing: 8) {
                Button(role: .destructive) {
                    if appStore.developmentEnableCLICode {
                        appStore.developmentEnableCLICode = false
                        cliCommandActionMessage = appStore.localized(.commandLineInterfaceRemoveCommandDone)
                    } else {
                        let removed = appStore.removeInstalledCLICommand()
                        cliCommandActionMessage = removed
                            ? appStore.localized(.commandLineInterfaceRemoveCommandDone)
                            : appStore.localized(.commandLineInterfaceRemoveCommandMissing)
                    }
                } label: {
                    Label(appStore.localized(.commandLineInterfaceRemoveCommandButton), systemImage: "trash")
                }
                .buttonStyle(.bordered)

                SettingsInfoAffordance(
                    isPresented: $showCLIRemoveInfoPopover,
                    iconFont: .body,
                    arrowEdge: .bottom
                ) {
                    SettingsInfoTitle(text: appStore.localized(.commandLineInterfaceRemoveCommandInfoTitle))
                    SettingsInfoBody(text: appStore.localized(.commandLineInterfaceRemoveCommandInfoBody))
                }
            }
            if let cliCommandActionMessage {
                Text(cliCommandActionMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var applicationIconCard: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                SettingsInfoTitle(text: appStore.localized(.customIconTitle))
                let hint = appStore.localized(.customIconHint)
                Text(twoLineHint(hint))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .trailing, spacing: 8) {
                    Button {
                        presentAppIconPicker()
                    } label: {
                        Label(appStore.localized(.customIconChoose), systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        showResetIconConfirm = true
                    } label: {
                        Label(appStore.localized(.customIconReset), systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(!appStore.hasCustomAppIcon)
                }

                Image(nsImage: appStore.currentAppIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 66, height: 66)
                    .cornerRadius(12)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .alert(appStore.localized(.resetIconConfirmTitle), isPresented: $showResetIconConfirm) {
            Button(appStore.localized(.customIconReset), role: .destructive) {
                appStore.resetCustomAppIcon()
            }
            Button(appStore.localized(.cancel), role: .cancel) {}
        }
    }

    @ViewBuilder
    func cliCommandRow(_ command: String) -> some View {
        HStack(spacing: 8) {
            Text(command)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .lineLimit(2)
                .truncationMode(.middle)
                .textSelection(.enabled)
            Spacer(minLength: 6)
            Button {
                copyCLICommand(command)
            } label: {
                Image(systemName: copiedCLICommand == command ? "checkmark.circle.fill" : "doc.on.doc")
                    .foregroundStyle(copiedCLICommand == command ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .help(appStore.localized(.backupCleanupCopyButton))
        }
    }

    func copyCLICommand(_ command: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        copiedCLICommand = command
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedCLICommand == command {
                copiedCLICommand = nil
            }
        }
    }

    func twoLineHint(_ text: String) -> String {
        let separators = [". ", "。", "！", "？", "；", ";", "，", ",", "、"]
        for sep in separators {
            if let range = text.range(of: sep) {
                let before = text[..<range.upperBound]
                let after = text[range.upperBound...].trimmingCharacters(in: .whitespaces)
                if after.isEmpty {
                    return String(before)
                }
                return String(before) + "\n" + after
            }
        }

        let words = text.split(separator: " ")
        if words.count >= 2 {
            let mid = words.count / 2
            let first = words[..<mid].joined(separator: " ")
            let second = words[mid...].joined(separator: " ")
            return first + "\n" + second
        }

        return text
    }

}
