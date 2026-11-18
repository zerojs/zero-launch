# ZeroLaunch 独立化改造清单

> 状态：**核心身份改造已全部完成**（2026-11-18）。
> 原始背景：项目 fork 自 `RoversX/LaunchNext`（其又基于 `ggkevinnnn/LaunchNow`，GPL-3.0）。
> 分发模式：与 LaunchNext 相同 —— GitHub Release 发 zip + App 内置 SwiftUpdater 自更新；免费路线用 ad-hoc 签名，正式公证等有 Developer ID 再上。

## ✅ 已完成

### 身份标识（project.pbxproj）

| 项 | 现值 | 行号 |
|---|---|---|
| 显示名 / 产物名 | `ZeroLaunch` | 513/556、523/566 |
| Bundle ID | `cn.zerojs.zerolaunch`（tests 为 `.tests`） | 522/565、590/612 |
| 版本 | `1.0.0`（build `1`） | 521/564、505/548 |
| Team ID | `ZJYPTGHQSF`（本机免费 Personal Team） | 404/471/507/550 |
| 版权 | `© 2026 zerojs. Based on LaunchNext by RoversX / CloseX. Licensed under GPL-3.0` | 516/559 |

### 单一身份真源

- [x] `LaunchNext/AppIdentity.swift`（新增）：displayName、`githubOwner="zerojs"` / `githubRepo="zero-launch"`、releaseAssetPattern、`appSupportDirectory()`（含 `LaunchNext` → `ZeroLaunch` 一次性旧数据搬迁）、`cacheDirectory()`。仓库未配置时更新检查直接报错，不会误拉原作者的包。
- [x] `UpdaterScripts/SwiftUpdater/Sources/SwiftUpdater/AppIdentity.swift`（新增）：updater 是独立 SwiftPM 包，这是同语义兜底副本；App 启动 updater 时传 `--repo`，运行时参数优先。

### 分发链路（zip + 自更新）

- [x] `AppStore.swift`：更新检查走 `AppIdentity.latestReleaseURL()`；updater 启动传 `--repo` + `--asset-pattern`；App Support / updater 配置目录走 AppIdentity
- [x] `LaunchpadApp.swift`：Data.store 目录走 AppIdentity
- [x] `LaunchNextCLIIPC.swift`：IPC socket 目录 `Caches/ZeroLaunch/cli.sock`
- [x] updater 包：`--repo` 参数、owner/repo 传参链路、`ZeroLaunch.*\.zip` 资产规则、`/Applications/ZeroLaunch.app` 兜底、TUI 标题与本地化文案
- [x] `scripts/release.sh`：`ZeroLaunch.app` → `ZeroLaunch<版本>.zip` + checksums，**含 ad-hoc 签名 + 清隔离提示**（免费路线，无开发者账号即可发）
- [x] `scripts/release-notarized.sh`：路径 / bundle id 校验（`cn.zerojs.zerolaunch`）/ zip 名 / 环境变量 `ZEROLAUNCH_*` / notary profile（正式签名 + 公证路线，需 Developer ID）
- [x] `.github/workflows/update-homebrew.yml`：tap `zerojs/homebrew-tap`、formula `zerolaunch`、仓库 `zerojs/zero-launch`

### CLI 与通知

- [x] 命令名 `launchnext` → `zerolaunch`：shim 安装路径（4 处 bin）、shim 内嵌帮助、shim 标记三常量（`# ZeroLaunch CLI shim`）、`~/.zprofile` 片段、卸载判断（兼容新旧两分支）、`LaunchNextCLI.swift` 33 处、`Localization.swift` 28 处（14 种语言）、设置页示例
- [x] 通知标识 `zerolaunch.update.*`；DispatchQueue / 搜索索引 label `io.zerojs.zerolaunch.*` / `cn.zerojs.zerolaunch.search-index`

### 外链

- [x] 关于页 4 个链接走 AppIdentity（项目 / issues / contribute），Blog → `https://www.zerojs.cn`

