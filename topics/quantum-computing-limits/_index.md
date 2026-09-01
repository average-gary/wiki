# quantum-computing-limits

> Fundamental — not engineering — ceilings on quantum computation. Qubit information capacity, discretised Hilbert Space, gravitational collapse models, cosmological information bounds, and what they imply for Shor's algorithm against RSA and ECDSA.

Last updated: 2026-09-01

## Statistics

- Sources: 1 raw document (1 paper)
- Articles: 0 compiled wiki articles
- Outputs: 0 generated artifacts
- Last compiled: never
- Last lint: never

## Quick Navigation

- [All Sources](raw/_index.md)
- [All Articles](wiki/_index.md)
- [Concepts](wiki/concepts/_index.md)
- [Topics](wiki/topics/_index.md)
- [References](wiki/references/_index.md)
- [Outputs](output/_index.md)
- [Configuration](config.md)
- [Activity Log](log.md)

## Scope

See [config.md](config.md) for full scope. In brief: proposals that a quantum computer's usable
size is bounded by physics rather than engineering, and the experiments that would tell those
proposals apart from textbook quantum mechanics. The crypto consequence (Shor's against RSA and
secp256k1) is in scope as a downstream inheritance, not as a settled result.

## Read This First

This topic opens with a **minority position, not a consensus one.** The founding source argues
that quantum computers are subject to a hard qubit ceiling and will never factor RSA-2048. That
is a prediction of a proposed alternative to quantum mechanics, published as a falsifiable claim
— not an established limit. Standard resource estimates in the literature assume no such ceiling
and are not yet represented here. Read anything compiled in this wiki as "theory T predicts X",
and treat the absence of the opposing baseline as a gap to fill rather than as agreement.

## Source Highlights

- **[Rational Quantum Mechanics (Palmer, arXiv:2510.02877v3)](raw/papers/2026-09-01-rational-quantum-mechanics-raqm.md)**
  — the founding source. The argument in one line: if qubit bases are only defined where
  `cos²(θ/2) = m/L` and `φ/2π = n/L` are rationals, then N qubits carry `N × L` bits while QM
  demands `2^(N+1) − 2` degrees of freedom, so a finite `N_max ≈ log₂ L` follows from counting
  alone. The physics enters when L is pinned: setting the state-reduction timescale
  `τ* = (L−1)·t_P` equal to the Diósi-Penrose collapse time gives `L = ⌈E_P/E_G⌉`, from which
  QM is the singular limit at `E_G = 0`, i.e. `G = 0` — gravity is what makes state space
  discrete. Estimates: `N_max ≈ 200` (quantum dot), `≈ 300` (photonic), `≈ 400` (ion trap),
  with a never-exceed bound of `≈ 1,000`. The paper itemises its own assumptions in §7, and
  notes that Davies' independent cosmological-information argument lands on `N_Davies ≈ 400`.

## Open Questions

Not answered by the founding source; targets for the next round of ingestion:

- What are the standard (no-ceiling) resource estimates for factoring RSA-2048, and how do
  Gidney's ~1M noisy-qubit figures and current vendor roadmaps compare against the predicted
  saturation point? The opposing baseline is entirely absent from this wiki.
- Has RaQM drawn published criticism? A PNAS acceptance is a venue fact, not a verification —
  the multi-qubit generalisation (`QIC = N × L`) and the identification `t* = t_P` are the two
  steps most exposed to attack.
- Is the "maximal superposition across the full Hilbert space" criterion sharp enough to
  classify algorithms? The paper's BCS-superconductivity rebuttal works by asserting the system
  occupies a small subspace; whether that test cleanly separates Shor's from every already-run
  large-N quantum experiment is unresolved.
- What does the predicted signature actually look like in data — "increasingly strong discretised
  shot noise as N approaches N_max" — and could it be distinguished from ordinary gate error at
  the qubit counts reachable in the next five years?
- The bound is stated for **perfect** qubits, with the noisy-qubit prediction phrased as
  performance degrading as N approaches `N_2048`. How would an error-corrected machine's logical
  qubit count map onto `N_max`, and does error correction interact with the information budget?
- Does the same argument bear on Shor's against **ECDSA secp256k1** (256-bit, far fewer qubits
  than RSA-2048)? If `N_max ≈ 1,000` and breaking secp256k1 needs ~2,300+ logical qubits by
  standard estimates, the ceiling would bite there too — but the paper does not treat elliptic
  curves, and this connects to the Bitcoin work in the neighbouring hub topics.
- Palmer's companion papers (arXiv:2601.14941 on impossible counterfactuals and Bell's theorem;
  the 2020 Bloch-sphere discretisation paper; the 2009 Invariant Set Postulate) carry the
  foundational motivation the PNAS paper only gestures at. Worth ingesting if the discretisation
  argument needs to be assessed on its own terms.

## Recent Changes

- 2026-09-01: Topic wiki created and first source ingested — Palmer, *Rational Quantum Mechanics* (arXiv:2510.02877v3, PNAS-accepted), full 24-page PDF.
