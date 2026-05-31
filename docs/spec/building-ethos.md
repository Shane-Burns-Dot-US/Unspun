# Unspun — Building Ethos

**Status:** Foundational belief document (the *how*).
**Relationship to the keystone:** [`domain-keystone.md`](./domain-keystone.md) defines
*what exists*; this document defines *how it must be built, verified, and surfaced.* Where
the keystone is the noun, this is the verb. Both bind the same system.

> This is a statement of belief about construction. It is deliberately durable and
> implementation‑agnostic: no timelines, no estimates, no tool choices — principles and
> the structures they imply.

---

## The six tenets

### 1. Determinism by default

**Everything that can be deterministic, is.** Determinism is the default; non‑determinism
is the explicit, fenced exception — never the ambient condition.

- A behavior is deterministic when the same inputs always produce the same outputs and the
  same state transition. Prefer it everywhere: identity (the prefixed, sortable IDs of the
  keystone §3), state machines (§17), pricing math, validation, scheduling rules,
  reconciliations.
- Non‑determinism has exactly three legitimate sources: **AI** (the `AICapability` layer),
  **human judgment**, and **the outside world** (weather, vendors, networks). Each must be
  *wrapped* by deterministic guards on both sides — deterministic inputs in, deterministic
  validation and recording out. This is already the shape of `Suggestion → HumanReview`;
  generalize it. **No raw non‑deterministic output reaches a client, guest, vendor, money,
  or the physical world un‑guarded.**
- A non‑deterministic step that *could* have been deterministic is a defect, not a
  convenience.

### 2. Verify in depth — and end with an ensemble

**What can be double‑checked is triple‑checked, or more — and the final pass is an
ensemble.** Verification is not a phase; it is a property of every step.

Checks come in four kinds, and a serious result is examined by **independent** checkers of
*different* kinds (a checker must never share the method that produced the thing it
checks):

| Check kind | Asks | Examples |
|---|---|---|
| **Error checks** | Did it *fail*? Is it well‑formed? | schema/type validity, exceptions, bounds, nulls |
| **Logic checks** | Does it *make sense*? | invariants, business rules, cross‑foot/reconciliation, "can't confirm without funded budget" |
| **Deterministic checks** | Is it *reproducible*? | property tests, replays, idempotency, recomputation from source |
| **Non‑deterministic checks** | Does *judgment* agree? | AI critique, human review, anomaly/statistical outlier detection |

