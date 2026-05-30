#!/usr/bin/env python3
"""Execute the merge: map ALL 78 Fête atoms to Unspun, keep every atom, emit:
  - merge-ledger.yaml   (machine map: atom -> disposition + targets, all 78)
  - merge-map.md        (human map: the same, as a table)
  - unified-graph.json  (kg.json nouns + fete atoms/outcomes kept + 'realizes' edges)

Move 1 (RECONCILE) + Pass 6 (UNIFY) of merge-procedure.md. Deterministic; regenerate.
Disposition is authored here (the CD/partner adjudication, encoded). Run:
  python3 docs/reconciliation/build_merge.py
"""
import json, os, yaml
BASE=os.path.dirname(os.path.abspath(__file__))
FETE=json.load(open(os.path.join(BASE,'fete-graph.json')))
KG=json.load(open(os.path.join(BASE,'..','graph','kg.json')))

# disposition: code -> (disposition, [unspun targets])
# EXISTING = is an existing master; DECOMPOSE = spans several; NEW-MASTER = genuinely new
D = {
 'T01':('EXISTING',['Lead','Inquiry','ContactChannel','AuditEvent']),
 'T02':('EXISTING',['AICapability','Lead']),
 'T03':('EXISTING',['AICapability','ProfileSignal','ClientProfile']),
 'T04':('EXISTING',['AICapability','TasteProfile','ProfileSignal']),
 'T05':('EXISTING',['AICapability','Consent','DiscretionPolicy','SourcePolicy']),
 'T06':('NEW-MASTER',['Touchpoint','Thread']),
 'T07':('DECOMPOSE',['EventBrief','AICapability']),
 'T08':('EXISTING',['Tastemaker','EventConcept']),
 'T09':('EXISTING',['Touchpoint','Message','MessageTemplate']),
 'T10':('NEW-MASTER',['Thread','Touchpoint']),
 'T11':('EXISTING',['TasteProfile','PreferenceModel','AICapability']),
 'T12':('DECOMPOSE',['PreferenceModel','TasteProfile','AICapability']),
 'T13':('EXISTING',['Concept','InspirationSource','AICapability']),
 'T14':('EXISTING',['Tastemaker','Concept','HumanReview']),
 'T15':('EXISTING',['Concept','MessageTemplate','AICapability']),
 'T16':('EXISTING',['VendorRecommendation','Vendor','Offering','Roster']),
 'T17':('DECOMPOSE',['Vendor','RelationshipEdge','Segment','ContainmentPolicy']),
 'T18':('EXISTING',['VendorRecommendation']),
 'T19':('EXISTING',['Tastemaker','Booking']),
 'T20':('NEW-MASTER',['Budget','DiscretionPolicy','Consent']),
 'T21':('EXISTING',['Quote','Booking','AICapability']),
 'T22':('EXISTING',['Proposal','PricingPlan']),
 'T23':('EXISTING',['Proposal','Document','MessageTemplate']),
 'T24':('DECOMPOSE',['Contract','Payment','CalendarItem','Engagement']),
 'T25':('EXISTING',['Process','Engagement','Pod']),
 'T26':('NEW-MASTER',['Pod','TeamMember','Touchpoint']),
 'T27':('EXISTING',['Concept','BrandAsset','AICapability']),
 'T28':('EXISTING',['Invitation','MessageTemplate','BrandAsset']),
 'T29':('EXISTING',['AICapability','Booking']),
 'T30':('EXISTING',['Quote','Booking','AICapability']),
 'T31':('EXISTING',['VendorContract','Document']),
 'T32':('DECOMPOSE',['Deposit','Payment','Ledger','Invoice']),
 'T33':('EXISTING',['Permit','Document']),
 'T34':('EXISTING',['VendorUser','VendorAccessRole']),
 'T35':('DECOMPOSE',['Program','Beat','LogisticsPlan','Process','Playbook']),
 'T36':('NEW-MASTER',['ChildFlowStation','Beat']),
 'T37':('DECOMPOSE',['Program','Beat']),
 'T38':('NEW-MASTER',['SensoryCue','Beat']),
 'T39':('DECOMPOSE',['GuestExperience','RSVP','SupervisionPlan','EmergencyPlan']),
 'T40':('DECOMPOSE',['Permission','Approval']),
 'T41':('NEW-MASTER',['Process','Permission','Approval']),
 'T42':('EXISTING',['Task','Venue','Checklist']),
 'T43':('EXISTING',['Task','Checklist','ChecklistRun']),
 'T44':('EXISTING',['Touchpoint','MessageTemplate','Document']),
 'T45':('NEW-MASTER',['Touchpoint']),
 'T46':('DECOMPOSE',['MediaPlan','ShotList','RelationshipEdge','MediaPolicy']),
 'T47':('EXISTING',['MediaGallery']),
 'T48':('DECOMPOSE',['Risk','Contingency','Process']),
 'T49':('DECOMPOSE',['Shift','ResourceAssignment','LogisticsPlan']),
 'T50':('DECOMPOSE',['Shift','ResourceAssignment']),
 'T51':('EXISTING',['Tastemaker','CheckResult']),
 'T52':('DECOMPOSE',['Guest','AccessPass']),
 'T53':('DECOMPOSE',['Program','Beat','Process']),
 'T54':('DECOMPOSE',['ChildFlowStation','SupervisionPlan']),
 'T55':('DECOMPOSE',['Program','Beat']),
 'T56':('NEW-MASTER',['Role','Pod']),
 'T57':('DECOMPOSE',['Incident','Contingency','Process']),
 'T58':('EXISTING',['MediaCrew','Shot']),
 'T59':('EXISTING',['MediaCrew','MediaGallery','BrandAsset']),
 'T60':('EXISTING',['Tastemaker','CheckResult']),
 'T61':('DECOMPOSE',['Shift','LogisticsPlan']),
 'T62':('NEW-MASTER',['Touchpoint']),
 'T63':('EXISTING',['MediaGallery','AICapability']),
 'T64':('EXISTING',['MediaGallery','Tastemaker']),
 'T65':('EXISTING',['MediaGallery','AICapability']),
 'T66':('EXISTING',['MediaGallery','Document']),
 'T67':('EXISTING',['Touchpoint','Message']),
 'T68':('NEW-MASTER',['Touchpoint','FeedbackSignal']),
 'T69':('EXISTING',['Referral','AICapability','HumanReview']),
 'T70':('EXISTING',['BrandAsset','Showcase']),
 'T71':('EXISTING',['VendorPerformance','VendorRating']),
 'T72':('DECOMPOSE',['Vendor','Roster']),
 'T73':('EXISTING',['ClientProfile','ProfileSignal']),
 'T74':('DECOMPOSE',['Cadence','Touchpoint']),
 'T75':('DECOMPOSE',['Referral','LedgerEntry']),
 'T76':('DECOMPOSE',['QualityReview','Playbook','KnowledgeAsset']),
 'T77':('DECOMPOSE',['Document','BrandAsset','MediaGallery']),
 'T78':('NEW-MASTER',['BrandAsset']),
}
# governance-bound (PII / minor / scrape-infer-enrich) — hard consent gate (Addendum B6)
GOV = {'T03','T04','T05','T20','T46','T73'}
# new proposed Unspun objects the merge introduces
NEW_OBJECTS = {'ChildFlowStation','SensoryCue'}

