# Unspun — Domain Keystone

**Status:** Anchoring design document (source of truth)
**Type:** Domain object model / ontology
**Scope:** The complete vocabulary of objects, definitions, identity rules, and
relationships for a turnkey, high‑touch children's birthday event service for
affluent households.

> This is the *keystone*: the one artifact every other artifact (data model,
> services, UI, runbooks, contracts, prompts) must agree with. If a term is used
> anywhere in the system, it is defined here. If two parts of the system disagree
> about what a thing *is*, this document wins until it is amended.
>
> It deliberately contains **no timelines, no estimates, and no implementation
> choices**. It defines *what exists*, *what each thing means*, *how each thing is
> identified and indexed*, and *how things relate*.

---

## 0. How to read this document

Each object is described with a fixed shape so the catalog stays scannable:

- **Definition** — one crisp sentence: what the object *is*.
- **Identity** — the primary key, its ID prefix, and any *natural keys* (real‑world
  attributes that must be unique). This is the "index clarification": how the
  object is found, referenced, and de‑duplicated.
- **Key attributes** — the defining fields (not exhaustive; the data model owns the
  full list).
- **Relationships** — how it connects to other objects (→ points to the related
  object; cardinality in parentheses).
- **Lifecycle** — the allowed states and transitions, where the object is stateful.
- **Invariants** — rules that must always hold.

Cross‑references use the object name in `CodeFont`. Every object also appears in
[`glossary.md`](./glossary.md), the alphabetical index.

---

## 1. Design principles (the spine)

These constrain every object below.

1. **Human‑fronted, AI‑backed.** The client and their guests experience *people and
   craft*, never a model. AI is an *internal capability layer* (§12) whose outputs
   are always `Suggestion`s gated by `HumanReview` before they touch a client,
   a guest, a vendor, or the physical world. "Abstract AI out of the equation"
   is encoded structurally, not as a guideline.
2. **Exceptional = slightly‑unique + reliably top‑decile.** "Exceptional" is not a
   vibe; it is two measurable things bound to every event: a *novelty* dimension
   (`ConceptVariant`, `SignatureTouch`) and an *exceptionality* dimension
   (`ExceptionalityScore` against an `ExperienceStandard`).
3. **Consistency is engineered, not heroic.** Service reliability lives in objects:
   `Playbook`, `Checklist`, `ServiceStandard`, `RiskRegister`, `Contingency`,
   `ContainmentPolicy`. A great outcome that cannot be reproduced is a defect.
4. **Everything sensitive carries provenance and consent.** Any datum about a
   `Client`, `Celebrant`, or `Guest` that was inferred, enriched, or scraped is a
   `ProfileSignal` with an attached `Provenance` and governed by `Consent`. There
   is no "ambient knowledge" — only sourced, consented, retained‑or‑expired facts.
5. **Minors are first‑class protected subjects.** The `Celebrant` and child
   `Guest`s are children. Data minimization, guardian consent, and tighter
   retention apply by default (§11).
6. **One relationship, many engagements.** The durable asset is the `Household`
   relationship; individual parties are `Engagement`s hung off it. Taste, history,
   and trust accrue to the household across events.
7. **Taste is an asset that can be decomposed and re‑composed.** A `Tastemaker`'s
   judgment is captured as a structured `TasteProfile` built from `TasteSignal`s,
   so it can be mirrored, aggregated, and applied — without replacing the human's
   final call.

---

## 2. Bounded‑context index (the map)

The domain is partitioned into nine operating contexts plus one cross‑cutting
context. Each owns its objects; objects reference across contexts by ID only.

| # | Context | Owns (what it is responsible for) | Section |
|---|---------|-----------------------------------|---------|
| A | **Identity & Relationships** | Who the household, client, child, and guests are; the social graph; consent | §3 |
| B | **Taste & Curation** | The tastemaker's judgment, the creative library, concepts and their variants | §4 |
| C | **Event** | The celebration itself: brief, concept, program, deliverables, signature touches | §5 |
| D | **Vendor & Supply** | Suppliers, offerings, quotes, bookings, vendor performance and containment | §6 |
| E | **Logistics & Risk** | Venue, permits, tasks, calendars, weather, risks, contingencies, incidents, changes | §7 |
| F | **Communication & Delight** | Every planned and ad‑hoc touch with client and guests; invitations, RSVPs, surprises | §8 |
| G | **Marketing & Distribution** | Leads, channels, campaigns, showcases, referrals, waitlist | §9 |
| H | **Operations & Team** | Our own people, pods, roles, service tiers, SOPs, quality reviews | §10 |
| I | **AI Enablement** | The internal, abstracted capability layer: agents, invocations, suggestions, guardrails | §12 |
| X | **Cross‑cutting** | Money, consent & privacy, provenance, audit, shared value objects | §11 |

---

## 3. Identity & indexing conventions (the "index clarification")

A robust system needs unambiguous identity. These rules apply to *every* object.

### 3.1 Primary identity
- Every object has a single immutable **primary key**: a prefixed, sortable ID
  (`<prefix>_<ulid>`), e.g. `hh_01J9Z…`. Prefixes are listed per object below and
  collected in the glossary. The prefix makes any ID self‑describing in logs, URLs,
  and references.
- IDs are **never reused** and **never carry meaning** beyond the prefix. Renaming,
  re‑theming, or re‑pricing an object does not change its ID.

### 3.2 Natural keys (uniqueness / de‑duplication indexes)
- A **natural key** is a real‑world attribute set that must be unique within a scope,
  used to prevent duplicates (e.g. a `Vendor` is unique by legal entity + region; a
  `Contact` is unique by verified email *or* phone). Natural keys are how the system
  recognizes "we already know this person/vendor."
- Where listed as `Identity`, the natural key is an *index*, not the primary key.

### 3.3 References vs. embedding
- Cross‑context links are **references by ID** (loose coupling). Within an aggregate
  (§13), child objects may be **embedded** (shared lifecycle with the root).
- Reference fields are named `<object>Id` (single) or `<object>Ids` (many).

### 3.4 Standard secondary indexes
Unless stated otherwise, every object is indexable by: `createdAt`, `updatedAt`,
owning context, and its primary foreign key to an aggregate root (`householdId`,
`engagementId`, or `eventId`). Stateful objects are additionally indexed by `state`.

### 3.5 Shared value objects (no independent identity)
`Money`, `DateWindow`, `GeoLocation`, `Address`, `Provenance`, `Score`,
`ContactChannel`, and `Attachment` are **value objects**: defined once (§11.5),
embedded wherever needed, compared by value, never assigned their own ID.

---

## 4. Aggregate roots (where consistency is enforced) — preview

Three objects are **aggregate roots**: transactional boundaries that own their
children and guarantee their own invariants. Everything else lives under one of them.

- `Household` (Context A) — the durable relationship.
- `Engagement` (Context H/C boundary) — one contracted project to deliver an event.
- `Event` (Context C) — the celebration; owned by an `Engagement`.

Full aggregate composition is in §13. The catalog follows.

---

## 5. Context A — Identity & Relationships

### Household
- **Definition:** The affluent family unit that is the durable customer relationship.
- **Identity:** `hh_` (primary). Natural key: primary `Client` verified contact +
  residence `Address` (soft index for de‑dup; not enforced hard).
- **Key attributes:** display name, tier eligibility, status markers (sensitive),
  preferred names/pronouns, languages, residences, household notes.
- **Relationships:** has many `Client` (1..n), `Member` (0..n), `Celebrant` (1..n,
  the children); has many `Engagement` (0..n); has one `ClientProfile`; subject of
  many `Consent` (0..n).
- **Invariants:** must have ≥1 `Client` with an active `Consent` before any
  `Engagement` may leave `Inquiry`.

