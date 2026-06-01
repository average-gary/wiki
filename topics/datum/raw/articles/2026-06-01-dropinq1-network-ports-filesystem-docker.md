---
title: "Network ports, filesystem layout, Docker entrypoint — the deployment surface"
source: https://raw.githubusercontent.com/OCEAN-xyz/datum_gateway/master/Dockerfile
type: articles
tags: [datum-gateway, drop-in-replacement, ports, docker, filesystem, deployment, operator-surface]
summary: "Default ports: stratum 23334/tcp, API/dashboard 7152/tcp, OCEAN upstream destination 28915/tcp (datum-beta1.mine.ocean.xyz). Filesystem state is essentially empty: no PID file, no lock file, no key store, no share log on disk; only the optional log file and optional save_submitblocks_dir. Docker image: debian:bookworm-slim, two-stage, runs as 'datumuser' (non-root), entrypoint hardcodes /app/datum_gateway --config /app/config/config.json, VOLUME /app/config, EXPOSE 23334+7152, healthcheck on 23334."
confidence: high
ingested: 2026-06-01
ingested_by: dropinq1
---

# Network ports, filesystem layout, Docker entrypoint

## Network ports

| Port | Direction | Purpose | Configurable via |
|---|---|---|---|
| **23334/tcp** | listen | SV1 stratum from miners | `stratum.listen_port` |
| **7152/tcp** | listen | HTTP dashboard / API | `api.listen_port` (0=disabled) |
| **28915/tcp** | outbound | OCEAN upstream (DATUM protocol) | `datum.pool_port` (default `datum-beta1.mine.ocean.xyz:28915`) |
| 8332/tcp | outbound | bitcoind RPC (typical mainnet) | `bitcoind.rpcurl` |

Note: `7152` is documented in the example config and in OCEAN's Docker docs. It is the default for the operator dashboard, NOT a privileged port. It's the port Knots `blocknotify` hits when using the network-mode HTTP fallback.

`23334` is the OCEAN-canonical stratum port; miners' `stratum+tcp://gateway:23334` URLs are baked into miner config files in the field. Changing it on the drop-in side is a breaking change to every deployed miner.

## Filesystem layout

The C gateway writes essentially nothing to disk. Surveyed across `datum_gateway.c`, `datum_protocol.c`, `datum_logger.c`, and (by inspection of headers/calls) the rest of the source tree:

| Artifact | Path | Format | Note |
|---|---|---|---|
| Config (read-only by default) | working dir / `datum_gateway_config.json` | JSON | unless `--config FILE` |
| Log file (optional) | `logger.log_file` (default `""` = disabled) | plaintext | rotated daily, suffix `.YYYY-MM-DD` |
| Submitblock save (optional) | `mining.save_submitblocks_dir` (default `""` = disabled) | one file per discovered block | belt-and-suspenders for block recovery |
| **PID file** | none | — | not implemented |
| **Lock file** | none | — | not implemented |
| **Keypair file** | none | — | keys generated fresh each startup (see `dropinq1-ocean-keypair-tides-attribution.md`) |
| **Share log** | none | — | shares are in-flight only |
| **State db** | none | — | no persistent state |

This is great news for the drop-in: there is no on-disk state to migrate or preserve at switch-over. The only operator-touched files are the config (JSON, schema documented in `path2-datum-config-surface.md`) and the optional log file.

## Docker image

From the upstream `Dockerfile`:

```Dockerfile
FROM debian:bookworm-slim AS runtime
USER datumuser           # useradd -r -s /bin/false datumuser
WORKDIR /app
EXPOSE 23334/tcp 7152/tcp
VOLUME ["/app/config"]
ENTRYPOINT ["/app/datum_gateway", "--config", "/app/config/config.json"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD nc -zv localhost 23334 || exit 1
```

Two-stage build: builder stage compiles from source against `libcurl`, `libjansson`, `libsodium`, `libmicrohttpd`; runtime stage copies the binary into a slim Debian image. No ENV vars set. No CMD (entrypoint is a fully-formed argv).

The `VOLUME` is `/app/config` — operators bind-mount their config dir there and the entrypoint reads `/app/config/config.json`. The example deployment in OCEAN's setup guide uses:

```sh
docker run -p 23334:23334 -p 7152:7152 \
  -v /path/to/your/config/directory:/app/config \
  --name datum-gateway \
  datum_gateway
```

## Drop-in implications

**Must preserve bit-exact**:
- Default port `23334` for stratum. Miners are deployed with this in their config.
- Default port `7152` for dashboard/API. `bitcoin.conf` blocknotify lines reference it.
- Default upstream `datum-beta1.mine.ocean.xyz:28915`. Miners' default config relies on this.
- Docker entrypoint argv shape `/app/datum_gateway --config /app/config/config.json`. Operators with `docker-compose.yml` referring to `image: datum_gateway` and a bind mount on `/app/config` expect this.
- VOLUME `/app/config`, image WORKDIR `/app`, EXPOSE `23334 7152`.

**Easy to preserve**:
- `debian:bookworm-slim` base — could move to `distroless` or Alpine for smaller footprint, but at the cost of `nc` for healthcheck (would need to swap healthcheck implementation).
- Non-root `datumuser` (good default; keep).
- Healthcheck `nc -zv localhost 23334` (works the same way for any TCP listener).

**Negotiable / improvable**:
- `nc` healthcheck is binary-presence + TCP-accept; a real healthcheck could verify SV2 handshake completes. Document any change in CHANGELOG.
- Add a second binary `datum_gateway-sv2-bridge` or similar variant tag if the drop-in supports both protocols. Keep the original tag `:latest` semantically equivalent for back-compat.

**Open question** for the drop-in:
- The Docker image tag/registry. OCEAN-xyz publishes to GHCR / Docker Hub? The drop-in should ship its own image; whether to publish under a name that auto-resolves for existing `docker pull datum_gateway` users is a coordination question with OCEAN, not a technical one.

## Justification

Closes the deployment-surface gap in the drop-in survey. Network ports are the most rigid surface (every miner has them hardcoded); filesystem layout is the most forgiving (almost nothing is on disk). The Docker entrypoint is the operator's primary integration seam — preserving it lets ops swap images with one tag change.