atoms=[n for n in FETE['nodes'] if n['kind']=='atom']
assert len(atoms)==78, f"expected 78 atoms, got {len(atoms)}"
missing=[a['id'] for a in atoms if a['id'] not in D]
assert not missing, f"atoms with no disposition: {missing}"

kg_ids={n['id'] for n in KG['nodes']}
ledger=[]
for a in sorted(atoms,key=lambda x:x['id']):
    code=a['id']; disp,targets=D[code]
    cd_sign = a['skill']=='TST' or a['quadrant']=='HUMAN'
    check_required = a['quadrant']!='AUTO' or code in {'T39'}  # B4: HUMAN/AUG-HITL/HUMAN-AI + safety-critical AUTO
    owner = 'CD' if a['skill']=='TST' else ('planner' if a['quadrant'] in ('HUMAN','HUMAN-AI') else 'dev')
    ledger.append({'atom':code,'name':a['name'],'arc':a['arc'],'phase':a['phase'],
        'ws':a['ws'],'skill':a['skill'],'quadrant':a['quadrant'],'serves':a['serves'],
        'disposition':disp,'unspun_targets':targets,
        'governance_bound':code in GOV,'check_required':check_required,
        'cd_sign_required':cd_sign,'owner':owner})

# ---- merge-ledger.yaml (the authoritative map; ALL 78) --------------------
from collections import Counter
dispc=Counter(r['disposition'] for r in ledger)
yaml_doc={'meta':{'atoms':len(ledger),'dispositions':dict(dispc),
    'governance_bound':sorted(GOV),'new_objects_introduced':sorted(NEW_OBJECTS),
    'join_key':'atom_code','note':'All 78 atoms retained; merge maps each to Unspun, none dropped.'},
    'ledger':ledger}
