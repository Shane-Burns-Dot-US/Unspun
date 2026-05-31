# Unspun — System Design Docs · v2.1

The standard system-design set: how the platform is *built and run*, grounded in the domain
model ([`../spec`](../spec)), the data model ([`../data-model`](../data-model)), the
substrate decision ([ADR-0001](../decisions/ADR-0001-system-data-substrate.md)), and the
merge ([`../reconciliation`](../reconciliation)).

**Version:** v2.1 (tracks [`../VERSION`](../VERSION)).

## The set

| Doc | Standard equivalent | Read it for |
|---|---|---|
| [`system-design.md`](./system-design.md) | SDD / HLD (arc42 condensed) | Goals, scope, constraints, solution strategy, quality goals, risks |
| [`architecture-c4.md`](./architecture-c4.md) | C4 model | System context, containers, key components (diagrams) |
| [`components.md`](./components.md) | Component/service decomposition | The building blocks, responsibilities, data ownership, interfaces |
| [`runtime-flows.md`](./runtime-flows.md) | Sequence / data-flow views | The load-bearing journeys end to end |
| [`api-and-events.md`](./api-and-events.md) | Interface design | API surfaces + the canonical domain-event contract |
| [`nfr.md`](./nfr.md) | Non-functional requirements | Quality-attribute targets and how they're met |
| [`security-privacy.md`](./security-privacy.md) | Security architecture / threat model | Trust boundaries, STRIDE, minors' PII, consent, discretion |
| [`deployment-and-ops.md`](./deployment-and-ops.md) | Deployment + operations | Topology, environments, observability, DR, runbooks |

## Design ground rules (inherited)

- **Two planes** (ADR-0001): Git **control plane** (definitions/atoms/policies) · event-sourced
  Postgres **data plane** (instances/PII) · ticketing **workflow surface**.
- **Human-fronted, AI-backed:** AI is internal; every AI output is a `Suggestion` gated by
  `HumanReview` before it reaches a client, guest, vendor, money, or the physical world.
- **Building Ethos:** determinism by default · verify-in-depth/ensemble · two formats one
  truth + attention matrix · small steps · minimal layers · atoms→molecules.
- **Reference, not lock-in:** technology picks below are a *reference design*; the binding
  decisions are the planes (ADR-0001) and the contracts (events/API), not the frameworks.

## Reference stack (illustrative)

Modular monolith for the core domain (extract services only where scale/security demands) ·
Postgres (system of record, event-sourced) · object storage (media) · vector/search store
(taste + KG retrieval) · message/event log · managed LLM provider behind the AI-Enablement
service · SMS/email, e-sign, payments, weather, calendar, maps as governed integrations.
