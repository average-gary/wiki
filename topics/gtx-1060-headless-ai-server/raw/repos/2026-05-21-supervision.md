---
title: "Roboflow supervision — model-agnostic counting glue"
source: https://supervision.roboflow.com/latest/
type: repo
tags: [supervision, roboflow, counting, polygon-zone, line-zone, mit]
date: 2026-05-21
quality: 4
confidence: high
agent: 6
summary: "MIT-licensed Python library for model-agnostic detection annotation, tracking, polygon/line zone counting. Works with Ultralytics, YOLO-NAS, RT-DETR, Detectron2, SAM, MMDetection. 38k+ stars, 1M+ monthly PyPI downloads."
---

# supervision (Roboflow)

## What it provides

- **Object Tracking** with persistent IDs across frames
- **Detection Annotation**: bounding boxes, masks, labels
- **Zone Analysis**: count and filter detections inside polygon zones
- **Line Zones**: count objects crossing predefined lines
- **Dataset Conversion**: YOLO ↔ COCO ↔ Pascal VOC
- **Model Benchmarking**: mAP and confusion matrices

## Model-agnostic

Converters for: Ultralytics, Roboflow Inference, Transformers, SAM, Detectron2, MMDetection, YOLO-NAS, PaddleDet, NCNN, Azure AI Vision, VLM parsers.

## License + maturity

- MIT (vs Ultralytics' AGPL-3.0)
- 38,000+ GitHub stars
- 1M+ monthly PyPI downloads
- Python ≥ 3.9

## Why it matters here

If you want to:
- Count cattle entering a paddock (PolygonZone)
- Count cattle crossing a race gate (LineZone)
- Use YOLOv8/v11 weights but escape AGPL by removing the Ultralytics runtime

`supervision` is the canonical glue. Its LineZone + ByteTrack composition is the cleanest path to a counting deliverable.
