---
title: "Rational Quantum Mechanics: Testing Quantum Theory with Quantum Computers"
source: "https://arxiv.org/abs/2510.02877"
type: papers
ingested: 2026-09-01
tags: [rational-quantum-mechanics, discretised-hilbert-space, qubit-information-capacity, shors-algorithm, rsa-2048-factoring, diosi-penrose-collapse, quantum-gravity, nivens-theorem, p-adic-numbers, invariant-set-postulate, quantum-computing-ceiling]
summary: "Tim Palmer (Oxford) proposes Rational Quantum Mechanics (RaQM), a discretisation of complex Hilbert Space in which qubit bases are only defined where squared amplitudes and phases are rationals m/L. Since N qubits then carry N x L bits while QM demands 2^(N+1) - 2 degrees of freedom, a finite qubit information capacity N_max ~ log2(L) follows; identifying the discretisation scale with Diosi-Penrose gravitational collapse gives L = ceil(E_P/E_G) and N_max ~ 200-400 for today's qubit technologies, never above ~1,000. The paper's testable consequence: algorithms needing maximal superposition (Shor's, via the Quantum Fourier Transform) saturate in advantage at ~1,000 perfect qubits, so a quantum computer will never factor a 2048-bit RSA integer."
authors: [Tim Palmer]
canonical_url: "https://arxiv.org/abs/2510.02877v3"
arxiv_id: "2510.02877v3"
categories: [quant-ph]
publication_status: "Accepted to appear in Proceedings of the National Academy of Sciences (PNAS)"
version_history: "v1 2025-09-19; v3 revised 2026-02-15 (paper dated 2026-02-17)"
content_format: pdf
sha256: "f5964092420e7e8d3af1159903f3bb469c32dbc3eb31c189611156ee06af5882"
page_count: 24
extraction_tool: "pdftotext (poppler), no -layout; source PDF https://arxiv.org/pdf/2510.02877v3"
fetched: 2026-09-01
---

# Rational Quantum Mechanics: Testing Quantum Theory with Quantum Computers

**Tim Palmer** — Department of Physics, University of Oxford, UK — tim.palmer@physics.ox.ac.uk

arXiv:2510.02877v3 [quant-ph], 15 Feb 2026 (paper dated February 17, 2026).
Accepted to appear in *Proceedings of the National Academy of Sciences*.
Funded by Leverhulme Trust Grant EM-2023-060.

> **Extraction note.** Text below is the full 24-page PDF extracted with `pdftotext`
> (poppler, without `-layout`). Prose is faithful; **display equations, the nested
> multi-qubit state expressions (4), (8), (9), and the figure panels are mangled by
> linearisation** — consult the PDF for any equation you intend to rely on. Page
> boundaries from the extractor's form feeds are marked `## Page N`. Mathematical
> symbols appear as Unicode math italics (e.g. `𝑁max`, `𝐿`, `𝜃`, `𝜙`, `𝜉`) as emitted
> by the extractor.

---

## Page 1

arXiv:2510.02877v3 [quant-ph] 15 Feb 2026

Rational Quantum Mechanics: Testing Quantum Theory with
Quantum Computers
Tim Palmer
Department of Physics, University of Oxford, UK
tim.palmer@physics.ox.ac.uk
February 17, 2026
Abstract
Motivated in part by John Wheeler’s assertion that the continuum nature of Hilbert Space
conceals the ‘it-from-bit’ information-theoretic character of the quantum wavefunction, a theory
of quantum physics (Rational Quantum Mechanics - RaQM) is proposed based on a specific
discretisation of complex Hilbert Space. The Schrödinger equation is not modified in RaQM,
even during measurement. However, the bases in which the quantum state is defined must
satisfy certain rational-number constraints. These constraints lead to the notion of finite qubit
information capacity 𝑁max : for any 𝑁 > 𝑁max qubit state, there is insufficient information in
the 𝑁 qubits (linearly growing in 𝑁) to allocate even one bit to each of all 2 𝑁 +1 − 2 continuum
degrees of freedom (exponentially growing in 𝑁) associated with quantum mechanics/theory
(QM, where 𝑁max = ∞). It is proposed that the discretisation of Hilbert Space in RaQM is
due to gravity, hence QM is the (singular) continuum limit of RaQM at 𝐺 = 0. On this basis,
it is estimated that 𝑁max lies between about 200 and 400 for current qubit technologies, and
will never exceed 1,000. Whilst QM and RaQM are experimentally indistinguishable for small
numbers of qubits, RaQM predicts that the exponential advantage of quantum algorithms
which, like Shor’s, require bases with maximal 𝑁-qubit superposition/entanglement, will have
saturated at 1,000 perfect qubits. Hence, insofar as a classical computer will never factor a
2048-bit RSA integer, RaQM predicts that a quantum computer won’t either. This predicted
breakdown of QM could be testable in less than 5 years.

Significance Statement
Is there a fundamental reason why quantum computers cannot factor large integers used for
encryption today? We introduce a theory of quantum physics based on the notion that the continuum nature of quantum mechanics’ state space approximates something inherently discrete,
and argue that the reason for such discreteness is gravity. From this we predict that quantum computers will never break realistic RSA-encrypted messages, for fundamental rather than
practical reasons. This predicted breakdown of quantum theory may be falsifiable in a few years.
If verified, quantum computers’ biggest impact may be in the development of new finite theories
which synthesise quantum and gravitational physics, potentially with commercial benefits (albeit
for future generations) eclipsing those derived from quantum mechanics alone.

1


## Page 2

1

Introduction

It has been reported [9] that 2048-bit RSA integers could be factored in under a week by a
quantum computer with less than a million noisy qubits. But could a quantum computer with
such capability ever be built? Unitary quantum mechanics/theory (QM) does not itself limit
the number of qubits that can be coherently entangled in quantum computers. In addition,
environmental decoherence can be minimised by ensuring a quantum computer’s qubits are
sufficiently isolated from their environmental, e.g., by positioning them, as has been suggested,
in a deep crater on the dark side of the Moon.
However, perhaps there are other constraints on what a quantum computer can in principle
achieve. For example, gravitationally induced state collapse would certainly limit multi-qubit
coherence [5] [8] [25]. However, for a million entangled quantum-computing qubits, collapse
timescales are longer than the age of the universe and therefore irrelevant as a constraint
on near-future quantum computing capability. Another source of error might be the indirect
dissipative effects of state collapse [34]. However, no dissipative effects have been observed [6].
Hence, it would appear that limitations on quantum computing performance are technical
and not fundamental. However, here we propose a novel type of fundamental constraint that is
not directly related to state collapse and involves no dissipative effects: the notion that a qubit
has a finite information capacity. To be clear about what is being proposed here, consider a
quantum mechanical qubit state
𝜃
𝜃
|𝜓(𝜃, 𝜙)⟩ = cos |1⟩ + 𝑒 𝑖 𝜙 sin | − 1⟩
2
2

(1)

in the eigenvector basis (|1⟩, | − 1⟩) of some hermitian operator, with 2 continuum degrees
of freedom represented by 𝜃, 𝜙 ∈ R. Certainly in QM, cos 𝜃 and 𝜙/2𝜋 could be irrational
numbers. Indeed, they might be non-computable numbers whose full description would require
the specification of unbounded amounts of information. QM does not itself limit the numbertheoretic complexity associated with these two degrees of freedom.
Does this matter? In classical physics, we routinely discretise differential equations to solve
them numerically on a digital computer. However, unless these equations are pathological,
theorems exist [30] which assert that for fine-enough discretisation, the numerical solution will
be as close as we like to the continuum solution. In this sense, the differential equations define
a smooth limit for the discretised models as the discretisation scale goes to zero. However,
we cannot assume the continuum limit is smooth if we discretise QM. In particular, one of
Lucien Hardy’s axioms for QM [12] - the single most important in his estimation - asserts the
continuity of QM’s state space: complex Hilbert Space. This raises the possibility that QM
is a singular limit [1] of some fundamentally new theory of quantum physics in which Hilbert
Space is discretised [2] [15] [3], as the discretisation scale goes to zero. Although such a theory
may have similar observational and experimental consequences to QM, Hardy’s axiom suggests
it will have an extremely different conceptual underpinning to QM (e.g, as general relativity is
to Newtonian gravity). The question we consider here is whether such a theory has testable
consequences, different from QM. By way of example, consider a model of fluid turbulence
based on the viscous Navier-Stokes equations at very large but finite Reynolds number 𝑅𝑒,
and a model based on the inviscid Euler equations. The two theories generate similar types
of turbulent motion. However, in going from Navier-Stokes to Euler, the boundary condition
at an aerofoil fundamentally changes, from no slip to no normal motion. This has testable
consequences: aircraft cannot fly in an inviscid fluid!
With this in mind, we will suppose that the continuum nature of complex Hilbert Space is
merely an idealisation for - and hence an approximation to - a deeper, inherently discrete theory
of quantum physics. Such a possibility was advocated by the eminent physicist John Wheeler,
who famously coined the aphorism ‘It from Bit’ (i.e., reality from information), writing [35]:

2


## Page 3