### Client
- **Definition:** An adult principal in a `Household` who is a decision‑maker, payer,
  and primary point of contact.
- **Identity:** `cli_`. Natural key: verified `ContactChannel` (email or phone).
- **Key attributes:** name, role in household, decision authority, communication
  preferences, VIP/discretion flags.
- **Relationships:** belongs to one `Household`; is a `Contact`; grants `Consent`;
  authors/approves `EventBrief`; receives `Touchpoint`s.

### Celebrant
- **Definition:** The child whose birthday is being celebrated — the guest of honor.
- **Identity:** `cel_`. Natural key: `householdId` + given name + date of birth.
- **Key attributes:** age‑turning, interests/obsessions, sensitivities (allergies,
  sensory, fears), friends‑who‑matter, do‑not‑include list. **Minor:** governed by
  §11 protections.
- **Relationships:** belongs to one `Household`; is the focus of one `Event` per
  birthday; interests feed the `EventBrief` and `Concept`.
- **Invariants:** flagged `isMinor = true`; guardian `Consent` required for any
  `ProfileSignal`; default retention is tightened (§11.3).

### Member
- **Definition:** Any other household person relevant to planning (sibling, partner,
  nanny, estate manager) who is not a `Client` or `Celebrant`.
- **Identity:** `mem_`. Natural key: `householdId` + name + role.
- **Relationships:** belongs to one `Household`; may be a `Contact`; may hold a
  logistics role (e.g. on‑site gatekeeper).

### Contact
- **Definition:** An addressable person with one or more verified channels — the base
  identity used to actually *reach* someone (client, member, guest, or vendor person).
- **Identity:** `con_`. Natural key: a verified `ContactChannel` (unique per channel
  value).
- **Key attributes:** name, channels (email/phone/messenger), preferred channel,
  language, opt‑in state, do‑not‑contact flag.
- **Relationships:** linked to exactly one of `Client`/`Member`/`Guest`/`VendorContact`;
  target of `Message` and `Touchpoint`.
- **Invariants:** a `Message` may only send on a channel with an active opt‑in and no
  do‑not‑contact flag.

### Guest
- **Definition:** A person invited to a specific `Event` — typically a child plus an
  accompanying adult.
- **Identity:** `gst_`. Natural key: `eventId` + `Contact`.
- **Key attributes:** child/adult, relationship to `Celebrant`, RSVP status, plus‑ones,
  dietary/sensory needs, accessibility needs, gifting notes.
- **Relationships:** belongs to one `Event`; references a `Contact`; may belong to a
  `GuestParty`; produces `RSVP` and `FeedbackSignal`; receives `Invitation`,
  `Update`, `DelightMoment`.
- **Lifecycle:** `Invited → Responded(Yes|No|Maybe) → Confirmed → Attended | NoShow`.

### GuestParty
- **Definition:** A group (often another household) that is invited and responds as a
  unit.
- **Identity:** `gpt_`. Natural key: `eventId` + group label.
- **Relationships:** belongs to one `Event`; groups many `Guest` (1..n).

### RelationshipEdge
- **Definition:** A directed link in the social graph between two people or households
  (e.g. "Celebrant is close friends with", "parent is peer of", "rival household").
- **Identity:** `rel_`. Natural key: from‑id + to‑id + relationship type.
- **Key attributes:** type, strength, since, source (`Provenance`).
- **Relationships:** connects `Celebrant`/`Client`/`Household`/`Guest` nodes; informs
  guest‑list curation and marketing `Referral` and `Segment`.
- **Notes:** the `ProfileGraph` is the *view* over all `RelationshipEdge`s; it is not a
  separate stored object.

### ClientProfile
- **Definition:** The composed, living portrait of a household's taste, status, context,
  and sensitivities used to personalize service and creative.
- **Identity:** `cpf_`. One per `Household` (natural key: `householdId`).
- **Key attributes:** taste summary, lifestyle markers, brands/affinities, social
  context, no‑go list, discretion level, confidence per facet.
- **Relationships:** belongs to one `Household`; *assembled from* many `ProfileSignal`;
  feeds `PreferenceModel` and `EventBrief`.
- **Invariants:** every assertion in the profile traces to ≥1 `ProfileSignal` with
  `Provenance`; no un‑sourced claims.

### ProfileSignal
- **Definition:** A single datum about a person or household — declared, observed,
  inferred, or externally sourced — with its provenance and consent state.
- **Identity:** `psg_`. Natural key: subject‑id + signal key + `Provenance.sourceRef`.
- **Key attributes:** subject ref, key, value, confidence, sensitivity class, capture
  method (`declared|observed|inferred|enriched|scraped`), `Provenance`, `consentId`,
  `expiresAt`.
- **Relationships:** about a `Household`/`Client`/`Celebrant`/`Guest`; governed by one
  `Consent`; aggregated into `ClientProfile` and `PreferenceModel`.
- **Invariants:** a signal whose `consentId` is withdrawn or whose `expiresAt` passed is
  **excluded** from all profiles and models (soft‑deleted, audit‑retained). Signals with
  capture method `scraped`/`enriched` require a recorded `lawfulBasis` (§11.2).

### Consent
- **Definition:** A granular, revocable record of permission from a data subject (or
  their guardian) to collect, use, enrich, or share specific categories of data for
  specific purposes.
- **Identity:** `cns_`. Natural key: subject‑id + purpose + scope + version.
- **Key attributes:** subject ref, purpose, data categories, `lawfulBasis`, granted‑by
  (self/guardian), grantedAt, withdrawnAt, evidence `Attachment`.
- **Relationships:** granted by `Client`/guardian; governs `ProfileSignal`, `Message`,
  `Showcase`, and any enrichment `Capability`.
- **Lifecycle:** `Granted → (Active) → Withdrawn | Expired`.

---

## 6. Context B — Taste & Curation

### Tastemaker
- **Definition:** An internal creative authority whose aesthetic judgment is the
  product differentiator; the human whose "taste" the system mirrors and amplifies.
- **Identity:** `tm_`. Natural key: `TeamMember` ref (a tastemaker is a role a team
  member holds).
- **Key attributes:** domains of authority, signature motifs, public persona,
  decision rights.
- **Relationships:** is a `TeamMember`; owns one or more `TasteProfile`; authors
  `Concept`; curates `MotifLibrary`; final approver of creative `Suggestion`s.

### TasteProfile
- **Definition:** A structured, inspectable model of an aesthetic point of view — for a
  `Tastemaker` or a `Household` — decomposed into dimensions that can be reasoned over.
- **Identity:** `tpf_`. Natural key: owner ref (`tastemakerId` or `householdId`) +
  version.
- **Key attributes:** dimensions (palette, materiality, formality, whimsy, restraint,
  references, anti‑references), weights, exemplars, `AestheticVector` (internal).
- **Relationships:** owned by `Tastemaker` or `Household`; built from many `TasteSignal`;
  consumed by `PreferenceModel` and `Concept` generation.
- **Invariants:** human‑readable dimensions are authoritative; the `AestheticVector` is a
  derived convenience, never the source of truth.

### TasteSignal
- **Definition:** A single act of taste — a like, a rejection, a "more like this," an
  annotation on a reference.
- **Identity:** `tsg_`. Natural key: actor ref + target `InspirationSource` + verdict +
  timestamp.
- **Key attributes:** actor, target, verdict (`love|like|neutral|dislike|veto`),
  annotation, weight.
- **Relationships:** produced by `Tastemaker` or `Client`; points at an
  `InspirationSource` or `Concept`; updates a `TasteProfile`.

### InspirationSource
- **Definition:** A reference artifact (image, real event, place, object, motif, link)
  used to elicit or express taste.
