# Architecture — C4 Views · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md).

## L1 — System Context

```mermaid
flowchart TB
  CLIENT[Client / Host<br/>affluent parent]:::p
  GUEST[Guest families<br/>parents + children]:::p
  VENDOR[Vendors<br/>florist, ceramicist, photographer…]:::p
  TEAM[Internal team<br/>CD/tastemaker, planner, pod]:::p
  SYS[Unspun Platform]:::s
  INTEG[External services<br/>SMS/email · e-sign · payments · weather · calendar · maps · LLM]:::e
  CLIENT -->|white-glove, no AI visible| SYS
  TEAM -->|internal app: CRM, ROS, taste| SYS
  VENDOR -->|scoped portal + cue sheets| SYS
  SYS -->|invitations, reminders, album| GUEST
  SYS <-->|governed integrations| INTEG
  classDef p fill:#eef,stroke:#88a
  classDef s fill:#efe,stroke:#8a8
  classDef e fill:#ffe,stroke:#aa6
```

The customer perceives **people and craft**; AI and back-of-house never cross the membrane.

## L2 — Containers

```mermaid
flowchart TB
  subgraph Surfaces
    INT[Internal Ops App<br/>mobile + web]:::c
    VP[Vendor Portal]:::c
    GE[Guest Engagement<br/>SMS/email service]:::c
    CX[Client Concierge surface<br/>thin, human-mediated]:::c
  end
  API[Core Domain API<br/>modular monolith · 12 contexts]:::c
  BUS[(Domain Event Log<br/>event-sourced spine)]:::q
  AIE[AI-Enablement Service<br/>capabilities · agents · guardrails · review queue]:::c
  MED[Media Service<br/>cull/select/retouch/deliver]:::c
  SYNC[Control-plane Sync<br/>Git atoms/policies → DB importer]:::c
  DB[(Postgres<br/>system of record + PII)]:::d
  OBJ[(Object store<br/>media)]:::d
  VEC[(Vector/Search<br/>taste + KG retrieval)]:::d
  GIT[(Git control plane<br/>catalog/atoms/policies)]:::m
  TKT[Ticketing<br/>workflow surface]:::w

  INT --> API
  VP --> API
  GE --> API
  CX --> API
  API <--> DB
  API --> BUS
  BUS --> AIE
  BUS --> MED
  BUS --> TKT
  AIE --> DB
  AIE <--> VEC
  MED --> OBJ
  GIT --> SYNC --> DB
  classDef c fill:#eef,stroke:#88a
  classDef d fill:#efe,stroke:#8a8
  classDef m fill:#dde,stroke:#88a
  classDef q fill:#ffe,stroke:#aa6
  classDef w fill:#fee,stroke:#a88
```

**Container responsibilities** are detailed in [`components.md`](./components.md).

## L3 — Components (Core Domain API)

One module per bounded context; the dynamic + AI layers are cross-cutting.

```mermaid
flowchart LR
  subgraph Core[Core Domain API]
    direction TB
    PAR[Parties & Consent]:::x
    TAS[Taste & Creative]:::x
    SUP[Supply / Vendors]:::x
    COM[Commercial & Finance]:::x
    EVD[Event Design]:::x
    PRD[Production & Logistics]:::x
    RSK[Risk & Resilience]:::x
    CR[Comms & Relationship]:::x
    ACQ[Acquisition]:::x
    OPS[Operations & Team]:::x
    SAF[Safety & Compliance]:::x
    PLT[Platform & Governance]:::x
    DYN[[Dynamic engine<br/>events · processes · checks]]:::y
    AIL[[AI gateway<br/>suggestion/review proxy]]:::y
  end
  DYN -. cuts across .- Core
  AIL -. cuts across .- Core
  classDef x fill:#eef,stroke:#88a
  classDef y fill:#ffe,stroke:#aa6
```

Each module owns its tables (the context's entities), publishes/consumes `DomainEvent`s, and
calls the **AI gateway** only — never an LLM directly — so the guardrail is unavoidable.

## Boundaries that matter

- **The membrane** (G1 stage/BoH): client/guest surfaces render only stage-grade artifacts;
  AI-Enablement, Media internals, ticketing, and Git never surface to the customer.
- **The plane boundary** (ADR-0001): `SYNC` is the *only* writer that turns Git definitions
  into DB masters; runtime never edits definitions.
- **The trust boundary** (security): Vendor Portal and Guest Engagement are externally exposed
  and row-scoped; the Internal Ops App is staff-only; see [`security-privacy.md`](./security-privacy.md).
