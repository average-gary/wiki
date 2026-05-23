---
title: "Plaquet & Bredin 2023 — Powerset multi-class cross entropy loss for neural speaker diarization"
source: https://arxiv.org/abs/2310.13025
type: paper
tags: [pyannote, diarization, powerset, bce, peer-reviewed, interspeech-2023]
date: 2026-05-21
quality: 6
confidence: high
agent: 5
summary: "INTERSPEECH 2023 paper introducing powerset multi-class loss used to train pyannote/segmentation-3.0. Eliminates detection threshold hyperparameter; significantly better on overlapping speech."
---

# Powerset multi-class cross-entropy for speaker diarization

## Authors

Alexis Plaquet & Hervé Bredin

## Citation

Proc. INTERSPEECH 2023, pp. 3222–3226, Dublin, Ireland.

## Verbatim abstract

> "[We] reformulate speaker diarization as a powerset multi-class problem... dedicated classes are assigned to pairs of overlapping speakers... eliminates the need for a detection threshold hyperparameter... significantly better performance (mostly on overlapping speech) and robustness to domain mismatch [over multi-label EEND baselines since 2019]."

Tested across 9 benchmarks. This is the loss used to train `pyannote/segmentation-3.0` — the segmentation block in the speaker-diarization-3.1 pipeline.

## Why this matters for the project

- Confirms the academic basis for trusting pyannote 3.x diarization quality
- Output: 7 classes — non-speech; speakers #1, #2, #3 (single); pairs #1&#2, #1&#3, #2&#3 (overlap)
- Up to 3 speakers per 10s chunk, 2 simultaneous per frame
