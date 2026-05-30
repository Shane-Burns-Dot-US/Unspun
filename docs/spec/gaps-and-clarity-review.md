# Unspun — Gaps & Clarity Review

**Type:** Completeness + clarity QA pass
**Subject:** [`domain-keystone.md`](./domain-keystone.md), [`glossary.md`](./glossary.md)
**Companion to:** [`mece-review.md`](./mece-review.md)

> Two questions only: **what is missing** (content the system needs but the catalog
> doesn't contain) and **what is unclear** (content that is present but ambiguous,
> contradictory, or unenforceable as written). This is distinct from the MECE review,
> which tested *grouping*. Where an item also appeared there, it is marked `[also MECE]`
> and only the *new* angle is added.

---

## 1. Headline

The catalog is a strong **static** model — objects, identity, relationships, states. Its
biggest omission is the **dynamic layer**: nothing says *what causes a state to change,
who is allowed to cause it, or how a rule that spans several objects is enforced.* Half of
the "unclear" findings below dissolve once that layer exists. The second theme is that
several **value-proposition-critical mechanics are named but not specified** (the "top
10%" measurement, taste decomposition, the discretion↔marketing tension). The third is
**measurement hygiene** — many fields (`confidence`, `discretion`, `likelihood`,
sentiment) are referenced without a defined scale, so they can't be compared or enforced.

---

## 2. Missing — the dynamic / behavioral layer (highest priority)

The model defines *nouns* and their *states* but not the *verbs* that move them.

| # | Missing | Why it's needed | Proposed addition |
|---|---|---|---|
| D‑1 | **Domain Events** (e.g. `EventConfirmed`, `BookingCancelled`, `RSVPReceived`, `WeatherThresholdBreached`, `ConsentWithdrawn`) | The system is full of reactions ("WeatherWatch *raises* a Touchpoint", "ChangeOrder *triggers* CalendarItem updates", "ConsentWithdrawn *excludes* signals") but the trigger itself isn't an object. Without domain events these reactions are prose, not mechanism. | A first‑class `DomainEvent` archetype (immutable, append‑only, alongside `AuditEvent`). Catalog the canonical events per aggregate. |
| D‑2 | **Transition triggers & guards** | `§17` lists *states* but not the *command/event* that causes each transition, nor the *guard* (precondition) and *who* may invoke it. "Briefing → Designing" — triggered by what, gated on what, by which `Role`? | For each lifecycle, a small transition table: `from → to : trigger [guard] {actor role}`. |
| D‑3 | **Cross‑aggregate process / saga** | The strongest invariants span aggregates: "`Event` cannot `Confirm` without funded `Budget` + secured `Venue` + `Granted` Permits." No single aggregate can enforce this. As written it's an assertion with no owner. | A `Process`/orchestration concept (e.g. "Confirmation Process", "Rain‑Call Process") that watches events and enforces multi‑object gates. The `Contingency` already implies this; generalize it. |
| D‑4 | **Authorization model** | `Role` exists, but nothing maps *role → permitted action on object/state*. Who can approve a `ChangeOrder`, withdraw `Consent` on a client's behalf, accept a `Suggestion`, or override a `ContainmentPolicy`? | A `Permission`/`Policy` mapping (actor `Role` × action × object/state). Distinct from `PolicyGuardrail`, which governs *AI*, not *people*. |
| D‑5 | **Reminder / internal alert** vs external `Message` | "WeatherWatch raises a Touchpoint" conflates *internal staff alerting* with *client communication*. There is no internal notification object. | An internal `Alert`/`Notification` distinct from client‑facing `Touchpoint`/`Message`. |

---

## 3. Missing — value-proposition mechanics that are named but unspecified

| # | Missing | The gap | Proposed addition |
|---|---|---|---|
| V‑1 | **The "top 10%" benchmark** | `ExceptionalityScore` claims a "percentile" but **against what population?** "Top 10% of events any of the kids will go to" has no reference set in the model, so the core promise is unmeasurable. | A `Benchmark`/`ReferencePopulation` object (peer events in a `Segment`/region/age band) the percentile is computed against; define how it's assembled and refreshed. |
| V‑2 | **Taste decomposition & aggregation (core IP)** | The brief stresses *mirroring, decomposing, and aggregating* tastemaker taste. The model has `TasteProfile`/`AestheticVector`/`PreferenceModel` as containers but **no description of the decomposition method** (what dimensions, how a reference is broken into them) or the **aggregation rule** (how multiple tastemakers/clients combine, whose taste wins on conflict). | Specify: the fixed taste‑dimension schema; the decomposition step (reference → weighted dimensions); the aggregation/conflict rule; how the tastemaker's veto overrides aggregation. |
| V‑3 | **Discretion ↔ marketing conflict** | `Household.discretion` and `Showcase` are in direct tension: affluent, discreet clients are the ones you most want to showcase and least able to. The model holds both but **never reconciles them.** | A `DiscretionPolicy` that gates *every* outward use (Showcase, Referral, testimonial via `FeedbackSignal`), plus an "anonymized showcase" path. Make discretion a hard precondition, not a flag. |
| V‑4 | **"Slightly unique" mechanism** | `ConceptVariant` promises a peer‑collision check "against recent events in the same ProfileGraph/Segment" — but **no window, no similarity measure, no threshold.** Unenforceable. | Define the collision check: comparison window, similarity function over taste dimensions/motifs, and the novelty‑delta threshold that passes. |

---

## 4. Missing — domain content gaps (net‑new beyond the MECE review)

| # | Missing | Why it matters here | Proposed addition |
|---|---|---|---|
| C‑1 | **Billing / business model** | Everything financial assumes a model that's never stated: are clients billed **cost‑plus, fixed‑fee, or commission on vendor spend**? `Budget.marginTarget` hints cost‑plus; `Invoice`↔`Budget` relationship is undefined. This drives Quote, Budget, Invoice, Margin semantics. `[also MECE: finance unity]` | State the pricing model(s) explicitly; tie `Invoice` derivation to `Budget`/`Booking` accordingly. |
| C‑2 | **Full‑event cancellation / postponement / churn** | `Engagement` has `Lost`; `Booking` has `Cancelled`; but **cancelling or postponing a *Confirmed* event** (force majeure, family emergency) has no flow — and these are high‑stakes for refunds and vendor penalties. | Add `Cancelled`/`Postponed` to `Event`; define the unwind process (which bookings cancel, refund/penalty handling) as a `Process` (D‑3). |
| C‑3 | **Series / package / multiple children** | `Engagement` "owns one (or few) Event" (see U‑1). Twins, or two siblings' parties in a season — **is that one engagement or two?** No `Package`/`Series` object. | Decide and model: a `Package` grouping multiple `Event`s under one `Engagement`, or one `Engagement` per `Event`. |
| C‑4 | **Dual audience for guest comms (parent + child)** | Guests are children, but the *reachable* party is the parent. `Invitation`/`RSVP`/`Update` don't distinguish the child invitee from the responding/consenting adult. | Model the invitee (`Guest`, a child) separately from the responsible adult `Contact`; route comms and consent to the adult. |
| C‑5 | **Consent vocabulary & erasure** | `Consent` references "purposes / data categories / sensitivity class" but **none are enumerated**, so consent cannot actually be checked in code. Withdrawal "excludes" signals but the **erasure‑vs‑audit‑retention conflict** isn't resolved. `[also MECE: governance]` | Enumerate purposes, data categories, and sensitivity classes; define the DSAR / right‑to‑erasure process and how it coexists with immutable `AuditEvent`. |
| C‑6 | **Scraping source governance** | "scraping/profiling the client" is a stated capability; the model has `Provenance` + `LawfulBasis` but **no allow‑list of permissible sources or a profiling policy** — the highest‑risk activity is the least specified. | A `SourcePolicy`/allow‑list and explicit rules for `inferred`/`scraped` signals about minors (default deny). |
| C‑7 | **Category / taxonomy object** | Vendor `Capability` is keyed on "taxonomy code" but **there is no taxonomy object** — the same category lives as free text across vendors, deliverables, motifs. | A shared `Category`/`Taxonomy` referenced by `Capability`, `Deliverable`, `Offering`, `Motif`. |

---

## 5. Missing — measurement & semantics hygiene

| # | Missing | Where it bites | Proposed addition |
|---|---|---|---|
| M‑1 | **Standardized scales** | `confidence` (on `ProfileSignal`, `Provenance`, `Suggestion`, `Trend`, `ClientProfile`), `likelihood`/`impact` (`Risk`), `sentiment` (`FeedbackSignal`), `discretion` (Household/Vendor/Event), `strength` (`RelationshipEdge`) — all referenced, **none defined**. Values can't be compared, rolled up, or thresholded. | Define each as a named enum/scale once (in the Shared Kernel) and reference it everywhere. `discretion` especially must be **one** scale, not three. |
| M‑2 | **Currency / base‑currency rule** | `Money` has a currency but destination/multi‑currency events and `Budget` roll‑ups have **no base‑currency or FX rule.** | A base currency per `Engagement`/`Budget` and an FX‑at‑date convention. |
| M‑3 | **Versioning & effective‑dating semantics** | Many objects are "versioned" (`TasteProfile`, `Concept`, `ServiceTier`, `Playbook`, `Consent`) but **what a version means** (immutable snapshot? supersession? effective dates?) is undefined. `ClientProfile` is "living" — i.e. mutable — yet assembled from versioned/expiring signals: the **reconciliation rule is missing.** | One versioning convention (immutable versions + `effectiveFrom/To` + `supersedes`) applied uniformly; state whether `ClientProfile` is a recomputed projection or a mutable entity (see U‑6). |
| M‑4 | **Provenance for inferred data** | `ProfileSignal` capture method includes `inferred`, but `Provenance` is shaped for *external* sources (source, URL). **How an inference records its basis** (which inputs, which model `Invocation`) isn't defined — yet this is exactly what auditability of profiling requires. | Extend `Provenance` to reference the deriving `Invocation`/inputs for `inferred` signals. |

---

## 6. Unclear — cardinality & relationship precision

| # | Statement | Ambiguity | Recommended precision |
|---|---|---|---|
| U‑1 | `Engagement` "owns **one (or few)**" `Event`; Event "owned by one Engagement"; §16 lists Event as a *reference* | Three different readings (owns one / owns few / references). `[also MECE A10/ME‑12]` | Pick one: **1 Engagement → 1..n Events by reference**, with `Package` (C‑3) if grouping is needed. State the exact cardinality. |
| U‑2 | `Deliverable` "fulfilled by `Booking`/`Offering`"; `Booking` "realizes `Deliverable`s" | Is it 1 Booking → many Deliverables, 1 Deliverable → many Bookings, or both? Affects budgeting and fulfilment tracking. | Define the cardinality explicitly (likely many‑to‑many via a fulfilment link). |
| U‑3 | `Beat` "needs Deliverables and ResourceAssignments"; `Program` "aligns with LogisticsPlan" | The join between the **experiential plan** (Program/Beat) and the **logistics plan** (Task/Resource) is asserted ("aligns"), not structured. How does a Beat actually pull its resources? | Define the link object/keys between `Beat` and `Task`/`ResourceAssignment`. |
| U‑4 | `Cadence` "schedules many Touchpoint"; `Touchpoint` "scheduled in Cadence" | Does a `Cadence` **generate** Touchpoints (template→instances) or just reference them? Template‑vs‑instance relationship unstated. | State that `Cadence` is a template that *instantiates* `Touchpoint`s per engagement; clarify regeneration on `ServiceTier` change. |
| U‑5 | `Capability` (vendor) identity = "vendor + taxonomy code" | Is `Capability` a **per‑vendor instance** ("this vendor does X") or a **shared category**? The name and key conflict. `[also: C‑7]` | Split: shared `Category` (taxonomy) + `VendorCapability` (the per‑vendor link). |

---

## 7. Unclear — definition ambiguities

| # | Object / field | What's ambiguous | Recommended fix |
|---|---|---|---|
| U‑6 | `ClientProfile` "living portrait" | Mutable entity or recomputed projection over signals? Determines who can edit it and how it reconciles with expiring/withdrawn signals (M‑3). | Declare it a **derived projection** over consented `ProfileSignal`s + an editable "curator notes" layer; auto‑recomputes on signal change. |
| U‑7 | `Contact` "linked to **exactly one** of Client/Member/Guest/VendorContact" | This **forbids the most common real case**: a parent who is a `Client` for their own child *and* a `Guest` at another family's party — central to an affluent social circle. `[also MECE ME‑5; new angle: correctness, not just consistency]` | One `Person`/`Contact` core that may hold **multiple role personas across households/events**. Remove "exactly one." |
| U‑8 | `Household` "status markers (sensitive)" | Undefined — net worth? social tier? This is the most sensitive data in the system and is described in three words. | Enumerate the marker categories, their sensitivity class, lawful basis, and retention — or remove if not justifiable. |
| U‑9 | `AestheticVector` / embedding | "Internal, derived convenience, never source of truth" — but its **actual role** (matching? generation input? ranking?) is unstated, so its necessity is unclear. | State its single purpose (e.g. similarity search for collision checks V‑4) or drop it. |
| U‑10 | `discretion` (Household) vs `discretion rating` (Vendor) vs `discretion level` (Event) vs `anonymization level` (Showcase) | Four phrasings — one concept or several? `[also M‑1]` | One named `DiscretionLevel` scale, referenced everywhere; `Showcase` anonymization derived from it. |
| U‑11 | `SignatureTouch.personalizationBasis` "which ProfileSignal/TasteSignal" | Asserts traceability to the signal that inspired it, but no structured link — so the "why this delighted them" trail isn't actually queryable. | Make it a typed reference list to the source signal(s). |
| U‑12 | `Incident.clientVisible?` and `Update`/`ChangeOrder` "client‑communication required?" | Booleans that encode a *decision* with no rule for who decides or when communication is mandatory (e.g. a safety incident must be disclosed). | Define the disclosure policy (severity/category → mandatory client comm), don't leave it as a free boolean. |

---

## 8. Priority shortlist

If addressing a subset, do these — they unblock the most downstream clarity:

1. **D‑1 + D‑2 + D‑3** — add the dynamic layer (events, transition triggers/guards, cross‑aggregate process). Resolves U‑1‑adjacent invariants and most "is asserted but unowned" prose.
2. **U‑7 + the Party pattern** — fix the person‑identity model so real social circles work (also the largest data‑quality risk).
3. **C‑5 + C‑6 + M‑4** — make consent, scraping governance, and inference provenance *enforceable*, since profiling minors is the sharpest legal/ethical edge.
4. **V‑1 + V‑4** — give "top 10%" and "slightly unique" real definitions; otherwise the core promise is unmeasurable.
5. **M‑1 (esp. one `DiscretionLevel`) + C‑1 (billing model)** — two small definitions that many objects silently depend on.
