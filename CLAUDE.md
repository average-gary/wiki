# Wiki Hub Conventions

This is the global LLM-wiki hub at `~/wiki/`. Conventions an agent must follow when working here.

## The hub is publishable

Treat `~/wiki/` as if it could be open-sourced at any time. Do not add content that the user cannot share publicly.

## Where company-proprietary research goes

**Not here.** Company-proprietary, employer-confidential, or repo-specific research lives in a repo-local `.wiki/` next to the code it documents — never in `~/wiki/topics/`.

This includes:
- Assessments of internal/private repos.
- Deployment plans tied to internal infra (DNS, account IDs, OIDC role names, KMS, internal SPEC numbers).
- ADR/SPEC commentary that isn't already public.
- Forward-looking gap analyses naming an employer or its products.
- Inventory candidates tracking employer-internal follow-ups.

## Pattern

1. Create `.wiki/` inside the relevant repo (e.g. `~/repos/<name>/.wiki/`).
2. Add a `config.md` with frontmatter `title`, `description`, `scope` (in-scope / out-of-scope), `created`.
3. Register it in `~/wiki/wikis.json` under `local_wikis` with a `sensitivity: "company-proprietary"` field if applicable.
4. Add a "Local Topics" entry to `~/wiki/_index.md` noting the path and sensitivity.
5. Decide commit posture per repo: gitignored if the repo is or may become public; committed if the repo is private and the wiki should travel with it.

## Default local on ambiguity

If unsure whether a topic belongs in the hub or a local repo wiki, **default local.** Promoting a local wiki to the hub later is trivial; redacting a hub topic after it's been published is not.

## Existing examples

- `~/repos/fGw/.wiki/` (compost-marketplace) — committed-with-repo, OSS-aligned community project.
- `~/repos/pool-v4-infra/.wiki/` (pool-v4-infra) — committed-with-repo, MARA-internal, sensitivity: company-proprietary. Moved from `~/wiki/topics/k8s-vs-alternatives-hybrid/` on 2026-05-22.

## When the user asks to research something employer-related

Default to creating or routing into `~/repos/<repo>/.wiki/` (or asking which local wiki to use) rather than into the hub. Confirm with the user before placing employer-named outputs anywhere under `~/wiki/topics/`.