- **Identity:** `isr_`. Natural key: content hash + origin URL.
- **Key attributes:** media `Attachment`, origin, tags, rights status, `Provenance`.
- **Relationships:** target of `TasteSignal`; cited by `Concept` and `Motif`.

### Motif
- **Definition:** A reusable aesthetic or experiential building block — a color story, a
  ritual, a material, a format, a gag — that can be composed into concepts.
- **Identity:** `mtf_`. Natural key: slug (unique in `MotifLibrary`).
- **Key attributes:** name, category, description, exemplars, pairing rules, cost band,
  reuse count, freshness (how recently/often used → guards against sameness).
- **Relationships:** lives in `MotifLibrary`; composed into `Concept`; realized as
  `SignatureTouch` or `Deliverable`.

### MotifLibrary
- **Definition:** The curated catalog of all `Motif`s, organized for composition and
  freshness control.
- **Identity:** `mlb_` (typically singleton per brand). Indexed by category, freshness.
- **Relationships:** contains many `Motif`.

### Concept
- **Definition:** A candidate creative direction for an event — a coherent composition of
  `Motif`s, theme, and narrative — proposed before it is bound to a specific `Event`.
- **Identity:** `cpt_`. Natural key: title + author + version.
- **Key attributes:** title, narrative, composed motifs, mood references, palette,
  signature ideas, estimated cost band, novelty rationale.
- **Relationships:** authored by `Tastemaker` (often from AI `Suggestion`); composed of
  `Motif`s; cites `InspirationSource`s; has many `ConceptVariant`; when selected, becomes
  the `EventConcept` of an `Event`.
- **Lifecycle:** `Draft → InReview → Approved → Selected | Archived`.

### ConceptVariant
- **Definition:** A deliberate small deviation of a `Concept` that makes a given event
  *slightly unique* relative to siblings, peers, or prior events.
- **Identity:** `cvr_`. Natural key: `conceptId` + variant label.
- **Key attributes:** what differs, why, novelty delta, peer‑collision check result.
- **Relationships:** belongs to one `Concept`; selected into one `EventConcept`.
- **Invariants:** before selection, a variant is checked against recent events in the same
  `ProfileGraph`/`Segment` to avoid repetition (the "slightly unique" guarantee).

### PreferenceModel
- **Definition:** An aggregated, decomposed representation of preferences — for a
  household, a segment, or the tastemaker's "ideal" — used to ideate and rank options.
- **Identity:** `pmd_`. Natural key: scope ref + version.
- **Key attributes:** weighted preference dimensions, derived‑from sources, confidence,
  staleness.
- **Relationships:** derived from `TasteProfile` + `ProfileSignal` (consented) + `Trend`;
  consumes/produces ranking for `Concept` and `Motif`; an input to AI ideation
  `Capability`.

### Trend
- **Definition:** An observed cultural, seasonal, or market signal relevant to children's
  events (e.g. a surging franchise, a format fatigue).
- **Identity:** `trd_`. Natural key: name + window.
- **Key attributes:** description, direction (rising/falling), confidence, sources,
  `DateWindow`, `Provenance`.
- **Relationships:** feeds `PreferenceModel` and marketing `Campaign`; ages out.

---

## 7. Context C — Event

### Event
- **Definition:** A single child's birthday celebration to be designed and delivered —
  the central thing the business produces. **Aggregate root.**
- **Identity:** `evt_`. Natural key: `celebrantId` + birthday `DateWindow`.
- **Key attributes:** title, `DateWindow`/date, headcount target, status, exceptionality
  target, discretion level.
- **Relationships:** owned by one `Engagement`; for one `Celebrant`; has one
  `EventBrief`, one `EventConcept`, one `Program`, many `Deliverable`, many `Guest`,
  one `LogisticsPlan`, one `RiskRegister`, one `Budget`, many `Touchpoint`.
- **Lifecycle:** `Briefing → Designing → Planning → Confirmed → InProduction → LiveDay →
  Wrap → Reviewed`.
- **Invariants:** cannot enter `Confirmed` without an `Approved` `EventConcept`, a funded
  `Budget`, secured `Venue`, and all required `Permit`s `Granted`.

### EventBrief
- **Definition:** The agreed, bounded set of parameters and constraints that define
  success for an event — the contract between client intent and creative freedom.
- **Identity:** `ebr_`. One per `Event` (natural key: `eventId`).
- **Key attributes:** celebrant focus, date/window, location preference, headcount,
  budget band, must‑haves, hard no‑gos, dietary/accessibility constraints, discretion
  requirements, tone.
- **Relationships:** belongs to one `Event`; authored with `Client`; bounds `Concept`
  selection and `Budget`.
- **Invariants:** every no‑go is enforced as a hard constraint across `Concept`,
  `Deliverable`, `Vendor`, and guest comms.

### EventConcept
- **Definition:** The single selected `Concept`+`ConceptVariant` bound to this event,
  with event‑specific adaptations.
- **Identity:** `ecn_`. One per `Event`.
- **Relationships:** belongs to one `Event`; references one `Concept` + one
  `ConceptVariant`; drives `Program`, `Deliverable`s, `SignatureTouch`es.

### Program
- **Definition:** The ordered run‑of‑show: the timed sequence of everything that happens
  on the event day.
- **Identity:** `prg_`. One per `Event`.
- **Key attributes:** ordered `Beat`s, call times, transitions.
- **Relationships:** belongs to one `Event`; composed of many `Beat`; aligns with
  `LogisticsPlan` and on‑day `Shift`s.

### Beat
- **Definition:** A discrete moment within the program (arrival, reveal, cake, a game, a
  performance) — the unit where experience and delight are placed.
- **Identity:** `bet_`. Natural key: `programId` + sequence.
- **Key attributes:** name, start/duration, location, owner, dependencies, the felt
  experience it should produce.
- **Relationships:** belongs to one `Program`; may realize a `SignatureTouch`; needs
  `Deliverable`s and `ResourceAssignment`s.

### SignatureTouch
- **Definition:** A bespoke, memorable gesture engineered into a specific event to make it
  distinctive and personal (the "delightful, slightly unique" element).
- **Identity:** `sig_`. Natural key: `eventId` + name.
- **Key attributes:** description, who it surprises (`Celebrant`/`Guest`/`Client`),
  personalization basis (which `ProfileSignal`/`TasteSignal`), wow rationale.
- **Relationships:** belongs to one `Event`; often tied to a `Beat`; may be realized by a
  `Deliverable` and an internal `DelightMoment`.

### Deliverable
- **Definition:** A concrete thing to be produced or procured for the event (cake,
  invitations, an installation, costumes, favors).
- **Identity:** `dlv_`. Natural key: `eventId` + name.
- **Key attributes:** type, spec, quantity, owner, source (in‑house vs `Vendor`),
  acceptance criteria, status.
- **Relationships:** belongs to one `Event`; may be fulfilled by a `Booking`/`Offering`;
  consumes `Budget`; tracked by `Task`s.
- **Lifecycle:** `Specified → Sourced → InProduction → Delivered → Accepted | Rejected`.

### ExperienceStandard
- **Definition:** The rubric defining what "top‑10% of events a child will attend" means,
  in scorable dimensions.
- **Identity:** `xst_` (versioned, brand‑level). Natural key: version.
- **Key attributes:** dimensions (delight, novelty, polish, personalization, flow,
  safety, parent‑impression), weights, scoring guidance.
- **Relationships:** applied to each `Event` via `ExceptionalityScore`.

### ExceptionalityScore
- **Definition:** An event's assessed standing against the `ExperienceStandard`, both
  predicted (design‑time) and realized (post‑event).
