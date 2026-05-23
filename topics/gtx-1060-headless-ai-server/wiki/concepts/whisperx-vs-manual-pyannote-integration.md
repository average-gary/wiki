---
title: "WhisperX vs faster-whisper + manual pyannote — pick WhisperX, pin carefully"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/repos/2026-05-21-whisperx.md
  - raw/repos/2026-05-21-whisper-diarization.md
  - raw/repos/2026-05-21-pyannote-audio.md
---

# WhisperX vs manual pyannote integration

## TL;DR

**Pick WhisperX** for transcription + speaker diarization on a 6GB Pascal GPU. You get wav2vec2 forced-alignment for free (which fixes Whisper's sloppy word timestamps) and `assign_word_speakers()` joins speakers per word. The main risks are dependency-pin landmines — read [[whisperx-known-broken-installs]] before installing.

## What WhisperX does that faster-whisper alone doesn't

Pipeline ([[WhisperX repo|raw/repos/2026-05-21-whisperx]]):
1. VAD preprocessing
2. faster-whisper batched inference
3. **wav2vec2 forced alignment** ← the key value-add (Whisper's built-in word timestamps are inaccurate)
4. pyannote diarization
5. `assign_word_speakers()` — joins speaker IDs to individual words

WhisperX claims `<8GB GPU memory for large-v2 with beam_size=5` — fits on 1060 6GB if you sequence model loads.

## Current pin set (WhisperX 3.8.x, May 2026)

```
python>=3.10, <3.14
torch ~=2.8.0
ctranslate2 >=4.5.0
faster-whisper >=1.2.0
pyannote-audio >=4.0.0       # ← jumped from 3.x
transformers >=4.48.0
```

## Low-VRAM levers for 6GB Pascal

- `--batch_size 4` (down from default 16)
- `--compute_type int8` ← NOT float16 (Pascal silently falls back, see [[ctranslate2-quantization-on-pascal]])
- Smaller model (`--model base|medium|distil-large-v3` instead of `large-v3`)
- **Sequence model loads** between transcribe / align / diarize:
  ```python
  import gc, torch
  del model; gc.collect(); torch.cuda.empty_cache()
  ```

## Alternative: whisper-diarization (no HF gating)

[MahmoudAshraf97/whisper-diarization](../../raw/repos/2026-05-21-whisper-diarization.md) uses NVIDIA NeMo (MarbleNet VAD + TitaNet embeddings) instead of pyannote. **No HuggingFace gating, no token dance.** But it recommends ≥10 GB for `diarize_parallel.py` — on 6 GB you must use sequential `diarize.py`. Output is SRT-only.

Pick this if: HF gated models are a non-starter for you OR pyannote 4.x dep hell is breaking your stack.

## Diarization accuracy ranking (DER, lower is better)

From [[pyannote 4.x DER table|raw/repos/2026-05-21-pyannote-audio]]:

1. pyannote `precision-2` (paid cloud) — best
2. pyannote `community-1` (4.x default) — best free
3. pyannote 3.1 (legacy, MIT) — slightly behind community-1
4. NeMo MSDD (whisper-diarization) — competitive on 2-4 speakers
5. NVIDIA Sortformer — strong on ≤4 speakers, English, ≤12 min audio only — ❌ deal-breaker for general use (CC-BY-NC-4.0, non-commercial)

## See also

- [[whisperx-known-broken-installs]] — the lightning quarantine + use_auth_token mismatch
- [[pyannote-audio-3.x-on-pascal]] — what pyannote does and how it sizes on 6GB
- [[faster-whisper-on-gtx-1060]] — the underlying transcription engine
