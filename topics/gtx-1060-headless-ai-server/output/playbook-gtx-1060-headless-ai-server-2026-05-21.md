---
title: "Playbook — GTX 1060 6GB Headless AI Server (Ubuntu 22.04)"
type: playbook
created: 2026-05-21
updated: 2026-05-21
status: draft
hardware: "MSI GS63VR 7RF Stealth Pro / i7-7700HQ / GTX 1060 6GB mobile (Pascal sm_61) / 16GB RAM"
---

# GTX 1060 Headless AI Server — Setup Playbook

End-to-end runbook for repurposing an MSI GS63VR (Pascal GTX 1060 6GB mobile, i7-7700HQ, 16GB RAM) as a 24/7 headless Ubuntu 22.04 LTS server for local audio transcription + speaker diarization + farm vision tasks.

You'll flash Ubuntu and set up SSH yourself; this playbook starts from the first SSH session.

---

## Phase 0 — Hardware safety + BIOS (BEFORE first boot)

1. **Open the chassis and remove the battery** if there's any chance it's swollen. A 2017 lithium battery used heavily as a gaming laptop is high-risk for puffing/ignition. Disconnect the battery connector from the motherboard; reassemble.
   - With battery removed, system will run AC-only — a power blip will hard-shutdown. Plan to add a small UPS (CyberPower CP685AVR or APC BE600M1, ~$60) before going 24/7.

