-- 01 — kernel value types (composite). The value-object atoms survive into the molecule.
-- Mirrors catalog/00-kernel.yaml value_types. Embedded as column types in 02-tables.sql.
SET search_path = unspun, public;

-- NB: named money_amount, not money — 'money' is a built-in Postgres type.
CREATE TYPE money_amount AS (
  amount    numeric(14,2),
  currency  text          -- ISO-4217; base currency tracked per budget/engagement
);

CREATE TYPE datewindow AS (
  start_at  timestamptz,
  end_at    timestamptz,  -- null = open-ended
  tz        text
);

CREATE TYPE geopoint AS (
  lat         double precision,
  lng         double precision,
  precision_m double precision,
  label       text          -- the "pinpoint geo target"
);

CREATE TYPE provenance AS (              -- origin of any sourced datum
  source        text,                    -- url | system | person | vendor | model
  method        capture_method,
  collected_by  text,
  captured_at   timestamptz,
  confidence    confidence,
  source_ref    text,
  derived_from_invocation_id text        -- for method = 'inferred'
);

CREATE TYPE score AS (
  dimension text,
  value     numeric,
  scale     text,
  basis     text
);

CREATE TYPE priority AS (                 -- the attention matrix (Building Ethos T3)
  urgency    urgency,
  importance importance
);
