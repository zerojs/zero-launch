import SwiftUI

enum LNAnimations {
    // MARK: - Springs - 优化性能的动画配置
    static var springFast: Animation {
        guard AnimationPreferences.isEnabled else { return .linear(duration: 0.0001) }
        return .spring(response: AnimationPreferences.springResponse, dampingFraction: 0.8)
    }
    
    // MARK: - 性能优化的动画
    static var dragPreview: Animation {
        guard AnimationPreferences.isEnabled else { return .linear(duration: 0.0001) }
        return .easeOut(duration: AnimationPreferences.baseDuration)
    }
    static var gridUpdate: Animation {
        guard AnimationPreferences.isEnabled else { return .linear(duration: 0.0001) }
        return .easeInOut(duration: AnimationPreferences.baseDuration)
    }
    
    // MARK: - Transitions
    static var folderOpenTransition: AnyTransition {
        if AnimationPreferences.isEnabled {
            return AnyTransition.scale(scale: 0.95).combined(with: .opacity)
        } else {
            return AnyTransition.opacity
        }
    }

    /// 从指定锚点(通常是文件夹图标的位置)缩放展开/收起的过渡,
    /// 模拟 LaunchOS 的文件夹打开动画。
    static func folderOpenAnchorTransition(anchor: UnitPoint) -> AnyTransition {
        guard AnimationPreferences.isEnabled else { return AnyTransition.opacity }
        return AnyTransition.modifier(
            active: FolderAnchorScaleModifier(anchor: anchor, isActive: true),
            identity: FolderAnchorScaleModifier(anchor: anchor, isActive: false)
        )
    }
}

/// 锚点缩放 + 透明度过渡修饰器:active 状态对应收起(小、透明),
/// identity 对应展开完成。
private struct FolderAnchorScaleModifier: ViewModifier {
    let anchor: UnitPoint
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.35 : 1, anchor: anchor)
            .opacity(isActive ? 0 : 1)
    }
}

private enum AnimationPreferences {
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "enableAnimations") as? Bool ?? true
    }

    static var baseDuration: Double {
        let stored = UserDefaults.standard.double(forKey: "animationDuration")
        let value = stored == 0 ? 0.3 : stored
        return max(0.05, min(value, 1.5))
    }

    static var springResponse: Double {
        max(0.15, baseDuration)
    }
}