- **Identity:** `xsc_`. Natural key: `eventId` + phase(`predicted|realized`).
- **Key attributes:** per‑dimension `Score`, composite, percentile target/achieved,
  notes.
- **Relationships:** scores one `Event`; informed by `FeedbackSignal` and
  `QualityReview`; feeds `PreferenceModel` and `MotifLibrary` freshness.

---

## 8. Context D — Vendor & Supply

### Vendor
- **Definition:** An external supplier organization that provides goods or services for
  events (caterers, entertainers, rentals, venues‑as‑vendors, florists).
- **Identity:** `ven_`. Natural key: legal entity + primary service region.
- **Key attributes:** legal name, categories (`Capability`), regions, insurance status,
  reliability grade, discretion rating, preferred flag.
- **Relationships:** has many `VendorContact`, `Capability`, `Offering`; party to
  `VendorContract`, `Quote`, `Booking`; carries `VendorPerformance`; bound by
  `ContainmentPolicy`.

### VendorContact
- **Definition:** A person at a `Vendor` we coordinate with.
- **Identity:** `vct_`. Natural key: `vendorId` + `ContactChannel`.
- **Relationships:** belongs to one `Vendor`; is a `Contact`.

### Capability
- **Definition:** A service category a vendor can perform (e.g. "balloon installation",
  "kosher catering"). *(Note: distinct from AI `Capability` in §12 — disambiguated by
  context.)*
- **Identity:** `cap_`. Natural key: vendor + taxonomy code.
- **Relationships:** held by a `Vendor`; matched against `Deliverable` needs.

### Offering
- **Definition:** A specific bookable product or service line from a vendor, with price
  basis — the vendor's "SKU."
- **Identity:** `ofr_`. Natural key: `vendorId` + SKU/slug.
- **Key attributes:** name, unit, price basis, lead requirements, constraints, options.
- **Relationships:** belongs to one `Vendor`; quoted in `Quote`; reserved by `Booking`;
  fulfills `Deliverable`.

### Quote
- **Definition:** A priced proposal from a vendor for specified offerings against an
  event's needs.
- **Identity:** `qot_`. Natural key: `vendorId` + `eventId` + revision.
- **Key attributes:** line items (`Money`), validity window, terms, assumptions.
- **Relationships:** from one `Vendor` for one `Event`; references `Offering`s; converts
  to `Booking`; feeds `Budget`.
- **Lifecycle:** `Requested → Received → Accepted | Rejected | Expired`.

### Booking
- **Definition:** A confirmed reservation/commitment with a vendor for an event — the
  binding line of supply.
- **Identity:** `bok_`. Natural key: `quoteId` (accepted) or `vendorId`+`eventId`+slot.
- **Key attributes:** offerings, agreed `Money`, dates/slots, deposit/payment state,
  cancellation terms.
- **Relationships:** belongs to one `Event`; with one `Vendor`; realizes `Deliverable`s;
  governed by `VendorContract` and `ContainmentPolicy`; appears in `LogisticsPlan`.
- **Lifecycle:** `Held → Confirmed → Fulfilled | Cancelled | NoShow`.
- **Invariants:** a `Confirmed` booking must have an active `VendorContract` and fit the
  `Budget`.

### VendorContract
- **Definition:** The legal agreement governing a vendor relationship or a specific
  booking (scope, liability, insurance, discretion/NDA).
- **Identity:** `vcn_`. Natural key: parties + effective `DateWindow`.
- **Relationships:** binds a `Vendor` (and optionally a `Booking`); referenced by
  `ContainmentPolicy`.

### VendorPerformance
- **Definition:** The running record of how a vendor actually performed across
  engagements — reliability, quality, incidents.
- **Identity:** `vpf_`. One per `Vendor` (rolling).
- **Key attributes:** on‑time rate, defect rate, `Incident` history, `QualityReview`
  ratings, discretion breaches.
- **Relationships:** about one `Vendor`; updated by `Incident` and `QualityReview`;
  drives `Vendor.reliabilityGrade` and `Roster` inclusion.

### ContainmentPolicy
- **Definition:** The rules that "contain" a vendor — scope boundaries, communication
  channels, client‑contact prohibitions, fallback/substitute requirements — so a vendor
  cannot create exposure or break the white‑glove frame.
- **Identity:** `cpy_`. Natural key: scope (`vendorId` or category) + version.
- **Key attributes:** allowed scope, comms boundary (no direct client contact),
  branding rules, required fallback vendor, escalation path.
- **Relationships:** applies to `Vendor`/`Booking`; enforced in `LogisticsPlan` and
  `Communication`.

### Roster
- **Definition:** A curated, ranked list of preferred vendors per category and region.
- **Identity:** `ros_`. Natural key: category + region + version.
- **Relationships:** selects from `Vendor`s by `VendorPerformance`; consulted during
  sourcing.

---

## 9. Context E — Logistics & Risk

### Venue
- **Definition:** The physical location(s) where an event happens (estate, hall, outdoor
  site).
- **Identity:** `vnu_`. Natural key: `Address` + name.
- **Key attributes:** `GeoLocation`, capacity, access/load‑in rules, amenities,
  restrictions, indoor/outdoor, weather exposure, permit requirements.
- **Relationships:** hosts one `Event` (per booking); referenced by `Permit`,
  `LogisticsPlan`, `WeatherWatch`; may be supplied via a `Vendor`/`Booking`.

### Permit
- **Definition:** A regulatory or property authorization required to legally hold an
  element of the event (noise, road, fire, food, structure, drone).
- **Identity:** `prm_`. Natural key: authority + type + `eventId`.
- **Key attributes:** authority, type, requirements, status, validity, conditions,
  evidence `Attachment`.
- **Relationships:** required by `Event`/`Venue`; blocks `Event.Confirmed` until
  `Granted`; tracked by `Task`; risks captured in `RiskRegister`.
- **Lifecycle:** `Required → Applied → Granted | Denied | Expired`.

### LogisticsPlan
- **Definition:** The operational plan that turns the `Program` into who/what/where/when:
  the schedule of tasks, resources, load‑in/out, and dependencies.
- **Identity:** `lgp_`. One per `Event`.
- **Relationships:** belongs to one `Event`; composed of `Task`s, `Dependency`s,
  `ResourceAssignment`s; aligns with `Program` and `Booking`s; synced to `CalendarItem`s.

### Task
- **Definition:** A unit of work to be completed before, during, or after the event, with
  an owner and a due moment.
- **Identity:** `tsk_`. Natural key: `engagementId`/`eventId` + slug.
- **Key attributes:** title, owner, due, status, blocking?, checklist link, source
  (manual vs `Playbook`).
- **Relationships:** belongs to a `LogisticsPlan` (or `Engagement`); may have
  `Dependency`s; assigned to `TeamMember`/`Vendor`; may instantiate from a `Playbook`.
- **Lifecycle:** `Todo → InProgress → Blocked → Done | Cancelled`.

### Dependency
- **Definition:** A directed constraint that one object must reach a state before another
  may proceed (task→task, permit→booking, booking→beat).
- **Identity:** `dep_`. Natural key: from‑ref + to‑ref + type.
- **Relationships:** links `Task`/`Booking`/`Permit`/`Beat`; evaluated for critical path
  and risk.

### ResourceAssignment
- **Definition:** The allocation of a specific resource (team member, vendor, equipment,
  vehicle) to a task or beat for a time window.
- **Identity:** `ras_`. Natural key: resource‑ref + target‑ref + `DateWindow`.
- **Relationships:** assigns `TeamMember`/`Vendor`/equipment to `Task`/`Beat`; checked for
  conflicts; feeds `Shift`.
- **Invariants:** no resource double‑booked across overlapping windows.

### CalendarItem
- **Definition:** A scheduled entry mirrored to internal and (selectively) client/vendor
  calendars, kept in sync.