The familiar probability function or functional, and wave equation or functional
wave equation, of standard quantum theory provide mere continuum idealizations
and by reason of this circumstance conceal the information-theoretic source from
which they derive.
As such, we present a theory of quantum physics ‘Rational Quantum Mechanics - RaQM’ based
on a discretisation of Hilbert Space, itself based on a discretisation of the Riemann Sphere of
(extended) complex numbers. Specifically, in RaQM, permitted qubit bases, i.e., bases where
|𝜓⟩ in (1) is mathematically defined, must be associated with rational values of cos 𝜃 and
𝜙/2𝜋 (more precise restrictions are defined below). Of course, we cannot assume that Wheeler
would have agreed with this particular choice of discretisation, however, as discussed below,
it does indeed reveal the information-theoretic nature of the qubit state, concealed by QM.
As part of this revelation, we define a finite quantity 𝑁max referred to as Qubit Information
Capacity (QIC): when 𝑁 > 𝑁max , there is insufficient bitwise information contained in an
𝑁-qubit system to allocate even one bit of information to each of the 2 𝑁 +1 − 2 Hilbert-space
dimensions demanded by QM. In QM itself, 𝑁max = ∞, hence QM’s unbounded QIC poses no
fundamental constraint on experimental quantum physics.
A sufficiently large but finite 𝑁max implies that RaQM is experimentally indistinguishable
from QM for systems comprising a small number of qubits. However, due to the exponential
growth of Hilbert Space with 𝑁, any finite 𝑁max could constrain the behaviour of a quantum
system with sufficiently many entangled qubits, providing the entanglement is fully spread
across the available state space. The purpose of this paper is to propose an experimental test
(which might be achievable in as few as 5 years) of the existence of such a constraint.
But why take RaQM seriously, finiteness issues notwithstanding? As discussed in a companion paper [20], RaQM provides a wholly novel way of framing and hence understanding the
so-called ‘weird’ properties of quantum physics, such as complementarity, non-commutativity
of observables and violation of Bell’s inequality. This reframing illustrates the singular nature
of QM as a limiting case of RaQM. By abandoning continuity even slightly, one can arrive at
a theory of quantum physics with radically different mathematical and conceptual properties
to QM itself. Not least, by violating the Measurement Independent assumption in Bell’s Theorem [13], not for nominal measurement settings under the full control of the experimenter,
but for exact measurement settings which were never under their control anyway (consider a
gravitational wave passing through an interferometer at the time of measurement), RaQM can
be shown to describe a locally realistic theory of quantum physics.
Information-theoretic considerations notwithstanding, it is proposed that the key physical
reason for eschewing the state-space continuum (and hence the infinitesimal [31] [7] [10]) is
gravity. It is generally accepted that gravitational effects may to a breakdown of the continuum
structure of space-time; a fortiori we propose such effects lead to a breakdown of the continuum
structure of state space. As such, we claim that gravity should play a fundamental role in the
very structure of theories of quantum physics, and hence is not some additional field ‘to be
quantised’. Consistent with this, we use existing models of gravitised QM [27] to provide
quantitative estimates of the discretisation scale and hence QIC, for different types of qubit.
The specific framework for discretising Hilbert Space is outlined in Section 2. Based on
a constructive discretisation of the Riemann Sphere of extended complex numbers described
in the Supporting Information, an explicitly information-theoretic representation of the 𝑁qubit state in discretised Hilbert Space is presented in Section 3. As discussed in Section 4,
state reduction/measurement in discretised Hilbert Space is represented geometrically by a
state-space magnification of a Cantor Set, and arithmetically by a chaotic shift map on 2-adic
representations of the Cantor Set. By equating the information-theoretic reduction time with
the Diósi-Penrose collapse time [5] [25], we arrive in Section 5 at a simple formula for QIC.
𝑁max for different types of qubit in existence today are estimated and an upper bound of

3


## Page 4

𝑁max ≈ 1, 000 that will never be exceeded is found. The proposed test of RaQM and hence of
the breakdown of QM itself is described in Section 6. Concluding remarks are made in Section
7, where we collect together the assumptions made in developing RaQM.

2

Discretised Hilbert Space

RaQM invokes a restriction to the Dirac-von Neumann axioms of QM. In particular, a qubit
state (1) in RaQM, evolved using the Schrödinger equation without modification, is only mathematically defined in bases {|1⟩, | − 1⟩} where
cos2

𝜃
𝑚
=
∈ Q;
2
𝐿

𝜙
𝑛
= ∈ Q.
2𝜋
𝐿

(2)

𝐿 ∈ N is the single most important variable in this paper (a function of the mass/energy of the
qubit as defined in Sections 4 and 5), defining the degree of granularity of discretised Hilbert
Space; 0 ≤ 𝑚, 𝑛 ≤ 𝐿 are whole numbers. Qubits in quantum computers will be found (Section
5) to have 𝐿 ≫ 1. By contrast, the classical limit corresponds to ‘maximal discretisation’
at 𝐿 = 1. QM (where |𝜓⟩ is mathematically defined in the bases of all hermitian operators)
corresponds to the singular limit of RaQM at 𝐿 = ∞. As mentioned in the Introduction, a
model with finite 𝐿 leads to a complete reimagining of the conceptual foundations of quantum
physics. For example, as discussed below, Born’s Rule is emergent in RaQM and hence not
needed as a separate axiom.
By construction, |𝜓⟩ is undefined in a basis where the rationality constraint (2) is not satisfied - for example, where cos 𝜃 = 2 cos2 (𝜃/2) − 1 and/or 𝜙/2𝜋 are irrational numbers. Such
hypothetical bases are found to be associated ubiquitously with counterfactual measurements
which arise when analysing non-classical properties of quantum systems such as complementarity, non-commutativity of observables, and entanglement (e.g., when considering the outcome
of a simultaneous counterfactual which-way experiment, when in reality one has performed an
interferometric experiment on some specific photon) [20].
Equation (2) is straightforwardly generalised for multi-qubit states. In QM, a general 𝑁qubit state can be written
𝛼1 |1, . . . , 1, 1⟩ + 𝛼2 |1, . . . , 1, −1⟩ + 𝛼3 |1, . . . , −1, 1⟩ + . . . + 𝛼2 𝑁 |−1, . . . , −1, −1⟩.

(3)

where 𝛼𝑖 ∈ C. (3) can be written in an explicitly normalised form; e.g. for 𝑁 = 3, as
𝜃4
𝜃4
𝜃2
cos |1⟩ × (cos |1⟩ + 𝑒 𝑖 𝜙4 sin | − 1⟩ )+
©
ª
2
2
2
­
®
| {z }
|
{z
}
­
®
𝜃1
­
®
2
3
cos |1⟩ × ­
®+
𝜃
𝜃
𝜃
2
5
5
­ + 𝑒 𝑖 𝜙2 sin | − 1⟩ ×(cos |1⟩ + 𝑒 𝑖 𝜙5 sin | − 1⟩ ) ®
2
®
| {z } ­
2
2
2
­ |
{z
} |
{z
} ®
1
«
¬
2
3
𝜃3
𝜃6
𝜃6
𝑖 𝜙6
cos |1⟩ × (cos |1⟩ + 𝑒 sin | − 1⟩ )+
©
ª
2
2
2
­
®
| {z }
|
{z
}
­
®
𝜃1
­
®
𝑖 𝜙1
2
3
+ 𝑒 sin | − 1⟩ × ­
®
𝜃
𝜃
𝜃
3
7
7
­ + 𝑒 𝑖 𝜙3 sin | − 1⟩ ×(cos |1⟩ + 𝑒 𝑖 𝜙7 sin | − 1⟩ ) ®
2
®
|
{z
} ­
2
2
2
­ |
{z
} |
{z
} ®
1
«
¬
2
3

4

(4)


## Page 5

Figure 1: A schematic representation of (4) corresponding to (3), explicitly normalised, for 𝑁 =
3. The self-similar generalisation of this representation to arbitrary 𝑁 is straightforward, giving
2 + 4 + 8 + . . . 2 𝑁 = 2 𝑁 +1 − 2 degrees of freedom in total. Here the discretisation ansatz (2) is applied
to each pair (𝜃 𝑖 , 𝜙𝑖 ).
where
𝛼1 = cos(𝜃 1 /2) cos(𝜃 2 /2) cos(𝜃 4 /2)
𝛼2 = cos(𝜃 1 /2) cos(𝜃 2 /2) sin(𝜃 4 /2)𝑒 𝑖 𝜙4
...
𝛼7 = sin(𝜃 1 /2) sin(𝜃 3 /2) sin(𝜃 7 /2)𝑒 𝑖 ( 𝜙1 +𝜙3 +𝜙7 )

(5)

The form (4) is represented schematically in Fig 1, where the 3 underbraced nested qubits
in (4) exhibit 2, 4 and 8 degrees of freedom respectively, totalling 14. Continuing to larger
values of 𝑁, each new qubit adds 2 𝑁 extra degrees of freedom to the quantum state, yielding
2 + 4 + 8 + . . . + 2 𝑁 = 2 𝑁 +1 − 2 in total (= 2 𝑁 complex degrees of freedom, less 2 for normalisation
and global phase as in (3)). In RaQM, we generalise (2) so that it applies to each of the
cos2 𝜃 𝑖 /2 and each of the 𝜙𝑖 /2𝜋.
As suggested by Fig 1, the form (4) is similar to that for a photon (say) passing through
a set of nested beamsplitters. The notion of using multiple beam splitters as a way of testing
the author’s model of discretised Hilbert Space is described in [11]. The estimates below, e.g.,
of 𝑁max ≈ 1, 000 seem so large that building a one-off laboratory apparatus seems impractical.
On the other hand, piggy-backing on the quantum-tech revolution, building such an apparatus
may not be inconceivable in the future. In any case, we argue below that quantum computers
(no matter what qubit technology is used) provide a testbed for discretised Hilbert Space,
potentially in a few years.
Before continuing, we consider a question whose answer may seem esoteric, but will be
central, not only to the mathematical viability of RaQM, but also to the way in which the
notion of measurement is described in RaQM. Since rational and irrational numbers can be
infinitesimally close, isn’t RaQM (where states in bases with irrational squared amplitudes
and/or phases are undefined) necessarily extremely fine tuned, and hence not robust to small
perturbations? To see that this is not the case, first note that irrational real numbers are limit
points of Cauchy sequences of rational numbers with specific respect to the Euclidean metric.

5


## Page 6

However, it is well known that Cauchy sequences of rationals can also be defined using the socalled 𝑝-adic metric [17], with respect to which the irrational reals are simply undefined (and
hence infinitely far away). The 𝑝-adic metric is to fractal geometry as the Euclidean metric
is to Euclidean geometry. In particular, the set of 2-adic integers is homeomorphic to the
self-similar Cantor Set 𝒞 [17][28]. With this in mind, when we come to discuss state reduction
as a state-space instability (Section 4), it will be done with respect to a magnification of 𝒞,
corresponding to a shift map on the 2-adic numbers which label pieces of 𝒞. All this goes to
reinforce the idea that QM is the singular continuum limit of RaQM at 𝐿 = ∞.

