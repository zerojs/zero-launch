import SwiftUI

// MARK: - 设置页行样式组件
//
// 外观页此前是逐个手写的：每条开关都要 6 行（HStack + Text + Spacer + Toggle +
// labelsHidden + toggleStyle），每条说明都要 3 行，每处「禁用 + 变淡」都要 2 行。
// 光外观一页就重复了 14 条开关、几十条说明。样式一改就得挨个改，
// 而且散落的 0.5 / 0.45 / 0.6 三套透明度已经不一致了。
//
// 这里只抽「形状确定、参数简单」的四种：开关行、步进器行、说明文字、滑块行。
// 刻意不做通用容器组件 —— 卡片背景的圆角（10~19）与填充（quaternarySystemFill /
// windowBackgroundColor / liquidGlass）差异太大，硬套一个 SettingsCard 只会让调用处变复杂。
//
// 也没有引入 `Form`。`Form` 会接管行高、分组与背景，把现有的自定义卡片和
// `liquidGlass` 材质全部冲掉，属于视觉重做而不是重构。

/// 开关行：左侧标题，右侧 `.switch` 开关。
struct SettingsToggleRow<Accessory: View>: View {
    let title: String
    @Binding var isOn: Bool
    /// 标题右侧的附加内容（信息气泡、提示图标等）。没有就传 `EmptyView`。
    let accessory: Accessory

    var body: some View {
        HStack {
            // 长文案（德语/俄语）宁可换行也不截断。
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
            accessory
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}

extension SettingsToggleRow where Accessory == EmptyView {
    init(title: String, isOn: Binding<Bool>) {
        self.init(title: title, isOn: isOn, accessory: EmptyView())
    }
}

extension SettingsToggleRow {
    /// 标题后带信息气泡的变体：`SettingsToggleRow(title:isOn:) { SettingsInfoAffordance(...) }`
    init(title: String, isOn: Binding<Bool>, @ViewBuilder accessory: () -> Accessory) {
        self.init(title: title, isOn: isOn, accessory: accessory())
    }
}

/// 设置项下方的说明文字。
struct SettingsHint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// 关联设置分组容器：把一组功能上相互关联的行（开关 + 它的联动滑杆、说明等）
/// 套进同一个浅色外框，配一个组标题。
/// 之前这些行平铺在一起，开关和它的倍率滑杆隔着十几行，看不出归属；
/// 外框 + 标题让「这堆设置是一件事」可以直接看出来，组内顺序 = 先开关后调参。
struct SettingsGroupBox<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .quaternarySystemFill).opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(nsColor: .separatorColor).opacity(0.2), lineWidth: 0.7)
        )
    }
}

/// 「这条设置只在某个布局模式下生效」的标签。
///
/// 之前这类设置只是静静地变灰/禁用：全屏时文件夹窗口尺寸滑不动、
/// 紧凑模式下隐藏菜单栏点不了，用户看不出是因为模式不对，很容易当成功能坏了。
/// 标签把「属于哪个模式」直接摆在标题旁边，用词跟「布局作用范围」控件保持一致（全屏 / 紧凑）。
struct SettingsModeBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.15), in: Capsule(style: .continuous))
            .fixedSize()
    }
}

/// 步进器行：左侧标题，右侧 `Stepper` 加当前数值。
struct SettingsStepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Stepper(value: $value, in: range) {
                Text("\(value)")
                    .font(.callout.monospacedDigit())
            }
            .controlSize(.small)
        }
    }
}

/// 滑块行：标题 + 右侧实时数值 → 滑块 →（可选）两端刻度。
///
/// `trailing` 用泛型而不是 String，是因为有两处右侧放的是「布局模式作用范围」切换控件
/// 而不是数值文本。
struct SettingsSliderRow<Trailing: View>: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double?
    var lowerLabel: String?
    var centerLabel: String?
    var upperLabel: String?
    var isEnabled: Bool
    /// 禁用时是否整行变淡。
    ///
    /// 有些行的默认值就是「关闭」（悬浮放大、按下缩放、文件夹窗口尺寸），
    /// 如果整行一起变淡，新装用户看到的就是一片灰，像功能坏了；
    /// 这类行沿用原来的做法：只让 Slider 变成不可用，标题与数值保持正常对比度。
    var dimsWhenDisabled: Bool
    /// 标题旁的模式标签（仅全屏 / 仅紧凑）。
    var badgeText: String?
    private let trailingContent: () -> Trailing

    init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        lowerLabel: String? = nil,
        centerLabel: String? = nil,
        upperLabel: String? = nil,
        isEnabled: Bool = true,
        dimsWhenDisabled: Bool = true,
        badgeText: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.lowerLabel = lowerLabel
        self.centerLabel = centerLabel
        self.upperLabel = upperLabel
        self.isEnabled = isEnabled
        self.dimsWhenDisabled = dimsWhenDisabled
        self.badgeText = badgeText
        self.trailingContent = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                if let badgeText {
                    SettingsModeBadge(text: badgeText)
                }
                Spacer()
                trailingContent()
            }

            slider

            if let lowerLabel, let upperLabel {
                HStack {
                    Text(lowerLabel).font(.footnote)
                    Spacer()
                    if let centerLabel {
                        Text(centerLabel)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Text(upperLabel).font(.footnote)
                }
            }
        }
        .settingsEnabled(isEnabled, dimmedOpacity: dimsWhenDisabled ? 0.5 : 1)
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $value, in: range, step: step)
        } else {
            Slider(value: $value, in: range)
        }
    }
}

extension SettingsSliderRow where Trailing == EmptyView {
    init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double? = nil,
        lowerLabel: String? = nil,
        centerLabel: String? = nil,
        upperLabel: String? = nil,
        isEnabled: Bool = true,
        dimsWhenDisabled: Bool = true,
        badgeText: String? = nil
    ) {
        self.init(
            title: title,
            value: value,
            range: range,
            step: step,
            lowerLabel: lowerLabel,
            centerLabel: centerLabel,
            upperLabel: upperLabel,
            isEnabled: isEnabled,
            dimsWhenDisabled: dimsWhenDisabled,
            badgeText: badgeText,
            trailing: { EmptyView() }
        )
    }
}

extension View {
    /// 「禁用 + 变淡」这对修饰总是一起出现，合成一处，顺便统一透明度。
    func settingsEnabled(_ isEnabled: Bool, dimmedOpacity: Double = 0.5) -> some View {
        disabled(!isEnabled)
            .opacity(isEnabled ? 1 : dimmedOpacity)
    }

    /// 给无背景按钮铺满命中区域。
    ///
    /// `.buttonStyle(.plain)` / `.borderless` 下只有图标与文字这些「有像素」的子视图
    /// 参与命中测试，视图本身是透明的：
    /// - `Label` 的图标与文字之间的间隙点不到（「重置布局」「恢复默认」都是这样）；
    /// - 外面用 padding / `frame(maxWidth: .infinity)` 撑出来的透明区域也点不到。
    /// 在标签最外层铺一次 contentShape，整块矩形就都能触发。
    ///
    /// 只影响命中测试、不改变布局尺寸。
    func settingsHitArea() -> some View {
        contentShape(Rectangle())
    }
}