- **Identity:** `cal_`. Natural key: source‑object ref + calendar.
- **Key attributes:** title, `DateWindow`, attendees, external calendar id, sync state.
- **Relationships:** mirrors a `Task`/`Beat`/`Touchpoint`/`Booking`; syncs to external
  calendars; change here raises a `ChangeOrder` if it moves a committed item.
- **Invariants:** a moved committed `CalendarItem` must reconcile with its source object
  and notify affected `Contact`s.

### RiskRegister
- **Definition:** The living catalog of everything that could go wrong for an event and
  the planned response to each.
- **Identity:** `rrg_`. One per `Event`.
- **Relationships:** belongs to one `Event`; contains many `Risk`; each `Risk` may have a
  `Contingency`.

### Risk
- **Definition:** A specific potential adverse event (rain, vendor no‑show, permit denial,
  allergy exposure, schedule slip, privacy leak) with likelihood and impact.
- **Identity:** `rsk_`. Natural key: `eventId` + category + descriptor.
- **Key attributes:** category, likelihood, impact, owner, trigger signals, status,
  residual rating.
- **Relationships:** lives in `RiskRegister`; mitigated by `Contingency`; if it occurs,
  becomes an `Incident`; weather risks watched by `WeatherWatch`.
- **Lifecycle:** `Identified → Mitigated → Accepted | Realized(→Incident) | Closed`.

### Contingency
- **Definition:** A pre‑planned response (a "Plan B" / playbook branch) ready to execute if
  a specific risk triggers — e.g. tent‑and‑move‑indoors for rain, substitute vendor.
- **Identity:** `ctg_`. Natural key: `riskId` + label.
- **Key attributes:** trigger condition, steps, owner, cost/impact, pre‑arranged resources
  (e.g. held fallback `Booking`).
- **Relationships:** responds to one `Risk`; may reference a fallback `Booking`/`Vendor`;
  executes as `Task`s and may become an `Incident` response.

### WeatherWatch
- **Definition:** An active monitor of forecast conditions for an outdoor‑exposed event
  with thresholds that trigger contingencies.
- **Identity:** `wwt_`. Natural key: `eventId` + `GeoLocation` + `DateWindow`.
- **Key attributes:** monitored conditions, thresholds, current forecast, alert state,
  data source `Provenance`.
- **Relationships:** watches a `Venue`/`Event`; trips a `Risk`/`Contingency`; raises a
  `Touchpoint` when action needed.

### Incident
- **Definition:** A realized problem during planning or execution that required response —
  the record of what went wrong and how it was handled.
- **Identity:** `inc_`. Natural key: `eventId` + sequence.
- **Key attributes:** description, severity, timeline, owner, resolution, client‑visible?,
  root cause, follow‑ups.
- **Relationships:** may stem from a `Risk`; affects `Vendor`(→`VendorPerformance`);
  reviewed in `QualityReview`; may spawn `ChangeOrder` and `KnowledgeAsset`.
- **Lifecycle:** `Open → Mitigating → Resolved → PostMortemDone`.

### ChangeOrder
- **Definition:** A controlled, recorded change to a confirmed event's scope, plan,
  budget, or schedule, with approvals and downstream propagation.
- **Identity:** `chg_`. Natural key: `eventId` + sequence.
- **Key attributes:** what changes, reason, cost/`Budget` delta, approver, affected
  objects, client‑communication required?
- **Relationships:** amends `Event`/`EventBrief`/`Budget`/`LogisticsPlan`/`Booking`;
  triggers `CalendarItem` updates and `Touchpoint`s.
- **Lifecycle:** `Proposed → Approved | Rejected → Applied`.

### Checklist / ChecklistRun
- **Definition:** `Checklist` is a reusable list of verification items from a `Playbook`;
  a `ChecklistRun` is one filled‑in instance for a specific event/phase.
- **Identity:** `ckl_` (template), `ckr_` (run). Run natural key: `checklistId` +
  `eventId` + phase.
- **Relationships:** template owned by `Playbook`; run attached to `Event`/`Engagement`;
  completion gates `Event` transitions.

---

## 10. Context F — Communication & Delight

### Touchpoint
- **Definition:** A planned moment of contact with a client or guest — the unit of the
  relationship cadence (welcome, milestone update, reminder, thank‑you).
- **Identity:** `tpt_`. Natural key: `engagementId`/`eventId` + audience + purpose +
  planned time.
- **Key attributes:** audience, purpose, planned moment, channel, owner, template,
  status, tone.
- **Relationships:** belongs to an `Engagement`/`Event`; targets `Client`/`Guest`
  `Contact`s; realized by `Message`(s); scheduled in `Cadence`; may carry a
  `DelightMoment`.
- **Lifecycle:** `Planned → Scheduled → Sent → Acknowledged | Failed`.

### Message
- **Definition:** A single concrete communication actually sent (or received) on a
  channel.
- **Identity:** `msg_`. Natural key: channel message id (provider) or internal seq.
- **Key attributes:** direction, channel, from/to `Contact`, body, attachments, template
  ref, send/receipt state.
- **Relationships:** realizes a `Touchpoint` or belongs to a `Thread`; to/from a
  `Contact`; may be drafted from an AI `Suggestion` after `HumanReview`.
- **Invariants:** outbound only on consented channels (§5 `Contact` invariant); client/
  guest‑facing messages are human‑approved (never raw AI).

### MessageTemplate
- **Definition:** A reusable, brand‑voiced template for a class of communication, with
  personalization slots.
- **Identity:** `mtp_`. Natural key: slug + version.
- **Relationships:** instantiated into `Message`s; personalized from `ClientProfile`/
  `Guest` data.

### Cadence
- **Definition:** The defined rhythm of touchpoints across an engagement's lifecycle — the
  communication plan that makes high‑touch service feel consistent.
- **Identity:** `cdn_`. Natural key: `serviceTierId` or `engagementId` + version.
- **Relationships:** schedules many `Touchpoint`; varies by `ServiceTier`.

### Invitation
- **Definition:** The formal request for a guest to attend an event, with RSVP mechanics.
- **Identity:** `inv_`. Natural key: `eventId` + `guestId`.
- **Key attributes:** design ref, sent state, channel, RSVP link, plus‑one allowance.
- **Relationships:** for one `Guest` to one `Event`; produces an `RSVP`; realized as a
  `Deliverable` (its design) and a `Message`.

### RSVP
- **Definition:** A guest's response to an invitation, with attendance and needs.
- **Identity:** `rsv_`. Natural key: `invitationId`.
- **Key attributes:** response, headcount, dietary/accessibility/sensory needs, notes.
- **Relationships:** answers one `Invitation`; updates `Guest` state and headcount;
  feeds `LogisticsPlan` and catering `Deliverable`.

### Update
- **Definition:** A proactive announcement to clients or guests about a change or piece of
  news (time change, what‑to‑bring, weather call).
- **Identity:** `upd_`. Natural key: `eventId` + sequence.
- **Relationships:** sent to `Guest`/`Client` audiences; often triggered by `ChangeOrder`
  or `WeatherWatch`; realized as `Touchpoint`/`Message`.

### DelightMoment
- **Definition:** An unscripted‑feeling surprise gesture toward a client or guest that
  exceeds expectation (a handwritten note, a remembered detail, a small bespoke gift).
- **Identity:** `dlm_`. Natural key: `engagementId`/`eventId` + recipient + label.
- **Key attributes:** recipient, basis (`ProfileSignal`/occasion), gesture, owner,
  delivered state, reaction.
- **Relationships:** targets `Client`/`Guest`; may pair with a `SignatureTouch`; sourced
  from `ClientProfile`; effect captured in `FeedbackSignal`.

