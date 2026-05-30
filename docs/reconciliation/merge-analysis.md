# Merge Analysis — Interfacing the Collective Old vs New Data Shapes

**Question:** how do we interface the **old** data shapes (the Unspun corpus —
`../spec`, `../data-model`, `../graph`) with the **new** data shapes (the Fête model —
[`fete-unifying-model.md`](./fete-unifying-model.md), `fete-graph.json`)?
**Inputs:** [`crosswalk.yaml`](./crosswalk.yaml), [`ADR-0001`](../decisions/ADR-0001-system-data-substrate.md).
**Output:** the recommended interface, the bridge schema, and the conflicts to resolve.
This is analysis — it proposes shape changes; it does not yet apply them.

---

## 1. The two collectives, in one inventory

| | **OLD — Unspun (noun / object)** | **NEW — Fête (verb / process)** |
|---|---|---|
| Core unit | Entity record (161) — `id, context, archetype, fields, state, relations` | Atom (78) — `Tnn: arc, phase, ws, skill, quadrant, serves[R], benchmark, failure_mode, subcomponents[], adjacency[]` |
| Anchors | Aggregate roots (Household/Engagement/Event); ExperienceStandard | Brand promise (Layer 0) + Outcomes R1–R15 |
| Grouping axes | context (12) × archetype (8) | backbone (Arc→Phase→Atom) × axes (skill, quadrant, lens G1–G7, asset) |
| Lifecycle | per-entity state machines (`event_state`, …) + dynamic layer | none per atom (atoms are definitions, not stateful) |
| Behavior layer | Process / DomainEvent / Check / AICapability / Suggestion / HumanReview | the atoms **are** the behavior; quadrant says who/AI runs them |
| Quality | ExperienceStandard + ExceptionalityScore (event-level) | benchmark + failure-mode (**per atom**) |
| Identity | prefixed ULIDs (`evt_01J…`) — instances | stable codes (`T35`, `R5`) — types |
| Persistence | transactional (Postgres data plane) | definitional (Git control plane) |
| Machine form | `kg.json` (191 nodes) | `fete-graph.json` (141 nodes) |

## 2. The decisive structural fact: **types vs instances, across two planes**

The two collectives barely *overlap* — they *stack*. Read column "Identity/Persistence":

