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

---

# Addendum A — Advisor Notes (Brian Chesky)

*Written as a hired advisor. Asked to hold nothing back. The brief was: sprinkles if the
ice cream is great, brownies if it's wrong. Here's the honest version of both.*

## A.0 The honest take first

The three documents in front of me are excellent **engineering**. The object model, the
MECE cut, the gap analysis — this is the work of people who will actually ship something
that doesn't fall over. Keep all of it. That's the ice cream, and it's good ice cream.

But I have to tell you what I see, because you hired me to. **It's all designed
inside‑out.** It starts from objects, contexts, and archetypes — from the filing cabinet —
and works toward the customer. Great hospitality is designed the other way around. It
starts with a face. A six‑year‑old's face the moment the doors open. Her mother's face
when she sees the grandmother who flew in from Seoul standing in the family photo nobody
asked her to arrange. The model should be anchored on **those moments**, and then the
objects should be reverse‑engineered to *protect and produce* them.

So this addendum isn't a correction — it's a re‑anchoring. The ice cream stays. But the
dessert your customer actually ordered is an *experience*, and for that we may need to
make some brownies. Here they are.

> **The one‑line reframe:** *You are not building an event‑planning app. You are building a
> hospitality operating system whose product is a memory and a feeling.* Every field you
> capture has to earn its place by answering: *which moment of delight does this protect,
> or which one does it create?* Data that answers neither is weight.

## A.1 The 11‑star exercise (do this before you build anything)

We did this at Airbnb and it changed the company. You imagine the experience at every star
level, past the point of reason, and then you walk it back to what's buildable. Let me do
it out loud for a kid's birthday, because it tells you exactly what to capture.

- **★5 — Expected.** The party happens. Right date, right cake, vendors show up, photos
  arrive in two weeks. Nothing breaks. *(This is where most of the industry lives. It is
  not the business you described.)*
- **★6 — Reliable+.** Nothing breaks *and you knew it wouldn't*, because every vendor
  confirmed their pin‑drop, their arrival time, and their deposit before the week of.
- **★7 — Thoughtful.** Every guest got a text in their preferred channel, in sequence, and
  the favors had their names on them. The shy kid's mom got a quiet heads‑up about who
  else was coming so her daughter would know a friendly face.
- **★8 — Anticipatory.** The system scheduled the cake for 5:40pm because that's when the
  light in the garden goes gold, and the second shooter was positioned for the candle
  blow‑out from the angle that catches both the child and the parents.
- **★9 — Memorable.** That night — *that night, not in two weeks* — every family got a
  ten‑photo teaser gallery of their own child, curated, looking like a magazine.
- **★10 — Story‑worthy.** The grandmother from Seoul gets a short film with her in it. The
  host remembered the child is obsessed with a particular shade of teal and the entire
  palette quietly answered to it. Parents are texting each other asking who did this.
- **★11 — Absurd (and instructive).** The child mentions, once, three weeks before, that she
  wishes her favorite author knew it was her birthday. A signed note arrives. We don't
  build "signed author notes" — but we build the **capability to capture a wish and route
  it to a human who can make magic**, because *that* is the ★11 generalized.

Every feature you listed maps onto this ladder. The point of the exercise is that **the
data model has to reach ★11**, even if the service usually delivers ★9, because the gap
between 9 and 11 is your entire brand. The granularity you're describing isn't
over‑engineering. It's the substrate of delight. Let me make it concrete.

## A.2 Capture the *moment*, not just the *fact* — four layers you're under‑modeling

The keystone tracks *that* a thing is happening. You're right that it needs to track *how
well, in what conditions, confirmed by whom, and to what effect.* Here are the four layers
where that granularity lives, with the fields to capture. **These extend, not replace, the
existing objects.**

### A.2.1 The Memory Layer — *the party lasts four hours; the photographs last forever*

This is the most under‑modeled, highest‑leverage layer in the whole system, because **the
photograph is the product that outlives the event.** A `Deliverable` called "photography"
is not nearly enough. Make a first‑class **`MediaPlan`** and **`ShotList`**, and capture
the crew to the person.