yaml.safe_dump(yaml_doc, open(os.path.join(BASE,'merge-ledger.yaml'),'w'), sort_keys=False, width=100)

# ---- merge-map.md (human map) ---------------------------------------------
rows=['# Merge Map — all 78 atoms retained, each mapped to Unspun',
 '',
 '> Generated by `build_merge.py`. The authoritative form is `merge-ledger.yaml`.',
 f'> Dispositions: {dict(dispc)}.  Governance-bound: {len(GOV)}.  None dropped.',
 '',
 '| Atom | Name | Q | Disp | Unspun targets | gov | chk | owner |',
 '|---|---|---|---|---|:--:|:--:|:--:|']
for r in ledger:
    rows.append(f"| {r['atom']} | {r['name'][:40]} | {r['quadrant']} | {r['disposition']} | "
        f"{', '.join(r['unspun_targets'])} | {'Y' if r['governance_bound'] else ''} | "
        f"{'Y' if r['check_required'] else ''} | {r['owner']} |")
open(os.path.join(BASE,'merge-map.md'),'w').write('\n'.join(rows)+'\n')

# ---- unified-graph.json (nouns + ALL atoms + outcomes + realizes edges) ---
nodes=list(KG['nodes']); edges=list(KG['edges'])
nid={n['id'] for n in nodes}
for n in FETE['nodes']:
    if n['kind'] in ('atom','outcome') and n['id'] not in nid:
        nodes.append(n); nid.add(n['id'])
# keep fete serves edges (atom->outcome)
for e in FETE['edges']:
    if e['rel']=='serves' and e['to'].startswith('R'):
        edges.append({'from':e['from'],'to':e['to'],'rel':'serves'})
# realizes edges (atom -> unspun target); create proposed nodes for NEW objects
realizes=0; proposed=set()
for r in ledger:
    for t in r['unspun_targets']:
        if t not in nid:
            nodes.append({'id':t,'kind':'proposed_entity'}); nid.add(t); proposed.add(t)
        edges.append({'from':r['atom'],'to':t,'rel':'realizes','disposition':r['disposition']})
        realizes+=1
nodes.sort(key=lambda n:(n['kind'],n.get('context') or '',n['id']))
edges.sort(key=lambda e:(e['from'],e['rel'],e['to']))
ug={'meta':{'note':'Unified projection: Unspun KG + all 78 Fête atoms + outcomes, joined on atom_code.',
    'node_count':len(nodes),'edge_count':len(edges),'atoms_kept':len(atoms),
    'realizes_edges':realizes,'proposed_entities':sorted(proposed)},
    'nodes':nodes,'edges':edges}
json.dump(ug, open(os.path.join(BASE,'unified-graph.json'),'w'), indent=2, sort_keys=True)

