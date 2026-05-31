# Runtime Flows · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md). The load-bearing journeys,
end to end. Each is driven by `DomainEvent`s and gated where the corpus says it must be.

## F1 — Intake → Event instantiation (catalog generates runtime)

```mermaid
sequenceDiagram
  participant L as Lead/Inquiry
  participant ACQ as Acquisition
  participant COM as Commercial
  participant SYNC as Control-plane Sync
  participant EVD as Event Design
  L->>ACQ: inbound (T01) → qualify (T02)
  ACQ->>COM: LeadWon → create Engagement
  COM->>COM: Contract + Budget + Pod (GATE_engagement_active)
  COM-->>EVD: EngagementActive
  EVD->>SYNC: request scaffold (ServiceTier × type)
  SYNC->>EVD: instantiate Process/Task/AICapability from atom catalog
  SYNC->>EVD: write atom_realizations (15 HUMAN = mandatory)
  Note over EVD: coverage gate blocks confirm if HUMAN atoms unrealized
```

## F2 — AI guardrail (nothing reaches the customer un-reviewed)

```mermaid
sequenceDiagram
  participant M as Module
  participant AIG as AI Gateway
  participant CD as Human (CD/planner)
  participant OUT as Artifact (Concept/Message/Signal)
  M->>AIG: request capability (e.g. moodboard draft T13)
  AIG->>AIG: Invocation (logged, provenance)
  AIG-->>CD: Suggestion (confidence, rationale) [GATE_ai_outward]
  CD->>AIG: HumanReview: accept / edit / reject
  alt accepted or edited
    AIG->>OUT: create/update domain object
  else rejected
    AIG-->>M: discarded (audit retained)
  end
  Note over AIG,CD: HUMAN-quadrant atoms skip AIG entirely
```

## F3 — Governance-bound enrichment (consent at the edge, not inherited)

```mermaid
sequenceDiagram
  participant PAR as Parties & Consent
  participant AIG as AI Gateway
  participant DB as Postgres (trigger)
  PAR->>AIG: enrich/infer (T03/T04/T05) on a household with a minor
  AIG-->>PAR: Suggestion (ProfileSignal candidate)
  PAR->>DB: write atom_realization + ProfileSignal
  DB-->>PAR: REJECT unless consent_id + lawful_basis present (GATE_atom_consent)
  Note over PAR,DB: scraped/inferred on minors requires guardian Consent + SourcePolicy
```

## F4 — Confirmation saga (cross-aggregate gate)

```mermaid
sequenceDiagram
  participant DEV as DomainEvent
  participant PC as ConfirmationProcess
  participant EVD as Event
  DEV->>PC: BudgetFunded / VenueSecured / PermitGranted / ConceptApproved
  PC->>PC: evaluate GATE_event_confirm
  alt all satisfied
    PC->>EVD: transition → confirmed (StateTransition)
  else missing
    PC-->>EVD: stay; raise Alert (attention matrix)
  end
```

## F5 — Day-of contingency (hostess-shielded)

```mermaid
sequenceDiagram
  participant WW as WeatherWatch
  participant RC as RainCallProcess
  participant P as Planner-on-ground
  participant H as Host
  WW->>RC: EnvThresholdBreached (wind/precip)
  RC->>RC: select pre-named Contingency branch
  RC->>P: execute (move indoors / tent); decision-rights owner ≠ host
  RC--xH: host NOT on the escalation list (don't-tell-hostess tier)
  Note over RC,H: recovery invisible; Incident logged for post-mortem
```

## F6 — Memory pipeline (same-night album race)

```mermaid
sequenceDiagram
  participant CAM as Capture
  participant MED as Media Service
  participant CD as CD (heroes)
  participant GF as GuestFamily
  CAM->>MED: frames (event ends)
  MED->>MED: cull (T63, AUTO) → editorial select (T64)
  MED->>CD: hero candidates → CD picks/retouch (T64/T65)
  MED->>GF: per-family album link (T66/T67) before the threads wake
```

## F7 — Merge import (Git atoms → runtime masters)

```mermaid
sequenceDiagram
  participant GIT as Git (atoms/policies)
  participant SYNC as Control-plane Sync
  participant DB as Postgres masters
  GIT->>SYNC: catalog change (merge-ledger.yaml)
  SYNC->>DB: upsert atoms/outcomes (idempotent on code,version)
  SYNC->>DB: refresh CheckDefinitions for G3/HUMAN/AUG-HITL atoms
  Note over SYNC,DB: one-way; instances pin atom_version; new version via ChangeOrder
```

Conformance & drift validators run on every import (and in CI) — see
[`deployment-and-ops.md`](./deployment-and-ops.md).
