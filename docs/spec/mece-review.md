# Unspun — MECE Review of the Domain Object Model

**Type:** Design critique / consultant findings
**Subject:** [`domain-keystone.md`](./domain-keystone.md) and [`glossary.md`](./glossary.md)
**Lens:** MECE — *Mutually Exclusive* (no overlap, no duplicate objects, every object has
exactly one home) and *Collectively Exhaustive* (no gaps in the problem space).

> Read this as a review, not a rewrite. It marks where the catalog is not yet MECE and
> recommends the smallest set of moves to make it so. Nothing here changes the keystone
> until adopted (§7 lists the line‑item actions).

---

## 1. Top‑line verdict

The model is **directionally strong but not yet MECE on either axis.** Three structural
faults, in priority order:

1. **The top‑level cut mixes partition dimensions** (subject‑matter *and* concern *and*
   lifecycle phase in one list of "contexts"). Mixing the basis of division is the
   classic MECE failure — it is what produces most of the overlaps below. *(ME)*
2. **One flat list mixes object archetypes** — transactional entities, master/library
   data, policies/standards, append‑only signals, and derived projections all sit
   side‑by‑side. Because archetype is not an explicit axis, objects of different *kinds*
   overlap at the edges (the "delight," "profile," "signal," and "concept" families). *(ME)*
3. **Material gaps for *this* business** — a children's‑event service for affluent
   families has hard requirements the catalog under‑models: safeguarding, client‑side
   commercial/contract, unified finance, security/privacy detail, scheduling/capacity,
   owned inventory, and document control. *(CE)*

A fourth, softer point: **"Cross‑cutting (X)" is a self‑declared miscellany bucket.** A
"misc" box is the textbook signal that the cut isn't MECE — its contents should be
distributed to real homes (a shared *kernel* of value objects is the only legitimate
residue).

---

## 2. Mutual‑Exclusivity findings (overlap / duplication / double‑home)

| # | Objects in tension | Why it breaks ME | Recommended resolution |
|---|---|---|---|
| ME‑1 | `SignatureTouch` (C) vs `DelightMoment` (F) | Both are "a delightful, bespoke gesture." Authors will not know where to put one. | **Sharpen the boundary, don't merge.** `SignatureTouch` = an *in‑show experiential element* placed on the `Program`/`Beat`, visible to the room. `DelightMoment` = a *1:1 relationship gesture* to a named person, usually *outside* the program. Add this distinction to both definitions. |
| ME‑2 | `ClientProfile` (A) vs `TasteProfile` (B) vs `PreferenceModel` (B) | Three "profile/model" objects; `ClientProfile` holds a "taste summary" and `TasteProfile` can be household‑owned. Overlapping responsibility for "what the client likes." | Make them a **layered stack, ME by role:** `ClientProfile` = sourced *facts & context* about a household (points to its taste); `TasteProfile` = the *aesthetic POV* (dimensions); `PreferenceModel` = a *derived, computed* ranking model. State explicitly that `ClientProfile` carries no aesthetic judgment of its own — it references the `TasteProfile`. |
| ME‑3 | `ProfileSignal` (A) · `TasteSignal` (B) · `FeedbackSignal` (F) | Parallel "Signal" objects with near‑identical shape; a guest comment could plausibly be any of the three. | Keep separate (different subjects/purposes) **but declare a common `Signal` shape** (subject‑ref, value, provenance, consent, weight) and a one‑line routing rule for each. Document that a `FeedbackSignal` may *promote* into a `TasteSignal`/`ProfileSignal`, and that promotion is the only allowed overlap. |
| ME‑4 | `Concept` · `ConceptVariant` · `EventConcept` | Three concept‑shaped objects; risk of authors creating a "concept" in the wrong layer. | Already nearly clean — **state the layering as a rule:** `Concept` (reusable, library) → `ConceptVariant` (deviation, still library) → `EventConcept` (the binding to one `Event`; owns event‑specific adaptation). No creative content originates on `EventConcept`. |
| ME‑5 | `Contact` ↔ `Client` / `Member` / `Guest` / `VendorContact` | The person‑identity pattern is applied **three different ways**: `Client` *is a* Contact, `Guest` *references* a Contact, `VendorContact` *is a* Contact. Inconsistent containment = ambiguous identity. | **Adopt one Party pattern.** `Contact`/`Person` is the single identity core; `Client`, `Member`, `Guest`, `VendorContact` are *roles/personas* attached to it (a person can hold several). Apply uniformly. This also collapses duplicate‑person risk across events/vendors. |
| ME‑6 | `Quote` (D) · `Budget`/`BudgetLine` · `Invoice`/`Payment` (X) | Financial/commercial concepts are **scattered across three contexts**; money has no single owner. | Create one **Commercial & Finance** context and move all money objects there (plus the missing client‑side `Contract`/`Proposal`, §3 CE‑2). |
| ME‑7 | `ExperienceStandard` (C) vs `ServiceStandard` (H) | Two "standard/rubric" objects in different contexts; plus `ContainmentPolicy`, `PolicyGuardrail`, `RetentionPolicy`, `LawfulBasis` are policy‑kind objects scattered everywhere. | Treat **Policy/Standard** as an *archetype* (§5), not a context resident. They can still be *owned* by a context, but classify them so reviewers see them as one family and check coverage. |
| ME‑8 | `CalendarItem` (E) and `ProfileGraph` (A) | Both are **projections/views** that duplicate truth held elsewhere (`Task`/`Beat`/`Booking`; `RelationshipEdge`). Listing them as peer entities implies they hold independent state. | **Demote to derived/projection** (archetype = Projection). `ProfileGraph` is already marked a view — make `CalendarItem` likewise (a sync projection), or, if it must hold sync state, scope that state to *sync metadata only*. |
| ME‑9 | `AICapability` (I) vs vendor `Capability` (D) | Name collision (already mitigated by rename). | Resolved — keep the `AICapability` rename and the glossary note. Confirm no other term is overloaded (`Role` vs `Capability` are fine; `Contract` will need client‑vs‑vendor disambiguation, §3). |
| ME‑10 | `Touchpoint` · `Message` · `Update` · `Invitation` (F) | Specialization hierarchy is implicit: `Update` and `Invitation` are "realized as Touchpoint/Message," so it's unclear whether they are *kinds of* Touchpoint, *kinds of* Message, or composites. | **Declare the hierarchy:** `Touchpoint` = planned intent; `Message` = the sent artifact; `Invitation` and `Update` are *Touchpoint subtypes* with extra structure (RSVP mechanics / change payload). One pattern, stated once. |
| ME‑11 | `Engagement` placed in **Operations & Team (H)** | `Engagement` is the *commercial spine* connecting `Household`→`Event`, and an aggregate root — not an ops/team concept. Its placement is a categorization smell that drags `ServiceTier`/`ServiceStandard` with it. | Move `Engagement` (and the commercial bits) to the new **Commercial** context; leave Operations & Team for *our people and how we work*. |
| ME‑12 | Aggregate nesting: `Engagement` "owns one `Event`" while `Event` is itself an aggregate root | Aggregates should **reference**, not **compose**, other aggregate roots — composition here creates a consistency boundary that spans two roots. | State the relationship as **reference** (`Engagement` references its `Event`), not ownership. Preserves both as independent consistency boundaries. |

