---
title: "Bhujel et al. 2024 — Public CV Datasets for Precision Livestock Farming: Systematic Survey"
source: https://arxiv.org/abs/2406.10628
type: paper
tags: [livestock, cattle, datasets, survey, peer-reviewed]
date: 2026-05-21
quality: 6
confidence: high
agent: 6
summary: "Surveys 58 public livestock CV datasets. Half are for cattle, then swine, poultry. Individual animal detection + color imaging dominate. Bottleneck: limited high-quality annotated datasets from diverse environments."
---

# Public CV Datasets for Precision Livestock Farming

## Authors

Bhujel et al. (2024)

## Verbatim

> "Among 58 public datasets identified and analyzed, encompassing different species of livestock, almost half of them are for cattle, followed by swine, poultry, and other animals... Individual animal detection and color imaging are the dominant application and imaging modality for livestock."
>
> "Limited quantity of high-quality annotated datasets collected from diverse environments [remains a bottleneck]."

## Datasets to consider for the GTX 1060 stack

- **AerialCattle2017** (University of Bristol, UAV Friesian cattle, hosted at data.bris.ac.uk) — primary aerial-cattle benchmark
- **Roboflow Universe** — search "cattle", "sheep", "livestock" for community YOLO-format datasets with pretrained weights for warm-start fine-tuning
- ShanghaiTech (human crowds; transferable architecture for density-regression workflows)
- ~58 surveyed public livestock datasets per Bhujel et al.

## Practical takeaway

For a project starting on a 6GB Pascal GPU:
1. Pull a Roboflow Universe cattle dataset → already in YOLO format
2. Warm-start from YOLOv8s/YOLO11s COCO weights
3. Fine-tune ~50 epochs at 640px batch 8 on the 1060
4. Validate on AerialCattle2017 if drone-deployment is the use case
