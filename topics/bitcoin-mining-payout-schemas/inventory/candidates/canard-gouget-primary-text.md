---
title: "Canard–Gouget ACNS 2008 — obtain the primary text and confirm the theorem's exact scope"
kind: ingest-candidate
status: active
priority: p3
created: 2026-07-29
updated: 2026-07-29
last_checked: 2026-07-29
next_action: "Obtain 'Anonymity in Transferable E-Cash', Canard & Gouget, ACNS 2008 pp.207–223 (Springer LNCS 5037) via institutional access or ILL. Confirm the exact theorem statement and which anonymity level it rules out. Direction is settled by four restatements; this closes numbering only."
sources:
  - raw/papers/2026-07-29-stateful-vs-oneshot-credentials-no-separation.md
  - wiki/concepts/blind-share-accounting.md
tags: [canard-gouget, transferable-ecash, paywalled, provenance, correction, low-priority]
confidence: high
summary: "A single misread of this paper's scope propagated into eight files in this topic and inverted a design prescription. The correction rests on four independent restatements rather than the primary text, which is paywalled. Worth closing for provenance hygiene, not because the answer is in doubt."
---

# Canard–Gouget primary text

## Why Track This

**Provenance hygiene on a claim that already caused real damage.** A secondhand characterization of
this paper became this topic's #1 blocker against blinded share accounting, was stated with the sign
**backwards**, and propagated into eight files before the 2026-07-29 thesis round caught it. The
correction is solid, but it rests on restatements rather than the source.

Priority is **p3, not p1**: the direction is not in doubt. Four independent restatements agree, and one
of them is decisive on its own.

## Current State

**Paywalled and unread.** Springer/DOI, `oa_status: closed`, no preprint, no OpenAlex abstract, no OA
copy found. Full reference: S. Canard and A. Gouget, *"Anonymity in Transferable E-Cash,"* ACNS 2008,
LNCS 5037, pp. 207–223.

**What is established without it**, from sources read directly:

- **Faller et al., IMACC 2021** (eprint 2021/1303) cite it as the reason *"A BBA issuer and an
  accumulator **can** collude without breaking privacy. This is necessary due to an impossibility
  result, cf. [12]"* — i.e. as a constraint **satisfied by** the single-key model, not a barrier to it.
  This is the decisive quote.
- **Black-Box Wallets p.3** invokes it while **rejecting transferable e-cash** as an alternative
  design.
- **P4TC** (PoPETs 2020(4)) describes it as *"an impossibility result [21] negating "perfect
  anonymity""* — scare quotes theirs.
- **A USP MSc thesis** (da Silva 2016, OA) restates the hierarchy: *"**Perfect Anonymity (PA)**… it is
  proved that PA cannot be achieved if the bank is itself a possible adversary"*, with
  `PA ⇒ FA ⇒ SA ⇒ WA`.
- **Gouget's own 2008 invited-talk abstract** attributes coin-growth to **Chaum–Pedersen**, not to
  herself — consistent with her ACNS paper being about anonymity levels rather than size bounds.

So: the impossible notion is **Perfect Anonymity**, one level *above* the "full unlinkability" this
wiki had invoked, and its predicate is **recognizing a coin you previously owned once it returns to
you** — transfer between *users*. A pool that increments weight itself never satisfies the antecedent.

## Close-out Condition

Obtain the PDF and confirm the theorem number and exact statement. Should change **numbering and
precision, not direction**. If it somehow contradicts all four restatements, that is a much bigger
finding and reopens
[[../../wiki/theses/blinded-share-credit-commitment|the thesis]]'s sub-claim B.

## Notes

- **Cite it as "the BBA literature's characterization of Canard–Gouget"** until this closes — never as
  a standalone result. That convention is now applied across the topic.
- **The result people usually mean** when they say "e-cash can't do this" is often **Chaum–Pedersen,
  EUROCRYPT '92, *"Transferred Cash Grows in Size"***, which has genuine theorems (4.2, 5.1) with
  entropy lower bounds and is freely available from Springer. It also scopes to *transferability*. BBA
  tokens stay constant-size precisely because the operator co-signs each increment.
- **Also unread and worth a look if access appears**: LatInc (TDSC 2026), the newest BBA-line work.
- **Process lesson worth more than the citation**: WebFetch silently fails on image-based PDFs and
  returns confident "ABSENT" verdicts. Download and `pdftotext -layout`.
