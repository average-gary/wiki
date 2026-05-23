---
title: "Plan: Stand up the GS63VR as a headless transcription + farm-vision server"
type: plan
format: roadmap
generated: 2026-05-21
sources:
  - wiki/topics/gtx-1060-headless-ai-server-synthesis.md
  - wiki/concepts/pascal-driver-cuda-pinning.md
  - wiki/concepts/ctranslate2-quantization-on-pascal.md
  - wiki/concepts/faster-whisper-on-gtx-1060.md
  - wiki/concepts/whisperx-vs-manual-pyannote-integration.md
  - wiki/concepts/whisperx-known-broken-installs.md
  - wiki/concepts/pyannote-audio-3.x-on-pascal.md
  - wiki/concepts/farm-vision-on-gtx-1060.md
  - wiki/concepts/headless-ubuntu-laptop-baseline.md
  - wiki/concepts/gpu-bench-and-smoke-tests.md
  - wiki/concepts/gpu-thermals-and-ops.md
  - output/playbook-gtx-1060-headless-ai-server-2026-05-21.md
gap_research:
  - phone-to-server video ingest (MediaMTX + SRT + Larix; NVDEC pull)
  - iroh p2p capabilities (dumbpipe SSH, sendme, iroh-ffi archived)
---

# Plan: Stand up the GS63VR as a headless transcription + farm-vision server

> Generated from [gtx-1060-headless-ai-server](../_index.md) wiki — 11 articles + 30 raw sources + 2 targeted gap-research probes (Iroh p2p, phone-video ingest).

## Executive Summary

Repurpose an MSI GS63VR (Pascal GTX 1060 6GB mobile, i7-7700HQ, 16 GB RAM) as a 24/7 headless Ubuntu 22.04 box that handles **two parallel workloads**: (1) drop-folder audio transcription with speaker diarization via faster-whisper + WhisperX + pyannote.audio, and (2) near-real-time video ingest from a phone over SRT into MediaMTX, with ffmpeg+NVDEC feeding 5 fps frames to a YOLO11 worker. Remote operator access uses **Iroh `dumbpipe`** to expose SSH (port 22) over a p2p tunnel — no router port-forward, no Tailscale.

The wiki already encodes the hardware-forced decisions (proprietary NVIDIA driver, CUDA 12.x ceiling, `compute_type=int8`, msi-ec unimplemented for GS63VR). This plan layers: phasing across two parallel tracks, the data-flow architecture, the cutover/rollback discipline, and per-phase "done" criteria.

## Architecture Decisions

### Decision 1 — Two parallel workload tracks share one base system, NOT one service per track

**Context**: User chose "Parallel tracks." [synthesis] establishes a shared baseline (driver/CUDA/thermals/ops). Both audio and vision workloads run as **isolated systemd services with separate venvs and HF caches** so they version-pin independently.

**Options considered**:
- **A. Separate services, shared driver/CUDA, shared GPU** ← chosen
- B. Containerize each workload (Docker + nvidia-container-toolkit)
- C. Single monolithic worker process

**Decision**: A. Containers add a layer that doesn't earn its weight on a single-tenant box, and the [pinned driver/CUDA approach](../wiki/concepts/pascal-driver-cuda-pinning.md) means one apt source-of-truth across services. Two systemd units (`whisper-server`, `vision-server`) keep restart/log boundaries clean.

**Consequences**: GPU contention is real on 6 GB — a long whisper job + simultaneous YOLO inference can OOM. Mitigation: per-service `MemoryMax`, plus a small **arbiter** that pauses video frame-grabbing when audio is processing a >large-v3 job. For v1, **don't co-schedule**: audio drop-folder runs in the off-hours; video runs when a phone is actively pushing.

### Decision 2 — Audio model: distil-large-v3 + int8

**Context**: [faster-whisper-on-gtx-1060](../wiki/concepts/faster-whisper-on-gtx-1060.md) — large-v3 int8 fits in ~3 GB; distil-large-v3 fits in ~1.5–2 GB. [ctranslate2-quantization-on-pascal](../wiki/concepts/ctranslate2-quantization-on-pascal.md) — `compute_type="float16"` silently demotes to fp32 on Pascal CC 6.1.

**Options**:
- A. **distil-large-v3 + int8** (recommended) — half the VRAM, ~6.3× faster, +1.3 WER short-form, slightly better long-form
- B. large-v3 + int8 — best accuracy at 3 GB; tighter VRAM if pyannote co-loads
- C. large-v3-turbo + int8 — fastest (~60× RTFx), 1.5 GB, similar accuracy to distil

**Decision**: Default to **A (distil-large-v3 + int8)**. Add a CLI flag `--accuracy hi` to switch to large-v3 when the user has a recording where WER matters. Never expose `float16` as an option — it's a footgun on Pascal.

### Decision 3 — Diarization: WhisperX wrapping pyannote 3.1 (NOT 4.x community-1)