## 有意保留（不要改成 ZeroLaunch）

| 内容 | 位置 | 原因 |
|---|---|---|
| `onboardingFlowPoweredBy: "RoversX / CloseX.org"` | `Localization.swift` ×13 | **GPL 署名，法律要求** |
| `legacyPreferencesDomain = "LaunchNext"` + 迁移逻辑 | `AppStore.swift:366` | 老用户升级带走设置 |
| `legacyDirectoryName = "LaunchNext"` | `AppIdentity.swift` | 一次性旧数据搬迁 |
| 备份扩展名 `.launchnext` | `SettingsSectionBackup.swift:425` | 改会破坏旧备份读取 |
| 卸载 shim 判断里的 `/LaunchNext.app/...` 分支 | `AppStore.swift:3146` | 兼容清理旧版残留 |

## ⬜ 剩余事项

### 发版前（P0）

- [ ] **Xcode GUI 里构建一次验证**：本会话命令行 `xcodebuild` / `swift build` 受 `sandbox-exec: Operation not permitted` 环境限制跑不起来（SwiftUI 宏插件起不来），签名、Run Script（updater 打包进 `Resources/Updater/`）只能在 Xcode 里确认
- [ ] GitHub 创建 `zerojs/zero-launch` 仓库并 push（更新检查指向它）
- [ ] `./scripts/release.sh` 产出 zip → `gh release create 1.0.0` 上传 `ZeroLaunch1.0.0.zip` + `checksums.txt`
- [ ] 验证自更新闭环：本机装 1.0.0 → 发 1.0.1 → App 内「检查更新」→ updater 拉包替换成功

### 品牌（P1）

- [x] `README.md` 重写为 ZeroLaunch 版：下载/网站（www.zerojs.cn）/brew（zerojs/homebrew-tap + zerolaunch）/CLI 命令/数据路径/签名说明（ad-hoc 免费路线）/GPL 署名（保留 `Built upon LaunchNow` 并新增 LaunchNext 署名行）/badge
- [x] `i18n/README.*.md`（12 个）同样改造：外链、命令名、路径、证书原因句（去掉「买不起」改为「暂未购买」）、每种语言插入 LaunchNext 署名行、badge 修正；`-scheme LaunchNext` / `LaunchNext.xcodeproj` / `LaunchNext target` 等内部工程名有意保留
- [x] `UpdaterScripts/SwiftUpdater/README.md` 同步改造；`launchnext_updater.py` → 重命名 `zerolaunch_updater.py`，常量对齐 `zerojs/zero-launch`
- [x] `Config/OpenMultitouchSupport.xcconfig` 注释更新；`__pycache__` 清理
- [ ] App 图标（`Assets.xcassets/AppIcon.appiconset`、`AppIcon.icon/`）与 `public/` 截图仍是原项目视觉，**需要你自己出图替换**
- [ ] Homebrew cask：需自建 `zerojs/homebrew-tap` 仓库；不建的话 workflow 会静默跳过（`TAP_TOKEN` 未配置时）

### 内部命名（P2，可不改）

- [ ] target `LaunchNext` / `LaunchNextTests` / `LaunchNextContextMenuCore`、scheme、`LaunchNext.xcodeproj`、源码目录 `LaunchNext/`、`LaunchNext.entitlements`、`LaunchNextCLI*.swift`、前缀函数 `LaunchNextParseHexColor` / `LaunchNextLabelColor`、根目录 `*.lproj`（pbxproj 14 处引用）

> 这些纯内部命名不影响任何功能，改名要动 pbxproj 和 scheme，收益低、风险高。LaunchNext 自己也没改工程名。**建议长期保留。**

## 法务：GPL-3.0 硬约束

- ✅ 版权声明已改成「zerojs + 保留原作者」形式
- 必须继续 GPL-3.0 分发，不能换成闭源或更宽松协议
- 对外发布二进制时必须能提供对应源码
- README 重写时保留原作者署名与 LaunchNow 来源说明
