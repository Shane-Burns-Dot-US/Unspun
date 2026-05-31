# Interface Design — API & Events · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md).

Two interface styles: **synchronous APIs** for the surfaces (apps/portals), and the
**asynchronous `DomainEvent` contract** as the integration spine (Ethos: small steps,
append-only). External integrations are isolated behind adapters.

## 1. API surfaces

| Surface | Audience | Style | Auth |
|---|---|---|---|
| Internal Ops API | staff app | resource API + realtime (ROS, alerts) | SSO + Permission map |
| Vendor Portal API | vendors | scoped resource API | vendor account, row-scoped |
| Guest Engagement API | guests | minimal (RSVP, Q&A, album) | magic-link token |
| Admin/Governance API | platform/ops | resource API + audit | elevated, MFA |

**Conventions.** Prefixed-ULID ids in paths (`/events/evt_…`); resources mirror context
aggregates; reads are projections, writes emit events; idempotency-key on all mutations;
optimistic concurrency via `updatedAt`; field-level redaction by `sensitivity` + caller scope.

**Resource map (illustrative).** `/households`, `/engagements`, `/events`,
`/events/{id}/program`, `/events/{id}/guest-families`, `/vendors`, `/bookings`, `/quotes`,
`/media-plans`, `/atoms` (read-only, control-plane), `/suggestions/{id}/review`,
`/risk-registers`, `/touchpoints`, `/referrals`.

## 2. The DomainEvent contract (the spine)

Canonical envelope — immutable, append-only, the join between modules, sagas, AI, and the
graph:

```json
{
  "id": "dev_01J…",
  "type": "EventConfirmed",
  "aggregate_id": "evt_01J…",
  "aggregate_type": "Event",
  "version": 7,
  "at": "2026-05-31T17:00:00Z",
  "actor_id": "tmb_01J…",
  "correlation_id": "eng_01J…",
  "provenance": { "source": "system", "method": "declared" },
  "payload": { "...": "..." }
}
```

**Rules.** Event types are versioned and additive; consumers are idempotent (dedupe on `id`);
ordering guaranteed per `aggregate_id` via `version`; `correlation_id` threads a saga;
sensitive payloads carry refs, not copies, where avoidable. The canonical event vocabulary is
catalogued per module in [`components.md`](./components.md) and realized in the dynamic-layer
catalog (`../data-model/catalog/06-dynamic-ai.yaml`).

**Core events (sample).** `ConsentGranted/Withdrawn`, `EngagementActive`, `EventConfirmed`,
`EventStateChanged`, `BookingConfirmed/Cancelled`, `DepositCleared`, `PermitGranted`,
`RSVPReceived`, `EnvThresholdBreached`, `IncidentOpened`, `AlbumDelivered`, `ReferralCreated`,
`SuggestionReviewed`, `AtomRealized`.

## 3. AI interface (internal only)

Modules call the **AI gateway**, never an LLM. Request → `Invocation` → `Suggestion`
(+confidence, rationale, target) → `HumanReview` → optional domain write. `GuardedAction`s are
the only auto-applied outputs and only within a `PolicyGuardrail` envelope (no external comms,
money, or world changes). HUMAN-quadrant work does not call the gateway at all.

## 4. Integration adapters (anti-corruption)

| Capability | Integration | Boundary rule |
|---|---|---|
| SMS / email | comms provider | only consented channels; templated, human-approved for clients |
| Payments | PSP | tokenized; AR/AP directional; webhooks → `DomainEvent` |
| E-sign | e-sign vendor | contracts/COIs → `Document` |
| Weather | forecast API | → `EnvironmentForecast`/`EnvironmentCondition` (provenance) |
| Calendar | cal providers | two-way sync; moved committed item ⇒ `ChangeOrder` |
| Maps/geo | maps API | pin confirmation per media crew |
| LLM | managed provider | behind AI-Enablement; never customer-facing |
| Identity enrichment | governed sources | `SourcePolicy` allow-list; minors default-deny |

Each adapter translates to/from domain types and emits events; no provider type leaks into the
domain. Webhooks are verified and converted to `DomainEvent`s at the edge.

## 5. Versioning

APIs version by URL major (`/v1`); events version per type (additive, never break payload
contracts); the **corpus** version (`../VERSION`) stamps generated artifacts. Breaking changes
require a new event type or API major, never a silent mutation.
