---
title: "NVIDIA DCGM-exporter — Prometheus GPU metrics"
source: https://github.com/NVIDIA/dcgm-exporter
type: repo
tags: [monitoring, prometheus, dcgm, nvidia, gpu-metrics]
date: 2026-05-21
quality: 4
confidence: high
agent: 7
summary: "NVIDIA-official Prometheus exporter for GPU metrics. Pascal-compatible (no profiling metrics — those need Ampere+ — but core/memory/clocks/temp/power available). Plenty for a homelab."
---

# DCGM-exporter

## Run (Docker)

```bash
docker run -d --gpus all --cap-add SYS_ADMIN -p 9400:9400 \
  nvcr.io/nvidia/k8s/dcgm-exporter:4.5.3-4.8.2-distroless
curl localhost:9400/metrics
```

## Pascal compatibility

- Core/memory/clocks/temp/power: ✓
- Profiling metrics (DCGM advanced): ✗ (require Ampere+)
- For a homelab single-GPU box: basic counters are sufficient

## Lighter alternative

[`utkuozbulak/nvidia_gpu_exporter`](https://github.com/utkuozbulak/nvidia_gpu_exporter) — `nvidia-smi --query-gpu` wrapper, no SYS_ADMIN cap, fewer metrics. Good single-GPU homelab fit.

## Quick CSV logging (no Prometheus needed)

```bash
nvidia-smi --query-gpu=timestamp,name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,power.draw,clocks.sm,clocks.mem \
  --format=csv -l 5 >> /var/log/gpu.log
nvidia-smi dmon -s pucvmet -o DT -c 0
```