| Capture | Field‑level detail |
|---|---|
| **Crew composition** | # photographers on site; senior/lead vs **second shooter(s)**; *confirmation* state per shooter (not "a photographer is booked" — *this named person confirmed*) |
| **Per‑shooter readiness** | equipment per shooter (bodies, lenses, lighting, backup body); **map destination set?**; **destination confirmed by *that shooter*** (lead *and* each second shooter independently); arrival time committed; **parking location as a geo pin**, not a sentence |
| **Output contract** | photos **taken** vs **delivered edited** (capture both — the ratio is a quality and trust signal); video deliverables; turnaround commitment; **delivery/transfer platform** (and whether it's outside the photographer's standard offering — capture the exception) |
| **Light & timing** | golden‑hour window for the venue/date; sun azimuth/elevation at key beats; **schedule the cake/candles/family photo *to the light*** |
| **Shot list** | structured, tied to `Beat`s **and to named people** ("celebrant + both parents", "grandmother who travelled"); must‑gets vs nice‑to‑haves; mark which are captured live on the day |
| **Resilience** | backup shooter / equipment redundancy; what happens if a body fails |
| **Rights** | usage/consent for *minors'* images, inheriting `DiscretionLevel`; who may ever see/post these |

*Sprinkles:* the **same‑night teaser gallery** (★9) should be a tracked deliverable with
its own SLA. And capture **photos delivered *per guest family*** — a parent doesn't want
800 photos, they want the 12 of *their* child. That's a delight feature hiding in your
data model.

### A.2.2 The Environment Layer — *weather isn't a checkbox, it's a set of conditions that each threaten a specific delight*

You're exactly right that this can't be binary. Don't store "weather: ok." Store the
**conditions**, and — this is the part that matters — **map each condition to the element
it affects and the threshold that triggers a contingency.**

| Condition (forecast, by hour, at venue pin) | Threatens / enables |
|---|---|
| Wind speed + gusts | balloon installs, tents, florals, candles, drone, hair |
| Sun intensity + cloud cover + **light quality window** | **photography**, guest comfort, cake melt, screen glare |
| Sun azimuth/elevation | photo angles, shade planning, **golden‑hour scheduling** |
| Temp + humidity + UV | guest comfort, melt, makeup/hair, sunscreen prompts |
| Precip probability (hourly) | the rain‑call `Contingency`, ground conditions |
| Pollen / AQI | allergy‑sensitive guests and the celebrant |

Each row is a `Risk` with a numeric threshold that auto‑fires a `Contingency` (the dynamic
layer in §2 of the main review is the engine that makes this real). "Probability of high
sun with good light for photography" becomes a *scored, monitored, actionable* signal — not
a note.

### A.2.3 The Guest Layer — *this is two‑sided, and right now it's modeled as one‑sided*

You're describing a **guest‑facing experience surface**, not just a guest *record*. Capture:

- **Import any format.** The client hands you a contact list in whatever shape it's in
  (screenshot, spreadsheet, group‑chat export). Ingest it, **filter and de‑dupe it before
  a single message goes out**, and let the host curate.
- **Capture from the guest, for the agent.** Confirm/enrich each guest's email and phone
  *through the guest*, so the event agent owns clean contact data — seeded from the
  client's messy list.
- **Confirmation beyond yes/no/maybe.** "Maybe" is the enemy of catering. Capture **passive
  signals** — opened, viewed, tapped the map, added to calendar — as a *soft* attendance
  probability, plus the hard RSVP.
