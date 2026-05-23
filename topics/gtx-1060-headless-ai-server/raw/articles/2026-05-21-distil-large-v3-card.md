---
title: "Distil-Whisper distil-large-v3 model card"
source: https://huggingface.co/distil-whisper/distil-large-v3
type: article
tags: [distil-whisper, model-card, wer, compression]
date: 2026-05-21
quality: 5
confidence: high
agent: 3
summary: "756M params (vs large-v3 1550M, ~49%). 6.3x faster. WER short 9.7% vs 8.4% baseline. Long-form WER actually slightly better than large-v3. Sweet spot for 6GB Pascal."
---

# distil-large-v3

## Numbers

| Metric | distil-large-v3 | large-v3 |
|--------|-----------------|----------|
| Params | 756M | 1550M |
| Relative latency | 6.3x faster | 1x |
| RTF (open-asr-leaderboard) | 214.42 | — |
| WER short-form | 9.7% | 8.4% |
| WER long-form (chunked) | **10.9%** | 11.0% |

## faster-whisper usage

```python
from faster_whisper import WhisperModel
model = WhisperModel("distil-large-v3", device=device, compute_type=compute_type)
segments, info = model.transcribe(audio_path, beam_size=1)
```

## Why this is the GTX 1060 sweet spot

- Roughly half the VRAM of large-v3 int8 → fits well under 2GB
- Half the transcription time of large-v3
- Long-form WER actually slightly better than large-v3 (chunked-mode advantage)
- Leaves 4GB+ free for pyannote diarization to coexist
