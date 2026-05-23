---
title: "WhisperX known-broken issues — pyannote 3.3.x lightning quarantine, 4.x partial migration"
source: https://github.com/m-bain/whisperX/issues/1412
type: article
tags: [whisperx, pyannote, lightning, version-pin, gotchas]
date: 2026-05-21
quality: 4
confidence: medium
agent: 4
summary: "Two open issues that bite installers in 2026: (#1412) pyannote 3.3.2/3.4.0 declare lightning>=2.0.1 but PyPI quarantined the lightning meta-package; (#1406) WhisperX 3.8.5 still has stale use_auth_token call site after pyannote 4.x migration."
---

# WhisperX install gotchas (2026)

## Issue #1412 — pyannote-audio 3.3.2 / 3.4.0 uninstallable

> "pyannote-audio>=3.3.2 cannot be used due to lightning package quarantine"

`pyannote-audio` 3.3.2/3.4.0 declare `lightning>=2.0.1` but PyPI admins quarantined the `lightning` meta-package. Both `pip` and `uv` fail with:

```
Could not find a version that satisfies the requirement lightning>=2.0.1
```

**Workaround**:
```bash
pip install pytorch-lightning>=2.0.1
pip install pyannote-audio==3.3.2 --no-deps
pip install asteroid-filterbanks>0.4 einops>0.6.0 omegaconf>2.1
```

**Implication**: don't try to pin pyannote 3.3.2/3.4.0. Either go pyannote 4.x (which WhisperX 3.8.x requires) or pin **pyannote 3.1 / 3.2**.

## Issue #1406 — pyannote 4.x partial migration in WhisperX 3.8.5

> "Released wheel still uses use_auth_token in whisperx/asr.py with pyannote 4.x"

`whisperx/vads/pyannote.py` was migrated to the new `token=...` kwarg, but `whisperx/asr.py` still calls `use_auth_token=use_auth_token`. With pyannote 4.x (which deprecated `use_auth_token`) you may need to patch the wheel or wait for a fix.

**Status as of May 2026**: open, monitor the repo.

## Other open: #1413 (batch inference), #1416 (Python API perf), #1404 (Python 3.14).
