---
title: "SYSTRAN/faster-whisper — README + benchmarks"
source: https://github.com/SYSTRAN/faster-whisper
type: repo
tags: [faster-whisper, ctranslate2, whisper, install, benchmark, vram]
date: 2026-05-21
quality: 6
confidence: high
agent: 3
summary: "Primary install + benchmark source. Critical version-pin: latest ctranslate2 needs CUDA 12 + cuDNN 9. CUDA 11/cuDNN 8 → pin ctranslate2==3.24.0. CUDA 12/cuDNN 8 → 4.4.0. VRAM tables for large-v3 fp16/int8."
---

# faster-whisper — install + benchmarks

## Install (Ubuntu 22.04 GPU path)

```bash
pip install faster-whisper
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*
export LD_LIBRARY_PATH=$(python3 -c 'import os, nvidia.cublas.lib, nvidia.cudnn.lib; print(os.path.dirname(nvidia.cublas.lib.__file__) + ":" + os.path.dirname(nvidia.cudnn.lib.__file__))')
```

## CRITICAL version-pin matrix

| CUDA | cuDNN | ctranslate2 |
|------|-------|-------------|
| 12.x | 9 | latest (4.5+) |
| 12.x | 8 | **4.4.0** (pin) |
| 11 | 8 | **3.24.0** (pin) |

> "The latest versions of `ctranslate2` only support CUDA 12 and cuDNN 9. For CUDA 11 and cuDNN 8, the current workaround is downgrading to the `3.24.0` version of `ctranslate2`."

## VRAM benchmarks (large-v2, 13 min audio, V100 — upper bound)

| Implementation | Precision | Beam | Time | VRAM |
|---|---|---|---|---|
| faster-whisper | fp16 | 5 | 1m03s | 4525 MB |
| faster-whisper batch=8 | fp16 | 5 | 17s | 6090 MB |
| faster-whisper | **int8** | 5 | 59s | **2926 MB** |

## large-v3 / turbo

| Model | Precision | Time | VRAM |
|---|---|---|---|
| large-v3 | fp16 | 52s | 4521 MB |
| large-v3 | int8 | 52.6s | **2953 MB** |
| large-v3-turbo | fp16 | 19.2s | 2537 MB |
| large-v3-turbo | int8 | 19.6s | **1545 MB** |

**Implication for 6GB GTX 1060**: large-v3 int8 fits with 3GB margin → enough room for pyannote diarization to coexist if sequenced. fp16 leaves only ~1.4GB → expect OOM with pyannote.

## BatchedInferencePipeline

```python
from faster_whisper import WhisperModel, BatchedInferencePipeline
model = WhisperModel("turbo", device="cuda", compute_type="float16")
batched_model = BatchedInferencePipeline(model=model)
segments, info = batched_model.transcribe("audio.mp3", batch_size=16)
```
"VAD filter is enabled by default for batched transcription."

## VAD (Silero)

```python
segments, _ = model.transcribe(
    "audio.mp3",
    vad_filter=True,
    vad_parameters=dict(min_silence_duration_ms=500),
)
```

## Distil-Whisper

```python
model = WhisperModel("distil-large-v3", device="cuda", compute_type="float16")
segments, info = model.transcribe("audio.mp3", beam_size=5, language="en",
                                   condition_on_previous_text=False)
```

## Recommended starting point for GTX 1060

```python
from faster_whisper import WhisperModel, BatchedInferencePipeline
model = WhisperModel("distil-large-v3", device="cuda", compute_type="int8")
batched = BatchedInferencePipeline(model=model)
segments, info = batched.transcribe("audio.mp3", batch_size=8, vad_filter=True, beam_size=1)
```
