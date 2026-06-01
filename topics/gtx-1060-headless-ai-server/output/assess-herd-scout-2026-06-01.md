---
title: "Repo Comparison: herd-scout vs gtx-1060-headless-ai-server + rust-multi-platform Wikis vs Market"
type: comparison
sources:
  - gtx-1060-headless-ai-server/wiki/concepts/farm-vision-on-gtx-1060.md
  - gtx-1060-headless-ai-server/wiki/concepts/gpu-bench-and-smoke-tests.md
  - gtx-1060-headless-ai-server/wiki/concepts/gpu-thermals-and-ops.md
  - gtx-1060-headless-ai-server/wiki/concepts/ctranslate2-quantization-on-pascal.md
  - gtx-1060-headless-ai-server/wiki/concepts/pascal-driver-cuda-pinning.md
  - gtx-1060-headless-ai-server/wiki/concepts/headless-ubuntu-laptop-baseline.md
  - gtx-1060-headless-ai-server/output/playbook-gtx-1060-headless-ai-server-2026-05-21.md
  - gtx-1060-headless-ai-server/output/plan-gs63vr-headless-server-2026-05-21.md
  - rust-multi-platform/wiki/concepts/mobile-ffi-decision-tree.md
  - rust-multi-platform/wiki/concepts/ios-xcframework-aar-pipeline.md
  - rust-multi-platform/wiki/concepts/desktop-cross-compile-and-package.md
  - rust-multi-platform/wiki/concepts/ui-framework-decision.md
  - rust-multi-platform/wiki/topics/rust-multi-platform-synthesis.md
generated: 2026-06-01
repo: /Users/garykrause/repos/herd-scout
wikis:
  - gtx-1060-headless-ai-server
  - rust-multi-platform
---

# herd-scout vs Knowledge Bases vs Market

## Executive Summary

**herd-scout** is a Rust + Android livestock-CV system with a noticeably mature
shape: a daemon owning an Iroh endpoint with five ALPNs (MoQ video, gossip,
SSH bridge, admin RPC, batch upload), an egui desktop GUI, an Android phone
publisher (CameraX → H.264 → MoQ), an Android admin APK (allowlist + audit log),
a `herdctl` CLI (SSH ProxyCommand + push/uploads), versioned ed25519 identity,
and a Python YOLO11s + ByteTrack sidecar over a Unix socket. Wave 13 just
shipped batch video upload; Wave 12 shipped the Android admin app and the
single-slot fleet model.

The two wikis it draws on cover **complementary** halves of the build:
`gtx-1060-headless-ai-server` is the load-bearing reference for the CV sidecar
(YOLO11s on 6 GB Pascal, ByteTrack, `supervision`, GPU thermals/ops), and
`rust-multi-platform` is the reference for distribution (cargo-ndk + AAR for
Android, cargo-dist for desktop, eventual iOS via UniFFI + xcframework). Most
of what herd-scout has built lines up with established wiki guidance — but it's
also done substantial work the wikis don't yet reflect (MoQ-over-Iroh, multi-ALPN
routing, single-slot fleet identity, audit-log RPC, BLAKE3 clip integrity).

The market check is the more interesting result. **Pure-CV cattle competition
is thinner than it looks**: Cattle-Eye is the only commercial pure-CV
incumbent; OneCup AI exited the cattle market; Halter / Nedap / Allflex /
smaXtec are wearables, not vision; and the closest open-source analogs
(`cow_tracking`, `livestock-detection-yolo`, AeroCensus) are research scripts,
not products. herd-scout's daemon + admin + p2p sync is a genuine
productization moat. The largest immediate technology gaps are around model
freshness (YOLO11s is one generation behind YOLO26 as of Jan 2026), tracking
robustness for occlusion-heavy scenes (BoT-SORT or SAM 2 over ByteTrack),
USDA EID 840 RFID compliance integration, and fine-tuning on operator data.