3 Information-theoretic Description of the 𝑁-Qubit
State in RaQM
As already discussed, discretising Hilbert Space, even when 𝐿 ≫ 1, leads to a very different
theoretical description of the quantum wavefunction than in QM. Specifically, the qubit state
(1) in a basis satisfying the rationality constraints (2), can be expressed as a finite length-𝐿 bit
string [23]. The key to this result, as described explicitly in the Supporting Information, is a
discretisation of the Riemann Sphere of (extended) complex numbers as permutation/negation
√
operators acting on length-𝐿 bit strings. On the discretised Riemann Sphere, 𝑖 = −1 is not
introduced axiomatically as in C, but constructively, as a permutation/negation operator acting on 2-bit strings {𝑎 1 , 𝑎 2 } where 𝑎 𝑖 ∈ {1, −1}. Specifically, 𝑖{𝑎 1 , 𝑎 2 } = {−𝑎 2 , 𝑎 1 } so that
𝑖 2 {𝑎 1 , 𝑎 2 } = −{𝑎 1 , 𝑎 2 }, where −{𝑎 1 , 𝑎 2 } = {−𝑎 1 , −𝑎 2 }. The full 3D discretised Riemann Sphere
is built up from 𝑖, using constructive quaternionic/spinorial generalisations of 𝑖, as described in
the Supporting Information. The discretised Riemann Sphere has non-trivial arithmetic properties which underpin RaQM’s unique physical interpretation (e.g., quantum physics without
randomness or spooky action at a distance; see Section 7 and [20]).
The discretised Riemann Sphere leads directly to the discretised Bloch Sphere as 𝐿-bit
strings. Specifically,
|𝜓(𝜃, 𝜙)⟩ ≡ { 1,
|

1, 1, . . . 1, 1, 1, −1, −1, −1, . . . , −1, −1, −1}
{z
}

mod 𝜉

(6)

𝜃,𝜙

where the bits ‘1’ and ’-1’ are symbolic labels for measurement outcomes [29]. Here the fraction
of 1s in |𝜓⟩ is equal to cos2 (𝜃/2) and 𝜙/2𝜋 = 𝑛/𝐿 encodes 𝑛 cyclic permutations of the 𝐿-bit
string. 𝜉 is a specific but unknown permutation operator, representing a specific but unknown
relationship of a particular quantum system with respect to the rest of the universe. In RaQM,
𝜉 acts as a hidden variable in RaQM, accounting for what in QM would be described as the
inherent randomness of quantum measurement. Just as |𝜓(𝜃, 𝜙)⟩ in QM is invariant under a
global phase transformation, so |𝜓(𝜃, 𝜙)⟩ in (6) is invariant under a generic permutation 𝜉. As
such, |𝜓⟩ in (6) describes an unordered ensemble of 𝐿 possible binary measurement outcomes
for identically prepared states, with frequencies consistent with Born’s rule.
Importantly, however, for some specific 𝜉, RaQM allows the state of some particular quantum system to be defined (something problematic in QM) as the specific bit string
|𝜓(𝜃, 𝜙)⟩ 𝜉 = 𝜉{ 1,
|

1, 1, . . . 1, 1, 1, −1, −1, −1, . . . , −1, −1, −1}
{z
}

(7)

𝜃,𝜙

which can be written as the difference between two complementary integers in standard base-2
representation (for example, {1, −1, −1, 1} ≡ 1001. − 0110.). As will be discussed elsewhere,
such a representation allows one to describe single-particle interference in a Mach-Zehnder

6


## Page 7

interferometer - the key point being that the finite bit-string representation of that single
quantum particle is the resource that can describe its wave-like properties.
A system comprising 𝑁 entangled qubits is represented as 𝑁 correlated length-𝐿 bit strings,
where the same permutation 𝜉 applies to each string (consistent with 𝜉 as a global phase in
QM). Importantly, 𝑁 qubits comprise 𝑁 × 𝐿 bits of information. For example, with 𝑁 = 3, in
some particular rational basis, the 3 length-𝐿 bit strings corresponding to (4) can be written
as

{ 1, 1, 1, . . . 1, 1, 1, −1, −1, −1, . . . , −1, −1, −1} mod 𝜉


|
{z
}




𝜃1 , 𝜙1



 {1, 1, . . . , 1, −1, −1, . . . , −1 1, 1, . . . , 1, −1, −1 . . . , −1} mod 𝜉

|
{z
} |
{z
}
|𝜓⟩ ≡
(8)


𝜃2 , 𝜙2
𝜃3 , 𝜙3



{1, . . . , −1 1, . . . , −1 1, . . . , −1 1, . . . , −1} mod 𝜉



|
{z
} |
{z
} | {z } |
{z
}


𝜃4 , 𝜙4
𝜃5 , 𝜙5
𝜃6 , 𝜙6
𝜃7 , 𝜙7

where the variables in the under-braces correspond directly to the continuum degrees of freedom in (4) and Fig 1, but now subject to the rationality constraints (2). For example, cos2 𝜃 2 /2
denotes the fraction of 1 bits in the second bit string which correspond to 1 bits in the first
bit string, and 𝜙2 represents a cyclic permutation of these specific bits in the second bit string.
As above, these bit strings can be interpreted as an ensemble of measurement outcomes described by the 8 symbolic labels (1, 1, 1), (1, 1, −1), . . ., (−1, −1, −1), i.e., as belonging to the set
{±1, ±2, ±3, ±4}.
As with a single qubit, it is also possible to to interpret a set of bit strings, for a specific 𝜉,
as representing the state

𝜉{ 1, 1, 1, . . . 1, 1, 1, −1, −1, −1, . . . , −1, −1, −1}


|
{z
}




𝜃1 , 𝜙1



 𝜉{1, 1, . . . , 1, −1, −1, . . . , −1 1, 1, . . . , 1, −1, −1 . . . , −1}

|
{z
} |
{z
}
|𝜓⟩ 𝜉 =


𝜃2 , 𝜙2
𝜃3 , 𝜙3



𝜉{1, . . . , −1 1, . . . , −1 1, . . . , −1 1, . . . , −1}



|
{z
} |
{z
} | {z } |
{z
}


𝜃4 , 𝜙4
𝜃5 , 𝜙5
𝜃6 , 𝜙6
𝜃7 , 𝜙7


(9)

of an individual 3-qubit quantum system. These can be represented, as above, as a sum of
complementary integers in base-4 (e.g., {2, −3, −1, 4} ≡ 2004. − 0310..)
At 𝐿 = ∞ (the QM limit), arbitrarily many degrees of freedom can be encoded in the
infinitely long bit strings, and there would be no information-theoretic constraint on the number
of qubits that could be entangled. However, if 𝐿 has some finite value, there will be a finite limit
to the number of degrees of freedom that can be encoded in these bit strings. In particular,
since the total number of the number of bits in 𝑁 bit strings equals 𝑁 × 𝐿, and the number of
degrees of freedom in an 𝑁-qubit state in QM is 2 𝑁 +1 − 2, then when
2 𝑁 +1 − 2 > 𝑁 × 𝐿

(10)

there simply aren’t enough bits to allocate even one bit to each QM degree of freedom. By
way of illustration, suppose 𝐿 = 16. A 5-qubit state in QM has 62 degrees of freedom. Since 5
length-16 bit strings contain 80 bits in total, there are just enough bits in the 5 bit strings to
allocated at least 1 bit to each QM degree of freedom. However, a 6-qubit state in QM has 126
degrees of freedom. Since 6 length-16 bit strings contain 96 bits in total, there aren’t enough
bits to allocate even 1 bit to each degree of freedom. Hence, with 𝐿 = 16, 𝑁max = 5.
When 𝐿 ≫ 1, (10) implies
𝑁max ≈ log2 𝐿
(11)

7


## Page 8

In the classical limit 𝐿 = 1 there aren’t enough bits for even 𝑁max = 1: the classical limit is
not quantum-like at all! Consistent with this, as shown in the Supporting Information, the
discretised Riemann Sphere contains no complex structure when 𝐿 = 1.

4

State Reduction/ Measurement

Although state reduction plays no direct role in defining QIC (and hence on the constraint on
quantum computers), state reduction in RaQM is analysed here as it allows us to estimate 𝐿
numerically (see Section 5). In RaQM, state reduction can be defined in two equivalent ways.
First, it describes a steady loss of information in a quantum system as that system becomes
entangled with the environment. Secondly, it describes a chaotic state-space instability, separating initially close state-space trajectories until they are classically (see e.g., Fig 30.19 of [26]).
To illustrate these processes in RaQM, we return to the discussion at the end of Section 2 and
consider the Cantor Set 𝒞 (see Fig 2). The iterates of 𝒞 are themselves labelled by 𝐿, where
coarser iterations correspond to smaller values of 𝐿. This is consistent with the representation
of pieces of 𝒞 by 2-adic numbers - the coarser the iteration of 𝒞, the fewer the number of bits
needed to represent the corresponding 2-adic integers. We use an initial value 𝐿 = 4 in Fig
2 purely for illustrative convenience - the generalisation to much larger values of 𝐿 is entirely
straightforward. The two pieces of 𝒞 at 𝐿 = 1 are to be considered attractors to which the
qubit state is attracted. The fractal structure of 𝒞 implies that the corresponding basins of
attraction are profoundly intertwined [21].
Here a qubit state 𝑆 is represented by a small segment of 𝒞 at the 𝐿 = 4th iterate, or
equivalently by a 2-adic integer with 4 bits (Fig 2). State reduction to the classical limit 𝐿 = 1
occurs in 3 timesteps 𝑡 ∗ . During the first timestep, from 𝐿 = 4 to 𝐿 = 3, the left half of the
Cantor Set (containing 𝑆) is magnified back to 𝒞’s original size. During the second timestep,
the right half of the 𝐿 = 3rd iterate of 𝒞 (containing 𝑆) is again magnified back to 𝒞’s original
size. Finally, during the third timestep, the left half of the 𝐿 = 2nd iterate of 𝒞 is again
magnified back to 𝒞’s original size. 𝑆 is now ‘reduced’ to the right-hand piece of 𝒞 at 𝐿 = 1.
Shown is the corresponding evolution of the state 𝑆 ′ initially neighbouring 𝑆 at 𝐿 = 4, to the
left-hand piece of 𝒞 at 𝐿 = 1, illustrating geometrically the nature of the instability.
Equivalently, such state reduction is given by a simple chaotic shift map [37] on the 2-adic
representation of 𝑆, each step corresponding to a division by 2. In particular, under the 3
timesteps, 𝑆 is mapped
1010. ↦→ 101. ↦→ 10. ↦→ 1. ,
(12)
consistent with Fig 2 and highlighting measurement as a loss of information (to the environment). With respect to the 2-adic metric, 𝑆 ′ = 0010. is 2-adically close to 𝑆 = 1010. and hence
neighbours 𝑆 on 𝒮 (Fig 2). Under the 3 timesteps 𝑡∗ , 𝑆 ′ is mapped to
0010. ↦→ 001. ↦→ 00. ↦→ 0. ,