---

## 3. Collective‑Exhaustiveness findings (gaps)

Gaps are weighted for *this* business — children, and affluent, discreet clients.

| # | Gap | Why it matters here | Proposed object(s) | Home |
|---|---|---|---|---|
| CE‑1 | **Safeguarding & child safety** | Children are the guests of honor; this is a duty‑of‑care and reputational must, not a nice‑to‑have. | `Safeguarding` policy, `BackgroundCheck` (staff/entertainers in contact with minors), `SupervisionPlan` (ratios), `EmergencyPlan` (medical/allergy/evac), `IncidentSeverity` for child incidents | **NEW: Safety & Compliance** |
| CE‑2 | **Client‑side commercial agreement** | Only `VendorContract` and a bare `Engagement.contractRef` exist; the *client* contract, proposal/SOW, and pricing have no object. | `Proposal`, `Contract` (client), `PricingPlan`/`Estimate` | Commercial & Finance |
| CE‑3 | **Unified finance** | Margin, accounts payable (vendor) vs receivable (client), deposits, refunds are implicit. | `Ledger`, `Margin`, make `Payment` directional (AP/AR), `Deposit`/`Refund` | Commercial & Finance |
| CE‑4 | **Security & privacy detail** | Affluent families: paparazzi, NDAs for guests, physical security, location secrecy, "no‑phones" policies. | `SecurityPlan`, `DiscretionPolicy`/NDA as a `Consent`/`Contract` subtype, `MediaPolicy` | Safety & Compliance |
| CE‑5 | **Transportation & access** | Guest transport, valet, parking, load‑in routing, destination logistics. | `TransportPlan`, `AccessPass`/credential | Production & Logistics |
| CE‑6 | **Owned inventory / assets** | `ResourceAssignment` references "equipment" with no object behind it; props/owned stock can't be tracked or conflict‑checked. | `Asset`/`InventoryItem`, `AssetReservation` | Production & Logistics |
| CE‑7 | **Document control** | Permits, COIs, releases, signed contracts need versioning, expiry, and audit — `Attachment` (a value object) can't carry that. | `Document` (entity: type, version, expiry, signer) wrapping `Attachment` | Platform/Governance |
| CE‑8 | **Capacity & availability** | `Waitlist` references capacity and `TeamMember` has an availability *attribute*, but there's no object to schedule against or to gate intake. | `Availability` (per resource), `Capacity`/`Calendar` (company‑level) | Operations & Team |
| CE‑9 | **Market / brand / region** | `Roster` is region‑scoped and there may be multiple brands/markets, but `Region`/`Brand` aren't objects. | `Market`/`Region`, `Brand` | Platform/Governance |
| CE‑10 | **Gifting** | Children's parties: favors are a `Deliverable`, but guest gifts, registry, and gift handling/thank‑you tracking aren't modeled. | `Gift`/`GiftRegistry`, `GiftLog` | Communication & Relationship |
| CE‑11 | **Generalized approval / workflow** | `HumanReview` is AI‑only; `ChangeOrder` has an approver; approvals are otherwise ad hoc. | `Approval`/`ApprovalGate` (generalized, with `HumanReview` as the AI specialization) | Platform/Governance |
| CE‑12 | **Accommodation** (conditional) | Only relevant for destination/multi‑day events; flag as optional. | `Accommodation`/`LodgingBooking` | Production & Logistics |

