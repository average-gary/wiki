---
title: "quantum-computing-limits"
description: "Fundamental — not engineering — ceilings on quantum computation. Qubit information capacity, discretised Hilbert Space, gravitational collapse models, cosmological information bounds, and what they imply for Shor's algorithm against RSA and ECDSA."
created: 2026-09-01
freshness_threshold: 70
---

# Wiki Configuration

## Scope

Proposals that a quantum computer's usable size is bounded by physics rather than by
engineering, and the tests that would distinguish them from textbook quantum mechanics.
Covers:

- **Discretised state space.** Theories in which complex Hilbert Space is an idealisation of
  something inherently discrete — Palmer's Rational Quantum Mechanics (RaQM), Buniy/Hsu/Zee,
  Carroll's finite QM, 't Hooft's cellular-automaton interpretation. The rationality/number-theoretic
  constraints, the discretisation parameter, and the singular-limit argument (why the continuum
  limit need not be smooth).
- **Qubit information capacity ceilings.** Constructions that pit an information budget growing
  linearly in N against a Hilbert-space dimension growing as 2^(N+1) − 2, and the resulting
  N_max. Numerical estimates per qubit technology (quantum dot, photonic, ion trap) and claimed
  hard upper bounds.
- **Gravity as the source of the bound.** Diósi-Penrose gravitational self-energy and collapse
  timescales, Penrose's gravitisation of QM, and the distinction between models that modify the
  Schrödinger equation (and so predict energy dissipation) and models that do not.
- **Cosmological information bounds.** Lloyd's computational capacity of the universe, Davies'
  argument that entangling more than log2(I_universe) qubits demands a Hilbert space larger than
  the universe's information content, and whether such holistic arguments and state-space
  discretisation converge on the same number by coincidence.
- **The falsification path.** Which algorithms actually require maximal superposition across the
  full Hilbert space (Quantum Fourier Transform, Shor's) versus those confined to a
  low-dimensional subspace (BCS superconductivity, synchronised-oscillator analogues), why the
  latter do not refute the bound, error-corrected/noisy-qubit counts for RSA-2048, and the
  predicted signature (discretised shot noise as N approaches N_max).
- **Consequences for cryptography.** Shor's against RSA and against ECDSA secp256k1, resource
  estimates in the literature (Gidney), and how a hard qubit ceiling would bear on
  post-quantum migration urgency — including for Bitcoin.
- **The competing baseline.** Standard resource estimates and roadmaps that assume no
  fundamental ceiling, so the two predictions can be held side by side rather than only the
  contrarian one being catalogued.

Out of scope for this topic:

- General quantum-computing tutorials, gate-model pedagogy, and vendor hardware news that make
  no claim about fundamental limits.
- Practical decoherence, error-correction code design, and threshold theorems as engineering
  subjects — cited here only where they bear on distinguishing a fundamental ceiling from a
  technical one.
- Quantum-foundations interpretation debates (Bell, superdeterminism, local realism) as ends in
  themselves. RaQM's Bell/counterfactual reframing is in scope only insofar as it motivates the
  discretisation; the companion papers are adjacent, not core.
- Post-quantum cryptography scheme selection (lattice/hash/code-based signature design). The
  migration *question* is in scope; the scheme catalogue is not.

## Conventions

- **Name the theory, never assert it.** Everything here is a live minority proposal. Write
  "Palmer predicts" / "RaQM implies", not "quantum computers cannot factor RSA-2048". Reserve
  `confidence: high` for what a source *states*, not for whether it is true.
- **Separate the three layers of any ceiling claim.** (1) the mathematical construction, (2) the
  physical identification that sets its scale, (3) the numerical estimate that falls out. These
  fail independently — a construction can be sound while the scale-setting identification is
  arbitrary. Compiled articles should say which layer a criticism lands on.
- **Carry the assumption list.** Papers in this area typically enumerate their own assumptions
  (RaQM's are itemised in its conclusions). Preserve that list verbatim in compiled articles;
  it is the honest measure of how load-bearing each step is.
- **Distinguish perfect from noisy qubit counts.** A ceiling stated in perfect/logical qubits
  says something different from one stated in physical noisy qubits. Never quote an N_max
  without saying which.
- **Peer-review status is metadata, not evidence.** Note where a paper stands (preprint, accepted,
  published, and in which venue) because it bears on how much weight to give it — but a PNAS
  acceptance is not a confirmation of the physics.
- **Keep the crypto consequence downstream.** Claims about RSA or Bitcoin follow from the
  physics claims and inherit all their uncertainty. Do not let a security conclusion appear
  more settled than the theory that produced it.
