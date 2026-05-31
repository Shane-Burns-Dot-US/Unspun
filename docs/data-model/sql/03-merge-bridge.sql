-- 03 — merge bridge. Interfaces the Fête atom catalog (verbs) with the Unspun model (nouns).
-- Additive only; runs after 00-02. Reversible (reversal block at the foot of this file).
-- Companion: catalog/07-merge-bridge.yaml; map: ../../reconciliation/merge-ledger.yaml.
SET search_path = unspun, public;

CREATE TYPE automation_quadrant AS ENUM ('auto','aug_hitl','human_ai','human');

-- ---- New control-plane masters --------------------------------------------
CREATE TABLE outcomes (             -- R1..R15
  id text PRIMARY KEY, code text NOT NULL UNIQUE, label text NOT NULL, promise_ref text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text);

CREATE TABLE atoms (                -- T01..T78 process templates (code UNIQUE for FK targets)
  id text PRIMARY KEY, code text NOT NULL UNIQUE, name text NOT NULL, arc text, phase_code text,
  workstream int, skill text, quadrant automation_quadrant,
  serves_outcome_codes text[], asset_tags text[], goals text[],
  benchmark text, failure_mode text, subcomponents jsonb, stage_boh text,
  governance_bound boolean NOT NULL DEFAULT false, disposition text, unspun_targets text[],
  version int NOT NULL DEFAULT 1, effective_from timestamptz, effective_to timestamptz, supersedes_id text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text);

-- ---- Runtime bridge (B2): which objects realized which atom, per event -----
CREATE TABLE atom_realizations (
  id text PRIMARY KEY, atom_code text NOT NULL REFERENCES atoms(code),
  atom_version int NOT NULL,                       -- B7: event pins the atom version
  event_id text NOT NULL, entity_id text NOT NULL, entity_type text NOT NULL,
  role text NOT NULL DEFAULT 'supporting',         -- primary | supporting
  status text NOT NULL DEFAULT 'planned',          -- planned | realized | skipped | failed
  consent_id text, lawful_basis lawful_basis,      -- B6: required when atom.governance_bound
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (atom_code, event_id, entity_id));

-- ---- The two genuinely-new objects ----------------------------------------
CREATE TABLE sensory_cues (         -- T38
  id text PRIMARY KEY, beat_id text NOT NULL REFERENCES beats(id) ON DELETE CASCADE,
  sequence int NOT NULL, channel text NOT NULL, cue text NOT NULL, time_offset text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (beat_id, sequence));

CREATE TABLE child_flow_stations (  -- T36/T54
  id text PRIMARY KEY, event_id text NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name text NOT NULL, pull_design text, capacity int, transition_cue text, keeper_role text,
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  created_by text, updated_by text, UNIQUE (event_id, name));

-- ---- Bridge columns on existing tables (additive) -------------------------
ALTER TABLE tasks            ADD COLUMN atom_code text REFERENCES atoms(code);
ALTER TABLE processes        ADD COLUMN phase_code text, ADD COLUMN atom_codes text[];
ALTER TABLE ai_capabilities  ADD COLUMN atom_code text REFERENCES atoms(code),
                             ADD COLUMN quadrant automation_quadrant;     -- B5
ALTER TABLE check_definitions ADD COLUMN atom_code text REFERENCES atoms(code);  -- B4 origin
ALTER TABLE moments          ADD COLUMN serves_outcome_code text REFERENCES outcomes(code),
                             ADD COLUMN stage_boh text;                   -- G1 membrane

-- ---- Indexes --------------------------------------------------------------
CREATE INDEX ix_atom_realizations_event ON atom_realizations(event_id);
CREATE INDEX ix_atom_realizations_atom  ON atom_realizations(atom_code);
CREATE INDEX ix_atoms_quadrant          ON atoms(quadrant);
CREATE INDEX ix_tasks_atom              ON tasks(atom_code);

-- ---- B6 governance gate (enforced here, not inherited) --------------------
-- A realization of a governance_bound atom must carry consent + lawful basis.
CREATE FUNCTION assert_atom_consent() RETURNS trigger AS $$
BEGIN
  IF (SELECT governance_bound FROM atoms WHERE code = NEW.atom_code)
     AND (NEW.consent_id IS NULL OR NEW.lawful_basis IS NULL) THEN
    RAISE EXCEPTION 'governance_bound atom % requires consent_id + lawful_basis', NEW.atom_code;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_atom_consent BEFORE INSERT OR UPDATE ON atom_realizations
  FOR EACH ROW EXECUTE FUNCTION assert_atom_consent();

-- ---- Reversal (drop to fully undo the bridge) -----------------------------
-- DROP TRIGGER trg_atom_consent ON atom_realizations; DROP FUNCTION assert_atom_consent;
-- ALTER TABLE moments DROP COLUMN serves_outcome_code, DROP COLUMN stage_boh;
-- ALTER TABLE check_definitions DROP COLUMN atom_code;
-- ALTER TABLE ai_capabilities DROP COLUMN atom_code, DROP COLUMN quadrant;
-- ALTER TABLE processes DROP COLUMN phase_code, DROP COLUMN atom_codes;
-- ALTER TABLE tasks DROP COLUMN atom_code;
-- DROP TABLE child_flow_stations, sensory_cues, atom_realizations, atoms, outcomes;
-- DROP TYPE automation_quadrant;
