---
title: "faster-whisper on GTX 1060 6GB — model picks, VRAM, version pins"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/repos/2026-05-21-faster-whisper.md
  - raw/data/2026-05-21-charliemike-gtx-1060-rtfx.md
---

# faster-whisper on GTX 1060 6GB

## Model fit on 6GB headless

| Model | int8 VRAM | fp32 VRAM | Recommended? |
|-------|-----------|-----------|--------------|
| tiny | ~0.3 GB | ~0.5 GB | trivial |
| base | ~0.5 GB | ~0.7 GB | trivial |
| small | ~1.0 GB | ~1.5 GB | easy |
| medium | ~2.0 GB | ~3.0 GB | comfortable |
| large-v2 | ~2.9 GB | ~4.5 GB | fits with margin (V100 reference) |
| **large-v3** | **~2.95 GB** | **~4.5 GB** | **fits — leaves ~3 GB for pyannote** |
| large-v3-turbo | ~1.5 GB | ~2.5 GB | very comfortable |
| **distil-large-v3** | **~1.5–2 GB** | ~3 GB | **best accuracy/speed/VRAM tradeoff** |

(VRAM numbers from [[faster-whisper README|raw/repos/2026-05-21-faster-whisper]] V100 benchmark; representative for sm_61 since memory is identical, only compute path differs.)

## Real-time factor on GTX 1060

The only first-party 1060 number I could find is from [[charliemike RTFx benchmark|raw/data/2026-05-21-charliemike-gtx-1060-rtfx]]:

| Configuration | RTFx | 1 hour audio takes |
|---|---|---|
| **distil-large-v3-turbo + int8** | **~60x** | **~1 minute** |
| large-v3 int8 (extrapolated) | ~20x | ~3 minutes |
| large-v3 fp32 | ~15-25x | ~3-4 minutes |
| whisper.cpp CPU baseline | ~1-3x | ~20-60 minutes |

(confidence: medium — single bench source for 1060)

## Version-pin matrix (CRITICAL)

From [[faster-whisper README|raw/repos/2026-05-21-faster-whisper]]:

| CUDA | cuDNN | ctranslate2 |
|------|-------|-------------|
| 12.x | 9 | latest (4.5+) |
| 12.x | 8 | **pin 4.4.0** |
| 11 | 8 | **pin 3.24.0** |

Recommended for GTX 1060 + driver 535: CUDA 12.x + cuDNN 9 + latest ctranslate2.

## Install (Ubuntu 22.04 GPU path)

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip
pip install faster-whisper
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*
export LD_LIBRARY_PATH=$(python3 -c 'import os, nvidia.cublas.lib, nvidia.cudnn.lib; print(os.path.dirname(nvidia.cublas.lib.__file__) + ":" + os.path.dirname(nvidia.cudnn.lib.__file__))')
```

## Recommended starting code

```python
from faster_whisper import WhisperModel, BatchedInferencePipeline

# distil-large-v3 + int8 = sweet spot for GTX 1060 6GB
model = WhisperModel("distil-large-v3", device="cuda", compute_type="int8")
batched = BatchedInferencePipeline(model=model)
segments, info = batched.transcribe(
    "audio.mp3",
    batch_size=8,        # safer than 16 on 6GB if pyannote is loaded
    vad_filter=True,
    beam_size=1,         # distil works well at beam=1
)
```

## Why `int8` and not `float16`

See [[ctranslate2-quantization-on-pascal]] — `compute_type="float16"` is silently demoted to fp32 on Pascal. Pick `int8` explicitly.

## See also

- [[whisperx-vs-manual-pyannote-integration]] — alignment + diarization wrapper
- [[pyannote-audio-3.x-on-pascal]] — diarization VRAM coexistence
- [[ctranslate2-quantization-on-pascal]] — compute_type table