(13)

This is consistent with 𝑆 and 𝑆 ′ ‘reducing’ to the two classically distinguishable attractors at
the 𝐿 = 1 iterate. The evolution to 𝐿 = 1 is associated with a decrease over 3𝑡 ∗ from the initial
value 𝐿 = 4. For a general 𝐿, the collapse time 𝜏∗ to 𝐿 = 1 is given by
𝜏∗ = (𝐿 − 1) 𝑡 ∗

(14)

i.e., 𝐿 − 1 individual magnifications/shift maps, terminating at 𝐿 = 1.
But what corresponds to the timestep 𝑡 ∗ ? This question can be answered by assuming
that the physical process associated with Hilbert Space discretisation is gravity. It is already
widely assumed that the space-time continuum will break down at the Planck Scale. Perhaps,

8


## Page 9

Figure 2: State reduction as both loss of information and as a chaotic state-space instability, describable geometrically as a magnification of a Cantor Set 𝒞, or arithmetically as a shift map on
the 2-adic representation of a rational number. Here, for illustrative simplicity, we consider a qubit
state 𝑆 (relative to a basis satisfying (2)) initially as a piece of 𝒞 at the 𝐿 = 4th iteration. The
iterate at 𝐿 = 3 shows a magnification of the left half of the iterate at 𝐿 = 4 containing the state
𝑆, and the iterate at 𝐿 = 2 is a magnification of the right half of the iterate at 𝐿 = 3, and so on.
This process is represented arithmetically by the shift map (12). Whilst 𝑆 = 1010. reduces to 1., the
neighbouring (2-adically close) state 𝑆 ′ = 0010. reduces to 0., illustrating the nature of the instability. The hypothetical state represented by ‘𝑋’ to the immediate right of 𝑆, but not lying on 𝒞, is
completely undefined. 𝑋 might correspond to the qubit state in a counterfactual basis where squared
amplitudes or complex phases (in degrees) are irrational numbers. Such bases typically occur when
considering non-classical properties of quantum systems [20].

9


## Page 10

a fortiori a synthesis of quantum and gravitational physics will lead to a breakdown in the
Hilbert Space continuum. Since QM has been such experimentally well-tested theory, it is
clear that any such breakdown of the Hilbert Space continuum must occur on very fine scales
(in the sense that discretisation is undetectable for small numbers of qubits). This is consistent
with gravity being so weak. However, as stressed above, if the continuum limit is singular,
there will surely be some observable consequences of Hilbert Space discretisation, no matter
how is fine the discretisation.
With this assumption, we draw on the Diósi-Penrose [5] [25] model of quantum state reduction with collapse timescale
ℏ
𝜏DP =
(15)
𝐸𝐺
Here, 𝐸 𝐺 is the Diósi-Penrose gravitational self-energy associated with two instances of a mass
in QM superposition. As discussed e.g., in [27], 𝐸 𝐺 can be viewed as the energy needed to move
one instance of the mass away from the other by a distance 𝑏 taking account of the gravitational
field of the masses. It can be noted that when 𝑀 equals the Planck mass, 𝜏DP = 𝑡 𝑃 , the Planck
time.
We now let 𝜏∗ = 𝜏DP and put 𝑡 ∗ = 𝑡 𝑃 . Then 𝐿 is described by the simple formula
𝐿=⌈

𝐸𝑃
⌉
𝐸𝐺

(16)

where 𝐸 𝑃 is the Planck energy (≈ 109 J) and ⌈𝑥⌉ denotes the ceiling function mapping the real
number 𝑥 to the nearest integer greater than 𝑥. The identification 𝑡∗ = 𝑡 𝑃 is consistent with the
Diósi-Penrose model, since if 𝐸 𝐺 were very slightly less than 𝐸 𝑃 , so that 𝐿 = 2, reduction to
the classical limit would occur in one timestep 𝑡∗ = 𝑡 𝑃 according to the Diósi-Penrose model.
From (16), we see that QM corresponds to the singular (unphysical) limit 𝐸 𝐺 = 0, i.e. 𝐺 = 0.
It is important to note that in RaQM, state collapse is not described by modifying the
Schrödinger equation. In particular, this state-reduction process does not itself imply any
local space-time energy dissipation, a feature of some collapse models (e.g., [24] [8]). Hence
RaQM is wholly consistent with a failure to detect the local effects of energy dissipation during
measurement [6].
As 𝐿 decreases to 1, we expect the quantum system to become more and more entangled
with its environment. As discussed in Section 3, an 𝑁-qubit system in RaQM is described by
𝑁 partially correlated bit strings, or equivalently as 1 string comprising 2 𝑁 labels. Hence, the
state of the fully entangled system in the classical limit 𝐿 = 1 is describable by a single one
of these 2 𝑁 labels, i.e. as a single integer 𝑝 (typically ≫ 0) lying between 0 and 2 𝑁 . Since
these are now single integers, and not strings of integers, In describing how different systems
described by different integers 𝑝 1 , 𝑝 2 etc interact when 𝐿 = 1, the arithmetic would necessarily
be Euclidean rather than 𝑝-adic. In this sense, the classical limit corresponds not only to
𝐿 = 1, but to a transition from 𝑝-adic to Euclidean arithmetic. We will pursue this conclusion
elsewhere.
The state reduction process described here plays no direct role in the quantum computing
constraint described in this paper. Rather, we ‘merely’ invoke state reduction in order to estimate QIC numerically. To see the irrelevance of state reduction as a direct physical constraint,
consider our estimate (Section 5) 𝐿 = 1070 for a quantum dot qubit. After 1 billion years, 𝐿
will have decreased by ≈ 3 × 1060 which is a negligible fraction of 1070 . By contrast, if the qubit
had sufficient mass that 𝐿 ≈ 1040 , still ≫ 1, then collapse to 𝐿 = 1 would take less than 1ms.

10


## Page 11

5

Estimating 𝐿 and 𝑁max .

For a system of mass 𝑀 with characteristic size 𝑅, in QM superposition over a distance 𝑏, we
make use of formulae for 𝐸 𝐺 already available in the literature. In particular [14]:


6𝐺 𝑀 2 5 2 5 3 1 5
𝐸𝐺 =
𝛽 − 𝛽 + 𝛽
if 0 ≤ 𝛽 ≤ 1
5𝑅
3
4
6


6𝐺 𝑀 2
5
=
1−
if 𝛽 ≥ 1
5𝑅
12𝛽
(17)
where 𝛽 = 𝑏/(2𝑅).
1) Consider a typical quantum dot associated with an electron of mass 10−30 kg in QM
superposition over 𝑏 = 5nm. A question immediately rises as to whether we take 𝑅 to be the
size 𝑅𝑒 of the electron, 10−15 m, or the size 𝑅 𝑝 of the electron’s QM probability cloud, say
10−9 m. We will use this ambiguity to provide an estimate of uncertainty in 𝐸 𝐺 . In both cases
𝛽 ≥ 1 and, for order-of-magnitude estimates we use the approximate expression
𝐸𝐺 ≈

𝐺 𝑀2
≈ 10−55 𝐽
𝑅

(18)

when 𝑅 = 𝑅𝑒 and 𝐸 𝐺 ≈ 10−61 J when 𝑅 = 𝑅 𝑝 . Using (16), then 𝐿 ≈ 1064 ≈ 2212 when 𝑅 = 𝑅𝑒
and 𝐿 ≈ 1070 ≈ 2232 when 𝑅 = 𝑅 𝑝 . In both cases, we have 𝑁max ≈ 200, showing that the
calculation is not especially sensitive to the choice of 𝑅.
2) With 𝑡 ∗ = 𝑡 𝑃 , the state-reduction model for discretised Hilbert Space necessarily incorporates the speed of light 𝑐. We will take advantage of this to estimate 𝐿 for photonic qubits in
a quantum computer, in superposition over a distance given by some fraction 𝛽 of the photon
wavelength 𝜆. Although the Diósi-Penrose model was developed within a Newtonian gravitational framework, we assume it will continue to hold in a post-Newtonian framework where
gravity couples to energy. For a photon, we let 𝑀 in (17) denote the relativistic mass ℎ/𝑐𝜆 in
the computer’s rest frame. Consider an infrared photon of wavelength 𝜆 = 103 nm, as used in a
photonic quantum computer. With 𝛽 = 10−3 say, (17) becomes
𝐺 ℎ2
𝐸 𝐺 ≈ 𝛽2 2 3 ≈ 10−82 𝐽
𝑐 𝜆

(19)

so that 𝐿 ≈ 1091 ≈ 2302 . Hence, 𝑁max ≈ 300, somewhat bigger than for the quantum dot
example. To be consistent with special relativity, both 𝐿 and 𝜏∗ are frame dependent.
3) Consider an ion in an ion-trap where the qubit basis states are based on hyperfine atomic
line splitting with an energy difference Δ𝐸 ≈ 10−9 eV. Writing (19) with 𝛽 ≈ 1, then
𝐸𝐺 ≈

𝐺Δ𝐸 3
≈ 10−100 𝐽
ℎ𝑐5

(20)