### FeedbackSignal
- **Definition:** Any captured reaction or sentiment from a client or guest — explicit
  (survey, message) or observed — used to measure delight and improve.
- **Identity:** `fbk_`. Natural key: source `Contact` + target object + timestamp.
- **Key attributes:** sentiment, target (`Event`/`Beat`/`Vendor`/service), verbatim,
  `Provenance`, consent for use (e.g. testimonial).
- **Relationships:** about an `Event`/`Beat`/`Vendor`/`TeamMember`; feeds
  `ExceptionalityScore`, `VendorPerformance`, `QualityReview`, and (with consent)
  `Showcase`/`Referral`.

### Thread
- **Definition:** A grouped conversation across messages with a contact or party.
- **Identity:** `thr_`. Natural key: participants + channel + topic.
- **Relationships:** groups many `Message`; tied to an `Engagement`/`Event`.

---

## 11. Context G — Marketing & Distribution

### Lead
- **Definition:** A prospective household not yet (or not currently) under engagement.
- **Identity:** `led_`. Natural key: best identifying `ContactChannel` or household name.
- **Key attributes:** source, fit/qualification, status, discretion, estimated tier.
- **Relationships:** may convert to a `Household` + `Engagement`; arrives via `Channel`/
  `Campaign`/`Referral`; profiled by consented `ProfileSignal`; sits in `Funnel`.
- **Lifecycle:** `New → Qualified → Nurtured → Won(→Household) | Lost | Waitlisted`.

### Inquiry
- **Definition:** A specific inbound request expressing interest in an event.
- **Identity:** `inq_`. Natural key: `leadId`/`householdId` + received time.
- **Relationships:** from a `Lead`/`Household`; seeds an `EventBrief` if won.

### Channel
- **Definition:** A distribution surface through which leads and referrals arrive (referral
  network, concierge partners, private events, social, press).
- **Identity:** `chn_`. Natural key: name.
- **Relationships:** sources `Lead`s; used by `Campaign`s.

### Campaign
- **Definition:** A coordinated marketing effort targeting a segment via channels with a
  goal.
- **Identity:** `cmp_`. Natural key: name + `DateWindow`.
- **Relationships:** targets a `Segment`; uses `Channel`s and `Showcase`s/`BrandAsset`s;
  generates `Lead`s.

### Segment
- **Definition:** A defined audience grouping of households/leads sharing attributes used
  to target and personalize (and to check peer‑collision for uniqueness).
- **Identity:** `seg_`. Natural key: definition hash.
- **Relationships:** groups `Household`/`Lead`; informed by `RelationshipEdge` and
  `ProfileSignal`; consumed by `Campaign` and `ConceptVariant` collision checks.

### Showcase
- **Definition:** A past event packaged (with strict consent and discretion) as marketing
  proof — a case study or portfolio piece.
- **Identity:** `shw_`. Natural key: `eventId` + version.
- **Key attributes:** narrative, assets, anonymization level, consented usage scope.
- **Relationships:** derived from an `Event`; gated by `Consent` (client + minor
  protections, §11); used by `Campaign` and `Referral`.
- **Invariants:** no `Celebrant`/`Guest` identifying content without explicit guardian
  `Consent`; honors `Household.discretion`.

### Referral
- **Definition:** An introduction of a new prospect by an existing client or partner.
- **Identity:** `ref_`. Natural key: referrer ref + referee ref.
- **Relationships:** from a `Client`/partner; creates a `Lead`; tracked for reward;
  follows `RelationshipEdge`.

### Funnel
- **Definition:** The ordered set of pipeline stages a lead/engagement passes through, used
  to manage distribution and conversion.
- **Identity:** `fnl_` (definition) with stage refs.
- **Relationships:** positions `Lead`/`Engagement`; reported on.

### Waitlist
- **Definition:** Ordered demand we cannot currently serve, preserved for capacity
  management and exclusivity.
- **Identity:** `wtl_`. Natural key: entry per `Lead` + desired `DateWindow`.
- **Relationships:** holds `Lead`s; feeds `Engagement` creation when capacity frees.

### BrandAsset
- **Definition:** A reusable brand artifact (logo, voice guide, photography, deck) used in
  marketing and client‑facing materials.
- **Identity:** `bas_`. Natural key: slug + version.
- **Relationships:** used by `Campaign`, `Showcase`, `MessageTemplate`.

---

## 12. Context H — Operations & Team

### TeamMember
- **Definition:** A person on our own staff who plans, designs, or delivers events.
- **Identity:** `tmb_`. Natural key: corporate identity (email).
- **Key attributes:** name, skills, certifications, availability, `Role`s.
- **Relationships:** holds `Role`(s); may be a `Tastemaker`; assigned via
  `ResourceAssignment`/`Shift`; member of a `Pod`; owner of `Task`s/`Touchpoint`s.

### Role
- **Definition:** A named bundle of responsibilities and decision rights (Producer,
  Tastemaker, Coordinator, Client Lead, On‑site Captain).
- **Identity:** `rol_`. Natural key: name.
- **Relationships:** held by `TeamMember`s; referenced by `Playbook`/`Task` ownership.

### Pod
- **Definition:** The small cross‑functional team assigned to a household/engagement to
  deliver high‑touch continuity.
- **Identity:** `pod_`. Natural key: name or `engagementId`.
- **Relationships:** groups `TeamMember`s; assigned to `Engagement`(s).

### ServiceTier
- **Definition:** The level of high‑touch service purchased, which sets cadence, staffing,
  inclusions, and standards.
- **Identity:** `stl_`. Natural key: name + version.
- **Key attributes:** inclusions, `Cadence`, staffing model, `ServiceStandard`s, price
  basis.
- **Relationships:** chosen per `Engagement`; drives `Cadence`, `Pod` size,
  `ServiceStandard`.

### ServiceStandard
- **Definition:** A measurable commitment about *how* service is delivered (response time,
  proactivity, error handling) — the operational analog to `ExperienceStandard`.
- **Identity:** `ssd_`. Natural key: code + version.
- **Relationships:** bound to `ServiceTier`; measured against `Engagement`; breaches raise
  `Incident`/`QualityReview`.

### Playbook
- **Definition:** A reusable standard operating procedure encoding how a recurring kind of
  work is done well and consistently (sourcing, load‑in, rain call, complaint recovery).
- **Identity:** `pbk_`. Natural key: slug + version.
- **Key attributes:** steps, owning `Role`, embedded `Checklist`(s), branch
  `Contingency`s, quality bar.
- **Relationships:** instantiates `Task`s/`Checklist`s onto an `Event`/`Engagement`;
  source of `Contingency`s; improved by `QualityReview`/`KnowledgeAsset`.

### Shift
- **Definition:** A staffed time block on event day assigning team (and vendor) people to
  on‑site roles.
- **Identity:** `shf_`. Natural key: `eventId` + role + `DateWindow`.
- **Relationships:** staffs the `Program`/`Beat`s; composed of `ResourceAssignment`s.

### QualityReview
- **Definition:** A structured post‑event (or post‑incident) assessment of what was
  delivered against standards, capturing learnings.
- **Identity:** `qrv_`. Natural key: `eventId` (or `incidentId`) + reviewer.
- **Key attributes:** scores vs `ExperienceStandard`/`ServiceStandard`, what worked,
  defects, actions.
- **Relationships:** reviews an `Event`/`Incident`; updates `ExceptionalityScore`,
  `VendorPerformance`, `Playbook`, `MotifLibrary`; produces `KnowledgeAsset`.

### KnowledgeAsset
- **Definition:** A captured, reusable piece of institutional knowledge (a fix, a vendor
  insight, a winning motif pairing, a recovery script).