The single highest-ROI item flagged in this assessment: **retrain on YOLO26
and benchmark on the same Pascal hardware** — same model family, NMS-free head,
~43 % faster CPU inference, and natively supported across the export targets
the sidecar already uses.

## Repo Overview

- **What it is**: P2P-first, edge-friendly livestock CV — Rust desktop daemon + GUI, Android phone publisher, Android admin APK, `herdctl` CLI, Python YOLO11s + ByteTrack sidecar, all wired through one Iroh endpoint with five ALPNs.
- **Tech stack**:
  - Rust workspace (`herd-scout-daemon`, `herd-scout-gui`, `herd-scout-ipc`, `herd-scout-identity`, `herdctl`, `android-jni`) on tokio + serde
  - Networking: `iroh` 0.98, `iroh-gossip`, `iroh-tickets`, `moq-lite`/`moq-relay`, `web-transport`; vendored `iroh-live`
  - Storage: `iroh-smol-kv` (KV CRDT, deliberately *not* iroh-docs), Room SQLite on Android
  - Crypto / integrity: ed25519 identities (versioned TOML envelope), BLAKE3 clip hashing
  - GUI: `egui`/`eframe` desktop; Jetpack Compose + Kotlin 2.1 + AGP 8.7 for both Android apps
  - JNI: `jni` 0.21 + `ndk` 0.9, arm64-v8a only (API 26+)
  - CV sidecar: Python + `onnxruntime-gpu` 1.23 with CUDA EP, YOLO11s with embedded NMS, ByteTrack
  - Deploy: systemd units for daemon + sidecar; Linux/macOS desktop targets
- **Key features** (from Phase 1 source-anchored scan):
  1. **QR-pairing live broadcast** — desktop mints an iroh-live ticket, phone scans QR, CameraX → 720p H.264 → MoQ to daemon (`android-jni/src/streaming.rs:1-120`).
  2. **Live CV overlay** — daemon decodes frames, posts BGR24 to Python sidecar over UDS, returns YOLO11s detections + ByteTrack IDs, GUI overlays at ~33 ms/frame (`herd-scout-daemon/src/cv/model.rs:1-150`).
  3. **Statistical herd report** — 30-frame median windows, ≥15-frame eligibility, 150-px centroid jump filter, bootstrap 95 % CI, deterministic seed from clip hash (`herd-scout-daemon/src/upload/report.rs:1-90`).
  4. **Batch video upload (Wave 13)** — `herdctl push <node-id> <video.mp4>` over `herd-scout/upload/1` ALPN; daemon imports via iroh-blobs, queues, returns BLAKE3, GUI shows progress (`herdctl/src/main.rs:19-58`).
  5. **iroh-bound SSH bridge (Wave 11)** — `herdctl proxy <node-id>` byte-pumps a QUIC stream into `OpenSSH ProxyCommand`, gated by NodeId allowlist on `herd-scout/ssh/1`.
  6. **Admin RPC plane (Wave 12)** — fourth ALPN `herd-scout/admin/1`; Android admin APK adds/removes allowlist entries, queries status, tails audit log (paginated `TailAudit` RPC).
  7. **Single-slot fleet model (Wave 12)** — at most one active iroh Connection per phone; switching daemons tears down and reconnects (no multiplexing); up to 10 saved daemons in admin app SharedPreferences.
  8. **Versioned identity envelope** — TOML schema v1, node_id integrity check, auto-migration on upgrade; shared by daemon, herdctl, admin APK; SAF-based export/import.
  9. **Append-only audit log** — JSONL, daily rotation, 90-day retention, surfaced via admin app.
  10. **Reconnection UX** — daemon returns to Idle on cancel/drop and republishes pairing automatically.
