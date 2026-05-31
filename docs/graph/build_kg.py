#!/usr/bin/env python3
"""Build the knowledge graph (kg.json) and the generated entity tree
(entities-by-context.md) from the authoritative data-model catalog.

Ethos: the KG is a *projection* of the catalog atoms (Tenet 6) — regenerate, don't
hand-edit. Structural nodes/edges are derived from catalog/*.yaml; the LOGIC layer
(state machines, gates, processes, governance, AI, verification, ethos, planes) is
authored here because it is logic *about* the entities, not stored in them.

Usage:  python3 docs/graph/build_kg.py
"""
import yaml, re, json, glob, os

BASE = os.path.dirname(os.path.abspath(__file__))
CAT  = os.path.join(BASE, '..', 'data-model', 'catalog')
MODEL_VERSION = open(os.path.join(BASE,'..','VERSION')).read().strip()  # single source: docs/VERSION

CTX_ORDER = ['c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','dyn','ai']
CTX_LABEL = {
  'c1':'Parties & Consent','c2':'Taste & Creative','c3':'Supply',
  'c4':'Commercial & Finance','c5':'Event Design','c6':'Production & Logistics',
  'c7':'Risk & Resilience','c8':'Communication & Relationship',
  'c9':'Acquisition & Distribution','c10':'Operations & Team',
  'c11':'Safety & Compliance','c12':'Platform & Governance',
  'dyn':'Dynamic Layer','ai':'AI Enablement'}
ARCH_ORDER = ['root','member','party','master','policy','signal','projection','value']

def scan_context(path):
    """Map each top-level entity key -> context code, by tracking section headers."""
    m, cur = {}, None
    for line in open(path):
        if line.startswith('#'):
            h = re.search(r'Context (\d+)', line)
            l = re.search(r'Layer (\w+)', line)
            if h: cur = 'c' + h.group(1)
            elif l: cur = l.group(1)
        else:
            k = re.match(r'^([A-Z][A-Za-z0-9_]*):', line)
            if k: m[k.group(1)] = cur
    return m

nodes, edges = [], []
for f in sorted(glob.glob(os.path.join(CAT, '0[1-7]-*.yaml'))):
    data = yaml.safe_load(open(f))
    cmap = scan_context(f)
    for name, meta in data.items():
        # entities have an 'arch' key; skip non-entity blocks (e.g. bridge_columns)
        if not isinstance(meta, dict) or 'arch' not in meta: continue
        nodes.append({'id': name, 'kind': 'entity',
                      'context': meta.get('ctx') or cmap.get(name),   # 07 uses per-entity ctx
                      'archetype': meta.get('arch'), 'pk': meta.get('pk'),
                      'states': meta.get('st')})
        for r in (meta.get('rel') or []):
            edges.append({'from': name, 'to': r.get('to'),
                          'rel': r.get('k'), 'card': r.get('c')})

