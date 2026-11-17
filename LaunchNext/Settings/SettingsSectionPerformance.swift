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
            Button(appStore.localized(.okButton), role: .cancel) {}
        } message: {
            Text(appStore.localized(.performanceModeRestartMessage))
        }
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