and hence 𝐿 ≈ 10109 ≈ 2400 . Hence 𝑁max ≈ 400, somewhat higher than the estimates above.
4) Undoubtedly, technological developments in qubit precision will increase 𝑁max further.
However, is there an upper limit to 𝑁max that technology, no matter how precise, cannot
exceed? Consider the energy 10−32 eV of a photon with the lowest possible frequency that can
be accommodated within the age of the universe (taken as 1011 years), giving a wavelength
𝜆 = 1025 m. Now consider two such ultra-low frequency photons in QM superposition over a
distance of one Planck length 10−35 m so that 𝛽2 ≈ 10−120 . Using (19), 𝐸 𝐺 ≈ 10−289 J and hence
𝐿 ≈ 10298 , giving 𝑁max ≈ 1, 000.

11


## Page 12

These estimates are based on single qubit mass/energy values. In the limit where the qubits
in a quantum computer are spatially well separated, then the relevant 𝐸 𝐺 for the composite
system will be equal to that for the individual qubits. On the other hand, if we were to consider
the 𝑁 qubits as a single ‘conglomerated’ mass, this would slightly reduce the estimates of 𝑁max
but not by much. For example, if 𝑀 ↦→ 300𝑀 in (18) then 𝐸 𝐺 ≈ 217 𝐸 𝐺 , and the estimate of
𝑁max only decreases by 17.
This limit does not change the more a quantum system is shielded from its non-gravitational
environment; positioning a quantum computer in a deep crater on the dark side of the moon
will not help to overcome the constraints of a finite 𝑁max . By the Principle of Equivalence, a
quantum computer will always be gravitationally coupled to the rest of the universe.

6

An Experimental Test of RaQM

From the discussion above, and the values obtained for 𝐿, RaQM will be experimentally indistinguishable from QM for small numbers of entangled qubits, and indeed for large numbers
𝑁 > 𝑁max qubits where superposition/entanglement is restricted to a low-dimensional sub-space
of the full 2 𝑁 +1 − 1 Hilbert Space dimension. On the other hand RaQM will be experimentally
distinguishable from QM for 𝑁 > 𝑁max for quantum systems where superposition/entanglement
is maximally distributed across the full 2 𝑁 +1 − 2 dimensions of Hilbert Space.
The Quantum Fourier Transform is such an algorithm [33]. Hence a candidate for testing
RaQM (and hence the breakdown of QM) is Shor’s algorithm. For example, the quantum
circuit described in [36], implementing Shor’s algorithm, needs 𝑁 qubits to factor an 𝑁 − 1-bit
semi-prime. Here 𝑁 = 2, 049 exceeds even our largest conceivable estimate of 𝑁max . Hence,
insofar as it is impossible to factor a 2048-bit integer (within the age of the universe) using
a classical computer, RaQM predicts it will be impossible to factor such an integer with a
quantum computer. Indeed, according to estimates described in Section 5, a quantum computer
based on current qubit technology will already have ceased having an advantage over a classical
computer in factoring a 1,024-bit RSA integer.
In practice, the performance of quantum computers is limited by qubit imperfections and
environmental noise. Error-correction algorithms can correct for such factors, utilising additional qubits. Hence, RaQM does not predict that the performance of noisy qubits will saturate
at 1,000 qubits. However, suppose, based on QM, it will be possible to factor a 2,048-bit RSA
integer in a quantum computer using some large number 𝑁2,048 > 2, 048 of noisy qubits (say
a million [9]), then we predict, based on RaQM, that the performance of the computer in
factoring such an integer will be no better than a classical computer as the number of qubits
approaches 𝑁2,048 . We therefore have a test of RaQM that could be falsified in a few years if
quantum technology roadmaps are accurate.
Perhaps it might be argued that macroscopic quantisation contradicts predictions of the
breakdown of QM when 𝑁 > 𝑁max . For example, a superconducting fluid comprising Avogadro’s number 𝑁𝑒 of electrons is very well described by QM (e.g., using the Bardeen, Cooper
Schrieffer BCS model) where 𝑁𝑒 ≫ 𝑁max . On the other hand, whilst such a system has the
potential for each of its component parts to be describable by individual wave functions so
that the system is a product state of a very large number of individual subsets, in practice
these subsets lock into a single collective wave function, having, for example, the same phase.
In this way, one can talk about the phase of the system’s wave function independent of the
individual electrons. In the BCS model, therefore, the system evolves in a very small subset
of the available Hilbert Space. That is to say, unlike the Quantum Fourier Transform, the
BCS model does not involve bases in which the system’s state is maximally spread across the
available Hilbert Space. A classical analogy of the point being made here might be the nonlinear synchronisation of a large number 𝑁𝑜 of oscillators. The fact that the oscillators are

12


## Page 13

synchronised means that the phase portrait of the system can be described in a very much
smaller dimensional space than that of the Cartesian product of all 𝑁𝑜 individual oscillators.
As such, macroscopic quantisation does not contradict RaQM’s predictions.
QM is not predicted to break down ‘suddenly’ at 𝑁 = 𝑁max qubits. For 𝑁 < 𝑁max , then
𝑁 𝐿/(2 𝑁 +1 − 2) bits can be allocated to each Hilbert Space dimension. For example, with
𝑁max ≫ 1 and 𝑁 = 𝑁max − 1, then 21 qubits can be allocated to each Hilbert State dimension.
When 𝑁 is 5 qubits short of 𝑁max , then 25 = 32 bits can be allocated to each Hilbert Space
dimension, and so on. Hence, if the computer can be completely shielded from environmental
noise, the output from the computer (in factoring integers with Shor’s algorithm) will appear
to be subject to an increasingly strong type of discretised ‘Shot’ noise as 𝑁 approaches 𝑁max .

7

Conclusions and Discussion

A novel theory, Rational Quantum Mechanics (RaQM), of quantum physics has been ourlined.
In RaQM, the complex Hilbert state of an entangled 𝑁-qubit system, evolved using the unmodified Schrödinger equation, is only mathematically defined in bases where squared amplitudes
and complex phases (in degrees) are rational numbers of the form 𝑚/𝐿 where 𝐿 ∈ N and 𝑚
is a whole number with 𝑚 ≤ 𝐿. Using a constructive discretisation of the Riemann Sphere
of complex numbers, the complex Hilbert state in such a basis can be described as 𝑁 correlated length-𝐿 bit strings, where 𝐿 is a fundamental variable of RaQM describing the degree
of granularity of Hilbert Space. QM is itself the singular continuum limit of RaQM at 𝐿 = ∞.
There are a number of compelling reasons for positing such a theory, only some of which
are discussed in this paper. Firstly, as discussed, it allows the information theoretic nature
of the quantum system to be described explicitly [35]. Secondly, as also discussed, it provides
an explicit description of state reduction to the classical limit 𝐿 = 1 in terms of a chaotic
instability which can be described both geometrically and arithmetically. Thirdly, not discussed
here but see the companion paper [20], see also below, discrete Hilbert Space provides novel
interpretations of inherently quantum properties, such as complementarity, non-commutativity
of observables and entanglement (and hence EPR/Bell nonlocality). Finally, as discussed,
discretisation provides a novel route for incorporating the effects of gravity in quantum physics,
not as some field to be quantised by independently derived quantisation rules, but as an inherent
ingredient of such quantisation rules.
Based on RaQM, we predict a breakdown of QM that may be experimentally falsifiable in
a few years using quantum computers. The assumptions made in making this prediction are
summarised here:
• RaQM assumes the discretisation ansatz (2) for a single qubit, thus introducing the finite
discretisation parameter 𝐿, also named Qubit Information Capacity (QIC).
• RaQM assumes a straightforward generalisation for multi-qubit states, implying that the
QIC of 𝑁 entangled qubits equals 𝑁 × 𝐿. Hence, for given 𝐿, QIC grows linearly with
𝑁. Since in QM the Hilbert space dimension of 𝑁 entangled qubits equals 2 𝑁 +1 − 2 and
hence grows exponentially with 𝑁, there must exist a maximum value 𝑁max ≈ log2 𝐿 of 𝑁,
above which it is not possible to allocate even one bit of information to each QM degree of
freedom. At this point, a quantum algorithm such as Shor’s, which utilises Hilbert Space
maximally, can no longer continue to have an advantage over a corresponding classical
algorithm.
• We estimate QIC by studying state reduction. It is assumed that state reduction is
associated with a chaotic state-space instability whereby initially nearby states diverge
exponentially until they have separated sufficiently to be classically distinguishable. This
process corresponds to a decrease in 𝐿 by a value of 1 per timestep 𝑡∗ until the classical

13


## Page 14

