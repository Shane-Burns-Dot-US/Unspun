# System Design (SDD / HLD) · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md) and the
[Data Architecture](../README.md).

## 1. Purpose & scope

A turnkey, high-touch service that designs and delivers exceptional children's birthday
events for affluent households — abstracting AI out of the customer's experience while using
it internally to scale taste, reliability, delight, distribution, and operations.

**In scope:** the operating system behind the service — intake→design→build→day-of→afterglow,
the vendor network, the internal team app, guest engagement, the media/memory pipeline, the
compounding assets (referral, vendor graph, dossier), and the governed AI layer.
**Out of scope (design):** marketing site, finance back-office GL, HR. Integrated, not built.

## 2. Goals & non-goals

**Goals.** (G1) Every event is *staged for, not managed* — zero questions to the host on the
day. (G2) Exceptional = slightly-unique + reliably top-decile, *measured*. (G3) Consistency
engineered into objects (playbooks, checks, contingencies). (G4) The atom catalog (taste/
playbook IP) **scales** via generate-govern-measure. (G5) Compounding moats: referral, vendor
network, customer dossier. (G6) Hard governance for minors' PII, consent, discretion.

**Non-goals.** Not a self-serve consumer app; not exposing AI to clients; not a generic
event marketplace; not replacing the human host — amplifying them.

## 3. Constraints & assumptions

- **Substrate fixed by ADR-0001:** Git control plane · event-sourced Postgres data plane ·
  ticketing workflow surface. Atoms/policies authored in Git; instances/PII in Postgres.
- **AI is internal-only**, gated by `HumanReview` (`GATE_ai_outward`).
- **Minors are first-class protected subjects;** right-to-erasure must be honored ⇒ PII never
  in Git/SaaS-of-record (ADR-0001 §hard blockers).
- **Low concurrency, high consequence:** few hundred concurrent engagements, but event-day is
  live and unforgiving; the memory artifact (photos) outlives the event.
- Internal team operates a **mobile app** (CRM, tasks, calendar, ROS, taste arbitration).

## 4. Solution strategy (the big moves)

1. **Modular monolith, context-aligned.** One deployable core with a module per bounded
   context (12 + dynamic + AI). Extract a service only where scale or trust demands it
   (AI-Enablement, Guest-Engagement, Vendor-Portal, Media) — Ethos T4/T5 (small steps,
   minimal layers).
2. **Event-sourced spine.** `DomainEvent`s are the integration backbone; `Process`es (sagas)
   enforce cross-aggregate gates (Confirmation, RainCall, Cancellation, ConsentWithdrawal).
3. **Control-plane catalog generates runtime.** The atom catalog (Git) is imported to masters
   and **instantiates** each event's `Process`/`Task`/required-`AICapability` graph; runtime
   reports conformance (the 15 HUMAN atoms are mandatory).
4. **AI behind a guardrail membrane.** `AICapability → Suggestion → HumanReview → artifact`;
   quadrant (AUTO/AUG-HITL/HUMAN-AI/HUMAN) binds autonomy.
5. **Governance at the edge, not inherited.** Consent/lawful-basis enforced where data is
   touched (`GATE_atom_consent` trigger, discretion policy, vendor containment, row-level
   access).
6. **Everything observable in two formats** (machine + human) ranked by urgency×importance.

## 5. Quality goals (top 5; full list in [`nfr.md`](./nfr.md))

| # | Attribute | Why it dominates here |
|---|---|---|
| Q1 | **Privacy & discretion** | Minors' PII + affluent clients; a leak is brand-ending |
| Q2 | **Day-of reliability** | Live, irreversible; degrade gracefully, never go down mid-event |
| Q3 | **Auditability/determinism** | Every AI run, consent change, money move is reproducible & logged |
| Q4 | **Delight latency** | Same-night album; <2h response on the named-human channel |
| Q5 | **Evolvability** | Atom catalog + generated projections change additively, reversibly |

## 6. Key design decisions

- **ADR-0001** — substrate (Git/Postgres/ticketing). *Accepted.*
- **Merge interface = compose-by-reference** (atoms template runtime via `atom_code`) —
  [`../reconciliation/merge-analysis.md`](../reconciliation/merge-analysis.md) (+ partner addendum).
- **Modular monolith first** (this doc §4.1) — extract on pressure.
- *Open ADRs to write:* event-bus choice; LLM provider & isolation; media store; search/vector
  store; auth/identity provider.

## 7. Top risks

| Risk | Mitigation |
|---|---|
| PII/erasure breach (minors) | Data-plane-only PII; consent gates; retention purge; no Git/SaaS PII |
| AI leaks to customer | `GATE_ai_outward`; HUMAN-quadrant invariant; membrane (`stage_boh`) |
| Day-of failure visible | Contingency sagas; hostess-shield escalation tier; pre-staged pipelines |
| Vendor exposure | `ContainmentPolicy`; scoped `VendorUser` access; performance scoring |
| Catalog/runtime drift | Conformance + drift validators; generated projections regenerated in CI |

## 8. Cross-references

Domain: [`../spec/domain-keystone.md`](../spec/domain-keystone.md) · Ethos:
[`../spec/building-ethos.md`](../spec/building-ethos.md) · Data:
[`../data-model`](../data-model) · Graph/lexicon: [`../graph`](../graph).
