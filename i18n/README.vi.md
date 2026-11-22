# ZeroLaunch

**Ngôn ngữ**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 Tải xuống

**[Tải tại đây](https://github.com/zerojs/zero-launch/releases/latest)** - Lấy phiên bản mới nhất

🌐 **Website**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **Tài liệu**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ Hãy xem xét gắn sao cho [ZeroLaunch](https://github.com/zerojs/zero-launch) và đặc biệt là dự án gốc [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe đã loại bỏ Launchpad, và phần thay thế thì rất khó dùng — nó thậm chí còn không tận dụng GPU của bạn. Apple, ít nhất hãy cho mọi người một tùy chọn để chuyển lại. Trước khi có điều đó, đây là ZeroLaunch.

*Được xây dựng dựa trên [LaunchNow](https://github.com/ggkevinnnn/LaunchNow) bởi ggkevinnnn — xin gửi lời cảm ơn rất lớn đến dự án gốc!❤️*

*ZeroLaunch được phát triển dựa trên [LaunchNext](https://github.com/RoversX/LaunchNext) của RoversX — cảm ơn dự án gốc!❤️*

*LaunchNow đã chọn giấy phép GPL 3. ZeroLaunch tuân theo các điều khoản cấp phép tương tự.*

## ✨ Điểm nổi bật của ZeroLaunch

ZeroLaunch được phát triển tích cực dựa trên LaunchNext. Dưới đây là những gì **fork này bổ sung** so với bản gốc:

- ⚡ **Tối ưu hiệu năng cấp engine** — layer-tree diffing chỉ render lại những biểu tượng thay đổi thay vì dựng lại 500+ layer; cuộn trang cảm giác như nhau trên màn hình 60Hz và 120Hz; cache biểu tượng nhận biết tỉ lệ (có giới hạn kích thước); lưu tăng dần (một lần kéo = một lần ghi đĩa)
- 🗑️ **Chế độ gỡ cài đặt bằng nhấn giữ** — chế độ rung lắc kiểu iOS với luồng thùng rác an toàn và nhiều cấp độ dự phòng quyền (ngay cả ứng dụng App Store thuộc sở hữu root cũng có thể đưa vào thùng rác)
- 📁 **Thư mục mở khi di chuột vào** — giữ một ứng dụng trên thư mục một lát, thư mục sẽ tự mở ra; thả vào bên trong để đặt ứng dụng đúng chỗ bạn muốn
- 🧲 **Lật trang ở cạnh màn hình kèm gợi ý** — kéo ứng dụng ra cạnh màn hình để lật trang, có thanh gợi ý trực quan; trang trống được tái sử dụng nên không bao giờ bị rác
- 🎬 **Hiệu ứng mở/đóng đối xứng** — khi mở, bảng thu về phía trung tâm; khi đóng, bảng nở ra ngoài, với thời lượng có thể cấu hình
- 🗂️ **Mở rộng thư mục kiểu LaunchOS** — thư mục nở ra từ chính biểu tượng bạn click; đổi tên bằng một click với ô nhập tự điều chỉnh
- ⚙️ **Settings được xây dựng lại hoàn toàn** — tìm kiếm ngay trong Settings với điều hướng bàn phím, đặt lại từng phần, bộ chuyển đổi phạm vi Fullscreen/Window, và các tùy chọn liên quan được nhóm thành thẻ
- 🧹 **Các tùy chọn được kiểm toán và dọn dẹp** — xóa bỏ setting vô dụng, thống nhất tên Fullscreen/Window, thanh trượt font-weight dạng số, hiển thị mức dùng bộ nhớ trực tiếp, và phím tắt khởi động lại ngay sau khi đổi chế độ hiệu năng
- 🌍 **14 ngôn ngữ** — mọi setting mới đều đi kèm bản địa hóa (en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **Phân phối độc lập** — bundle ID riêng, CLI `zerolaunch`, tự cập nhật tích hợp sẵn, và script phát hành
- 🛠️ **Sửa lỗi thực tế** — nền hình nền macOS 26 (khớp cửa sổ bản địa hóa + dự phòng cấp tệp), settings sheet mất tiêu điểm, vùng nhấn của nút nguy hiểm quá nhỏ, và nhiều lỗi khác

## 🚀 Cài đặt

### Tùy chọn 1 — Tải bản phát hành

1. Lấy `ZeroLaunch<phiên bản>.zip` từ [bản phát hành mới nhất](https://github.com/zerojs/zero-launch/releases/latest)
2. Giải nén và kéo `ZeroLaunch.app` vào `/Applications`
3. Khởi chạy — nếu macOS chặn, xem lưu ý bên dưới

### Tùy chọn 2 — Build từ mã nguồn

Xem [Xây dựng từ mã nguồn](#build-from-source) bên dưới.

> ⚠️ **Nếu macOS chặn ứng dụng, hãy chạy lệnh này trong Terminal:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**Lý do**: Các bản phát hành của ZeroLaunch hiện được ký ad-hoc và chưa notarized (chưa có tài khoản Apple Developer trả phí), nên macOS chặn ứng dụng chưa ký theo mặc định. Lệnh này xóa cờ cách ly để ứng dụng chạy được. **Chỉ dùng lệnh này cho ứng dụng bạn tin tưởng.** Bạn cũng có thể click chuột phải → **Open** → xác nhận.

**Trạng thái ký mã**: các bản phát hành hiện **được ký ad-hoc, chưa notarized**. Gatekeeper có thể cảnh báo ở lần chạy đầu; xem lệnh ở trên hoặc click chuột phải → Open. Khi có tài khoản Apple Developer trả phí sau này, bản phát hành sẽ chuyển sang ký Developer ID + notarization. Build từ mã nguồn? Xem [Cấu hình ký mã cục bộ](#configure-local-code-signing).

### ZeroLaunch mang lại điều gì

- ✅ **Nhập một cú nhấp từ Launchpad hệ thống cũ** - đọc trực tiếp cơ sở dữ liệu SQLite Launchpad gốc (`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`) để tái tạo hoàn hảo các thư mục, vị trí ứng dụng và bố cục hiện có
- ✅ **Trải nghiệm Launchpad cổ điển** - hoạt động y hệt giao diện gốc được yêu thích
- ✅ **Hỗ trợ đa ngôn ngữ** - bản địa hóa đầy đủ với English, Simplified Chinese, Traditional Chinese, Japanese, French, Spanish, German, Russian và nhiều ngôn ngữ khác
- ✅ **Ẩn nhãn biểu tượng** - giao diện sạch sẽ, tối giản khi không cần tên ứng dụng
- ✅ **Kích thước biểu tượng tùy chỉnh** - điều chỉnh kích thước biểu tượng theo ý bạn
- ✅ **Quản lý thư mục thông minh** - tạo và tổ chức thư mục như trước
- ✅ **Tìm kiếm mờ và điều hướng bàn phím** - tìm ứng dụng nhanh, dù nhập liệu không đầy đủ hoặc không chính xác
- ✅ **Hỗ trợ CLI / TUI** - kiểm tra và thao tác bố cục từ terminal với lệnh `zerolaunch`
- ✅ **Hot Corner và hỗ trợ cử chỉ gốc** - mở ZeroLaunch bằng góc màn hình, cử chỉ trackpad và tùy chọn 4 / 5 ngón tay
- ✅ **Kéo ứng dụng trực tiếp vào Dock** - có trong Next Engine + Core Animation
- ✅ **Thư mục Core Animation** - nội dung thư mục hỗ trợ bố cục phân trang và cuộn dọc
- ✅ **Menu ngữ cảnh tốt hơn** - Show in Finder, Copy App Path, Rename Folder và hành động gỡ cài đặt đã cấu hình
- ✅ **Tab cập nhật với release notes Markdown** - trải nghiệm cập nhật trong ứng dụng phong phú hơn
- ✅ **Cải tiến sao lưu, tay cầm và giọng nói** - độ tin cậy và khả năng trợ năng tốt hơn

### Những gì macOS Tahoe đã lấy mất

- ❌ Không có tổ chức ứng dụng tùy chỉnh
- ❌ Không có thư mục do người dùng tạo
- ❌ Không có tùy chỉnh kéo và thả
- ❌ Không có quản lý ứng dụng trực quan
- ❌ Nhóm phân loại bắt buộc

### Lưu trữ dữ liệu

Dữ liệu ứng dụng được lưu an toàn tại:

```text
~/Library/Application Support/ZeroLaunch/Data.store
```

### Tích hợp Launchpad gốc

Đọc trực tiếp từ cơ sở dữ liệu Launchpad của hệ thống:

```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## Xây dựng từ mã nguồn

### Yêu cầu

- macOS 26 (Tahoe) trở lên
- Bộ xử lý Apple Silicon hoặc Intel
- Xcode 26 (để build từ mã nguồn)

<a name="build-from-source"></a>
### Xây dựng từ mã nguồn

1. **Clone kho lưu trữ**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Mở bằng Xcode**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**Cấu hình ký mã cục bộ**
   - Không cần tài khoản Apple Developer trả phí để build hoặc đóng góp cho ZeroLaunch.
   - Chọn target **LaunchNext**, mở **Signing & Capabilities**, đặt **Team** thành team của bạn (Personal Team miễn phí cũng được), hoặc đặt **Team** thành `None` và chọn `Sign to Run Locally` làm chứng chỉ ký.
   - Giữ Hardened Runtime được bật.
   - Xcode có thể đánh dấu tệp dự án là đã sửa sau khi đổi các thiết lập cục bộ này. Đừng đưa các thay đổi chỉ liên quan đến ký mã vào pull request.

4. **Build và chạy**
   - Để chạy ứng dụng bằng `⌘+R`, chọn `My Mac` làm đích chạy — đừng chọn `Any Mac`.
   - `Any Mac (arm64, x86_64)` dành cho build và archive nói chung; không dùng để khởi chạy ứng dụng khi debug.
   - Nhấn `⌘+B` nếu bạn chỉ muốn build.

### Build dòng lệnh

**Build thông thường:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**Build universal binary (Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**Gói phát hành (zip + checksum, ký ad-hoc):**
```bash
./scripts/release.sh
```

## Sử dụng

### Bắt đầu

1. **Khởi chạy đầu tiên**: ZeroLaunch tự động quét tất cả ứng dụng đã cài đặt
2. **Chọn**: click để chọn ứng dụng, double-click để mở
3. **Tìm kiếm**: gõ để lọc ứng dụng ngay lập tức
4. **Sắp xếp**: kéo ứng dụng để tạo thư mục và bố cục tùy chỉnh
5. **Tự động hóa**: bật CLI trong Cài đặt nếu bạn dùng workflow terminal

### Nhập Launchpad của bạn

1. Mở Cài đặt
2. Nhấn **Import Launchpad**
3. Bố cục và thư mục hiện có của bạn sẽ được nhập tự động

### Chế độ hiển thị

- **Window**: cửa sổ nổi với góc bo tròn
- **Fullscreen**: chế độ toàn màn hình để có tầm nhìn tối đa
- **Legacy Engine** và **Next Engine + Core Animation** có trong Cài đặt
- ZeroLaunch có thể giữ cài đặt riêng cho chế độ toàn màn hình và cửa sổ
- Có tùy chọn ẩn thanh menu khi toàn màn hình; khi bật, macOS cũng ẩn cả Dock

## Tính năng nâng cao

### Trải nghiệm tìm kiếm và thư mục

- **Tìm kiếm mờ**: khớp ứng dụng theo tên một phần, viết tắt và nhập liệu không chuẩn
- **Độ trễ tìm kiếm cấu hình được**: chỉnh thời gian debounce trong Cài đặt
- **Chế độ bố cục thư mục**: chọn giữa thư mục phân trang kiểu Launchpad và thư mục cuộn dọc
- **Render thư mục Core Animation**: tương tác mượt hơn cho thư mục lớn

### Tương tác nền thông minh

- Phát hiện click thông minh, tránh đóng nhầm
- Xử lý cử chỉ theo ngữ cảnh
- Bảo vệ ô tìm kiếm

### Tối ưu hiệu năng

- **Cache biểu tượng**: cache hình ảnh thông minh cho cuộn mượt
- **Tải lười**: dùng bộ nhớ hiệu quả
- **Quét nền**: phát hiện ứng dụng không chặn giao diện

### Tự động hóa và kích hoạt

- **CLI / TUI**: quản lý ZeroLaunch từ terminal với `zerolaunch`
- **Hot Corner**: mở ZeroLaunch từ góc màn hình có thể cấu hình
- **Cử chỉ gốc thử nghiệm**: hành động pinch / tap 4 / 5 ngón, kể cả chọn thiết bị trackpad ngoài
- **Kéo vào Dock**: kéo ứng dụng thẳng vào Dock macOS trong Next Engine + Core Animation

### Quản lý ứng dụng

- **Hành động menu ngữ cảnh**: Show in Finder, copy đường dẫn ứng dụng, đổi tên thư mục và dùng công cụ gỡ cài đặt đã cấu hình

### Công cụ cập nhật và sao lưu

- **Tab cập nhật**: kiểm tra cập nhật và đọc release notes Markdown ngay trong Cài đặt
- **Công cụ sao lưu**: tạo và khôi phục bản sao lưu an toàn hơn
- **Cập nhật thông báo**: hỗ trợ API thông báo hiện đại

### Hỗ trợ nhiều màn hình

- Tự động nhận diện màn hình
- Định vị riêng cho từng màn hình
- Luồng làm việc đa màn hình liền mạch

## Khắc phục sự cố

### Vấn đề thường gặp

**Q: Ứng dụng không khởi động?**  
A: Hãy xác nhận bạn đang dùng macOS 26.0 trở lên và kiểm tra quyền hệ thống. Nếu ứng dụng bị Gatekeeper chặn, chạy `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app` hoặc click chuột phải → Open.

**Q: Tôi nên dùng engine nào?**  
A: `Next Engine + Core Animation` được khuyến nghị cho trải nghiệm tốt nhất. `Legacy Engine` vẫn có sẵn nếu bạn cần đường dẫn tương thích cũ.

**Q: Tại sao lệnh CLI vẫn chưa có?**  
A: Trước tiên hãy bật giao diện dòng lệnh trong Cài đặt. ZeroLaunch có thể cài đặt và gỡ lệnh `zerolaunch` được quản lý cho bạn.

## Đóng góp

Mọi đóng góp đều được chào đón. Hãy:

1. Fork kho lưu trữ
2. Tạo nhánh tính năng (`git checkout -b feature/amazing-feature`)
3. Commit thay đổi (`git commit -m 'Add amazing feature'`)
4. Push nhánh (`git push origin feature/amazing-feature`)
5. Mở Pull Request

### Hướng dẫn phát triển

- Tuân theo quy ước style của Swift
- Thêm comment có ý nghĩa cho logic phức tạp
- Kiểm tra trên nhiều phiên bản macOS
- Duy trì khả năng tương thích ngược

## Tương lai của quản lý ứng dụng

Khi Apple ngày càng rời xa giao diện có thể tùy biến, ZeroLaunch đại diện cho một nỗ lực hướng tới quyền kiểm soát và cá nhân hóa của người dùng. Tôi vẫn hy vọng Apple mang Launchpad trở lại.

**ZeroLaunch** không chỉ là bản thay thế Launchpad — mà là một tuyên bố rằng lựa chọn của người dùng quan trọng.


---

**ZeroLaunch** - Giành lại quyền kiểm soát launcher ứng dụng của bạn 🚀

*Dành cho người dùng macOS không muốn thỏa hiệp về khả năng tùy biến.*

## Công cụ phát triển

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google



- Hỗ trợ cử chỉ thử nghiệm được xây dựng trên [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) và fork của [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport).❤️


![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
