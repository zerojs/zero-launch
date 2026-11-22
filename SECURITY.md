# Security Policy

## Supported versions

ZeroLaunch is a community project distributed as pre-built releases. Security fixes are applied to the latest release only.

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Older releases | No |

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Email **zerojs@zerojs.cn** with:

- a description of the vulnerability and its impact
- steps to reproduce, or a proof of concept
- the affected app version and macOS version

You should receive an acknowledgement within 72 hours. If the report is confirmed, a fix and a new release will be prepared before public disclosure. You will be credited in the release notes unless you prefer to remain anonymous.

## Scope

The following are in scope:

- privilege escalation or code execution through the app's app-management operations (install, uninstall, move to trash)
- vulnerabilities in the in-app updater or release asset verification
- local data exposure of application settings or folder data

The following are generally out of scope:

- issues that require administrator privileges the user already granted
- Gatekeeper quarantine warnings on ad-hoc signed releases (see the README)
- vulnerabilities in upstream dependencies that have not been confirmed to affect ZeroLaunch