**The ensemble (the fifth pass and beyond):** combine multiple independent checkers and
require **agreement / quorum**. Agreement passes silently; **disagreement escalates** to a
human via the surfacing rules of Tenet 3. The depth of checking is scaled by the
importance × urgency of what's being checked (Tenet 3) — trivial things get the cheap
passes; consequential things (money, minors' data, the day‑of, an irreversible commitment)
get the full ensemble.

**Checks are first‑class artifacts.** Every check produces a recorded result
(a `CheckResult` / `VerificationRecord`), append‑only, attributable, and replayable —
sitting in the Signal/Record archetype alongside `AuditEvent` and `DomainEvent`. A check
that leaves no record did not happen.

### 3. Two audiences, two formats, one truth

**Every result is emitted in both a machine‑readable optimization format and a simply
intuitive, human‑intelligible format — and the human one matters more.**

- **Machine format:** complete, structured, lossless, built for pipelines, metrics, and
  optimization. This is the substrate.
- **Human format:** a *projection* (in the keystone/MECE sense — it holds no independent
  truth) that **abstracts away complexity while staying consistently structured.** Same
  shape every time, so a person learns to read it once. It does not show everything; it
  shows **what matters, ranked.**

Both are derived from the **same single source of truth**; they may never diverge. The
machine format is exhaustive; the human format is *curated by consequence*.

**What the human sees is governed by an urgency × importance matrix:**

| | **Urgent** | **Not urgent** |
|---|---|---|
| **Important** | **Act now** — surfaced loudly, top of view (a day‑of failure, a safety/consent breach, an ensemble disagreement on something consequential) | **Schedule** — visible, planned, not alarming (an upcoming permit, a vendor reconfirmation) |
| **Not important** | **Delegate / automate** — handled deterministically, shown only as a tidy summary | **Suppress** — recorded in the machine format, kept out of the human's face entirely |

The matrix is the contract for *attention*: it decides prominence, channel, and whether a
human is interrupted at all. Importance and urgency are themselves scored on the
standardized scales the clarity review (M‑1) asks for, so the projection is computed, not
hand‑curated.

### 4. Small steps over big leaps

**Many small, incremental steps beat a few big ones.** Each step should be independently
**verifiable** (Tenet 2), **observable**, and wherever possible **reversible**. Small steps
make failure cheap, local, and visible; big steps hide it until it's expensive. Compose
forward in atoms (Tenet 6); never advance the system in a leap that can't be checked or
backed out.

### 5. Minimize layers of abstraction

**Keep the abstraction stack shallow.** Every layer must justify its own existence; an
unjustified layer is removed. Prefer **flat composition of small units over tall towers of
abstraction.**

The reason is not aesthetic — it is **optionality.** Thin, removable layers let *different
schemas and variations* be assembled for different use cases, rather than forcing every
consumer through one canonical abstraction that was optimized for someone else. When you
must choose between a clever abstraction and a shallow, recombinable structure, choose
shallow. (This deliberately trades some DRY for far more adaptability; that trade is
intended.)

### 6. Atomic particles, molecular recomposition

**Below the high‑level objects live atomic particles that can be re‑composed into different
molecular structures depending on what a human or a machine wants to optimize for.**

- The keystone's high‑level objects are **one** valid composition of the underlying facts —
  the default molecule. They are not the only legal arrangement of the atoms.
- Keep the **atomic substrate addressable**: the smallest meaningful, reusable units —
  individual fields, facts, checks, steps, the "atomic unit of delight" from Addendum A.
  An atom does one thing and is reusable across many molecules.
- The same atoms recombine into alternative **molecular structures** (alternative schemas,
  views, pipelines) selected per **optimization target** — what *this* human or *this*
  machine needs for *this* use case. A photographer's call‑sheet, a finance reconciliation,
  a delight storyboard, and a vendor scorecard are different molecules built from
  overlapping atoms.
- Maintain a **side‑set index**: a parallel, orthogonal index of the *multiple valid
  approaches* (the "multiplexes") — so the right composition can be chosen deliberately
  rather than rediscovered. This is the same dual‑axis move the MECE review makes (Context
  × Archetype), generalized: the high‑level object is one index; the side‑set index records
  the others.

> Practically: do not let the high‑level object become a one‑way door that traps its data.
> Build it from atoms, keep the atoms first‑class, and keep an index of the other ways
> those atoms can be arranged.

---

## How the tenets reinforce each other

They are one loop, not six rules:

**Atoms (6)** are advanced by **small steps (4)**, each **verified in depth (2)**, with
non‑deterministic moves fenced by **determinism (1)**, every result kept in **two formats
with one truth (3)**, all over a **shallow, recombinable stack (5)** so the atoms can be
re‑composed (6) for the next use case. Determinism makes verification cheap; small steps
make verification local; shallow layers keep the atoms reachable; the dual format makes the
whole thing legible to both the optimizer and the human.

---

## Anti‑patterns (violations of the ethos)

- **Ambient non‑determinism** — AI or judgment in a path that could have been deterministic,
  or non‑deterministic output reaching the world un‑guarded.
- **Single‑pass trust** — accepting a consequential result on one check, or checking with
  the same method that produced it (no independence, no ensemble).
- **Format monoculture** — machine‑only output (illegible to humans) or human‑only output
  (un‑optimizable), or two formats that have drifted from one truth.
- **Flat firehose** — showing humans everything instead of ranking by urgency × importance.
- **Big‑bang steps** — advances that can't be individually verified or reversed.
- **Abstraction towers** — layers that exist for elegance, trapping the atoms beneath them
  in a single schema.
- **Sealed objects** — high‑level objects whose underlying particles can't be addressed or
  re‑composed, with no side‑set index of alternatives.

---

## Relationship to the rest of the corpus

- **Keystone** (`domain-keystone.md`) — the objects these tenets build and decompose.
- **MECE review** (`mece-review.md`) — Tenet 6's dual‑axis (Context × Archetype) and Tenet
  3's "projection" archetype originate there.
- **Gaps & clarity review** (`gaps-and-clarity-review.md`) — Tenet 2's checks ride on the
  dynamic layer (domain events, processes) that review asks for; Tenet 3's matrix uses the
  standardized scales (M‑1) it asks for.
- **Addendum A (Chesky)** — Tenet 6's "atom" is that addendum's *atomic unit of delight*;
  Tenet 3's human projection is its "human‑intelligible, abstraction‑away‑complexity"
  surface for the Host.

This ethos is the standing answer to "how should we build this part?" — apply the six
tenets, in the loop above, scaled by consequence.
