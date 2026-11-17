import SwiftUI

/// 设置页「说明气泡」统一组件。
///
/// 把「info.circle 触发按钮 + 气泡容器（内边距 / 固定宽度 / 对齐）」收成一处，
/// 页面侧只描述气泡里要放什么内容，避免每个页面各写一遍 padding 与 frame。
struct SettingsInfoAffordance<Content: View>: View {
    @Binding var isPresented: Bool
    let iconFont: Font
    let arrowEdge: Edge
    let width: CGFloat
    let beforeToggle: () -> Void
    let content: () -> Content

    init(
        isPresented: Binding<Bool>,
        iconFont: Font = .caption.weight(.regular),
        arrowEdge: Edge = .top,
        width: CGFloat = 390,
        beforeToggle: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.iconFont = iconFont
        self.arrowEdge = arrowEdge
        self.width = width
        self.beforeToggle = beforeToggle
        self.content = content
    }

    var body: some View {
        Button {
            beforeToggle()
            isPresented.toggle()
        } label: {
            Image(systemName: "info.circle")
                .font(iconFont)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .settingsInfoPopover(isPresented: $isPresented, arrowEdge: arrowEdge, width: width) {
            content()
        }
    }
}

extension View {
    /// 统一的气泡容器：顶部对齐 + 12pt 内边距 + 固定宽度。
    /// 适合触发按钮另有自定义行为、不方便整体替换成 `SettingsInfoAffordance` 的场景。
    func settingsInfoPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .top,
        width: CGFloat = 390,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(12)
            .frame(width: width, alignment: .leading)
        }
    }
}

/// 气泡内的小标题
struct SettingsInfoTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.headline)
    }
}

/// 气泡内的说明正文
struct SettingsInfoBody: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }
}
