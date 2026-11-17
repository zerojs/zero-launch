import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var systemVersionText: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return String(format: appStore.localized(.aboutInfoMacOSValueFormat),
                      v.majorVersion, v.minorVersion, v.patchVersion)
    }

    var chipText: String {
        var size: size_t = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var nameBuffer = [CChar](repeating: 0, count: Int(size))
        if sysctlbyname("machdep.cpu.brand_string", &nameBuffer, &size, nil, 0) == 0 {
            return String(cString: nameBuffer)
        }
        return appStore.localized(.aboutInfoUnknownChip)
    }

    var displayResolutionText: String {
        guard let screen = NSScreen.main else { return appStore.localized(.aboutInfoUnknownDisplay) }
        let scale = screen.backingScaleFactor
        let size = screen.frame.size
        let width = Int(size.width * scale)
        let height = Int(size.height * scale)
        return "\(width)×\(height)"
    }

    var displayNameText: String {
        if let name = NSScreen.main?.localizedName, !name.isEmpty {
            return name
        }
        return appStore.localized(.aboutInfoDisplayGeneric)
    }

    @ViewBuilder
    var headlineGlass: some View {
        PressableGlassTitle(text: appStore.localized(.appTitle))
    }

    struct PressableGlassTitle: View {
        let text: String

        @GestureState private var isPressed = false
        @State private var bounce = false

        private var scale: CGFloat {
            if isPressed { return 0.97 }
            if bounce { return 1.01 }
            return 1.0
        }

        private var shadowOpacity: Double {
            isPressed ? 0.18 : 0.0
        }

        private var shadowRadius: CGFloat {
            isPressed ? 8 : 0
        }

        private var shadowOffsetY: CGFloat {
            isPressed ? 4 : 0
        }

        var body: some View {
            let label = Text(text)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)

            label
                .glassEffect(.clear, in: Capsule())
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: shadowOffsetY)
                .scaleEffect(scale)
                .contentShape(Capsule())
                .gesture(pressGesture)
                .animation(.easeOut(duration: 0.12), value: isPressed)
                .animation(.spring(response: 0.26, dampingFraction: 0.62), value: bounce)
        }

        private var pressGesture: some Gesture {
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if bounce { bounce = false }
                }
                .updating($isPressed) { _, state, _ in
                    state = true
                }
                .onEnded { _ in
                    bounce = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        bounce = false
                    }
                }
        }
    }


    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .center) {
                Image("AboutBackground")
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(16.0/9.0, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(spacing: 12) {
                    headlineGlass

                    Text(String(format: appStore.localized(.versionLabelFormat),
                                getVersion(fallback: appStore.localized(.versionFallback))))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(appStore.localized(.backgroundHint))
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 180, maxHeight: 200)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1.4)
            )
            .padding(.bottom, 12)

            HStack(alignment: .bottom, spacing: 12) {
                TicTacToeBoard()
                    .frame(width: 130)

                infoCard
            }

            Spacer()

            HStack(spacing: 12) {
                glassButton(title: appStore.localized(.aboutProjectLink), systemImage: "arrow.up.right.square") {
                    openExternalLink("https://github.com/RoversX/LaunchNext")
                }
                glassButton(title: appStore.localized(.aboutReportBug), systemImage: "exclamationmark.bubble") {
                    openExternalLink("https://github.com/RoversX/LaunchNext/issues")
                }
                glassButton(title: appStore.localized(.aboutContribute), systemImage: "hands.sparkles") {
                    openExternalLink("https://github.com/RoversX/LaunchNext")
                }
                glassButton(title: appStore.localized(.aboutBlog), systemImage: "globe") {
                    openExternalLink("https://blog.closex.org")
                }
            }
            .frame(maxWidth: .infinity)

            // 退出放在「关于」：它是「关掉这个应用」的动作，和版本信息属于同一类，
            // 放在通用页的底部反而容易被当成普通设置误点。
            Button {
                showQuitConfirm = true
            } label: {
                Label(appStore.localized(.quit), systemImage: "power")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    // `.buttonStyle(.plain)` 下只有文字与图标本身参与命中测试，
                    // 外面那层 frame 是透明的、不会扩大点击区域 —— 所以之前只有
                    // 「退出」两个字能点。显式铺一层 contentShape，
                    // 让整块玻璃背景都可触发。
                    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .alert(appStore.localized(.quitConfirmTitle), isPresented: $showQuitConfirm) {
                Button(appStore.localized(.quit), role: .destructive) {
                    AppDelegate.shared?.quitWithFade()
                }
                Button(appStore.localized(.cancel), role: .cancel) {}
            }
        }
        .frame(maxWidth: .infinity, minHeight: 550, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    func openExternalLink(_ rawURL: String) {
        guard let url = URL(string: rawURL) else {
            NSSound.beep()
            return
        }

        if let appDelegate = AppDelegate.shared {
            appDelegate.openExternalURL(url)
        } else if !NSWorkspace.shared.open(url) {
            NSSound.beep()
        }
    }

    @ViewBuilder
    var infoCard: some View {
        let cardFill = colorScheme == .light ? Color.white : Color.white.opacity(0.05)
        VStack(alignment: .leading, spacing: 10) {
            Text(appStore.localized(.aboutInfoSystemTitle))
                .font(.headline.weight(.semibold))
            infoRow(label: appStore.localized(.aboutInfoMacOSLabel), value: systemVersionText)

            Divider()

            Text(appStore.localized(.aboutInfoProcessorTitle))
                .font(.headline.weight(.semibold))
            infoRow(label: appStore.localized(.aboutInfoChipLabel), value: chipText)

            Divider()

            Text(appStore.localized(.aboutInfoDisplayTitle))
                .font(.headline.weight(.semibold))
            infoRow(label: displayNameText, value: displayResolutionText)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }

    @ViewBuilder
    func glassButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Inline Games
    struct TicTacToeBoard: View {
        enum Mark: String {
            case x = "X", o = "O", empty = ""
        }

        @State private var cells: [Mark] = Array(repeating: .empty, count: 9)
        @State private var isPlayerTurn: Bool = true
        @State private var statusText: String = "Your turn"
        @State private var gameOver: Bool = false

        var body: some View {
            VStack(spacing: 12) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
                    ForEach(0..<9) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.12))
                            Text(cells[index].rawValue)
                                .font(.system(size: 28, weight: .bold))
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            guard !gameOver, isPlayerTurn, cells[index] == .empty else { return }
                            makeMove(at: index, mark: .x)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                aiTurn()
                            }
                        }
                    }
                }
                Text(statusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(action: resetGame) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }

        private func makeMove(at index: Int, mark: Mark) {
            cells[index] = mark
            if let winner = evaluateWinner() {
                statusText = winner == .x ? "You win!" : "AI wins!"
                gameOver = true
            } else if !cells.contains(.empty) {
                statusText = "Draw"
                gameOver = true
            } else {
                isPlayerTurn.toggle()
                statusText = isPlayerTurn ? "Your turn" : "AI thinking..."
            }
        }

        private func aiTurn() {
            guard !gameOver else { return }
            guard !isPlayerTurn else { return }

            let emptyCells = cells.enumerated().filter { $0.element == .empty }.map { $0.offset }
            guard let choice = emptyCells.randomElement() else { return }
            makeMove(at: choice, mark: .o)
        }

        private func evaluateWinner() -> Mark? {
            let lines = [
                [0,1,2],[3,4,5],[6,7,8],
                [0,3,6],[1,4,7],[2,5,8],
                [0,4,8],[2,4,6]
            ]
            for line in lines {
                let marks = line.map { cells[$0] }
                if marks.allSatisfy({ $0 == .x }) { return .x }
                if marks.allSatisfy({ $0 == .o }) { return .o }
            }
            return nil
        }

        private func resetGame() {
            cells = Array(repeating: .empty, count: 9)
            isPlayerTurn = true
            statusText = "Your turn"
            gameOver = false
        }
    }

}
