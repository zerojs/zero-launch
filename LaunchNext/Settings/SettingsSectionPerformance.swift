import SwiftUI
import AppKit
import UniformTypeIdentifiers
import SwiftData
import MachO
import Darwin

extension SettingsView {
    var performanceSection: some View {
        let stats = appStore.cacheStatistics
        let isLeanMode = appStore.performanceMode == .lean
        let canUseCAGrid = appStore.performanceMode == .lean

        return VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text(appStore.localized(.performanceModeTitle))
                    .font(.title3.weight(.semibold))
                Text(appStore.localized(.performanceModeSubtitle))
                    .font(.callout)
                    .foregroundStyle(.secondary)

                performanceModePicker()

                Text(appStore.localized(isLeanMode ? .performanceModeDescriptionLean : .performanceModeDescriptionFull))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Divider()

                HStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(appStore.localized(.performanceRendererBadge))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                        Text(appStore.localized(.performanceRendererTitle))
                            .font(.headline)
                    }
                    Spacer()
                    Toggle("", isOn: $appStore.useCAGridRenderer)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .disabled(!canUseCAGrid)
                }
                .opacity(canUseCAGrid ? 1 : 0.5)

                if !canUseCAGrid {
                    Text(appStore.localized(.performanceRendererSubtitle))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if appStore.useCAGridRenderer {
                    Text(appStore.localized(.performanceRendererWarning))
                        .font(.footnote)
                        .foregroundStyle(Color.accentColor)
                }

                if !appStore.useCAGridRenderer {
                    Text(appStore.localized(.performanceRendererRecommendation))
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(appStore.localized(.performanceCacheTitle))
                        .font(.title3.weight(.semibold))
                    Spacer()
                    if isLeanMode {
                        leanModeBadge()
                    }
                    cacheStatusBadge(isValid: stats.isCacheValid)
                }

                Text("\(appStore.localized(.performanceCacheLastUpdateLabel)): \(formattedCacheUpdate(stats.lastUpdate))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if isLeanMode {
                    Text(appStore.localized(.performanceCacheLeanHint))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // 内存占用是活数据：TimelineView 每 2s 重算一次 phys_footprint，
                // 而不是只在视图出现时读一次（那样展示的是打开设置页瞬间的死快照）。
                TimelineView(.periodic(from: .now, by: 2)) { _ in
                    cacheCountRow(title: appStore.localized(.performanceMemoryUsageLabel),
                                  valueText: currentMemoryUsageValue())
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    cacheCountRow(title: appStore.localized(.performanceCacheIconLabel),
                                  valueText: isLeanMode ? appStore.localized(.performanceCacheIconsDisabled) : "\(stats.iconCacheSize)")
                    cacheCountRow(title: appStore.localized(.performanceCacheAppInfoLabel),
                                  valueText: "\(stats.appInfoCacheSize)")
                    cacheCountRow(title: appStore.localized(.performanceCacheGridLabel),
                                  valueText: "\(stats.gridLayoutCacheSize)")
                    cacheCountRow(title: appStore.localized(.performanceCacheTotalLabel),
                                  valueText: "\(stats.totalCacheSize)")
                }

                Button {
                    appStore.clearCache()
                    IconStore.shared.clear()
                    FolderPreviewCache.shared.clear()
                } label: {
                    Label(appStore.localized(.performanceCacheClearButton), systemImage: "trash")
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .onChange(of: appStore.performanceMode) { _, _ in
            showPerformanceRestartPrompt = true
        }
        .alert(appStore.localized(.performanceModeRestartTitle), isPresented: $showPerformanceRestartPrompt) {
            Button(appStore.localized(.restartNowButton)) {
                Self.relaunchApp()
            }
            Button(appStore.localized(.okButton), role: .cancel) {}
        } message: {
            Text(appStore.localized(.performanceModeRestartMessage))
        }
    }

    /// 退出并重新拉起当前 app（性能模式切换、导入备份后使用）。
    /// 用 `Bundle.main.bundleURL` 而不是硬编码 /Applications——开发期部署在别的位置也能正确重启。
    ///
    /// 两个必须避开的坑：
    /// 1. `open -n` 会在旧实例还没退出时就另起一个新实例 —— 结果两个进程同时在跑，
    ///    旧实例的设置面板与其上的弹窗留在屏幕上，看起来就是「点了重启但弹窗没关」。
    ///    所以改成先等旧 PID 真正退出，再用不带 `-n` 的 `open -a` 拉起。
    /// 2. `NSApp.terminate` 会走 applicationShouldTerminate → 窗口淡出动画后才退出；
    ///    设置面板（sheet）还挂着时动画可能不回调，进程就永远不退出。调用前先收掉 sheet。
    static func relaunchApp() {
        let bundlePath = Bundle.main.bundleURL.path
        let pid = ProcessInfo.processInfo.processIdentifier
        // 等旧进程退出（kill -0 在进程不存在时返回非 0），再拉起新实例。
        let script = "while kill -0 \(pid) 2>/dev/null; do sleep 0.2; done; open -a \"\(bundlePath)\""
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        try? process.run()

        // 先把 sheet 收掉，避免 terminate 卡在淡出动画上。
        if let sheet = NSApp.windows.first(where: { $0.isSheet }) {
            sheet.sheetParent?.endSheet(sheet)
        }
        NSApp.terminate(nil)
    }

    func currentMemoryUsageValue() -> String {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        let kern = withUnsafeMutablePointer(to: &info) { pointer -> kern_return_t in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }

        guard kern == KERN_SUCCESS else { return "--" }

        let usedBytes = info.phys_footprint
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(usedBytes))
    }

    func currentMemoryUsageString() -> String {
        "Memory: \(currentMemoryUsageValue())"
    }

    func formattedCacheUpdate(_ date: Date) -> String {
        if date == .distantPast {
            return appStore.localized(.performanceCacheNever)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func performanceModePicker() -> some View {
        HStack(spacing: 6) {
            performanceModeButton(mode: .lean, title: appStore.localized(.performanceModeLean))
            performanceModeButton(mode: .full, title: appStore.localized(.performanceModeFull))
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .quaternarySystemFill))
        )
    }

    func performanceModeButton(mode: PerformanceMode, title: String) -> some View {
        let isSelected = appStore.performanceMode == mode
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                appStore.performanceMode = mode
            }
        } label: {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.clear)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(isSelected ? Color.accentColor.opacity(0.45) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }

    func cacheStatusBadge(isValid: Bool) -> some View {
        let title = appStore.localized(isValid ? .performanceCacheStatusValid : .performanceCacheStatusInvalid)
        let color = isValid ? Color.green : Color.orange
        return Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.16))
            )
    }

    func leanModeBadge() -> some View {
        Text(appStore.localized(.performanceModeLean))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.green.opacity(0.16))
            )
    }

    func cacheCountRow(title: String, valueText: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valueText)
                .font(.callout.weight(.semibold).monospacedDigit())
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .quaternarySystemFill))
        )
    }

}
