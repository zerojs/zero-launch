# 本地修改记录(CHANGELOG-LOCAL)

> 本文件记录基于上游 2.4.1 源码(commit `f8864a4` 附近)进行的本地优化与修复。
> 所有改动均未提交,可通过 `git diff` 审阅、`git checkout -- <file>` 回退单个文件。
> 本地构建版本已部署至 `/Applications/LaunchNext.app`(ad-hoc 签名)。

---

## 一、性能优化

### 1. 翻页动画与帧率解耦(P0)
- **问题**:页面滚动动画用"每帧固定收敛 18%"的逐帧积分,动画时长随屏幕帧率变化(60Hz 比 120Hz 慢一倍);CADisplayLink 常驻注册,空闲时每帧唤醒主线程。
- **修改**(`CAGridView.swift`、`CAFolderGridView.swift`):
  - 改为基于时间增量的指数收敛,速率 `23.8/s`(与 120Hz 下旧手感一致),任何帧率下动画时长一致;
  - displayLink 空闲时自动 `isPaused`,滚动/翻页/拖拽入口处恢复(`resumeDisplayLink()`);
  - 帧间隔 `animationDelta` 钳制在 `[1/240s, 0.1s]`,防止异常跳变。

### 2. 图标渲染管线修正(P0)
- **问题**:图标位图下采样硬编码 `iconSize × 2`,不看窗口真实后备缩放(高分屏发糊、1x 屏浪费 4 倍内存);`contentsScale` 用 `NSScreen.main` 而非窗口所在屏,多显示器下错配;图标缓存字典无上限,长跑内存增长。
- **修改**(`CAGridView+Layout.swift`、`CAGridView.swift`):
  - 新增 `iconBackingScale`(优先 `window?.backingScaleFactor`),下采样与全部 `contentsScale`/`rasterizationScale` 统一使用;
  - 图标缓存键加入 scale(`path#scale`),换屏后自动重渲;
  - 缓存加 400 条上限,超限整体清空(有锁保护)。

### 3. 图层树差量更新(P0)
- **问题**:`items` 每次赋值(拖拽、搜索过滤、刷新)都触发 `rebuildLayers()` 全量重建——移除全部 CALayer 再逐页重建(单页约 150-200 层,5 页满配 500-700 层),主线程同步执行。
- **修改**(`CAGridView.swift`、`CAGridView+Layout.swift`):
  - `items` didSet 改走新增的 `reconcileLayers(previous:)`:按 (页, 槽位) 对比身份 key(含应用路径/显示名/文件夹 id+成员/缺失占位/空槽统一身份),未变化的槽位**复用现有 CALayer**,变化的槽位单独替换;
  - 页数变化或首次构建时自动回退全量 `rebuildLayers()`;
  - 完全无变化时直接返回,不触发布局。

### 4. 文件夹预览缓存精确失效(P0)
- **问题**:`triggerFolderUpdate()` 每次清空整个 `FolderPreviewCache`,任何文件夹变动后所有可见文件夹都在下一帧主线程重渲 3×3 拼贴;而缓存 key 本就含成员路径内容 hash,全清是浪费。
- **修改**(`AppStore.swift`):
  - `triggerFolderUpdate(clearsPreviewCache:)` 增加参数,默认保持旧行为;
  - 8 处纯文件夹内容操作(建/删/改名/重排/增删成员/固定快捷启动等)传 `false`,靠内容 hash 自然失效;
  - 合并标志(`pendingFolderPreviewCacheClear`)保证"已排队但未清空"的调度不丢失效请求。

### 5. 拖拽交互单轮化(P1)
- **问题**:同页拖拽一次 = items 赋值 → 0.1s 后 compact 再赋值(两轮重渲)→ 显式保存 + 0.6s 后防抖再保存(两次全量重写)。
- **修改**(`LaunchpadView.swift`、`AppStore.swift`):
  - 新增纯函数 `precompactedItems(_:)`,赋值前完成页内压缩,单次赋值、单次保存;
  - 新增 `skipNextDebouncedSave` 抑制冗余防抖保存,并配 `itemsRevision` 版本号守卫:显式保存后 items 又有变化时,防抖保存照常执行(防止丢数据)。

### 6. 持久化增量 upsert(P1)
- **问题**:`saveAllOrder()` 全量重写:2 次全量 fetch + 全删 + 全插 + 2 次 commit,约 30 个调用点,一次拖拽至少执行 2 次;每次还额外清理旧版 TopItemData 表。
- **修改**(`AppStore.swift`):
  - 按 `slotId` 建索引,命中行**原地更新字段**,未命中插入,消失的槽位删除,单次 commit;
  - 旧表清理改为会话内仅首次执行(`didCleanLegacyTopItems`)。

### 7. 启动路径去 O(n²)(P2)
- **问题**:`loadOrderFromPageEntries` 对每条持久化记录线性扫描 `apps` 数组(整体 O(rows × apps)),全部发生在主线程。
- **修改**(`AppStore.swift`):启动时预建 `[String: AppInfo]` 路径字典,三处查找改 O(1)。

