# ZeroLaunch

**言語**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 ダウンロード

**[こちらからダウンロード](https://github.com/zerojs/zero-launch/releases/latest)** - 最新版を入手

🌐 **公式サイト**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **ドキュメント**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ [ZeroLaunch](https://github.com/zerojs/zero-launch) と元プロジェクト [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) へのスターをお願いします！

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe は Launchpad を削除しましたが、代わりとなるインターフェースは使いにくく、GPU も十分に活用できません。Apple よ、せめて元に戻すオプションを提供してください。それまでは、ZeroLaunch があります。

*[LaunchNext](https://github.com/RoversX/LaunchNext)（RoversX 氏）をベースに開発しました。原プロジェクトに心から感謝します！❤️ LaunchNext 自体は [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)（ggkevinnnn 氏）をベースにしています。*

*LaunchNow は GPL 3 ライセンスを選択しました。LaunchNext と ZeroLaunch も同じライセンス条件に従います。*

## ✨ ZeroLaunch のハイライト

ZeroLaunch は LaunchNext 上で活発に開発されています。以下は**この fork が元プロジェクトに追加したもの**です：

- ⚡ **エンジンレベルのパフォーマンス刷新** — レイヤーツリーの差分更新で、変化したアイコンだけを再描画（500 以上のレイヤーを全再構築しない）；ページスクロールの感触は 60Hz / 120Hz ディスプレイで同一；スケールを考慮したアイコンキャッシュ（上限付き）；増分永続化（1 回のドラッグ = 1 回のディスク書き込み）
- 🗑️ **長押しアンインストールモード** — iOS 風の揺れモード、安全なゴミ箱移動、多段階の権限フォールバック（root 所有の App Store アプリもゴミ箱へ移せます）
- 📁 **ホバーでフォルダを開く** — アプリをフォルダの上にかざすと少し待って自動展開；ドロップで目的の位置に正確に配置
- 🧲 **画面端フリップとエッジヒント** — アプリを画面端にドラッグするとヒントバー付きでページが切り替わり、空ページは再利用されるのでゴミが溜まりません
- 🎬 **対称的な開閉アニメーション** — 開くときは中央へズーム、閉じるときは外側へ拡大し、時間を設定可能
- 🗂️ **LaunchOS 風のフォルダ展開** — クリックしたアイコンの位置からフォルダが拡大；アダプティブな入力欄でワンクリック改名
- ⚙️ **設定画面を完全再構築** — 設定内検索とキーボードナビゲーション、セクション単位のリセット、全画面/ウィンドウのスコープ切り替え、関連オプションをカードにグループ化
- 🧹 **監査・整理されたオプション** — 死に設定を削除、全画面/ウィンドウの命名を統一、数値フォントウェイトスライダー、リアルタイムメモリ使用量表示、パフォーマンスモード切替後の即時再起動ショートカット
- 🌍 **14 言語** — 新しい設定項目はすべてローカライズ（en、zh-Hans、zh-Hant、ja、ko、fr、es、de、ru、it、cs、pt-BR、vi、hi）
- 🚢 **独立した配布** — 独自の Bundle ID、`zerolaunch` CLI、内蔵セルフアップデーター、リリーススクリプト
- 🛠️ **実際のバグ修正** — macOS 26 の壁紙背景（ローカライズされたウィンドウ照合 + ファイル単位のフォールバック）、設定シートのフォーカス喪失、危険なボタンのヒット領域が小さい問題など

## 🚀 インストール

### オプション 1 — リリースをダウンロード
1. [最新リリース](https://github.com/zerojs/zero-launch/releases/latest)から `ZeroLaunch<バージョン>.zip` を入手
2. 解凍し、`ZeroLaunch.app` を `/Applications` にドラッグ
3. 起動する — macOS にブロックされた場合は下記を参照

### オプション 2 — ソースからビルド

下記の[ソースからビルド](#ソースからビルド)を参照してください。

> ⚠️ **macOS がアプリをブロックする場合、ターミナルで実行してください：**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**理由**：ZeroLaunch のリリースは ad-hoc 署名であり、まだ公証されていません（有料の Apple Developer 会員ではないため）。そのため macOS は既定で未署名アプリをブロックします。このコマンドは隔離フラグを削除して実行を許可します。**信頼できるアプリにのみ使用してください。** アプリを右クリック → **開く** → 確認でも構いません。

**コード署名の状態**：現在のリリースは **ad-hoc 署名・未公証**です。初回起動時に Gatekeeper が警告する場合があります。上記のコマンドまたは右クリック → 開くを使用してください。将来的に有料の Apple Developer 会員を追加したら、Developer ID 署名 + 公証に移行します。ソースからビルドする場合は[ローカルコード署名の設定](#configure-local-code-signing)を参照してください。

### ZeroLaunch が提供するもの

- ✅ **旧システム Launchpad からのワンクリックインポート** — ネイティブ Launchpad の SQLite データベース（`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`）を直接読み取り、既存のフォルダ、アプリ位置、レイアウトを完全に再現
- ✅ **クラシックな Launchpad 体験** — 愛されていた元のインターフェースとまったく同じ操作感
- ✅ **多言語対応** — 英語、簡体字中国語、繁体字中国語、日本語、フランス語、スペイン語、ドイツ語、ロシア語など、完全な国際化
- ✅ **アイコンラベルの非表示** — アプリ名が不要なときはすっきりしたミニマル表示
- ✅ **カスタムアイコンサイズ** — 好みに合わせてアイコンの大きさを調整
- ✅ **スマートなフォルダ管理** — これまでどおりフォルダを作成・整理
- ✅ **あいまい検索とキーボードナビゲーション** — 一部や不正確な入力でもアプリをすばやく検索
- ✅ **CLI / TUI 対応** — `zerolaunch` コマンドでターミナルからレイアウトを確認・操作
- ✅ **Hot Corner とネイティブジェスチャー対応** — 画面コーナー、トラックパッドジェスチャー、4 / 5 指オプションで起動
- ✅ **アプリを Dock に直接ドラッグ** — Next Engine + Core Animation で利用可能
- ✅ **Core Animation フォルダ** — フォルダ内容がページ送りと縦スクロールのレイアウトに対応
- ✅ **より良いコンテキストメニュー** — Finder で表示、App パスをコピー、フォルダ名変更、設定済みのアンインストール操作
- ✅ **Markdown リリースノート付き更新タブ** — より充実したアプリ内更新体験
- ✅ **バックアップ、コントローラー、音声サポートの改善** — 信頼性とアクセシビリティの向上

### macOS Tahoe が失わせたもの
- ❌ カスタムのアプリ整理が不可
- ❌ ユーザー作成フォルダが不可
- ❌ ドラッグ＆ドロップでのカスタマイズが不可
- ❌ 視覚的なアプリ管理が不可
- ❌ 強制的なカテゴリグループ化

### データ保存
アプリデータは以下に保存されます：
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### ネイティブ Launchpad 統合
ZeroLaunch はシステム Launchpad データベースを直接読み取れます：
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## ソースからビルド

### 必要条件
- macOS 26（Tahoe）以降
- Apple Silicon または Intel プロセッサ
- Xcode 26（ソースからビルドする場合）

### ソースからビルド

1. **リポジトリをクローン**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Xcode で開く**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**ローカルコード署名を設定**
   - ZeroLaunch のビルドやコントリビューションに有料の Apple Developer 会員は不要です。
   - **LaunchNext ターゲット**を選択し、**Signing & Capabilities** を開き、**Team** に自分のチーム（無料の Personal Team でも可）を設定するか、**Team** を `None` にして署名証明書に `Sign to Run Locally` を選択してください。
   - Hardened Runtime は有効なままにしてください。
   - これらのローカル設定を変更すると、Xcode がプロジェクトファイルを変更済みとマークする場合があります。署名のみの変更を Pull Request に含めないでください。

4. **ビルドして実行**
   - `⌘+R` で起動するには、実行先に `My Mac` を選択してください（`Any Mac` ではありません）。
   - `Any Mac (arm64, x86_64)` は汎用ビルドやアーカイブ用で、デバッグのためのアプリ起動はできません。
   - ビルドのみの場合は `⌘+B` を押してください。

### コマンドラインビルド

**通常ビルド：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**ユニバーサルバイナリビルド（Intel + Apple Silicon）：**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**リリースパッケージ（zip + チェックサム、ad-hoc 署名）：**
```bash
./scripts/release.sh
```

## 使い方

### はじめに
1. **初回起動**：ZeroLaunch がインストール済みアプリを自動スキャンします
2. **選択**：クリックで選択、ダブルクリックで起動
3. **検索**：入力すると即座にアプリを絞り込みます
4. **整理**：アプリをドラッグしてフォルダやカスタムレイアウトを作成
5. **自動化**：ターミナルワークフローを使う場合は設定で CLI を有効にしてください

### Launchpad をインポート
1. 設定（歯車アイコン）を開く
2. **「Import Launchpad」** をクリック
3. 既存のレイアウトとフォルダが自動でインポートされます

### 表示モード
- **ウィンドウ**：角丸のフローティングウィンドウ
- **全画面**：視野を最大化する全画面モード
- 設定で **Legacy Engine** と **Next Engine + Core Animation** を切り替え可能
- ZeroLaunch は全画面モードとウィンドウモードで別々の設定を保持できます
- 全画面時のメニューバー非表示も選択可能；有効にすると macOS は Dock も非表示にします

## 高度な機能

### 検索とフォルダの操作
- **あいまい検索**：部分名、略称、不正確な入力でアプリを検索
- **検索遅延の設定**：設定で検索の debounce 時間を調整可能
- **フォルダレイアウトモード**：Launchpad 風のページ送りフォルダと縦スクロールフォルダから選択
- **Core Animation フォルダ描画**：大きなフォルダでも滑らかに操作

### スマートな背景操作
- 誤操作による閉じを防ぐインテリジェントなクリック検出
- 状況に応じたジェスチャー処理
- 検索フィールドの保護

### パフォーマンス最適化
- **アイコンキャッシュ**：滑らかなスクロールのためのインテリジェントな画像キャッシュ
- **遅延読み込み**：メモリを効率的に使用
- **バックグラウンドスキャン**：ブロックしないアプリ探索

### 自動化と起動
- **CLI / TUI**：`zerolaunch` でターミナルから ZeroLaunch を管理
- **Hot Corner**：設定した画面コーナーから ZeroLaunch を起動
- **実験的なネイティブジェスチャー**：4 / 5 指の pinch / tap（外部トラックパッドの選択にも対応）
- **Dock ドラッグ**：Next Engine + Core Animation でアプリを macOS Dock へ直接ドラッグ

### アプリ管理
- **コンテキストメニュー操作**：Finder で表示、App パスをコピー、フォルダ名変更、設定済みのアンインストールツールを使用

### 更新とバックアップツール
- **更新タブ**：設定内で更新を確認し、Markdown のリリースノートを読む
- **バックアップツール**：より安全なバックアップ作成と復元
- **通知の更新**：モダンな通知 API に対応

### マルチディスプレイ対応
- 画面を自動検出
- ディスプレイごとの位置設定
- シームレスなマルチモニター工作流

## トラブルシューティング

### よくある質問

**Q: アプリが起動しない？**  
A: macOS 26.0 以降であることと、システム権限を確認してください。Gatekeeper にブロックされた場合は `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` を実行するか、右クリック → 開くを使用してください。

**Q: どのエンジンを使うべき？**  
A: 最適な体験のため `Next Engine + Core Animation` を推奨します。古い互換パスが必要な場合は `Legacy Engine` も利用できます。

**Q: CLI コマンドがまだないのはなぜ？**  
A: まず設定でコマンドラインインターフェースを有効にしてください。ZeroLaunch が管理対象の `zerolaunch` コマンドをインストール・削除できます。

## コントリビューション

コントリビューションを歓迎します。以下をお願いします：

1. リポジトリを Fork
2. 機能ブランチを作成（`git checkout -b feature/amazing-feature`）
3. 変更をコミット（`git commit -m 'Add amazing feature'`）
4. ブランチに Push（`git push origin feature/amazing-feature`）
5. Pull Request を作成

### 開発ガイドライン
- Swift のスタイル規約に従う
- 複雑なロジックには意味のあるコメントを追加する
- 複数の macOS バージョンでテストする
- 後方互換性を維持する

## アプリ管理の未来

Apple がカスタマイズ可能なインターフェースから離れていく中で、ZeroLaunch はユーザーによる制御とパーソナライゼーションへの取り組みです。Apple が Launchpad を復活させてくれることを今も願っています。

**ZeroLaunch** は単なる Launchpad の代替ではありません——ユーザーの選択が重要だという主張です。

---

**ZeroLaunch** - アプリランチャーの主導権を取り戻す 🚀

*カスタマイズを妥協したくない macOS ユーザーのために。*

## 開発ツール

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- 実験的ジェスチャー機能は [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) と [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport) の fork をベースにしています。❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
