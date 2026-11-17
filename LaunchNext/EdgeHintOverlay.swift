import AppKit
import SwiftUI

/// 把 `EdgeHintController`（CA 网格用的边缘翻页提示条）桥接到 SwiftUI。
///
/// 轻量模式关掉 CA 渲染后，网格改由 SwiftUI 绘制，没有自己的 CALayer 宿主，
/// 这个提示条就只存在于 CA 渲染器里 —— 同一份拖拽逻辑换个渲染器就少了一个
/// 可见反馈，看起来像「提示效果被删了」。
///
/// 这里给它一个真实的 NSView 宿主，样式、渐变、chevron、进度环全部复用同一个
/// controller，不另写一套 SwiftUI 版本，避免两边慢慢走偏。
struct EdgeHintOverlay: NSViewRepresentable {
    /// -1 左边缘 / 1 右边缘 / 0 收起
    let side: Int

    final class HostView: NSView {
        let controller = EdgeHintController()

        /// 期望朝向。首帧 bounds 还是 0，等 layout() 回调时再真正摆上。
        var desiredSide: Int = 0

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.masksToBounds = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        /// 完全不参与命中测试：拖拽手势必须落到下面的网格上。
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func layout() {
            super.layout()
            applySide()
        }

        func applySide() {
            guard bounds.width > 0, bounds.height > 0, let layer else { return }
            controller.update(side: desiredSide, in: bounds, host: layer)
        }
    }

    func makeNSView(context: Context) -> HostView {
        HostView(frame: .zero)
    }

    func updateNSView(_ nsView: HostView, context: Context) {
        nsView.desiredSide = side
        nsView.applySide()
    }
}
