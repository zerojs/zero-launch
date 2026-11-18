import Foundation

/// SwiftUpdater 是独立 SwiftPM 包，不能 import 主 App 的 `AppIdentity`。
/// 这里是同一份身份信息的**兜底副本**，语义与 `LaunchNext/AppIdentity.swift` 一致。
///
/// 优先级：App 启动 updater 时会传 `--repo owner/repo` 和 `--asset-pattern`，
/// 那两个参数优先于这里的常量。这里只在「用户手动跑 updater 二进制」时兜底。
enum AppIdentity {
    static let displayName = "ZeroLaunch"

    // 默认发布仓库。留空表示未配置——此时若不传 `--repo`，更新会直接报错。
    static let githubOwner = "zerojs"
    static let githubRepo = "zero-launch"

    static var isUpdateSourceConfigured: Bool {
        !githubOwner.isEmpty && !githubRepo.isEmpty
    }

    static var defaultRepoSlug: String? {
        isUpdateSourceConfigured ? "\(githubOwner)/\(githubRepo)" : nil
    }

    /// `~/Library/Application Support/<displayName>/updates`
    static var baseDirectory: URL {
        let fm = FileManager.default
        return fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent(displayName)
            .appendingPathComponent("updates")
    }

    /// 默认安装路径（未传 `--install-dir` 时的兜底）。
    static var defaultInstallPath: String {
        "/Applications/\(displayName).app"
    }
}
