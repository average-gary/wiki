---
title: "Ultralytics object counting — built-in detect+track+line/zone"
source: https://docs.ultralytics.com/guides/object-counting/
type: guide
tags: [yolo, counting, tracking, bytetrack, botsort, livestock]
date: 2026-05-21
quality: 4
confidence: high
agent: 6
summary: "Built-in `yolo solutions count` does detect+track+line/zone counting. Aquaculture fish-population is explicitly listed (closest analog to livestock). For ground CCTV cattle counting: line-zone + ByteTrack."
---

# Ultralytics object counting

## What it does

> "accurate identification and counting of specific objects in videos and camera streams"

Excels at real-time surveillance, crowd analysis. Practical applications listed include:
- Logistics conveyor belt
- **Aquaculture fish population monitoring** ← closest livestock analog
- Retail customer flow
- Traffic vehicle counting

## Region argument formats

- **Lines**: two points → line-crossing detection (directional count)
- **Polygons**: ≥3 points → bounded zone count

## Tracking backends

- **BoT-SORT** (default: `botsort.yaml`)
- **ByteTrack** (`bytetrack.yaml`)

## Quick start

```bash
yolo solutions count source="path/to/video.mp4" region="[(20, 400), (1080, 400)]"
```

## Key parameters

| Parameter | Purpose |
|-----------|---------|
| `classes` | Filter by class index (e.g. `[0, 2]`) |
| `conf` | Confidence threshold (default 0.1) |
| `iou` | IoU threshold (default 0.7) |
| `device` | CPU, GPU, or compute device |

## Recipes for farm tasks

**Ground CCTV — cattle moving through gate/race**:
- Lateral video → YOLO11n fine-tuned on lateral cattle imagery
- LineZone perpendicular to direction of travel
- ByteTrack to maintain IDs (prevents double-counting)
- Result: directional count

**Drone/aerial stills — paddock census**:
- Top-down stills → YOLO11s @ 1280px
- No tracking needed — `count = len(boxes)` per frame
- For dense flocks (overlapping), fall back to CSRNet density regression
