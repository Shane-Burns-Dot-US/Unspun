# Unspun — Glossary & Object Index

Alphabetical index of every object in the [Domain Keystone](./domain-keystone.md).
Use this to look up a one‑line definition, its ID prefix, owning context, and where it
is defined. The **ID prefix** column is the authoritative registry — no two objects may
share a prefix.

**Contexts:** A Identity & Relationships · B Taste & Curation · C Event ·
D Vendor & Supply · E Logistics & Risk · F Communication & Delight ·
G Marketing & Distribution · H Operations & Team · I AI Enablement · X Cross‑cutting.

| Object | Prefix | Ctx | One‑line definition |
|---|---|---|---|
| Address *(VO)* | — | X | A postal/physical address. |
| Agent | `agt_` | I | A configured AI worker that performs an AICapability within guardrails. |
| AICapability | `aic_` | I | A named, governed internal AI‑assisted function (named to disambiguate from vendor Capability). |
| Attachment *(VO)* | — | X | A stored file/media reference. |
| AuditEvent | `aud_` | X | Immutable record of a significant action (who/what/when/why). |
| Beat | `bet_` | C | A discrete moment within the event program. |
| Booking | `bok_` | D | A confirmed reservation/commitment with a vendor. |
| BrandAsset | `bas_` | G | A reusable brand artifact used in marketing/client materials. |
| Budget | `bdg_` | X | The financial envelope and plan for an engagement/event. |
| BudgetLine | `bdl_` | X | An allocation within a budget. |
| Cadence | `cdn_` | F | The defined rhythm of touchpoints across an engagement. |
| CalendarItem | `cal_` | E | A scheduled entry mirrored/synced to internal and external calendars. |
| Campaign | `cmp_` | G | A coordinated marketing effort targeting a segment via channels. |
| Capability (vendor) | `cap_` | D | A service category a vendor can perform. |
| Celebrant | `cel_` | A | The child whose birthday is celebrated (protected minor). |
| Channel | `chn_` | G | A distribution surface through which leads/referrals arrive. |
| ChangeOrder | `chg_` | E | A controlled, recorded change to a confirmed event. |
| Checklist | `ckl_` | E | A reusable verification list from a Playbook. |
| ChecklistRun | `ckr_` | E | One filled‑in instance of a Checklist for an event/phase. |
| Client | `cli_` | A | An adult principal/decision‑maker/payer in a household. |
| ClientProfile | `cpf_` | A | The composed living portrait of a household's taste/status/sensitivities. |
| Concept | `cpt_` | B | A candidate creative direction for an event. |
| ConceptVariant | `cvr_` | B | A deliberate small deviation making an event slightly unique. |
| Consent | `cns_` | A | A granular, revocable permission record from a subject/guardian. |
| Contact | `con_` | A | An addressable person with verified channels (base reach identity). |
| ContactChannel *(VO)* | — | X | A reachable address on a medium (email/phone/messenger). |
| ContainmentPolicy | `cpy_` | D | Rules that contain a vendor (scope, comms, fallback). |
| Contingency | `ctg_` | E | A pre‑planned response ready if a risk triggers. |
| DateWindow *(VO)* | — | X | A start/end span (or open‑ended). |
| DelightMoment | `dlm_` | F | An unscripted‑feeling surprise gesture toward client/guest. |
| Deliverable | `dlv_` | C | A concrete thing to be produced/procured for the event. |
| Dependency | `dep_` | E | A directed constraint: one object must reach a state before another proceeds. |
| Engagement | `eng_` | H | One contracted project to deliver an event (aggregate root). |
| Event | `evt_` | C | A single child's birthday celebration (aggregate root). |
| EventBrief | `ebr_` | C | The agreed bounded parameters/constraints defining success. |
| EventConcept | `ecn_` | C | The selected Concept+Variant bound to a specific event. |
| ExceptionalityScore | `xsc_` | C | An event's assessed standing vs. the ExperienceStandard. |
| ExperienceStandard | `xst_` | C | The rubric defining "top‑10% event" in scorable dimensions. |
| FeedbackSignal | `fbk_` | F | Any captured client/guest reaction or sentiment. |
| Funnel | `fnl_` | G | The ordered pipeline stages a lead/engagement passes through. |
| GeoLocation *(VO)* | — | X | A point on earth. |
| Guest | `gst_` | A | A person invited to a specific event. |
| GuestParty | `gpt_` | A | A group invited and responding as a unit. |
| Household | `hh_` | A | The affluent family unit; durable customer relationship (aggregate root). |
| HumanReview | `hrv_` | I | The mandatory human checkpoint accepting/editing/rejecting a Suggestion. |
| Incident | `inc_` | E | A realized problem during planning/execution and its handling. |
| InspirationSource | `isr_` | B | A reference artifact used to elicit/express taste. |
| Invitation | `inv_` | F | The formal request for a guest to attend, with RSVP mechanics. |
| Invocation | `ivk_` | I | A single logged AI execution (auditable atom). |
| Invoice | `ivc_` | X | A billed amount to the client. |
| KnowledgeAsset | `kna_` | H | A captured reusable piece of institutional knowledge. |
| KnowledgeBase | `kb_` | I | The curated internal corpus the AI layer reasons over. |
| LawfulBasis | *(enum)* | X | Recorded justification permitting a data use. |
| Lead | `led_` | G | A prospective household not currently under engagement. |
| LogisticsPlan | `lgp_` | E | The plan turning the program into who/what/where/when. |
| Member | `mem_` | A | Another household person relevant to planning. |
| Message | `msg_` | F | A single concrete communication actually sent/received. |
| MessageTemplate | `mtp_` | F | A reusable brand‑voiced template with personalization slots. |
| MinorProtection | *(rules)* | X | Default‑on protections for any minor subject. |
| Money *(VO)* | — | X | An amount in a currency. |
| Motif | `mtf_` | B | A reusable aesthetic/experiential building block. |
| MotifLibrary | `mlb_` | B | The curated catalog of all motifs. |
| Payment | `pay_` | X | A settled transfer (client or vendor direction). |
| Permit | `prm_` | E | A regulatory/property authorization required to hold an element legally. |
| Pod | `pod_` | H | The small cross‑functional team assigned to an engagement. |
| PolicyGuardrail | `pgr_` | I | A rule constraining what AI may do/see/output. |
| PreferenceModel | `pmd_` | B | Aggregated, decomposed preferences used to ideate and rank. |
| Playbook | `pbk_` | H | A reusable SOP encoding how recurring work is done well. |
| ProfileGraph | *(view)* | A | The view over all RelationshipEdges (not separately stored). |
| ProfileSignal | `psg_` | A | A single sourced/consented datum about a person/household. |
| Program | `prg_` | C | The ordered run‑of‑show for the event day. |
| Provenance *(VO)* | — | X | Origin record attached to any sourced datum. |
| Quote | `qot_` | D | A priced vendor proposal for specified offerings. |
| QualityReview | `qrv_` | H | A structured post‑event/incident assessment of delivery vs. standards. |
| Offering | `ofr_` | D | A specific bookable vendor product/service line (the vendor "SKU"). |
| RelationshipEdge | `rel_` | A | A directed link in the social graph between people/households. |
| Referral | `ref_` | G | An introduction of a prospect by an existing client/partner. |
| ResourceAssignment | `ras_` | E | Allocation of a resource to a task/beat for a window. |
| RetentionPolicy | `rtp_` | X | Rule governing how long a data category is kept. |
| Risk | `rsk_` | E | A specific potential adverse event with likelihood/impact. |
| RiskRegister | `rrg_` | E | The living catalog of what could go wrong for an event. |
| Role | `rol_` | H | A named bundle of responsibilities and decision rights. |
| Roster | `ros_` | D | A curated, ranked list of preferred vendors per category/region. |
| RSVP | `rsv_` | F | A guest's response to an invitation, with needs. |
| Score *(VO)* | — | X | A rated value on a rubric dimension. |
| Segment | `seg_` | G | A defined audience grouping used to target and check uniqueness. |
| ServiceStandard | `ssd_` | H | A measurable commitment about how service is delivered. |
| ServiceTier | `stl_` | H | The level of high‑touch service purchased. |
| Shift | `shf_` | H | A staffed time block on event day. |
| Showcase | `shw_` | G | A past event packaged (with consent) as marketing proof. |
| SignatureTouch | `sig_` | C | A bespoke memorable gesture engineered into an event. |
| Suggestion | `sgt_` | I | A proposed AI output presented to a human for review (never auto‑applied). |
| GuardedAction | `gac_` | I | An action AI may take automatically only within a bounded low‑risk envelope. |
| Task | `tsk_` | E | A unit of work with an owner and due moment. |
| TasteProfile | `tpf_` | B | A structured inspectable model of an aesthetic point of view. |
| TasteSignal | `tsg_` | B | A single act of taste (like/reject/annotate). |
| Tastemaker | `tm_` | B | An internal creative authority whose taste is the differentiator. |
| TeamMember | `tmb_` | H | A person on our own staff. |
| Thread | `thr_` | F | A grouped conversation across messages. |
| Touchpoint | `tpt_` | F | A planned moment of contact with client/guest. |
| Trend | `trd_` | B | An observed cultural/seasonal/market signal. |
| Update | `upd_` | F | A proactive announcement to clients/guests about a change/news. |
| Vendor | `ven_` | D | An external supplier organization. |
| VendorContact | `vct_`† | D | A person at a vendor we coordinate with. |
| VendorContract | `vcn_` | D | The legal agreement governing a vendor relationship/booking. |
| VendorPerformance | `vpf_` | D | The running record of how a vendor actually performed. |
| Venue | `vnu_` | E | The physical location(s) where an event happens. |
| WeatherWatch | `wwt_` | E | An active monitor of forecast conditions with action thresholds. |
| Waitlist | `wtl_` | G | Ordered demand we cannot currently serve. |

*(VO) = value object: no independent identity; embedded and compared by value (§14.4).*

† **Prefix note:** `VendorContact` and `VendorContract` must not collide. Canonical
assignment: **VendorContact = `vct_`**, **VendorContract = `vcn_`**. Likewise
**Invoice = `ivc_`** (Invitation keeps `inv_`).
