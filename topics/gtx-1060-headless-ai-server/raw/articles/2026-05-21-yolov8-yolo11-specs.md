---
title: "Ultralytics YOLOv8 + YOLO11 — model specs comparison"
source: https://docs.ultralytics.com/models/yolov8/, https://docs.ultralytics.com/models/yolo11/
type: article
tags: [yolo, yolov8, yolo11, model-specs, gtx-1060, vram-budget]
date: 2026-05-21
quality: 5
confidence: high
agent: 6
summary: "Canonical Ultralytics specs. YOLO11n: 2.6M / 39.5 mAP. YOLO11s: 9.4M / 47.0 mAP. YOLO11m: 20.1M / 51.5 mAP — the m variant has 22% fewer params than YOLOv8m at higher mAP. For 1060 6GB: n trains at batch 16, s at batch 8, m at batch 2-4 with grad accum."
---

# YOLOv8 + YOLO11 specs

## YOLOv8

| Variant | Params (M) | FLOPs (B) | mAP COCO | CPU ms | A100 GPU ms |
|---------|------------|-----------|----------|--------|-------------|
| YOLOv8n | 3.2 | 8.7 | 37.3 | 80.4 | 0.99 |
| YOLOv8s | 11.2 | 28.6 | 44.9 | 128.4 | 1.20 |
| YOLOv8m | 25.9 | 78.9 | 50.2 | 234.7 | 1.83 |
| YOLOv8l | 43.7 | 165.2 | 52.9 | 375.2 | 2.39 |
| YOLOv8x | 68.2 | 257.8 | 53.9 | 479.1 | 3.53 |

## YOLO11

| Variant | Params (M) | FLOPs (B) | mAP COCO | CPU ms | T4 TRT10 ms |
|---------|------------|-----------|----------|--------|-------------|
| YOLO11n | 2.6 | 6.5 | **39.5** | 56.1 | 1.5 |
| YOLO11s | 9.4 | 21.5 | **47.0** | 90.0 | 2.5 |
| YOLO11m | 20.1 | 68.0 | **51.5** | 183.2 | 4.7 |
| YOLO11l | 25.3 | 86.9 | 53.4 | 238.6 | 6.2 |
| YOLO11x | 56.9 | 194.9 | 54.7 | 462.8 | 11.3 |

> "YOLO11m achieves a higher mean Average Precision (mAP) on the COCO dataset while using 22% fewer parameters than YOLOv8m"

## GTX 1060 6GB practical batches (640px training)

| Variant | Train batch | Inference FPS (PyTorch fp32) |
|---------|-------------|------------------------------|
| YOLO11n / YOLOv8n | 16 | 40-60 |
| YOLO11s / YOLOv8s | 8 | 20-35 |
| YOLO11m / YOLOv8m | 2-4 with grad accum 4 | 8-15 |
| YOLO11l/x, YOLOv8l/x | infeasible | very low |

## Pascal-specific caveats

- T4 TensorRT 10 numbers do NOT translate to GTX 1060 — **TensorRT 10 dropped Pascal support**; must use TensorRT 8.6.x for sm_61 INT8/FP16 export
- No Tensor Cores on Pascal → AMP/FP16 training gives ~1.3-1.5× speedup at best (vs 2-3× on Turing+)
- Some users report AMP loss-scaling issues on 1060 — keep FP32 if losses NaN

## Recommendation

For livestock detection on GTX 1060 6GB:
- **Drone/aerial stills**: YOLO11s @ 1280px, batch 4 + grad accum 4
- **Ground CCTV**: YOLO11n @ 640px, batch 16, with ByteTrack/BoT-SORT for line-crossing counts
