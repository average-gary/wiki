---
title: "WhisperX install gotchas — lightning quarantine + use_auth_token mismatch"
type: concept
created: 2026-05-21
updated: 2026-05-21
verified: 2026-05-21
volatility: hot
confidence: high
sources:
  - raw/articles/2026-05-21-whisperx-known-broken.md
---

# WhisperX install gotchas (May 2026)

Two open issues will bite you on a fresh install. Source: [[issues #1412 and #1406|raw/articles/2026-05-21-whisperx-known-broken]].

## Gotcha 1 — pyannote-audio 3.3.x / 3.4.0 uninstallable (`lightning` quarantine)

`pyannote-audio` 3.3.2 / 3.4.0 declare `lightning>=2.0.1` as a dep. PyPI quarantined the `lightning` meta-package. Both `pip` and `uv` fail with:

```
Could not find a version that satisfies the requirement lightning>=2.0.1
```

**Fix**:

```bash
pip install pytorch-lightning>=2.0.1
pip install pyannote-audio==3.3.2 --no-deps
pip install asteroid-filterbanks>0.4 einops>0.6.0 omegaconf>2.1
```

Or skip 3.3.x entirely and pin **pyannote 3.1 / 3.2** (or jump to 4.x).

## Gotcha 2 — WhisperX 3.8.5 stale `use_auth_token` call site

WhisperX 3.8.5 requires `pyannote-audio>=4.0.0`. pyannote 4.x deprecated `use_auth_token=` in favor of `token=`. WhisperX migrated `whisperx/vads/pyannote.py` but forgot `whisperx/asr.py`.

If you see a TypeError or auth error on pyannote 4.x: this is why. **Workaround**: patch the wheel manually OR downgrade pyannote to 3.1:

```bash
pip install "pyannote.audio>=3.1,<3.3" --no-deps
pip install pytorch-lightning asteroid-filterbanks einops omegaconf
```

Status May 2026: open, monitor [m-bain/whisperX#1406](https://github.com/m-bain/whisperX/issues/1406).

## Recommended pin path for GTX 1060 6GB (least-pain)

```bash
# 1. Accept HF gating in browser FIRST:
#    https://huggingface.co/pyannote/segmentation-3.0
#    https://huggingface.co/pyannote/speaker-diarization-3.1

# 2. CUDA 12 + cuDNN 9 path
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*

# 3. Install whisperx (will pull torch ~2.8, ct2 4.5+, pyannote 4.0+)
pip install whisperx

# 4. If issue #1406 bites, downgrade pyannote:
pip install "pyannote.audio>=3.1,<3.3" --no-deps
pip install pytorch-lightning>=2.0.1 asteroid-filterbanks>0.4 einops omegaconf
```

## Also remember

- `use_auth_token` (pyannote 3.x) vs `token` (pyannote 4.x) — silent landmine. If diarization 401s at runtime not at install, this is why.
- HF gating must be done in browser **before** any pip install runs — the pipeline 401s at runtime when the token can't fetch the gated model card.

## See also

- [[whisperx-vs-manual-pyannote-integration]] — pipeline overview
- [[pyannote-audio-3.x-on-pascal]] — gated-model workflow
