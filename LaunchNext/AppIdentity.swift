import Foundation

/// 这个 App「是谁」的唯一来源。
///
/// 之前这些值散在十几处：GitHub API 地址、更新包匹配规则、Application Support
/// 目录名、Caches 目录名、安装路径兜底值…… 改名或换仓库时得全局搜索替换，
/// 漏一处就是「更新检查装回别人家的包」。
///
/// 现在集中在这里。改名 / 换仓库 / 换目录只需要动这一个文件。
///
/// 注意：`UpdaterScripts/SwiftUpdater` 是独立 SwiftPM 包，不能 import 本文件，
/// 它有自己的一份 `AppIdentity.swift`（同名、同语义）。改动时两边一起改，
/// 或者用 `--repo` 参数从 App 传给 updater（推荐，见 `startUpdaterProcess`）。
enum AppIdentity {
    /// 对外显示名。同时决定：
    /// - 更新包里 `.app` 的文件名（`ZeroLaunch1.0.0.zip` → `ZeroLaunch.app`）
    /// - 默认安装位置 `/Applications/ZeroLaunch.app`
    /// - Application Support / Caches 目录名
    static let displayName = "ZeroLaunch"

    // MARK: - 自更新发布源

    /// 自更新拉取的 GitHub 仓库。留空表示「未配置」——此时更新检查会直接报错，
    /// 而不是悄悄去拉原作者的包。
    static let githubOwner = "zerojs"
    static let githubRepo = "zero-launch"

    static var isUpdateSourceConfigured: Bool {
        !githubOwner.isEmpty && !githubRepo.isEmpty
    }

    /// 是否在设置侧栏露出「更新」入口。
    ///
    /// 首个 Release（1.0.0）已发布，`/releases/latest` 可用，入口正常展示。
    static let showsUpdatesEntry = true

    /// 传给内置 SwiftUpdater 的 `--repo owner/repo` 参数。
    static var githubRepoSlug: String? {
        isUpdateSourceConfigured ? "\(githubOwner)/\(githubRepo)" : nil
    }

    /// 发布资产文件名规则（NSRegularExpression 语法）。
    /// 必须和 `scripts/release.sh` 产出的 zip 名字一致：`ZeroLaunch1.0.0.zip`。
    static var releaseAssetPattern: String {
        "\(displayName).*\\.zip"
    }

    static func latestReleaseURL() -> URL? {
        guard isUpdateSourceConfigured else { return nil }
        return URL(string: "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/latest")
    }

    static func releaseTagURL(_ tag: String) -> URL? {
        guard isUpdateSourceConfigured else { return nil }
        return URL(string: "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/tags/\(tag)")
    }

    static var releasesPageURL: URL? {
        guard isUpdateSourceConfigured else { return nil }
        return URL(string: "https://github.com/\(githubOwner)/\(githubRepo)/releases")
    }

    // MARK: - 磁盘目录

    /// 改名前的目录名。只用于「首次启动把旧数据搬过来」，不做读取。
    private static let legacyDirectoryName = "LaunchNext"

    /// `~/Library/Application Support/<displayName>`
    ///
    /// 首次调用时如果新目录不存在、而旧目录存在，会把旧目录整个复制过来，
    /// 这样改名不会丢已保存的布局（Data.store）、文件夹和排序。
    static func appSupportDirectory() -> URL {
        let fm = FileManager.default
        guard let base = try? fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }

        let target = base.appendingPathComponent(displayName, isDirectory: true)
        if !fm.fileExists(atPath: target.path) {
            migrateLegacyDirectoryIfNeeded(
                from: base.appendingPathComponent(legacyDirectoryName, isDirectory: true),
                to: target
            )
            if !fm.fileExists(atPath: target.path) {
                try? fm.createDirectory(at: target, withIntermediateDirectories: true)
            }
        }
        return target
    }

    /// `~/Library/Caches/<displayName>`：CLI 的 IPC socket 就放这里。
    static func cacheDirectory() -> URL? {
        let fm = FileManager.default
        guard let caches = try? fm.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return nil
        }
        let directory = caches.appendingPathComponent(displayName, isDirectory: true)
        if !fm.fileExists(atPath: directory.path) {
            try? fm.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private static func migrateLegacyDirectoryIfNeeded(from legacy: URL, to target: URL) {
        let fm = FileManager.default
        guard fm.fileExists(atPath: legacy.path),
              !fm.fileExists(atPath: target.path) else { return }
        do {
            try fm.copyItem(at: legacy, to: target)
        } catch {
            // 复制到一半失败就清掉，避免留下「半套数据」让下次启动以为已经迁移过。
            try? fm.removeItem(at: target)
        }
    }
}
