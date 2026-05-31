# Non-Functional Requirements · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md). Targets are *reference*
goals to design against, not SLAs to a customer. Each maps to a quality goal in
[`system-design.md`](./system-design.md) and an Ethos tenet.

| # | Attribute | Target (reference) | How it's met |
|---|---|---|---|
| **Privacy & data protection** | Q1 | No minors' PII in Git/SaaS-of-record; right-to-erasure honored ≤ statutory window; field redaction by `sensitivity` + scope | Data-plane-only PII (ADR-0001); consent gates; `RetentionPolicy` purge; audit-retained tombstones — see [`security-privacy.md`](./security-privacy.md) |
| **Day-of availability** | Q2 | Live-event windows: no hard outage; graceful degradation (read-only ROS, queued comms) | Pre-staged pipelines; cached run-of-show on device; contingency sagas; the internal app works offline-first for day-of |
| **Auditability & determinism** | Q3 | 100% of AI invocations, consent changes, money moves logged & replayable; deterministic IDs/state machines | Append-only `AuditEvent`/`DomainEvent`/`Invocation`; event sourcing; Ethos T1 |
| **Delight latency** | Q4 | Named-human channel response < 2h waking; same-night album; teaser within hours | Alerting on the channel; Media same-night pipeline; SLA on `Touchpoint` |
| **Evolvability** | Q5 | Schema/catalog changes additive & reversible; projections regenerated, never hand-edited | Atoms→molecules (Ethos T6); additive bridges; CI regenerates graphs |
| **Performance** | — | Internal app reads p95 < 300ms; writes < 800ms; album link opens < 5s | Projections/read models; CDN for media; modest dataset sizes |
| **Scalability** | — | Hundreds of concurrent engagements; RSVP/album bursts × 10 | Burst services (Guest, Media) scale independently; event log buffers |
| **Reliability/consistency** | — | At-least-once events + idempotent handlers; sagas converge or compensate | Dedup on event id; `Process` compensation; per-aggregate ordering |
| **Security** | Q1 | Least-privilege; row-level scoping; MFA for elevated; vendor containment | Permission map; trust boundaries; `ContainmentPolicy` |
| **Observability** | — | Every signal in two formats (machine + human); attention ranked by urgency×importance | Ethos T2/T3; `CheckResult`/`Alert`; dashboards |
| **Cost** | — | LLM spend bounded per engagement; AUTO atoms carry the throughput, humans the 15 | Quadrant-aware routing; `Invocation.cost` tracked; G7 cost lens |
| **Accessibility & i18n** | — | Guest comms in preferred language/channel; accessible album viewer | `Contact` language/channel prefs; WCAG on guest surfaces |
| **Maintainability** | Q5 | One module per context; no cross-table reads; generated docs | Modular monolith; by-id links; KG/lexicon regenerated |
| **Disaster recovery** | — | RPO ≤ 5 min (data plane); RTO ≤ 1h; control plane = Git (inherently recoverable) | PITR backups; object-store replication; Git is the catalog DR |

## Conflicts & priorities

When attributes collide, the order is **Privacy/Safety (minors) > Day-of reliability >
Auditability > Delight > Performance/Cost.** Examples: a discretion/consent constraint
overrides a delight feature (no showcase without consent); day-of reliability overrides cost
(pre-stage redundantly); auditability overrides latency (never skip the log to be fast).