- **Build/deploy targets**: Linux + macOS desktop; Android arm64-v8a (API 26+); systemd-managed Linux headless. iOS not targeted yet (consistent with `gtx-1060-headless-ai-server` plan: "iOS deferred to v2").
- **Notable design decisions called out in `.wiki/`**:
  - Five ALPNs on a *single* iroh endpoint to reduce port pressure / firewall friction.
  - CV sidecar pivot (Wave 6.5): abandoned in-process `ort` on Pascal due to static-init deadlock; Python subprocess + framed binary protocol over UDS proved more reliable.
  - "Phone-as-dumb-camera" — all CV inference on desktop; phone only encodes H.264.
  - `iroh-smol-kv` chosen over `iroh-docs` — KV CRDT is simpler reasoning surface than JSON CRDT for this fleet.
  - Drone-agnostic MVP — phone works whether bolted to DJI / ArduPilot / vehicle dash / hand.

## Alignment (Repo + Wiki agree)

| Feature | Repo Implementation | Wiki Research | Notes |
|---|---|---|---|
| YOLO + ByteTrack on 6 GB Pascal | YOLO11s w/ embedded NMS, ByteTrack, ONNX Runtime CUDA EP via Python sidecar | `farm-vision-on-gtx-1060` recommends YOLO11s @ 640 px / batch 8 + ByteTrack + Roboflow `supervision` line/polygon zones, validated against AerialCattle2017 | Direct match; counting primitives in repo align with wiki recipe. |
| Sidecar / out-of-process inference | Python sidecar over UDS, framed binary protocol, BGR24 in / detections out | Wiki playbook treats Python inference as the established pattern on Pascal (CTranslate2 / faster-whisper / pyannote pipelines all run as separate processes) | Repo took the harder lesson the wiki implies — abandoned in-process `ort` after static-init deadlock on Pascal, now matches wiki's process-isolation pattern. |
| Pascal driver / CUDA pinning | Sidecar relies on CUDA 12.x EP; daemon's `.wiki/` pins driver 535 LTS for Pascal | `pascal-driver-cuda-pinning` mandates 535 LTS + CUDA 12.x, no CUDA 13+, apt preferences pinning | Aligned. |
| GPU thermals + persistence-mode | systemd units in `deploy/systemd/`; `.wiki/` references `nvidia-smi -pl` and persistence | `gpu-thermals-and-ops` codifies `nvidia-smi -pl 65W`, persistence mode, nbfc-linux fan fallback | Aligned in spirit; verify the systemd unit actually applies the wattage cap. |
| Headless Ubuntu baseline | GTX 1060 GS63VR + headless Linux deployment documented in `.wiki/` | `headless-ubuntu-laptop-baseline` covers SSH, lid-close masking, Optimus, BIOS quirks for the same MSI laptop | Direct lift; wiki playbook is essentially the deploy target. |
| Multi-ABI Android JNI | `android-jni` cdylib, `cargo-ndk` workflow, arm64-v8a (API 26+) | `mobile-ffi-decision-tree` flags hand-rolled JNI as a valid path for perf-critical / opaque-handle work | Aligned, with caveat below (UniFFI is recommended default; see Opportunities). |
| Desktop cross-compile mindset | Rust workspace already structured for desktop binaries | `desktop-cross-compile-and-package` documents the 3-runner GitHub Actions matrix + `cross` / `cargo-zigbuild` / `cargo-xwin` + `cargo-dist` | Repo is set up for it but doesn't yet ship the matrix — see Opportunities. |
| Iroh + p2p-first architecture | One iroh endpoint, five ALPNs, no central server | Both wikis lean on iroh as the transport (gtx-1060 plan refers to dumbpipe/iroh for SSH; rust-multi-platform synthesis discusses Iroh after iroh-ffi archive) | Strong alignment. Repo goes well beyond what either wiki currently documents. |
| BYO open-source CV stack | YOLO11s + supervision-style counting | `farm-vision-on-gtx-1060` warns off AGPL-3.0 Ultralytics for closed shipping → Roboflow `supervision` (MIT) is the safe primitive | License posture worth confirming in repo `Cargo.toml` / sidecar `requirements.txt`. |