---

## 二、Bug 修复

### 1. 桌面壁纸背景无效(macOS 26)
- **问题**:开启"背景图片 → 桌面壁纸"没有任何效果。根因:壁纸窗口探测用 `kCGWindowOwnerName` 匹配英文名 `"WindowManager"`/`"Dock"`,而 macOS 26 中文系统返回**本地化名称"程序坞"**,且窗口名格式变为 `Wallpaper-<UUID>`——匹配永不成功,静默失败。
- **修改**(`BackgroundImageController.swift`):
  - 匹配逻辑放弃 owner 判断(本地化不可靠),改为**窗口名前缀 `wallpaper` + 覆盖屏幕面积 ≥50%** 双条件;
  - 新增**权限无关的文件级回退** `refreshDesktopFromFile(...)`:窗口截取失败(如未授予屏幕录制)时,用 `NSWorkspace.desktopImageURL(for:)` 直接读取壁纸文件解码,双保险;
  - 新增统一日志(`log show --predicate 'eventMessage CONTAINS "LaunchNext Background"'`)便于诊断。

### 2. 点击空白区域关闭面板
- **需求**:网格间隙可关闭,但网格视图边界之外的空白(页码指示条周围、四周边缘)点击无响应。
- **实现与回归**(`LaunchpadView.swift`、`BackgroundImageController.swift`):
  - 第一版用 SwiftUI 根容器 `onTapGesture`——引入回归:NSViewRepresentable(网格)不向 SwiftUI 手势声明"已消费",点图标时关闭动作同时触发(点文件夹表现为"打开即关闭");
  - 最终方案:新增 `BlankAreaClickCatcher`(垫在 ZStack 底部的 NSView),利用 AppKit 命中测试"最上层视图优先":网格/搜索框/按钮/页点各自消费点击,纯空白区域落到捕获器关闭;含 5pt 位移阈值,拖拽不误判。

---

## 三、新功能