- **Fête shapes are design-time *definitions / templates*** — "this is how an Author-ROS
  task should go, this is the 5-star bar, this is its failure mode." They are
  control-plane, versioned, low-write (ADR-0001's Git plane).
- **Unspun shapes are run-time *records / instances*** — "this *specific* event's ROS task,
  in state `in_progress`, owned by `tmb_…`." They are data-plane, transactional.

So **"merge" is the wrong verb. The correct verb is *compose by reference*:** a Fête atom
is the **template**; an Unspun `Task`/`Process`/`AICapability` is the **instance** that
*realizes* it. The interface is a foreign key, not a flattening.

```mermaid
flowchart LR
  subgraph CP[Control plane · Git · DEFINITIONS]
    AT[Fête atoms T01-T78<br/>benchmark · failure-mode · quadrant]
    OUT[Outcomes R1-R15]
    AT -->|serves| OUT
  end
  subgraph DP[Data plane · Postgres · INSTANCES]
    PR[Process / Task]
    AIC[AICapability]
    EVT[(Event / entities)]
    PR -->|reads/writes| EVT
  end
  PR -.realizes (atom_code).-> AT
  AIC -.realizes (atom_code).-> AT
  EXC[ExceptionalityScore / Moment] -.measured against.-> OUT
  classDef d fill:#efe,stroke:#8a8; classDef m fill:#eef,stroke:#88a;
  class PR,AIC,EVT,EXC d; class AT,OUT m;
```

This also closes the ADR-0001 loop: the Fête atom catalog *is* control-plane master data;
the runtime records *are* the data plane. The merge analysis and the substrate decision
agree.

## 3. Shape-by-shape interface verdict

| OLD shape | NEW shape | Relationship | Interface mechanism | Conflict |
|---|---|---|---|---|
| `Task` / `Process` | Atom `Tnn` | template:instance (1 atom : n instances) | add `atom_code` FK on runtime row | grain — fine |
| `AICapability` (`autonomy`, `requires_human_review`) | Atom `quadrant` | 1:1 by atom | `quadrant` enum + map to `autonomy`/`GATE_ai_outward` | quadrant tally drift (§5) |
| `Role` / `Tastemaker` | Atom `skill` (TST/CAR/…) | n:m | `skill` tag on atom → role competency map | none |
| `ExperienceStandard.dimensions` / `Moment` | Outcome `R1–R15` | n:m | new `outcomes` master; link dimensions & `Moment.serves_outcome` | partial |
| `ExceptionalityScore` | Benchmark (per atom) | aggregation | event score rolls up atom benchmarks | grain: event vs atom |
| `Risk` / `Incident` / `CheckDefinition` | Atom `failure_mode` | template:instance | `failure_mode` seeds a `Risk`/`CheckDefinition` template | **gap (old)** |
| `Checklist` items / task substeps | Atom `subcomponents[]` | 1:n | import subcomponents as checklist template | partial |
| `Dependency` | Atom `adjacency[]` | 1:1 edges | adjacency → dependency edges between instances | none |
| `engagement_state`/`event_state`; `Cadence` | Arc / Phase | classification | `phase_code` tag on `Process`; arc→lifecycle map | partial |
| `VendorPerformance`/`Roster`/`ClientProfile`/`Referral`/`Playbook` | Asset (G5) | already entities | atom `asset` tag points at the entity it compounds | none |
| planes / human-fronted principle | Membrane (G1) | implicit→explicit | add `stage_boh` flag (Moment/Task) | **gap (old)** |
| `Beat`/`Touchpoint.channel` | Sensory cue (T38), child-flow (T36) | partial | **new objects** `SensoryCue`, `ChildFlowStation` | **gap (old)** |
| Consent/Retention/MinorProtection/dynamic layer | — | — | Fête inherits these *for free* by running on the data plane | **gap (new)** |

## 4. Interface options

| Option | What | Pro | Con | Verdict |
|---|---|---|---|---|
| **A — Crosswalk only** | keep both graphs separate, join via `crosswalk.yaml` at analysis time | zero schema change | no runtime link; benchmarks/quadrants never reach execution | too loose |
| **B — Template-import + reference bridge** | import Fête atoms/outcomes as control-plane **master tables**; runtime `Process/Task/AICapability` carry `atom_code` | preserves both planes; closes old gaps (benchmark/failure-mode become first-class); one-way sync | adds ~2 tables + a few columns | **recommended** |
| **C — Full structural merge** | flatten atoms into entity tables (or vice versa) | one schema | destroys type/instance + plane separation; conflates verbs and nouns; unversionable | reject |
| **D — Federated two-graph** | two independent stores, query-time federation | full autonomy | duplicate identity, no integrity, drift (we already saw drift in §5) | reject |

**Recommendation: B.** It is the only option that respects ADR-0001 (atoms = control
plane, instances = data plane), closes the `gap_in_unspun` items by making
benchmark/failure-mode/quadrant first-class, and leaves Fête authored in Git while runtime
lives in Postgres.

## 5. The bridge schema (Option B, concrete)

**New control-plane master atoms (catalog YAML shape):**

```yaml
Outcome:   {pk: out_, arch: master, ctx: c5, nat: [code],          # R1..R15
   f: {code: txt, label: txt, promise_ref: txt}}
Atom:      {pk: atom_, arch: master, ctx: c10, mix: [+versioned],  # T01..T78 (process templates)
   nat: [code, version],
   f: {code: txt, name: txt, arc: txt, phase_code: txt, workstream: int, skill: txt,
       quadrant: automation_quadrant, serves_outcome_codes: "[txt]", asset_tags: "[txt]",
       benchmark: txt, failure_mode: txt, subcomponents: jsonb, stage_boh: txt}}
```

**Bridge columns on existing runtime tables (SQL):**

```sql
CREATE TYPE automation_quadrant AS ENUM ('auto','aug_hitl','human_ai','human');
ALTER TABLE tasks            ADD COLUMN atom_code text REFERENCES atoms(code);
ALTER TABLE processes        ADD COLUMN phase_code text, ADD COLUMN atom_codes text[];
ALTER TABLE ai_capabilities  ADD COLUMN atom_code text REFERENCES atoms(code),
                             ADD COLUMN quadrant automation_quadrant;
ALTER TABLE check_definitions ADD COLUMN atom_code text REFERENCES atoms(code);   -- failure_mode -> check
ALTER TABLE moments          ADD COLUMN serves_outcome_code text REFERENCES outcomes(code),
                             ADD COLUMN stage_boh text;
```

**New objects to close the structural gaps (G3/G4 in crosswalk):** `SensoryCue` (c6,
member of Beat), `ChildFlowStation` (c6) — small additions; and `stage_boh` makes the
membrane queryable.

**KG interface:** add `realizes` edges (`Task`→`atom`) and reuse `serves`
(`atom`→`outcome`) so `kg.json` (nouns) and `fete-graph.json` (verbs) become **one
queryable graph** joined on `atom_code` — no node duplication.

## 6. Identity & sync contract

- **Fête codes are stable natural keys** (`T35`, `R5`); runtime rows keep prefixed ULIDs
  and carry `atom_code` as the join. Codes never become primary keys of instances.
- **Sync is one-way:** control plane (Git) → import → data plane. Atoms are *authored and
  versioned in Git*, imported idempotently keyed on `(code, version)`. Runtime never edits
  an atom definition; it references it. (Exactly ADR-0001's plane discipline.)
- **Provenance:** an imported atom row records its source commit; an instance records the
  `atom_code@version` it realized, so "which template produced this task" is auditable.

## 7. Conflicts to resolve before/while interfacing

1. **Quadrant drift (within Fête).** Atlas roll-up (22/28/13/15) ≠ per-atom tags
   (26/27/10/15). **Adopt per-atom as source of truth**; the `Atom.quadrant` column imports
   the decomposition value; refresh the Atlas summary. (crosswalk `C1`.)
2. **Grain.** 78 atoms vs 161 entities is *expected* — verb plane vs noun plane. Do **not**
   force 1:1; an atom realizes across several entities (e.g. T35 ROS touches
   `Program`/`Beat`/`Task`/`Dependency`). Map via `atom_code` on the *primary* runtime row
   + adjacency for the rest.
3. **Quality grain.** Benchmark is per-atom (new), ExceptionalityScore is per-event (old);
   interface = event score **aggregates** the realized atoms' benchmark verdicts (each
   becomes a `CheckResult` against the atom's benchmark, rolled up — ties to Ethos T2).
4. **Gaps, both ways (now actionable):**
   - *Old gains from new:* per-atom benchmark/failure-mode, explicit membrane (`stage_boh`),
     sensory-cue & child-flow objects, named-human/register richness on WS9 atoms.
   - *New gains from old (for free):* consent, minor protection, retention, discretion-as-
     policy, the dynamic layer — because atoms now *run on* the governed data plane.

## 8. Recommended interface (summary)

> **Compose, don't merge.** Import the Fête atom + outcome catalog as **control-plane
> master data**; reference it from runtime `Process/Task/AICapability` via `atom_code`;
> map `quadrant` onto the AI-Enablement layer; aggregate per-atom benchmarks into
> `ExceptionalityScore`; unify the two graphs on `atom_code`. The verb-graph templates the
> work; the noun-graph records and governs it.

**Minimal build to stand up the interface (no sequencing/estimates):**
`automation_quadrant` enum · `atoms` + `outcomes` master tables · `atom_code`/`quadrant`/
`phase_code`/`serves_outcome_code`/`stage_boh` bridge columns · `SensoryCue` +
`ChildFlowStation` objects · an idempotent Git→DB atom importer · `realizes` edges in the
unified graph.

**Open decisions for you:** (a) confirm Option B over A; (b) confirm per-atom quadrant as
source of truth; (c) whether benchmark/failure-mode should also generate runtime
`CheckDefinition`s now or later. On your word, I'll apply the bridge to the catalog + SQL
and emit the unified graph.

---

# Addendum B — Partner Review & Amendments

*Reviewed as the engagement partner. Verdict first, then the corrections that are
load-bearing before anyone builds this. The associate work is directionally right; it is
not yet safe to implement as written. Four of the amendments are blocking.*

## B.0 Verdict

**Endorsed, with amendments.** The spine of this analysis is correct and I would defend it
to the client: *compose, don't merge*; Option **B** as the target; **per-atom quadrant** as
source of truth; the two-graph join. Keep all of that. But the document makes one **framing
error** that propagates, one **schema decision that is under-modeled and will lose data**,
and it **defers two questions that are not deferrable** because they are the whole value and
the whole risk. Amendments B1–B4 are blocking; B5–B7 are required before scale; B8 is the
sequencing correction. I also add the strategic "so what," which the analysis omits entirely
— a partner does not ship a data-architecture memo with no line to value.

## B1 — Framing error: Unspun is **not** "the data plane." It spans both planes. *(blocking)*

The analysis says "Fête = control plane, Unspun = data plane." That is too clean and it is
wrong. Unspun **already has a control plane** — `Playbook`, `AICapability`, `ServiceTier`,
`ExperienceStandard`, `Process` *definitions*, `StateTransition` are all master/policy
(control‑plane) entities; only the roots/members/signals are data‑plane instances.

So the true interface is **two control‑plane vocabularies meeting first**, and the runtime
instances sitting *below both*:

```
Fête atom  ⇄  Unspun control-plane master (Playbook / AICapability / Process-definition)
                         │  instantiates
                         ▼
            Unspun data-plane instance (Process-instance / Task / records)
```

**Amendment:** restate the seam as *Fête atom ↔ Unspun control‑plane master*, which **then**
instantiates to runtime. This matters because §2's picture implies atoms reference *instances*
directly; they should reference (and largely **be reconciled with**) Unspun's **definition**
objects. Several atoms won't create new masters at all — they *are* existing Unspun
`AICapability`/`Playbook` masters under another name. The first reconciliation pass is
therefore a **de‑duplication of two control‑plane vocabularies**, not an import of one into
the other.

## B2 — Under-modeled schema: a single `atom_code` column is lossy. Use a realization table. *(blocking)*

§5 hangs `atom_code` on "the primary runtime row" and waves at adjacency for the rest. That
loses the truth that one atom realizes across a **cluster** of entities (T35 "author ROS" →
`Program` + `Beat` + `Task` + `Dependency`). A nullable column on one `Task` cannot answer
"was T35 delivered, and where does it live?"

**Amendment:** replace the scattered `atom_code` columns with a first‑class link:

```sql
CREATE TABLE atom_realizations (        -- which runtime objects realize which atom, per event
  id text PRIMARY KEY, atom_code text NOT NULL REFERENCES atoms(code),
  atom_version int NOT NULL,
  event_id text NOT NULL, entity_id text NOT NULL, entity_type text NOT NULL,
  role text,                            -- primary | supporting
  status text NOT NULL DEFAULT 'planned',  -- planned | realized | skipped | failed
  created_at timestamptz NOT NULL DEFAULT now());
```

Keep a convenience `atom_code` on `tasks`/`ai_capabilities` for the *primary* binding, but
the realization table is the system of record for coverage and traceability. This is also
what makes B3 possible.

## B3 — The atom catalog must **generate**, not just **label**. *(blocking — this is the value)*

The analysis treats `atom_code` as a tag you attach to runtime rows *after* they exist. That
inverts the leverage. The point of a versioned atom catalog is that it **instantiates the
runtime scaffold for each event** — the `Process`/`Task`/required‑`AICapability` graph is
*generated from* the atoms applicable to that event's service tier and type (this is Fête's
own T25 "project instantiation," and Unspun's `Playbook`→`Task` instantiation). Runtime then
reports **conformance** back through `atom_realizations`.

**Amendment:** the interface is **bidirectional**: *catalog → instantiates → runtime → reports
coverage → catalog*. Add a **coverage guarantee**: for every `Event`, the required atom set
(by `ServiceTier` × event type) must be realized, and the **15 HUMAN brand‑critical atoms are
mandatory** — an event that cannot show realization of them is non‑conformant and blocks the
`Event→confirmed`/`reviewed` gates. Without this, the bridge is decorative.

## B4 — Stop deferring the check-selection rule. Decide it. *(blocking — this is the risk)*

§8(c) lists "generate `CheckDefinition`s now or later" as an open question. It is not
optional — runtime quality enforcement is the entire reason to carry benchmarks. But the
naïve reading (78 atoms → 78 checks × every instance) is also wrong; it would drown the team.

**Amendment — the selection rule (not the timing):** an atom's benchmark becomes a runtime
`CheckDefinition` **iff** it is brand‑destroying/irreversible (lens **G3**) **or** in the
**HUMAN / AUG‑HITL** quadrant. Everything else is logged, not gated. This focuses checks on
the ~20 atoms that actually carry brand risk, aligns with Ethos T2 (depth scales with
consequence), and makes the ExceptionalityScore roll‑up tractable.

## B5 — The quadrant→AI mapping is asserted, not specified — and it conflates two quadrants. *(pre-scale)*

§3 maps quadrant onto the AI layer in one breath, but **HUMAN‑AI ≠ AUG‑HITL** and they bind to
different Unspun constructs. Specify it, with the invariant:

| Fête quadrant | Unspun binding | Invariant |
|---|---|---|
| **AUTO** | `AICapability` autonomous; may emit `GuardedAction` within envelope | bounded envelope only; never client‑facing un‑gated |
| **AUG-HITL** | `AICapability` → `Suggestion` → **`HumanReview`** (async draft/approve) | no outward artifact without accepted review (`GATE_ai_outward`) |
| **HUMAN-AI** | `Agent` as *scaffold/tool* to a human acting **live**; no `Suggestion` gate needed | agent output is private to the operator, never the customer |
| **HUMAN** | **no** `AICapability` in the customer‑perceived loop | AI may prep BoH only; `stage_boh='stage'` ⇒ AI prohibited |

**Amendment:** add this table to §3 and enforce the HUMAN‑row invariant in `PolicyGuardrail`.

## B6 — "Governance for free" is false precisely where it matters most. *(pre-scale — compliance)*

§7.4 claims the new atoms inherit consent/minor‑protection "for free." For most atoms, fine.
But the highest‑risk atoms — **T03 enrich, T04 aesthetic inference, T05 discretion detection**
(and any scraping) — are exactly the ones touching a **minor's** and a private client's PII.
Inheritance is not automatic; it requires the realization edge to **bind** to `Consent`,
`LawfulBasis`, `SourcePolicy`, and `MinorProtection`.

**Amendment:** mark T03–T05 (and any `capture_method ∈ {inferred, enriched, scraped}` atom)
as **governance‑bound**: their `atom_realizations` row must carry a valid `consent_id` +
`lawful_basis` or the realization is refused. This is a hard gate, not an inheritance.

## B7 — Version-pinning policy is missing. *(pre-scale — operational hazard)*

Atoms are versioned; events are long‑lived. State the binding rule or you'll get silent
retro‑changes mid‑build.

**Amendment:** an event **pins** the atom catalog version at instantiation
(`atom_realizations.atom_version`). Later catalog bumps do **not** retro‑apply; adopting a new
atom version into a live event is a `ChangeOrder`. The unified graph is a **regenerated
projection** (Ethos), not a third source of truth — say so to prevent a new drift source.

## B8 — A and B are a path, not a choice; and add the validation you forgot. *(sequencing)*

§4 frames A (crosswalk‑only) vs B (bridge) as either/or. They aren't. **A already exists**
(`crosswalk.yaml`), is reversible, and is the analysis layer; **B is the runtime target**.
Run A now, commit to B, and **stage the bridge by G3 risk** (governance‑bound + brand‑critical
atoms first). And the memo ships no way to know the interface works — add the validation, per
Ethos T2:
- **Conformance:** % of required atoms realized per event (target 100% of the 15 HUMAN).
- **Drift detector:** atom catalog (Git) vs realized runtime — flags atoms never realized
  (dead templates) and runtime work with no atom (un‑templated drift).
- **Reversibility:** the bridge is additive (new tables/columns/edges); it can be dropped
  without touching the existing keystone or Fête sources.

## B9 — The strategic "so what" (the line to value the memo omits)

A data‑architecture memo with no line to the business is half a memo. Here it is:

**The atom catalog is the codified taste‑and‑judgment IP — it is the moat, and this interface
is the mechanism that lets that IP scale.** Keeping atoms in the versioned control plane,
*generating* every event from them (B3), *governing* the risky ones (B6), and *measuring*
conformance (B8) is precisely what turns "one brilliant CD's taste" into a repeatable,
auditable, compounding system — the 3× throughput thesis from the Atlas, expressed in
schema. The 15 HUMAN atoms stay human **by policy** (B5); everything around them is templated
and governed. That is the whole business model, encoded at the interface. The merge analysis
should be read as an **operating‑model decision**, not a plumbing decision.

## B10 — Amended minimal build

`automation_quadrant` enum · `atoms` + `outcomes` masters **reconciled against existing
`Playbook`/`AICapability` first (B1)** · **`atom_realizations` link table (B2)** · catalog→
runtime **instantiator + coverage gate on the 15 HUMAN atoms (B3)** · **benchmark→
`CheckDefinition` for G3/HUMAN/AUG‑HITL atoms only (B4)** · quadrant→AI binding table + HUMAN
invariant (B5) · **governance‑bound flag + hard consent gate on T03–T05 (B6)** ·
version‑pinning via `ChangeOrder` (B7) · conformance + drift validators (B8). Convenience
`atom_code` columns are secondary to the realization table.

**Net:** proceed with B — but build B1, B2, B3, B4 first; they are the difference between an
interface that *governs and scales the business* and one that merely *annotates rows*.
