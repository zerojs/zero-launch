# ZeroLaunch

**語言**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 下載

**[按此下載](https://github.com/zerojs/zero-launch/releases/latest)** - 取得最新版本

🌐 **網站**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **說明文件**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ 請考慮為 [ZeroLaunch](https://github.com/zerojs/zero-launch) 和原專案 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) 給 star！

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe 移除了 Launchpad，取而代之的介面很難用，甚至連你的 GPU 都沒有充分利用。蘋果，至少給使用者一個切換回去的選項吧。在此之前，這裡是 ZeroLaunch。

*基於 [LaunchNext](https://github.com/RoversX/LaunchNext)（作者 RoversX）開發——非常感謝原專案！❤️ LaunchNext 本身則是基於 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)（作者 ggkevinnnn）。*

*LaunchNow 選擇了 GPL 3 授權條款，LaunchNext 與 ZeroLaunch 遵循相同的授權條款。*

## ✨ ZeroLaunch 亮點

ZeroLaunch 在 LaunchNext 基礎上持續開發，以下是**本 fork 相對原專案的增強**：

- ⚡ **引擎級效能重構** — 圖層樹差量更新（只重新繪製變化的圖示，不再全量重建 500+ 圖層）；翻頁手感在 60Hz / 120Hz 螢幕上完全一致；感知縮放的圖示快取（附上限）；增量持久化（一次拖拽 = 一次寫入磁碟）
- 🗑️ **長按解除安裝模式** — iOS 風格抖動模式，安全移入垃圾桶，權限多級降級備援（就連 root 擁有的 App Store App 也能移入垃圾桶）
- 📁 **懸停自動展開資料夾** — 拖著 App 懸停資料夾片刻即自動展開，放開即可精準放置到資料夾內
- 🧲 **邊緣翻頁與邊緣提示** — 拖到螢幕邊緣即可翻頁並顯示視覺提示條；空白頁會自動回收，不會累積雜亂
- 🎬 **對稱的開啟/關閉動畫** — 開啟時面板向中心縮放、關閉時向外擴展，時長可設定
- 🗂️ **LaunchOS 風格資料夾展開** — 資料夾從點擊的圖示位置放大展開；單擊即可重新命名，輸入框會自適應
- ⚙️ **全面重建的設定** — 設定內搜尋搭配鍵盤導航、分區級重設、全螢幕/視窗作用域切換器、相關選項以卡片分組
- 🧹 **審核並精簡過的選項** — 移除無效設定、統一「全螢幕 / 視窗」命名、字重數值滑桿、即時記憶體用量讀取、切換效能模式後可一鍵重新啟動
- 🌍 **14 種語言** — 每個新增設定項都已完成本地化（en、zh-Hans、zh-Hant、ja、ko、fr、es、de、ru、it、cs、pt-BR、vi、hi）
- 🚢 **獨立發行體系** — 獨立 Bundle ID、`zerolaunch` CLI、內建自動更新、發版腳本
- 🛠️ **真正的錯誤修復** — macOS 26 桌布背景（本地化視窗比對 + 檔案層級備援）、設定頁偶發失去焦點、危險操作按鈕熱區過小等

## 🚀 安裝

### 方式一：下載發布版
1. 從[最新版本](https://github.com/zerojs/zero-launch/releases/latest)下載 `ZeroLaunch<版本>.zip`
2. 解壓縮，把 `ZeroLaunch.app` 拖入「應用程式」
3. 啟動；若被 macOS 封鎖，請見下方說明

### 方式二：從原始碼建置

請見下方[從原始碼建置](#從原始碼建置)。

> ⚠️ **若 macOS 封鎖 App，請在終端機執行：**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**原因**：ZeroLaunch 發布版目前為 ad-hoc 簽章且尚未公證（沒有付費 Apple 開發者會員），因此 macOS 預設會封鎖未簽章 App。此指令會移除隔離標記讓 App 得以執行。**僅對你信任的 App 使用此指令。** 也可以在 App 上按右鍵 → **開啟** → 確認。

**程式碼簽章狀態**：目前發布版為 **ad-hoc 簽章、未公證**。首次啟動時 Gatekeeper 可能會警告；請見上方指令或按右鍵 → 開啟。日後加入付費 Apple 開發者會員後，發布版將改用 Developer ID 簽章 + 公證。從原始碼建置請見[設定本機程式碼簽章](#configure-local-code-signing)。

### ZeroLaunch 提供什麼

- ✅ **從舊系統 Launchpad 一鍵匯入** — 直接讀取原生 Launchpad SQLite 資料庫（`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`），完整重建現有的資料夾、App 位置與佈局
- ✅ **經典 Launchpad 體驗** — 操作方式與深受喜愛的原始介面完全一致
- ✅ **多語言支援** — 完整國際化，支援英文、簡體中文、繁體中文、日文、法文、西班牙文、德文、俄文等
- ✅ **隱藏圖示標籤** — 不需要 App 名稱時，呈現乾淨、極簡的畫面
- ✅ **自訂圖示大小** — 依喜好調整圖示尺寸
- ✅ **智慧資料夾管理** — 如同以往般建立與整理資料夾
- ✅ **模糊搜尋與鍵盤導航** — 即使輸入不完整或不精確，也能快速找到 App
- ✅ **CLI / TUI 支援** — 透過 `zerolaunch` 指令在終端機檢查與操作佈局
- ✅ **Hot Corner 與原生手勢支援** — 可透過畫面角落、觸控板手勢，以及 4 / 5 指選項開啟 ZeroLaunch
- ✅ **直接拖曳 App 到 Dock** — 在 Next Engine + Core Animation 中可用
- ✅ **Core Animation 資料夾** — 資料夾內容支援分頁與垂直捲動佈局
- ✅ **更佳的右鍵選單** — 在 Finder 中顯示、複製 App 路徑、重新命名資料夾，以及已設定的解除安裝動作
- ✅ **附 Markdown 版本說明的更新分頁** — 更豐富的 App 內更新體驗
- ✅ **備份、控制器與語音支援改進** — 提升可靠性與輔助使用體驗

### macOS Tahoe 拿走了什麼
- ❌ 無法自訂 App 組織
- ❌ 無法建立使用者自訂資料夾
- ❌ 無拖曳自訂功能
- ❌ 無視覺化 App 管理
- ❌ 強制分類分組

### 資料儲存
應用資料儲存在：
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### 原生 Launchpad 整合
ZeroLaunch 可以直接讀取系統 Launchpad 資料庫：
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## 從原始碼建置

### 系統需求
- macOS 26（Tahoe）或更新版本
- Apple Silicon 或 Intel 處理器
- Xcode 26（從原始碼建置時需要）

### 從原始碼建置

1. **複製儲存庫**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **在 Xcode 中開啟**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**設定本機程式碼簽章**
   - 建置或貢獻 ZeroLaunch 不需要付費 Apple 開發者會員。
   - 選擇 **LaunchNext target**，開啟 **Signing & Capabilities**，將 **Team** 設為你自己的團隊（免費的 Personal Team 也可以），或將 **Team** 設為 `None` 並選擇 `Sign to Run Locally` 作為簽章憑證。
   - 保持 Hardened Runtime 啟用。
   - 變更這些本機設定後，Xcode 可能會標記專案檔案為已修改。請勿在 Pull Request 中包含僅涉及簽章的變更。

4. **建置並執行**
   - 若要使用 `⌘+R` 啟動 App，請選擇 `My Mac` 作為執行目標——不要選 `Any Mac`。
   - `Any Mac (arm64, x86_64)` 是用於通用建置與封存的，無法啟動 App 進行除錯。
   - 若只想建置，請按 `⌘+B`。

### 命令列建置

**常規建置：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**通用二進位建置（Intel + Apple Silicon）：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**發布包（zip + 校驗和，ad-hoc 簽章）：**
```bash
./scripts/release.sh
```

## 使用方法

### 快速開始
1. **首次啟動**：ZeroLaunch 會自動掃描所有已安裝的 App
2. **選擇**：按一下選取 App，按兩下啟動
3. **搜尋**：輸入文字即時篩選 App
4. **整理**：拖曳 App 建立資料夾與自訂佈局
5. **自動化**：若需要終端機工作流程，請在設定中啟用 CLI

### 匯入你的 Launchpad
1. 開啟設定（齒輪圖示）
2. 點擊 **「Import Launchpad」**
3. 現有佈局與資料夾會自動匯入

### 顯示模式
- **視窗**：圓角浮動視窗
- **全螢幕**：全螢幕模式，視野最大化
- 設定中提供 **Legacy Engine** 與 **Next Engine + Core Animation**
- ZeroLaunch 可為全螢幕與視窗模式分別保存設定
- 可選擇在全螢幕時隱藏選單列；啟用時 macOS 也會自動隱藏 Dock

## 進階功能

### 搜尋與資料夾體驗
- **模糊搜尋**：以部分名稱、縮寫或不精確的輸入比對 App
- **可設定搜尋延遲**：在設定中調整搜尋的 debounce 時間
- **資料夾佈局模式**：在類似 Launchpad 的分頁資料夾與垂直捲動資料夾之間選擇
- **Core Animation 資料夾渲染**：讓大型資料夾的互動更滑順

### 智慧背景互動
- 智慧的點擊偵測，避免誤觸關閉
- 情境感知的手勢處理
- 搜尋欄位保護

### 效能最佳化
- **圖示快取**：智慧的圖片快取，帶來滑順捲動
- **延遲載入**：有效運用記憶體
- **背景掃描**：不阻塞的 App 探索

### 自動化與啟用
- **CLI / TUI**：透過 `zerolaunch` 在終端機管理 ZeroLaunch
- **Hot Corner**：從可設定的畫面角落開啟 ZeroLaunch
- **實驗性原生手勢**：4 / 5 指 pinch 與 tap 動作，包括外部觸控板裝置選擇
- **Dock 拖曳**：在 Next Engine + Core Animation 中將 App 直接拖入 macOS Dock

### App 管理
- **右鍵選單動作**：在 Finder 中顯示 App、複製 App 路徑、重新命名資料夾，以及使用已設定的解除安裝工具

### 更新與備份工具
- **更新分頁**：在設定中檢查更新並閱讀 Markdown 版本說明
- **備份工具**：更安全地建立與還原備份
- **通知更新**：支援現代通知 API

### 多螢幕支援
- 自動偵測螢幕
- 依螢幕個別設定位置
- 無縫的多螢幕工作流程

## 故障排除

### 常見問題

**問：App 無法啟動？**  
答：請確認系統為 macOS 26.0 以上並檢查系統權限。若 App 被 Gatekeeper 封鎖，請執行 `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` 或按右鍵 → 開啟。

**問：應該使用哪個引擎？**  
答：建議使用 `Next Engine + Core Animation` 以獲得最佳體驗。若需要舊相容路徑，`Legacy Engine` 仍然可用。

**問：為什麼 CLI 指令還不存在？**  
答：請先在設定中啟用命令列介面。ZeroLaunch 可以為你安裝與移除受管理的 `zerolaunch` 指令。

## 貢獻

我們歡迎貢獻！請：

1. Fork 儲存庫
2. 建立功能分支（`git checkout -b feature/amazing-feature`）
3. 提交變更（`git commit -m 'Add amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 開啟 Pull Request

### 開發指南
- 遵循 Swift 風格約定
- 為複雜邏輯加入有意義的註解
- 在多個 macOS 版本上測試
- 維持向後相容性

## App 管理的未來

隨著 Apple 逐漸遠離可自訂的介面，ZeroLaunch 代表了一種對使用者控制與個人化的堅持。我仍然期待 Apple 把 Launchpad 帶回來。

**ZeroLaunch** 不只是 Launchpad 的替代品——它是一種「使用者的選擇很重要」的宣言。

---

**ZeroLaunch** - 重新掌控你的 App 啟動器 🚀

*為拒絕在自訂化上妥協的 macOS 使用者打造。*

## 開發工具

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- 實驗性手勢支援基於 [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) 及其 [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport) 分支。❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