- **Identity:** `kna_`. Natural key: slug + version.
- **Relationships:** distilled from `Incident`/`QualityReview`/`FeedbackSignal`; feeds
  `Playbook`, `MotifLibrary`, and AI `KnowledgeBase`.

### Engagement
- **Definition:** One contracted project to plan and deliver an event (or tight series)
  for a household — the unit of work, staffing, billing, and SLA. **Aggregate root.**
- **Identity:** `eng_`. Natural key: `householdId` + primary `eventId`/season.
- **Key attributes:** status, `ServiceTier`, contract ref, `Budget` ref, assigned `Pod`,
  `Cadence`.
- **Relationships:** belongs to one `Household`; owns one (or few) `Event`; has one
  `ServiceTier`, one `Pod`, one `Budget`, one `Cadence`, many `Task`/`Touchpoint`.
- **Lifecycle:** `Inquiry → Proposed → Contracted → Active → Delivered → Closed |
  Lost`.
- **Invariants:** cannot reach `Active` without signed contract, assigned `Pod`, and
  funded `Budget`; all client data use governed by `Consent`.

---

## 13. Context I — AI Enablement (abstracted internal layer)

> This context exists so AI can be *used everywhere internally* and *seen nowhere
> externally*. Every object here sits behind a `HumanReview` gate before its output can
> become a client‑, guest‑, vendor‑, or world‑facing action. This is the structural
> encoding of "abstract AI out of the equation."

### AICapability
- **Definition:** A named, governed AI‑assisted function the business offers internally
  (e.g. `ConceptIdeation`, `MotifDecomposition`, `RiskScan`, `MessageDrafting`,
  `ProfileEnrichment`, `VendorMatch`). *(Named `AICapability` to disambiguate from vendor
  `Capability`.)*
- **Identity:** `aic_`. Natural key: name + version.
- **Key attributes:** purpose, inputs, output type, allowed autonomy level, required
  `PolicyGuardrail`s, mandatory `HumanReview`?
- **Relationships:** executed by an `Agent`; produces `Suggestion`/`GuardedAction`;
  constrained by `PolicyGuardrail`; reads `KnowledgeBase`.

### Agent
- **Definition:** A configured AI worker that performs an `AICapability` within set
  guardrails.
- **Identity:** `agt_`. Natural key: name + config version.
- **Relationships:** performs `AICapability`s; emits `Invocation`s; bound by
  `PolicyGuardrail`.

### Invocation
- **Definition:** A single, logged execution of an agent/capability — the auditable atom
  of AI use.
- **Identity:** `ivk_`. Natural key: agent + request hash + timestamp.
- **Key attributes:** inputs (refs, not copies of sensitive data where avoidable),
  outputs, cost, latency, `Provenance` of inputs, policy checks passed.
- **Relationships:** runs an `AICapability`; yields `Suggestion`/`GuardedAction`; linked to
  an `AuditEvent`.

### Suggestion
- **Definition:** A proposed output from AI (a concept, a draft message, a risk list, an
  enrichment) presented to a human for acceptance, edit, or rejection — never auto‑applied.
- **Identity:** `sgt_`. Natural key: `invocationId` + index.
- **Key attributes:** content, confidence, rationale, target object, review state.
- **Relationships:** produced by `Invocation`; reviewed via `HumanReview`; on acceptance
  becomes/updates a domain object (`Concept`, `Message`, `Risk`, `ProfileSignal`, …).
- **Lifecycle:** `Proposed → UnderReview → Accepted | Edited | Rejected`.
- **Invariant:** no client/guest/vendor‑facing artifact is created directly from a
  `Suggestion` without an `Accepted`/`Edited` `HumanReview`.

### GuardedAction
- **Definition:** An action an agent is permitted to take *automatically* only within an
  explicitly bounded, low‑risk policy envelope (e.g. drafting an internal task, flagging a
  forecast). Anything outside the envelope downgrades to a `Suggestion`.
- **Identity:** `gac_`. Natural key: `invocationId` + action.
- **Relationships:** authorized by `PolicyGuardrail`; logged as `AuditEvent`.
- **Invariant:** the envelope explicitly excludes any external communication, financial
  commitment, or physical/world‑affecting change.

### HumanReview
- **Definition:** The mandatory checkpoint where a `TeamMember` (often a `Tastemaker` for
  creative, a Producer for operational) accepts, edits, or rejects a `Suggestion`.
- **Identity:** `hrv_`. Natural key: `suggestionId` + reviewer.
- **Key attributes:** reviewer, decision, edits, rationale, timestamp.
- **Relationships:** gates `Suggestion`s; recorded in `AuditEvent`; reviewer accountability
  via `Role`.

### PolicyGuardrail
- **Definition:** A rule constraining what AI may do, see, or output (data it may touch,
  autonomy ceiling, prohibited actions, consent/lawful‑basis requirements).
- **Identity:** `pgr_`. Natural key: code + version.
- **Relationships:** constrains `AICapability`/`Agent`/`GuardedAction`; enforces `Consent`
  and §11 governance.

### KnowledgeBase
- **Definition:** The curated internal corpus the AI layer reasons over (playbooks,
  motifs, past events, vendor insights) — distinct from raw operational data.
- **Identity:** `kb_` with `Embedding` entries.
- **Relationships:** built from `KnowledgeAsset`/`Playbook`/`MotifLibrary`/(consented)
  history; read by `AICapability`; never includes data lacking a lawful basis.

---

## 14. Context X — Cross‑cutting

### 14.1 Money & budget

#### Budget
- **Definition:** The financial envelope and plan for an engagement/event, tracking
  planned vs. committed vs. actual.
- **Identity:** `bdg_`. One per `Engagement`/`Event`.
- **Key attributes:** total `Money`, allocations (`BudgetLine`s), committed, actual,
  margin target.
- **Relationships:** belongs to `Engagement`/`Event`; composed of `BudgetLine`s; consumed
  by `Booking`/`Deliverable`; constrains `Concept` selection.
- **Invariant:** committed must not exceed total without an `Approved` `ChangeOrder`.

#### BudgetLine
- **Definition:** An allocation within a budget to a category, deliverable, or booking.
- **Identity:** `bdl_`. Natural key: `budgetId` + category/target.
- **Relationships:** rolls up to `Budget`; maps to `Booking`/`Deliverable`.

#### Invoice / Payment
- **Definition:** `Invoice` is a billed amount to the client; `Payment` is a settled
  transfer (in either direction, incl. vendor payments).
- **Identity:** `inv_`?? → **`ivc_`** (invoice), `pay_` (payment). *(Invitation already
  uses `inv_`; invoices use `ivc_`.)*
- **Relationships:** `Invoice` against `Engagement`; `Payment` settles `Invoice` or
  `Booking` deposit; both post to `Ledger`/`Budget` actuals.

### 14.2 Consent, privacy & minor protection (governance)

These are constraints realized through objects already defined (`Consent`,
`ProfileSignal`, `Provenance`), plus:

#### LawfulBasis
- **Definition:** The recorded justification permitting a given data use (consent,
  contract, legitimate interest) — required for any `enriched`/`scraped` `ProfileSignal`.
- **Identity:** value referenced by `Consent`/`ProfileSignal`; enumerated.
- **Rule:** enrichment/scraping `AICapability` (`ProfileEnrichment`) may run only where a
  `LawfulBasis` is present and the subject is not a protected minor without guardian
  `Consent`.

#### RetentionPolicy
- **Definition:** The rule governing how long a category of data is kept before
  expiry/purge; tighter for `Celebrant`/`Guest` (minors).
- **Identity:** `rtp_`. Natural key: data category + subject class.
- **Relationships:** applied to `ProfileSignal`/`Message`/`Showcase`; sets `expiresAt`.

