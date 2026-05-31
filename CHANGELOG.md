# Changelog

All notable changes to the Unspun data-architecture corpus are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions track
[`docs/VERSION`](./docs/VERSION) — the single source of truth that every generator stamps
into its output. Bumping the corpus version = edit `docs/VERSION`, regenerate, add a section
here.

## [Unreleased]
- Open ADRs flagged in `docs/design/`: event-bus, LLM provider/isolation, media store,
  vector store, auth/identity provider.
- Optional CI workflow (`docs/design/deployment-and-ops.md` §3): YAML parse, generator
  drift-check, Mermaid lint, prefix-uniqueness, 78-atom/15-HUMAN coverage.

## [2.1] — 2026-05-31
### Added
- **System design docs** (`docs/design/`): SDD/HLD, C4 views, components, runtime flows,
  API & events, NFRs, security & privacy, deployment & ops.
- **Data-architecture README** (`docs/README.md`) — versioned front door + corpus map.
- **`docs/VERSION`** — single source of truth for the corpus version; all generators read
  and stamp it.
- **Master lexicon** (`docs/graph/lexicon.md` + `build_lexicon.py`) — index of every name
  (~348 terms) + ID-prefix registry.
- **Atomics KG** (`docs/reconciliation/atomics-kg.{md,json}`) — the 78 atoms and where they
  map, per arc.
- **`GuestFamily`** model — a guest is never singular (parents, children+ages, contacts,
  mailing address, special requests, satisfaction + follow-ups).
### Changed
- Knowledge graph + system tree to v2.1; all reconciliation/graph artifacts version-stamped.
- `GuestParty` → `GuestFamily` across keystone, glossary, catalog, and SQL.
### Fixed
- Mermaid render error: split multi-`classDef`-on-one-line in `knowledge-graph.md` (View 8)
  and `merge-analysis.md`.

## [2.0] — 2026-05-31
### Added
- **Fête merge** (`docs/reconciliation/`): unifying model (FUM), crosswalk, merge analysis
  (+ Addendum B partner review), merge procedure, the 78-atom merge ledger + map, the
  unified graph, and the preserved Fête sources.
- **Merge bridge schema** (`catalog/07-merge-bridge.yaml`, `sql/03-merge-bridge.sql`):
  `Atom`/`Outcome` masters, `AtomRealization`, `SensoryCue`, `ChildFlowStation`,
  `automation_quadrant` enum, bridge columns, and the `GATE_atom_consent` trigger — additive
  and reversible.
- Knowledge graph + tree updated to v2.0 (merge-bridge nodes + View 8).
### Notes
- Merge is *compose-by-reference* (atoms template runtime via `atom_code`), not a flatten —
  preserving the two-plane separation (ADR-0001).

## [1.0] — 2026-05-31
### Added
- **Domain keystone** (`docs/spec/domain-keystone.md`) + glossary — the object model:
  12 contexts × 8 archetypes, identity rules, relationships, state vocabularies.
- **Building Ethos** (`docs/spec/building-ethos.md`) — the six construction tenets.
- **Reviews**: MECE structural review; gaps & clarity review (+ Addendum A, Brian Chesky).
- **Data model** (`docs/data-model/`): atomic YAML catalog (00–06) → Postgres reference
  schema (00–02), ~161 entities.
- **ADR-0001** — substrate decision: Git control plane + event-sourced Postgres + ticketing.
- **Knowledge graph + system tree** (`docs/graph/`) — generated projections of the corpus.

[Unreleased]: https://github.com/Shane-Burns-Dot-US/Unspun/compare/v2.1...HEAD
[2.1]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v2.1
[2.0]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v2.0
[1.0]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v1.0
