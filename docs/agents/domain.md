# Domain docs

How the engineering skills consume this repo's domain documentation. Single context.

## Before exploring, read these

- **[`GLOSSARY.md`](../../GLOSSARY.md)** at the repo root.
- **[`docs/adr/`](../adr/)**: read ADRs that touch the area you're about to work in.
- **[`docs/design.md`](../design.md)**: decisions table, network values, secrets flow, bootstrap sequence.

The `/domain-modeling` skill edits the glossary and records new ADRs (`docs/adr/NNNN-<slug>.md`, next free number). A changed decision gets a superseding ADR or an edit to the ADR body; git history is the revision log.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a proposal, a hypothesis, a commit message), use the term as defined in `GLOSSARY.md`. Don't drift to synonyms the glossary lists under _Avoid_.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0003 (miroir local-only), but worth reopening because…_
