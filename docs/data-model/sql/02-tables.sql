-- 02 — tables. The full relational molecule, grouped by context.
-- Conventions (README §3): id text PK = '<prefix>_<ulid>'; audit/soft/sourced/versioned
-- columns expanded inline. Cross-context links are by-id (app-enforced, loose coupling,
-- keystone §3.3); strong within-aggregate compositions get FK+CASCADE at the end of file.
SET search_path = unspun, public;

-- ============================ Context 1 — Parties & Consent =================
CREATE TABLE persons (
  id text PRIMARY KEY, display_name text NOT NULL, given_name text, family_name text,
  pronouns text, languages text[], is_minor boolean NOT NULL DEFAULT false, date_of_birth date, notes text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE contact_channels (
  id text PRIMARY KEY, person_id text NOT NULL, channel_type text NOT NULL, value text NOT NULL,
  verified boolean NOT NULL DEFAULT false, preferred boolean NOT NULL DEFAULT false,
  opt_in boolean NOT NULL DEFAULT false, do_not_contact boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz,
  UNIQUE (person_id, channel_type, value));

CREATE TABLE households (
  id text PRIMARY KEY, display_name text NOT NULL, discretion discretion_level NOT NULL DEFAULT 'standard',
  primary_person_id text, residences text[], household_notes text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE client_roles (
  id text PRIMARY KEY, person_id text NOT NULL, household_id text NOT NULL,
  decision_authority text, is_payer boolean NOT NULL DEFAULT false, vip boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (person_id, household_id));

CREATE TABLE members (
  id text PRIMARY KEY, person_id text NOT NULL, household_id text NOT NULL, role_in_household text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (person_id, household_id));

CREATE TABLE celebrants (
  id text PRIMARY KEY, person_id text NOT NULL, household_id text NOT NULL, age_turning int,
  interests text[], sensitivities jsonb, do_not_include text[],
  sensitivity sensitivity_class NOT NULL DEFAULT 'minor_protected',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (person_id, household_id));

CREATE TABLE relationship_edges (
  id text PRIMARY KEY, from_id text NOT NULL, to_id text NOT NULL, edge_type text NOT NULL,
  strength edge_strength, since date,
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (from_id, to_id, edge_type));

CREATE TABLE client_profiles (
  id text PRIMARY KEY, household_id text NOT NULL UNIQUE, taste_summary text, lifestyle_markers jsonb,
  affinities jsonb, no_go text[], curator_notes text, taste_profile_id text, recomputed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text);

CREATE TABLE profile_signals (
  id text PRIMARY KEY, subject_id text NOT NULL, subject_type text NOT NULL, signal_key text NOT NULL,
  value jsonb, capture_method capture_method NOT NULL, lawful_basis lawful_basis, superseded_by_id text,
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class);

CREATE TABLE consents (
  id text PRIMARY KEY, subject_id text NOT NULL, purpose text NOT NULL, scope text,
  data_categories text[], lawful_basis lawful_basis NOT NULL, granted_by text, granted_by_relation text,
  granted_at timestamptz, withdrawn_at timestamptz, evidence_document_id text, state consent_state NOT NULL DEFAULT 'granted',
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (subject_id, purpose, scope, version));

CREATE TABLE consent_vocabularies (
  id text PRIMARY KEY, kind text NOT NULL, code text NOT NULL, label text NOT NULL,
  sensitivity sensitivity_class, minor_allowed boolean NOT NULL DEFAULT false,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (kind, code, version));

CREATE TABLE source_policies (
  id text PRIMARY KEY, source text NOT NULL, allowed_methods capture_method[], allowed_for_minors boolean NOT NULL DEFAULT false,
  lawful_basis lawful_basis, max_sensitivity sensitivity_class, notes text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (source, version));

-- ============================ Context 11 — Safety & Compliance ==============
CREATE TABLE safeguarding_policies (
  id text PRIMARY KEY, code text NOT NULL, rules jsonb NOT NULL, applies_to text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE background_checks (
  id text PRIMARY KEY, subject_person_id text NOT NULL, check_type text NOT NULL, status text,
  issued_at timestamptz, expires_at timestamptz, evidence_document_id text, verified_by text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (subject_person_id, check_type, issued_at));

CREATE TABLE supervision_plans (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, required_ratio text, planned_ratio text, coverage jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE emergency_plans (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, medical jsonb, allergies jsonb, evac_routes jsonb,
  nearest_facilities jsonb, on_site_first_aid boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE security_plans (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, detail_level text, access_control jsonb,
  media_blackout boolean NOT NULL DEFAULT false, location_secrecy discretion_level,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE media_policies (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, may_capture boolean NOT NULL DEFAULT true,
  may_share_internal boolean NOT NULL DEFAULT false, may_showcase boolean NOT NULL DEFAULT false,
  consent_id text, discretion discretion_level,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (scope_id, version));

CREATE TABLE discretion_policies (
  id text PRIMARY KEY, household_id text NOT NULL, level discretion_level NOT NULL,
  allow_showcase boolean NOT NULL DEFAULT false, allow_referral boolean NOT NULL DEFAULT false,
  allow_testimonial boolean NOT NULL DEFAULT false, anonymization_required boolean NOT NULL DEFAULT true,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (household_id, version));

-- ============================ Context 12 — Platform & Governance ============
CREATE TABLE audit_events (
  id text PRIMARY KEY, actor_id text, actor_role text, action text NOT NULL, target_id text,
  target_type text, at timestamptz NOT NULL DEFAULT now(), reason text, payload jsonb);

CREATE TABLE documents (
  id text PRIMARY KEY, doc_type text NOT NULL, subject_id text, uri text NOT NULL, mime text,
  hash text, rights_status text, signer_id text, signed_at timestamptz, expires_at timestamptz,
  state doc_state NOT NULL DEFAULT 'active',
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (doc_type, subject_id, version));

CREATE TABLE approvals (
  id text PRIMARY KEY, target_id text NOT NULL, target_type text NOT NULL, gate text NOT NULL,
  decided_by text, role text, decision text, rationale text, decided_at timestamptz,
  state approval_state NOT NULL DEFAULT 'pending');

CREATE TABLE regions (
  id text PRIMARY KEY, code text NOT NULL UNIQUE, name text NOT NULL, timezone text, regulatory_notes jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE brands (
  id text PRIMARY KEY, slug text NOT NULL UNIQUE, name text NOT NULL, voice_document_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE retention_policies (
  id text PRIMARY KEY, data_category text NOT NULL, subject_class text NOT NULL, retain_days int NOT NULL,
  hard_delete boolean NOT NULL DEFAULT false,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (data_category, subject_class, version));

CREATE TABLE alerts (
  id text PRIMARY KEY, to_actor_id text NOT NULL, subject text NOT NULL, body text, priority priority,
  source_event_id text, read_at timestamptz, resolved_at timestamptz);

-- ============================ Context 4 — Commercial & Finance ==============
CREATE TABLE engagements (
  id text PRIMARY KEY, household_id text NOT NULL, service_tier_id text, pod_id text, contract_id text,
  base_currency text, cadence_id text, state engagement_state NOT NULL DEFAULT 'inquiry',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE packages (
  id text PRIMARY KEY, engagement_id text NOT NULL, label text NOT NULL, kind text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (engagement_id, label));

CREATE TABLE proposals (
  id text PRIMARY KEY, engagement_id text NOT NULL, narrative text, pricing_plan_id text, status text,
  sent_at timestamptz, accepted_at timestamptz,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (engagement_id, version));

CREATE TABLE contracts (
  id text PRIMARY KEY, engagement_id text NOT NULL, document_id text, effective datewindow, terms jsonb,
  signed_by text, signed_at timestamptz, state doc_state NOT NULL DEFAULT 'draft',
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (engagement_id, version));

CREATE TABLE pricing_plans (
  id text PRIMARY KEY, code text NOT NULL, model text NOT NULL, fee money_amount, margin_target_pct numeric,
  markup_pct numeric, notes text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE budgets (
  id text PRIMARY KEY, engagement_id text NOT NULL UNIQUE, total money_amount, committed money_amount, actual money_amount,
  margin_target_pct numeric, base_currency text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE budget_lines (
  id text PRIMARY KEY, budget_id text NOT NULL, category text NOT NULL, target_id text, target_type text,
  planned money_amount, committed money_amount, actual money_amount,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (budget_id, category, target_id));

CREATE TABLE invoices (
  id text PRIMARY KEY, engagement_id text NOT NULL, number text NOT NULL, amount money_amount, issued_at timestamptz,
  due_at timestamptz, status text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (engagement_id, number));

CREATE TABLE payments (
  id text PRIMARY KEY, direction payment_direction NOT NULL, amount money_amount, invoice_id text, booking_id text,
  method text, settled_at timestamptz, state payment_state NOT NULL DEFAULT 'scheduled',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE deposits (
  id text PRIMARY KEY, booking_id text NOT NULL, sequence int NOT NULL, amount money_amount, due_at timestamptz,
  confirmed_at timestamptz, unlocks_work boolean NOT NULL DEFAULT true, state payment_state NOT NULL DEFAULT 'scheduled',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (booking_id, sequence));

CREATE TABLE refunds (
  id text PRIMARY KEY, payment_id text NOT NULL, amount money_amount, reason text, issued_at timestamptz,
  state payment_state NOT NULL DEFAULT 'scheduled',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE ledgers (
  id text PRIMARY KEY, engagement_id text NOT NULL UNIQUE, base_currency text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE ledger_entries (
  id text PRIMARY KEY, ledger_id text NOT NULL, at timestamptz NOT NULL DEFAULT now(),
  direction payment_direction NOT NULL, amount money_amount, account text, ref_id text, ref_type text);

CREATE TABLE margins (
  id text PRIMARY KEY, engagement_id text NOT NULL, revenue money_amount, cost money_amount, margin_pct numeric, computed_at timestamptz);

-- ============================ Context 3 — Supply / Vendors ==================
CREATE TABLE vendors (
  id text PRIMARY KEY, legal_name text NOT NULL, display_name text, region_id text, insurance_status text,
  reliability_grade text, discretion discretion_level NOT NULL DEFAULT 'standard', preferred boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (legal_name, region_id));

CREATE TABLE vendor_users (
  id text PRIMARY KEY, vendor_id text NOT NULL, person_id text NOT NULL, access_role_id text, invited_by text,
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (vendor_id, person_id));

CREATE TABLE vendor_access_roles (
  id text PRIMARY KEY, vendor_id text NOT NULL, name text NOT NULL, permissions jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (vendor_id, name));

CREATE TABLE categories (
  id text PRIMARY KEY, code text NOT NULL, label text NOT NULL, parent_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE vendor_capabilities (
  id text PRIMARY KEY, vendor_id text NOT NULL, category_id text NOT NULL, notes text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (vendor_id, category_id));

CREATE TABLE offerings (
  id text PRIMARY KEY, vendor_id text NOT NULL, sku text NOT NULL, name text NOT NULL, category_id text,
  unit text, price_basis money_amount, lead_requirements text, options jsonb, is_standard boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (vendor_id, sku));

CREATE TABLE quotes (
  id text PRIMARY KEY, vendor_id text NOT NULL, event_id text NOT NULL, revision int NOT NULL DEFAULT 1,
  line_items jsonb, total money_amount, valid_until timestamptz, terms text, state quote_state NOT NULL DEFAULT 'requested',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (vendor_id, event_id, revision));

CREATE TABLE bookings (
  id text PRIMARY KEY, event_id text NOT NULL, vendor_id text NOT NULL, quote_id text, agreed money_amount,
  slot datewindow, cancellation_terms text, containment_policy_id text, state booking_state NOT NULL DEFAULT 'held',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE booking_deliverables (
  id text PRIMARY KEY, booking_id text NOT NULL, deliverable_id text NOT NULL, UNIQUE (booking_id, deliverable_id));

CREATE TABLE vendor_contracts (
  id text PRIMARY KEY, vendor_id text NOT NULL, booking_id text, document_id text, effective datewindow,
  liability jsonb, nda boolean NOT NULL DEFAULT false, state doc_state NOT NULL DEFAULT 'draft',
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (vendor_id, effective_from));

CREATE TABLE containment_policies (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, allowed_scope jsonb,
  no_client_contact boolean NOT NULL DEFAULT true, branding_rules jsonb, fallback_vendor_id text, escalation_path jsonb,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (scope_id, version));

CREATE TABLE vendor_performance (
  id text PRIMARY KEY, vendor_id text NOT NULL UNIQUE, on_time_rate numeric, defect_rate numeric,
  confirm_discipline numeric, edit_delivery_ratio numeric, sentiment numeric, discretion_breaches int NOT NULL DEFAULT 0,
  composite_score numeric, computed_at timestamptz);

CREATE TABLE vendor_ratings (
  id text PRIMARY KEY, vendor_id text NOT NULL, factor text NOT NULL, value score, source_id text, at timestamptz NOT NULL DEFAULT now());

CREATE TABLE rosters (
  id text PRIMARY KEY, category_id text NOT NULL, region_id text NOT NULL, ranked_vendor_ids text[],
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (category_id, region_id, version));

CREATE TABLE vendor_recommendations (
  id text PRIMARY KEY, brief_id text, category_id text NOT NULL, ranked jsonb, rationale text,
  invocation_id text, computed_at timestamptz);

-- ============================ Context 2 — Taste & Creative ==================
CREATE TABLE tastemakers (
  id text PRIMARY KEY, team_member_id text NOT NULL UNIQUE, domains text[], signature_motifs text[], decision_rights jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE taste_dimensions (
  id text PRIMARY KEY, code text NOT NULL, label text NOT NULL, kind text, scale text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE taste_profiles (
  id text PRIMARY KEY, owner_id text NOT NULL, owner_type text NOT NULL, dimensions jsonb, weights jsonb,
  exemplars text[], aesthetic_vector jsonb,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (owner_id, version));

CREATE TABLE taste_signals (
  id text PRIMARY KEY, actor_id text NOT NULL, target_id text NOT NULL, target_type text, verdict text,
  annotation text, weight numeric, at timestamptz NOT NULL DEFAULT now(), UNIQUE (actor_id, target_id, at));

CREATE TABLE inspiration_sources (
  id text PRIMARY KEY, content_hash text NOT NULL UNIQUE, media_document_id text, origin text, tags text[], rights_status text,
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE motifs (
  id text PRIMARY KEY, slug text NOT NULL, name text NOT NULL, category_id text, description text, exemplars text[],
  pairing_rules jsonb, cost_band text, reuse_count int NOT NULL DEFAULT 0, last_used_at timestamptz,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

CREATE TABLE motif_libraries (
  id text PRIMARY KEY, brand_id text NOT NULL UNIQUE, name text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE concepts (
  id text PRIMARY KEY, title text NOT NULL, author_id text NOT NULL, narrative text, motif_ids text[], palette jsonb,
  mood_refs text[], est_cost_band text, novelty_rationale text, from_suggestion_id text, state concept_state NOT NULL DEFAULT 'draft',
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (title, author_id, version));

CREATE TABLE concept_variants (
  id text PRIMARY KEY, concept_id text NOT NULL, label text NOT NULL, differs text, novelty_delta numeric,
  collision_window datewindow, collision_similarity numeric, collision_passed boolean,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (concept_id, label));

CREATE TABLE preference_models (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, dimensions jsonb, weights jsonb,
  derived_from jsonb, aggregation_rule text, confidence confidence, staleness_days int, version int NOT NULL DEFAULT 1,
  UNIQUE (scope_id, version));

CREATE TABLE trends (
  id text PRIMARY KEY, name text NOT NULL, description text, direction text, confidence confidence, time_window datewindow,
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

-- ============================ Context 5 — Event Design ======================
CREATE TABLE events (
  id text PRIMARY KEY, engagement_id text NOT NULL, celebrant_id text NOT NULL, title text, date datewindow,
  headcount_target int, exceptionality_target_pct numeric, discretion discretion_level NOT NULL DEFAULT 'standard',
  state event_state NOT NULL DEFAULT 'briefing',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE event_briefs (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, celebrant_focus text, date_pref datewindow, location_pref text,
  headcount int, budget_band money_amount, must_haves text[], no_gos text[], constraints jsonb, tone text,
  discretion discretion_level,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE event_concepts (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, concept_id text NOT NULL, concept_variant_id text, adaptations jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE programs (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, call_times jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE beats (
  id text PRIMARY KEY, program_id text NOT NULL, sequence int NOT NULL, name text NOT NULL, time_window datewindow,
  location text, owner_id text, intended_feeling text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (program_id, sequence));

CREATE TABLE signature_touches (
  id text PRIMARY KEY, event_id text NOT NULL, name text NOT NULL, description text, surprises text, beat_id text,
  wow_rationale text, basis_profile_signal_ids text[], basis_taste_signal_ids text[],
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, name));

CREATE TABLE deliverables (
  id text PRIMARY KEY, event_id text NOT NULL, name text NOT NULL, category_id text, spec jsonb, quantity int,
  owner_id text, source text, acceptance_criteria text, state deliverable_state NOT NULL DEFAULT 'specified',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, name));

CREATE TABLE experience_standards (
  id text PRIMARY KEY, version int NOT NULL, dimensions jsonb, weights jsonb, guidance text,
  effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (version));

CREATE TABLE benchmarks (
  id text PRIMARY KEY, segment_id text, age_band text, region_id text, time_window datewindow, sample jsonb, distribution jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE exceptionality_scores (
  id text PRIMARY KEY, event_id text NOT NULL, phase text NOT NULL, dimension_scores jsonb, composite numeric,
  percentile numeric, benchmark_id text, computed_at timestamptz, UNIQUE (event_id, phase));

CREATE TABLE moments (
  id text PRIMARY KEY, event_id text NOT NULL, protagonist text NOT NULL, sequence int NOT NULL, frame text NOT NULL,
  expected_feeling text, is_peak boolean NOT NULL DEFAULT false, is_end boolean NOT NULL DEFAULT false,
  owner_id text, protecting_data jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, protagonist, sequence));

-- ============================ Context 6 — Production & Logistics ============
CREATE TABLE venues (
  id text PRIMARY KEY, name text NOT NULL, address jsonb, geo geopoint, capacity int, indoor_outdoor text,
  access_rules jsonb, restrictions jsonb, weather_exposure text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE logistics_plans (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, venue_id text, load_in datewindow, load_out datewindow,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE tasks (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, title text NOT NULL, owner_id text,
  due_at timestamptz, blocking boolean NOT NULL DEFAULT false, playbook_id text, priority priority,
  state task_state NOT NULL DEFAULT 'todo',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE dependencies (
  id text PRIMARY KEY, from_id text NOT NULL, from_type text NOT NULL, to_id text NOT NULL, to_type text NOT NULL,
  dep_type text NOT NULL, UNIQUE (from_id, to_id, dep_type));

CREATE TABLE resource_assignments (
  id text PRIMARY KEY, resource_id text NOT NULL, resource_type text NOT NULL, target_id text NOT NULL,
  target_type text NOT NULL, time_window datewindow,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE assets (
  id text PRIMARY KEY, code text NOT NULL UNIQUE, name text NOT NULL, category_id text, condition text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE asset_reservations (
  id text PRIMARY KEY, asset_id text NOT NULL, event_id text, time_window datewindow,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE transport_plans (
  id text PRIMARY KEY, event_id text NOT NULL, kind text NOT NULL, details jsonb, parking_geo geopoint,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, kind));

CREATE TABLE access_passes (
  id text PRIMARY KEY, event_id text NOT NULL, holder_id text NOT NULL, holder_type text, zones text[], valid datewindow,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, holder_id));

CREATE TABLE accommodations (
  id text PRIMARY KEY, event_id text NOT NULL, label text NOT NULL, details jsonb, for_party_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, label));

CREATE TABLE shifts (
  id text PRIMARY KEY, event_id text NOT NULL, role text NOT NULL, time_window datewindow, staffed_ids text[],
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE calendar_items (
  id text PRIMARY KEY, source_id text NOT NULL, source_type text NOT NULL, calendar text NOT NULL, external_id text,
  sync_state text, last_synced_at timestamptz, UNIQUE (source_id, calendar));

CREATE TABLE permits (
  id text PRIMARY KEY, event_id text NOT NULL, authority text NOT NULL, permit_type text NOT NULL, requirements jsonb,
  validity datewindow, conditions text, evidence_document_id text, state permit_state NOT NULL DEFAULT 'required',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, authority, permit_type));

CREATE TABLE media_plans (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, vendor_id text, transfer_platform text,
  is_nonstandard_transfer boolean NOT NULL DEFAULT false, turnaround_commit_days int,
  same_night_teaser boolean NOT NULL DEFAULT false, teaser_count int,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE media_crews (
  id text PRIMARY KEY, media_plan_id text NOT NULL, person_id text, role text NOT NULL,
  is_second_shooter boolean NOT NULL DEFAULT false, confirmed boolean NOT NULL DEFAULT false, equipment jsonb,
  backup_body boolean NOT NULL DEFAULT false, arrival_time timestamptz, map_destination geopoint,
  destination_confirmed boolean NOT NULL DEFAULT false, parking_geo geopoint,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (media_plan_id, person_id));

CREATE TABLE shot_lists (
  id text PRIMARY KEY, media_plan_id text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE shots (
  id text PRIMARY KEY, shot_list_id text NOT NULL, sequence int NOT NULL, description text NOT NULL, beat_id text,
  subject_person_ids text[], priority priority, must_get boolean NOT NULL DEFAULT false, captured boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (shot_list_id, sequence));

CREATE TABLE media_galleries (
  id text PRIMARY KEY, media_plan_id text NOT NULL, kind text NOT NULL, taken_count int, delivered_edited_count int,
  video_deliverables jsonb, per_family boolean NOT NULL DEFAULT false, delivered_at timestamptz, light_window datewindow,
  state deliverable_state NOT NULL DEFAULT 'specified',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (media_plan_id, kind));

-- ============================ Context 7 — Risk & Resilience =================
CREATE TABLE risk_registers (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE risks (
  id text PRIMARY KEY, register_id text NOT NULL, category text NOT NULL, descriptor text NOT NULL,
  likelihood likelihood, impact impact, owner_id text, trigger_signals jsonb, residual text,
  state risk_state NOT NULL DEFAULT 'identified',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (register_id, category, descriptor));

CREATE TABLE contingencies (
  id text PRIMARY KEY, risk_id text NOT NULL, label text NOT NULL, trigger_condition jsonb, steps jsonb,
  owner_id text, fallback_booking_id text, cost_impact money_amount,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (risk_id, label));

CREATE TABLE environment_forecasts (
  id text PRIMARY KEY, event_id text NOT NULL, geo geopoint, for_time timestamptz NOT NULL, source text,
  captured_at timestamptz NOT NULL DEFAULT now(), confidence confidence);

CREATE TABLE environment_conditions (
  id text PRIMARY KEY, forecast_id text NOT NULL, factor text NOT NULL, value numeric, unit text,
  threatens text[], threshold numeric, breached boolean NOT NULL DEFAULT false, risk_id text,
  UNIQUE (forecast_id, factor));

CREATE TABLE incidents (
  id text PRIMARY KEY, event_id text NOT NULL, sequence int NOT NULL, description text NOT NULL, severity impact,
  timeline jsonb, owner_id text, resolution text, client_visible boolean NOT NULL DEFAULT false,
  disclosure_required boolean NOT NULL DEFAULT false, root_cause text, vendor_id text,
  state incident_state NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, sequence));

CREATE TABLE change_orders (
  id text PRIMARY KEY, event_id text NOT NULL, sequence int NOT NULL, change jsonb, reason text, budget_delta money_amount,
  approver_id text, affected jsonb, client_comm_required boolean NOT NULL DEFAULT false,
  state change_state NOT NULL DEFAULT 'proposed',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, sequence));

CREATE TABLE checklists (
  id text PRIMARY KEY, slug text NOT NULL, items jsonb, playbook_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

CREATE TABLE checklist_runs (
  id text PRIMARY KEY, checklist_id text NOT NULL, event_id text NOT NULL, phase text NOT NULL, results jsonb,
  complete boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (checklist_id, event_id, phase));

-- ============================ Context 8 — Communication & Relationship ======
CREATE TABLE guests (
  id text PRIMARY KEY, event_id text NOT NULL, person_id text NOT NULL, is_child boolean NOT NULL DEFAULT true,
  responsible_adult_person_id text, relationship_to_celebrant text, guest_party_id text, plus_ones int, needs jsonb,
  state guest_state NOT NULL DEFAULT 'invited',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz, UNIQUE (event_id, person_id));

CREATE TABLE guest_parties (
  id text PRIMARY KEY, event_id text NOT NULL, label text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, label));

CREATE TABLE guest_experiences (
  id text PRIMARY KEY, guest_id text NOT NULL UNIQUE, dietary jsonb, sensory jsonb, accessibility jsonb,
  friendships text[], personalization jsonb, arrival_notes text);

CREATE TABLE contact_imports (
  id text PRIMARY KEY, event_id text NOT NULL, source_format text, raw jsonb, parsed_count int,
  deduped_count int, filtered_count int, imported_by text, at timestamptz NOT NULL DEFAULT now());

CREATE TABLE touchpoints (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, subtype text NOT NULL DEFAULT 'generic',
  audience text, purpose text, planned_at timestamptz, channel text, owner_id text, template_id text, priority priority,
  state touchpoint_state NOT NULL DEFAULT 'planned',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE messages (
  id text PRIMARY KEY, touchpoint_id text, thread_id text, direction text, channel text, from_id text, to_id text,
  body text, template_id text, provider_message_id text, sent_at timestamptz, receipt_state text);

CREATE TABLE message_templates (
  id text PRIMARY KEY, slug text NOT NULL, channel text, body text NOT NULL, slots jsonb, brand_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

CREATE TABLE cadences (
  id text PRIMARY KEY, scope text NOT NULL, service_tier_id text, schedule jsonb,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (scope, version));

CREATE TABLE invitations (
  id text PRIMARY KEY, event_id text NOT NULL, guest_id text NOT NULL, design_document_id text, channel text,
  rsvp_link text, plus_one_allowed boolean NOT NULL DEFAULT false, sent_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, guest_id));

CREATE TABLE rsvps (
  id text PRIMARY KEY, invitation_id text NOT NULL UNIQUE, response rsvp_response NOT NULL DEFAULT 'no_response',
  headcount int, needs jsonb, notes text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE reminder_sequences (
  id text PRIMARY KEY, event_id text NOT NULL, label text NOT NULL, phases jsonb, channels text[],
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, label));

CREATE TABLE passive_signals (
  id text PRIMARY KEY, guest_id text NOT NULL, kind text NOT NULL, at timestamptz NOT NULL DEFAULT now(),
  soft_attendance_prob numeric);

CREATE TABLE guest_queries (
  id text PRIMARY KEY, event_id text NOT NULL, guest_id text NOT NULL, question_key text NOT NULL, prompt text,
  answer jsonb, channel text, answered_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, guest_id, question_key));

CREATE TABLE guest_visibility_grants (
  id text PRIMARY KEY, event_id text NOT NULL, viewer_guest_id text NOT NULL, subject_guest_id text NOT NULL,
  field text NOT NULL, granted_by text, granted_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (event_id, viewer_guest_id, subject_guest_id, field));

CREATE TABLE updates (
  id text PRIMARY KEY, event_id text NOT NULL, sequence int NOT NULL, audience text, payload jsonb, trigger_ref text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, sequence));

CREATE TABLE delight_moments (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, recipient_id text NOT NULL,
  basis_signal_id text, gesture text, owner_id text, delivered_at timestamptz, reaction text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (scope_id, recipient_id, gesture));

CREATE TABLE feedback_signals (
  id text PRIMARY KEY, source_person_id text, target_id text NOT NULL, target_type text, sentiment sentiment,
  verbatim text, use_consent_id text, at timestamptz NOT NULL DEFAULT now(),
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class);

CREATE TABLE threads (
  id text PRIMARY KEY, scope_id text NOT NULL, scope_type text NOT NULL, topic text, participant_ids text[],
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE gifts (
  id text PRIMARY KEY, event_id text NOT NULL, label text NOT NULL, from_guest_id text, registry_item_id text,
  thank_you_sent boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, label));

CREATE TABLE gift_registries (
  id text PRIMARY KEY, event_id text NOT NULL UNIQUE, items jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE physical_deliveries (
  id text PRIMARY KEY, event_id text NOT NULL, item_label text NOT NULL, recipient_id text NOT NULL,
  dispatched_at timestamptz, delivered_at timestamptz, receipt_confirmed_at timestamptz, proof_document_id text,
  carrier_ref text, state delivery_state NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, item_label, recipient_id));

-- ============================ Context 9 — Acquisition & Distribution ========
CREATE TABLE leads (
  id text PRIMARY KEY, display_name text NOT NULL, person_id text, channel_id text, qualification text,
  estimated_tier text, discretion discretion_level NOT NULL DEFAULT 'standard', state lead_state NOT NULL DEFAULT 'new',
  provenance provenance, consent_id text, expires_at timestamptz, sensitivity sensitivity_class,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE inquiries (
  id text PRIMARY KEY, lead_id text, household_id text, received_at timestamptz NOT NULL DEFAULT now(), summary text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE channels (
  id text PRIMARY KEY, name text NOT NULL UNIQUE, kind text, partner_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE campaigns (
  id text PRIMARY KEY, name text NOT NULL, time_window datewindow, segment_id text, channel_ids text[], goal text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE segments (
  id text PRIMARY KEY, definition_hash text NOT NULL UNIQUE, name text, definition jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE showcases (
  id text PRIMARY KEY, event_id text NOT NULL, narrative text, asset_document_ids text[],
  anonymization_level discretion_level, consent_id text, discretion_policy_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, version));

CREATE TABLE referrals (
  id text PRIMARY KEY, referrer_id text NOT NULL, referee_id text, lead_id text, reward money_amount, at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (referrer_id, referee_id));

CREATE TABLE funnels (
  id text PRIMARY KEY, name text NOT NULL UNIQUE, stages jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE waitlists (
  id text PRIMARY KEY, lead_id text NOT NULL, desired_window datewindow, rank int,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE brand_assets (
  id text PRIMARY KEY, slug text NOT NULL, kind text, document_id text, brand_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

-- ============================ Context 10 — Operations & Team ================
CREATE TABLE team_members (
  id text PRIMARY KEY, person_id text NOT NULL UNIQUE, corporate_email text, skills text[], certifications jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, deleted_at timestamptz);

CREATE TABLE roles (
  id text PRIMARY KEY, name text NOT NULL UNIQUE, description text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE permissions (
  id text PRIMARY KEY, role_id text NOT NULL, action text NOT NULL, object_type text NOT NULL, state text,
  allowed boolean NOT NULL DEFAULT true,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (role_id, action, object_type, version));

CREATE TABLE pods (
  id text PRIMARY KEY, name text NOT NULL UNIQUE, engagement_id text, member_ids text[],
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE service_tiers (
  id text PRIMARY KEY, name text NOT NULL, inclusions jsonb, cadence_id text, staffing_model jsonb, price_basis money_amount,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (name, version));

CREATE TABLE service_standards (
  id text PRIMARY KEY, code text NOT NULL, metric text, target text, service_tier_id text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE playbooks (
  id text PRIMARY KEY, slug text NOT NULL, steps jsonb, owning_role_id text, checklist_ids text[], quality_bar text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

CREATE TABLE availabilities (
  id text PRIMARY KEY, resource_id text NOT NULL, resource_type text NOT NULL, time_window datewindow, status text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), created_by text, updated_by text);

CREATE TABLE capacities (
  id text PRIMARY KEY, region_id text, time_window datewindow, max_events int NOT NULL, committed_events int NOT NULL DEFAULT 0);

CREATE TABLE quality_reviews (
  id text PRIMARY KEY, subject_id text NOT NULL, subject_type text NOT NULL, reviewer_id text NOT NULL, scores jsonb,
  what_worked text, defects text, actions jsonb,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (subject_id, reviewer_id));

CREATE TABLE knowledge_assets (
  id text PRIMARY KEY, slug text NOT NULL, kind text, body text NOT NULL, derived_from jsonb,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

-- ============================ Layer dyn — Dynamic ===========================
CREATE TABLE domain_events (
  id text PRIMARY KEY, event_type text NOT NULL, aggregate_id text NOT NULL, aggregate_type text NOT NULL,
  at timestamptz NOT NULL DEFAULT now(), actor_id text, payload jsonb, sequence int, correlation_id text);

CREATE TABLE state_transitions (
  id text PRIMARY KEY, machine text NOT NULL, from_state text NOT NULL, to_state text NOT NULL, trigger text NOT NULL,
  guard jsonb, actor_role text, emits_event text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (machine, from_state, to_state, version));

CREATE TABLE processes (
  id text PRIMARY KEY, slug text NOT NULL, description text, steps jsonb, listens_to text[], enforces jsonb, compensation jsonb,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (slug, version));

CREATE TABLE process_instances (
  id text PRIMARY KEY, process_id text NOT NULL, subject_id text NOT NULL, subject_type text NOT NULL,
  started_at timestamptz NOT NULL DEFAULT now(), current_step text, context jsonb, finished_at timestamptz,
  state process_state NOT NULL DEFAULT 'pending');

CREATE TABLE check_definitions (
  id text PRIMARY KEY, code text NOT NULL, kind check_kind NOT NULL, target_type text, rule jsonb,
  independent_of text[], min_quorum int, scaled_by text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE check_results (
  id text PRIMARY KEY, check_definition_id text NOT NULL, kind check_kind NOT NULL, target_id text NOT NULL,
  target_type text, verdict check_verdict NOT NULL, detail jsonb, machine_payload jsonb, human_summary text,
  priority priority, ensemble_id text, at timestamptz NOT NULL DEFAULT now());

CREATE TABLE ensemble_results (
  id text PRIMARY KEY, target_id text NOT NULL, target_type text, member_result_ids text[] NOT NULL,
  verdict check_verdict NOT NULL, quorum text, disagreement boolean NOT NULL DEFAULT false, escalated_alert_id text,
  priority priority, at timestamptz NOT NULL DEFAULT now());

-- ============================ Layer ai — AI Enablement ======================
CREATE TABLE ai_capabilities (
  id text PRIMARY KEY, name text NOT NULL, purpose text, inputs jsonb, output_type text, autonomy text,
  requires_human_review boolean NOT NULL DEFAULT true, guardrail_ids text[],
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (name, version));

CREATE TABLE agents (
  id text PRIMARY KEY, name text NOT NULL, config jsonb, guardrail_ids text[],
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (name, version));

CREATE TABLE invocations (
  id text PRIMARY KEY, agent_id text, capability_id text NOT NULL, request_hash text, inputs_ref jsonb, outputs jsonb,
  cost money_amount, latency_ms int, policy_checks jsonb, at timestamptz NOT NULL DEFAULT now());

CREATE TABLE suggestions (
  id text PRIMARY KEY, invocation_id text NOT NULL, idx int NOT NULL DEFAULT 0, content jsonb, confidence confidence,
  rationale text, target_id text, target_type text, state suggestion_state NOT NULL DEFAULT 'proposed');

CREATE TABLE guarded_actions (
  id text PRIMARY KEY, invocation_id text NOT NULL, action text NOT NULL, within_envelope boolean NOT NULL DEFAULT true,
  guardrail_id text, audit_event_id text, at timestamptz NOT NULL DEFAULT now());

CREATE TABLE human_reviews (
  id text PRIMARY KEY, suggestion_id text NOT NULL, reviewer_id text NOT NULL, decision text, edits jsonb,
  rationale text, at timestamptz NOT NULL DEFAULT now(), state approval_state NOT NULL DEFAULT 'pending');

CREATE TABLE policy_guardrails (
  id text PRIMARY KEY, code text NOT NULL, constrains text, data_scope jsonb, autonomy_ceiling text,
  prohibited_actions text[], requires_lawful_basis boolean NOT NULL DEFAULT false,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (code, version));

CREATE TABLE knowledge_bases (
  id text PRIMARY KEY, name text NOT NULL, sources jsonb, embedding_store_ref text,
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (name, version));

-- ============================ Strong compositions (FK + CASCADE) ============
-- Within-aggregate ownership only; cross-context links stay app-enforced (keystone §3.3).
ALTER TABLE contact_channels    ADD FOREIGN KEY (person_id)     REFERENCES persons(id)        ON DELETE CASCADE;
ALTER TABLE client_profiles     ADD FOREIGN KEY (household_id)  REFERENCES households(id)     ON DELETE CASCADE;
ALTER TABLE budgets             ADD FOREIGN KEY (engagement_id) REFERENCES engagements(id)    ON DELETE CASCADE;
ALTER TABLE budget_lines        ADD FOREIGN KEY (budget_id)     REFERENCES budgets(id)        ON DELETE CASCADE;
ALTER TABLE event_briefs        ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE event_concepts      ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE programs            ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE beats               ADD FOREIGN KEY (program_id)    REFERENCES programs(id)       ON DELETE CASCADE;
ALTER TABLE deliverables        ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE signature_touches   ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE moments             ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE logistics_plans     ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE risk_registers      ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE risks               ADD FOREIGN KEY (register_id)   REFERENCES risk_registers(id) ON DELETE CASCADE;
ALTER TABLE contingencies       ADD FOREIGN KEY (risk_id)       REFERENCES risks(id)          ON DELETE CASCADE;
ALTER TABLE environment_conditions ADD FOREIGN KEY (forecast_id) REFERENCES environment_forecasts(id) ON DELETE CASCADE;
ALTER TABLE media_plans         ADD FOREIGN KEY (event_id)      REFERENCES events(id)         ON DELETE CASCADE;
ALTER TABLE media_crews         ADD FOREIGN KEY (media_plan_id) REFERENCES media_plans(id)    ON DELETE CASCADE;
ALTER TABLE shot_lists          ADD FOREIGN KEY (media_plan_id) REFERENCES media_plans(id)    ON DELETE CASCADE;
ALTER TABLE shots               ADD FOREIGN KEY (shot_list_id)  REFERENCES shot_lists(id)     ON DELETE CASCADE;
ALTER TABLE media_galleries     ADD FOREIGN KEY (media_plan_id) REFERENCES media_plans(id)    ON DELETE CASCADE;
ALTER TABLE vendor_users        ADD FOREIGN KEY (vendor_id)     REFERENCES vendors(id)        ON DELETE CASCADE;
ALTER TABLE offerings           ADD FOREIGN KEY (vendor_id)     REFERENCES vendors(id)        ON DELETE CASCADE;
ALTER TABLE booking_deliverables ADD FOREIGN KEY (booking_id)   REFERENCES bookings(id)       ON DELETE CASCADE;
ALTER TABLE deposits            ADD FOREIGN KEY (booking_id)    REFERENCES bookings(id)       ON DELETE CASCADE;
ALTER TABLE concept_variants    ADD FOREIGN KEY (concept_id)    REFERENCES concepts(id)       ON DELETE CASCADE;
ALTER TABLE guest_experiences   ADD FOREIGN KEY (guest_id)      REFERENCES guests(id)         ON DELETE CASCADE;
ALTER TABLE rsvps               ADD FOREIGN KEY (invitation_id) REFERENCES invitations(id)    ON DELETE CASCADE;
ALTER TABLE ledger_entries      ADD FOREIGN KEY (ledger_id)     REFERENCES ledgers(id)        ON DELETE CASCADE;

-- ============================ Indexes =======================================
-- state (hot filters)
CREATE INDEX ix_events_state       ON events(state);
CREATE INDEX ix_engagements_state  ON engagements(state);
CREATE INDEX ix_bookings_state     ON bookings(state);
CREATE INDEX ix_tasks_state        ON tasks(state);
CREATE INDEX ix_guests_state       ON guests(state);
CREATE INDEX ix_suggestions_state  ON suggestions(state);
-- aggregate fan-out
CREATE INDEX ix_events_engagement  ON events(engagement_id);
CREATE INDEX ix_bookings_event     ON bookings(event_id);
CREATE INDEX ix_deliverables_event ON deliverables(event_id);
CREATE INDEX ix_guests_event       ON guests(event_id);
CREATE INDEX ix_tasks_scope        ON tasks(scope_id);
CREATE INDEX ix_profile_signals_subject ON profile_signals(subject_id);
-- append-only streams by time / correlation
CREATE INDEX ix_domain_events_aggregate  ON domain_events(aggregate_id, at);
CREATE INDEX ix_domain_events_corr        ON domain_events(correlation_id);
CREATE INDEX ix_audit_events_target       ON audit_events(target_id, at);
CREATE INDEX ix_check_results_target      ON check_results(target_id, at);
CREATE INDEX ix_env_forecasts_event_time  ON environment_forecasts(event_id, for_time);