**Context**: [whisperx-vs-manual-pyannote-integration](../wiki/concepts/whisperx-vs-manual-pyannote-integration.md) recommends WhisperX. [whisperx-known-broken-installs](../wiki/concepts/whisperx-known-broken-installs.md) documents the WhisperX 3.8.5 / pyannote 4.x `use_auth_token` mismatch (issue #1406) and the lightning-quarantine issue (#1412).

**Options**:
- A. WhisperX + pyannote 4.x community-1 — best DER, license is CC-BY-4.0
- B. **WhisperX + pyannote 3.1** ← chosen — known-working, MIT license, verified against issue #1406
- C. whisper-diarization (NeMo, no HF gating) — needs ≥10 GB for `diarize_parallel`; only sequential mode fits 6 GB

**Decision**: B. The DER delta from 4.x is small (AMI IHM 18.8% → 17.0%) and not worth fighting issue #1406 in v1. Revisit after WhisperX 3.9.x lands a fix.

### Decision 4 — Video ingest: phone → SRT → MediaMTX → ffmpeg-NVDEC → Python YOLO

**Context**: User wants reliability over latency for phone-streamed video. Wiki had no coverage; gap research identified **MediaMTX** as the single-binary daemon that speaks SRT/RTSP/RTMP/WebRTC/HLS and natively records segments. **SRT** is purpose-built for unreliable WAN (ARQ retransmit). [farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md) confirms YOLO11s as the right model for 6 GB. Pascal NVDEC supports H.264 + HEVC 8-bit (no AV1, no HEVC 10-bit).

**Options**:
- A. RTSP from phone (IP Webcam app) — simplest, LAN-only
- B. RTMP push from phone — fine on stable Wi-Fi
- C. **SRT push from phone (Larix Broadcaster) → MediaMTX → local RTSP pull** ← chosen
- D. WebRTC — high signaling complexity for a single phone

**Decision**: C. SRT survives flaky cellular/Wi-Fi via ARQ; MediaMTX republishes as local RTSP so the ffmpeg→YOLO pipeline doesn't care which protocol the phone uses. Force **H.264** in Larix settings — Pascal NVDEC is fine with it; iPhone HEVC HDR (Main10) would silently fall back to CPU.

### Decision 5 — Iroh as the **only** transport: SSH + Android phone (live + blob), iOS deferred to v2 (native app)

**Context**: User chose Iroh p2p for everything, including phone video, with both live and batched-blob fallback. Gap research found `iroh-ffi` (mobile SDK) was **archived in mid-2025**. As of May 2026 the situation per platform is:

| Platform | dumbpipe / sendme available? | Live SRT-in-tunnel feasible? | Blob fallback feasible? |
|----------|------------------------------|------------------------------|-------------------------|
| Linux server | Yes (Cargo, distro) | N/A (server side) | N/A (server side) |
| Operator laptop | Yes (Cargo, Homebrew) | Yes | Yes |
| **Android** | Yes — via **Termux** (`pkg install rust && cargo install dumbpipe sendme`) | Yes — Larix pushes SRT to `127.0.0.1:8890`, Termux dumbpipe forwards over iroh | Yes — Termux + sendme |
| **iOS** | **No** — no Termux equivalent, no published iroh CLI, no maintained iOS bindings | **No** — requires native Swift app with custom Rust+UniFFI bindings (4+ weeks dev) | **No** — same |

**Options considered**:
- A. **Android-via-Termux now; iOS as v2 native-app project** ← chosen
- B. Tailscale fallback for iOS only — rejected (user explicitly asked Iroh)
- C. Build the iOS native app in v1 — rejected (~4 weeks blocking, archived FFI as starting point)
- D. iOS uses macOS-as-relay (Mac sendme picks up clips AirDropped from phone) — possible v1.5, requires a Mac on the property

**Decision**: A. Ship Android live + blob in v1. **iOS is deferred to v2** as a discrete native-app project. Until then, iOS users either (a) wait for v2 or (b) AirDrop clips to a nearby Mac that runs `sendme send` (out-of-v1-scope manual workflow).

**Iroh roles in this architecture**:
1. **Operator SSH**: server runs `dumbpipe listen-tcp --host localhost:22` (systemd unit). Operator laptop SSHes via `dumbpipe connect-tcp --addr 127.0.0.1:2222 <ticket>`.
2. **Android live video**: Termux on phone runs `dumbpipe connect-tcp --addr 127.0.0.1:8890 <ticket>`; Larix pushes SRT to `srt://127.0.0.1:8890`; traffic tunnels over iroh QUIC to server's MediaMTX. Server runs `dumbpipe listen-tcp --host localhost:8890` (systemd).
3. **Android blob fallback**: when the live tunnel is unreachable, a small Termux script records clips to phone storage and runs `sendme send` per clip. Server runs `sendme receive` in a watcher loop into `~/inbox-vision/`.
4. **Operator file drops** (audio): operator's laptop runs `sendme send recording.wav`; server's `sendme receive` watcher routes to `~/inbox/`.

**Consequences**:
- v1 ships Android-only for phone video. iOS users explicitly held back.
- Phone must run Termux (not great UX, but the only path) + Larix (Android Larix is solid).
- Ticket distribution becomes a real concern — same ticket on phone and operator laptop is fine, but rotation hygiene matters. Document a rotation procedure.
- **No router port-forwarding anywhere.** Server is invisible from the public internet.

### Decision 6 — Audio API: drop-folder watcher

**Context**: User chose drop-folder. Lowest cognitive load, easy to integrate with `rsync`, `scp`, `sendme` (over Iroh!), Syncthing.

**Decision**: `~/inbox/` is watched by `inotifywait`; new file → enqueue → worker transcribes → writes `~/outbox/<basename>.{srt,json,txt}`. Errors go to `~/outbox/errors/<basename>.err`. Atomic rename ensures partial uploads aren't picked up.

**Bonus**: Because Iroh's `sendme` produces a ticket from a local path and the recipient does `sendme receive <ticket>`, the operator can drop a recording onto `~/inbox/` from anywhere in the world by running `sendme send recording.wav` on their laptop, then having the server run `sendme receive` in a watcher loop. (v2 — not v1.)

## Implementation Phases

> **Tracks run in parallel where possible.** Track A (operator-control plane + audio) and Track B (vision + video ingest) only intersect at Phase 0 (shared base). After Phase 1, you can hop between tracks freely.

---

### Phase 0 — Shared baseline (both tracks blocked on this) — ~1 day

**Goal**: From a freshly-flashed Ubuntu Server 22.04, reach the state where `nvidia-smi` reports a GTX 1060 with persistence on, power cap 65 W, gpu-burn passes 1 hour clean.

**Tasks**:
- [ ] Hardware safety: open chassis, **remove battery if any chance of swelling**; reassemble. Order small UPS (CyberPower CP685AVR, ~$60) — install when it arrives.
- [ ] BIOS: Secure Boot **disabled**, Primary Display = **IGFX**, SATA = **AHCI**, Wake-on-LAN **enabled**.
- [ ] Ubuntu Server 22.04 LTS install — minimal + OpenSSH server. Ethernet only (don't trust Killer 1535 Wi-Fi).
- [ ] First-login package set: `build-essential pkg-config git curl wget vim tmux htop python3 python3-venv python3-pip ffmpeg lm-sensors smartmontools ufw fail2ban avahi-daemon ethtool linux-cpupower`
- [ ] Lid + suspend disable per [headless-ubuntu-laptop-baseline](../wiki/concepts/headless-ubuntu-laptop-baseline.md): `/etc/systemd/logind.conf` with all three `HandleLidSwitch*=ignore`; mask `sleep.target suspend.target hibernate.target hybrid-sleep.target`. **Run with lid open** for thermals.
- [ ] SSH hardening + ufw + fail2ban (key-only, deny incoming, ssh allow). Rule: no router port-forward — operator access comes via Iroh in Phase 1.
- [ ] DHCP reservation by MAC on the router; `avahi-daemon` for `<host>.local` mDNS.
- [ ] Wake-on-LAN: `ethtool -s eno1 wol g` + persist via NetworkManager.
- [ ] Install proprietary driver 535-server: `sudo ubuntu-drivers install --gpgpu`; `sudo apt install nvidia-utils-535-server`; `sudo systemctl enable --now nvidia-persistenced`; reboot; `nvidia-smi` confirms CC 6.1.
- [ ] **Pin** `nvidia-* libcuda* cuda-*` to 535 in `/etc/apt/preferences.d/nvidia` (Pin-Priority 1001). Enable `unattended-upgrades` (security only). [pascal-driver-cuda-pinning]
- [ ] systemd oneshot for `nvidia-smi -pm 1 && nvidia-smi -pl 65`. [gpu-thermals-and-ops]
- [ ] CPU side: install `throttled` (Kaby Lake compatible); disable `thermald`; PL1=35W, PL2=45W, undervolt -80mV starting; trip 90°C. Validate with mprime small-FFT 4 hr.
- [ ] CPU governor: `cpupower frequency-set -g schedutil`.
- [ ] Fan control: install `nbfc-linux`, run `nbfc rate-config -a` to see if a GS63VR config exists. If yes, enable. If no, BIOS Cooler Boost button + cooling pad as fallback. [gpu-thermals-and-ops]
- [ ] journald drop-in (`SystemMaxUse=500M MaxRetentionSec=4week`). tmpfs `/tmp` size=4G in `/etc/fstab`.

**Validation**:
- `nvidia-smi` → GTX 1060 6GB, driver 535.x, persistence on, PL=65W
- `python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_capability())"` → `True (6, 1)`
- `gpu_burn` (built with `make COMPUTE=6.1`) — 1 hour clean, peak temp < 82°C with cooling pad. [gpu-bench-and-smoke-tests]
- `stress-ng --cpu $(nproc) --vm 2 --vm-bytes 75% --timeout 600s` — no thermal throttle below 90°C

**Wiki grounding**: [headless-ubuntu-laptop-baseline](../wiki/concepts/headless-ubuntu-laptop-baseline.md), [pascal-driver-cuda-pinning](../wiki/concepts/pascal-driver-cuda-pinning.md), [gpu-thermals-and-ops](../wiki/concepts/gpu-thermals-and-ops.md), [gpu-bench-and-smoke-tests](../wiki/concepts/gpu-bench-and-smoke-tests.md).

---

### Phase 1A — Iroh `dumbpipe` SSH tunnel (Track A) — ~2 hours

**Goal**: Operator can `ssh` into the server from any network on earth by sharing a single ticket, no port-forward.

**Tasks**:
- [ ] Install dumbpipe on server: `cargo install dumbpipe` (or distro/Homebrew if available)
- [ ] systemd unit `iroh-ssh.service`:
  ```
  [Service]
  Type=simple
  User=ai
  ExecStart=/usr/local/bin/dumbpipe listen-tcp --host localhost:22
  Restart=on-failure
  RestartSec=5
  StandardOutput=journal
  ```
- [ ] First start logs the ticket; capture from journal, save to operator's password manager.
- [ ] Operator workstation: `dumbpipe connect-tcp --addr 127.0.0.1:2222 <ticket>` then `ssh -p 2222 user@localhost`.
- [ ] Add `Host gs63vr-iroh` block to `~/.ssh/config` with `ProxyCommand` invoking `dumbpipe connect-tcp` so `ssh gs63vr-iroh` Just Works.
- [ ] Document ticket-rotation procedure (regenerate by restarting the service; share new ticket).

**Validation**: `ssh gs63vr-iroh uptime` works from a laptop on a different network. Test: tether laptop to phone, run again.

**Risks**: Public iroh relays are best-effort. If reliability matters, Phase 1A.5 = self-host `iroh-relay` on a VPS later.

**Wiki grounding**: New gap-fill (no prior wiki article); will compile back to wiki as `concepts/iroh-tunnel-for-headless-server.md` after this plan.

---

### Phase 1B — MediaMTX + Iroh dumbpipe (Track B, server side) — ~1 day

**Goal**: Server is ready to receive SRT from any iroh peer that has the right ticket. MediaMTX records and republishes as local RTSP. **Phone not in this phase yet** — verified with a laptop running dumbpipe + a local SRT pusher.

**Tasks**:
- [ ] Install MediaMTX (single Go binary, latest release as of plan date: v1.18.2). Drop in `/usr/local/bin/`.
- [ ] `/etc/mediamtx.yml`:
  - SRT listener on `127.0.0.1:8890` (loopback only — only iroh-tunneled traffic reaches it)
  - One path `phone` with `recordEnabled: yes`, `recordSegmentDuration: 60s`, `recordDeleteAfter: 24h`, `recordPath: /var/lib/mediamtx/recordings/%path/%Y-%m-%d_%H-%M-%S`
  - Auth: internal user/pass — credentials are still meaningful even with iroh fronting
- [ ] systemd unit `mediamtx.service`, `Restart=on-failure`, `RestartSec=2`, `After=network-online.target`.
- [ ] systemd unit `iroh-srt.service` — wraps dumbpipe:
  ```ini
  [Service]
  Type=simple
  User=ai
  ExecStart=/usr/local/bin/dumbpipe listen-tcp --host localhost:8890
  Restart=on-failure
  RestartSec=5
  StandardOutput=journal
  ```
- [ ] First start logs the **video ticket** (separate from the SSH ticket — different ALPN, different rotation cadence). Capture from `journalctl -u iroh-srt.service`. Save to a secure store.
- [ ] **NO ufw inbound rules opened for SRT.** UDP 8890 stays loopback. Iroh QUIC handles wire transit on its own port (typically random high UDP).
- [ ] Loopback smoke test (server alone, no phone):
  ```bash
  # Push synthetic SRT to localhost
  ffmpeg -re -f lavfi -i testsrc=size=1280x720:rate=30 -t 30 \
    -c:v libx264 -preset ultrafast -tune zerolatency \
    -f mpegts srt://127.0.0.1:8890?streamid=publish:phone
  # In another shell: pull RTSP
  ffplay rtsp://127.0.0.1:8554/phone
  ```
- [ ] Laptop-as-phone smoke test (validates iroh tunnel without needing the phone yet):
  ```bash
  # On operator laptop
  dumbpipe connect-tcp --addr 127.0.0.1:8890 <video-ticket>
  # Then push to laptop's localhost:
  ffmpeg -re -f lavfi -i testsrc=... srt://127.0.0.1:8890?streamid=publish:phone
  ```
- [ ] Frame-grab template (used in Phase 2B):
  ```bash
  ffmpeg -hide_banner -loglevel warning \
    -fflags nobuffer -flags low_delay \
    -rtsp_transport tcp \
    -hwaccel cuda -hwaccel_output_format cuda \
    -i rtsp://127.0.0.1:8554/phone \
    -vf "fps=5,hwdownload,format=nv12,format=bgr24" \
    -f rawvideo -pix_fmt bgr24 -an pipe:1
  ```
- [ ] Validate Pascal NVDEC engagement: `nvidia-smi dmon -s u -c 30` shows non-zero decoder utilization during the laptop test.

**Validation**:
- Synthetic SRT from laptop, tunneled via iroh → MediaMTX receives → RTSP republishes locally → `ffplay` shows it
- `recordings/` has 60s fMP4 segments
- `dumbpipe` ticket survives `systemctl restart iroh-srt.service` (re-emits same identity from saved keystore — verify; if not, document new-ticket distribution)
- No UDP/TCP listener exposed externally (`ss -tlnp`, `ss -ulnp` show no public binds for 8890)

**Wiki grounding**: Gap-fill — will compile to `concepts/iroh-tunneled-srt-ingest.md`.

---

### Phase 1B-Android — Termux + dumbpipe + Larix on phone — ~half day

**Goal**: An Android phone with Termux + Larix pushes live SRT through iroh to the server. **No batched-blob fallback yet** (Phase 2B-fallback below).

**Tasks**:
- [ ] Phone: install **Termux** from F-Droid (NOT Play Store — Play version is abandoned). Update: `pkg upgrade`.
- [ ] Termux: `pkg install rust openssl-tool` then `cargo install dumbpipe sendme` (will take 5-15 min, Rust compile on phone).
- [ ] Termux: write `~/iroh-srt.sh` shell script wrapping `dumbpipe connect-tcp --addr 127.0.0.1:8890 $VIDEO_TICKET` (ticket from Phase 1B). Add to `~/.bashrc` or trigger via Termux:Boot extension on device boot.
- [ ] Phone: install **Larix Broadcaster** from Play Store (Android version is the recommended pick).
- [ ] Larix config:
  - Connection: `srt://127.0.0.1:8890?streamid=publish:phone:<auth>`
  - Encoder: **H.264** (force; not HEVC) — Pascal NVDEC handles HEVC 8-bit but H.264 is the safer commitment ([NVIDIA matrix](../raw/articles/2026-05-21-nvidia-driver-535-supportedchips.md))
  - Resolution: 1280x720 @ 30fps (server downsamples to 5 fps anyway; lower input bitrate = better resilience on weak signal)
  - Bitrate: 2-3 Mbps adaptive
  - Reconnect: enabled, 5s retry
- [ ] Validate live: open Larix, start broadcast → `ffplay rtsp://127.0.0.1:8554/phone` on server should show the phone camera within 3-10 seconds.
- [ ] Stress test: walk phone out of Wi-Fi range (cellular handoff), back into range. Larix should auto-reconnect; server-side MediaMTX republishes seamlessly.

**Validation**: 30-min sustained Larix broadcast from phone over LTE → server receives without manual intervention. `dumbpipe` reconnects across NAT changes (Larix on cellular while moving).

**Wiki grounding**: Gap-fill — will compile to `concepts/android-iroh-video-push.md`.

---

### Phase 1B-iOS — DEFERRED to v2 — ~0 in v1

**Goal in v1**: Document the path. **Don't build.**

**Why deferred**:
- `iroh-ffi` is archived (mid-2025); no maintained Swift bindings.
- No iOS equivalent of Termux that runs Rust binaries (iSH is x86 emulation, too slow for live video).
- Larix-on-iOS is fine, but **its SRT destination must be reachable** — without iroh-on-device, the only path is direct LAN (defeats the user's "iroh only" requirement) or a public relay (defeats "no port-forward").

**v2 work outline** (when prioritized):
1. Build a custom Rust crate wrapping iroh-blobs + iroh-quic; export via UniFFI for Swift.
2. Native iOS app: capture from `AVCaptureSession`, encode H.264 via VideoToolbox, push frames either:
   - (a) directly into iroh-blobs as 60s mp4 chunks (simpler), OR
   - (b) via a local SRT loopback the Rust shim consumes (parallel architecture to Android).
3. Estimated effort: 4-6 weeks for an experienced Swift+Rust developer.

**v1 workaround for iOS users**:
- Record clips locally on iOS (built-in Camera app saves to Photos)
- AirDrop or Files-app-share the clip to a nearby Mac
- Mac runs `sendme send <clip>` → ticket → server's `sendme receive` watcher pulls into `~/inbox-vision/`
- Manual but functional for the small subset of cases where iOS users have a Mac on the property

**Wiki grounding**: Gap-fill — will compile to `concepts/ios-iroh-deferred.md` with the v2 design.

---

### Phase 2B-fallback — Android batched-blob via sendme (when live tunnel down) — ~half day, after Phase 2B

**Goal**: When `dumbpipe` can't establish (e.g. relay down, hostile NAT, phone offline-recording), Android records 60s clips locally and queues them for `sendme` upload when connectivity returns.

**Tasks**:
- [ ] Phone-side Termux script `record-and-queue.sh`:
  - Use Termux:API to access camera (limited) OR a third-party recorder app that writes to a known directory
  - On 60s rollover, move file to `~/sendme-queue/`
  - Watcher: `for f in ~/sendme-queue/*.mp4; do sendme send "$f" > ~/sendme-out/$(basename "$f").ticket; done` — emits ticket per clip
  - Tickets posted to a small server-side endpoint (or via the SSH iroh tunnel as text)
- [ ] Server-side: `sendme-receive-watcher.service` reads incoming tickets and runs `sendme receive` into `~/inbox-vision/`
- [ ] Vision worker (Phase 2B) treats `~/inbox-vision/*.mp4` like a stream: `ffmpeg ... -i <file> ...` → frames → YOLO → annotated output
- [ ] Phone-side queue trim: keep last 24h locally; delete after server ack

**Validation**: Force-disable the live tunnel mid-broadcast → phone falls back to recording → tunnel restored → queued blobs drain → server processes them.

**Wiki grounding**: Gap-fill — will compile to `concepts/iroh-blob-fallback-queue.md`.

---

### Phase 2A — Audio drop-folder transcription (Track A) — ~1 day

**Goal**: Drop a `.wav`/`.mp3`/`.m4a` into `~/inbox`; ~3-5× audio-length later, find `.srt` + `.json` (with speakers) in `~/outbox`. Service runs as `whisper-server.service`.

**Prerequisite**: Browser-accept HF user-conditions on `pyannote/segmentation-3.0` AND `pyannote/speaker-diarization-3.1` ([pyannote-audio-3.x-on-pascal](../wiki/concepts/pyannote-audio-3.x-on-pascal.md)).

**Tasks**:
- [ ] `~/srv/whisper/.venv` Python 3.11 venv
- [ ] Install path per [whisperx-known-broken-installs](../wiki/concepts/whisperx-known-broken-installs.md):
  ```
  pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*
  pip install whisperx
  # If issue #1406 bites:
  pip uninstall -y pyannote.audio
  pip install "pyannote.audio>=3.1,<3.3" --no-deps
  pip install pytorch-lightning>=2.0.1 asteroid-filterbanks>0.4 einops>0.6.0 omegaconf>2.1
  ```
- [ ] Smoke test on a known clip: `whisperx clip.wav --model distil-large-v3 --compute_type int8 --batch_size 8 --diarize --hf_token $HF_TOKEN`. Confirm SRT has speaker labels.
- [ ] Worker script `~/srv/whisper/worker.py`:
  - `inotifywait -m ~/inbox -e moved_to,close_write` loop
  - For each new file: load WhisperX once at startup (warm), run pipeline, write `<base>.srt` + `<base>.json` to `~/outbox/`
  - `tmpfile.tmp` → atomic rename pattern in writer
  - Errors → `~/outbox/errors/<base>.err` + structured JSON log line
  - Single-file-at-a-time (no concurrency in v1)
- [ ] systemd unit `whisper-server.service`:
  ```
  [Service]
  User=ai
  WorkingDirectory=/home/ai/srv/whisper
  EnvironmentFile=/etc/whisper-server.env
  ExecStart=/home/ai/srv/whisper/.venv/bin/python worker.py
  Restart=on-failure
  RestartSec=10
  MemoryMax=12G
  NoNewPrivileges=yes
  ProtectSystem=strict
  ReadWritePaths=/home/ai/inbox /home/ai/outbox /var/log /home/ai/srv/whisper
  ```
- [ ] `/etc/whisper-server.env` (mode 0600): `HF_TOKEN=hf_...` + `LD_LIBRARY_PATH=...`
- [ ] logrotate `/etc/logrotate.d/whisper-server` (daily, 7, compress, copytruncate).
- [ ] Bench: 1-hour test recording → measure wall time. Target: distil-large-v3 int8 ~2 min wall ([charliemike data](../raw/data/2026-05-21-charliemike-gtx-1060-rtfx.md) extrapolation).

**Validation**:
- Drop clip into `~/inbox` → `.srt` + `.json` appear in `~/outbox` within RTFx budget
- Speaker labels present in JSON
- Service survives a `kill -9` of the worker (systemd restarts)
- Service survives a `systemctl reboot` (auto-resumes any unprocessed files in `~/inbox`)

**Wiki grounding**: [faster-whisper-on-gtx-1060](../wiki/concepts/faster-whisper-on-gtx-1060.md), [whisperx-vs-manual-pyannote-integration](../wiki/concepts/whisperx-vs-manual-pyannote-integration.md), [whisperx-known-broken-installs](../wiki/concepts/whisperx-known-broken-installs.md), [pyannote-audio-3.x-on-pascal](../wiki/concepts/pyannote-audio-3.x-on-pascal.md).

---

### Phase 2B — YOLO11 vision worker hooked to phone stream (Track B) — ~1-2 days

**Goal**: Phone push → YOLO11s inferences at 5 fps → annotated frames written to disk + per-segment counts logged to a CSV. No fine-tuning yet — use COCO weights for first signal.

**Tasks**:
- [ ] `~/srv/vision/.venv` venv
- [ ] `pip install ultralytics supervision opencv-python`
- [ ] Smoke test: `python -c "from ultralytics import YOLO; YOLO('yolo11s.pt').predict('https://ultralytics.com/images/bus.jpg', conf=0.25, device=0)"` — confirms Pascal CUDA path works.
- [ ] Worker script `~/srv/vision/worker.py`:
  - Subprocess: ffmpeg pulling RTSP from MediaMTX → BGR24 frames on stdout (the Phase 1B template)
  - Read `width*height*3` bytes per frame; `np.frombuffer(...).reshape(h, w, 3)`
  - YOLO11s `.predict(frame, device=0, conf=0.3)` — keep model warm, reuse
  - Annotate frame with `supervision` `BoxAnnotator` + `LabelAnnotator`
  - Write annotated `.jpg` snapshots every N seconds to `~/outbox-vision/<YYYYmmdd>/<HHMMSS>.jpg`
  - Append counts (per class) to `~/outbox-vision/counts.csv`
  - Supervisor wraps the ffmpeg subprocess: respawn on EOF/exit, exponential backoff
- [ ] systemd unit `vision-server.service`:
  - `Restart=on-failure`, `RestartSec=10`, `MemoryMax=8G`
  - `After=mediamtx.service`
  - `Wants=mediamtx.service`
- [ ] Bench: confirm YOLO11s @ 640px inference latency on 1060 (target 30-50 ms/frame, well under 200 ms budget for 5 fps).

**Validation**:
- Phone pushing → annotated JPGs land in `~/outbox-vision/` at 1 per 5s (or whatever cadence chosen)
- Counts CSV updates
- Killing the phone app → service logs disconnection, ffmpeg respawns, no crash on the Python side
- 30-min sustained run: GPU temp stable, no OOM, no NaN

**Wiki grounding**: [farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md). Phone-side covered by Phase 1B.

---

### Phase 3 — Domain-tune YOLO on actual farm imagery (Track B) — ~3-7 days

**Goal**: Replace COCO weights with a YOLO11s checkpoint fine-tuned on YOUR cattle/sheep/etc. data. Counts get accurate.

**Tasks**:
- [ ] Capture seed dataset: 200-500 phone snapshots/frames from your site, varied angles + lighting
- [ ] Annotate via Roboflow web (use **MobileSAM** click-to-mask to speed labeling per [farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md))
- [ ] Optional warm-start: pull a Roboflow Universe cattle/sheep dataset, merge with yours
- [ ] Fine-tune: `yolo train model=yolo11s.pt data=farm.yaml epochs=50 imgsz=640 batch=8 device=0` (overnight on 1060)
- [ ] Validate: hold out 20%, inspect per-class mAP, confusion matrix
- [ ] Swap `vision-server` to load `runs/train/weights/best.pt`; rolling restart
- [ ] Optional: validate on AerialCattle2017 (UoBristol) as a sanity check if your use case is drone

**Validation**: Visual spot-check on 20 production frames; mAP@50 > 0.7 on holdout.

**Wiki grounding**: [farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md), [Bhujel survey](../raw/papers/2026-05-21-bhujel-livestock-cv-survey.md).

---

### Phase 4 — Iroh `sendme` for over-the-internet drop-folder ingest (Track A bonus) — ~half day

**Goal**: Operator's laptop, anywhere → drop file into server's `~/inbox/` over Iroh.

**Tasks**:
- [ ] Install sendme on server + operator laptop: `cargo install sendme`
- [ ] Server-side: a small wrapper `sendme-watch.py` that periodically generates a fresh `sendme send ~/inbox-drop/` ticket, exposes it via the SSH/iroh tunnel for retrieval
- [ ] OR simpler v1: operator runs `sendme send recording.wav` on laptop, copies the ticket, runs `sendme receive <ticket>` over SSH on server — manual but works today
- [ ] Document procedure in `~/srv/whisper/README.md`

**Validation**: 100 MB audio file transferred laptop → server `~/inbox` from cellular tether, verified by hash.

**Wiki grounding**: Gap-fill on Iroh — will compile.

---

### Phase 5 — Operations + reliability (both tracks) — ~1 day

**Goal**: Survive a power blip, an apt upgrade, an SSD fill. 24/7 ready.

**Tasks**:
- [ ] UPS arrives → install + apcupsd/NUT → graceful shutdown on power loss
- [ ] DCGM-exporter container for Prometheus (optional) OR plain CSV log via `nvidia-smi --query-gpu=... --format=csv -l 60`
- [ ] Weekly cron: `smartctl -a /dev/nvme0` + `df -h` → email/notify on threshold
- [ ] Quarterly maintenance procedure documented in repo: snapshot rootfs (LVM/Btrfs); upgrade nvidia + cuda together; smoke-test all services; rollback if regressed
- [ ] Disaster recipe: `output/runbook-recovery.md` — what to do when (a) NVIDIA driver breaks after upgrade, (b) HF gated-model 401s come back, (c) phone can't reach SRT, (d) Iroh ticket stops working

**Validation**:
- Pull AC plug → graceful shutdown completes (UPS battery, ~5 min)
- `apt upgrade` → driver pin holds → `nvidia-smi` still works
- Fill `/var/log` to 90% → logrotate kicks in, no service degradation

**Wiki grounding**: [gpu-thermals-and-ops](../wiki/concepts/gpu-thermals-and-ops.md), [unattended-upgrades-pin-nvidia](../raw/articles/2026-05-21-unattended-upgrades-pin-nvidia.md).

---

## Risks & Mitigations

| Risk | Source | Mitigation |
|------|--------|------------|
| Pascal silently demotes fp16 → fp32; user picks `compute_type="float16"` and gets no speedup | [ctranslate2-quantization-on-pascal](../wiki/concepts/ctranslate2-quantization-on-pascal.md) | Hard-code `compute_type="int8"` in worker; never expose float16 as CLI option |
| WhisperX 3.8.5 + pyannote 4.x mismatch (issue #1406) | [whisperx-known-broken-installs](../wiki/concepts/whisperx-known-broken-installs.md) | Pin pyannote 3.1 in v1; revisit when WhisperX 3.9.x ships |
| HF gated model 401 at runtime (user skipped browser-accept step) | [pyannote-audio-3.x-on-pascal](../wiki/concepts/pyannote-audio-3.x-on-pascal.md) | Phase 2A prerequisite checklist; runtime probe at service start |
| Audio + video co-running OOMs the 6 GB GPU | [synthesis](../wiki/topics/gtx-1060-headless-ai-server-synthesis.md) | Don't co-schedule in v1; arbiter (Phase 5+) gates audio jobs when video active |
| msi-ec doesn't support GS63VR — no software fan control | [msi-ec-gs63vr-unimplemented](../raw/repos/2026-05-21-msi-ec-gs63vr-unimplemented.md) | nbfc-linux + cooling pad + lid-open + `nvidia-smi -pl 65` |
| 2017 battery is a fire risk | [gpu-thermals-and-ops](../wiki/concepts/gpu-thermals-and-ops.md) | Phase 0: REMOVE battery before deployment; UPS fills the buffer role |
| Driver bumped by unattended-upgrades, breaks ctranslate2 | [unattended-upgrades-pin-nvidia](../raw/articles/2026-05-21-unattended-upgrades-pin-nvidia.md) | apt pin nvidia-* + cuda-* at Pin-Priority 1001 |
| iPhone HEVC 10-bit silent CPU fallback in NVDEC | gap research (NVIDIA matrix) | Force H.264 in Larix encoder settings |
| Iroh public relay outage | gap research (n0 Nov 2024 postmortem) | Self-host iroh-relay on a $5/mo VPS later (Phase 5 stretch) |
| **iroh-ffi archived → iOS native app needed for iroh on iPhone** | gap research | iOS deferred to v2 (4-6 wk Swift+UniFFI project); v1 ships Android-only |
| **Termux on Android: third-party app, awkward UX, F-Droid only** | gap research | Document install steps explicitly; Termux:Boot for auto-start; user must accept this UX cost |
| **Termux Rust compile on-device is slow (5-15 min)** | gap research | One-time setup; document expectations; alternative is cross-compiling on operator laptop and ADB-pushing the binary |
| **Same iroh ticket on phone + operator laptop** has both bearer-credential implications | gap research | Use **separate tickets** per role (SSH = unit `iroh-ssh.service`; Video = unit `iroh-srt.service`); rotate independently |
| Larix on Android may push HEVC by default | gap research (NVIDIA matrix) | Force H.264 in Larix encoder settings; verify with `ffprobe rtsp://127.0.0.1:8554/phone` shows `h264` |
| Pascal CC 6.1 — TensorRT 10 dropped support | [farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md) | Stay on PyTorch CUDA EP; if TRT needed, pin to TRT 8.6.x |
| Long-form audio OOM with both whisper + pyannote loaded | [pyannote-audio-3.x-on-pascal](../wiki/concepts/pyannote-audio-3.x-on-pascal.md) | distil-large-v3 + sequenced loads (`del model; gc.collect(); torch.cuda.empty_cache()`) — WhisperX does this implicitly |

## Open Questions

1. **iOS priority?** Phase 1B-iOS is deferred. Is iOS-first parity a v2 commitment (warrants the 4-6 wk Swift+UniFFI project), a v3+ nice-to-have, or "skip — Mac+sendme manual workflow is fine"?
2. **Animal target species and counting cadence?** Affects Phase 3 dataset choice and whether ground-CCTV (line-zone tracking) or aerial (frame-count) recipes apply.
3. **Audio source format and volume?** Bench numbers in this plan assume <2 hour clips; if you'll routinely process 5+ hour recordings, a memory-leak characterization round (gap #7 from research) becomes worth doing first.
4. **Self-host iroh-relay now or later?** Free public relays are fine for hobby use; a $5/mo VPS adds reliability if the server becomes operationally important. Specific concern: phone live tunnel uses relay fallback when NAT punching fails — production reliability argues for self-hosted relay sooner rather than later.
5. **YOLO worker — record full video or only annotated snapshots?** Full video doubles disk IO; snapshots are usually enough for counting + audit.
6. **Termux UX acceptable?** The Android user has to install Termux from F-Droid and run a Rust toolchain to compile dumbpipe/sendme. Acceptable v1 friction, or worth investigating cross-compiled prebuilt binaries we can side-load via ADB?
7. **Ticket distribution mechanism?** Manual paste from server journalctl into operator's password manager works for v1 but doesn't scale. v2 question: small encrypted-bootstrap web page on the server (behind iroh) that emits new tickets on demand?

## Cumulative effort estimate

| Phase | Calendar days | Active work hours | Track |
|-------|---------------|-------------------|-------|
| 0 — Baseline | 1 | 4-6 | Both |
| 1A — Iroh SSH tunnel | 0.25 | 2 | A |
| 1B — MediaMTX + iroh-srt + laptop test | 1 | 5-7 | B |
| 1B-Android — Termux + Larix | 0.5 | 3-4 | B |
| 1B-iOS — DEFERRED v2 | 0 (in v1) | 0 | B (v2) |
| 2A — Audio worker | 1 | 6-8 | A |
| 2B — Vision worker | 1-2 | 8-12 | B |
| 2B-fallback — Blob queue | 0.5 | 4-5 | B |
| 3 — Fine-tune YOLO | 3-7 (mostly waiting) | 6-10 | B |
| 4 — sendme audio drop | 0.5 | 2 | A |
| 5 — Ops + UPS + maintenance | 1 | 4-6 | Both |
| **Total v1** | **9-16** | **44-62** | |
| **v2 — iOS native app** | 20-30 | 120-180 | B (deferred) |

**Critical paths**:
- Audio MVP: 0 → 1A → 2A (~2.5 days, ~12-16 hr)
- Android-video MVP: 0 → 1B → 1B-Android → 2B (~3.5 days, ~22-29 hr)
- Add 2B-fallback for resilience; add 3 for accuracy; add 4-5 for hardening.

After Phase 0, tracks A and B are independent.

## Sources Consulted

### From the wiki (11 articles)
- [topics/gtx-1060-headless-ai-server-synthesis](../wiki/topics/gtx-1060-headless-ai-server-synthesis.md) — single-page summary
- [concepts/pascal-driver-cuda-pinning](../wiki/concepts/pascal-driver-cuda-pinning.md) — driver branch + apt pin
- [concepts/ctranslate2-quantization-on-pascal](../wiki/concepts/ctranslate2-quantization-on-pascal.md) — int8 only on Pascal
- [concepts/faster-whisper-on-gtx-1060](../wiki/concepts/faster-whisper-on-gtx-1060.md) — model VRAM, RTFx, pin matrix
- [concepts/whisperx-vs-manual-pyannote-integration](../wiki/concepts/whisperx-vs-manual-pyannote-integration.md) — pick WhisperX
- [concepts/whisperx-known-broken-installs](../wiki/concepts/whisperx-known-broken-installs.md) — issue #1406 / #1412
- [concepts/pyannote-audio-3.x-on-pascal](../wiki/concepts/pyannote-audio-3.x-on-pascal.md) — gating + DER
- [concepts/farm-vision-on-gtx-1060](../wiki/concepts/farm-vision-on-gtx-1060.md) — YOLO11 + supervision
- [concepts/headless-ubuntu-laptop-baseline](../wiki/concepts/headless-ubuntu-laptop-baseline.md) — install + SSH baseline
- [concepts/gpu-bench-and-smoke-tests](../wiki/concepts/gpu-bench-and-smoke-tests.md) — 5-layer verification
- [concepts/gpu-thermals-and-ops](../wiki/concepts/gpu-thermals-and-ops.md) — 24/7 thermals + ops

### Gap research (2 probes)
- **Phone-to-server video**: MediaMTX (v1.18.2, May 2026), Larix Broadcaster (Android+iOS), SRT vs RTSP/RTMP/WebRTC reliability, NVIDIA NVDEC support matrix for Pascal, ffmpeg+NVDEC pipe template
- **Iroh p2p**: dumbpipe v0.37.0 + sendme v0.34.0 (May 8, 2026); iroh 1.0.0-rc.0 (May 11, 2026); **iroh-ffi archived mid-2025**; relay model + self-host option; Termux-on-Android as the only no-build path; iOS requires native Swift+UniFFI

## Follow-up suggestions

After v1 is running:
- `/wiki:research --wiki gtx-1060-headless-ai-server "iOS native app for iroh-blobs video push: Swift + Rust UniFFI starter kit"` ← required for v2 iOS
- `/wiki:research --wiki gtx-1060-headless-ai-server "self-hosted iroh-relay on $5 VPS"` ← when reliability becomes critical
- `/wiki:research --wiki gtx-1060-headless-ai-server "Termux dumbpipe cross-compile + sideload to skip on-device Rust build"` ← UX improvement
- `/wiki:research --wiki gtx-1060-headless-ai-server "long-form audio OOM characterization on WhisperX+pyannote 6GB"`
- `/wiki:research --wiki gtx-1060-headless-ai-server "TensorRT 8.6 INT8 export for YOLO11 on Pascal"`
- Compile new concept articles back into the wiki:
  - `iroh-tunnel-for-headless-server` (Phase 1A)
  - `iroh-tunneled-srt-ingest` (Phase 1B)
  - `android-iroh-video-push` (Phase 1B-Android)
  - `ios-iroh-deferred` (Phase 1B-iOS — v2 design doc)
  - `iroh-blob-fallback-queue` (Phase 2B-fallback)