limit at 𝐿 = 1 is reached. Physically, we can suppose that this reduction in information
is lost to the environment as the quantum system decoheres.
• It is assumed that gravity sets the discretisation scale 𝐿, so that the state reduction
timescale becomes 𝜏∗ = (𝐿 − 1)𝑡 𝑃 , where 𝑡 𝑃 is the Planck time. Consistent with this,
𝜏∗ = 𝜏DP , the Diósi-Penrose collapse timescale, so that 𝐿 = ⌈𝐸 𝑃 /𝐸 𝐺 ⌉, where 𝐸 𝑃 is the
Planck energy, 𝐸 𝐺 is the Diósi-Penrose gravitational self-energy difference, and ⌈. . .⌉ is
the ceiling function of number theory.
• Existing formulae for 𝜏DP are used to estimate 𝐿 for a quantum dot qubit in a quantum
computer, giving 𝑁max ≈ 200.
• It is assumed that the Diosi-Penrose formula can be extended to describe photonic qubits
by replacing 𝑀 with the relativistic mass-energy ℎ/𝑐𝜆 in the computer’s rest frame. This
leads to a value 𝑁max ≈ 300 for a photonic qubit, and 𝑁max ≈ 400 for an ion trap qubit
based on hyperfine line splitting.
• Considering a photon with frequency given by the inverse age of the universe, put into
phase superposition over one Planck length, we show that 𝑁max can never exceed 1, 000
and hence 2048-bit RSA integers will never be factored.
The notion that there may be an information-theoretic limitation to the capability of a
quantum computer is not entirely new (e.g., [32]). In particular Davies [4] has argued, using
Lloyd’s [18] estimate 𝐼universe ≈ 10122 of bits of information (in bosons, fermions and gravitational degrees of freedom) encoded in the universe, that the Hilbert Space dimension of a
quantum state which entangles more than 𝑁Davies = log2 𝐼universe qubits is larger than 𝐼universe .
Davies suggests that this may signal a fundamental physical limit to quantum computation.
Whether one is convinced by a cosmological argument of this type or not, the value 𝑁Davies ≈
400 is remarkably similar to the ones deduced here, made without explicit reference to the rest
of the universe. Is this a coincidence? The author thinks not. The original motivation for
developing a model of quantum physics based on discretised Hilbert Space [23] was as a way
to understand the violation of Bell’s inequality. For example, the arithmetic properties of the
discretisation of the Riemann Sphere (see Supporting Information) imply that the Measurement
Independence postulate [13] in Bell’s Theorem is violated, not for nominal measurement settings
that are always under the full control of experimenters, but for exact measurement settings
that were never under their control anyway. Hence, as discussed in [20], the violation of
Bell’s inequality need not imply abandonment of local realism. However, it must imply some
notion of holism. Indeed, one can take inspiration from the development of general relativity,
motivated by Mach’s holistic but not nonlocal principle that inertia ‘here’ is due to mass
‘there’. The author’s Invariant Set Postulate [22], that the universe be considered a chaotic
dynamical system evolving precisely on a dynamically invariant measure-zero fractal, is also
an example of a holistic but not EPR/Bell nonlocal concept - and is consistent with the 𝑝-adic
state representations discussed in this paper. In this regard, the close numerical agreement
between 𝑁max and 𝑁Davies may well be evidence of the holistic nature of the laws of physics at
their most fundamental, as discussed above. This surely must be important when attempting
to synthesise quantum and gravitational physics.
Much of the development of quantum computers has been motivated by their potential
commercial applications. If the proposed test does indeed support RaQM, it will stymie the
development of such applications. On the other hand, if quantum computers can aid the development of an improved understanding of the fundamental laws of physics, not least in helping
to synthesise quantum and gravitational physics, then currently unforeseeable commercial opportunities may arise for future generations.

14


## Page 15

Acknowledgements
My thanks to Simon Benjamin, Stephen Blundell, Paul Davies, Chris Heunen, Sabine Hossenfelder, Richard Howl, Roger Penrose, Felix Tennie and the PNAS reviewers for extremely helpful
comments and inputs. My thanks also to Brendan Palmer for assistance with the graphics.
The research described in this paper was supported by the Leverhulme Trust Grant Number
EM-2023-060.

References
[1] M Berry. Singular limits. Physics Today, 55:10–11, 2002.
[2] R. Buniy, S. Hsu, and A. Zee. Is Hilbert space discrete? Phys.Lett., B630:68–72, 2005.
[3] S.M. Carroll. Completely discretised, finite quantum mechanics. Found. Phys., 53:90,
2013.
[4] P.C.W. Davies. The implications of a cosmological information bound for complexity,
quantum information and the nature of physical law. Fluctuation and Noise Letters,
07:C37–C50, 2007.
[5] L. Diósi. Models for universal reduction of macroscopic quantum fluctuations. Phys. Rev.,
A40:1165–74, 1989.
[6] S. Donaldi. Underground test of gravity related wave-function collapse. Nature, 17:74–78,
2021.
[7] G.F.R. Ellis, K.A.Meissner, and H.Nicolai. The physics of infinity. Nature, 14:770–772,
2018.
[8] G.C. Ghirardi, A. Rimini, and T. Weber. Continuous-spontaneous-reduction model involving gravity. Phys. Rev. A, A42:1057–64, 1990.
[9] C. Gidney. How to factor 2048 bit RSA integers with less than a million noisy qubits.
arXiv:2505.15917, 2025.
[10] N. Gisin. Indeterminism in physics, classical chaos and Bohmian mechanics: Are real
numbers really real? Erkenntnis, 86:1469–1481, 2021.
[11] Jonte R Hance, Tim N Palmer, and John Rarity. Experimental tests of invariant set
theory. Physica Scripta, 100:065123, 2025.
[12] L. Hardy. Why is nature described by quantum theory? In Science and Ultimate Reality:
Quantum Theory, Cosmology and Complexity. Eds J.D Barrow, P.C.W. Davies and C.L.
Harper Jr. Cambridge University Press, 2004.
[13] Sabine Hossenfelder and Tim Palmer. Rethinking superdeterminism. Frontiers in Physics,
8:139, 2020.
[14] Richard Howl, Roger Penrose, and Ivette Fuentes. Exploring the unification of quantum
theory and general relativity with a Bose-Einstein condensate. New Journal of Physics,
21:043047, 2019.
[15] S. Hsu. Discrete Hilbert Space, the Born rule and quantum gravity. Mod. Phys. Lett,
A36:2150013, 2021.
[16] J. Jahnel. When does the (co)-sine of a rational angle give a rational number?
arXiv:1006.2938, 2010.
[17] S. Katok. P-adic analysis compared with real. American Mathematical Society, 2007.

15


## Page 16

[18] S. Lloyd. Computational capacity of the universe. Phys. Rev. Lett, 88:237901, 2002.
[19] I. Niven. Irrational Numbers. The Mathematical Association of America, 1956.
[20] Tim Palmer. Impossible counterfactuals, discrete Hilbert space and Bell’s theorem. Journal of Physics - Conference Series. Issue in Memory of Basil Hiley, arXiv:2601.14941,
2026.
[21] T.N. Palmer. A local deterministic model of quantum spin measurement. Proc. Roy. Soc.,
A451:585–608, 1995.
[22] T.N. Palmer. The invariant set postulate: a new geometric framework for the foundations
of quantum theory and the role played by gravity. Proc. Roy. Soc., A465:3165–3185, 2009.
[23] T.N. Palmer. Discretization of the Bloch sphere, fractal invariant sets and Bell’s theorem.
Proc. Roy. Soc., https://doi.org/10.1098/rspa.2019.0350, arXiv:1804.01734, 2020.
[24] P. Pearle. Reduction of the state vector by a nonlinear schrödinger equation. Phys. Rev.
D, 13:857–868, 1976.
[25] R. Penrose. On gravity’s role in quantum state reduction. General Relativity and Gravitation, 28:581–600, 1996.
[26] R. Penrose. The Road to Reality: A Complete Guide to the Laws of the Universe. Jonathan
Cape, London, 2004.
[27] R. Penrose. On the gravitization of quantum mechanics 1: Quantum state reduction.
Foundations of Physics, 44:557–575, 2014.
[28] A. M. Robert. A Course in p-adic Analysis. Springer ISBN 0-387-98660-3, 2000.
[29] J. Schwinger. Quantum Mechanics: Symbolism of Atomic Measurements. Springer, 2001.
[30] S.H. Strogatz. Nonlinear dynamics and chaos. Westview Press, 2000.
[31] G. ’tHooft. Models on the boundary between classical and quantum mechanics. Phil.
Trans. A, A373:20140236, 2015.
[32] G. ’tHooft. The Cellular Automaton Interpretation of Quantum Mechanics. Springer,
2016.
[33] Jon Tyson. Operator-schmidt decomposition of the quantum fourier transform on 1𝑛 ⊗ 2𝑛 .
J. Phys. A., 36:6813, 2003.
[34] Michele Vischi, Ferialdi L., Trombettoni A., and Bassi A. Possible limits on superconducting quantum computers from spontaneous wave-function collapse models. Phys. Rev.,
B106:174506, 2022.
[35] J. Wheeler. Information, physics, quantum: the search for links. 3rd Int Symp. Foundations of Quantum Mechanics, Tokyo, pages 354–368, 1989.
[36] D. Willsch, P. Hanussek, G. Hoever, M. Willsch, F. Jin, H. de Raedt, and K. Michielsen.
The state of factoring on quantum computers. arXiv:2410.14397, 2024.
[37] C.F. Woodcock and N.P.Smart. p-adic chaos and random number generation. Experimental Mathematics, 7:333–342, 1998.

Supporting Information
Discretising the Riemann Sphere
√
The continuum field C, with its axiomatically defined element 𝑖 = −1, plays an essential
role in QM (either explicitly or implicitly as in the de Broglie-Bohm interpretation). Central

16


## Page 17

to RaQM is a discretisation of the Riemann Sphere C ∪ {∞} of (extended) complex numbers
𝑧(𝜃, 𝜙) = cot(𝜃/2)𝑒 𝑖 𝜙 where 𝜃 denotes co-latitude (or zenith angle) and 𝜙 denotes longitude (or
azimuth). The discretisation is defined by
cos2

𝜃
𝑚
=
∈ Q;
2
𝐿

𝜙
𝑛
= ∈ Q.
2𝜋
𝐿

(21)

where 𝐿 ∈ N and 0 ≤ 𝑚, 𝑛 ≤ 𝐿 are whole numbers. Note that if 𝜃 satisfies (21) then since
cos 𝜃 = 2 cos2 (𝜃/2) − 1, necessarily cos 𝜃 ∈ Q. 𝐿 is an especially important variable, defining
the degree of granularity of discretised Hilbert Space: QM is the (singular) limit of RaQM
at 𝐿 = ∞, whilst the classical limit of RaQM occurs at 𝐿 = 1. The key property of this
discretisation is that the 𝑖 (with property 𝑖 2 = −1) does not have to be introduced by axiom.
Rather, as discussed below, 𝑖 and the corresponding quaternions are defined constructively from
representations of complex numbers as permutation/negation operators acting on bit strings.
With this definition of 𝑖, the entire set {𝑧(𝜃, 𝜙)} of complex numbers on the discretised Riemann
Sphere is obtained constructively by an inductive argument, for all 𝐿 ∈ N.

Discretised Complex Numbers and Quaternions
When 𝐿 = 20 = 1, (21) implies 𝜃 ∈ {0, 𝜋}, 𝜙 = 0, i.e., the discretisation only admits 2 points at
the north and south poles. We represent the corresponding set of ‘complex numbers’ in terms
of the identity and negation operators
𝑧(0, 0){1} = {1}; 𝑧(𝜋, 0){1} = {−1} = −{1}

