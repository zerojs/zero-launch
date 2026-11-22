# ZeroLaunch

**Languages**: [English](README.md) | [简体中文](i18n/README.zh.md) | [繁體中文](i18n/README.zh-TW.md) | [日本語](i18n/README.ja.md) | [한국어](i18n/README.ko.md) | [Français](i18n/README.fr.md) | [Español](i18n/README.es.md) | [Deutsch](i18n/README.de.md) | [Русский](i18n/README.ru.md) | [हिन्दी](i18n/README.hi.md) | [Tiếng Việt](i18n/README.vi.md) | [Italiano](i18n/README.it.md) | [Čeština](i18n/README.cs.md)

## 📥 Download

**[Download here](https://github.com/zerojs/zero-launch/releases/latest)** - Get the latest release

🌐 **Website**: [www.zerojs.cn](https://www.zerojs.cn)

| | |
|:---:|:---:|
| ![](./public/banner.webp) | ![](./public/setting1.webp) |
| ![](./public/setting2.webp) | ![](./public/setting3.webp) |

macOS Tahoe removed Launchpad, and the replacement is painful to use — it doesn't even take advantage of your GPU. Apple, please at least give people an option to switch back. Until then, here's ZeroLaunch.

*Built upon [LaunchNext](https://github.com/RoversX/LaunchNext) by RoversX — huge thanks to the original project!❤️ LaunchNext itself is based on [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) by ggkevinnnn.*

*LaunchNow chose the GPL 3 license. LaunchNext and ZeroLaunch follow the same licensing terms.*

## ✨ ZeroLaunch Highlights

ZeroLaunch is actively developed on top of LaunchNext. Here is what **this fork adds** beyond the original:

- ⚡ **Engine-level performance overhaul** — layer-tree diffing re-renders only the icons that changed instead of rebuilding 500+ layers; page scrolling feels identical on 60Hz and 120Hz displays; scale-aware icon caching with a bounded cache; incremental persistence (one drag = one disk write)
- 🗑️ **Long-press uninstall mode** — iOS-style jiggle mode with a safe trash flow and multi-level permission fallbacks (even root-owned App Store apps can be trashed)
- 📁 **Hover-to-open folders** — hold an app over a folder and it auto-expands after a moment; drop inside to place the app exactly where you want
- 🧲 **Edge page-flip with edge hints** — drag apps to the screen edge to flip pages with a visual hint bar; blank pages are recycled so clutter never builds up
- 🎬 **Symmetric open/close animations** — the panel zooms toward center on open and expands outward on close, with a configurable duration
- 🗂️ **LaunchOS-style folder expansion** — folders grow out of the icon you clicked; one-click rename with an adaptive input box
- ⚙️ **Fully rebuilt Settings** — in-settings search with keyboard navigation, per-section reset, a Fullscreen/Window scope switcher, and related options grouped into cards
- 🧹 **Audited, decluttered options** — dead settings removed, unified Fullscreen/Window naming, numeric font-weight slider, live memory usage readout, restart-now shortcut after switching performance mode
- 🌍 **14 languages** — every new setting ships localized (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Independent distribution** — own bundle ID, `zerolaunch` CLI, built-in self-updater, and release scripts
- 🛠️ **Real bug fixes** — macOS 26 wallpaper background (localized window matching + file-level fallback), settings sheet losing focus, undersized hit areas on destructive buttons, and more

## 🚀 Installation

### Option 1 — Download the release
1. Grab `ZeroLaunch<version>.zip` from the [latest release](https://github.com/zerojs/zero-launch/releases/latest)
2. Unzip and drag `ZeroLaunch.app` into `/Applications`
3. Launch it — if macOS blocks the app, see the note below

### Option 2 — Build from source

See [Build from Source](#build-from-source) below.

> ⚠️ **If macOS blocks the app, run this in Terminal:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Why**: ZeroLaunch releases are ad-hoc signed and not notarized yet (no paid Apple Developer membership), so macOS blocks unsigned apps by default. This command removes the quarantine flag to let it run. **Only use this command on apps you trust.** You can also right-click the app → **Open** → confirm.

**Code Signing Status**: releases are currently **ad-hoc signed, not notarized**. Gatekeeper may warn on first launch; see the command above or use right-click → Open. When a paid Apple Developer membership is added later, releases will move to Developer ID signing + notarization. Building from source? See [Configure local code signing](#configure-local-code-signing).

### What ZeroLaunch Delivers
- ✅ **One-click import from old system Launchpad** - directly reads your native Launchpad SQLite database (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) to perfectly recreate your existing folders, app positions, and layout
- ✅ **Classic Launchpad experience** - works exactly like the beloved original interface
- ✅ **Multi-language support** - full internationalization with English, Simplified Chinese, Traditional Chinese, Japanese, French, Spanish, German, Russian, and more
- ✅ **Hide icon labels** - clean, minimalist view when you don't need app names
- ✅ **Custom icon sizes** - adjust icon dimensions to fit your preferences
- ✅ **Smart folder management** - create and organize folders just like before
- ✅ **Fuzzy search and keyboard navigation** - find apps quickly, even with partial or imperfect input
- ✅ **CLI / TUI support** - inspect and operate your layout from the terminal with the `zerolaunch` command
- ✅ **Hot Corner and native gesture support** - open ZeroLaunch with corners, trackpad gestures, and 4 / 5 finger options
- ✅ **Drag apps directly to the Dock** - available in Next Engine + Core Animation
- ✅ **Core Animation folders** - folder content supports paged and vertical scroll layouts
- ✅ **Better context menus** - Show in Finder, Copy App Path, Rename Folder, and configured uninstall actions
- ✅ **Update tab with Markdown release notes** - richer in-app update experience
- ✅ **Backup, controller, and voice support improvements** - better reliability and accessibility

### What We Lost in macOS Tahoe
- ❌ No custom app organization
- ❌ No user-created folders
- ❌ No drag-and-drop customization
- ❌ No visual app management
- ❌ Forced categorical grouping


### Data Storage
Application data is safely stored in:
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### Native Launchpad Integration
Reads directly from the system Launchpad database:
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Building from Source

### Requirements
- macOS 26 (Tahoe) or later
- Apple Silicon or Intel processor
- Xcode 26 (for building from source)

### Build from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Open in Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Configure local code signing**
   - A paid Apple Developer membership is not required to build or contribute to ZeroLaunch.
   - Select the **LaunchNext target**, open **Signing & Capabilities**, set **Team** to your own team (a free Personal Team works), or set **Team** to `None` and select `Sign to Run Locally` as the signing certificate.
   - Keep Hardened Runtime enabled.
   - Xcode may mark the project file as modified after changing these local settings. Do not include signing-only changes in a pull request.

4. **Build and run**
   - To launch the app with `⌘+R`, select `My Mac` as the run destination—not `Any Mac`.
   - `Any Mac (arm64, x86_64)` is intended for generic builds and archives; it cannot launch the app for debugging.
   - Press `⌘+B` if you only want to build.

### Command Line Build

**Regular Build:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Universal Binary Build (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Release package (zip + checksums, ad-hoc signed):**
```bash
./scripts/release.sh
```

## Usage

### Getting Started
1. **First Launch**: ZeroLaunch automatically scans all installed applications
2. **Select**: Click to select apps, double-click to launch
3. **Search**: Type to instantly filter applications
4. **Organize**: Drag apps to create folders and custom layouts
5. **Automate**: Enable CLI in Settings if you want terminal workflows

### Import Your Launchpad
1. Open Settings (gear icon)
2. Click **"Import Launchpad"**
3. Your existing layout and folders are automatically imported


### Display Modes
- **Window**: Floating window with rounded corners
- **Fullscreen**: Full-screen mode for maximum visibility
- **Legacy Engine** and **Next Engine + Core Animation** are available in Settings
- ZeroLaunch can keep separate settings for fullscreen and window mode
- Optional fullscreen menu bar hiding is available; macOS also hides the Dock when this is enabled

## Advanced Features

### Search and Folder Experience
- **Fuzzy Search**: Match apps with partial names, abbreviations, and imperfect input
- **Configurable Search Delay**: Tune search debounce timing in Settings
- **Folder Layout Modes**: Choose between Launchpad-like paged folders and vertical scrolling folders
- **Core Animation Folder Rendering**: Smoother folder interaction for larger folders

### Smart Background Interaction
- Intelligent click detection prevents accidental dismissal
- Context-aware gesture handling
- Search field protection

### Performance Optimization
- **Icon Caching**: Intelligent image caching for smooth scrolling
- **Lazy Loading**: Efficient memory usage
- **Background Scanning**: Non-blocking app discovery

### Automation and Activation
- **CLI / TUI**: Manage ZeroLaunch from the terminal with `zerolaunch`
- **Hot Corner**: Open ZeroLaunch from a configurable screen corner
- **Experimental native gestures**: 4 / 5 finger pinch and tap actions, including external trackpad device selection
- **Dock drag**: Drag apps directly into the macOS Dock in Next Engine + Core Animation

### App Management
- **Context menu actions**: Show apps in Finder, copy app paths, rename folders, and use a configured uninstall tool

### Update and Backup Tools
- **Update tab**: Check for updates and read Markdown release notes inside Settings
- **Backup tools**: Create and restore backups more safely
- **Notification update**: Modern notification API support

### Multi-Display Support
- Automatic screen detection
- Per-display positioning
- Seamless multi-monitor workflows

## Troubleshooting

### Common Issues

**Q: App won't start?**
A: Ensure macOS 26.0+ and check system permissions. If the app is blocked by Gatekeeper, run `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` or right-click → Open.

**Q: Which engine should I use?**
A: `Next Engine + Core Animation` is recommended for the best experience. `Legacy Engine` is still available if you need the older compatibility path.

**Q: Why doesn't the CLI command exist yet?**
A: Enable the command line interface in Settings first. ZeroLaunch can install and remove the managed `zerolaunch` command for you.

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Swift style conventions
- Add meaningful comments for complex logic
- Test on multiple macOS versions
- Maintain backward compatibility

## The Future of App Management

As Apple moves away from customizable interfaces, ZeroLaunch represents a push toward user control and personalization. I still hope Apple brings Launchpad back.

**ZeroLaunch** isn't just a Launchpad replacement—it's a statement that user choice matters.


---

**ZeroLaunch** - Reclaim Your App Launcher 🚀

*Built for macOS users who refuse to compromise on customization.*

## Development Tools

- Claude Code 
- Cursor 
- OpenAI Codex CLI
- Perplexity
- Google



- Experimental gesture support is built on [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) and the fork by [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️


![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