## Research Gaps (Repo does it, Wiki doesn't cover it)

| Repo Feature | What's missing from wiki | Suggested research |
|---|---|---|
| MoQ-over-Iroh broadcast (`moq-lite` + `moq-relay` + `moq-media` + vendored `iroh-live`) | Neither wiki covers Media-over-QUIC. The rust-multi-platform synthesis mentions Iroh broadly; nothing on MoQ live broadcast wiring. | `/wiki:research "Media-over-QUIC moq-lite + iroh integration patterns 2026"` |
| Multi-ALPN routing on a single iroh endpoint (5 ALPNs) | Neither wiki documents how to run video / gossip / SSH / admin RPC / blob upload on one Router | `/wiki:research "iroh Router multi-ALPN dispatch best practices"` |
| Single-slot fleet model (one active connection per phone, daemon switching tears down) | Neither wiki has a "fleet identity / slot model" article; rust-multi-platform's mobile FFI piece doesn't reach this layer | `/wiki:research "single-slot edge fleet identity patterns: Tailscale tagged keys, Kubernetes StatefulSet, balena fleet, mender"` |
| Versioned ed25519 identity envelope (TOML, schema v1, node_id integrity check) | Wiki has nothing on identity-file design / migration | `/wiki:research "long-lived signed identity envelopes for Rust + Android — TOML / CBOR / Protobuf, key rotation"` |
| Append-only JSONL audit log + paginated `TailAudit` RPC over admin ALPN | No coverage of audit-log primitives in either wiki | `/wiki:research "append-only audit logs for edge fleet RPC: rotation, retention, query patterns"` |
| BLAKE3 clip integrity + iroh-blobs as upload primitive | gtx-1060 wiki references iroh broadly; no article on iroh-blobs-as-upload-channel | `/wiki:research "iroh-blobs for resumable file uploads + BLAKE3 verification on the wire"` |
| QR ticket pairing flow (server-displays-QR, phone-scans, iroh ticket) | No wiki article on the cryptography or UX of QR pairing | `/wiki:research "QR pairing protocols: Tailscale device-link, Plex claim, Magic Wormhole, Noise IK over Iroh"` |
| Statistical herd-count report (median window, eligibility, bootstrap CI, deterministic seed) | gtx-1060 wiki covers detection + counting *primitives* but not the statistical aggregation layer | `/wiki:research "robust herd counting from MOT outputs: eligibility windows, ID-switch correction, bootstrap confidence intervals"` |
| `herdctl proxy` for OpenSSH ProxyCommand over iroh | No wiki article on iroh-bound SSH bridges (gtx-1060 plan only references dumbpipe) | `/wiki:research "iroh-as-SSH-transport: ProxyCommand integrations, allowlist gate patterns"` |
| Drone-agnostic phone-on-drone capture (CameraX foreground service, screen-locked broadcast) | Wikis don't cover phone-as-payload airframe pattern | `/wiki:research "phone-on-drone airframes: power, mounts, thermal, foreground-service constraints"` |

## Opportunities (Wiki knows it, Repo doesn't do it)