(22)

With 𝐿 = 20 (the classical limit of RaQM), the discretisation is too coarse to admit complex
structure at all. Complex numbers play no essential role in classical physics.
When 𝐿 = 21 , then 𝜃 ∈ {0, 𝜋/2, 𝜋}, 𝜙 ∈ {0, 𝜋} according to (21). 𝐿 = 2 is large enough to
admit complex structure, represented by the permutation/negation operator (PNO) 𝑖 defined
as
𝑖{𝑎 1 , 𝑎 2 } = {−𝑎 2 , 𝑎 1 }
(23)
where 𝑎 𝑖 ∈ {1, −1}, so that 𝑖 2 {𝑎 1 , 𝑎 2 } = {−𝑎 1 , −𝑎 2 } ≡ −{𝑎 1 , 𝑎 2 }. Generalising (22), the set of
complex numbers on the 𝐿 = 2 discretised Riemann Sphere are associated with the 4 PNOs
{𝑖 0 , 𝑖, 𝑖 2 , 𝑖 3 }. Specifically,
𝑧(0, 0){1, 1} = 𝑖 0 {1, 1} = {1, 1};
𝜋
𝑧( , 0){1, 1} = 𝑖{1, 1} = {−1, 1};
2
𝑧(𝜋, 0){1, 1} = 𝑧(𝜋, 𝜋){1, 1} = 𝑖 2 {1, 1} = {−1, −1};
𝜋
𝑧( , 𝜋){1, 1} = 𝑖 3 {1, 1} = {1, −1}
2

(24)

as shown in Fig 3a.
When 𝐿 = 22 = 4 then 𝜃 ∈ {0, 𝜋/3, 𝜋/2, 2𝜋/3, 𝜋}, 𝜙 ∈ {0, 𝜋/2, 𝜋, 3𝜋/2} according to (21). The
discretised sphere now comprises 8 points on each of two complete great circles (at 𝜙 = 0, 𝜋 and
𝜙 = 𝜋/2, 3𝜋/2) passing through the north and south poles - 14 points in total. 𝐿 = 4 is now
large enough to admit quaternionic structure, as shown below. The complex numbers at these
points are represented as PNOs acting on 4-bit strings. We start by considering the points
on the great circle 𝜙 = 0, 𝜋, writing {1, 1, 1, 1} as two concatenated 2-bit strings {1, 1}|{1, 1}.
We define PNOs based on {𝑖 0 , 𝑖, 𝑖 2 , 𝑖 3 } acting individually on each pair of 2-bit strings, with
a construction motivated by the theory of spinors. Specifically, we first apply 𝑖 twice to the
second 2-bit string keeping the first fixed. We then apply −𝑖 twice to the first 2-bit string

17


## Page 18

{1,1}

a)

L=2

{1,-1}

{-1,1}

{-1,-1}

b)

{1,1,1,1,}
{1,1}

L=4

2×(L=2)
{1,1,-1,1}

{-1,1}

{1,-1}

{-1,-1}

{1,1,-1,-1}

{-1,1,1,1}

{-1,-1,1,1}

{1,1}

2×(L=2)
{1,-1,-1,-1}

{1,-1}

{-1,1}

{-1,-1,1,-1}

{-1,-1}

{-1,-1,-1,-1}
Figure 3: a) The discretised Riemann Sphere at 𝐿 = 2, represented as four 2-bit strings on a
complete great circle at 𝜙 = 0, 𝜋 through the poles. b) A schematic illustration of how to construct
the discretised Riemann Sphere for 𝐿 = 4, again on the great circle through 𝜙 = 0, 𝜋, from two 𝐿 = 2
great circles as in a). See the text for details. This also illustrates the construction of an 𝐿 = 2 𝑀
discretised Riemann Sphere on the great circle at 𝜙 = 0, 𝜋, from two 𝐿/2-bit discretised great circles.
18


## Page 19

keeping the second fixed; then again apply 𝑖 twice to the second bit string keeping the first
fixed; then again apply −𝑖 twice to the first bit string keeping the second fixed. In total, from
Fig 3a, the first 2-bit string has been rotated by 4𝜋 relative to the second (like Dirac scissors
relative to the back of the chair). Specifically,
𝑧(0, 0){1, 1, 1, 1} = 𝑖 0 {1, 1}|𝑖 0 {1, 1} = {1, 1, 1, 1};
𝜋
𝑧( , 0){1, 1, 1, 1} = 𝑖 0 {1, 1}|𝑖 1 {1, 1} = {1, 1, −1, 1};
3
𝜋
𝑧( , 0){1, 1, 1, 1} = 𝑖 0 {1, 1}|𝑖 2 {1, 1} = {1, 1, −1, −1};
2
2𝜋
𝑧( , 0){1, 1, 1, 1} = 𝑖 3 {1, 1}|𝑖 2 {1, 1} = {1, −1, −1, −1};
3
𝑧(𝜋, 0){1, 1, 1, 1} = 𝑧(𝜋, 𝜋){1, 1, 1, 1} = 𝑖 2 {1, 1}|𝑖 2 {1, 1} = {−1, −1, −1, −1};
2𝜋
𝑧( , 𝜋){1, 1, 1, 1} = 𝑖 2 {1, 1}|𝑖 3 {1, 1} = {−1, −1, 1, −1};
3
𝜋
𝑧( , 𝜋){1, 1, 1, 1} = 𝑖 2 {1, 1}| 𝑖 0 {1, 1} = {−1, −1, 1, 1};
2
𝜋
𝑧( , 𝜋){1, 1, 1, 1} = 𝑖 1 {1, 1}|𝑖 0 {1, 1} = {−1, 1, 1, 1}
3

(25)