---

## 4. Containment‑type analysis (the grouping mechanisms)

The catalog uses **ten distinct grouping/containment mechanisms.** MECE requires each to
be applied *consistently* and not to conflict with another. Assessment:

| Containment type | What it groups | Consistency | Issue |
|---|---|---|---|
| **Bounded context** | Subject‑matter ownership (A–X) | ⚠️ Mixed | Partition basis is inconsistent (subject vs concern vs phase). §1.1, §5. |
| **Aggregate** | Transactional consistency (Household/Engagement/Event) | ⚠️ | Nested roots (ME‑12); `Engagement` mis‑homed (ME‑11). |
| **Composition (owns)** | Parent + child, shared lifecycle | ✅ Mostly | Good in §16; verify no composed object is itself a root. |
| **Reference (by ID)** | Loose cross‑context links | ✅ | Convention is clear (`<obj>Id`). Apply to Engagement→Event (ME‑12). |
| **Specialization / role** | Person personas; comms subtypes | ❌ Inconsistent | `Contact` pattern applied 3 ways (ME‑5); comms hierarchy implicit (ME‑10). |
| **Library / catalog** | Reusable master data (Motif∈MotifLibrary, Vendor∈Roster, KnowledgeAsset∈KnowledgeBase, Offering∈Vendor, BrandAsset) | ⚠️ | Real repeated pattern but **not named**. Formalize "Catalog/Library" as an archetype so coverage is checkable. |
| **Policy / standard / config** | Rules & rubrics (ExperienceStandard, ServiceStandard, ContainmentPolicy, PolicyGuardrail, RetentionPolicy, Cadence‑template) | ❌ Scattered | Same archetype living in 5 contexts (ME‑7). Classify as one family. |
| **Signal / append‑record** | Event‑sourced facts (ProfileSignal, TasteSignal, FeedbackSignal, AuditEvent, Invocation) | ⚠️ | Parallel shapes not unified (ME‑3); archetype implicit. |
| **Derived / projection** | Views over other truth (ProfileGraph, CalendarItem, PreferenceModel, ExceptionalityScore, VendorPerformance) | ❌ Implicit | Mixed in with entities; reader can't tell what holds independent state (ME‑8). |
| **Value object (kernel)** | Embedded, identity‑less (Money, DateWindow, …) | ✅ | Clean (§14.4). This is the *only* legitimate "shared" bucket. |

**Read‑through:** the green rows are your real containment primitives. The red/amber rows
fail because **two of the ten — "object archetype" and "subject context" — are collapsed
into a single list.** Separate them and most ME issues dissolve.

---

## 5. Root cause & the fix: one list, two axes

Every object should be classified on **two orthogonal, each‑independently‑MECE axes:**

**Axis 1 — Subject Context (ownership / where it lives).** Pick *one* basis of division:
subject‑matter. Recommended re‑cut (single dimension, ME by subject):

1. Parties & Consent · 2. Taste & Creative · 3. Supply (Vendors) ·
4. **Commercial & Finance** *(new — absorbs Quote, Budget, Invoice, Payment, client Contract, Engagement)* ·
5. Event Design · 6. Production & Logistics · 7. **Risk & Resilience** *(split out of Logistics)* ·
8. Communication & Relationship · 9. Acquisition & Distribution ·
10. Operations & Team · 11. **Safety & Compliance** *(new)* · 12. **Platform & Governance** *(audit, provenance, documents, identity conventions, region/brand, approvals)*.

> `AI Enablement` is **not a subject context — it is a capability *layer*** that cuts
> across all twelve. Model it as an orthogonal layer (it already behaves like one via the
> `Suggestion`→`HumanReview` gate), not a peer box. Likewise dissolve "Cross‑cutting":
> finance→Commercial, consent→Parties, audit/provenance/documents→Platform & Governance,
> value objects→a named **Shared Kernel** (the only legitimate shared residue).

