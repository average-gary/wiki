---
title: "GTX 1060 Headless AI Server — synthesis"
type: topic
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: high
compiled-from: conversation
---

# GTX 1060 6GB Headless AI Server — synthesis

The actionable single-page summary tying every concept article together.

## The hardware verdict

| Constraint | Implication |
|------------|-------------|
| Pascal sm_61 / CC 6.1 | Open kernel modules unavailable; must use proprietary NVIDIA driver. fp16/bf16 silently fall back to fp32 in CTranslate2. |
| 6 GB VRAM | large-v3 int8 (3 GB) + pyannote (2-3 GB) coexist with thin margin. distil-large-v3 int8 is the sweet spot. |
| GS63VR 7RF chassis | **msi-ec unimplemented** — no sysfs fan/battery control. nbfc-linux fallback. Plus thermal-throttle risk under sustained load. |
| 16 GB RAM, i7-7700HQ Kaby Lake | throttled (erpalma) for undervolt + PL1/PL2 cap; schedutil governor. |
| 2017 battery (likely swollen) | **REMOVE before 24/7 deployment** (fire risk). Add small UPS. |
| CUDA 13 dropped Pascal | Pin to CUDA 12.x + driver 535 LTS. Pin via apt to prevent unattended-upgrade breakage. |

## The decision tree

1. **Driver/CUDA**: [[pascal-driver-cuda-pinning]] — `sudo ubuntu-drivers install --gpgpu` → 535-server. Pin via `/etc/apt/preferences.d/nvidia`.
2. **Ubuntu baseline**: [[headless-ubuntu-laptop-baseline]] — Server 22.04 install, BIOS IGFX + AHCI + WoL, ethernet only, lid-close ignore, SSH key-only + ufw + fail2ban.
3. **Thermals**: [[gpu-thermals-and-ops]] — remove battery, UPS, `nvidia-smi -pl 65`, throttled, nbfc-linux, cooling pad, lid open.
4. **Audio stack**: [[whisperx-vs-manual-pyannote-integration]] — WhisperX with [[pyannote-audio-3.x-on-pascal]] gated-models accepted in browser FIRST. Watch for [[whisperx-known-broken-installs]].
5. **Vision stack**: [[farm-vision-on-gtx-1060]] — YOLO11s + Roboflow supervision + Roboflow Universe cattle dataset. Validate on AerialCattle2017.
6. **Benchmarks**: [[gpu-bench-and-smoke-tests]] — gpu-burn (`make COMPUTE=6.1`!), then PyTorch + ctranslate2 + pyannote + ffmpeg NVENC smoke. DCGM-exporter for ongoing monitoring.

## Recommended stack (in one screen)

```
Hardware:
  MSI GS63VR 7RF — battery removed, on cooling pad, lid open, ethernet only, UPS
OS:
  Ubuntu Server 22.04 LTS, headless, OpenSSH key-only + fail2ban + ufw
Driver:
  nvidia-driver-535-server (proprietary, ERD)
  pinned via /etc/apt/preferences.d/nvidia
CUDA:
  12.4 (toolkit only — most projects use bundled wheels)
  cuDNN 9 (via pip wheels: nvidia-cudnn-cu12==9.*)
Audio pipeline:
  faster-whisper distil-large-v3 + compute_type=int8
  pyannote/speaker-diarization-3.1 (or community-1 for 4.x)
  WhisperX wraps both with wav2vec2 alignment + assign_word_speakers
Vision pipeline:
  YOLO11s for fine-tune; YOLO11n for ground CCTV
  supervision (Roboflow) for LineZone/PolygonZone counting
  ByteTrack for video tracking
Operations:
  nvidia-smi -pm 1; nvidia-smi -pl 65 (systemd oneshot)
  throttled (CPU PL1=35/PL2=45, undervolt -80mV)
  nbfc-linux (verify GS63VR config exists)
  schedutil CPU governor
  systemd-journald: SystemMaxUse=500M, MaxRetentionSec=4week
  apt-pin nvidia-* + cuda-*
  unattended-upgrades for security only
Monitoring:
  DCGM-exporter (Pascal-compatible basic counters)
  smartctl weekly via systemd timer
Bench targets (1 hr audio):
  distil-large-v3-turbo int8: ~1 min wall
  large-v3 int8: ~3 min wall
  YOLO11n inference: 40-60 FPS @ 640px
```

## See also

- [[ctranslate2-quantization-on-pascal]]
- [[faster-whisper-on-gtx-1060]]
- All concept articles linked above