| Wiki Knowledge | Potential feature | Priority | Complexity |
|---|---|---|---|
| `desktop-cross-compile-and-package` — 3-runner GH Actions matrix + `cargo-dist` v0.31 + signing | Ship signed releases of `herdctl` / GUI / daemon for Linux / macOS / Windows (currently only deploy is systemd on Linux) | High | M — mostly config; macOS notarization + Windows signing add real cost ($10/mo Azure Trusted Signing) |
| `mobile-ffi-decision-tree` — UniFFI is the default for app-internal Rust cores | Migrate `android-jni` from hand-rolled `jni-rs` to UniFFI for non-perf-critical surfaces (admin RPC, identity, control); keep raw JNI only for the camera/video hot path | Medium | M — incremental; reduces binding maintenance |
| `ios-xcframework-aar-pipeline` | iOS admin app (mirror of Android admin APK) — Swift + UniFFI-wrapped core, SPM binary distribution | Medium | L — full new platform, but pipeline is well-trodden in wiki |
| `gpu-bench-and-smoke-tests` — `gpu-burn COMPUTE=6.1`, layer-5 microbench targets, DCGM-exporter | Add a `herdctl bench` subcommand or `make smoke` target that runs gpu-burn + a YOLO-FPS warmup before declaring a node ready | Medium | S |
| `ctranslate2-quantization-on-pascal` lessons (no FP16, only INT8 / FP32) | Document and assert in the sidecar startup that FP16 engines are rejected on sm_61; pre-warm with FP32/INT8 only | Low | S |
| `farm-vision-on-gtx-1060` — Roboflow `supervision` MIT-licensed counting primitives | Confirm sidecar is using `supervision` (MIT), not Ultralytics' AGPL-3.0 line counters; if not, swap | High | S |
| `farm-vision-on-gtx-1060` — AerialCattle2017 / Roboflow Universe livestock datasets | Add a fine-tune target: train on customer-paddock images + AerialCattle2017 + a HuggingFace dataset (e.g. `eelianafang/MOUNT-Cattle`); ship per-customer weights via iroh-blobs | High | M |
| Wiki playbook structure (gtx-1060 has a 7-phase playbook) | Promote `.wiki/` content into a public `README.md` + `docs/` (Phase 7 of repo doc-scan flagged "no root README") | High | S |
| `ui-framework-decision` — egui is fine for tools/dashboards, no Rust UI framework has production mobile a11y | Stay on egui for desktop, native Compose on Android (already correct); explicitly *not* Tauri Mobile | Confirmation only | — |

## Market Gaps (Neither covers, but competitors / market does)

| Capability | Who has it | Relevance | Notes |
|---|---|---|---|
| YOLO26 (Jan 2026) — NMS-free, ~43 % faster CPU, better small-object | Ultralytics; same export targets as YOLO11 | High — drop-in replacement for YOLO11s with material gains on Pascal | Highest-ROI single change in this assessment |
| BoT-SORT default tracker (Ultralytics ships it default over ByteTrack) + OC-SORT for non-linear motion | Industry consensus 2025-2026 for non-rigid subjects | High — cattle in pens / through gates have non-linear motion + occlusion | A/B against current ByteTrack on bunching scenes |
| SAM 2 video memory tracking | Meta SAM 2; integrated with YOLO via Grounded-SAM-2 | Medium — keeps stable IDs through bunching where ByteTrack drops | Sidecar GPU only |
| Open-vocabulary detection (YOLO-World, Grounded-SAM-2) | Ultralytics, IDEA Research | Medium — operator queries like "limping cow", "calf near fence" with no retrain | Differentiator if operator UX needs ad-hoc queries |
| 2 B-class on-prem VLM for natural-language event summaries (SmolVLM) | HuggingFace SmolVLM, Apr 2025 | Medium — fits on Pascal alongside YOLO; "3 calves entered paddock 4 at 06:12" | Operator-facing; no cloud |
| RFID 840 EID integration (USDA mandate Nov 2024) | Allflex / Tru-Test / Datamars / Gallagher EID readers | Very High — every US customer now has RFID-tagged cattle by regulation | `.wiki/` already plans `herd-scout-eid` crate; market makes this a near-term feature, not a roadmap line item |
| Visual ear-tag OCR + RFID fusion (audit-trail tag reads) | Niche academic; not productized in OSS | Very High — defensible feature; vision cross-checks RFID, flags mis-reads | Strong fit for Iroh-signed events |
| Body condition scoring (BCS) | Cattle-Eye (commercial pure-CV incumbent) | Medium-High — Cattle-Eye's headline feature; absent from herd-scout | Possible separate model head on top of detection |
| Lameness / gait analytics via dense point tracking | CoTracker3 (Meta, Oct 2024) | Medium — high-value vet signal; ByteTrack cannot produce it | 12-18 mo horizon |
| Cloud-free farm-data sovereignty + PQ crypto | Iroh 1.0-rc (May 2026) shipped post-quantum key exchange | High — explicit differentiator vs every cloud-SaaS competitor | Pin Iroh 1.0 before Sep 2026 |
| Capacitor / PWA operator app | Industry trend; not a competitor product per se | Low-Medium — could halve operator-app maintenance long-term | Risk: Iroh JNI bindings are smoother native |