2. **Boot to BIOS** (DEL key on POST). Set:
   - Secure Boot: **Disabled** (avoids signing dance for proprietary NVIDIA driver; unblocks throttled MSR writes)
   - Primary Display: **IGFX** (boot framebuffer via Intel HD 630; GTX 1060 visible only to CUDA)
   - SATA Mode: AHCI (default — verify, don't change)
   - Wake on LAN: Enabled
   - Save and exit

3. Plug ethernet — **don't rely on the Killer 1535 Wi-Fi**. The Atheros QCA6174 / `ath10k_pci` driver has known firmware-crash issues on Linux that will not survive 24/7.

---

## Phase 1 — First SSH login + base system

After flashing Ubuntu Server 22.04 LTS and confirming SSH login works:

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y \
  build-essential pkg-config git curl wget vim tmux htop \
  python3 python3-venv python3-pip \
  ffmpeg lm-sensors smartmontools \
  ufw fail2ban avahi-daemon ethtool \
  linux-cpupower
sudo sensors-detect --auto
```

### Lid-close + suspend disable

`/etc/systemd/logind.conf` (under `[Login]`):

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore   # <-- IGNORED BY DEFAULT, must be set explicitly
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=no
```

```bash
sudo systemctl restart systemd-logind
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

**Run with lid open anyway** for thermal headroom on this thin chassis.

### SSH hardening (LAN-only)

`/etc/ssh/sshd_config`:

```
PasswordAuthentication no
PermitEmptyPasswords no
PubkeyAuthentication yes
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
```

```bash
sudo sshd -t                  # validate first
sudo systemctl reload ssh
```

### UFW + fail2ban

```bash
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw enable

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/^enabled = false$/enabled = true/' /etc/fail2ban/jail.local
sudo systemctl enable --now fail2ban
sudo systemctl status fail2ban
sudo iptables -S | grep f2b   # verify chains exist
```

### LAN discovery — DHCP reservation + mDNS

- On your router admin: reserve the GS63VR's MAC → fixed IP (survives a reflash).
- avahi-daemon is already installed → `ssh user@<hostname>.local` works from macOS/Linux clients.

### Wake-on-LAN

```bash
sudo ethtool -s eno1 wol g
ethtool eno1 | grep Wake-on        # should show 'Wake-on: g'
```

Persist via NetworkManager: `nmcli connection modify <name> 802-3-ethernet.wake-on-lan magic`.

Wake from another LAN host: `wakeonlan <MAC_addr>`.

---

## Phase 2 — NVIDIA driver + CUDA (Pascal pinning)

```bash
sudo ubuntu-drivers install --gpgpu          # picks 535-server automatically
sudo apt install -y nvidia-utils-535-server
sudo systemctl enable --now nvidia-persistenced
sudo reboot
```

After reboot:

```bash
nvidia-smi                                    # should report GTX 1060 6GB, driver 535.x
nvidia-smi --query-gpu=compute_cap --format=csv   # 6.1
```

### Pin against unattended-upgrades

`/etc/apt/preferences.d/nvidia`:

```
Package: nvidia-* libcuda* cuda-*
Pin: version 535.*
Pin-Priority: 1001
```

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades     # accept defaults (security only)
```

### Important rules

- **NEVER install `nvidia-driver-XXX-open`** — Pascal not supported by NVIDIA's open kernel modules
- **NEVER install CUDA Toolkit 13.x** — sm_61 was removed there. Stick to 12.x.

---

## Phase 3 — Thermal + power tuning

### GPU power cap (does NOT persist — needs systemd oneshot)

`/etc/systemd/system/nvidia-tuning.service`:

```ini
[Unit]
Description=NVIDIA persistence and power limit
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi -pl 65
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now nvidia-tuning.service
nvidia-smi --query-gpu=power.limit --format=csv     # verify 65 W
```

(Verify legal range first: `nvidia-smi --query-gpu=power.min_limit,power.max_limit,power.default_limit --format=csv`)

### CPU undervolt + PL1/PL2

Install [throttled](https://github.com/erpalma/throttled). Conservative `/etc/throttled.conf`:
- PL1=35W, PL2=45W (default 45W TDP — slightly relaxed)
- Undervolt CPU Core / Cache: -80mV
- Trip temp: 90°C

```bash
sudo systemctl disable --now thermald
sudo systemctl enable --now throttled.service
```

Validate undervolt stability: run `mprime` / prime95 small-FFT over 4+ hours; if no NaN errors → OK.

### CPU governor

```bash
sudo cpupower frequency-set -g schedutil
```

Avoid `performance` — pegs i7-7700HQ at boost continuously, generates idle heat unnecessarily.

### Fan control fallback (msi-ec unimplemented for GS63VR)

```bash
# Install nbfc-linux (check distro packages page)
sudo nbfc update
sudo nbfc rate-config -a                   # list compatible configs
sudo nbfc config --set "MSI GS63VR ..."    # if a config exists; else use BIOS Cooler Boost button
sudo nbfc restart -r                       # read-only mode
nbfc status
sudo nbfc restart                          # write mode
sudo systemctl enable nbfc_service
```

### Physical cooling

- Cooling pad (basic dual-fan USB pad drops package temps 5-10°C)
- Run with lid open
- Vertical "on-its-side" orientation if rack-mounting

---

## Phase 4 — Smoke tests + benchmarks

### Build cuda-samples + gpu-burn

```bash
git clone https://github.com/NVIDIA/cuda-samples ~/cuda-samples
cd ~/cuda-samples && git checkout v12.4
mkdir build && cd build && cmake .. && make -j$(nproc)
./Samples/1_Utilities/deviceQuery/deviceQuery        # expect Result = PASS, CC 6.1
./Samples/1_Utilities/bandwidthTest/bandwidthTest    # expect ~12 GB/s HtoD on PCIe 3.0 x16

cd ~ && git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make COMPUTE=6.1                                      # CRITICAL for Pascal
./gpu_burn 600                                        # 10-min smoke
./gpu_burn -d 3600                                    # 1-hour double-precision burn-in
```

While burn-in runs, monitor in another shell:
```bash
nvidia-smi dmon -s pucvmet -d 5
```

Targets:
- Temps stay < 80°C (with `-pl 65` + cooling pad)
- No "Hard XID errors" in `dmesg`
- gpu_burn reports zero errors at end

### CPU + RAM stress

```bash
sudo apt install -y stress-ng sysbench
stress-ng --cpu $(nproc) --vm 2 --vm-bytes 75% --timeout 600s --metrics-brief
sysbench cpu --threads=$(nproc) --time=60 run
sysbench memory --memory-total-size=10G run
```

### ffmpeg NVENC/NVDEC

```bash
ffmpeg -hwaccels                          # should list cuda, cuvid, nvdec
ffmpeg -y -f lavfi -i testsrc=size=1920x1080:rate=30 -t 5 \
  -c:v h264_nvenc -preset p4 /tmp/out.mp4
```

GTX 1060 has **4th-gen NVENC**: H.264 + HEVC encode (no AV1).

---

## Phase 5 — Audio pipeline (faster-whisper + WhisperX + pyannote)

### Pre-install: accept HuggingFace gated models IN BROWSER FIRST

These will 401 at runtime if you skip:
1. Create token: https://huggingface.co/settings/tokens (read scope)
2. Accept conditions:
   - https://huggingface.co/pyannote/segmentation-3.0
   - https://huggingface.co/pyannote/speaker-diarization-3.1
   - (Optional, for pyannote 4.x) https://huggingface.co/pyannote/speaker-diarization-community-1
3. Save token somewhere — you'll export it as `HF_TOKEN`.

### Python venv

```bash
mkdir -p ~/srv/whisper && cd ~/srv/whisper
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
```

### Install path A — WhisperX (recommended)

```bash
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*
pip install whisperx                # pulls torch ~2.8, ct2 4.5+, pyannote 4.0+
```

### IF the install hits issues #1412 or #1406 — fallback pin

```bash
pip uninstall -y pyannote.audio
pip install "pyannote.audio>=3.1,<3.3" --no-deps
pip install pytorch-lightning>=2.0.1 asteroid-filterbanks>0.4 einops>0.6.0 omegaconf>2.1
```

### Smoke test (sanity)

```bash
export HF_TOKEN=hf_...
export LD_LIBRARY_PATH=$(python3 -c 'import os, nvidia.cublas.lib, nvidia.cudnn.lib; print(os.path.dirname(nvidia.cublas.lib.__file__) + ":" + os.path.dirname(nvidia.cudnn.lib.__file__))')

# Tiny end-to-end: distil-large-v3 + int8 (GTX 1060 sweet spot)
python -c "
from faster_whisper import WhisperModel
m = WhisperModel('distil-large-v3', device='cuda', compute_type='int8')
segs, info = m.transcribe('clip.wav', beam_size=1)
print(info.language)
for s in segs: print(f'[{s.start:.2f}-{s.end:.2f}] {s.text}')
"
```

### Diarization smoke

```bash
python -c "
import torch, time
from pyannote.audio import Pipeline
import os
pipe = Pipeline.from_pretrained('pyannote/speaker-diarization-3.1', use_auth_token=os.environ['HF_TOKEN'])
pipe.to(torch.device('cuda'))
t0 = time.time(); diar = pipe('clip.wav'); print('wall=', time.time()-t0, 's')
for turn, _, spk in diar.itertracks(yield_label=True):
    print(f'{turn.start:.1f}-{turn.end:.1f} {spk}')
"
```

### Full WhisperX (transcription + diarization + word-level speakers)

```bash
whisperx clip.wav --model distil-large-v3 --compute_type int8 \
  --batch_size 8 --diarize --hf_token $HF_TOKEN
```

### IMPORTANT compute_type rule (Pascal-specific)

- ✅ `int8` — INT8 weights, fp32 accumulate, ~50% VRAM, possible DP4A acceleration
- ❌ `float16` — silently demotes to fp32 on Pascal (no benefit, just warning noise)
- ✅ `float32` — baseline; use only if accuracy is critical

### Expected RTFx on GTX 1060

| Config | RTFx | 1 hour audio takes |
|---|---|---|
| distil-large-v3-turbo + int8 | ~60x | ~1 min |
| large-v3 int8 | ~20x | ~3 min |
| distil-large-v3 int8 (recommended) | ~30-40x | ~1.5-2 min |

### VRAM budget (target: leave room for pyannote)

- distil-large-v3 int8: ~1.5-2 GB → safe to coexist with pyannote
- large-v3 int8: ~3 GB → tight but works
- large-v3 fp32: ~4.5 GB → likely OOM if pyannote loads simultaneously

If both don't fit: sequence load → transcribe with Whisper → `del model; gc.collect(); torch.cuda.empty_cache()` → diarize.

---

## Phase 6 — Vision pipeline (farm / herd counting)

```bash
mkdir -p ~/srv/vision && cd ~/srv/vision
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install ultralytics supervision opencv-python
```

### Smoke test

```bash
python -c "
from ultralytics import YOLO
m = YOLO('yolo11s.pt')                          # downloads ~19MB COCO weights
results = m.predict('https://ultralytics.com/images/bus.jpg', conf=0.25, device=0)
print(results[0].boxes)
"
```

### Benchmark on the 1060

```bash
python -c "
from ultralytics.utils.benchmarks import benchmark
benchmark(model='yolo11n.pt', data='coco8.yaml', imgsz=640, half=False, device=0)
"
```

Expected at fp32: YOLO11n ~40-60 FPS, YOLO11s ~20-35 FPS, YOLO11m ~8-15 FPS.

### Fine-tune on a Roboflow Universe cattle dataset

```bash
# Pull a dataset (Roboflow web UI gives a download command per dataset)
# Then:
yolo train model=yolo11s.pt data=cattle.yaml epochs=50 imgsz=640 batch=8 device=0
```

### Counting recipes

**Ground CCTV (cattle moving through gate/race) — line counting**:
```bash
yolo solutions count source="paddock.mp4" \
  region="[(20, 400), (1080, 400)]"
```

**Drone aerial (paddock census) — `len(boxes)` per frame**:
```python
from ultralytics import YOLO
m = YOLO('runs/train/weights/best.pt')
results = m.predict('aerial_paddock.tif', conf=0.3, device=0, imgsz=1280)
print('Cattle counted:', len(results[0].boxes))
```

**Or use `supervision` (MIT, model-agnostic, Roboflow):**
```python
import supervision as sv
import cv2
from ultralytics import YOLO

model = YOLO('best.pt')
line_zone = sv.LineZone(start=sv.Point(20, 400), end=sv.Point(1080, 400))
tracker = sv.ByteTrack()
# loop frames → infer → tracker.update → line_zone.trigger → line_zone.in_count / out_count
```

---

## Phase 7 — Operational hardening

### Log retention

`/etc/systemd/journald.conf.d/server.conf`:
```ini
[Journal]
Storage=persistent
SystemMaxUse=500M
SystemKeepFree=1G
SystemMaxFileSize=50M
MaxFileSec=1week
MaxRetentionSec=4week
```
```bash
sudo systemctl restart systemd-journald
```

### tmpfs for /tmp (spare SSD wear)

`/etc/fstab`:
```
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=4G 0 0
```

### Inference service template

`/etc/systemd/system/whisper-server.service`:

```ini
[Unit]
Description=faster-whisper inference server
After=network-online.target nvidia-tuning.service

[Service]
Type=simple
User=ai
Group=ai
WorkingDirectory=/srv/whisper
EnvironmentFile=/etc/whisper-server.env
ExecStart=/srv/whisper/.venv/bin/python -m whisper_server
Restart=on-failure
RestartSec=10
StartLimitBurst=5
LogRateLimitIntervalSec=30s
LogRateLimitBurst=1000
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/srv/whisper /var/log

[Install]
WantedBy=multi-user.target
```

`/etc/whisper-server.env` (mode 0600):
```
HF_TOKEN=hf_...
LD_LIBRARY_PATH=/srv/whisper/.venv/lib/python3.x/site-packages/nvidia/cublas/lib:/srv/whisper/.venv/lib/python3.x/site-packages/nvidia/cudnn/lib
```

### Monitoring (optional Prometheus)

```bash
docker run -d --gpus all --cap-add SYS_ADMIN -p 9400:9400 \
  nvcr.io/nvidia/k8s/dcgm-exporter:4.5.3-4.8.2-distroless
curl localhost:9400/metrics
```

Or just CSV-log nvidia-smi:
```bash
nvidia-smi --query-gpu=timestamp,temperature.gpu,utilization.gpu,memory.used,power.draw \
  --format=csv -l 60 >> /var/log/gpu.log &
```

### Disk health (weekly cron)

```bash
sudo smartctl -a /dev/nvme0
```

Watch `Percentage Used` and `Available Spare`.

### Quarterly maintenance window

- Snapshot rootfs (Btrfs/LVM) before upgrade
- Manually upgrade `nvidia-driver-535*` + `cuda-*` together
- Run smoke tests (Phase 4) end-to-end
- Roll back snapshot if anything regresses

---

## What success looks like

After completing all phases, you should be able to:

1. SSH in over LAN by hostname (`ssh ai@gs63vr.local`)
2. Wake the box via WoL after `systemctl poweroff`
3. Run `nvidia-smi` showing GTX 1060 6GB, driver 535, persistence on, power cap 65W
4. `gpu-burn` runs 1 hour with zero errors, peak temp < 82°C
5. `whisperx clip.wav --diarize` produces SRT with speaker labels
6. `yolo predict source=paddock.jpg` returns bounding boxes
7. Logs rotate at 4-week retention; rootfs free space stable
8. NVIDIA driver pinned — apt does not bump it on security upgrades

## Troubleshooting cheatsheet

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Requested float16 ... do not support efficient float16 computation` | Used `compute_type="float16"` on Pascal | Switch to `int8` |
| `Could not find a version that satisfies the requirement lightning>=2.0.1` | pyannote 3.3.x lightning quarantine | Pin pyannote 3.1, or `pip install pytorch-lightning` + `--no-deps` |
| `TypeError: ... got unexpected keyword argument 'use_auth_token'` | WhisperX 3.8.5 + pyannote 4.x mismatch | Downgrade pyannote to 3.1 |
| 401 from HF when loading pyannote pipeline | Token missing OR user-conditions not accepted | Accept conditions in browser; export HF_TOKEN |
| `nvidia-smi` shows persistence/PL reset after reboot | `-pm` and `-pl` don't persist | Confirm `nvidia-tuning.service` is enabled |
| GS63VR throttling under sustained load | Stock cooling marginal | Cooling pad + lid open + `-pl 65` + throttled undervolt |
| Wi-Fi keeps dropping | ath10k_pci firmware crash | Use ethernet only (don't trust Killer 1535 on Linux) |
| CUDA 13 install breaks faster-whisper | Pascal sm_61 removed in CUDA 13 | Pin CUDA 12.x; never install 13.x |

## See also (in this wiki)

- [[topics/gtx-1060-headless-ai-server-synthesis]] — single-page summary
- [[concepts/pascal-driver-cuda-pinning]]
- [[concepts/ctranslate2-quantization-on-pascal]]
- [[concepts/faster-whisper-on-gtx-1060]]
- [[concepts/whisperx-vs-manual-pyannote-integration]]
- [[concepts/whisperx-known-broken-installs]]
- [[concepts/pyannote-audio-3.x-on-pascal]]
- [[concepts/farm-vision-on-gtx-1060]]
- [[concepts/headless-ubuntu-laptop-baseline]]
- [[concepts/gpu-bench-and-smoke-tests]]
- [[concepts/gpu-thermals-and-ops]]