# ---------------------------------------------------------------------------
# LOGIC layer (authored): the rules and flows that operate over the entities.
# ---------------------------------------------------------------------------
LOGIC_NODES = [
  # belief
  {'id':'T1_determinism','kind':'ethos','label':'Determinism by default'},
  {'id':'T2_verify_ensemble','kind':'ethos','label':'Verify in depth, end in ensemble'},
  {'id':'T3_two_formats','kind':'ethos','label':'Two formats, one truth + attention matrix'},
  {'id':'T4_small_steps','kind':'ethos','label':'Small steps over big leaps'},
  {'id':'T5_min_layers','kind':'ethos','label':'Minimize abstraction layers'},
  {'id':'T6_atoms_molecules','kind':'ethos','label':'Atoms -> molecules + side-set index'},
  # planes (ADR-0001)
  {'id':'control_plane','kind':'plane','label':'Control plane (Git)'},
  {'id':'data_plane','kind':'plane','label':'System of record (event-sourced Postgres)'},
  {'id':'workflow_surface','kind':'plane','label':'Workflow surface (ticketing, swappable)'},
  # state machines (spine)
  {'id':'sm_engagement','kind':'state_machine','label':'engagement_state',
   'states':['inquiry','proposed','contracted','active','delivered','closed','lost']},
  {'id':'sm_event','kind':'state_machine','label':'event_state',
   'states':['briefing','designing','planning','confirmed','in_production','live_day','wrap','reviewed','postponed','cancelled']},
  {'id':'sm_booking','kind':'state_machine','label':'booking_state',
   'states':['held','confirmed','fulfilled','cancelled','no_show']},
  {'id':'sm_suggestion','kind':'state_machine','label':'suggestion_state',
   'states':['proposed','under_review','accepted','edited','rejected']},
  # invariants / gates
  {'id':'GATE_event_confirm','kind':'invariant',
   'label':'Event->confirmed requires approved EventConcept + funded Budget + secured Venue + granted Permits'},
  {'id':'GATE_booking_confirm','kind':'invariant',
   'label':'Booking->confirmed requires active VendorContract + fits Budget'},
  {'id':'GATE_engagement_active','kind':'invariant',
   'label':'Engagement->active requires signed Contract + assigned Pod + funded Budget + active Consent'},
  {'id':'GATE_ai_outward','kind':'invariant',
   'label':'No client/guest/vendor-facing artifact from a Suggestion without accepted/edited HumanReview'},
  {'id':'GATE_signal_use','kind':'invariant',
   'label':'ProfileSignal usable only with active Consent + LawfulBasis; excluded on withdrawal/expiry'},
  {'id':'GATE_minor_enrichment','kind':'invariant',
   'label':'scraped/enriched signal on a minor requires guardian Consent + permitting SourcePolicy'},
  {'id':'GATE_outward_use','kind':'invariant',
   'label':'Showcase/Referral/testimonial gated by DiscretionPolicy + MediaPolicy + Consent'},
  # processes (sagas)
  {'id':'proc_confirmation','kind':'process','label':'ConfirmationProcess'},
  {'id':'proc_raincall','kind':'process','label':'RainCallProcess'},
  {'id':'proc_cancellation','kind':'process','label':'CancellationProcess'},
  {'id':'proc_consent_withdrawal','kind':'process','label':'ConsentWithdrawalProcess'},
  # verification / attention
  {'id':'check_error','kind':'logic','label':'error check'},
  {'id':'check_logic','kind':'logic','label':'logic check'},
  {'id':'check_det','kind':'logic','label':'deterministic check'},
  {'id':'check_nondet','kind':'logic','label':'non-deterministic check'},
  {'id':'ensemble','kind':'logic','label':'ensemble (quorum, escalate on disagreement)'},
  {'id':'attention_matrix','kind':'logic','label':'urgency x importance attention matrix'},
]

