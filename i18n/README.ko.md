# ZeroLaunch

**언어**: [English](../README.md) | [简体中文](README.zh.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [Tiếng Việt](README.vi.md) | [Italiano](README.it.md) | [Čeština](README.cs.md)

## 📥 다운로드

**[여기서 다운받기](https://github.com/zerojs/zero-launch/releases/latest)** - 최신 버전 받기

🌐 **웹사이트**: [www.zerojs.cn](https://www.zerojs.cn/)  
📚 **문서**: [www.zerojs.cn](https://www.zerojs.cn/)

⭐ [ZeroLaunch](https://github.com/zerojs/zero-launch)와 원본 프로젝트 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)에 star를 달아주세요!

| | |
|:---:|:---:|
| ![](../public/banner.webp) | ![](../public/setting1.webp) |
| ![](../public/setting2.webp) | ![](../public/setting3.webp) |

macOS Tahoe는 런치패드를 없앴고, 그 대안은 쓰기 불편할 뿐 아니라 GPU도 제대로 활용하지 못해요. Apple이 런치패드를 다시 넣어주는 날이 오길 바라며, 그때까지 ZeroLaunch를 사용해보세요.

*[LaunchNext](https://github.com/RoversX/LaunchNext)(RoversX 제작)를 기반으로 개발되었어요. 원본 프로젝트에 진심으로 감사드려요!❤️ LaunchNext 자체는 [LaunchNow](https://github.com/ggkevinnnn/LaunchNow)(ggkevinnnn 제작)를 기반으로 해요.*

*LaunchNow는 GPL 3 라이선스를 선택했고, LaunchNext와 ZeroLaunch도 같은 라이선스 조건을 따릅니다.*

## ✨ ZeroLaunch 하이라이트

ZeroLaunch는 LaunchNext 위에서 활발히 개발되고 있어요. 다음은 **이 fork가 원본 프로젝트에 추가한 내용**입니다:

- ⚡ **엔진 수준의 성능 개편** — 레이어 트리 diff 방식으로 변경된 아이콘만 다시 그려요(500개 이상의 레이어를 전부 재구성하지 않음); 페이지 스크롤 느낌이 60Hz / 120Hz 디스플레이에서 동일해요; 스케일을 고려한 아이콘 캐시(용량 제한 있음); 증분 저장(드래그 한 번 = 디스크 기록 한 번)
- 🗑️ **길게 눌러 삭제 모드** — iOS 스타일의 흔들기 모드, 안전한 휴지통 이동, 다단계 권한 폴백(root 소유 App Store 앱도 휴지통으로 보낼 수 있어요)
- 📁 **마우스를 올리면 폴더 열기** — 앱을 폴더 위에 잠시 올려두면 자동으로 펼쳐지고, 놓으면 원하는 위치에 정확히 배치돼요
- 🧲 **화면 가장자리 페이지 넘김 + 힌트** — 앱을 화면 가장자리로 드래그하면 시각적 힌트 바와 함께 페이지가 넘어가고, 빈 페이지는 재활용돼서 쌓이지 않아요
- 🎬 **대칭적인 열기/닫기 애니메이션** — 열 때는 패널이 중앙으로 줌인, 닫을 때는 바깥으로 확장하며, 지속 시간을 설정할 수 있어요
- 🗂️ **LaunchOS 스타일 폴더 펼치기** — 클릭한 아이콘 위치에서 폴더가 커지며 펼쳐지고, 적응형 입력창으로 한 번에 이름을 바꿀 수 있어요
- ⚙️ **설정 화면 전면 재구성** — 설정 내 검색과 키보드 탐색, 섹션별 초기화, 전체화면/창 스코프 전환기, 관련 옵션 카드 그룹화
- 🧹 **검증하고 정리한 옵션** — 불필요한 설정 제거, 전체화면/창 명칭 통일, 숫자 폰트 굵기 슬라이더, 실시간 메모리 사용량 표시, 성능 모드 전환 후 즉시 재시작 단축키
- 🌍 **14개 언어** — 새 설정 항목은 모두 현지화했어요(en, zh-Hans, zh-Hant, ja, ko, fr, es, de, ru, it, cs, pt-BR, vi, hi)
- 🚢 **독립 배포 체계** — 자체 Bundle ID, `zerolaunch` CLI, 내장 셀프 업데이터, 릴리즈 스크립트
- 🛠️ **실제 버그 수정** — macOS 26 배경화면(현지화된 창 매칭 + 파일 단위 폴백), 설정 시트의 포커스 이탈, 위험한 버튼의 히트 영역이 너무 작은 문제 등

## 🚀 설치

### 방법 1 — 릴리즈 다운로드
1. [최신 릴리즈](https://github.com/zerojs/zero-launch/releases/latest)에서 `ZeroLaunch<버전>.zip`을 받으세요
2. 압축을 풀고 `ZeroLaunch.app`을 `/Applications`로 드래그하세요
3. 실행하세요 — macOS가 차단하면 아래를 참고하세요

### 방법 2 — 소스에서 빌드

아래 [소스에서 빌드](#소스에서-빌드)를 참고하세요.

> ⚠️ **macOS가 앱을 차단하면 터미널에서 실행하세요:**
```bash
sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app
```
**이유**: ZeroLaunch 릴리즈는 ad-hoc 서명이며 아직 공증되지 않았어요(유료 Apple Developer 멤버십이 없기 때문). 그래서 macOS가 기본적으로 서명되지 않은 앱을 차단해요. 이 명령은 격리 플래그를 제거해 앱이 실행되도록 해요. **신뢰할 수 있는 앱에만 사용하세요.** 앱을 마우스 오른쪽 클릭 → **열기** → 확인을 눌러도 돼요.

**코드 서명 상태**: 현재 릴리즈는 **ad-hoc 서명, 미공증** 상태예요. 첫 실행 시 Gatekeeper가 경고할 수 있으니 위 명령이나 마우스 오른쪽 클릭 → 열기를 사용하세요. 나중에 유료 Apple Developer 멤버십을 추가하면 Developer ID 서명 + 공증으로 전환할 예정이에요. 소스에서 빌드한다면 [로컬 코드 서명 설정](#configure-local-code-signing)을 참고하세요.

### ZeroLaunch가 제공하는 것

- ✅ **기존 시스템 Launchpad 원클릭 가져오기** — 네이티브 Launchpad SQLite 데이터베이스(`/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db`)를 직접 읽어 기존 폴더, 앱 위치, 레이아웃을 완벽하게 재현해요
- ✅ **클래식 Launchpad 경험** — 사랑받았던 원래 인터페이스와 똑같이 동작해요
- ✅ **다국어 지원** — 영어, 간체 중국어, 번체 중국어, 일본어, 프랑스어, 스페인어, 독일어, 러시아어 등을 완전히 지원해요
- ✅ **아이콘 라벨 숨기기** — 앱 이름이 필요 없을 때 깔끔하고 미니멀한 화면
- ✅ **사용자 지정 아이콘 크기** — 원하는 대로 아이콘 크기를 조절하세요
- ✅ **스마트 폴더 관리** — 예전처럼 폴더를 만들고 정리하세요
- ✅ **퍼지 검색과 키보드 탐색** — 일부 또는 부정확한 입력으로도 앱을 빠르게 찾아요
- ✅ **CLI / TUI 지원** — `zerolaunch` 명령으로 터미널에서 레이아웃을 확인하고 조작하세요
- ✅ **Hot Corner와 네이티브 제스처 지원** — 화면 모서리, 트랙패드 제스처, 4 / 5손가락 옵션으로 열 수 있어요
- ✅ **앱을 Dock으로 바로 드래그** — Next Engine + Core Animation에서 사용 가능
- ✅ **Core Animation 폴더** — 폴더 내용이 페이지 및 세로 스크롤 레이아웃을 지원해요
- ✅ **더 나은 컨텍스트 메뉴** — Finder에서 보기, 앱 경로 복사, 폴더 이름 변경, 설정된 삭제 동작
- ✅ **Markdown 릴리즈 노트가 있는 업데이트 탭** — 더 풍부한 인앱 업데이트 경험
- ✅ **백업, 컨트롤러, 음성 지원 개선** — 안정성과 접근성 향상

### macOS Tahoe가 없애버린 것
- ❌ 커스텀 앱 정리 불가
- ❌ 커스텀 폴더 생성 불가
- ❌ 드래그 앤 드롭 사용자화 불가
- ❌ 시각적 앱 관리 불가
- ❌ 강제 카테고리 그룹화

### 데이터 저장
앱 데이터는 다음 위치에 저장돼요:
```
~/Library/Application Support/ZeroLaunch/Data.store
```

### 네이티브 Launchpad 통합
ZeroLaunch는 시스템 Launchpad 데이터베이스를 직접 읽을 수 있어요:
```bash
/private$(getconf DARWIN_USER_DIR)com.apple.dock.launchpad/db/db
```

## 소스에서 빌드

### 요구사항
- macOS 26(Tahoe) 이상
- Apple Silicon 또는 Intel 프로세서
- Xcode 26(소스에서 빌드할 경우)

### 소스에서 빌드

1. **저장소 복제**
   ```bash
   git clone https://github.com/zerojs/zero-launch.git
   cd zero-launch
   ```

2. **Xcode에서 열기**
   ```bash
   open LaunchNext.xcodeproj
   ```

3. <a name="configure-local-code-signing"></a>**로컬 코드 서명 설정**
   - ZeroLaunch를 빌드하거나 기여하는 데 유료 Apple Developer 멤버십은 필요하지 않아요.
   - **LaunchNext 타겟**을 선택하고 **Signing & Capabilities**를 연 뒤, **Team**에 본인 팀(무료 Personal Team도 가능)을 설정하거나 **Team**을 `None`으로 두고 서명 인증서로 `Sign to Run Locally`를 선택하세요.
   - Hardened Runtime은 켜두세요.
   - 이 로컬 설정을 바꾸면 Xcode가 프로젝트 파일을 수정된 것으로 표시할 수 있어요. 서명 관련 변경만 한 내용은 Pull Request에 포함하지 마세요.

4. **빌드 및 실행**
   - `⌘+R`로 실행하려면 실행 대상을 `Any Mac`이 아닌 `My Mac`으로 선택하세요.
   - `Any Mac (arm64, x86_64)`은 범용 빌드와 아카이브용이라 디버깅을 위해 앱을 실행할 수 없어요.
   - 빌드만 하려면 `⌘+B`를 누르세요.

### 명령줄 빌드

**일반 빌드:**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release
```

**유니버설 바이너리 빌드(Intel + Apple Silicon):**
```bash
xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO clean build
```

**릴리즈 패키지(zip + 체크섬, ad-hoc 서명):**
```bash
./scripts/release.sh
```

## 사용법

### 시작하기
1. **첫 실행**: ZeroLaunch가 설치된 앱을 자동으로 스캔해요
2. **선택**: 클릭해서 선택, 더블클릭으로 실행
3. **검색**: 입력하면 즉시 앱을 필터링해요
4. **정리**: 앱을 드래그해 폴더와 사용자 지정 레이아웃을 만드세요
5. **자동화**: 터미널 작업 흐름이 필요하면 설정에서 CLI를 활성화하세요

### Launchpad 가져오기
1. 설정(톱니바퀴 아이콘)을 열세요
2. **"Import Launchpad"**를 클릭하세요
3. 기존 레이아웃과 폴더가 자동으로 가져와져요

### 표시 모드
- **창**: 둥근 모서리의 플로팅 창
- **전체화면**: 시야를 최대화하는 전체화면 모드
- 설정에서 **Legacy Engine**과 **Next Engine + Core Animation**을 선택할 수 있어요
- ZeroLaunch는 전체화면과 창 모드의 설정을 각각 따로 저장할 수 있어요
- 전체화면에서 메뉴 바를 숨길 수 있고, 이때 macOS는 Dock도 숨겨요

## 고급 기능

### 검색과 폴더 경험
- **퍼지 검색**: 부분 이름, 약어, 부정확한 입력으로 앱을 찾아요
- **검색 지연 설정**: 설정에서 검색 debounce 시간을 조절하세요
- **폴더 레이아웃 모드**: Launchpad 스타일 페이지 폴더와 세로 스크롤 폴더 중 선택
- **Core Animation 폴더 렌더링**: 큰 폴더도 더 부드럽게 조작

### 스마트 배경 상호작용
- 실수로 닫히는 것을 막는 지능형 클릭 감지
- 상황을 인식하는 제스처 처리
- 검색 필드 보호

### 성능 최적화
- **아이콘 캐시**: 부드러운 스크롤을 위한 지능형 이미지 캐싱
- **지연 로딩**: 메모리를 효율적으로 사용
- **백그라운드 스캔**: 논블로킹 앱 탐색

### 자동화와 활성화
- **CLI / TUI**: `zerolaunch`로 터미널에서 ZeroLaunch를 관리하세요
- **Hot Corner**: 설정한 화면 모서리에서 ZeroLaunch를 여세요
- **실험적 네이티브 제스처**: 4 / 5손가락 pinch / tap 동작(외부 트랙패드 기기 선택 포함)
- **Dock 드래그**: Next Engine + Core Animation에서 앱을 macOS Dock으로 바로 드래그

### 앱 관리
- **컨텍스트 메뉴 동작**: Finder에서 보기, 앱 경로 복사, 폴더 이름 변경, 설정된 삭제 도구 사용

### 업데이트와 백업 도구
- **업데이트 탭**: 설정에서 업데이트를 확인하고 Markdown 릴리즈 노트를 읽으세요
- **백업 도구**: 더 안전하게 백업을 만들고 복원하세요
- **알림 업데이트**: 최신 알림 API 지원

### 멀티 디스플레이 지원
- 화면 자동 감지
- 디스플레이별 위치 설정
- 끊김 없는 멀티 모니터 작업 흐름

## 문제 해결

### 일반적인 문제

**Q: 앱이 실행되지 않아요?**  
A: macOS 26.0 이상인지 확인하고 시스템 권한을 점검하세요. Gatekeeper에 차단됐다면 `sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app`을 실행하거나 마우스 오른쪽 클릭 → 열기를 사용하세요.

**Q: 어떤 엔진을 써야 하나요?**  
A: 최고의 경험을 위해 `Next Engine + Core Animation`을 권장해요. 오래된 호환성이 필요하면 `Legacy Engine`을 계속 사용할 수 있어요.

**Q: CLI 명령이 아직 없어요. 왜 그런가요?**  
A: 먼저 설정에서 명령줄 인터페이스를 활성화하세요. ZeroLaunch가 관리되는 `zerolaunch` 명령을 설치하고 제거할 수 있어요.

## 기여

기여를 환영해요! 다음을 따라주세요:

1. 저장소 포크
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 푸시 (`git push origin feature/amazing-feature`)
5. Pull Request 열기

### 개발 가이드라인
- Swift 스타일 규칙을 따르세요
- 복잡한 로직에는 의미 있는 주석을 추가하세요
- 여러 macOS 버전에서 테스트하세요
- 하위 호환성을 유지하세요

## 앱 관리의 미래

Apple이 커스텀 가능한 인터페이스에서 멀어지는 가운데, ZeroLaunch는 사용자 통제와 개인화를 향한 움직임이에요. 여전히 Apple이 런치패드를 되돌려주길 바랍니다.

**ZeroLaunch**는 단순한 런치패드 대체제가 아니에요 — 사용자의 선택이 중요하다는 선언입니다.

---

**ZeroLaunch** - 앱 런처의 주도권을 되찾으세요 🚀

*커스터마이징에 타협하지 않는 macOS 사용자를 위해.*

## 개발 도구

- Claude Code
- Cursor
- OpenAI Codex CLI
- Perplexity
- Google

- 실험적 제스처 지원은 [OpenMultitouchSupport](https://github.com/Kyome22/OpenMultitouchSupport) 와 [KrishKrosh](https://github.com/KrishKrosh/OpenMultitouchSupport) 포크를 기반으로 합니다.❤️

![GitHub downloads](https://img.shields.io/github/downloads/zerojs/zero-launch/total)