### 图标文字颜色配置
- 位置:设置 → 外观 → "标签字体大小"滑条下方,新增"图标文字颜色"行。
- **"跟随系统深浅色"** 勾选框(默认开,深色白字/浅色黑字);取消勾选出现系统取色器,任意颜色实时生效。
- 存储为 `iconLabelColorHex`(#RRGGBB,空 = 跟随系统),重启保留。
- 生效范围:CA 主网格、文件夹内网格、旧 SwiftUI 引擎(`LaunchpadItemButton`)三处渲染路径。
- 相关代码:`AppStore.iconLabelColorHex`、`LaunchNextParseHexColor/LaunchNextLabelColor`(共用解析)、两个 Representable 桥接、`SettingsView.appearanceQuaternarySection`。
- 本地化:中文/英文完整,其余语言回落英文。

> 注:文字**大小**(9-16pt,支持全屏/紧凑双模式独立作用域)与**字重**为上游已有功能,位于同一设置区。

### 文件夹展开体验(LaunchOS 风格)
- **锚点展开动画**(`Animations.swift`、`CAGridViewRepresentable.swift`、`LaunchpadView.swift`):点击文件夹图标时,面板从**图标所在位置**缩放展开(0.35 → 1 + 淡入,spring 驱动),关闭时缩回图标处;键盘打开时以中心点为锚点。实现:`onOpenFolder` 回调带出图标中心(窗口坐标),换算为文件夹视图内的归一化 `UnitPoint`,经自定义 `AnyTransition.modifier` 应用。
- **文件夹名称移到展开框之外**(`FolderView.swift`):标题从玻璃面板内部顶部移到面板上方,网格不再为标题预留空间(`verticalHeaderHeight: 0`),纵向滚动模式下的标题随内容滚动/淡出逻辑一并移除。
- **单击标题重命名**(`FolderView.swift`):原为双击进入编辑,现单击标题即可改名(回车或点击框内提交)。

---

## 四、本次会话配套的数据迁移工具(未纳入仓库)

- **LaunchOS → LaunchNext 布局迁移**:通过应用内建 CLI IPC(`~/Library/Caches/LaunchNext/cli.sock`,需临时开启设置 → 开发 → Command line interface)驱动 `create-folder`/`move` 命令完成,复用应用自身持久化路径,布局含文件夹成员顺序完整迁移并校验通过。
- **Launchpad 旧版 schema 合成器**:将 LaunchOS 数据转为 `apps/groups/items` 三表结构,可经设置 → 开发 → "导入 Legacy (.lmy)" 导入。
- 脚本位于 `/tmp/launchnext-convert/`(重启后丢失,如需保留请自行归档)。

---

## 五、本地构建方法

本机无 Xcode 团队证书,使用 ad-hoc 签名构建:

```bash
# 1. 预构建更新器(构建脚本要求二进制已存在)
cd UpdaterScripts/SwiftUpdater
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift build --configuration release --product SwiftUpdater

# 2. 构建 Release(绕过 xcode-select 全局设置 + 本地签名)
cd ../..
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext \
  -configuration Release -destination 'platform=macOS,arch=arm64' \
  DEVELOPMENT_TEAM= CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual build

# 3. 部署(产物在 DerivedData/LaunchNext-*/Build/Products/Release/)
#    单元测试:
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild test -project LaunchNext.xcodeproj -scheme LaunchNext \
  -destination 'platform=macOS,arch=arm64' \
  DEVELOPMENT_TEAM= CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual
```

---

## 六、验证记录

| 项目 | 结果 |
|---|---|
| Debug/Release 编译 | BUILD SUCCEEDED |
| 单元测试 | 11/11 通过 |
| 布局完整性(迁移后) | 24 槽位 + 8 文件夹逐槽位校验通过 |
| 持久化 round-trip | 重启后布局一致(增量 upsert 读写正常) |
| 壁纸背景 | 窗口匹配 + 截取 1470×956 成功;文件回退路径可用 |
| 内存 | 与优化前基本持平;图标缓存上限消除长期增长 |

## 七、已知未做事项

- 拆分 AppStore 的 115 个 `@Published` 巨石状态层(侵入面大,建议独立进行);
- LocalizationManager 按语言懒加载(实测构建成本仅数毫秒,性价比低);
- CAFolderGridView 的 `rebuildLayers` 仍为全量(文件夹视图每次打开新建,收益有限);
- 上述修改尚未向上游提交 PR;提交前建议按上游贡献规范拆分为独立 commit。

---

## 八、交互调整(2026-10-26)

### 1. 拖拽投放目标缩放 1.1 → 1.3
- **范围**:CA 主网格 `applyScaleForIndex`(`CAGridView+Input.swift`)、旧 SwiftUI 渲染路径 `externalScale`(`LaunchpadView.swift`)。
- 拖拽应用悬停在文件夹(或应用,用于建文件夹)投放区时,图标放大倍数由 1.1 提升到 1.3(动画时长保持 0.12s easeOut)。
- 对照:键盘选中仍为 1.2,普通悬停放大仍走 `hoverMagnificationScale`(默认 1.1,可配置)。

### 2. 拖拽悬停文件夹 3 秒自动展开(dwell auto-open)
**链路**(仅 CA 渲染路径):

1. **计时**(`CAGridView+Input.swift`):`updateDragging` 中仅"悬停文件夹中心且拖拽物为应用"分支设置 `dwellTarget`;函数用 `defer` 统一收敛——目标不变则保持计时,否则取消。计时器跑在 `.common` 模式,拖拽事件跟踪期间也能触发。`cancelDragging` / `endDragging` 均清理计时器。
2. **触发**(`handleFolderDwellFire`):取消主网格拖拽(视觉复位,应用保持原槽位,并清 `pressedIndex` 防止残余事件误触发),带出文件夹图标中心作为展开动画锚点,回调 `onDwellOpenFolder(app, folder, anchor)`。
3. **接力**(`CAGridViewRepresentable`):写入 `AppStore.incomingFolderDragApp / incomingFolderDragFolderID / incomingFolderDragScreenLocation`,随后走原有 `onOpenFolder`(带锚点展开动画)。
4. **接管**(`CAFolderGridViewRepresentable.updateNSView`):出现且 ID 匹配时消费接力状态 → `CAFolderGridView.beginExternalDrag(app:screenPoint:)`。
5. **继续拖拽**(`CAFolderGridView`):原始 `mouseDown` 发生在主网格,事件序列不会路由到文件夹视图,故用 `NSEvent` 本地监视器接管 `leftMouseDragged / leftMouseUp`。
   - 拖拽预览层沿用内部拖拽的 `makeDraggingLayer`;
   - 分页模式复用左右边缘自动翻页;
   - 插入位置预览:分页模式复用 `updatePagedReorderPreview(source: apps.count)` 的"source 不在当前页 → 后方让位"分支,纵向模式单独实现插入缺口;
   - 松手在网格内 → `onDropExternalApp(app, index)` → `AppStore.addAppToFolder(app, folder:, at:)`(新增带位置的插入重载,先按路径去重再插入,复用原持久化流程);
   - 松手在网格外 → `onExternalDragCancelled` → 关闭文件夹,应用留在主网格原位;
   - 展开动画期间已松手(`NSEvent.pressedMouseButtons` 检查)→ 放弃接力,文件夹保持打开。

**已知限制**:
- 旧 SwiftUI 渲染引擎(`useCAGridRenderer == false`)未实现 dwell 展开与拖入接力,仅 CA 路径生效;
- dwell 时长固定 3 秒(未做成配置项)。

**验证状态**:7 个改动文件 `swiftc -parse` 语法检查通过;完整 `xcodebuild` 编译因 Xcode 27.1 许可协议未同意而未执行(需本机 `sudo .../xcodebuild -license accept`)。
