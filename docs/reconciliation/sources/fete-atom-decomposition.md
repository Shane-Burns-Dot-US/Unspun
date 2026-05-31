# Fête Kids — Atomic Decomposition (T01–T78) v1

**Companion to** `Fete_Experience_Process_Atlas_v1.md`.
**Method:** every atom gets a WHAT (concrete definition), a WHY (what breaks if it's missing — tied to Caroline's review line where applicable), and a sub-component decomposition (3–6 operational pieces). Each sub-component has its own what + why. Inputs / outputs / adjacent atoms close each entry.

**Schema per atom:**

```
### Tnn — Atom name
WS · Phase · Skill · Quadrant
Serves: R-line(s) it produces
WHAT: ...
WHY: ...
Sub-components:
  1. Name — what · why
  ...
Inputs:  ...
Outputs: ...
Adjacent atoms: ...
```

**Discipline reminders (do not skip when reading):**
- Persona-stable, register-tunable: the atoms don't move when the customer shifts; the voice and cultural codes do. For Caroline, the register is established, dry, in-network.
- The membrane (G1) decides scoring: Stage atoms are scored aesthetically, BoH atoms are scored on speed/accuracy.
- The 15 HUMAN-quadrant atoms are the irreducible brand. Treat sub-components inside them as direction for the human, not as automation specs.

---

## Arc A — Discovery & Trust (T01–T10)

### T01 — Capture inbound to single qualified-lead record
**WS1 · P01 · OPS · AUTO**
**Serves:** preconditions for R2.

**WHAT:** Every inbound signal — website form, IG DM to the CD, referral text to the CEO, warm email intro — is captured into one record per real person, keyed to identity rather than channel. Source path is preserved on the record.

**WHY:** A first impression cannot include "let me find your file." If the same person hits us through two channels and we don't unify them, she tells the story twice, the warmth dies, and R2 ("a friend who had the brief") is unrecoverable. The CRM is the substrate every later atom reads from.

**Sub-components:**
1. **Multi-source unifier** — pull form, DM, referral email, warm intro into one queue. *Why:* the same person reaches us 2–3 ways in the first 72 hours.
2. **Identity dedup** — reconcile email + phone + LinkedIn handle to one record. *Why:* duplicate cards split her file and later create cold-feeling re-intros.
3. **Source attribution tag** — preserve who/what brought her in. *Why:* drives referral attribution (T75) and ICP triage (T02).
4. **Freshness signal** — time-from-first-touch on the record. *Why:* drives triage urgency; warm inbounds decay fast.
5. **Initial routing flag** — CD review vs planner first-look. *Why:* CD calendar is the scarcest input; not every lead needs it.

**Inputs:** webhook events, CD's DM inbox, CEO's referral email folder.
**Outputs:** single CRM record with source provenance and routing flag.
**Adjacent atoms:** T02, T03, T75.

---

