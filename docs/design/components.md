# Components & Decomposition · v2.1

**Version:** v2.1 · part of the [System Design set](./README.md).

## Core domain modules (one per bounded context)

Each module owns its context's entities (see [`../graph/entities-by-context.md`](../graph/entities-by-context.md)),
exposes an API slice, and emits/consumes `DomainEvent`s. No module reaches into another's
tables; cross-context links are by-id.

| Module | Owns (key entities) | Publishes (events) | Consumes |
|---|---|---|---|
| **Parties & Consent** | Household, Person, ClientRole, Consent, ProfileSignal, ClientProfile | `ConsentGranted/Withdrawn`, `HouseholdCreated` | enrichment Suggestions |
| **Taste & Creative** | TasteProfile, Concept, ConceptVariant, Motif, PreferenceModel | `ConceptApproved`, `MoodboardReady` | TasteSignal, FeedbackSignal |
| **Supply / Vendors** | Vendor, Offering, Quote, Booking, VendorContract, VendorPerformance | `BookingConfirmed/Cancelled`, `VendorScored` | Deliverable needs |
| **Commercial & Finance** | Engagement, Contract, Budget, Invoice, Payment, Deposit | `EngagementActive`, `DepositCleared` | bookings, change orders |
| **Event Design** | Event, EventBrief, EventConcept, Program, Beat, Deliverable, Moment | `EventConfirmed`, `EventStateChanged` | concept, budget, permits |
| **Production & Logistics** | Venue, LogisticsPlan, Task, Shift, MediaPlan, SensoryCue, ChildFlowStation, Permit | `PermitGranted`, `TaskBlocked` | ROS, bookings |
| **Risk & Resilience** | RiskRegister, Risk, Contingency, EnvironmentForecast, Incident, ChangeOrder | `EnvThresholdBreached`, `IncidentOpened` | weather, vendor signals |
| **Comms & Relationship** | Guest, GuestFamily, Invitation, RSVP, Touchpoint, DelightMoment, FeedbackSignal | `RSVPReceived`, `AlbumDelivered` | cadence, updates |
| **Acquisition** | Lead, Channel, Campaign, Segment, Showcase, Referral, Waitlist | `LeadWon`, `ReferralCreated` | feedback, discretion policy |
| **Operations & Team** | TeamMember, Role, Permission, Pod, ServiceTier, Playbook, QualityReview | `PodAssigned`, `PlaybookVersioned` | engagement, post-mortem |
| **Safety & Compliance** | Safeguarding, BackgroundCheck, SupervisionPlan, EmergencyPlan, SecurityPlan, MediaPolicy | `BackgroundCheckExpired` | event, staff/vendor |
| **Platform & Governance** | AuditEvent, Document, Approval, Region, Brand, RetentionPolicy, Alert | `RetentionDue` | all (audit sink) |

## Cross-cutting components

| Component | Responsibility | Notes |
|---|---|---|
| **Dynamic engine** | `DomainEvent` log; `Process`/saga execution; `StateTransition` enforcement; `Check`/ensemble + attention matrix | the integration spine; idempotent handlers |
| **AI gateway / Enablement** | the only path to an LLM: `AICapability → Invocation → Suggestion`; `HumanReview` queue; `GuardedAction` envelope; `PolicyGuardrail` | enforces `GATE_ai_outward`; quadrant→autonomy |
| **Identity & Auth** | staff SSO, vendor accounts, guest magic-links; row-level scoping; the Permission map | trust-boundary enforcement |
| **Control-plane Sync** | imports Git catalog/atoms/policies → DB masters; instantiates per-event scaffold; conformance/drift | one-way; version-pinned (B7) |

## Externally-exposed services (extracted for scale/trust)

| Service | Why separate | Surface |
|---|---|---|
| **Vendor Portal** | external, untrusted, scoped per `VendorUser`/`VendorAccessRole` | self-service teams, cue-sheet slice, deposits |
| **Guest Engagement** | high-burst comms (RSVP/album); guest-facing; minor data | invitations, sequenced reminders, Q&A, album link |
| **Media Service** | heavy compute (cull/retouch); same-night SLA; large binaries | pipeline → object store; per-family delivery |
| **AI-Enablement** | isolation of the LLM provider; rate/cost; review queue | internal only; never customer-facing |

## Data ownership

Postgres is the system of record (per-module schemas/tables). Object store holds media;
vector/search store holds taste/KG embeddings (derived, rebuildable). Git holds the catalog,
atoms, playbooks, and policies (control plane). Nothing PII lives in Git or the vector store
beyond consented, rebuildable derivations.

## Decomposition rule

Start as a **modular monolith**; a module graduates to a service only when it hits a real
pressure: external exposure (Vendor Portal), burst/independent scale (Guest, Media), or
provider isolation (AI). Premature extraction violates Ethos T5 (minimal layers).
