# ADR‑0001 — Substrate for system data management (Git / Jira vs build)

**Status:** Accepted (recommendation)
**Question:** Can Git + Jira serve as the infrastructure/backbone for system data
management, or should we build a bespoke datastore from scratch?
**Relates to:** [`../data-model/`](../data-model/), [`../spec/building-ethos.md`](../spec/building-ethos.md),
the MECE archetype axis ([`../spec/mece-review.md`](../spec/mece-review.md)).

---

## Decision (TL;DR)

**Hybrid, archetype‑driven — not either/or, and not "from scratch."**

- **Git = control plane.** Backbone for *definitional* data: the catalog, schemas,
  policies, standards, templates, the creative library (motifs/concepts), state‑transition
  and check definitions. Versioned, PR‑reviewed, deterministic. *We already do this; keep it.*
- **Postgres (the existing model) = system of record** for *business* data:
  relational, high‑write, queryable, PII, customer/vendor‑facing. Ideally **event‑sourced**
  to preserve the immutable‑log property that makes Git feel attractive. This is the boring,
  correct choice — not a from‑scratch build.
- **Jira / ticketing = optional internal workflow surface** for team operations
  (tasks, approvals, incidents), driven by domain events. **Never the system of record.**
  Keep it swappable.

## Reframe: two questions hide in "system data management"

1. Managing the system's own **definitions/config** (schemas, playbooks, policies) →
   *control plane* → **Git is ideal.**
2. Managing the **business/customer data** the system processes (events, guests, money,
   media) → *data plane* → **needs a database.**

The instinct that "Git + tickets are great backbones" is **correct for (1)** and
**hostile for (2).** Proof: this repo's catalog and specs live in Git already, and that is
the right home for them.

## Why the instinct is sound (and how it generalizes)

Git's model — content‑addressed immutable history, deterministic hashes, small reviewable
commits, append‑only log, author/sign‑off provenance, human‑diffable + machine‑parseable —
is nearly a restatement of the **Building Ethos** (determinism, small steps, append‑only
audit/checks, two formats / one truth). That resonance is why it feels right.

The deeper pattern the instinct is reaching for is **an append‑only log with derived
projections** — i.e. **event sourcing**, which is exactly the `DomainEvent` dynamic layer.
Conclusion: *keep the instinct, change the implementation* — get Git‑like immutability
inside a governed datastore, without Git's weaknesses.

## Substrate by archetype (the classification answers the question)

| Archetype | Examples | Backbone | Fit |
|---|---|---|---|
| Master / Policy / Standard (versioned, low‑write, curated, review‑worthy) | catalog, playbooks, ExperienceStandard, PricingPlan, MessageTemplate, Motif/Concept library, StateTransition & CheckDefinition, PolicyGuardrail | **Git** (config‑as‑code) | strong |
| Signal / Record (append‑only) | DomainEvent, AuditEvent, CheckResult, Invocation | append‑only DB log / event stream (Git‑*like*) | strong |
| Root / Member / Party / Projection (relational, high‑write, queryable, **PII**, external‑facing) | Household, Person, Guest, RSVP, Booking, Payment, ProfileSignal, MediaGallery, EnvironmentForecast | **Postgres** | required |
| Operational workflow (tasks, approvals, queues, SLAs) | Task, Approval, ChangeOrder, Incident, Permit chase | **Jira/ticketing** as workflow surface | acceptable |

## Hard blockers — why Git/Jira cannot be the system of record for the data plane

These are disqualifiers, not preferences:

1. **Right‑to‑erasure on minors' PII.** Git history is immutable by design; you cannot
   truly delete. Holding children's personal data in a third‑party issue tracker is worse.
   Both collide with the consent / retention / `MinorProtection` model. **Decisive.**
2. **Row‑level access control.** "Second shooter sees only the call sheet + pin," client
   `DiscretionLevel`, guest‑facing surfaces — Git is all‑or‑nothing per repo; Jira is
   per‑project, not per‑row.
3. **Scale / concurrency / query.** Guests, passive signals, messages, forecasts are
   high‑write; "all May events with open permits" is a query. Git has no
   indexes/transactions; JQL won't carry relational reporting.
4. **External UX, cost, lock‑in.** Affluent clients will never touch Jira; per‑seat pricing
   for every vendor/guest is a non‑starter; modeling the domain as issues/sub‑tasks
   contorts it ("everything is a ticket" anti‑pattern).

## Alternatives considered

- **All‑Git (incl. business data, e.g. flat files / Dolt).** Rejected as system of record:
  erasure, access granularity, scale, external UX. *Dolt* ("Git for data": SQL DB with
  branch/merge/diff) is a genuine fit for **master/reference** tables (mergeable taste
  libraries, config) and worth a **pilot on the control‑plane edge** — but not for
  high‑write PII (maturity/scale, and it still doesn't solve erasure).
- **All‑Jira (domain as issues).** Rejected: issue tracker ≠ CRM/ERP; custom‑field sprawl,
  lock‑in, no relational reporting, no customer surface.
- **Roll everything from scratch.** Rejected as wasteful: Git already wins the control
  plane; a bespoke versioned‑config store would re‑implement Git poorly. Use Postgres for
  the data plane (not "scratch" — the standard choice).
- **Hybrid (chosen).** Git control plane + event‑sourced Postgres system of record +
  optional ticketing workflow surface, wired through the dynamic layer.

## Consequences

- **Integration is via the dynamic layer.** Domain events bridge the planes: a Git merge to
  a policy can emit an event; a DB event can open/transition a ticket; ticket transitions
  emit events back. One event vocabulary, three surfaces.
- **Governance lives with the DB**, where consent, retention, erasure, and row‑level access
  can actually be enforced — never in Git history or SaaS tickets.
- **Boring core, swappable edges.** Postgres + Git are durable bets; Jira (or any tracker)
  stays behind the event interface so it can be replaced without touching the record.
- **Re‑evaluate Dolt** for the master/reference subset once it's proven at our scale; it is
  the one option that could make the literal "Git as data backbone" intuition real for the
  parts where mergeable history is genuinely valuable.