This construction is illustrated schematically in Fig 3b. Here the 4-bit strings on the 𝐿 = 4
great circle comprise two 2-bit strings from the pair of smaller 𝐿 = 2 circles, where one rotates
in steps of 𝜋/2 by 4𝜋 relative to the other.
The complex numbers on the 𝜙 = 𝜋/2, 3𝜋/2 great circle are PNOs obtained by a cyclic
permutation of bit strings on the 𝜙 = 0, 𝜋 great circle, so that
𝜋
){1, 1, 1, 1} = {1, 1, 1, 1};
2
𝜋 𝜋
𝑧( , ){1, 1, 1, 1} = {1, −1, 1, 1};
3 2
𝜋 𝜋
𝑧( , ){1, 1, 1, 1} = {1, −1, −1, 1};
2 2
2𝜋 𝜋
𝑧( , ){1, 1, 1, 1} = {−1, −1, −1, 1};
3 2
𝜋
3𝜋
𝑧(𝜋, ){1, 1, 1, 1} = 𝑧(𝜋,
) = {−1, −1, −1, −1};
2
2
2𝜋 3𝜋
){1, 1, 1, 1} = {−1, 1, −1, −1};
𝑧( ,
3 2
𝜋 3𝜋
𝑧( ,
){1, 1, 1, 1} = {−1, 1, 1, −1};
2 2
𝜋 3𝜋
𝑧( ,
){1, 1, 1, 1} = {1, 1, 1, −1}.
3 2
𝑧(0,

(26)

That this cyclic permutation is consistent with quaternionic structure can be seen by defining
the operators
𝐼{𝑎 1 , 𝑎 2 , 𝑎 3 , 𝑎 4 } = {𝑎 3 , 𝑎 4 , −𝑎 1 , −𝑎 2 }
𝐽{𝑎 1 , 𝑎 2 , 𝑎 3 , 𝑎 4 } = {𝑎 2 , −𝑎 1 , −𝑎 4 , 𝑎 3 }
𝐾 {𝑎 1 , 𝑎 2 , 𝑎 3 , 𝑎 4 } = {−𝑎 4 , 𝑎 3 , −𝑎 2 , 𝑎 1 }

(27)

which satisfy
𝐼 2 = 𝐽 2 = 𝐾 2 = −1;

19

𝐼 × 𝐽 = 𝐾.

(28)


## Page 20

In particular, 𝐼{1, 1, 1, 1} = {1, 1, −1, −1} = 𝑧(𝜋/2, 0){1, 1, 1, 1} and 𝐽{1, 1, 1, 1} = {1, −1, −1, 1} =
𝑧(𝜋/2, 𝜋/2){1, 1, 1, 1}, consistent with 𝐼 and 𝐽 rotating the 4-bit string {1, 1, 1, 1} at the north
pole to the 4-bit strings on the equator at 𝜙 = 0 and 𝜙 = 𝜋/2, respectively. Consistent with
this, 𝐾 maps one these equatorial points to the other:
𝐾 𝐼{1, 1, 1, 1} = 𝐾 {1, 1, −1, −1} = {1, −1, −1, 1} = 𝐽{1, 1, 1, 1}.

(29)

The 14 4-bit strings on the 3D 𝐿 = 4 discretised Riemann sphere are shown in Fig 4. The
inductive step is to write the discretised PNOs for some 𝐿 = 2 𝑀 , acting on the 𝐿-bit string
{1, 1, . . . , 1} as PNOs acting on 2 concatenated 𝐿/2-bit strings {1, 1, . . . 1}|{1, 1, . . . , 1}. The
PNOs on the 𝜙 = 0, 𝜋 great circle are defined using the spinorial construction illustrated in Fig
4b, generalised so that the two smaller circles represent the two 𝐿/2 discretised great circles at
𝜙 = 0, 𝜋. We then rotate the 𝜙 = 0, 𝜋 great circle around the polar axis by cyclically permuting
the 𝐿-bit string as in
𝜁 {𝑎 1 , 𝑎 2 , . . . , 𝑎 𝐿 } ↦→ {𝑎 2 , 𝑎 3 , . . . , 𝑎 𝐿 , 𝑎 1 }
(30)
Each application of 𝜁 corresponds to a rotation by 2𝜋/𝐿 radians.
This completes the 𝐿-discretisation of the Riemann Sphere when 𝐿 is a power of 2. For
discretisations where 𝐿 is not a power of 2, one can simply interpolate between constructions
where 𝐿 is a power of 2. For example, with 𝐿 = 3, one can simply remove the last bit from the
𝐿 = 4 construction on 𝜙 = 0, yielding
𝑧(0, 0){1, 1, 1} = {1, 1, 1};
𝑧(𝜃 ∗ , 0){1, 1, 1} = {1, 1, −1, };
𝑧(𝜋 − 𝜃 ∗ , 0){1, 1, 1} = {1, −1, −1};
𝑧(𝜋, 0){1, 1, 1} = {−1, −1, −1}

(31)

where cos 𝜃 ∗ = 1/3. For the longitudes 𝜙 = 2𝜋/3, 4𝜋/3, one simply performs two cyclic permutations to the 3-bit strings.
Note that, for all 𝐿, the proportion of 1s in the bit-string representing 𝑧(𝜃, 𝜙) is equal to
cos2 𝜃/2. Hence the proportion of −1s equals sin2 𝜃/2, and the relative frequency of 1s to −1s
is equal to cot2 𝜃/2. This is the basis for the claim that there is no need to postulate Born’s
Rule in RaQM - it is redundant in the Dirac-von Neumann axioms.

Arithmetic Properties of Complex Numbers on the Discretised Riemann
Sphere
Central to the physical interpretation of RaQM are the arithmetic properties of the complexnumber PNOs on the 𝐿-bit discretisation of the Riemann Sphere. In particular, suppose 𝑧1 and
𝑧 2 are complex numbers belonging to the 𝐿-discretised sphere. The key question we consider
in this section is whether 𝑧 1 ± 𝑧 2 belongs to the discretised sphere. We show that, typically,
but non-trivially, they do not.
On the Argand plane, 𝑧1 , 𝑧2 and 𝑧2 − 𝑧1 correspond to three sides of a triangle with vertices
at the origin, at 𝑧1 and at 𝑧2 . We will assume the triangle is non-degenerate, i.e. the angle 𝜙
between 𝑧 1 and 𝑧2 is non-zero. On the Riemann Sphere the corresponding triangle is a spherical
triangle with vertices which we label 𝑂, 1 and 2 (where 𝑂 corresponds to the south pole).
Now if 𝑧 1 = cot(𝜃 1 /2)𝑒 𝑖 𝜙1 and 𝑧 2 = cot(𝜃 2 /2)𝑒 𝑖 𝜙2 , both satisfy the rationality conditions
(21) then cos 𝜃 1 ∈ Q, cos 𝜃 2 ∈ Q and 𝜙 = (𝜙2 − 𝜙1 )/2𝜋 ∈ Q. If we write 𝑧2 − 𝑧 1 = cot(𝜃 3 /2)𝑒 𝑖 𝜙3 ,
then for 𝑧 2 − 𝑧 1 to lie on the discretised Riemann Sphere, we require that cos 𝜃 3 ∈ Q.
The cosine rule applied to the triangle △𝑂12 can be written
cos 𝜃 3 = cos 𝜃 1 cos 𝜃 2 + sin 𝜃 1 sin 𝜃 2 cos 𝜙

20

(32)


## Page 21

{1,1,1,1}

L=4

{1,1,1,-1}
{1,1,-1,1}

{-1,1,1,1}
{1,-1,1,1}
{-1,1,1,-1}

{1,1,-1,-1}

{-1,-1,1,1}
{1,-1,-1,1}
{-1,1,-1,-1}

{1,-1,-1,-1}

{-1,-1,1,-1}
{-1,-1,-1,1}

{-1,-1,-1,-1}

Figure 4: The full 3D discretised Riemann Sphere for 𝐿 = 4 - where, consistent with quaternionic
structure (see text), rotation about the polar axes corresponding to a cyclic permutation of the 4-bit
strings.

21


## Page 22

If cos 𝜃 3 ∈ Q, then, since the first term on the RHS of (32) is rational, the second term on the
RHS must also be rational. Squaring, this implies that
(1 − cos2 𝜃 1 )(1 − cos2 𝜃 2 ) cos2 𝜙 ∈ Q

(33)

and hence cos2 𝜙 ∈ Q and therefore cos 2𝜙 ∈ Q. However, we now have a contradiction since we
know that 𝜙/2𝜋 ∈ Q. According to Niven’s Theorem [19] [16], the only values 0 ≤ 𝜙 < 2𝜋 where
cos 2𝜙 and 2𝜙/2𝜋 are simultaneously rational are:
2𝜙 = 0,

𝜋 𝜋 2𝜋
4𝜋 3𝜋 5𝜋
, ,
, 𝜋,
,
,
.
3 2 3
3 2 3

(34)

Hence, unless 2𝜙 is a multiple of 60◦ exactly, cos 2𝜙 and 2𝜙/2𝜋 cannot be simultaneously
rational. Hence, modulo these exceptions, if 𝑧1 and 𝑧 2 satisfy (2), 𝑧 2 − 𝑧 1 cannot satisfy (21).
Of course, the same conclusion can be drawn if we add 𝑧 2 to 𝑧1 . In the argument above we
merely replace 𝜙 with 𝜋 − 𝜙.
We refer to this result as the ‘Impossible Triangle Corollary’ (to Niven’s Theorem). Niven’s
Theorem is central to RaQM and plays a vital role in the interpretation of complementarity,
non-commuting observables and to the violation of Bell inequalities in RaQM [20]. In these
interpretations the mathematically impossible bases (one with irrational squared amplitudes
and/or phases) correspond to physically impossible simultaneous counterfactual measurements.

Uncertainty Principle
In RaQM, the Uncertainty Principle for a single qubit arises from a trigonometric inequality
on the sphere, together with Niven’s Theorem. We then discuss the Uncertainty Principle for
multiple qubits.
Consider a point 𝑝 on the unit sphere (Fig 5) whose colatitude with respect to the three
orthogonal poles 𝑝 𝑥 , 𝑝 𝑦 and 𝑝 𝑧 is 𝜃, 𝜃 ′ and 𝜃 ′′ respectively.aThe internal angles 𝜙′ and 𝜂 are
shown on the figure. By the sine rule for spherical triangle 𝑝 𝑝 𝑥 𝑝 𝑦
sin 𝜃 ′′
sin 𝜋/2
1
=
=
sin 𝜙′
sin 𝜂
sin 𝜂

(35)

Hence
| sin 𝜃 ′′ | ≥ | sin 𝜙′ |
a
By the cosine rule for spherical triangle 𝑝 𝑝 𝑥 𝑝 𝑧 ,

(36)

cos 𝜃 = sin 𝜃 ′ sin 𝜙′

(37)

| sin 𝜃 ′ || sin 𝜃 ′′ | ≥ | sin 𝜃 ′ || sin 𝜙′ |

(38)

| sin 𝜃 ′ || sin 𝜃 ′′ | ≥ | cos 𝜃|

(39)

From (36)
and using (37)
As discussed, a bit string at colatitude 𝜃 has a mean value 𝜇 𝜃 = cos 𝜃, and standard deviation
𝜎𝜃 = sin 𝜃. With this in mind, consider three discretised Bloch spheres, with the north poles
oriented at 𝑝 𝑥 , 𝑝 𝑦 and 𝑝 𝑧 respectively. With cos 𝜃 = 𝜇 𝜃 , sin 𝜃 = 𝜎𝜃 (the mean and standard
deviation of the bit string) then from (39),
𝜎𝜃 ′ 𝜎𝜃 ′′ ≥ |𝜇 𝜃 |

22

(40)


## Page 23

Figure 5: In RaQM, the Uncertainty Principle Δ𝑆 𝑥 Δ𝑆 𝑦 ≥ 2ℏ 𝑆 𝑧 for a single spin qubit arises from the
trigonometry of spherical triangles and the correspondence between points on the discretised Bloch
sphere with coordinates satisfying the rationality and bit strings.

23


## Page 24

If instead of ±1, the bit strings have dimensional values ±ℏ/2 in order that they correspond to
physical spin, then (40) becomes the familiar uncertainty principle for spin qubits
Δ𝑆 𝑥 Δ𝑆 𝑦 ≥

ℏ
𝑆𝑧
2

(41)

The rationality constraints play
a a key role here. If, for example, cos 𝜃 ∈ Q and 𝜙 ∈ Q,
by Niven’s Theorem applied to 𝑝 𝑝 𝑥 𝑝 𝑧 , cos 𝜃 ′ cannot be rational. Hence it is impossible to
know simultaneously, the spin values of a particle with respect to the two directions 𝑝 𝑥 and 𝑝 𝑧
(similarly for any two other pairs of directions).
Let us now derive the Uncertainty Principle for conjugate observables defined on multiple
qubits (like position and momentum). First we square (40) and average over 𝑀 points 𝑝 on
the discretised Bloch Sphere. Then, from (39),
𝜎𝜃2′ 𝜎𝜃2′′ ≥ |𝜇 𝜃 | 2

(42)

Now
𝜎𝜃2′ 𝜎𝜃2′′ =

1
1
(𝜎 2′ + 𝜎𝜃2′ + . . . + 𝜎𝜃2′ ) × (𝜎𝜃2′′ + 𝜎𝜃2′′ + . . . + 𝜎𝜃2′′ )
1
2
2
𝑀
𝑀
𝑀 𝜃1
𝑀
1
((𝜎𝜃2′ 𝜎𝜃2′′ + 𝜎𝜃2′ 𝜎𝜃2′′ + . . . + 𝜎𝜃2′ 𝜎𝜃2′′ ) = 𝜎𝜃2′ 𝜎𝜃2′′
>
1
1
2
2
𝑀
𝑀
𝑀

(43)

Hence, if the 𝑀 points are uniformly distributed with respect to cos 𝜃 so that | cos 𝜃| = 1/2,
then
√︃
√︃
1
(44)
𝜎𝜃2′ 𝜎𝜃2′′ ≥
2
Multiplying by ℏ gives the standard position/momentum form
Δ𝑥Δ𝑝 ≥
of the Uncertainty Principle.

24

1
ℏ
2

(45)


