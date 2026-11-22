# Contributing to ZeroLaunch

Thanks for taking the time to contribute. ZeroLaunch is a fork of LaunchNext (which itself builds on LaunchNow) and is licensed under GPL-3.0. By contributing, you agree that your contribution is licensed under the same terms.

## Getting started

- macOS 26 (Tahoe) or later, Xcode 26
- No paid Apple Developer membership is required — a free Personal Team, or "Sign to Run Locally", works
- See the [Building from Source](README.md#building-from-source) section of the README for the full setup

Before opening a pull request:

1. Fork the repository and create a branch from `main`.
2. Build the updater once, since the Xcode target embeds it during build:

   ```bash
   cd UpdaterScripts/SwiftUpdater
   swift build --configuration release --arch arm64 --arch x86_64 --product SwiftUpdater
   ```

3. Build and run the tests:

   ```bash
   xcodebuild -project LaunchNext.xcodeproj -scheme LaunchNext -configuration Debug test
   ```

4. Test the app on your Mac, including the features your change touches.

## Commit and pull request conventions

- Keep commits focused; one logical change per commit.
- Use a short imperative subject line, e.g. `fix: preserve folder order after import`, `feat: add keyboard shortcut for search`.
- Describe **what** changed and **why** in the PR body. Link any related issue.
- Do not include signing-only changes to `project.pbxproj` (your local Team ID, certificate, or provisioning profile) in a PR. The project is configured to sign locally by default.
- Do not add generated files, build artifacts, or local notes to the repository.

## Reporting bugs

Use the [bug report template](https://github.com/zerojs/zero-launch/issues/new?template=bug_report.md) and include:

- ZeroLaunch version and macOS version
- steps to reproduce and the expected vs actual behavior
- relevant logs or screenshots

For security vulnerabilities, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Scope of contributions

Bug fixes, performance improvements, and small UX refinements are especially welcome. Larger features are best discussed in an issue first so we can agree on the approach before you invest time in implementation.

## Language

README translations live under `i18n/` and are versions of the English `README.md`. If you update the English README, please keep the translations in sync where practical.
