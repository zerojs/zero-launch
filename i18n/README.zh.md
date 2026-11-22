# ZeroLaunch

**语言**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 下载

**[点此下载](https://github.com/zerojs/zero-launch/releases/latest)** - 获取最新版本

🌐 **网站**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **文档**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ 请考虑为 [ZeroLaunch](https://github.com/zerojs/zero-launch) 和原项目 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) 点 star！

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe 移除了 Launchpad，取而代之的界面很难用，甚至都没有充分利用你的 GPU。苹果，至少给用户一个切换回去的选项吧。在此之前，这里是 ZeroLaunch。

*基于 [LaunchNext](https://github.com/RoversX/LaunchNext)（作者 RoversX）开发——非常感谢原项目！❤️ LaunchNext 本身则是基于 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)（作者 ggkevinnnn）。*

*LaunchNow 选择了 GPL 3 许可证，LaunchNext 与 ZeroLaunch 遵循相同的许可条款。*

## ✨ ZeroLaunch 亮点

ZeroLaunch 在 LaunchNext 基础上持续开发，以下是**本 fork 相对原项目的增强**：

- ⚡ **引擎级性能重构** — 图层树差量更新（只重渲变化的图标，不再全量重建 500+ 图层）；翻页手感在 60Hz / 120Hz 屏幕上完全一致；感知真实缩放比的图标缓存（带上限）；持久化增量写入（一次拖拽 = 一次落盘）
- 🗑️ **长按卸载模式** — iOS 风格抖动模式，安全移入废纸篓，权限多级降级兜底（连 root 属主的 App Store 应用也能移入废纸篓）
- 📁 **悬停自动展开文件夹** — 拖着应用悬停文件夹片刻即自动展开，松手精准落位到文件夹内
- 🧲 **拖边缘翻页 + 边缘提示条** — 拖到屏幕边缘即可翻页并有视觉提示，空白页自动回收不留脏页
- 🎬 **对称的打开/关闭动画** — 打开时面板向中心收拢、关闭时向四周外扩，时长可调
- 🗂️ **LaunchOS 风格文件夹展开** — 文件夹从点击的图标位置放大展开；单击标题即可重命名，输入框会自适应
- ⚙️ **设置页全面重构** — 设置内搜索 + 键盘导航、分区级恢复默认、全屏/窗口作用域切换器、关联设置卡片分组
- 🧹 **死设置清理** — 全量审计移除无效配置项，统一「全屏模式 / 窗口模式」命名，字重数值滑杆、实时内存用量显示、切换性能模式后可一键重启
- 🌍 **14 种语言** — 新增设置项全部完成本地化（简中、繁中、日、韩、英、法、西、德、俄、意、捷、葡、越、印地）
- 🚢 **独立分发体系** — 独立 Bundle ID、`zerolaunch` 命令行、内置自更新、一键发版脚本
- 🛠️ **实打实的 Bug 修复** — macOS 26 桌面壁纸背景（本地化窗口匹配 + 文件级兜底）、设置页偶发失焦、危险操作按钮热区过小等

## 🚀 安装

### 方式一：下载安装包（推荐）
1. 从 [最新 Release](https://github.com/zerojs/zero-launch/releases/latest) 下载 `ZeroLaunch<版本>.zip`
2. 解压，把 `ZeroLaunch.app` 拖入「应用程序」
3. 启动；如被 macOS 拦截，见下方说明

### 方式二：从源码构建
见下方 [从源码构建](#从源码构建)。

> ⚠️ **如果 macOS 阻止应用运行，请在终端执行：**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**原因**：发布为 ad-hoc 签名、暂未公证（未购买苹果开发者账号），Gatekeeper 默认拦截未签名应用。这个命令移除隔离标记让应用正常运行。**仅对信任的应用使用此命令。** 也可以右键 App → **打开** → 确认。

**签名状态**：当前为 **ad-hoc 签名、未公证**。首次启动可能被 Gatekeeper 警告；见上方命令或右键 → 打开。后续购买 Developer ID 后会切换到正式签名 + 公证。从源码构建请见[配置本地签名](#configure-local-code-signing)。

### ZeroLaunch 提供什么

- ✅ **从旧系统 Launchpad 一键导入** — 直接读取原生 Launchpad SQLite 数据库（`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`），完整重建现有的文件夹、应用位置和布局
- ✅ **经典 Launchpad 体验** — 操作方式与深受喜爱的原始界面完全一致
- ✅ **多语言支持** — 完整国际化，支持英文、简体中文、繁体中文、日文、法文、西班牙文、德文、俄文等
- ✅ **隐藏图标标签** — 不需要应用名称时，呈现干净、极简的画面
- ✅ **自定义图标大小** — 依喜好调整图标尺寸
- ✅ **智能文件夹管理** — 如同以往般创建与整理文件夹
- ✅ **模糊搜索与键盘导航** — 即使输入不完整或不精确，也能快速找到应用
- ✅ **CLI / TUI 支持** — 通过 `zerolaunch` 命令在终端检查与操作布局
- ✅ **Hot Corner 与原生手势支持** — 可通过屏幕角落、触控板手势，以及 4 / 5 指选项开启 ZeroLaunch
- ✅ **直接拖曳应用到 Dock** — 在 Next Engine + Core Animation 中可用
- ✅ **Core Animation 文件夹** — 文件夹内容支持分页与垂直滚动布局
- ✅ **更佳的右键菜单** — 在 Finder 中显示、复制应用路径、重命名文件夹，以及已配置的卸载动作
- ✅ **附 Markdown 版本说明的更新标签页** — 更丰富的应用内更新体验
- ✅ **备份、控制器与语音支持改进** — 提升可靠性与辅助使用体验

### macOS Tahoe 拿走了什么

- ❌ 无法自定义应用组织
- ❌ 无法创建用户文件夹
- ❌ 无拖拽定制功能
- ❌ 无可视化应用管理
- ❌ 强制分类分组

### 数据存储

应用数据保存在：
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### 原生 Launchpad 集成

ZeroLaunch 可以直接读取系统 Launchpad 数据库：
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## 从源码构建

### 系统要求

- macOS 26（Tahoe）或更高版本
- Apple Silicon 或 Intel 处理器
- Xcode 26（从源码构建时需要）

### 从源码构建

1. **克隆仓库**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **在 Xcode 中打开**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**配置本地代码签名**
   - 构建或贡献 ZeroLaunch 不需要付费 Apple 开发者账号。
   - 选择 **LaunchNext target**，打开 **Signing & Capabilities**，将 **Team** 设为自己的团队（免费的 Personal Team 也可以），或将 **Team** 设为 `None` 并选择 `Sign to Run Locally` 作为签名证书。
   - 保持 Hardened Runtime 启用。
   - 修改这些本地设置后，Xcode 可能会将项目文件标记为已修改。请不要在 Pull Request 中包含仅涉及签名的更改。

4. **构建并运行**
   - 若要用 `⌘+R` 启动应用，请选择 `My Mac` 作为运行目标——不要选 `Any Mac`。
   - `Any Mac (arm64, x86_64)` 用于通用构建和归档，无法启动应用进行调试。
   - 如果只想构建，请按 `⌘+B`。

### 命令行构建

**常规构建：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**通用二进制构建（Intel + Apple Silicon）：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**发布包（zip + 校验和，ad-hoc 签名）：**
```bash
./scripts/release.sh
```

## 使用方法

### 快速开始

1. **首次启动**：ZeroLaunch 会自动扫描所有已安装的应用
2. **选择**：单击选中应用，双击启动
3. **搜索**：输入文字即时筛选应用
4. **整理**：拖曳应用建立文件夹与自定义布局
5. **自动化**：若需要终端工作流程，请在设置中启用 CLI

### 导入你的 Launchpad

1. 打开设置（齿轮图标）
2. 点击 **「Import Launchpad」**
3. 现有布局与文件夹会自动导入

### 显示模式

- **窗口**：圆角浮动窗口
- **全屏**：全屏模式，视野最大化
- 设置中提供 **Legacy Engine** 与 **Next Engine + Core Animation**
- ZeroLaunch 可为全屏与窗口模式分别保存设置
- 可选择在全屏时隐藏菜单栏；启用时 macOS 也会自动隐藏 Dock

## 高级功能

### 搜索与文件夹体验

- **模糊搜索**：以部分名称、缩写或不精确的输入匹配应用
- **可设置搜索延迟**：在设置中调整搜索的 debounce 时间
- **文件夹布局模式**：在类似 Launchpad 的分页文件夹与垂直滚动文件夹之间选择
- **Core Animation 文件夹渲染**：让大型文件夹的交互更顺滑

### 智能背景交互

- 智能的点击检测，避免误触关闭
- 情境感知的手势处理
- 搜索框保护

### 性能优化

- **图标缓存**：智能的图片缓存，带来顺滑滚动
- **延迟加载**：高效利用内存
- **后台扫描**：不阻塞的应用发现

### 自动化与激活

- **CLI / TUI**：通过 `zerolaunch` 在终端管理 ZeroLaunch
- **Hot Corner**：从可配置的屏幕角落开启 ZeroLaunch
- **实验性原生手势**：4 / 5 指 pinch 与 tap 动作，包括外部触控板设备选择
- **Dock 拖曳**：在 Next Engine + Core Animation 中将应用直接拖入 macOS Dock

### 应用管理

- **右键菜单动作**：在 Finder 中显示应用、复制应用路径、重命名文件夹，以及使用已配置的卸载工具

### 更新与备份工具

- **更新标签页**：在设置中检查更新并阅读 Markdown 版本说明
- **备份工具**：更安全地创建与还原备份
- **通知更新**：支持现代通知 API

### 多显示器支持

- 自动检测屏幕
- 按屏幕分别设置位置
- 无缝的多屏幕工作流程

## 故障排除

### 常见问题

**问：应用无法启动？**  
答：请确认系统为 macOS 26.0 以上并检查系统权限。若应用被 Gatekeeper 拦截，请执行 `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` 或右键 → 打开。

**问：应该使用哪个引擎？**  
答：推荐使用 `Next Engine + Core Animation`。如果你确实需要旧兼容路径，再使用 `Legacy Engine`。

**问：为什么还没有 CLI 命令？**  
答：先在设置中启用命令行接口。ZeroLaunch 可以为你安装和移除托管的 `zerolaunch` shim。

## 贡献

我们欢迎贡献！请：

1. Fork 仓库
2. 创建功能分支（`git checkout -b feature/amazing-feature`）
3. 提交更改（`git commit -m 'Add amazing feature'`）
4. 推送分支（`git push origin feature/amazing-feature`）
5. 打开 Pull Request

### 开发指南

- 遵循 Swift 风格约定
- 为复杂逻辑添加有意义的注释
- 在多个 macOS 版本上测试
- 维持向后兼容性

## 应用管理的未来

随着 Apple 逐渐远离可自定义的界面，ZeroLaunch 代表了一种对用户控制与个性化的坚持。我仍然期待 Apple 把 Launchpad 带回来。

**ZeroLaunch** 不只是 Launchpad 的替代品——它是一种"用户的选择很重要"的宣言。

---

**ZeroLaunch** - 重新掌控你的应用启动器 🚀

*为拒绝在定制化上妥协的 macOS 用户打造。*

## 开发工具

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- 实验性手势支持基于 [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) 及其 [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport) 分支。❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
