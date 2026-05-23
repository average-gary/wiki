---
title: "pyannote/speaker-diarization-3.1 — model card"
source: https://huggingface.co/pyannote/speaker-diarization-3.1
type: article
tags: [pyannote, diarization, der, gated-model, hf-token]
date: 2026-05-21
quality: 6
confidence: high
agent: 5
summary: "Pure-PyTorch pipeline (3.0's onnxruntime dep removed). Segmentation-3.0 (powerset BCE) + wespeaker ResNet34 + agglomerative clustering. DER table: AMI IHM 18.8%, DIHARD3 21.7%, VoxConverse v0.3 11.3%. Gated — accept user conditions on segmentation-3.0 AND speaker-diarization-3.1, then HF read token."
---

# pyannote/speaker-diarization-3.1

## Architecture

- **Segmentation**: `pyannote/segmentation-3.0` (PyAnNet-style, powerset BCE-trained, 10s chunks at 16kHz, ≤3 speakers/chunk + 2 simultaneous)
- **Embedding**: `wespeaker/wespeaker-voxceleb-resnet34-LM` (ResNet34 x-vector, ~256-d)
- **Clustering**: agglomerative hierarchical
- License: MIT
- Paper: Plaquet & Bredin INTERSPEECH 2023 (powerset BCE) + Bredin INTERSPEECH 2023 (pipeline)

## Verbatim — change vs 3.0

> "This pipeline is the same as `pyannote/speaker-diarization-3.0` except it removes the problematic use of `onnxruntime`. Both speaker segmentation and embedding now run in pure PyTorch. This should ease deployment and possibly speed up inference."
>
> "It ingests mono audio sampled at 16kHz and outputs speaker diarization as an `Annotation` instance. Stereo or multi-channel audio files are automatically downmixed to mono by averaging the channels."

## DER benchmark table

Fully automatic, no manual VAD, no per-dataset tuning, no collar, overlapped speech evaluated:

| Dataset | DER% | FA% | Miss% | Conf% |
|---------|------|-----|-------|-------|
| AISHELL-4 | 12.2 | 3.8 | 4.4 | 4.0 |
| AMI (IHM) | 18.8 | 3.6 | 9.5 | 5.7 |
| DIHARD 3 | 21.7 | 6.2 | 8.1 | 7.3 |
| VoxConverse v0.3 | 11.3 | 4.1 | 3.4 | 3.8 |

## Gated-model workflow (do BEFORE pip install)

1. Create read token: https://huggingface.co/settings/tokens
2. Accept conditions on `pyannote/segmentation-3.0`
3. Accept conditions on `pyannote/speaker-diarization-3.1`
4. Pass token to `Pipeline.from_pretrained` or run `huggingface-cli login`

## Usage

```python
from pyannote.audio import Pipeline
import torch
pipeline = Pipeline.from_pretrained(
    "pyannote/speaker-diarization-3.1",
    use_auth_token="hf_...")
pipeline.to(torch.device("cuda"))
diarization = pipeline("audio.wav")
```

Speaker count hints:
```python
diarization = pipeline("audio.wav", num_speakers=2)
diarization = pipeline("audio.wav", min_speakers=2, max_speakers=5)
```

ProgressHook:
```python
from pyannote.audio.pipelines.utils.hook import ProgressHook
with ProgressHook() as hook:
    diarization = pipeline("audio.wav", hook=hook)
```

## Pascal compatibility

No Pascal-specific blockers documented. Pipeline runs **fp32 by default** — no autocast/`.half()` calls — which is correct for Pascal sm_61 (weak fp16 throughput 1:64). Empirical community VRAM usage at default batch sizes ~1.5–3GB; reduce `pipeline.segmentation_batch_size` and `pipeline.embedding_batch_size` if OOM.

Issue #1370 notes ~12% relative DER drift between CUDA 11.6 → 11.7 due to embedding+clustering non-determinism (not a bug, expect small drift vs published table).
