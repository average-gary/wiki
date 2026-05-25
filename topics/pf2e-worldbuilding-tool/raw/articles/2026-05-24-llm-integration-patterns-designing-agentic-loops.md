---
title: "Designing agentic loops"
source: "https://simonwillison.net/2025/Sep/30/designing-agentic-loops/"
type: article
date_fetched: 2026-05-24
date_published: "2025-09-30"
tags: [llm, agents, tool-use, eval, security]
quality: 4
credibility: high
path: llm-integration-patterns
summary: "Simon Willison's framework for agent loops: tools-in-a-loop pattern, the read-act cycle, evals as success criteria, and risk bounding via containers and credential scoping. Direct guide for the GM-assistant agentic workflow."
---

# Designing Agentic Loops - Applied to PF2e GM Assistant

## Core Pattern
"An agentic loop is an LLM that runs tools in a loop to achieve a goal." Best for problems with **clear success criteria** and a **trial-and-error** structure.

## Tool Design
- Prefer **shell commands** + an `AGENTS.md` doc over heavy MCP wrappers
- LLMs infer usage well from terse descriptions + examples
- Document tool failure modes alongside success cases

## The Read-Act Loop
1. Agent reads current state / past tool outputs
2. Acts (calls tool)
3. Observes result
4. Refines next action
Repeat until success criterion met or iteration cap hit.

## Risk Bounding (the "YOLO mode" risks)
Three categories:
1. **Destructive commands**: agent deletes user's campaign notes
2. **Data exfiltration**: agent leaks home-brew canon
3. **Attack proxy**: agent's network access used against third parties

Mitigations:
- Run in isolated containers (Docker, Codespaces) - for our GM tool, sandboxed processes
- Use third-party infra over personal machine for risky tasks
- Restrict network to allow-listed hosts (Archives of Nethys, Pathfinder Wiki)

## Credential Scoping
- Test/staging-only credentials
- Budget caps on spending creds (he uses $5-capped Fly.io org)
- For GM tool: a dry-run mode that reports what would change without writing campaign DB

## Recommended Use Cases (translate to PF2e)
Simon's list: debugging, performance, dependency upgrades. Translation:
- "Debug this encounter" - agent loops through XP budget calc, monster lookup, terrain check, retries until balanced
- "Convert this 5e statblock to PF2e" - agent loops with rules-validation tool until output passes schema + level-budget checks
- "Fix this homebrew spell" - agent iterates until spell-balance heuristics pass

## Evals = Success Criteria
The loop only works if you can mechanically check success. For PF2e:
- Statblock validity: schema + level budget + AC/HP curves vs Bestiary norms
- Encounter balance: XP budget within +/- 10% of target
- Canon faithfulness: retrieved-fact recall on a held-out QA set

Without evals, "agent loops" are just unbounded model calls.
