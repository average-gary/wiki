---
title: Inventory Index
type: index
updated: 2026-08-14
---

# Inventory Index

> Durable tracking records for items, candidates, entities, corpora, and watch items.

Last updated: 2026-08-14

## Statistics

- Total records: 5
- Items: 0
- Candidates: 5
- Entities: 0
- Corpora: 0
- Active: 4
- Ingested (question answered): 1
- Blocked: 0

## Quick Navigation

- [Candidates](candidates/_index.md)

## Contents

| File | Kind | Status | Priority | Next Action | Updated |
|------|------|--------|----------|-------------|---------|
| [candidates/coinbase-native-stealth-payout.md](candidates/coinbase-native-stealth-payout.md) | question | open | p2 | Write the spec diff against BIP 352's Sender/Receiver sections (close-out condition 1) — the executable check now exists and passes (`~/repos/sp-coinbase-vectors/`, 11 cases). Settle in the diff: fresh hash tags vs. BIP0352 tag reuse; version byte from `bip-0352.mediawiki:152-176`. | 2026-08-14 |
| [candidates/batched-credit-timing-leak.md](candidates/batched-credit-timing-leak.md) | question | active | p1 | Quantify hashrate recoverability from batched credit timing — simulate fixed vs Poisson-randomized boundaries at `b ∈ {10, 72, 1271}` against R&C's 0.53–34.4 % ISP-Log baseline. | 2026-07-29 |
| [candidates/doj-1960-noncustodial-enforcement-theory.md](candidates/doj-1960-noncustodial-enforcement-theory.md) | question | active | p1 | Retrieve the Samourai §1960 theory from CourtListener/RECAP (justice.gov 403/404) and reconcile against FinCEN §5.4. | 2026-07-29 |
| [candidates/canard-gouget-primary-text.md](candidates/canard-gouget-primary-text.md) | ingest-candidate | active | p3 | Obtain Canard & Gouget, *"Anonymity in Transferable E-Cash,"* ACNS 2008 pp.207–223 via institutional access; confirm the theorem number and which anonymity level it rules out. Direction is settled by four restatements. | 2026-07-29 |
| [candidates/blinded-mining-cookie-security.md](candidates/blinded-mining-cookie-security.md) | question | **ingested** *(answered — see `resolved: 2026-07-29`)* | p1 | None — closed by the 2026-07-29 thesis round on its third close-out condition, in narrowed form. Two follow-ups spun out above. | 2026-07-29 |

## Notes

**Round two, 2026-07-29 (thesis round).** `blinded-mining-cookie-security` is **closed** — `status:
ingested`, the schema's terminal value for a record whose work is done, with a `resolved: 2026-07-29`
date recording when. It closed on
"aggregation provably requires a persistent identifier," but *not* as "secure but unusable," because
the miner-carried-accumulator horn turned out to be open and affordable. Its second close-out
condition was struck as unsatisfiable (Bedrock names no hardness assumption). Two records spun out of
it, and the split is deliberate: **`batched-credit-timing-leak` inherits the p1**, because it is where
the round relocated the actual difficulty, while **`canard-gouget-primary-text` is p3** — provenance
hygiene on a claim whose direction is already settled by four independent restatements. A single
misread of that paper's scope had propagated into eight files and inverted a design prescription, which
is why it is tracked at all rather than simply corrected and forgotten.

The two original records originate in the 2026-07-29 attribution-privacy round and corresponded to the
two highest-impact of its six remaining gaps. The other four are recorded in
[[../output/playbook-self-blinding-pool-attribution-2026-07-29|the playbook]] § Remaining gaps and
were judged not durable enough for their own records: connection-level Sybil re-correlation
(unquantified in any paper, but a sub-question of the blinded-cookie record), subset-sum against
real coinbase payout sets, the EU TFR/MiCA retrieval (folded into the §1960 record — same
retrieval problem, same article section), and the 404'd PPLNS-JD primary paper.
