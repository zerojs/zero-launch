#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="LaunchNext.xcodeproj"
SCHEME="LaunchNext"
CONFIGURATION="Release"

# 开源项目不绑定任何个人 Team ID（pbxproj 里 DEVELOPMENT_TEAM 为空）。
# 命令行构建必须显式走 ad-hoc 签名，否则会报 "requires a development team"。
# 产物在下方还会用 codesign --sign - 再做一次 deep ad-hoc 重签名。
SIGNING_ARGS=(
  CODE_SIGN_STYLE=Manual
  CODE_SIGN_IDENTITY=-
  CODE_SIGNING_REQUIRED=NO
)

cd "${ROOT_DIR}"

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  "${SIGNING_ARGS[@]}" \
  clean build

BUILT_PRODUCTS_DIR="$(xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  "${SIGNING_ARGS[@]}" \
  -showBuildSettings \
  | awk -F ' = ' '/^[[:space:]]*BUILT_PRODUCTS_DIR = / { print $2 }' \
  | tail -n 1)"

APP_PATH="${BUILT_PRODUCTS_DIR}/ZeroLaunch.app"
BUILD_DIR="$(cd "${BUILT_PRODUCTS_DIR}/../.." && pwd)"
RELEASE_DIR="${BUILD_DIR}/dist"

rm -rf "${RELEASE_DIR}"
mkdir -p "${RELEASE_DIR}"

if [[ ! -d "${APP_PATH}" ]]; then
  echo "error: Release app not found at ${APP_PATH}" >&2
  exit 1
fi

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "${APP_PATH}/Contents/Info.plist")"
if [[ -z "${VERSION}" ]]; then
  echo "error: Could not read CFBundleShortVersionString from ${APP_PATH}" >&2
  exit 1
fi

# —— ad-hoc 签名（免费路线，无需付费开发者账号）——
# 未签名/ ad-hoc 签名的 app 下载后会带 quarantine 标记，Gatekeeper 会拦。
# 这里用 ad-hoc（`-`）对 .app 重新签名，让本机与信任来源能直接跑；
# 分发时用户仍需清一次隔离标记（见脚本结尾的提示）。
echo "Ad-hoc signing the app bundle..."
codesign --force --deep --sign - "${APP_PATH}" 2>&1 || {
  echo "warning: ad-hoc signing failed; continuing with the unsigned build" >&2
}

# 名字必须和 AppIdentity.releaseAssetPattern（`ZeroLaunch.*\.zip`）匹配，
# 内置 updater 按这个规则在 release 里挑资产。
ZIP_NAME="ZeroLaunch${VERSION}.zip"
ZIP_PATH="${RELEASE_DIR}/${ZIP_NAME}"
CHECKSUMS_PATH="${RELEASE_DIR}/checksums.txt"

ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"

(
  cd "${RELEASE_DIR}"
  shasum -a 256 "${ZIP_NAME}" > "${CHECKSUMS_PATH}"
)

SHA256="$(awk '{print $1}' "${CHECKSUMS_PATH}")"

echo "Release artifacts:"
echo "  ${ZIP_PATH}"
echo "  ${CHECKSUMS_PATH}"
echo ""
echo "Version: ${VERSION}"
echo "SHA256: ${SHA256}"
echo ""
echo "Upload these assets to the GitHub release tagged ${VERSION}:"
echo "  ${ZIP_NAME}"
echo "  checksums.txt"
echo ""
echo "======================================================"
echo "NOTE: this build is ad-hoc signed, NOT notarized."
echo "macOS Gatekeeper may block it on first launch."
echo "Users can unblock it with:"
echo "  sudo xattr -r -d com.apple.quarantine /Applications/ZeroLaunch.app"
echo "Or: right-click the app → Open → confirm \"Open\"."
echo "======================================================"