#### MinorProtection (rule set)
- **Definition:** The default‑on protections for any `isMinor` subject: data
  minimization, guardian‑only consent, no marketing use without explicit consent, tighter
  retention, restricted enrichment.
- **Realized by:** invariants on `Celebrant`/`Guest`, `Consent`, `RetentionPolicy`,
  `Showcase`, `ProfileEnrichment` guardrails.

### 14.3 Audit & provenance

#### AuditEvent
- **Definition:** An immutable record of a significant action (who/what/when/why) across
  the system — especially data access, consent changes, AI invocations, and money.
- **Identity:** `aud_`. Append‑only; natural key: actor + action + target + timestamp.
- **Relationships:** references any object; emitted by sensitive operations; never
  mutated.

#### Provenance *(value object)*
- **Definition:** The origin record attached to any sourced datum: source, method,
  collector, captured‑at, confidence, source reference/URL.
- **Embedded in:** `ProfileSignal`, `InspirationSource`, `Trend`, `WeatherWatch`,
  `FeedbackSignal`, `Invocation` inputs.

### 14.4 Shared value objects (defined once, embedded everywhere)

| Value object | Definition | Fields |
|---|---|---|
| `Money` | An amount in a currency | amount, currency |
| `DateWindow` | A start/end span (or open‑ended) | start, end, tz |
| `GeoLocation` | A point on earth | lat, lng, precision |
| `Address` | A postal/physical address | lines, locality, region, country, postcode |
| `ContactChannel` | A reachable address on a medium | type(email/phone/messenger), value, verified |
| `Provenance` | Origin of a datum | source, method, collectedBy, capturedAt, confidence, ref |
| `Score` | A rated value on a rubric dimension | dimension, value, scale, basis |
| `Attachment` | A stored file/media reference | uri, mime, hash, rightsStatus |

---

## 15. Cross‑context relationship map (the wiring)

Read top‑to‑bottom as "designs into / drives."

```
Household ──< Engagement ──< Event
   │             │             │
   │             │             ├── EventBrief ──(bounds)── EventConcept ──< Program ──< Beat
   │             │             │                              │                         │
   │             │             │                       Concept/ConceptVariant     SignatureTouch
   │             │             │                              ▲                         │
   │             │             │                         Motif (MotifLibrary)      DelightMoment
   │             │             │                              ▲
   │             │             │                       TasteProfile ──< TasteSignal ── InspirationSource
   │             │             │                              ▲                         ▲
   │             │             │                       PreferenceModel ── Trend         │
   │             │             │                                                        │
   │             │             ├── Deliverable ──(fulfilled by)── Booking ──< Quote ── Vendor ──< Offering
   │             │             │                                     │                    │
   │             │             │                              VendorContract        ContainmentPolicy
   │             │             │                                                          │
   │             │             ├── LogisticsPlan ──< Task ──< Dependency            VendorPerformance
   │             │             │        │              │                                  ▲
   │             │             │     Venue ── Permit   ResourceAssignment ──< Shift   Incident/QualityReview
   │             │             │        │                                              
   │             │             ├── RiskRegister ──< Risk ──< Contingency ── WeatherWatch
   │             │             │                       │
   │             │             │                   Incident ── ChangeOrder ── CalendarItem
   │             │             │
   │             │             ├── Touchpoint ──< Message (Thread)  ── MessageTemplate
   │             │             │        │
   │             │             │     Invitation ── RSVP ── Guest ──< GuestParty
   │             │             │
   │             │             └── ExceptionalityScore ── ExperienceStandard ── FeedbackSignal
   │             │
   │          ServiceTier ── Cadence ── ServiceStandard ── Pod ──< TeamMember ── Role
   │             │                                                      │
   │          Budget ──< BudgetLine ── Invoice ── Payment          Tastemaker
   │
   ├── Client / Member / Celebrant ── Contact ── ContactChannel
   ├── ClientProfile ──< ProfileSignal ── Provenance ── Consent ── LawfulBasis
   └── RelationshipEdge (ProfileGraph) ── Segment ── Campaign ── Channel ── Lead ── Referral ── Showcase

AI Enablement (cross‑cuts all): AICapability ── Agent ── Invocation ── Suggestion ──[HumanReview]──▶ domain object
                                 PolicyGuardrail ── KnowledgeBase           GuardedAction (bounded)
Audit/Governance (cross‑cuts all): AuditEvent · RetentionPolicy · MinorProtection
```

---

## 16. Aggregate composition (consistency boundaries)

| Aggregate root | Owns (shared lifecycle) | References (by ID, independent lifecycle) |
|---|---|---|
| `Household` | `Client`, `Member`, `Celebrant`, `ClientProfile`, `ProfileSignal`, `Consent`, `RelationshipEdge` | `Engagement`, `Lead` history |
| `Engagement` | `Budget`/`BudgetLine`, `Pod` assignment, `Cadence` instance, engagement‑level `Task`/`Touchpoint` | `Household`, `ServiceTier`, `Event`, `Invoice` |
| `Event` | `EventBrief`, `EventConcept`, `Program`/`Beat`, `Deliverable`, `SignatureTouch`, `Guest`/`GuestParty`/`Invitation`/`RSVP`, `LogisticsPlan`/`Task`, `RiskRegister`/`Risk`/`Contingency`, `Incident`, `ChangeOrder`, `ExceptionalityScore`, event `Touchpoint` | `Concept`/`Motif`, `Vendor`/`Booking`/`Quote`, `Venue`/`Permit`, `CalendarItem`, `Budget` |

Library/registry objects with their own lifecycles, shared across events:
`MotifLibrary`/`Motif`, `Concept`, `TasteProfile`, `PreferenceModel`, `Trend`,
`Vendor` (+supply), `Roster`, `Playbook`/`Checklist`, `ServiceTier`/`ServiceStandard`,
`ExperienceStandard`, `KnowledgeAsset`, `BrandAsset`, all AI‑Enablement objects, and all
Cross‑cutting governance objects.

---

## 17. State vocabularies (canonical enums)

These status sets are canonical; UIs and services must use exactly these.

- **Engagement:** Inquiry · Proposed · Contracted · Active · Delivered · Closed · Lost
- **Event:** Briefing · Designing · Planning · Confirmed · InProduction · LiveDay · Wrap · Reviewed
- **Concept:** Draft · InReview · Approved · Selected · Archived
- **Guest:** Invited · Responded · Confirmed · Attended · NoShow
- **Quote:** Requested · Received · Accepted · Rejected · Expired
- **Booking:** Held · Confirmed · Fulfilled · Cancelled · NoShow
- **Permit:** Required · Applied · Granted · Denied · Expired
- **Task:** Todo · InProgress · Blocked · Done · Cancelled
- **Risk:** Identified · Mitigated · Accepted · Realized · Closed
- **Incident:** Open · Mitigating · Resolved · PostMortemDone
- **ChangeOrder:** Proposed · Approved · Rejected · Applied
- **Touchpoint:** Planned · Scheduled · Sent · Acknowledged · Failed
- **Suggestion:** Proposed · UnderReview · Accepted · Edited · Rejected
- **Consent:** Granted · Active · Withdrawn · Expired
- **Lead:** New · Qualified · Nurtured · Won · Lost · Waitlisted
- **Deliverable:** Specified · Sourced · InProduction · Delivered · Accepted · Rejected

---

## 18. Amending this keystone

This document changes only by deliberate edit. When adding or changing an object:
add/keep the fixed shape (§0), assign an ID prefix that is unique across §3 and the
glossary, place it in exactly one context, declare its identity and aggregate, and add it
to the glossary. If a concept does not fit an existing context, prefer adding it to
Cross‑cutting (§14) over blurring a context boundary.
