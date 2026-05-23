---
title: "Farm vision (herd counting) on GTX 1060 6GB"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: warm
confidence: medium
sources:
  - raw/articles/2026-05-21-yolov8-yolo11-specs.md
  - raw/guides/2026-05-21-ultralytics-object-counting.md
  - raw/repos/2026-05-21-supervision.md
  - raw/papers/2026-05-21-bhujel-livestock-cv-survey.md
---

# Farm vision on GTX 1060 6GB — herd / livestock counting

## TL;DR

- **Train and infer**: YOLO11s (or YOLOv8s) — 9.4 M params, 47 mAP COCO, fits at batch 8 on 6GB at 640px
- **Count**: Ultralytics built-in `yolo solutions count` OR Roboflow `supervision` LineZone/PolygonZone (model-agnostic, MIT)
- **Tracking**: ByteTrack (faster) or BoT-SORT (default) — use for ground CCTV, skip for aerial stills
- **Datasets**: warm-start from Roboflow Universe cattle datasets; validate on AerialCattle2017 (UoBristol) for drone work
- **Pascal caveat**: TensorRT 10 dropped Pascal — use TRT 8.6.x or stay on PyTorch CUDA EP

## Model fit on 6GB

From [[YOLO specs|raw/articles/2026-05-21-yolov8-yolo11-specs]]:

| Variant | Params | mAP COCO | Train batch (640px) | Inference FPS (1060 fp32) |
|---------|--------|----------|----------------------|---------------------------|
| YOLO11n | 2.6 M | 39.5 | 16 | 40-60 |
| **YOLO11s** | **9.4 M** | **47.0** | **8** | **20-35** |
| YOLO11m | 20.1 M | 51.5 | 2-4 + grad accum 4 | 8-15 |
| YOLO11l/x | 25-57 M | 53-55 | infeasible | very low |
| YOLOv8s | 11.2 M | 44.9 | 8 | comparable to 11s |
| RT-DETR-L | ~32 M | 53.0 | tight | likely slower than 11s |

**YOLO11m has 22% fewer params than YOLOv8m at higher mAP** — prefer YOLO11 over v8 in 2026.

## Approach by deployment surface

| Use case | Recipe |
|----------|--------|
| **Drone aerial stills** (paddock census, top-down) | YOLO11s @ 1280px, batch 4 + grad accum 4. Count = `len(boxes)` per frame. No tracking. |
| **Ground CCTV at gate/race** (lateral, animals moving) | YOLO11n @ 640px, batch 16. Ultralytics `solutions count` with LineZone + ByteTrack. |
| **Dense flock (overlapping sheep)** | Density-map regression — CSRNet or DM-Count (small VGG-16 backbone, fits easily). Build your own labels: centroid → gaussian-blur → density map. |

## Counting tooling

**Option A — Ultralytics `solutions count` ([[guide|raw/guides/2026-05-21-ultralytics-object-counting]])**:
```bash
yolo solutions count source="paddock.mp4" region="[(20, 400), (1080, 400)]"
```

**Option B — Roboflow `supervision` ([[repo|raw/repos/2026-05-21-supervision]])**:
- MIT (avoids Ultralytics AGPL-3.0)
- Model-agnostic (Ultralytics + RT-DETR + Detectron2 + SAM + ...)
- LineZone / PolygonZone primitives are clean Python objects

For a hobby/farm project, Ultralytics solutions is faster to deploy. For anything that might ship: `supervision` for license clarity.

## Datasets and warm-start

[[Bhujel et al. 2024 survey|raw/papers/2026-05-21-bhujel-livestock-cv-survey]]: 58 public livestock CV datasets exist; ~half are cattle.

Practical ramp:
1. Pull a cattle dataset from **Roboflow Universe** (already in YOLO format)
2. Warm-start from YOLO11s COCO weights
3. Fine-tune ~50 epochs at 640px batch 8 on the 1060 — overnight job
4. Validate on **AerialCattle2017** (UoB, drone Friesian cattle) if drone is the deployment

Bottleneck per the survey: "Limited quantity of high-quality annotated datasets collected from diverse environments." Be ready to label your own pasture imagery via CVAT or Roboflow.

## Annotation labor reduction

Use **MobileSAM** (9.66M params, ~12ms/image on 1060) for click-to-segment label acceleration in CVAT — turns one click into a tight mask, cuts annotation time by 5-10x for dense images. SAM 2 / SAM2-t (38.9M, 78MB) is also feasible at inference time but heavier than MobileSAM for label work.

## Pascal-specific inference notes

- **TensorRT 10 dropped Pascal** — must use TensorRT 8.6.x for sm_61 INT8/FP16 export, or stay on PyTorch CUDA EP / ONNX Runtime CUDA EP
- Pascal has **no Tensor Cores** → AMP/FP16 training gives ~1.3-1.5x speedup at best; some users see AMP loss-scaling NaN issues on 1060 — fall back to FP32 if it happens
- Realistic FPS targets at 640px PyTorch fp32:
  - YOLO11n: 40-60 FPS
  - YOLO11s: 20-35 FPS
  - YOLO11m: 8-15 FPS
  These are inference; training is ~3-4x slower per step.

## See also

- [[gpu-bench-and-smoke-tests]] — verify your CUDA stack before training
- [[gpu-thermals-and-ops]] — sustained training will heat-soak the GS63VR
- [[pascal-driver-cuda-pinning]] — driver/CUDA stack
