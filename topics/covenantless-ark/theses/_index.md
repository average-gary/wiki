---
title: covenantless-ark — theses
type: theses-index
---

# covenantless-ark — theses

Testable claims surfaced during research. Each is a candidate for a `/wiki:research --mode thesis` follow-up.

## Suggested theses (not yet investigated)

1. **clArk's interactivity limitation and its griefing/DoS surface are the same property, not two.** Roose's "the bad actions of certain users will affect all other users" implies the synchronous n-of-n round is simultaneously the liveness burden and the attack surface. A thesis run would test whether any mitigation reduces one without the other.
2. **clArk cannot safely admit pure receivers into a round; all real send-to-others must go out-of-round.** Direct consequence of the receiver-DoS asymmetry (receivers have nothing at stake). Verdict question: do Delegation/Intents or any covenantless trick close this without CTV?
   - **Follow-up investigated** → [[../../ark-boarding-sv2-mining/theses/ark-boarding-sv2-mining|ark-boarding-sv2-mining thesis]] applied this to mining payouts (miners as pure receivers). Verdict: Partially Supported — the pure-receiver DoS is *mitigable* (miner stake + identity + bans, proxy/JDC-held keys, delegated renewal) but not dismissible, and n-of-n still doesn't scale to a full pool. See [[../../ark-boarding-sv2-mining/wiki/concepts/pure-receiver-and-liveness|pure-receiver / liveness]].
3. **The covenantless exit-data storage burden is a materially larger self-custody risk than covenant-Ark's.** Lose the presigned exit chain → lose unilateral exit. A thesis would quantify real-world data-loss risk and compare to CTV variants that need no client-side exit data.
4. **A mass unilateral exit is economically infeasible for small VTXOs under realistic fee conditions.** Combines O(log t) exit cost, per-tx CPFP, the exit-window race before `T_exp`, and dust economics. A thesis would model exit feasibility vs VTXO size and mempool congestion.
5. **The two clArk implementations (bark hash-locks vs arkd connectors) have materially different forfeit-atomicity security properties.** A thesis would compare the hash-lock/preimage round-forfeit design against the connector design for edge cases (round reorg, preimage leakage, connector-tree malleability).
6. **"Ark v2" is a marketing frame, not a protocol release; the real evolution is incremental (tree-signing, OOR, delegation) plus a covenant horizon.** A thesis would test whether any single change constitutes a v2 or whether it is purely cumulative.