## Competitive Landscape

| Competitor / Tool | Overlap with herd-scout | Unique features | Weaknesses |
|---|---|---|---|
| **Cattle-Eye** (cattleeye.com) | Pure-CV cattle product | Body-condition scoring, lameness scoring at parlour exit, validated; integrates with herd mgmt SaaS | Dairy parlour-only; cloud-dependent; no edge / on-prem story; no open data layer |
| **OneCup AI / OneKind AI** (onekind.ai) | Was cattle-CV; **pivoted to companion-animal pharma** | (n/a — exited cattle market) | herd-scout effectively inherits an open lane |
| **Halter** (halterhq.com) | Adjacent (collars + virtual fencing) | Solar GPS collars, virtual fencing, ~400 k animals, $100 M Series D 2025 | No CV / imagery layer; collar capex; cloud SaaS |
| **Nedap CowControl** | Sensor wearables (no CV) | 50 yr brand, distributed via Lely / GEA / Alta | No video; closed ecosystem; expensive per-animal hardware |
| **smaXtec** | Rumen bolus sensors | Earliest disease detection (~5 day lead) via core temp / pH | No visual context; invasive bolus per animal |
| **HerdDogg** | BLE ear tags + solar gateways | Cheap (~8¢/animal/day claim), beef-targeted | Low-fidelity behavioral data only; no imagery |
| **Allflex SenseHub** (MSD/Merck) | Ear-tag / collar accelerometer | Global dairy + beef distribution | No vision component |
| **Connecterra** | Pivoted to dairy data-integration / AI Copilot | Pulls from EZfeed / GEA / Lely | Now an analytics layer — possible *integration target*, not competitor |
| **Vence** (Merck) | Virtual fencing collars (rangeland) | Acquired by Merck 2022; still active | Same gap as Halter — no CV |
| **Aquabyte** (aquaculture) | Adjacent species, similar architecture | Hardware-first capex, ~1.3 M images/day/camera, 8 yr data, 800+ systems | Inverse capex model from herd-scout's BYO-camera/edge play |
| **ReelData** (RAS aquaculture) | IP-camera + AI for biomass + appetite | Strong "appetite-driven feeding" loop | Cloud SaaS only |
| **Wild Me / Wildbook** | Adjacent (wildlife conservation) | 12 yr OSS, 53 species, 7 ID algorithms, 74 peer-reviewed pubs | Centralized server model; research-org distribution |
| **AeroCensus Livestock Detection** (GitHub `filatovcv/aerocensus-livestock-detection`, Mar 2026) | Closest open-source aerial-cattle benchmark | Multi-architecture comparison (YOLO / Faster R-CNN / RT-DETR / EfficientDet / SAM 2), planned CC BY 4.0 dataset | Pre-release; no production deployment |
| **`MenesesCarlos29/livestock-detection-yolo`** (Dec 2025) | YOLOv8-Nano fine-tuned for edge | Single-script reference impl | No daemon / fleet / sync |
| **`Donatien-Wallaert/cow_tracking`** (Apr 2026) | Multi-camera cattle tracking | YOLOv11 + SAM3 + Random Forest cross-camera handover (more sophisticated than ByteTrack alone) | Research code; no productization |
| **`AdamLt-GH/yolo_livestock_detection`** (Sep 2025) | YOLOv11 sheep/cattle real-time | Capstone-tier reference impl | Not productized |

