---
title: "cashubtc/cdk — `MintPayment` trait (cdk-common)"
type: repo
source: https://github.com/cashubtc/cdk/blob/main/crates/cdk-common/src/payment.rs
fetched: 2026-05-28
confidence: high
tags: [cdk, mint-payment-trait, lightning-backend, abstraction]
summary: The canonical Rust trait every CDK lightning backend implements (cdk-cln, cdk-lnd, cdk-lnbits, cdk-fake-wallet, cdk-ldk-node, cdk-payment-processor). Defines the contract a mint-side LNURL bridge must wrap.
---

# `MintPayment` trait — cdk-common

`pub trait MintPayment` (line 420 in `crates/cdk-common/src/payment.rs`) is the abstraction every CDK backend implements. To add LNURL on top of CDK, an operator either:

1. Stands up a separate process that calls the mint's NUT-04 / NUT-05 HTTP endpoints — the dominant production pattern (`npubcash-server`, ZEUS zeuspay, LNbits Cashu extension), or
2. Wraps a real backend in a custom `MintPayment` impl that injects LNURL bookkeeping — heavier but enables in-process LNURL serving.

## Methods

- `start()` / `stop()` — lifecycle (added in v0.12 explicitly to support backends like LDK Node that need explicit start/stop)
- `get_settings() -> SettingsResponse` — advertises BOLT11/BOLT12/Onchain capabilities
- `create_incoming_payment_request(...)` — generates a BOLT11/BOLT12 invoice
- `get_payment_quote(...)` — quotes outgoing payment cost (fee estimate)
- `make_payment(...)` — pays a BOLT11
- `wait_payment_event() -> Stream<...>` — async stream of incoming-payment events (renamed from `wait_invoice` in commit `4eb3f316` 2026-04-15: trait method now `payment_event_stream`)
- `is_payment_event_stream_active()` / `cancel_payment_event_stream()`
- `check_incoming_payment_status(...)` / `check_outgoing_payment(...)` — defensive polling

## Associated types

- `pub type DynMintPayment = Arc<dyn MintPayment<Err = Error> + Send + Sync>;`
- Wrapper `MetricsMintPayment<T>` for Prometheus instrumentation (gated by `prometheus` feature).

## Why this matters for LNURL

A CDK mint exposing LNURL-pay would either:

- Run an LNURL-pay server in a sidecar process that calls `POST /v1/mint/quote/bolt11` on the mint, returns the resulting BOLT11 inside the LNURL `pr` field, and on success polls `GET /v1/mint/quote/bolt11/{quote_id}` for state — entirely outside `MintPayment`.
- Or wrap an LDK Node `MintPayment` with its own LNURL handler that intercepts incoming-payment events. Tighter coupling, harder to evolve.

Most production deployments choose the sidecar pattern. See [[2026-05-28-cashubtc-npubcash-server.md|npubcash-server]] for the canonical implementation.