LOGIC_EDGES = [
  # planes carry archetypes (ADR-0001)
  {'from':'control_plane','to':'master','rel':'hosts'},
  {'from':'control_plane','to':'policy','rel':'hosts'},
  {'from':'data_plane','to':'root','rel':'hosts'},
  {'from':'data_plane','to':'party','rel':'hosts'},
  {'from':'data_plane','to':'projection','rel':'hosts'},
  {'from':'data_plane','to':'signal','rel':'hosts'},
  {'from':'workflow_surface','to':'Task','rel':'surfaces'},
  {'from':'workflow_surface','to':'Approval','rel':'surfaces'},
  {'from':'workflow_surface','to':'Incident','rel':'surfaces'},
  # state machines govern aggregates
  {'from':'sm_engagement','to':'Engagement','rel':'governs'},
  {'from':'sm_event','to':'Event','rel':'governs'},
  {'from':'sm_booking','to':'Booking','rel':'governs'},
  {'from':'sm_suggestion','to':'Suggestion','rel':'governs'},
  {'from':'StateTransition','to':'sm_event','rel':'defines'},
  {'from':'StateTransition','to':'sm_engagement','rel':'defines'},
  # confirmation gate
  {'from':'GATE_event_confirm','to':'Event','rel':'gates'},
  {'from':'GATE_event_confirm','to':'EventConcept','rel':'requires'},
  {'from':'GATE_event_confirm','to':'Budget','rel':'requires'},
  {'from':'GATE_event_confirm','to':'Venue','rel':'requires'},
  {'from':'GATE_event_confirm','to':'Permit','rel':'requires'},
  {'from':'proc_confirmation','to':'GATE_event_confirm','rel':'enforces'},
  {'from':'proc_confirmation','to':'sm_event','rel':'drives'},
  # booking / engagement gates
  {'from':'GATE_booking_confirm','to':'Booking','rel':'gates'},
  {'from':'GATE_booking_confirm','to':'VendorContract','rel':'requires'},
  {'from':'GATE_booking_confirm','to':'Budget','rel':'requires'},
  {'from':'GATE_engagement_active','to':'Engagement','rel':'gates'},
  {'from':'GATE_engagement_active','to':'Contract','rel':'requires'},
  {'from':'GATE_engagement_active','to':'Pod','rel':'requires'},
  {'from':'GATE_engagement_active','to':'Consent','rel':'requires'},
  # AI guardrail flow
  {'from':'AICapability','to':'Agent','rel':'performed_by'},
  {'from':'Agent','to':'Invocation','rel':'emits'},
  {'from':'Invocation','to':'Suggestion','rel':'yields'},
  {'from':'Invocation','to':'GuardedAction','rel':'yields'},
  {'from':'Suggestion','to':'HumanReview','rel':'gated_by'},
  {'from':'GATE_ai_outward','to':'Suggestion','rel':'gates'},
  {'from':'PolicyGuardrail','to':'AICapability','rel':'constrains'},
  {'from':'PolicyGuardrail','to':'GuardedAction','rel':'constrains'},
  {'from':'HumanReview','to':'Concept','rel':'may_produce'},
  {'from':'HumanReview','to':'Message','rel':'may_produce'},
  {'from':'HumanReview','to':'ProfileSignal','rel':'may_produce'},
  # governance / consent
  {'from':'Consent','to':'ProfileSignal','rel':'governs'},
  {'from':'GATE_signal_use','to':'ProfileSignal','rel':'gates'},
  {'from':'GATE_signal_use','to':'Consent','rel':'requires'},
  {'from':'GATE_minor_enrichment','to':'ProfileSignal','rel':'gates'},
  {'from':'GATE_minor_enrichment','to':'SourcePolicy','rel':'requires'},
  {'from':'GATE_minor_enrichment','to':'Celebrant','rel':'protects'},
  {'from':'ProfileSignal','to':'ClientProfile','rel':'feeds'},
  {'from':'GATE_outward_use','to':'Showcase','rel':'gates'},
  {'from':'DiscretionPolicy','to':'GATE_outward_use','rel':'informs'},
  {'from':'RetentionPolicy','to':'ProfileSignal','rel':'expires'},
  # processes listen/emit via domain events
  {'from':'proc_raincall','to':'EnvironmentForecast','rel':'listens_to'},
  {'from':'proc_raincall','to':'Contingency','rel':'triggers'},
  {'from':'proc_cancellation','to':'sm_event','rel':'drives'},
  {'from':'proc_cancellation','to':'Booking','rel':'unwinds'},
  {'from':'proc_consent_withdrawal','to':'Consent','rel':'listens_to'},
  {'from':'proc_consent_withdrawal','to':'GATE_signal_use','rel':'enforces'},
  {'from':'DomainEvent','to':'proc_confirmation','rel':'wakes'},
  {'from':'DomainEvent','to':'proc_raincall','rel':'wakes'},
  # verification ensemble (Ethos T2/T3)
  {'from':'check_error','to':'ensemble','rel':'feeds'},
  {'from':'check_logic','to':'ensemble','rel':'feeds'},
  {'from':'check_det','to':'ensemble','rel':'feeds'},
  {'from':'check_nondet','to':'ensemble','rel':'feeds'},
  {'from':'ensemble','to':'CheckResult','rel':'records'},
  {'from':'ensemble','to':'Alert','rel':'escalates'},
  {'from':'CheckResult','to':'attention_matrix','rel':'ranked_by'},
  {'from':'attention_matrix','to':'Alert','rel':'routes'},
  # ethos anchors
  {'from':'T2_verify_ensemble','to':'ensemble','rel':'realized_by'},
  {'from':'T3_two_formats','to':'CheckResult','rel':'realized_by'},
  {'from':'T3_two_formats','to':'attention_matrix','rel':'realized_by'},
  {'from':'T1_determinism','to':'GATE_ai_outward','rel':'realized_by'},
  {'from':'T6_atoms_molecules','to':'data_plane','rel':'realized_by'},
]

