import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    /// 数据管理：导出/导入整份布局数据、从系统 Launchpad 迁移、套用预设布局。
    ///
    /// 从「通用」搬过来的。这些动作动的都是布局数据本身（可导出、可迁移、可覆盖），
    /// 和「应用来源 / 应用标题 / 隐藏应用」是同一类东西，放在「通用」里既没线索也容易误触。
    var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            dataManagementCard

            SettingsHint(appStore.localized(.importTip))
                .padding(.top, -6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var dataManagementCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                SettingsInfoTitle(text: appStore.localized(.dataManagementTitle))
                Spacer()
                HStack(spacing: 10) {
                    Button { exportDataFolder() } label: {
                        Text(appStore.localized(.exportData))
                    }
                    .buttonStyle(.bordered)

                    Button { importDataFolder() } label: {
                        Text(appStore.localized(.importData))
                    }
                    .buttonStyle(.bordered)
                }
            }

            HStack(spacing: 10) {
                Button { importFromLaunchpad() } label: {
                    Label(appStore.localized(.importSystem), systemImage: "square.and.arrow.down.on.square")
                }
                .buttonStyle(.bordered)
                .help(appStore.localized(.importTip))

                // 一键把整份布局换成 macOS 26 预设：会重建分页、文件夹与排序，
                // 没有撤销，属于「点错了就回不去」的动作，先确认再执行。
                Button {
                    showPresetLayoutConfirm = true
                } label: {
                    Label(appStore.localized(.layoutPresetApplyButton), systemImage: "square.grid.3x3.topleft.filled")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .alert(appStore.localized(.overwriteLayoutConfirmTitle), isPresented: $showPresetLayoutConfirm) {
            Button(appStore.localized(.layoutPresetApplyButton), role: .destructive) {
                applyMacOS26PresetLayout()
            }
            Button(appStore.localized(.cancel), role: .cancel) {}
        } message: {
            Text(appStore.localized(.overwriteLayoutConfirmMessage))
        }
    }
}
