import AppKit
import QuartzCore

/// 拖拽到左右边缘时的「即将翻页」提示条。
///
/// 主网格与文件夹网格各持有一个实例,样式一致:
/// - 贴着边缘的一层渐隐白雾,越靠边越亮,提示"再往前就是另一页";
/// - 中间一个指向翻页方向的 chevron;
/// - 一圈圆角描边按翻页延迟从 0 走到 1,走满即触发翻页。
///
/// 所有图层都落在宿主 view 的 layer 上,zPosition 抬到 900,
/// 高于图标角标、低于拖拽预览,不会盖住正在拖的图标。
final class EdgeHintController {
    // MARK: - 可调参数

    /// 提示条宽度
    var width: CGFloat = 72
    /// 描边进度走完一圈的时长,与翻页延迟保持一致
    var progressDuration: TimeInterval = 0.4
    /// 距上下边缘的留白
    var verticalInset: CGFloat = 88
    /// 最小高度,避免窗口很矮时提示条糊成一条
    var minHeight: CGFloat = 180
    /// 圆角
    var cornerRadius: CGFloat = 10

    // MARK: - 状态

    /// 当前朝向:-1 左,1 右,0 未显示
    private(set) var side: Int = 0

    private weak var hostLayer: CALayer?
    private var container: CALayer?
    private var gradient: CAGradientLayer?
    private var chevron: CAShapeLayer?
    private var border: CAShapeLayer?

    // MARK: - 对外接口

    /// 更新提示条:-1 左 / 1 右 / 0 隐藏
    func update(side newSide: Int, in bounds: CGRect, host: CALayer?) {
        guard newSide != 0, bounds.width > 0, bounds.height > 0 else {
            hide()
            return
        }
        guard let host else { return }

        if container?.superlayer !== host {
            container?.removeFromSuperlayer()
            let fresh = makeContainer()
            host.addSublayer(fresh)
            container = fresh
            side = 0
        }

        hostLayer = host
        let changed = newSide != side
        side = newSide

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        container?.isHidden = false
        applyLayout(in: bounds)
        CATransaction.commit()

        // 换边才重放进度;同一侧持续停留则保留已有进度,避免每帧重置导致永远走不满
        if changed || border?.animation(forKey: "fill") == nil {
            startProgress()
        }
    }

    /// 宿主尺寸变化时重新摆放(保持当前朝向)
    func layoutIfVisible(in bounds: CGRect) {
        guard side != 0, container != nil, bounds.width > 0, bounds.height > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        applyLayout(in: bounds)
        CATransaction.commit()
    }

    func hide() {
        guard container != nil || side != 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        border?.removeAllAnimations()
        container?.removeFromSuperlayer()
        CATransaction.commit()
        container = nil
        gradient = nil
        chevron = nil
        border = nil
        side = 0
    }

    // MARK: - 图层搭建

    private func makeContainer() -> CALayer {
        let container = CALayer()
        container.name = "edgeHint"
        container.zPosition = 900
        container.masksToBounds = false

        let gradient = CAGradientLayer()
        gradient.name = "gradient"
        gradient.cornerRadius = cornerRadius
        gradient.colors = [
            NSColor.white.withAlphaComponent(0.30).cgColor,
            NSColor.white.withAlphaComponent(0.10).cgColor,
            NSColor.white.withAlphaComponent(0.0).cgColor
        ]
        gradient.locations = [0, 0.45, 1]
        container.addSublayer(gradient)
        self.gradient = gradient

        let chevron = CAShapeLayer()
        chevron.name = "chevron"
        chevron.fillColor = NSColor.clear.cgColor
        chevron.strokeColor = NSColor.white.withAlphaComponent(0.88).cgColor
        chevron.lineWidth = 2.5
        chevron.lineCap = .round
        chevron.lineJoin = .round
        container.addSublayer(chevron)
        self.chevron = chevron

        let border = CAShapeLayer()
        border.name = "border"
        border.fillColor = NSColor.clear.cgColor
        border.strokeColor = NSColor.white.withAlphaComponent(0.72).cgColor
        border.lineWidth = 2
        border.lineCap = .round
        border.strokeEnd = 0
        container.addSublayer(border)
        self.border = border

        return container
    }

    // MARK: - 布局

    private func applyLayout(in bounds: CGRect) {
        guard let container, let gradient, let chevron, let border else { return }

        let height = max(minHeight, bounds.height - verticalInset * 2)
        let y = max(0, (bounds.height - height) / 2)
        let frame = CGRect(
            x: side < 0 ? 0 : bounds.width - width,
            y: y,
            width: width,
            height: min(height, bounds.height)
        )

        container.frame = frame
        gradient.frame = container.bounds
        gradient.cornerRadius = cornerRadius
        // 靠屏幕边缘一侧最亮,向内渐隐
        gradient.startPoint = side < 0 ? CGPoint(x: 0, y: 0.5) : CGPoint(x: 1, y: 0.5)
        gradient.endPoint = side < 0 ? CGPoint(x: 1, y: 0.5) : CGPoint(x: 0, y: 0.5)

        let box = container.bounds
        let center = CGPoint(x: box.midX, y: box.midY)
        let halfW: CGFloat = 5
        let halfH: CGFloat = 11
        // side < 0 箭头朝左(翻上一页),side > 0 箭头朝右(翻下一页)
        let tipX = side < 0 ? center.x - halfW : center.x + halfW
        let tailX = side < 0 ? center.x + halfW : center.x - halfW
        let path = CGMutablePath()
        path.move(to: CGPoint(x: tailX, y: center.y - halfH))
        path.addLine(to: CGPoint(x: tipX, y: center.y))
        path.addLine(to: CGPoint(x: tailX, y: center.y + halfH))
        chevron.frame = box
        chevron.path = path
        chevron.shadowColor = NSColor.black.withAlphaComponent(0.35).cgColor
        chevron.shadowOpacity = 1
        chevron.shadowRadius = 3
        chevron.shadowOffset = .zero

        let inset: CGFloat = 1
        border.frame = box
        border.path = CGPath(
            roundedRect: box.insetBy(dx: inset, dy: inset),
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
    }

    // MARK: - 进度描边

    /// 描边按 progressDuration 从 0 走到 1;走到 1 时宿主即将翻页
    private func startProgress() {
        guard let border else { return }
        border.removeAnimation(forKey: "fill")

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = progressDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        border.strokeEnd = 1
        CATransaction.commit()

        border.add(animation, forKey: "fill")
    }
}
