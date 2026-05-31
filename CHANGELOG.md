# Changelog

All notable changes to the Unspun data-architecture corpus are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions track
[`docs/VERSION`](./docs/VERSION) — the single source of truth that every generator stamps
into its output. Bumping the corpus version = edit `docs/VERSION`, regenerate, add a section
here. All work to date was produced on branch `claude/genetic-party-platform-spec-wzW28`
(PR [#1](https://github.com/Shane-Burns-Dot-US/Unspun/pull/1)).

## [Unreleased]
- Open ADRs flagged in `docs/design/`: event-bus, LLM provider/isolation, media store,
  vector store, auth/identity provider.
- Optional CI workflow (`docs/design/deployment-and-ops.md` §3): YAML parse, generator
  drift-check, Mermaid lint, prefix-uniqueness, 78-atom / 15-HUMAN coverage.
- Git release tags (`v1.0`/`v2.0`/`v2.1`) pending merge to `main` (so changelog links resolve).

## [2.1] — 2026-05-31
The "make it navigable, versioned, and buildable" pass.

### Added
- **System design docs** (`docs/design/`, 9 files): `README` index, `system-design` (SDD/HLD),
  `architecture-c4` (context/container/component), `components`, `runtime-flows` (7 sequences),
  `api-and-events` (+ canonical `DomainEvent` contract), `nfr`, `security-privacy` (STRIDE +
  enforcement points), `deployment-and-ops`.
- **Data-architecture README** (`docs/README.md`) — the versioned front door + full corpus map.
- **`docs/VERSION`** — single source of truth for the corpus version; `build_kg.py`,
  `build_lexicon.py`, `build_fete_graph.py`, `build_merge.py` all read and stamp it.
- **Master lexicon** (`docs/graph/lexicon.md` + `build_lexicon.py`) — index of every name
  (~348 terms: entities, logic, atoms, outcomes, backbone, axes, value types/enums) + the
  ID-prefix registry (no collisions).
- **Atomics KG** (`docs/reconciliation/atomics-kg.md` + `atomics-kg.json`) — the 78 atoms and
  where they map to the merged model, per arc, coloured by automation quadrant.
- **`GuestFamily`** model — a guest is never singular: parents, children + ages, contacts,
  mailing address, special requests, satisfaction score + follow-ups; `Guest` enriched
  (age, family, contact, special requests).
- **`CHANGELOG.md`** (this file).

### Changed
- Knowledge graph + system tree bumped to v2.1; all reconciliation + graph artifacts
  version-stamped from `docs/VERSION` (meta `version` in every generated json/yaml; version
  headers on the markdown).
- `GuestParty` → `GuestFamily` across keystone, glossary, catalog (04), and SQL (02).
- `merge-analysis.md` cross-linked to/from the architecture README.

### Fixed
- Mermaid render error: split multi-`classDef`-on-one-line in `knowledge-graph.md` (View 8)
  and `merge-analysis.md`; verified no multi-`classDef` lines remain corpus-wide.

## [2.0] — 2026-05-30
Reconcile and merge the **Fête** experience model (3 uploaded artifacts) with Unspun.

### Added
- **Fête unifying model** (`docs/reconciliation/fete-unifying-model.md`) — unifies the three
  Fête sources into one atom graph (FUM); the verb-graph ↔ noun-graph thesis.
- **Sources preserved** (`docs/reconciliation/sources/`) — atom decomposition, process atlas,
  experience-atlas deck.
- **Fête graph generator** (`build_fete_graph.py` + `fete-graph.json`) — 78 atoms with
  backbone + skill/quadrant/lens/asset axes (parsed deterministically from the decomposition).
- **`crosswalk.yaml`** — machine-readable, status-tagged Fête↔Unspun mapping.
- **Merge analysis** (`merge-analysis.md`) — interfacing the collective old vs new data
  shapes; recommends Option B (compose-by-reference), **+ Addendum B** (engagement-partner
  review & blocking amendments B1–B10).
- **Merge procedure** (`merge-procedure.md`) — the six-pass, gated procedure (RECONCILE ·
  BRIDGE · GENERATE/GOVERN/MEASURE).
- **Executed merge** (`build_merge.py` + `merge-ledger.yaml`, `merge-map.md`,
  `unified-graph.json`) — all 78 atoms mapped and kept (42 EXISTING · 24 DECOMPOSE ·
  12 NEW-MASTER), 6 governance-bound, joined to the noun-graph on `atom_code`.
- **Merge bridge schema** (`catalog/07-merge-bridge.yaml`, `sql/03-merge-bridge.sql`):
  `Atom`/`Outcome` masters, `AtomRealization` (version-pinned), `SensoryCue`,
  `ChildFlowStation`, `automation_quadrant` enum, bridge columns on existing tables, and the
  **`GATE_atom_consent`** trigger (consent/lawful-basis enforced, not inherited) — additive
  and reversible.

### Changed
- Knowledge graph + system tree updated to v2.0 (merge-bridge nodes, `GATE_atom_consent`,
  View 8, version numbers).

### Notes
- The merge *composes by reference* (atoms template runtime via `atom_code`), preserving the
  two-plane separation from ADR-0001 — not a flatten.
- Surfaced a within-Fête conflict (quadrant roll-up vs per-atom tags); adopted per-atom as
  source of truth.

## [1.0] — 2026-05-30
The founding corpus: domain, ethos, data model, substrate, and graph.

### Added
- **Domain keystone** (`docs/spec/domain-keystone.md`) + **glossary** — the object model:
  12 contexts × 8 archetypes, prefixed-ULID identity rules, relationships, aggregate
  composition, and canonical state vocabularies.
- **MECE review** (`docs/spec/mece-review.md`) — structural critique + the Context × Archetype
  recut and the 12-context taxonomy.
- **Gaps & clarity review** (`docs/spec/gaps-and-clarity-review.md`) — completeness/clarity QA;
  **+ Addendum A (Brian Chesky)** delight-centric capture (11-star, the four granular layers).
- **Building Ethos** (`docs/spec/building-ethos.md`) — six construction tenets (determinism,
  verify/ensemble, two formats + attention matrix, small steps, minimal layers,
  atoms→molecules); referenced from the keystone.
- **Data model** (`docs/data-model/`): atomic YAML catalog (`00-kernel` … `06-dynamic-ai`,
  incl. the dynamic + AI-enablement layers) composing into a Postgres reference schema
  (`00-extensions-enums`, `01-kernel-types`, `02-tables`) — ~161 entities, 37 enums,
  6 composite value types.
- **ADR-0001** (`docs/decisions/`) — substrate decision: Git control plane + event-sourced
  Postgres system of record + ticketing workflow surface (hybrid; rejects all-Git/all-Jira).
- **Knowledge graph + system tree** (`docs/graph/`: `build_kg.py`, `kg.json`,
  `knowledge-graph.md`, `system-tree.md`, `entities-by-context.md`) — generated projections
  of the corpus (8 Mermaid views; belief→domain→logic→architecture→corpus tree).

## Repository & process

- Local git repo with `origin` tracking on the feature branch; author `Claude`.
- PR [#1](https://github.com/Shane-Burns-Dot-US/Unspun/pull/1) opened from the branch (Claude
  Code UI); subscribed to its activity (CI + review comments) — no CI configured yet, no
  review threads.
- Pre-existing root `readme.md` (unrelated LLM-bias prompts) left untouched.

[Unreleased]: https://github.com/Shane-Burns-Dot-US/Unspun/compare/v2.1...HEAD
[2.1]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v2.1
[2.0]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v2.0
[1.0]: https://github.com/Shane-Burns-Dot-US/Unspun/releases/tag/v1.0