nodes += LOGIC_NODES
edges += LOGIC_EDGES

# Merge-bridge logic (v2.0): how the Fête atom catalog interfaces this model.
BRIDGE_NODES = [
  {'id':'GATE_atom_consent','kind':'invariant',
   'label':'AtomRealization of a governance_bound atom requires consent_id + lawful_basis (B6)'},
]
BRIDGE_EDGES = [
  {'from':'Task','to':'Atom','rel':'templated_by'},            # tasks.atom_code
  {'from':'AICapability','to':'Atom','rel':'templated_by'},    # ai_capabilities.atom_code
  {'from':'AICapability','to':'GATE_ai_outward','rel':'quadrant_binds'},  # quadrant -> AI guardrail (B5)
  {'from':'CheckDefinition','to':'Atom','rel':'derived_from'}, # benchmark/failure-mode (B4)
  {'from':'Moment','to':'Outcome','rel':'serves'},             # moments.serves_outcome_code
  {'from':'GATE_atom_consent','to':'AtomRealization','rel':'gates'},
  {'from':'GATE_atom_consent','to':'Consent','rel':'requires'},
]
nodes += BRIDGE_NODES
edges += BRIDGE_EDGES

# deterministic ordering (Ethos T1)
nodes.sort(key=lambda n: (n['kind'], n.get('context') or '', n['id']))
edges.sort(key=lambda e: (e['from'], e['to'] or '', e['rel'] or ''))

kg = {'meta': {'version': MODEL_VERSION,
               'generated_from': 'docs/data-model/catalog/*.yaml + authored logic + merge bridge',
               'node_count': len(nodes), 'edge_count': len(edges),
               'kinds': sorted({n['kind'] for n in nodes}),
               'edge_relations': sorted({e['rel'] for e in edges if e['rel']})},
      'nodes': nodes, 'edges': edges}
with open(os.path.join(BASE, 'kg.json'), 'w') as fh:
    json.dump(kg, fh, indent=2, sort_keys=True)

# generated entity tree (contexts -> archetype -> entities)
ents = [n for n in nodes if n['kind'] == 'entity']
lines = [f'# Entities by context (generated) — v{MODEL_VERSION}',
         '',
         '> Generated by `build_kg.py` from the catalog. Do not hand-edit; regenerate.',
         f'> {len(ents)} entities across {len(CTX_ORDER)} contexts/layers.', '']
for c in CTX_ORDER:
    block = [e for e in ents if e['context'] == c]
    if not block: continue
    lines.append(f'## {c} — {CTX_LABEL[c]}  ({len(block)})')
    for a in ARCH_ORDER:
        row = sorted(e['id'] for e in block if e['archetype'] == a)
        if row:
            lines.append(f'- **{a}**: ' + ', '.join(
                f"{i}`{next(e['pk'] for e in block if e['id']==i)}`"
                + (f" [{next(e['states'] for e in block if e['id']==i)}]"
                   if next(e['states'] for e in block if e['id']==i) else '')
                for i in row))
    lines.append('')
with open(os.path.join(BASE, 'entities-by-context.md'), 'w') as fh:
    fh.write('\n'.join(lines))

print(f"nodes={len(nodes)} edges={len(edges)} entities={len(ents)}")
print("kinds:", sorted({n['kind'] for n in nodes}))
miss = sorted({e['context'] for e in ents if not e['context']})
print("entities missing context:", miss or "none")