**Strategic read**: pure-CV cattle competition is genuinely thin — Cattle-Eye is the only commercial pure-CV incumbent and is dairy-parlour-only; OneCup exited; the wearable/collar/RFID/bolus stack solves a different problem; OSS is research scripts. herd-scout's daemon + Android operator + admin + Iroh sync is a real productization moat. The white space sits at **aerial / drone cattle counting** and **beef-extensive (vs. dairy-parlour) CV**.

## Emerging Trends

(All horizons relative to today, 2026-06-01.)

- **Now**: YOLO26 (Jan 2026) is the production edge default — drop-in retrain likely yields free latency + small-cattle accuracy gains on Pascal. **YOLOv12 is research-only**; Ultralytics explicitly recommends YOLO11/YOLO26 for production. **Iroh 1.0-rc** (May 2026) and post-quantum key exchange landed — pin Iroh 1.0 before Sep 2026. **USDA EID 840 RFID** rule in force since Nov 2024 — every US cattle customer now has electronically-readable cattle by regulation.
- **6 mo**: **BoT-SORT / OC-SORT** as ByteTrack alternatives for non-linear motion + occlusion. **SAM 2 video memory tracking** for stable IDs through bunching events (sidecar GPU only). **OpenVINO** mainlines Intel NPU + ARM CPU paths for YOLOv11/26 — opens a non-NVIDIA sidecar SKU. **Apple Core ML 2025-2026** normalizes on-device YOLO/VLM — feasible iOS operator path.
- **6-12 mo**: **YOLO-World / Grounded-SAM-2** for open-vocabulary livestock queries ("calf near fence", "limping cow") without retrain. **SmolVLM-class 2 B VLMs** for on-prem captioning and triage — fits alongside YOLO on a Pascal GPU.
- **12-18 mo**: **CoTracker3** for fine-grained motion (gait / lameness) — high-value vet signal ByteTrack can't produce. **WebGPU browser CV** for zero-install operator UX (YOLO inference in browser on Pixel/iPhone NPUs). **RT-DETRv4 + VFM-boosted lightweight detectors** as a credible alternative if cattle re-id needs richer features. **Capacitor / PWA + on-device CoreML/TFLite** could collapse Android admin APK + future iOS admin into one TS codebase. **Automerge 3.0** (Jul 2025, >10× memory cut) opens a CRDT layer for cattle inventory / paddock annotations / operator notes over Iroh.
- **Watch**: `iroh-willow` (still "in construction" — defer ≥12 mo); `iroh-docs` evolution; HuggingFace cattle dataset coverage continuing to grow (`eelianafang/MOUNT-Cattle`, `Arvin26/cattle-detection`, CattleFace-RGBT, CattleSSFR, africa-sahel cattle-theft probability).

## Recommended Actions

### Research (fill wiki gaps)

1. `/wiki:research "Media-over-QUIC moq-lite + iroh integration patterns 2026"` — herd-scout is using this stack at depth and the wikis don't reflect it.
2. `/wiki:research "iroh Router multi-ALPN dispatch best practices"` — five ALPNs on one endpoint is herd-scout's signature; no wiki coverage.
3. `/wiki:research "single-slot edge fleet identity patterns: Tailscale tagged keys, Kubernetes StatefulSet, balena fleet, mender"` — the Wave 12 fleet model has no prior-art article.
4. `/wiki:research "QR pairing protocols: Tailscale device-link, Plex claim, Noise IK over Iroh"` — herd-scout already does this; market check confirms it's a real pattern worth codifying.
5. `/wiki:research "iroh-blobs for resumable file uploads + BLAKE3 verification"` — Wave 13's foundation.
6. `/wiki:research "YOLO26 vs YOLO11 for livestock CV on sm_61 Pascal — benchmark, fine-tune recipes"` — the highest-ROI build action also belongs in the wiki as research first.
7. `/wiki:research "robust herd counting from MOT outputs: eligibility windows, bootstrap CI, ID-switch correction"` — herd-scout has the only impl in our corpus; deserves an article.
8. `/wiki:research "USDA EID 840 RFID readers (Allflex, Tru-Test, Datamars, Gallagher) — Bluetooth/USB protocols, OSS bridges"` — required for the planned `herd-scout-eid` crate.