print(f"atoms mapped={len(ledger)}/78  dispositions={dict(dispc)}")
print(f"governance_bound={sorted(GOV)}")
print(f"unified: nodes={len(nodes)} edges={len(edges)} realizes={realizes} proposed={sorted(proposed)}")
unresolved=[t for r in ledger for t in r['unspun_targets'] if t in proposed]
print("proposed (new) targets:", sorted(set(unresolved)))

# ---- Atomics KG: atoms + outcomes + where they map (focused subgraph) ------
try: VER=json.load(open(os.path.join(BASE,'..','graph','kg.json')))['meta']['version']
except Exception: VER='2.1'
ARCS=[('A','Discovery & Trust'),('B','Vision & Commit'),('C','Build'),('D','Day-Of'),('E','Afterglow & Loop')]
QCLASS={'AUTO':'auto','AUG-HITL':'aug','HUMAN-AI':'hai','HUMAN':'hum'}
an, ae = [], []
for r in ledger:
    an.append({'id':r['atom'],'kind':'atom','arc':r['arc'],'quadrant':r['quadrant'],
               'disposition':r['disposition'],'name':r['name']})
    ae.append({'from':r['atom'],'to':f"Q:{r['quadrant']}",'rel':'in_quadrant'})
    for s in r['serves']: ae.append({'from':r['atom'],'to':f'R{s}','rel':'serves'})
    for i,t in enumerate(r['unspun_targets']):
        ae.append({'from':r['atom'],'to':t,'rel':'realizes','role':'primary' if i==0 else 'supporting'})
tset=sorted({t for r in ledger for t in r['unspun_targets']})
oset=sorted({f'R{s}' for r in ledger for s in r['serves']}, key=lambda x:int(x[1:]))
an+=[{'id':t,'kind':'unspun_target'} for t in tset]+[{'id':o,'kind':'outcome'} for o in oset]
an+=[{'id':f'Q:{q}','kind':'quadrant'} for q in QCLASS]
json.dump({'meta':{'tracks_model':VER,'atoms':len(ledger),'targets':len(tset),
    'note':'Atoms -> where they map in the merged model (realizes) + served outcomes (serves).'},
    'nodes':an,'edges':ae}, open(os.path.join(BASE,'atomics-kg.json'),'w'), indent=2, sort_keys=True)

ML=[f'# Atomics KG · tracks v{VER} — the 78 atoms and where they map','',
 '> Machine form: [`atomics-kg.json`](./atomics-kg.json). Full join with the noun-graph: '
 '[`unified-graph.json`](./unified-graph.json). The 78-atom map: [`merge-ledger.yaml`](./merge-ledger.yaml).',
 '> Each atom `--realizes-->` its **primary** Unspun target (diagram) and `--serves-->` its outcome(s).',
 '> Colour = automation quadrant.','']
for code,label in ARCS:
    rows=[r for r in ledger if r['arc']==code]
    ML+= [f'## Arc {code} — {label} ({len(rows)} atoms)','','```mermaid','flowchart LR']
    for r in rows:
        prim=r['unspun_targets'][0]
        ML.append(f"  {r['atom']}[{r['atom']}]:::{QCLASS[r['quadrant']]} -->|realizes| {prim}([{prim}])")
    for cls in ['auto','aug','hai','hum']:
        col={'auto':'#dff0d8','aug':'#fcf8e3','hai':'#d9edf7','hum':'#f2dede'}[cls]
        ML.append(f"  classDef {cls} fill:{col},stroke:#999")
    ML+=['```','',
     '| Atom | Name | Q | Disp | Realizes (Unspun) | Serves |','|---|---|---|---|---|---|']
    for r in rows:
        ML.append(f"| {r['atom']} | {r['name'][:34]} | {r['quadrant']} | {r['disposition']} | "
            f"{', '.join(r['unspun_targets'])} | {', '.join('R'+str(s) for s in r['serves']) or '—'} |")
    ML.append('')
open(os.path.join(BASE,'atomics-kg.md'),'w').write('\n'.join(ML)+'\n')
print(f"atomics-kg: nodes={len(an)} edges={len(ae)} targets={len(tset)} outcomes={len(oset)}")