### T02 — Qualify against ICP filter
**WS1 · P01 · ANL · AUTO**
**Serves:** preconditions for R2 (we pre-know whether she's "our kind of host").

**WHAT:** A structured triage that decides whether the lead matches ICP and, if so, what tier of attention it earns. Output: a triage code with a one-line rationale written to the record.

**WHY:** CD time is scarcer than money. A lead pulled into discovery who shouldn't be there is a brand-trust loss for her and an opportunity-cost loss for us. Triage also pre-shapes the register the CD enters with.

**Sub-components:**
1. **Geo filter** — Hillsborough, Atherton, Woodside, Belvedere, Diablo, Newport Coast, Pacific Heights. *Why:* venue and vendor graph are geo-local.
2. **Budget signal inference** — zip + spouse employer + observable lifestyle. *Why:* we don't ask budget on form; we infer the envelope first.
3. **Event-type filter** — milestone children's events only. *Why:* category discipline preserves taste and pricing.
4. **Child-age window** — currently 3–12. *Why:* age band drives child-flow design and vendor ensemble.
5. **Referral-source weighting** — warm intro from CD's club > cold form. *Why:* the source predicts conversion and lifetime value.

**Inputs:** record from T01.
**Outputs:** triage tier (Green / Yellow / Red) with rationale.
**Adjacent atoms:** T01, T03, T05.

---

### T03 — Enrich identity
**WS1 · P02 · ANL · AUTO**
**Serves:** R2.

**WHAT:** A two-page brief on who she is — role, boards, household, schools, prior events she's hosted, the aesthetic she signals — assembled before the CD speaks with her.

**WHY:** Time-poor, taste-rich. She will not explain her life. R2 requires the CD to walk in already knowing her shape. The brief is the difference between "a vendor call" and "a friend who had the brief."

**Sub-components:**
1. **LinkedIn + press scrape** — current role, board seats, public stories. *Why:* shapes what we won't make her re-explain.
2. **Household composition** — spouse, children, household scale (visible only). *Why:* anchors the event scale and household decorum.
3. **Prior-event signal** — public IG + lifestyle press on what she's hosted. *Why:* tells us the standard she's already set; we must clear it.
4. **Aesthetic sample** — IG grid, Pinterest, brand affinities. *Why:* feeds T04 vector.
5. **Network adjacency** — who in her network we already know — mothers' club, school, fund. *Why:* discretion (T05), social-overlap check (T17), referral pathing (T69).

**Inputs:** record from T01–T02.
**Outputs:** 2-page brief readable in ~4 minutes; structured CRM extension.
**Adjacent atoms:** T04, T05, T11, T73.

---

### T04 — Infer aesthetic posture from public signal
**WS1 · P02 · ANL · AUG-HITL**
**Serves:** R3, R4.

**WHAT:** A vision-and-language pass over her IG and Pinterest (her own posts, her saves, her tags) producing a posture vector — palette, motifs, references, aesthetic axes — that anchors the moodboard before she's said anything.

**WHY:** R3 requires the moodboard to land first pass. Genre-default work fails this. The signal she has already left is more reliable than the words she'd use on a call.

**Sub-components:**
1. **Palette extraction** — dominant + accent colors across recent posts. *Why:* the moodboard inherits her room.
2. **Motif library** — flora, materials, periods, places (wisteria, ceramics, Carmel). *Why:* gives the CD anchors to push or suppress.
3. **Reference graph** — photographers, designers, magazines she's tagged or saved. *Why:* lineage matters more than category.
4. **Negative space** — what she visibly never posts (balloons, character branding, glitter). *Why:* the "not this" list is half the brief.
5. **Confidence band** — sparse vs dense signal; triggers CD pass if low. *Why:* low-confidence vector becomes a question, not a guess.

**Inputs:** T03 brief, public IG/Pinterest URLs.
**Outputs:** posture vector + confidence band + CD-review flag.
**Adjacent atoms:** T11, T13, T14.

---

### T05 — Detect status / discretion sensitivities
**WS1 · P02 · ANL · AUG-HITL**
**Serves:** R6.

**WHAT:** Identification of sensitivity flags on the record — IPO-track spouse, public fund in fundraise, custody nuance, recent family loss, anything that must not appear in a searchable artifact or be mentioned by name to a vendor.

**WHY:** R6 (the private-budget moment) and the entire R14 referral surface depend on her trusting that we know what not to say. One careless line on a quote sheet or vendor brief breaks the loop.

**Sub-components:**
1. **Recent-press scan** — any news in last 12 months on her or spouse. *Why:* a story she's in changes what she wants visible.
2. **SEC / board flag** — public-company affiliation creating information sensitivity. *Why:* shapes what we don't put in writing.
3. **Household status** — children, custody, recent family events. *Why:* discretion at the household level.
4. **Vendor-side risk** — vendors unsafe given who else they serve. *Why:* "small world" exposure.
5. **Discretion ledger** — what NOT to say, who NOT to introduce. *Why:* persists across all subsequent atoms.

**Inputs:** T03 brief.
**Outputs:** sensitivity flags on the record; CD-confirm required before propagating.
**Adjacent atoms:** T06, T20, T31.

---

### T06 — Discovery call · conversational, not interview
**WS1 · P03 · CAR · HUMAN**
**Serves:** R2.

**WHAT:** A 30–45 minute first call run by the CD, structured to feel like coffee with a friend rather than a vendor intake. Few questions, careful listening, a one-line read at the end.

**WHY:** This is where R2 is earned or lost. The entire loop is downstream of trust formed here. The atom is HUMAN because no agent can earn what a person earns in this conversation.

**Sub-components:**
1. **Pre-call ritual** — last review of T03 brief; CD enters with the file in mind, not on screen. *Why:* nothing breaks trust faster than visibly reading notes.
2. **Conversational open** — reference what we know from T03 lightly, never as a recall test. *Why:* shows we did the reading without performing it.
3. **Listen for the unstated** — what she avoids, what she lights up on, what makes her quiet. *Why:* the real brief lives here.
4. **Defer the proposal** — never sell, never propose; mirror back at the end. *Why:* a call she didn't have to defend builds the willingness to refer.
5. **Capture the in-room moment** — what she said + what we heard her actually want. *Why:* hand-off material for T07/T08.

**Inputs:** T03 brief, T04 posture, T05 flags.
**Outputs:** discovery transcript + CD's one-line read.
**Adjacent atoms:** T07, T08, T09, T10.

---

### T07 — Capture stated and unstated brief
**WS1 · P03 · COM · AUG-HITL**
**Serves:** R2, R4.

**WHAT:** Structured capture of both the explicit brief (theme, guests, budget, date) and the implicit brief (avoidances, emphases, in-jokes, references, negative space).

**WHY:** A surface brief produces a surface event. R4 — "it was ours" — requires hearing the second brief, not just the first. The agent structures the transcript; the CD names the unstated.

**Sub-components:**
1. **Stated brief** — theme, headcount, date, budget envelope.
2. **Unstated brief** — what she didn't say but signaled.
3. **Negative-space list** — explicit "not this" items.
4. **Trusted references** — names she dropped (her grandmother's wisteria, the Carmel ceramicist).
5. **Decision-style read** — options vs recommendation; how much she wants to see vs delegate.

**Inputs:** T06 transcript + CD read.
**Outputs:** brief document with explicit + implicit columns.
**Adjacent atoms:** T08, T11, T44.

---

### T08 — CD taste arbitration of brief
**WS7 · P03 · TST · HUMAN**
**Serves:** R4.

**WHAT:** The CD's interpretive read of the brief — naming what's actually being asked for under what was asked for, and committing to a creative direction the moodboard will execute.

**WHY:** This is where taste lives. The brand is this read. We pay for this read. It cannot be tooled.

**Sub-components:**
1. **Strip the asked-for** — set aside the surface request. *Why:* surface requests trap you in genre.
2. **Name the actual ask** — one sentence: "she wants X" where X is what she didn't say. *Why:* the brief gets a verb.
3. **Identify the brave move** — the one unexpected choice that will be the talking point. *Why:* R5 lives here.
4. **Set the constraint** — what we're refusing to do, and why. *Why:* the "not this" list calibrates everything downstream.
5. **Hand off in writing** — direction for the moodboard team, not a vibe. *Why:* taste must be transmissible to T13.

**Inputs:** T07 brief; CD's discovery experience.
**Outputs:** one-paragraph creative direction.
**Adjacent atoms:** T11, T13, T14, T19.

---

### T09 — Same-day recap note
**WS1 · P03 · COM · AUTO**
**Serves:** R2.

**WHAT:** A short, warm written follow-up sent within hours of T06 — references something specific from the call, restates what we heard, names the next step. Not a SOW.

**WHY:** Momentum and trust are perishable. The forwardability of this note (to her husband, to a friend) is an early predictor of referral activation (T69).

**Sub-components:**
1. **Specific reference** — one detail from the call, not a generic compliment.
2. **One-paragraph mirror** — what we heard, in her register.
3. **Next step + owner** — named human, not a department.
4. **Signed by the named human** — never "the Fête team."
5. **No pricing, no terms** — that comes later, in T22/T23.

**Inputs:** T06 transcript, T07 brief.
**Outputs:** email she could forward without editing.
**Adjacent atoms:** T10, T22, T23.

---

### T10 — Open private channel with named human
**WS9 · P03 · CAR · HUMAN**
**Serves:** structural — undergirds every later Stage atom.

**WHAT:** A direct text / Signal / iMessage channel between Caroline and a single named human at Fête. Not a shared inbox. Not a ticket queue.

**WHY:** The whole brand is built on her not feeling project-managed. A named human she can text is the brand's primary structural commitment.

**Sub-components:**
1. **Channel selection** — match her preference (text > email > Signal). *Why:* meet her where she is.
2. **Single named owner** — never a shared inbox. *Why:* the relationship is with a person.
3. **Response SLA** — < 2h within waking hours; otherwise acknowledged with ETA. *Why:* silence kills trust faster than a "no."
4. **Backup protocol** — named backup announced in advance. *Why:* continuity in absences.
5. **Continuity** — same channel + owner across the arc. *Why:* the felt experience of a single relationship.

**Inputs:** identity of CD or planner-on-ground.
**Outputs:** open channel + first message from owner.
**Adjacent atoms:** T26, T44, T45, T62, T68, T74.

---

## Arc B — Vision & Commit (T11–T28)

### T11 — Synthesize taste vector from intake + enrichment
**WS2 · P04 · ANL · AUG-HITL**
**Serves:** R3, R4.

**WHAT:** Combination of T04 posture (public signal) with T07 brief (stated + unstated) into a single aesthetic vector that conditions retrieval — moodboard composition, vendor longlist, key image rendering.

**WHY:** Without a vector, every downstream choice defaults to category templates. The vector is the contract between her language and our retrieval graph.

**Sub-components:**
1. **Posture × brief reconciliation** — where public signal and verbal brief agree, disagree, and complement.
2. **Anchor references** — 3–5 fixed reference points that the vector must satisfy (the wisteria, the grandmother, the Carmel ceramicist).
3. **Style axes** — formal/informal, period/contemporary, restrained/abundant, literal/abstract.
4. **Exclusion vector** — explicit anti-vector for known wrong moves.
5. **Confidence band** — sparse signal triggers a question on T06, not a guess.

**Inputs:** T04, T07.
**Outputs:** taste vector + anchors + exclusions.
**Adjacent atoms:** T12, T13, T16, T27.

---

### T12 — Identify three axes to push and three to suppress
**WS2 · P04 · ANL · AUG-HITL**
**Serves:** R4.

**WHAT:** Translation of the taste vector into a discrete creative posture — three specific axes to amplify and three to mute — readable as a one-line directive by the moodboard team.

**WHY:** Vectors are too high-dimensional to act on. The push/suppress reduction gives the moodboard a brave move and a constraint.

**Sub-components:**
1. **Push #1** — the lead aesthetic move.
2. **Push #2** — the texture / sensory move.
3. **Push #3** — the discovery / surprise move.
4. **Suppress #1** — the obvious category default we are refusing.
5. **Suppress #2** — the over-trodden reference.
6. **Suppress #3** — the visible-expense move that would violate her register.

**Inputs:** T11 vector.
**Outputs:** push/suppress card.
**Adjacent atoms:** T13, T14.

---

### T13 — Compose moodboard at editorial quality
**WS2 · P05 · CRF · AUG-HITL**
**Serves:** R3, R13.

**WHAT:** A composed moodboard — not a collage — meeting print-frame editorial quality. Image selection, layout, palette discipline, type, sequence.

**WHY:** R3 — "a moodboard I genuinely wanted to print" — is the point of separation from category competitors who send slide decks of stock images. The moodboard is the first artifact she touches.

**Sub-components:**
1. **Image sourcing** — original photography, editorial archives, vendor portfolios, taste-vector retrieval.
2. **Composition** — pages laid out as editorial spreads, not grids.
3. **Palette discipline** — palette derived from the vector, not from the images.
4. **Type system** — restrained, brand-consistent.
5. **Sequence** — the moodboard reads as a narrative she can show someone.

**Inputs:** T08 direction, T11 vector, T12 push/suppress.
**Outputs:** moodboard at print-frame quality.
**Adjacent atoms:** T14, T15, T27.

---

### T14 — CD final pass on moodboard
**WS7 · P05 · TST · HUMAN**
**Serves:** R3, R5.

**WHAT:** The CD's last hands-on edit before the moodboard goes to Caroline — kill the wrong piece, add the unexpected one, calibrate the cover. Includes the long-tail anchor (the Carmel ceramicist).

**WHY:** R3 + R5 both ride here. The moodboard cannot smell of "AI moodboard"; it has to carry the CD's eye. This atom is HUMAN by design.

**Sub-components:**
1. **Kill** — the one wrong inclusion that's almost-right but off.
2. **Add** — the one unexpected anchor she's never come across.
3. **Cover** — the opening image carries the whole posture.
4. **Sign** — the CD's mark, visible.
5. **Approve to send** — gate before the moodboard reaches Caroline.

**Inputs:** T13 moodboard.
**Outputs:** signed-off moodboard.
**Adjacent atoms:** T15, T27.

---

### T15 — Write moodboard caption deck
**WS2 · P05 · COM · AUTO**
**Serves:** R3.

**WHAT:** Captions and the small accompanying narrative copy that turns the moodboard from a visual artifact into a story document. Tone-trained to Caroline's register.

**WHY:** Captions decide whether the moodboard reads as inventory or as a story. The story is what she shows her sister-in-law, what she reads aloud, what she remembers.

**Sub-components:**
1. **Cover narrative** — one paragraph that frames the whole moodboard.
2. **Section captions** — short titles per spread, not labels.
3. **Anchor captions** — for the brave moves (R5), explain just enough to give her the talking point.
4. **Closing line** — the single line she'll quote back to us.
5. **Register check** — dry, established, period-style sentences. Not aspirational copy.

**Inputs:** T13 moodboard, T08 direction.
**Outputs:** caption deck integrated into moodboard.
**Adjacent atoms:** T22, T23.

---

### T16 — Vendor longlist conditioned on taste vector
**WS3 · P06 · ANL · AUTO**
**Serves:** R5.

**WHAT:** Retrieval of vendor candidates per category (florist, ceramicist, stationer, etc.) conditioned on the taste vector + geography + availability + price band.

**WHY:** R5 — the Carmel ceramicist — only happens if the longlist reaches beyond the local rolodex. This is the platform play at the atomic level.

**Sub-components:**
1. **Per-category retrieval** — each vendor category run as a separate query.
2. **Vector conditioning** — vendor portfolios scored against the taste vector.
3. **Geo + logistics filter** — travel feasibility, dates, install windows.
4. **Long-tail injection** — at least one non-rolodex discovery per category.
5. **Tier banding** — A/B/C bands to allow ensemble pairing in T19.

**Inputs:** T11 vector, T07 brief, vendor graph.
**Outputs:** ranked longlist per category.
**Adjacent atoms:** T17, T18, T19, T29, T71.

---

### T17 — Availability + social-overlap check
**WS3 · P06 · ANL · AUG-HITL**
**Serves:** R5 (negative) and discretion.

**WHAT:** Cross-checks each longlisted vendor against (a) availability for the date, (b) prior collaboration history, (c) social overlap with Caroline's network — to avoid double-books, redundant recurrences, and embarrassing collisions.

**WHY:** A vendor she's already used and tired of, or one she'd be embarrassed about in her network, undoes everything. One delightful overlap (a referee in common) is a feature, several is a problem.

**Sub-components:**
1. **Availability** — confirm with vendor calendar (API or human check).
2. **Prior collab history** — has she used them before; was the outcome strong.
3. **Social overlap** — vendor's recent clients vs her network.
4. **One-delightful-overlap rule** — at most one "small world" coincidence per event.
5. **Embarrassment screen** — vendors active in tabloid press, public disputes, etc.

**Inputs:** T16 longlist, T03 network adjacency.
**Outputs:** filtered longlist with annotations.
**Adjacent atoms:** T18, T19.

---

### T18 — Shortlist with rationale
**WS3 · P06 · ANL · AUG-HITL**
**Serves:** R5.

**WHAT:** Reduction of longlist to 2–3 candidates per category, each accompanied by a one-line taste rationale ("why this florist, not just a florist").

**WHY:** The vendor pack reads as a catalog or as a curation. The difference is the rationale line. Curation builds her confidence in our judgment.

**Sub-components:**
1. **Reduce to 2–3** per category.
2. **One-line taste rationale** per entry.
3. **Compatibility note** — how this vendor pairs with the others on the shortlist.
4. **Cost band** — A/B band labeling (not raw price).
5. **CD-readable** — format the shortlist for T19 rather than for Caroline directly.

**Inputs:** T17 filtered list.
**Outputs:** shortlist with rationales.
**Adjacent atoms:** T19, T21, T22.

---

### T19 — Ensemble taste pairing
**WS7 · P06 · TST · HUMAN**
**Serves:** R5, R13.

**WHAT:** The CD picks the actual ensemble — florist × ceramicist × stationer × photographer × cake — for aesthetic coherence. Each pick individually fine; together, they must photograph as one event.

**WHY:** Each shortlisted vendor can be perfect alone and still produce a dissonant event. Ensemble coherence is taste at a higher abstraction. HUMAN by design.

**Sub-components:**
1. **Aesthetic coherence check** — palette, materials, period, register.
2. **Photographability check** — how the ensemble reads in editorial frames (T59).
3. **Anchor commit** — one anchor (often the brave move from T08) defines the others.
4. **Substitution test** — would another shortlist combination work better?
5. **CD commit** — sign-off, in writing, with one-line rationale.

**Inputs:** T18 shortlists.
**Outputs:** committed vendor ensemble.
**Adjacent atoms:** T21, T29, T58, T59.

---

### T20 — Surface the dual-budget question
**WS1 · P07 · CAR · HUMAN**
**Serves:** R6.

**WHAT:** The conversation in which Caroline's private budget number is elicited gracefully, without it ever appearing on a spouse-visible artifact. A human moment, often by text or a phone call, never a form.

**WHY:** R6 — "the number I'd quietly given them, not the number on the household ledger" — is the discretion clause. If we miss this atom, R6 collapses and the trust around discretion (T05, T68) collapses with it.

**Sub-components:**
1. **Trigger moment** — initiated after T08 direction, before T21 pre-negotiation.
2. **Channel** — direct text or call, never email-with-attachment.
3. **Framing** — "two envelopes, one visible, one quiet." Her language, not ours.
4. **Quote-routing rule** — what number lives on which artifact.
5. **CRM annotation** — discretion flag added to T05 ledger so it persists.

**Inputs:** T05 sensitivities, T08 direction.
**Outputs:** dual-budget structure on record.
**Adjacent atoms:** T21, T22, T31.

---

### T21 — Pre-negotiate vendor ranges before quoting hostess
**WS4 · P07 · NEG · AUG-HITL**
**Serves:** R6.

**WHAT:** All vendor pricing is negotiated to a band before any number is quoted to Caroline. The number she sees is the number she pays.

**WHY:** Quote-then-haggle is the category default and reads as untrustworthy. R6 specifically depends on her quietly-given number landing without drift.

**Sub-components:**
1. **Per-vendor envelope** — what we'll accept.
2. **Bundled-rate logic** — ensemble pricing where it helps.
3. **Margin floor** — what we won't cross.
4. **Vendor-side rationale** — what we're giving the vendor in return (referrals, network access).
5. **Closed-band confirmation** — written confirmation before T22 proposal.

**Inputs:** T19 ensemble, T20 budget.
**Outputs:** closed bands per vendor.
**Adjacent atoms:** T22, T29, T30.

---

### T22 — Tiered scope proposal
**WS1 · P07 · COM · AUG-HITL**
**Serves:** structural — preserves agency.

**WHAT:** A 3-tier scope proposal — good / surprising / unforgettable — written so the middle tier feels like her choice, not an upsell.

**WHY:** "Pay more to be respected" is the brand killer. She must pick the middle and feel she chose. This atom is where pricing meets taste.

**Sub-components:**
1. **Tier definition** — what's in each, with no top-tier shaming the bottom.
2. **Story framing** — each tier as a story, not a SKU list.
3. **Anchor on middle** — the middle tier is the design center.
4. **Brave-move surfacing** — the brave move (T08) shows up in the middle.
5. **Register check** — no urgency, no exclusivity language; her register is too established for that.

**Inputs:** T08 direction, T21 bands.
**Outputs:** tiered proposal.
**Adjacent atoms:** T23, T24.

---

### T23 — Draft proposal as a story document
**WS1 · P08 · COM · AUG-HITL**
**Serves:** structural; protects R2.

**WHAT:** The proposal she receives is a story document — a piece she'd keep — not a contract or SOW.

**WHY:** A legal-grade document at this stage breaks the friendship register T06 established. The story document is the artifact that makes the experience worth describing to her sister-in-law.

**Sub-components:**
1. **Cover** — the key image (T27) and a single sentence.
2. **Story spread** — the event as a narrative.
3. **Tier presentation** — T22 tiers as story options, not feature lists.
4. **Number presentation** — one number per tier, no line-item dissection.
5. **Signature page** — light, warm; legal terms in an appendix she won't read.

**Inputs:** T22 tiers, T13 moodboard, T27 key image.
**Outputs:** proposal document.
**Adjacent atoms:** T24, T31.

---

### T24 — Capture commit
**WS1 · P08 · OPS · AUTO**
**Serves:** structural.

**WHAT:** Same-day capture of signature, deposit, calendar hold, and household block-out. Everything happens in one transaction.

**WHY:** Slippage on the calendar hold has cost us events before. Same-day close keeps the warmth from T06–T23 from cooling.

**Sub-components:**
1. **E-sign** — single click, light-touch.
2. **Deposit** — handled inline; no separate "we'll invoice you."
3. **Calendar hold** — vendor calendars + her household calendar updated.
4. **Household block-out** — back-end signaling so the planner-on-ground knows the day is held.
5. **Confirmation** — warm note from the named human (T10).

**Inputs:** T23 proposal.
**Outputs:** signed agreement + deposit + holds.
**Adjacent atoms:** T25, T26.

---

### T25 — Project instantiation
**WS6 · P08 · OPS · AUTO**
**Serves:** structural.

**WHAT:** The internal project record is created from T24, all workstreams instantiated, all CRM context propagated to vendor portal (T34), photo brief (T46), ROS (T35), and dossier (T73).

**WHY:** Manual handoff is where context dies. Zero context loss is the standard. Caroline never repeats anything.

**Sub-components:**
1. **Workstream instantiation** — all 9 workstreams active with owners.
2. **Context propagation** — CRM → vendor portal → ROS → photo brief.
3. **Sensitivity inheritance** — T05 flags propagate to every workstream.
4. **Owner assignment** — single named owner per workstream.
5. **First standup trigger** — internal kickoff scheduled.

**Inputs:** T24, all prior CRM context.
**Outputs:** active project with full context.
**Adjacent atoms:** T26, T34, T35, T46.

---

### T26 — Planner-on-ground introduced by name
**WS9 · P08 · CAR · HUMAN**
**Serves:** structural; precondition for R7, R10.

**WHAT:** The planner who will run the day is introduced to Caroline by the CD — by name, voice memo, with one anchor of warmth — well before the build phase begins.

**WHY:** R7 — "no one asked me anything" — only works if she has known the human in charge for weeks, not minutes. The cold handoff is the agency-grade move; we don't make it.

**Sub-components:**
1. **CD voice memo** — introduces the planner in CD's voice, not corporate copy.
2. **Planner's first message** — sent same day, in her register.
3. **Channel continuity** — planner joins the T10 channel; doesn't open a new one.
4. **Backup announcement** — who covers if the planner is unavailable.
5. **First context message** — planner references something specific from the brief.

**Inputs:** T10 channel, T07 brief.
**Outputs:** named-human handoff to build phase.
**Adjacent atoms:** T44, T45, T62.

---

### T27 — Render the key image
**WS2 · P05 · CRF · AUG-HITL**
**Serves:** R3.

**WHAT:** A single editorial render of the event before it exists — the press still she'd use to invite people. AI-image-gen + CD selection.

**WHY:** The key image is the invitation's job: it makes the event feel inevitable. R3's "moodboard I wanted to print" extends to the key image.

**Sub-components:**
1. **Generation set** — multiple frontier-model renders conditioned on T11 vector.
2. **CD selection** — taste pass on the set.
3. **Composition lock** — selected image cropped to invite + cover ratios.
4. **Brand-asset prep** — exports for invite, proposal cover (T23), social.
5. **Print check** — large-format printable.

**Inputs:** T11 vector, T19 ensemble.
**Outputs:** locked key image.
**Adjacent atoms:** T23, T28.

---

### T28 — Invite copy + visual aligned to moodboard
**WS2 · P05 · COM/CRF · AUTO**
**Serves:** structural; sets photograph-on-the-day expectation.

**WHAT:** Invitation suite — copy and visual — that the actual event will live up to. Tone calibrated to her register.

**WHY:** If the invite aesthetic doesn't match the event aesthetic, the photograph on the day disappoints. The invite is the first physical artifact her guests touch.

**Sub-components:**
1. **Copy** — tone-trained to T03/T07 register.
2. **Visual** — T27 key image + T13 palette.
3. **Format** — paper / digital choice that matches her decorum.
4. **RSVP path** — discreet, in her channel preference.
5. **Versioning** — separate child-guest copy and adult-guest copy where appropriate.

**Inputs:** T13, T27.
**Outputs:** invitation suite.
**Adjacent atoms:** T34 (vendor portal), T46 (photo brief expectation).

---

## Arc C — Build (T29–T48)

### T29 — Vendor outreach
**WS4 · P09 · NEG · AUTO**
**Serves:** structural.

**WHAT:** Outreach to committed vendors with terms, scope, dates, and the relevant cue-sheet slice — closed within one cycle, not a multi-round email chain.

**WHY:** Vendors who feel respected work harder. A clean one-cycle close is also where the platform thesis pays off — agents handling negotiation at scale lets us serve 3× the events.

**Sub-components:**
1. **Per-vendor brief** — what their slice is, not the whole event.
2. **Terms package** — closed band from T21, dates, payment cadence.
3. **Cue sheet slice** — their arrival window, install time, neighbors.
4. **Confirmation cycle** — single round, signed term sheet returned.
5. **Discretion brief** — what T05 flags apply to them.

**Inputs:** T19 ensemble, T21 bands.
**Outputs:** confirmed vendor commitments.
**Adjacent atoms:** T30, T31, T34.

---

### T30 — Counter-quote handling
**WS4 · P09 · NEG · AUG-HITL**
**Serves:** R6.

**WHAT:** When a vendor returns a counter, the response is automated within the envelope; out-of-envelope counters are routed to the planner for human judgment.

**WHY:** Margin discipline and protecting Caroline's quietly-given number both happen here. Hostess price drift is the most common path to R6 collapse.

**Sub-components:**
1. **In-envelope auto-handle** — agent re-offers within band.
2. **Out-of-envelope escalation** — planner judgment call.
3. **Trade options** — non-price levers (timeline, scope tweak, network value).
4. **Substitution path** — replace vendor if needed.
5. **Ledger update** — keep the closed band current.

**Inputs:** T29 outreach.
**Outputs:** confirmed final terms per vendor.
**Adjacent atoms:** T31, T32.

---

### T31 — Generate vendor contracts
**WS4 · P09 · OPS · AUTO**
**Serves:** structural.

**WHAT:** Standard vendor contracts generated from template + variable terms. Discretion flags (T05) propagated; spouse-visible language scrubbed.

**WHY:** Manual contract drafting is error-prone and slow. Standardization preserves margin and ensures discretion flags don't leak.

**Sub-components:**
1. **Template fill** — variable terms from T30.
2. **Discretion scrub** — T05 flags applied to language.
3. **Insurance / indemnity** — standard riders.
4. **Cancellation terms** — protect both sides.
5. **E-sign delivery** — to vendor with deadline.

**Inputs:** T30 terms.
**Outputs:** signed vendor contracts.
**Adjacent atoms:** T32, T33.

---

### T32 — Deposits, payment scheduling, invoicing ledger
**WS4 · P09 · OPS · AUTO**
**Serves:** vendor relationship; supply-side compounding.

**WHAT:** Deposits scheduled and paid; payment cadence locked; ledger maintained so vendors are never asking twice.

**WHY:** Vendors who get paid on time work harder and refer. AR discipline is invisible to Caroline but compounding to the vendor network asset.

**Sub-components:**
1. **Deposit schedule** — payment dates locked at signing.
2. **Auto-pay execution** — vendor never has to chase.
3. **Tracking ledger** — finance-grade record.
4. **Variance alerts** — change orders handled cleanly.
5. **Vendor-side acknowledgment** — closes the loop.

**Inputs:** T31 contracts.
**Outputs:** clean AP execution.
**Adjacent atoms:** T71 (vendor scoring).

---

### T33 — Insurance, permits, COIs
**WS4 · P09 · OPS · AUTO**
**Serves:** structural; protects T56–T62.

**WHAT:** All insurance certificates, permits, COIs collected and stored well before the day. Liability exposure closed.

**WHY:** Day-of liability is brand-destroying. The vendor who shows up without insurance is a brand-killing event.

**Sub-components:**
1. **COI collection** — from each vendor, named correctly.
2. **Permit pull** — venue, road closures, alcohol if applicable.
3. **Document storage** — single source of truth.
4. **Expiration tracking** — flagged before the day.
5. **Pre-day audit** — final completeness check 7 days out.

**Inputs:** T31 vendors, venue specifics.
**Outputs:** complete compliance bundle.
**Adjacent atoms:** T42, T48.

---

### T34 — Vendor portal with cue sheet slice
**WS3 · P09 · OPS · AUTO**
**Serves:** R8 (rhythm); R10 (parallel tracks).

**WHAT:** Each vendor logs into a portal that shows their slice of the cue sheet — their arrival, install, cue moments, hand-off neighbors — and only their slice.

**WHY:** Vendors need to know when they appear and who they hand off to, not the whole ROS. The portal is what makes T35 ROS executable across an ensemble.

**Sub-components:**
1. **Per-vendor view** — only their lane.
2. **Neighbor visibility** — who they stand next to in time.
3. **Cue commitments** — their specific cues, with a "tell" for execution.
4. **Live updates** — cue sheet changes propagate.
5. **Mobile-first** — viewable from the truck.

**Inputs:** T35 ROS, T31 vendors.
**Outputs:** per-vendor active portal.
**Adjacent atoms:** T35, T49, T50, T53.

---

### T35 — Author run-of-show
**WS5 · P10 · LOG · AUG-HITL**
**Serves:** R7, R8.

**WHAT:** Minute-by-minute ROS authored from the concept and venue — reads as the script of *this* party, not as a template.

**WHY:** R8 — "rhythm but not the mechanics" — is the ROS's job. Generic ROSs feel like project management; party-specific ROSs feel like choreography.

**Sub-components:**
1. **Time-slice authoring** — every minute owned by a cue or a person.
2. **Sensory layer** — light, sound, scent shifts paired to time-slices (feeds T38).
3. **Decision-rights overlay** — who decides what, in flight (feeds T40).
4. **Escalation overlay** — who gets paged for what (feeds T41).
5. **Contingency branches** — pre-named branches per risk (feeds T48).

**Inputs:** T08 direction, T19 ensemble, venue specifics.
**Outputs:** ROS v1.
**Adjacent atoms:** T36, T37, T38, T40, T41, T48.

---

### T36 — Child-flow choreography
**WS5 · P10 · LOG · HUMAN-AI**
**Serves:** R9.

**WHAT:** Station design and child-handling staffing such that children move themselves through the event — no "everyone come over here" moments.

**WHY:** R9 — "didn't realize they were being moved" — is impossible without designed pull at every station. Forced gathering moments are the visible failure of a kids' event.

**Sub-components:**
1. **Station pull design** — each station has intrinsic appeal pulling kids in.
2. **Spatial flow** — physical layout that suggests motion.
3. **Child-handling staff** — trained, not babysitter-default.
4. **Transition cues** — visual or sensory rather than verbal.
5. **Parent off-ramp** — adults are not asked to wrangle.

**Inputs:** T35 ROS, age band, venue layout.
**Outputs:** child-flow plan.
**Adjacent atoms:** T37, T54.

---

### T37 — Parallel-track design
**WS5 · P10 · LOG · AUG-HITL**
**Serves:** R10.

**WHAT:** The kid track and the adult track are designed as parallel events with the kid track ending slightly before the adult track begins.

**WHY:** R10 — "the adults transitioned to drinks under the pergola and the children had already eaten" — is the entire dual-tier feat. The seam between tracks is where the magic appears.

**Sub-components:**
1. **Kid-track timeline** — ends with kids fed and entertained, not at peak.
2. **Adult-track timeline** — opens with adult mode the moment kids exit peak.
3. **Crossover ritual** — a clean moment when adults shift register.
4. **Staffing split** — separate staff lanes, separate cues.
5. **Seam test** — runs through walk-through (T42) and dry run (T43).

**Inputs:** T35 ROS, T36 child flow.
**Outputs:** parallel-track plan.
**Adjacent atoms:** T54, T55.

---

### T38 — Sensory cue sheet
**WS5 · P10 · LOG · AUG-HITL**
**Serves:** R8.

**WHAT:** Music, light, scent, and motion cues paired to every ROS time-slice. Transitions felt sensorily rather than announced verbally.

**WHY:** R8 — rhythm felt, mechanics invisible — happens when sensory transitions do the work that announcements would otherwise do.

**Sub-components:**
1. **Music progression** — playlist and volume cues per scene.
2. **Light cues** — fixture or natural-light shifts.
3. **Scent moments** — florals and food scenting the air as scenes turn.
4. **Motion** — staff movements, opening doors, releasing items.
5. **Non-verbal staff signals** — the "tell" each staff member responds to.

**Inputs:** T35 ROS.
**Outputs:** sensory cue sheet, integrated into ROS.
**Adjacent atoms:** T50, T53.

---

### T39 — Allergy + child preference matrix
**WS5 · P10 · LOG · AUTO**
**Serves:** safety; brand.

**WHAT:** Per-guest, per-child food restrictions and preferences captured and distributed to F&B staff in plate-actionable form.

**WHY:** A visible allergy moment for a child is brand-destroying. This atom is high-stakes, high-leverage automation.

**Sub-components:**
1. **Guest data collection** — discreet RSVP capture.
2. **Per-child capture** — peanut, dairy, etc.
3. **Plate-actionable distribution** — what arrives at which seat.
4. **F&B staff brief** — color-coded plates, named allergies.
5. **Backup options** — every plate has a clean alternative.

**Inputs:** RSVPs.
**Outputs:** allergy matrix; staff brief.
**Adjacent atoms:** T50, T55.

---

### T40 — Decision-rights pre-assignment
**WS5 · P10 · LOG · AUG-HITL**
**Serves:** R1, R7.

**WHAT:** Every foreseeable in-flight decision has a named owner who is not Caroline. Documented before the day.

**WHY:** R7 — "no one asked me anything" — is the test. Any decision that lands on her on the day means we missed this atom.

**Sub-components:**
1. **Decision enumeration** — list every foreseeable choice.
2. **Owner assignment** — named human per decision, not "the planner."
3. **Authority bounds** — what each owner can decide without escalating.
4. **Escalation path** — only to CD or planner, never hostess.
5. **Documented in the ROS** — visible to all staff.

**Inputs:** T35 ROS, T19 ensemble, venue.
**Outputs:** decision-rights matrix.
**Adjacent atoms:** T41, T48, T57.

---

### T41 — Escalation protocol with "don't tell hostess" tier
**WS5 · P10 · LOG · AUG-HITL**
**Serves:** R1, R7.

**WHAT:** A tiered escalation protocol with an explicit tier that excludes Caroline from the loop. Recovery happens behind the membrane.

**WHY:** Vendors who panic call the host. We make sure she's not on the call list. Recovery has to be invisible.

**Sub-components:**
1. **Tier 1** — vendor handles in-band.
2. **Tier 2** — planner-on-ground decides.
3. **Tier 3** — CD or planner judgment, hostess still not informed.
4. **Tier 4** — break-glass only, hostess looped in last.
5. **Documented + rehearsed** — at T43 dry run.

**Inputs:** T40 decision rights.
**Outputs:** escalation card distributed to staff and vendors.
**Adjacent atoms:** T43, T57.

---

### T42 — Pre-day site walk
**WS8 · P11 · OPS · HUMAN-AI**
**Serves:** R8; preconditions for clean cues.

**WHAT:** Physical walk-through of the venue by the planner — marking camera angles, child flow lines, adult flow lines, vendor staging, load-in path — well before the day.

**WHY:** Day-of discovery problems are the most expensive kind. The walk-through is where we discover them cheaply.

**Sub-components:**
1. **Camera angles** — pre-marked for T58 photographer.
2. **Flow lines** — child vs adult, marked.
3. **Vendor staging zones** — load-in to placement.
4. **Risk inventory** — what could go wrong on this site.
5. **ROS reconciliation** — does the ROS actually fit the physical space.

**Inputs:** T35 ROS, venue.
**Outputs:** site notes; ROS revisions if needed.
**Adjacent atoms:** T43, T49.

---

### T43 — Dry-run cue sheet
**WS8 · P11 · OPS · HUMAN-AI**
**Serves:** R8.

**WHAT:** Rehearsal of the cue sheet with planner + photographer + lead vendor — cues hit silently, hand-offs tested, contingencies walked.

**WHY:** First-time cues at full pressure miss. The dry run is where we catch coordination misfires cheaply.

**Sub-components:**
1. **Cue execution** — walk through every cue verbally and physically.
2. **Hand-off rehearsal** — vendor-to-vendor moments.
3. **Contingency walk** — at least the top-3 named branches.
4. **Photographer alignment** — shot list mapped to cue moments.
5. **Adjustments** — ROS revised based on rehearsal.

**Inputs:** T35 ROS, T42 site walk, T46 photo brief.
**Outputs:** ROS final; rehearsed staff.
**Adjacent atoms:** T49, T50, T53, T58.

---

### T44 — Hostess one-page day-of brief
**WS5 · P11 · COM · AUTO**
**Serves:** R1, R7.

**WHAT:** A one-page brief sent to Caroline the day before — no logistics, only what she needs to know: arrival time, what to wear, when not to be reachable. One sentence of encouragement.

**WHY:** A vendor pack to read the night before would rattle her. The one-pager is the brand's promise that we have it covered.

**Sub-components:**
1. **Arrival time** — when to be there, dressed.
2. **Wardrobe note** — only if relevant.
3. **Unreachable window** — when not to be on her phone.
4. **Encouragement line** — warm, one sentence.
5. **Named human's signature** — the planner she's been talking to.

**Inputs:** T35 ROS.
**Outputs:** one-page PDF.
**Adjacent atoms:** T45, T56.

---

### T45 — CD/CEO evening-before check-in
**WS9 · P11 · CAR · HUMAN**
**Serves:** R1; brand.

**WHAT:** A short, warm check-in from the CD or CEO the evening before — vibe, not logistics. A voice memo, a short call, or a text.

**WHY:** Last-minute logistics calls rattle the hostess. The vibe call is the brand reassuring her without burdening her.

**Sub-components:**
1. **Channel** — T10 channel; in her preferred medium.
2. **Register** — warm, brief, no questions.
3. **Reference one specific thing** — from the brief or the build.
4. **Sign-off** — "we have it; sleep well."
5. **CD-only** — not the planner; this is a brand voice moment.

**Inputs:** T10 channel.
**Outputs:** her sleeping well.
**Adjacent atoms:** T62, T68.

---

### T46 — Photo brief with relational geometry
**WS6 · P10 · OPS · AUG-HITL**
**Serves:** R11, R13.

**WHAT:** The photo brief includes the relational geometry — which family relationships, in-laws, friend pairings must be framed — derived from the CRM dossier.

**WHY:** R11 (the mother-in-law converted) requires that she be photographed beautifully. Missing the in-laws frame is brand-destroying.

**Sub-components:**
1. **Family group plan** — every important relationship has a planned frame.
2. **In-laws inclusion** — explicit.
3. **No-posed-children note** — children candid, not lined up.
4. **CD-tagged hero shots** — which moments are the editorial heroes.
5. **Discretion list** — anyone NOT to photograph or not to publish.

**Inputs:** T03 dossier, T05 discretion, T07 brief.
**Outputs:** photo brief for T58–T59 photographer.
**Adjacent atoms:** T58, T59, T64.

---

### T47 — Album delivery pipeline pre-staging
**WS6 · P10 · OPS · AUTO**
**Serves:** R12.

**WHAT:** The post-event album pipeline (cull → select → retouch → render → deliver) pre-staged before the day so Sunday-morning delivery is mechanical, not heroic.

**WHY:** R12 — "before the school threads woke up" — is a race against organic chatter. The race is won by pre-staging, not by Sunday-morning effort.

**Sub-components:**
1. **Cull infrastructure** — model + pipeline ready to run.
2. **Selection rubric** — CD-approved selection criteria.
3. **Retouch presets** — applied to hero set.
4. **Render templates** — album layout, mobile-first.
5. **Delivery channel** — shared link, mobile-optimized, branded.

**Inputs:** brand assets, prior album pipelines.
**Outputs:** ready pipeline.
**Adjacent atoms:** T63, T64, T65, T66, T67.

---

### T48 — Contingency triggers
**WS5 · P11 · OPS · AUG-HITL**
**Serves:** R1, R7.

**WHAT:** Pre-named branches for foreseeable contingencies — weather, vendor no-show, kid meltdown, food delay — each with owner and decision rule.

**WHY:** Improvised recovery on the day is visible. Pre-named recovery is invisible.

**Sub-components:**
1. **Weather plan** — indoor/outdoor switchover.
2. **Vendor no-show plan** — substitution paths.
3. **Meltdown protocol** — child handling, parent contact.
4. **Food delay plan** — bridge moment with kids and adults.
5. **Final decision rule** — when to invoke break-glass.

**Inputs:** T35 ROS, T19 ensemble, venue.
**Outputs:** contingency card.
**Adjacent atoms:** T41, T49, T57.

---

## Arc D — Day-Of (T49–T62)

### T49 — Vendor arrival staging
**WS8 · P12 · OPS · HUMAN-AI**
**Serves:** R7 (preconditions); G1 membrane.

**WHAT:** Vendor arrival, load-in, and staging choreographed so trucks and crates are never in front of guests.

**WHY:** Trucks parked in front while guests arrive is the canonical membrane breach. The whole front-of-house must be camera-ready.

**Sub-components:**
1. **Load-in window** — earlier than guest arrival by a margin.
2. **Alternate route** — back-of-house load-in path.
3. **Staging zone** — out of sight lines.
4. **Setup sequence** — large items first, taste items last.
5. **Membrane discipline** — staff in costume/uniform before any guest could see them.

**Inputs:** T34 portal, T42 site walk.
**Outputs:** invisible setup.
**Adjacent atoms:** T50, T52.

---

### T50 — Staff brief and assignment confirmation
**WS8 · P12 · OPS · AUG-HITL**
**Serves:** R7, R8.

**WHAT:** Pre-event briefing of all staff — their lane, their tell (the non-verbal cue), and their escalation path. Confirmation before doors open.

**WHY:** Staff who freelance are the visible failure mode. Staff who know three things each are choreographed.

**Sub-components:**
1. **Lane** — what they own.
2. **Tell** — the non-verbal cue they respond to.
3. **Escalation path** — who they call, with what threshold.
4. **Discretion brief** — T05 flags relevant to them.
5. **Sign-off** — every staff member confirms before doors.

**Inputs:** T35 ROS, T40 decisions, T41 escalation, T05 discretion.
**Outputs:** briefed and confirmed staff.
**Adjacent atoms:** T53, T54, T57.

---

### T51 — Final aesthetic walk-through
**WS7 · P12 · TST · HUMAN**
**Serves:** R11, R13; brand.

**WHAT:** The CD or senior planner walks the event 30 minutes before doors and removes the one wrong thing. Could be a misplaced sign, a flower that's wrong, a tablecloth corner.

**WHY:** Mostly-right is the brand killer. The one wrong thing always appears in a photo if it's left. This is taste at the final moment.

**Sub-components:**
1. **Walk path** — same as guest entry; see what she'll see.
2. **Remove, not adjust** — kill anything off; don't try to fix.
3. **Add the missing detail** — if a moment needs one more touch.
4. **Photo check** — would this look right in T58 frames.
5. **Sign-off** — CD or planner clears the floor.

**Inputs:** the set-up venue.
**Outputs:** floor cleared.
**Adjacent atoms:** T58, T60.

---

### T52 — Guest arrival management
**WS8 · P12 · OPS · AUTO**
**Serves:** R11 (relationship recognition).

**WHAT:** Greeters at arrival have a tablet manifest and greet guests by name where possible. Recognition is the first warmth the guest receives.

**WHY:** Caroline notices when her guests are received well; her guests notice; the photos of arrival are framed.

**Sub-components:**
1. **Manifest** — guest list with name pronunciations.
2. **VIP flag** — in-laws, fund LPs, board members.
3. **Tablet view** — greeter sees the list, never the host.
4. **Drink hand-off** — first beverage offered.
5. **Light direction** — gentle path to the event space.

**Inputs:** RSVP list, T46 relational geometry.
**Outputs:** warm arrival.
**Adjacent atoms:** T56, T58.

---

### T53 — Cue execution against ROS
**WS5 · P12 · LOG · HUMAN-AI**
**Serves:** R8.

**WHAT:** The planner-on-ground (with countdown / cue scaffolding from agent) executes the ROS in real time — cues hit, hand-offs land, slippage tolerated within band.

**WHY:** R8 lives here. Slippage compounds; an under-cue moment loses the rhythm.

**Sub-components:**
1. **Countdown surface** — planner sees next cue, time-to-cue.
2. **Hand-off prompts** — agent nudges hand-offs.
3. **Slippage tracker** — compound delays flagged.
4. **Adjustment authority** — planner can re-cue without escalating.
5. **Sensory cross-check** — T38 cues happening on time.

**Inputs:** T35 ROS, T38 sensory cues.
**Outputs:** event on-cue.
**Adjacent atoms:** T54, T55, T57.

---

### T54 — Child-flow live management
**WS5 · P12 · LOG · HUMAN**
**Serves:** R9.

**WHAT:** Live management of children through stations — humans (trained staff) reading the room, rotating kids gently, intervening when needed.

**WHY:** Live child management is HUMAN because no agent can read a 5-year-old's energy. We staff for it because R9 depends on it.

**Sub-components:**
1. **Station-keeper presence** — trained, named.
2. **Energy read** — when a station is flagging or overcrowded.
3. **Gentle rotation** — through suggestion, not announcement.
4. **Intervention protocol** — meltdowns, parent contact.
5. **Hand-off to F&B** — the eating moment is staged.

**Inputs:** T36 child flow.
**Outputs:** children moving themselves.
**Adjacent atoms:** T36, T39, T55.

---

### T55 — Adult-track pacing
**WS5 · P12 · LOG · HUMAN-AI**
**Serves:** R10.

**WHAT:** The planner and lead F&B staff pace the adult track — drinks, dinner rollover, conversation — so the adults release into adult mode at the right beat.

**WHY:** R10 — the parallel-track magic — only works if the adult track is paced live. Adults dragged into kid-mode lose the event.

**Sub-components:**
1. **Drinks pacing** — service speed adjusted to mood.
2. **Dinner rollover** — kid dinner ends before adult dinner begins.
3. **Conversation arc** — moments built for adults to settle into.
4. **Music shift** — T38 cue; lifts at the transition.
5. **Pergola or equivalent** — the spatial cue that they've moved.

**Inputs:** T37 parallel design, T38 sensory cues.
**Outputs:** adults in adult mode.
**Adjacent atoms:** T54, T58.

---

### T56 — Hostess shadow
**WS9 · P12 · CAR · HUMAN**
**Serves:** R1, R7.

**WHAT:** A named human whose entire job that day is to anticipate Caroline's next need — a drink, a child, a quiet moment, an exit — before she asks.

**WHY:** R1 — "present at my own party" — is unachievable without this atom. It is the most expensive HUMAN-quadrant atom and it is what she pays for.

**Sub-components:**
1. **Pre-day prep** — shadow reviews her file, knows her tells.
2. **Proximity discipline** — visible to her, invisible to others.
3. **Anticipation set** — drink, child, in-law, exit, photo.
4. **Quiet hand-off** — when shadow needs to step away, named hand-off.
5. **Closing moment** — last touch with hostess at T62.

**Inputs:** T03, T07, T46 (relational geometry).
**Outputs:** her never asking for anything.
**Adjacent atoms:** T57, T62.

---

### T57 — In-flight contingency handling
**WS8 · P12 · OPS · HUMAN-AI**
**Serves:** R1, R7.

**WHAT:** Live execution of T48 contingencies — vendor late, weather shift, kid meltdown — routed through T41 escalation, never reaching Caroline.

**WHY:** Recovery becomes brand-destroying the moment it's visible. This atom is the operational membrane.

**Sub-components:**
1. **Detection** — early signal flags.
2. **Branch selection** — pre-named branch invoked.
3. **Routing** — vendor handles, planner decides, or CD adjudicates.
4. **Hostess shielding** — confirm she's not on the call list.
5. **Post-event log** — recorded for T76 post-mortem.

**Inputs:** T41, T48.
**Outputs:** invisible recovery.
**Adjacent atoms:** T41, T48, T76.

---

### T58 — Live host / family / in-law coverage
**WS6 · P13 · CRF · HUMAN-AI**
**Serves:** R11, R13.

**WHAT:** The lead photographer (with shot-list scaffolding) covers the host, her spouse, child, parents, in-laws, and the in-network social proof shots — the relational geometry from T46.

**WHY:** R11 (mother-in-law converted) and R13 (framed in the hallway) both depend on a great photo of the right person at the right moment.

**Sub-components:**
1. **Shot-list adherence** — T46 frames hit.
2. **Mother-in-law frame** — explicit attention.
3. **Host-with-child** — the canonical hero frame.
4. **Group geometry** — family groupings as planned.
5. **Live editing** — photographer flags potential hero candidates in real time.

**Inputs:** T46 photo brief.
**Outputs:** relational coverage.
**Adjacent atoms:** T59, T64.

---

### T59 — Editorial coverage
**WS6 · P13 · CRF · HUMAN-AI**
**Serves:** R13; portfolio asset (compounding referral).

**WHAT:** Editorial coverage of the room — still lifes, details, atmosphere, the brand assets that carry forward — in addition to documentary coverage.

**WHY:** Documentary-only coverage gives her an album but gives us nothing for the brand. The editorial layer is the vendor network's compounding asset and the next pitch deck's hero set.

**Sub-components:**
1. **Still-life set** — table, cake, florals.
2. **Atmosphere frames** — light, room, density.
3. **Detail coverage** — the brave moves (T08, T19).
4. **Hero candidates** — flagged in real time.
5. **Clearance plan** — pre-cleared for portfolio use.

**Inputs:** T46 brief, T19 ensemble.
**Outputs:** editorial set.
**Adjacent atoms:** T64, T65, T70.

---

### T60 — Real-time taste corrections
**WS7 · P12 · TST · HUMAN**
**Serves:** R11, R13.

**WHAT:** The CD or planner makes live taste corrections — a station has gone flat, a light is wrong, a child is upset and being photographed — dissolving wrong moments before they crystallize.

**WHY:** Errors caught live disappear; errors caught in the album are forever. The membrane defense is real-time.

**Sub-components:**
1. **Live taste read** — CD walks the floor periodically.
2. **Intervention authority** — to redirect staff, vendor, photographer.
3. **Light correction** — natural light + fixtures adjusted.
4. **Mood correction** — energy shifts.
5. **Photo veto** — moments removed from the capture loop.

**Inputs:** live event.
**Outputs:** wrong moments dissolved.
**Adjacent atoms:** T51, T58.

---

### T61 — End-of-event de-stage
**WS8 · P12 · OPS · AUG-HITL**
**Serves:** G1 membrane.

**WHAT:** Wrap begins behind a curtain — staff de-staging starts before lingering guests have left. The visible wind-down is graceful, not industrial.

**WHY:** Wrap-up is the last impression. Trucks pulling up while guests are still hugging is brand-destroying.

**Sub-components:**
1. **Curtain area** — physical or temporal screen.
2. **De-stage sequence** — taste items first, infrastructure last.
3. **Guest-aware timing** — wait for guest exit before visible breakdown.
4. **Vendor exit choreography** — quiet, ordered.
5. **Final sweep** — leave no trace.

**Inputs:** end-of-event signal.
**Outputs:** graceful wrap.
**Adjacent atoms:** T62, T63.

---

### T62 — Hostess send-off
**WS9 · P12 · CAR · HUMAN**
**Serves:** R1, structural for R14.

**WHAT:** A single private moment with the CD or planner before they leave — "you nailed it" — warm, brief, sincere.

**WHY:** Her last memory of Fête should be a warm human, not the wrap crew. R14 (referral activation) is shaped by this moment.

**Sub-components:**
1. **Timing** — after most guests have left, before wrap is visible.
2. **Voice** — CD or planner, never operations.
3. **Specificity** — reference one moment from the night.
4. **Sign-off** — warm, no business.
5. **Channel handoff** — T74 loop-hold cadence opens here.

**Inputs:** the event.
**Outputs:** warm closing memory.
**Adjacent atoms:** T68, T74.

---

## Arc E — Afterglow & Loop (T63–T78)

### T63 — Same-night photo cull
**WS6 · P14 · CRF · AUTO**
**Serves:** R12.

**WHAT:** Thousands of frames culled to hundreds, same night. Frontier vision models on a pre-staged pipeline (T47).

**WHY:** R12 (before the threads woke up) requires hours, not days. Same-night cull is the unlock.

**Sub-components:**
1. **Technical reject** — out of focus, eyes closed.
2. **Duplicate reduction** — keep best of burst.
3. **Editorial flag** — model surfaces hero candidates for CD.
4. **Discretion filter** — anyone flagged in T05 / T46 removed.
5. **Output staging** — culled set ready for T64.

**Inputs:** event captures.
**Outputs:** hundreds-set.
**Adjacent atoms:** T64.

---

### T64 — Editorial selection
**WS6 · P14 · CRF · AUG-HITL**
**Serves:** R12, R13.

**WHAT:** Reduction of hundreds to ~80 album frames + 10 hero frames. Agent shortlists, CD picks heroes.

**WHY:** Heroes are the print-grade output (R13). Album set is the gift; heroes are the brand asset. CD owns the heroes.

**Sub-components:**
1. **Algorithmic shortlist** — model-ranked candidates.
2. **CD hero pick** — taste pass on candidates.
3. **Story arc** — album sequenced as a narrative.
4. **Family inclusion check** — every important relationship has frames.
5. **Discretion final pass** — second sensitivity check.

**Inputs:** T63 culled set, T46 photo brief.
**Outputs:** 80-album + 10-hero sets.
**Adjacent atoms:** T65, T66, T70.

---

### T65 — Color, retouch on hero frames
**WS6 · P14 · CRF · AUTO**
**Serves:** R13.

**WHAT:** Heroes get the editorial retouch pass — color, skin, light correction — to portfolio quality. Non-hero album set gets baseline preset.

**WHY:** Untreated heroes look amateur in a frame. The retouch is the difference between an album and a portfolio.

**Sub-components:**
1. **Preset application** — non-heroes via preset.
2. **Hero color** — manual or model-assisted.
3. **Skin / portrait correction** — for the host and family.
4. **Light recovery** — natural + fixture inconsistency cleaned.
5. **Print-grade export** — for T70 portfolio.

**Inputs:** T64 sets.
**Outputs:** treated album + heroes.
**Adjacent atoms:** T66, T70.

---

### T66 — Album rendered, shared, mobile + download
**WS6 · P14 · OPS · AUTO**
**Serves:** R12.

**WHAT:** Album packaged in a shared link — mobile-optimized, downloadable, fast.

**WHY:** Friction at delivery kills R12. Five-second tap-to-share is the bar.

**Sub-components:**
1. **Layout** — branded, restrained.
2. **Mobile-first** — opens fast, swipes well.
3. **Download** — full-resolution for keepsake.
4. **Share** — one-tap to school thread.
5. **Analytics** — silent, only for our learning.

**Inputs:** T65 treated set.
**Outputs:** shared link.
**Adjacent atoms:** T67.

---

### T67 — Album delivery message
**WS6 · P14 · COM · AUTO**
**Serves:** R12, R14.

**WHAT:** The message that accompanies the album — warm, brief, references the day, sent via T10 channel.

**WHY:** R14 (referrals) is primed by this moment. A generic notification kills the moment; a brand-voice message multiplies it.

**Sub-components:**
1. **Reference specific detail** — from the day.
2. **Brevity** — one short paragraph.
3. **Channel** — text or the channel she prefers.
4. **Sign** — named human.
5. **Follow-on hint** — opens the door for T68.

**Inputs:** T66 link.
**Outputs:** the message that gets forwarded.
**Adjacent atoms:** T68, T69.

---

### T68 — Personal follow-up
**WS9 · P15 · CAR · HUMAN**
**Serves:** R14.

**WHAT:** Personal follow-up from the CD or CEO — voice memo or handwritten note — referencing a specific moment from the day.

**WHY:** Templated thank-yous don't earn referrals. Specific personal follow-ups do. HUMAN because the point IS the personal.

**Sub-components:**
1. **Specific reference** — a moment only an attendee would name.
2. **Medium** — voice memo, note, never a templated email.
3. **Brevity** — short.
4. **No ask** — not "would you refer us"; just gratitude.
5. **Timing** — within 48 hours.

**Inputs:** day-of memory.
**Outputs:** an emotional reply.
**Adjacent atoms:** T69, T74.

---

### T69 — Referral activation
**WS1 · P15 · COM · AUG-HITL**
**Serves:** R14.

**WHAT:** A frictionless referral mechanism activated at the emotional peak — agent provides the path, human signs.

**WHY:** Asked too soon or too transactionally, referrals die. The frictionless mechanism + the right timing = R14.

**Sub-components:**
1. **Timing nudge** — agent flags peak moment.
2. **Mechanism** — one-tap intro, pre-drafted forwardable note.
3. **Human signature** — CD or planner adds the line.
4. **Attribution wiring** — referrals feed T75.
5. **Restraint** — never more than one ask per arc.

**Inputs:** T68 follow-up.
**Outputs:** referrals out.
**Adjacent atoms:** T75.

---

### T70 — Press / portfolio pipeline
**WS6 · P15 · OPS · AUTO**
**Serves:** brand asset; compounding.

**WHAT:** Editorial frames (T59) cleared for portfolio use, tagged, captioned, available to the marketing surface.

**WHY:** Every event must feed the next pitch. The portfolio is a compounding asset.

**Sub-components:**
1. **Clearance check** — release on file.
2. **Tagging** — vendor credits, style tags.
3. **Captioning** — brand voice.
4. **Storage** — searchable archive.
5. **Push to surfaces** — deck library, website refresh.

**Inputs:** T59, T65.
**Outputs:** portfolio additions.
**Adjacent atoms:** T76.

---

### T71 — Vendor scoring
**WS3 · P15 · ANL · AUTO**
**Serves:** vendor network asset.

**WHAT:** Each vendor scored — reliability, taste fit, cost discipline, hand-off behavior — updates the vendor graph.

**WHY:** The vendor graph IS the compounding asset. Each event makes the next event easier.

**Sub-components:**
1. **Reliability score** — punctuality, completeness.
2. **Taste-fit score** — coherence with ensembles.
3. **Cost-discipline score** — held to envelope.
4. **Hand-off behavior** — how they were as neighbors.
5. **Re-engagement tier** — A/B/C for next-event consideration.

**Inputs:** event execution log.
**Outputs:** updated vendor graph.
**Adjacent atoms:** T72, T16.

---

### T72 — Vendor network growth
**WS3 · P15 · OPS · AUG-HITL**
**Serves:** vendor network asset.

**WHAT:** Long-tail vendors discovered (T16) and used (T19) are onboarded properly into the Fête Kids Approved gated tier.

**WHY:** A one-shot vendor never returns. Two new vendors per event onto the network is the growth rate that builds the moat.

**Sub-components:**
1. **Onboarding pack** — gated tier benefits explained.
2. **Taste validation** — CD signs the aesthetic.
3. **Operational vetting** — insurance, COIs on file.
4. **Network introductions** — to the planner team.
5. **Data tier** — placed in the graph with full metadata.

**Inputs:** T71 scoring.
**Outputs:** vendors onboarded.
**Adjacent atoms:** T71, T16.

---

### T73 — Customer dossier update
**WS1 · P15 · ANL · AUTO**
**Serves:** referral + dossier compounding asset.

**WHAT:** What she liked, what we'd do differently next time, household preferences updated to the dossier.

**WHY:** Year-2 re-engagement starts cold without this atom. The dossier is the customer-side compounding asset.

**Sub-components:**
1. **Aesthetic learning** — what landed, what didn't.
2. **Vendor preferences** — who she liked.
3. **Household preferences** — F&B, music, scent.
4. **Network learning** — new connections surfaced.
5. **Next-event seed** — what the next birthday might want.

**Inputs:** event execution log, T68 reply.
**Outputs:** updated dossier.
**Adjacent atoms:** T74, T76.

---

### T74 — Loop hold
**WS9 · P15 · CAR · HUMAN-AI**
**Serves:** structural; referral compounding.

**WHAT:** Quarterly warm touch from the CD or planner — not a pitch, not a newsletter. A specific, brief acknowledgment.

**WHY:** Cold lists kill the loop. She has to think of Fête when her sister-in-law mentions a milestone.

**Sub-components:**
1. **Cadence** — quarterly, dynamic to her calendar.
2. **Timing nudge** — agent flags right moment.
3. **Content** — specific to her, not generic.
4. **Channel** — T10.
5. **No-ask discipline** — never sell.

**Inputs:** T73 dossier.
**Outputs:** sustained relationship.
**Adjacent atoms:** T68, T69.

---

### T75 — Referral attribution
**WS1 · P15 · OPS · AUTO**
**Serves:** structural; closes the loop.

**WHAT:** Each referral attributable to source event and source customer; reflected in accounting and reporting.

**WHY:** Without attribution, the referral asset is invisible. With it, we can measure the loop's strength.

**Sub-components:**
1. **Source tagging** — referral chain preserved.
2. **Accounting** — credit applied to source.
3. **Reporting** — internal dashboard.
4. **Threshold flags** — customers who refer 3+ get special hold-cadence.
5. **Vendor attribution** — analogous for T72.

**Inputs:** T69 referrals.
**Outputs:** clean attribution.
**Adjacent atoms:** T69, T73.

---

### T76 — Post-mortem with planner + CD
**WS1 · P15 · OPS · AUG-HITL**
**Serves:** structural; playbook compounding.

**WHAT:** A post-event review of the build and execution — what worked, what didn't, what to change in the playbook.

**WHY:** Same mistakes recurring is the institutional failure mode. The playbook version increments every event.

**Sub-components:**
1. **What worked** — preserve and codify.
2. **What didn't** — identify root cause, not symptom.
3. **Playbook diff** — agent drafts, planner approves.
4. **Vendor feedback** — flow back to T71.
5. **Customer feedback** — flow back to T73.

**Inputs:** event log, T57 contingency log, T73 dossier delta.
**Outputs:** playbook version.
**Adjacent atoms:** T71, T73.

---

### T77 — Hostess-grade recap doc
**WS6 · P15 · COM · AUG-HITL**
**Serves:** R14 (compounding), brand.

**WHAT:** A recap doc — one page write-up + hero frames — sent to Caroline as a gift, not as an invoice. A keepsake.

**WHY:** The final touch is either an invoice or a gift. The gift earns the next event and the next referral.

**Sub-components:**
1. **Photo selection** — heroes from T64.
2. **Write-up** — single page, brand voice.
3. **Format** — printable.
4. **Delivery** — physical or high-quality digital.
5. **Sign** — CD.

**Inputs:** T64 heroes, T68 follow-up energy.
**Outputs:** kept recap.
**Adjacent atoms:** T78.

---

### T78 — CD handwritten note on recap doc
**WS7 · P15 · TST · HUMAN**
**Serves:** brand.

**WHAT:** A handwritten note from the CD on the recap doc. By design, not automated.

**WHY:** Industrial finish kills the brand at the closing moment. The handwritten note is the brand's last act and the asset she photographs.

**Sub-components:**
1. **Specific reference** — to the day or her household.
2. **Length** — a few lines.
3. **Hand** — actual handwriting, not font.
4. **Placement** — first page of recap doc.
5. **Sign** — CD's first name.

**Inputs:** T77 recap.
**Outputs:** the closing brand asset.
**Adjacent atoms:** T74 (loop hold).

---

## Cross-cutting reading guides

**If you are reading this to staff a planner team:** the 15 HUMAN atoms + 13 HUMAN-AI atoms are the human-day. Every other atom is agent or pipeline.
**If you are reading this to design a workflow:** start from the AUG-HITL atoms; their sub-components are the surfaces you iterate.
**If you are reading this to audit a brand-destroying risk:** the brand-risk-high atoms (search "brandRisk:'high'" in the HTML data) are where regression is most expensive.
**If you are reading this to size the compounding loop:** T71, T72, T73, T75 are the four atoms whose output feeds future events.