- **Sequenced, multi‑phase reminders** across channels (text/email), at the right cadence —
  and turn each touch into a **phase of delight**: a Q&A offering ("any allergies? a song
  she'd love? want carpool help?"), not just a nag.
- **Host‑controlled social transparency.** *"Is Jane going? Is she bringing Tim?"* — this is
  a real and delightful feature, and a privacy minefield. Model it explicitly: the **host
  grants visibility**, guest‑to‑guest, per their request, governed by per‑guest **privacy
  disclosures and sharing preferences**. Carpool coordination falls out of this for free.
- **Physical delight, confirmed.** Staged **physical delivery of cards and pre‑gifts with
  confirmation of receipt** — a tracked `Deliverable` with a delivery state machine and a
  proof‑of‑receipt, because an unconfirmed gift is a silent failure.
- **Per‑guest personalization & the return trip.** The shy kid, the peanut allergy, the best
  friend — surfaced to vendors automatically. And post‑event: the thank‑you that includes a
  photo of *that guest's own child*. (★9 again, almost free once the Memory Layer exists.)

### A.2.4 The Vendor Layer — *make vendors want to be on your platform; that's a moat, not a feature*

This is the second thing the model under‑builds. You're describing a **two‑sided partner
platform** — the Superhost dynamic. Vendors who get value *stay*, *improve*, and *prefer
you*. Capture:

- **Vendor logins + self‑service teams.** Vendors add their own team members with
  **vendor‑customized access levels** — the lead photographer sees the brief; the second
  shooter sees only the call time, pin, and shot list. The vendor manages this, not you.
- **Calendar integration + authentication with the vendor.** Real two‑way sync and a real
  auth handshake — so availability, holds, and double‑booking prevention are live, not
  emailed.
- **Deposit → deliverable → line‑item, as a confirmed chain.** Deposit delivery and
  confirmation; **stipulations predicated on payment terms** (work unlocks when the deposit
  clears); **deliverable definitions down to specific action items**; and **per‑line‑item
  performance feedback** captured for next time ("delivered editing in 9 days, second
  shooter confirmed late twice").
- **Multi‑factor vendor rating → algorithmic recommendation.** Not one star rating —
  on‑time, deposit‑terms compliance, deliverable completeness, **confirmation discipline**
  (pins, second shooters), edit‑to‑delivery ratio, client sentiment, discretion. Roll it
  into an **internal‑facing recommendation engine** that suggests the right vendor for the
  next brief. This is your taste/quality flywheel pointed at supply.
- **Vendor value‑creation loop.** Give vendors a reason to be great *on your platform
  specifically*: visibility into their own scores, more bookings as they climb, a
  "preferred" tier that unlocks autonomy. That's the Superhost mechanic.

## A.3 The principle that decides what to build: *every datum closes a loop*

Here's the discipline that keeps this from becoming a thousand fields nobody fills in.
**Every captured detail must do one of three things, and you should be able to say which:**

1. **Prevent a failure** (pin confirmed by the second shooter → nobody's lost at call time),
2. **Create a delight** (golden‑hour cake timing → magazine photos),
3. **Train the engine** (per‑line‑item vendor feedback → better recommendations next time).

If a field does none of the three, cut it. If it does one, it's worth the friction. This is
how you get granularity *without* bureaucracy — the **atomic unit of delight**: the
smallest captured fact that protects or produces a moment.

## A.4 The architectural brownie: re‑anchor on a *journey/moment spine*

This is the one structural challenge to the existing docs. The MECE review optimized the
object graph for *correctness*. But **delight lives in the edges MECE wants to sand off** —
the grandmother, the teal, the shy kid. So in addition to the Context × Archetype matrix,
add a second organizing spine the whole team designs against:

- **Storyboard the journey, frame by frame — for all four protagonists.** The *client*, the
  *celebrant*, the *guest*, and (don't forget) the *vendor* and the *internal host*. Disney
  storyboards every frame; so should you. Each frame is a **`Moment`** with an owner, an
  expected feeling, the data that protects it, and a peak/end flag (people remember the
  **peaks and the ending** — engineer those hardest).
- **Name a single human Host per event.** The platform's job is to make that one person feel
  superhuman — anticipatory prompts ("grandmother travelled — confirm she's in the family
  photo shot list"), never to replace them. This is also how you keep your promise to
  "abstract the AI out": the guest feels a person; the person is amplified by the machine.

## A.5 So — do I see where this is going? Yes.

You're building a system where **granularity is the moat.** Anyone can book a clown.
Almost no one captures the second shooter's confirmed parking pin, schedules the candles to
the light, sends each family their own twelve photos that night, and turns every one of
those details into a vendor score and a better recommendation next time. The detail
*compounds*: into taste, into reliability, into a vendor network that competes to be on
your platform, into households that never leave because you remembered the teal.

That's not an events business with software. That's a **hospitality operating system with a
taste engine and a two‑sided network**, and the data you're describing is exactly its fuel.

Build the filing cabinet — you've designed a beautiful one. But hang it on the wall behind
the host, and point the whole thing at the six‑year‑old's face.

*— Brian*