### Build (feature candidates ranked by impact × feasibility)

1. **YOLO26 retrain + Pascal benchmark** — high impact, low cost. Same export targets, same sidecar wiring.
2. **`herdctl bench` smoke-test subcommand** — wraps `gpu-burn COMPUTE=6.1` + YOLO-FPS warmup + audio bench (if relevant); turns the gtx-1060 wiki playbook into a one-shot command.
3. **License audit on the sidecar** — confirm Roboflow `supervision` (MIT) is what's used for line/zone counting, not AGPL-3.0 Ultralytics counters.
4. **Public `README.md` + `docs/`** — docs scan flagged the missing root README; promotes `.wiki/` artifacts to user-facing.
5. **GH Actions desktop release matrix + `cargo-dist`** — ship signed installers for `herdctl` + GUI on Linux / macOS / Windows.
6. **`herd-scout-eid` crate** — already in the roadmap; market check (USDA mandate) makes it near-term.
7. **Fine-tune pipeline + per-customer weights distribution via iroh-blobs** — combines `farm-vision-on-gtx-1060` with HuggingFace cattle datasets and herd-scout's own transport.
8. **A/B BoT-SORT / OC-SORT vs ByteTrack on bunching scenes** — small experiment, potentially large UX win on ID stability.
9. **Migrate non-perf-critical Android FFI surfaces to UniFFI** — keep `jni-rs` for the camera/video hot path, UniFFI for admin RPC + identity + control.
10. **Iroh 1.0 pin once stable** — schedule before Sep 2026.

### Monitor

- YOLO26 → YOLO27 release cadence and any Pascal-specific regressions
- SAM 2 / Grounded-SAM-2 integration paths into Ultralytics
- `iroh-willow` reaching alpha; Automerge 3.x adoption in Rust ecosystem
- USDA / EU livestock traceability rule deltas (any 2026 amendments to the 840 EID rule)
- Cattle-Eye, AeroCensus, `cow_tracking` repo activity (closest competitive signals)
- Halter and Vence outside-CV moves (in case they bolt on a vision layer)

## Confidence Notes

- **High confidence**: herd-scout architecture and feature inventory (anchored in source-code reads with file:line citations); wiki concept maps (read all concept articles directly); Cattle-Eye / OneCup / Halter / Nedap / Allflex / smaXtec / HerdDogg / Aquabyte / Wildbook market positions; YOLO26 release facts; Iroh 1.0-rc dates; USDA 840 EID rule effective date; OSS competitor repos and last-push dates.
- **Medium confidence**: YOLO26 specific perf claim (~43 % faster CPU vs YOLO11) — repeated by Ultralytics, not independently verified on Pascal; SAM 2 / CoTracker3 fit for cattle specifically (architecturally sound, no production case study found); Capacitor + on-device CoreML maturity for ag operator apps (general trend, not livestock-specific).
- **Lower confidence / speculative**: OneCup AI's *complete* exit from cattle (their public surface is now OneKind AI; treat as exit pending direct confirmation); Faromatics / Tidal status (domains non-responsive on the day of scan — likely dormant but unconfirmed); claim that "white space at aerial / drone cattle CV" is durable (AeroCensus could ship; commercial drone-co could enter).
- **Not validated by this assessment**: herd-scout's accuracy claims (its own `.wiki/` flags MAE ±5-10 % as a target, not a measurement); whether the existing systemd unit actually applies the wiki-recommended `nvidia-smi -pl 65W` cap; whether the sidecar uses Roboflow `supervision` (MIT) vs Ultralytics counters (AGPL-3.0).


