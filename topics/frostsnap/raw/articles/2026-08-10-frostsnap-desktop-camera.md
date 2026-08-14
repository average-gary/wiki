---
title: "frostsnap_desktop_camera: QR Camera Capture for Desktop"
source: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnapp/desktop_camera/README.md"
type: articles
ingested: 2026-08-10
tags: [frostsnap, qr-scanning, camera-capture, v4l2, media-foundation, cross-platform, mobile-scanner]
summary: "Camera capture library backing QR scanning in the Frostsnap desktop app: V4L2 via the v4l crate on Linux, Media Foundation on Windows. On macOS capture is delegated to the Flutter mobile_scanner package instead, so the Rust crate covers only the two desktop platforms lacking a usable Flutter path."
collection: "frostsnap"
adapter: git
upstream_id: "frostsnapp/desktop_camera/README.md"
upstream_type: git-file
revision: "c319850a77cf077febbd9bccd9dffdf7b666b009"
sha: "b3fb7e75f1ffda86638929bd69b5456cd64fe3ef"
canonical_url: "https://github.com/frostsnap/frostsnap/blob/c319850a77cf077febbd9bccd9dffdf7b666b009/frostsnapp/desktop_camera/README.md"
content_format: markdown
license: "MIT"
fetched: 2026-08-10
---

# frostsnap_desktop_camera

Camera capture library for Linux and Windows, optimized for QR scanning.

- **Linux**: Uses V4L2 via the `v4l` crate
- **Windows**: Uses Media Foundation

On macOS, camera capture is handled by the Flutter `mobile_scanner` package instead.

---

## Ingest note

QR scanning is a transport surface for the coordinator app. The docs ingested in
this collection do not specify what is conveyed over QR (share backups,
addresses, PSBTs, or device certificates); that would need to be established
from `frostsnap_comms`/`frostsnap_coordinator` source or product documentation
rather than inferred here. This crate is a `default-members` workspace entry, so
it builds on a plain root `cargo check`.
