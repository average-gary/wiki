---
title: "macOS codesign + notarytool CI workflow"
source: https://www.kencochrane.com/2020/08/01/build-and-sign-golang-binaries-for-macos-with-github-actions/
type: guide
tags: [macos, codesign, notarytool, github-actions, gatekeeper]
date: 2026-05-21
quality: 3
confidence: medium
agent: 4
summary: "Apple Developer Program ($99/yr). Cert export as .p12 → base64 → GitHub secret → import-codesign-certs action. xcrun notarytool submit + xcrun stapler staple (replaces deprecated altool). Pattern is language-agnostic; applies to Rust binaries identically."
---

# macOS Codesign + Notarize for Rust binaries (CI workflow)

## Apple Developer Program

- **$99 / year**
- Unlocks "Developer ID Application" certificate for distribution OUTSIDE the Mac App Store
- Without it: Gatekeeper blocks the binary; users must right-click → Open or `xattr -d com.apple.quarantine <file>`

## Required GitHub secrets

| Secret | Source |
|--------|--------|
| `APPLE_DEVELOPER_CERTIFICATE_P12_BASE64` | Export "Developer ID Application" cert as `.p12`, base64-encode |
| `APPLE_DEVELOPER_CERTIFICATE_PASSWORD` | Password chosen during `.p12` export |
| `AC_USERNAME` | Apple ID email |
| `AC_PASSWORD` | App-specific password (regular password fails with 2FA) |

## Workflow steps

1. **Import certificate** to runner keychain:
   ```yaml
   - uses: Apple-Actions/import-codesign-certs@v3
     with:
       p12-file-base64: ${{ secrets.APPLE_DEVELOPER_CERTIFICATE_P12_BASE64 }}
       p12-password: ${{ secrets.APPLE_DEVELOPER_CERTIFICATE_PASSWORD }}
   ```

2. **Sign**:
   ```bash
   codesign --force --sign "Developer ID Application: <Name> (<TEAMID>)" \
     --options runtime --timestamp <binary-or-app>
   ```

3. **Notarize** (modern toolchain — `notarytool` since 2023, replaces `altool`):
   ```bash
   xcrun notarytool submit <archive.dmg|.zip> \
     --apple-id "$AC_USERNAME" \
     --password "$AC_PASSWORD" \
     --team-id "$TEAM_ID" \
     --wait
   ```

4. **Staple** the notarization ticket so it works offline:
   ```bash
   xcrun stapler staple <archive.dmg|.app|.pkg>
   ```

## CI architecture

- Build on Linux (Docker) for speed
- Sign on macOS runner via artifact upload/download
- Avoids Docker limitations on GitHub macOS runners

## Tooling alternative

Mitchell Hashimoto's `gon` tool wraps signing+notarization; configure via JSON specifying binary path, bundle ID, signing identity. Less ceremony than raw `codesign`+`notarytool`.

## Cross-references

- [[cargo-dist]] — has macOS signing configuration support (v0.30+)
- [[Rust Apple iOS platform support]] — separate signing path (Xcode/iOS App Store)
