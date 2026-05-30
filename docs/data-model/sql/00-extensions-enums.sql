-- Unspun reference schema (the relational "molecule" of the atomic catalog).
-- 00 — extensions + enums. Mirrors catalog/00-kernel.yaml enums.
-- Generated/maintained per docs/data-model/README.md §4.

CREATE EXTENSION IF NOT EXISTS pgcrypto;     -- gen ids if not supplied by app
CREATE SCHEMA IF NOT EXISTS unspun;
SET search_path = unspun, public;

-- ids are text ULIDs with a type prefix (e.g. 'evt_01J...'); the app supplies them.

-- standardized scales --------------------------------------------------------
CREATE TYPE confidence        AS ENUM ('very_low','low','medium','high','very_high');
CREATE TYPE likelihood        AS ENUM ('rare','unlikely','possible','likely','almost_certain');
CREATE TYPE impact            AS ENUM ('negligible','minor','moderate','major','severe');
CREATE TYPE sentiment         AS ENUM ('very_negative','negative','neutral','positive','very_positive');
CREATE TYPE sensitivity_class AS ENUM ('public','internal','confidential','restricted','minor_protected');
CREATE TYPE discretion_level  AS ENUM ('open','standard','discreet','private','sealed');
CREATE TYPE urgency           AS ENUM ('none','low','medium','high','critical');
CREATE TYPE importance        AS ENUM ('trivial','low','medium','high','vital');
CREATE TYPE edge_strength     AS ENUM ('weak','moderate','strong','primary');
CREATE TYPE capture_method    AS ENUM ('declared','observed','inferred','enriched','scraped');
CREATE TYPE lawful_basis      AS ENUM ('consent','contract','legitimate_interest','legal_obligation','vital_interest');
CREATE TYPE check_kind        AS ENUM ('error','logic','deterministic','non_deterministic','ensemble');
CREATE TYPE check_verdict     AS ENUM ('pass','warn','fail','disagree','inconclusive');
CREATE TYPE archetype         AS ENUM ('root','member','party','master','policy','signal','projection','value');

-- status enums ---------------------------------------------------------------
CREATE TYPE engagement_state  AS ENUM ('inquiry','proposed','contracted','active','delivered','closed','lost');
CREATE TYPE event_state       AS ENUM ('briefing','designing','planning','confirmed','in_production','live_day','wrap','reviewed','postponed','cancelled');
CREATE TYPE concept_state     AS ENUM ('draft','in_review','approved','selected','archived');
CREATE TYPE guest_state       AS ENUM ('invited','responded','confirmed','attended','no_show');
CREATE TYPE rsvp_response     AS ENUM ('yes','no','maybe','no_response');
CREATE TYPE quote_state       AS ENUM ('requested','received','accepted','rejected','expired');
CREATE TYPE booking_state     AS ENUM ('held','confirmed','fulfilled','cancelled','no_show');
CREATE TYPE permit_state      AS ENUM ('required','applied','granted','denied','expired');
CREATE TYPE task_state        AS ENUM ('todo','in_progress','blocked','done','cancelled');
CREATE TYPE risk_state        AS ENUM ('identified','mitigated','accepted','realized','closed');
CREATE TYPE incident_state    AS ENUM ('open','mitigating','resolved','post_mortem_done');
CREATE TYPE change_state      AS ENUM ('proposed','approved','rejected','applied');
CREATE TYPE touchpoint_state  AS ENUM ('planned','scheduled','sent','acknowledged','failed');
CREATE TYPE suggestion_state  AS ENUM ('proposed','under_review','accepted','edited','rejected');
CREATE TYPE consent_state     AS ENUM ('granted','active','withdrawn','expired');
CREATE TYPE lead_state        AS ENUM ('new','qualified','nurtured','won','lost','waitlisted');
CREATE TYPE deliverable_state AS ENUM ('specified','sourced','in_production','delivered','accepted','rejected');
CREATE TYPE delivery_state    AS ENUM ('pending','dispatched','in_transit','delivered','receipt_confirmed','failed');
CREATE TYPE payment_state     AS ENUM ('scheduled','authorized','captured','settled','refunded','failed');
CREATE TYPE payment_direction AS ENUM ('inbound','outbound');
CREATE TYPE approval_state    AS ENUM ('pending','approved','rejected','escalated');
CREATE TYPE process_state     AS ENUM ('pending','running','waiting','completed','failed','compensating');
CREATE TYPE doc_state         AS ENUM ('draft','active','superseded','expired','void');
