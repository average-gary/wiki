---
title: "Headless GPU benchmark + smoke-test suite for GTX 1060"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: cold
confidence: high
sources:
  - raw/repos/2026-05-21-gpu-burn.md
  - raw/repos/2026-05-21-dcgm-exporter.md
---

# GPU bench + smoke tests

A 5-layer verification stack:

1. **Driver/runtime sanity** — `nvidia-smi`, `deviceQuery`, `bandwidthTest`
2. **Burn-in** — `gpu-burn`, `stress-ng`
3. **Framework smoke** — PyTorch one-liner, ctranslate2, pyannote
4. **Workload micro-benchmarks** — Whisper RTF, YOLO FPS, NVENC FPS
5. **Continuous monitoring** — `nvidia-smi` CSV log or DCGM-exporter → Prometheus

## Layer 1: 5-minute sanity

```bash
nvidia-smi                              # driver alive
nvidia-smi -q                           # full per-GPU dump
nvidia-smi -q -d CLOCK,POWER,TEMPERATURE,UTILIZATION
nvidia-smi topo -m                      # PCIe topology

# CUDA samples (build once)
git clone https://github.com/NVIDIA/cuda-samples
cd cuda-samples && git checkout v12.4   # match your CUDA toolkit
mkdir build && cd build && cmake .. && make -j$(nproc)
./Samples/1_Utilities/deviceQuery/deviceQuery       # expect Result = PASS, CC 6.1
./Samples/1_Utilities/bandwidthTest/bandwidthTest   # expect HtoD/DtoH ~12 GB/s on PCIe 3.0 x16
```

cuDNN sanity:
```bash
sudo apt install libcudnn9-samples
cd $HOME/cudnn_samples_v9/mnistCUDNN && make && ./mnistCUDNN     # expect "Test passed!"
```

## Layer 2: burn-in (CRITICAL Pascal flag)

[[gpu-burn|raw/repos/2026-05-21-gpu-burn]] **must** be built with `make COMPUTE=6.1` for Pascal — default builds target newer arch and silently misbehave.

```bash
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make COMPUTE=6.1
./gpu_burn 600                  # 10-min smoke
./gpu_burn -d 3600              # 1-hour double-precision burn-in
./gpu_burn -m 5500 1800         # cap at 5.5 GB on 6 GB card, 30 min
```

CPU/RAM:
```bash
stress-ng --cpu $(nproc) --vm 2 --vm-bytes 75% --timeout 600s --metrics-brief
sysbench cpu --threads=$(nproc) --time=60 run
sysbench memory --memory-total-size=10G run
```

If gpu-burn passes 1 hour AND temps stay safe (< 80°C with [[power cap|gpu-thermals-and-ops]]) → GPU + driver + power delivery are good for sustained inference.

## Layer 3: framework smoke

PyTorch one-liner (expect `True (6, 1) <cuda> <cudnn>`):
```bash
python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_capability(), torch.version.cuda, torch.backends.cudnn.version())"
```

Allocate + compute + sync:
```python
import torch
x = torch.randn(4096, 4096, device='cuda')
y = x @ x
torch.cuda.synchronize()
print('OK', y.sum().item(), torch.cuda.get_device_name())
```

ctranslate2 / faster-whisper sanity (use `int8`, NOT float16 — see [[ctranslate2-quantization-on-pascal]]):
```python
from faster_whisper import WhisperModel
model = WhisperModel("base", device="cuda", compute_type="int8")
segments, info = model.transcribe("clip.wav", beam_size=5)
print(info.language)
for s in segments: print(f"[{s.start:.2f}-{s.end:.2f}] {s.text}")
```

pyannote sanity (after HF gating accepted, see [[pyannote-audio-3.x-on-pascal]]):
```python
import torch, time
from pyannote.audio import Pipeline
pipe = Pipeline.from_pretrained("pyannote/speaker-diarization-3.1", token="<HF_TOKEN>")
pipe.to(torch.device("cuda"))
t0 = time.time(); diar = pipe("clip.wav"); print("wall=", time.time()-t0)
```

## Layer 4: ffmpeg NVENC/NVDEC (Pascal GP106 = 4th-gen NVENC)

GTX 1060 supports **H.264 + HEVC encode**, no AV1 (Pascal predates AV1). NVDEC: H.264, HEVC, VP9, MPEG-2, VC-1.

```bash
ffmpeg -hwaccels                                # should list cuda, cuvid, nvdec
ffmpeg -hide_banner -encoders 2>/dev/null | grep nvenc
ffmpeg -hide_banner -decoders 2>/dev/null | grep -E 'cuvid|nvdec'

# Encode smoke (synthetic source)
ffmpeg -y -f lavfi -i testsrc=size=1920x1080:rate=30 -t 5 -c:v h264_nvenc -preset p4 out.mp4

# Full GPU pipeline (decode + encode without CPU touch)
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i in.mp4 -c:v h264_nvenc -preset p4 out.mp4

nvidia-smi dmon -s u -c 30                      # watch encoder/decoder load
```

## Layer 5: workload-shaped micro-benchmarks

Custom one-shot scripts for the actual workloads — these are the only numbers that matter for capacity planning:

| Bench | Command | Expected on 1060 |
|-------|---------|------------------|
| Whisper RTF | Transcribe a 10-min clip; measure wall time | distil-large-v3 int8: ~10s; large-v3 int8: ~30s |
| pyannote DER | Run pipeline on same 10-min clip; measure wall time | ~15-25s |
| YOLO FPS | `from ultralytics.utils.benchmarks import benchmark; benchmark(model='yolo11n.pt', imgsz=640, half=True, device=0)` | n: 40-60 FPS, s: 20-35 FPS |
| NVENC FPS | Encode 1-min 1080p30 H.264 | 200-400 FPS source |
| llama.cpp | `llama-bench -m model-Q4_K_M.gguf -p 512 -n 128 -ngl 32 -r 5` | ~7B Q4_K_M @ 8-15 tok/s |

## Layer 6: continuous monitoring

Quick CSV (single-machine):
```bash
nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,memory.used,power.draw,clocks.sm \
  --format=csv -l 5 >> /var/log/gpu.log &
nvidia-smi dmon -s pucvmet -o DT -c 0
```

Prometheus stack: [[DCGM-exporter|raw/repos/2026-05-21-dcgm-exporter]] (Pascal-compatible, basic counters only — DCGM profiling metrics need Ampere+) → Grafana.

```bash
docker run -d --gpus all --cap-add SYS_ADMIN -p 9400:9400 \
  nvcr.io/nvidia/k8s/dcgm-exporter:4.5.3-4.8.2-distroless
```

Lighter alternative: `utkuozbulak/nvidia_gpu_exporter` — `nvidia-smi --query-gpu` wrapper, no SYS_ADMIN cap.

## See also

- [[pascal-driver-cuda-pinning]]
- [[gpu-thermals-and-ops]]
- [[ctranslate2-quantization-on-pascal]]
