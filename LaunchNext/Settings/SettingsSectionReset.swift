import SwiftUI

/// 分区级「恢复本页默认」页脚。
///
/// 之前重置入口是散落的：外观重置挂在「通用」页、应用来源自带一个确认弹窗，
/// 用户要先离开出问题的页面才能找到对应开关。这里把入口收回它作用的那个页面，
/// 并统一成同一套长相与交互：
/// 一条分隔线 → 一句影响范围说明 → 一个红色恢复入口，点击后走确认弹窗。
///
/// 文案刻意强调「只重置本页偏好」，因为这些重置都不碰文件夹、排序与已扫描应用，
/// 与「重置布局」那种清数据的动作是两件事。
struct SettingsResetFooter: View {
    let appStore: AppStore
    /// 按钮文案，同时用作确认弹窗标题。
    let buttonTitle: String
    let hint: String
    let confirmMessage: String
    let action: () -> Void

    @State private var isConfirming = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 16)

                // 与「通用」页底部危险操作区保持同一种表现形式（纯文字 + 红色），
                // 避免同一个设置窗口里出现两种风格的重置入口。
                Button {
                    isConfirming = true
                } label: {
                    Label(buttonTitle, systemImage: "arrow.counterclockwise")
                        .foregroundStyle(Color.red)
                        // 图标与文字之间的间隙原本点不到，铺满命中区域。
                        .settingsHitArea()
                }
                .buttonStyle(.plain)
                .fixedSize()
            }
        }
        .padding(.top, 6)
        .alert(buttonTitle, isPresented: $isConfirming) {
            Button(appStore.localized(.resetConfirm), role: .destructive, action: action)
            Button(appStore.localized(.cancel), role: .cancel) {}
        } message: {
            Text(confirmMessage)
        }
    }
}

extension SettingsResetFooter {
    /// 通用版本：文案取同一套 key，只需要调用方给出页面标题。
    /// 这样新增可重置分区时不必再为确认文案单独翻译一遍。
    init(appStore: AppStore, sectionTitle: String, action: @escaping () -> Void) {
        self.init(
            appStore: appStore,
            buttonTitle: appStore.localized(.settingsResetSectionTitle),
            hint: appStore.localized(.settingsResetSectionHint),
            confirmMessage: String(
                format: appStore.localized(.settingsResetSectionConfirmFormat),
                sectionTitle
            ),
            action: action
        )
    }
}