**Axis 2 — Archetype (what *kind* of object, its lifecycle class).** A MECE set:

| Archetype | Holds independent truth? | Lifecycle | Examples |
|---|---|---|---|
| Aggregate Root | Yes | Transactional | Household, Engagement, Event |
| Aggregate Member | Yes (within root) | Shared with root | Beat, Deliverable, RSVP, Risk |
| Party / Identity | Yes | Long‑lived | Contact, Client, Guest, Vendor |
| Master / Catalog | Yes | Curated, versioned | Motif, Concept, Offering, Playbook, ServiceTier |
| Policy / Standard | Yes | Versioned config | ExperienceStandard, ContainmentPolicy, RetentionPolicy |
| Signal / Record | Append‑only | Immutable facts | ProfileSignal, FeedbackSignal, AuditEvent, Invocation |
| Derived / Projection | **No** | Recomputed | ProfileGraph, CalendarItem, PreferenceModel, ExceptionalityScore, VendorPerformance |
| Value Object | No | Embedded | Money, DateWindow, Provenance |

**Rule:** every object carries exactly one Context (Axis 1) **and** one Archetype
(Axis 2). Each axis is MECE on its own. This is the single highest‑leverage change — it
makes "where does this go?" unambiguous and exposes gaps (an empty cell in the Context ×
Archetype matrix is a question to answer).

---

## 6. The Context × Archetype matrix (how to use it)

Lay the 12 contexts down the side and the 8 archetypes across the top. Place every object
in exactly one cell. Two payoffs:

- **ME test:** if an object wants two cells, its definition is doing two jobs — split it
  (ME‑1, ME‑6) or it's a projection of another (ME‑8).
- **CE test:** scan for *suspiciously empty* cells. E.g. "Safety & Compliance × Policy"
  was empty → surfaced CE‑1/CE‑4. "Commercial × Aggregate/Master" empty → CE‑2.

---

## 7. Recommended actions (line items)

**Mutually‑Exclusive (de‑overlap):**
- A1. Sharpen `SignatureTouch` vs `DelightMoment` definitions (in‑show vs 1:1). *(ME‑1)*
- A2. Re‑state the profile stack roles; `ClientProfile` references `TasteProfile`, holds no aesthetics. *(ME‑2)*
- A3. Declare a common `Signal` shape + promotion‑only overlap rule. *(ME‑3)*
- A4. State Concept→Variant→EventConcept as a layering rule. *(ME‑4)*
- A5. Adopt one **Party** identity pattern (Contact core + role personas). *(ME‑5)*
- A6. Create **Commercial & Finance**; move Quote/Budget/Invoice/Payment + add client Contract; move `Engagement`. *(ME‑6, ME‑11, CE‑2/3)*
- A7. Classify all Policy/Standard objects as one archetype. *(ME‑7)*
- A8. Demote `CalendarItem` to a projection (sync‑metadata only). *(ME‑8)*
- A9. Declare the comms subtype hierarchy (Touchpoint ⊃ Invitation/Update; Message = artifact). *(ME‑10)*
- A10. Change `Engagement`→`Event` from *owns* to *references*. *(ME‑12)*

**Collectively‑Exhaustive (close gaps):**
- B1. Add **Safety & Compliance** context: Safeguarding, BackgroundCheck, SupervisionPlan, EmergencyPlan, SecurityPlan, MediaPolicy. *(CE‑1, CE‑4)*
- B2. Add Commercial objects: Proposal, Contract, PricingPlan, Ledger, Margin, directional Payment, Deposit/Refund. *(CE‑2/3)*
- B3. Add Production objects: TransportPlan, Asset/InventoryItem + AssetReservation, (optional) Accommodation. *(CE‑5/6/12)*
- B4. Add Platform & Governance objects: Document (wrapping Attachment), Approval/ApprovalGate, Region/Brand. *(CE‑7/9/11)*
- B5. Add Availability/Capacity to Operations. *(CE‑8)*
- B6. Add Gifting objects to Communication & Relationship. *(CE‑10)*

**Structural (root cause):**
- C1. Re‑cut contexts on a single dimension (subject) → 12 contexts (§5).
- C2. Add **Archetype** as a second classification axis (§5) and tag every object.
- C3. Reframe **AI Enablement** as an orthogonal *layer*, not a context.
- C4. Dissolve **Cross‑cutting**; keep only a named **Shared Kernel** of value objects.

> Smallest high‑value subset if appetite is limited: **A5, A6, A8, C2, B1.** These fix the
> identity ambiguity, unify money, stop projections masquerading as entities, add the
> classification that prevents future drift, and close the one gap that is a genuine
> liability (child safety).
