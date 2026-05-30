#!/usr/bin/env python3
"""Build the Fête graph (fete-graph.json) from the atom-decomposition source.

The three Fête artifacts (Atom Decomposition, Process Atlas, Deck) are three *views*
of one atom graph. This parses the decomposition (the most structured view) into nodes
+ edges so the Fête model can be aligned against the Unspun KG (docs/graph/kg.json)
during reconciliation. Deterministic projection — regenerate, don't hand-edit.

Usage:  python3 docs/reconciliation/build_fete_graph.py
"""
import re, json, os
BASE = os.path.dirname(os.path.abspath(__file__))
SRC  = os.path.join(BASE, 'sources', 'fete-atom-decomposition.md')

# Backbone constants (from the Process Atlas spine) -------------------------
ARC_OF_PHASE = {**{f'P0{i}':'A' for i in (1,2,3)},
                **{f'P0{i}':'B' for i in (4,5,6,7,8)},
                'P09':'C','P10':'C','P11':'C','P12':'D','P13':'D','P14':'E','P15':'E'}
ARC_LABEL = {'A':'Discovery & Trust','B':'Vision & Commit','C':'Build',
             'D':'Day-Of','E':'Afterglow & Loop'}
WS = {1:('Lead intake & qualification','agent'),2:('Design ideation & moodboarding','agent'),
      3:('Vendor matching','agent'),4:('Vendor negotiation & contracting','agent'),
      5:('Logistics & run-of-show','agent'),6:('Post-event delivery','agent'),
      7:('Taste arbitration','human'),8:('On-site execution','human'),
      9:('Relationship custody','human')}
SKILL = {'TST':'taste','LOG':'logistics','NEG':'negotiation','CRF':'craft',
         'CAR':'care/relationship','ANL':'analysis/inference','COM':'communication/copy','OPS':'operations'}
OUTCOME = {1:'present at my own party',2:'recognized, not interviewed',
  3:'disproportionate creative return',4:'identity reflected, not category',
  5:'discovery / status / novelty',6:'discretion / private budget',7:'day-of cognitive offload',
  8:'rhythm felt, mechanics invisible',9:'effortless child choreography',10:'invisible dual-tier magic',
  11:'in-room intergenerational proof',12:'velocity beat the network',13:'print-grade photography',
  14:'she becomes the distribution channel',15:'staged for, not managed'}

nodes, edges = [], []
def add_node(nid, kind, **kw): nodes.append({'id':nid,'kind':kind,**kw})

# reference nodes
for a,l in ARC_LABEL.items(): add_node(f'Arc:{a}','arc',label=l)
for n,(l,t) in WS.items(): add_node(f'WS{n}','workstream',label=l,wstype=t)
for c,l in SKILL.items(): add_node(f'SKILL:{c}','skill',label=l)
for q in ['AUTO','AUG-HITL','HUMAN-AI','HUMAN']: add_node(f'Q:{q}','quadrant')
for r,l in OUTCOME.items(): add_node(f'R{r}','outcome',label=l)
seen_phase=set()

text=open(SRC).read()
# split into atom blocks
blocks=re.split(r'\n### (T\d+) — ', text)
# blocks[0] is preamble; then alternating id, body
atoms=0
for i in range(1,len(blocks),2):
    tid=blocks[i]; body=blocks[i+1]
    name=body.splitlines()[0].strip()
    m=re.search(r'\*\*WS(\d+)\s*·\s*(P\d+)\s*·\s*([\w/]+)\s*·\s*([A-Z][A-Z-]*)\*\*', body)
    if not m:  # safety
        continue
    ws,phase,skill,quad=int(m.group(1)),m.group(2),m.group(3),m.group(4)
    arc=ARC_OF_PHASE.get(phase)
    serves_text=(re.search(r'\*\*Serves:\*\*\s*(.*)', body) or re.search(r'(^)','')).group(1) if re.search(r'\*\*Serves:\*\*', body) else ''
    serves=sorted(set(int(x) for x in re.findall(r'R(\d+)', serves_text)))
    structural='structural' in serves_text.lower()
    goals=[]
    for kw,gid in [('brand','GOAL:brand'),('safety','GOAL:safety'),('membrane','GOAL:membrane'),
                   ('referral','ASSET:referral'),('vendor network','ASSET:vendor_network'),
                   ('dossier','ASSET:customer_dossier'),('playbook','ASSET:playbook')]:
        if kw in serves_text.lower(): goals.append(gid)
    adj_line=re.search(r'\*\*Adjacent atoms:\*\*\s*(.*)', body)
    adj=sorted(set(re.findall(r'T\d+', adj_line.group(1)))) if adj_line else []
    sub=re.search(r'\*\*Sub-components:\*\*(.*?)\*\*Inputs:', body, re.S)
    subnames=re.findall(r'\d+\.\s+\*\*(.*?)\*\*', sub.group(1)) if sub else []
    add_node(tid,'atom',name=name,arc=arc,phase=phase,ws=ws,skill=skill,quadrant=quad,
             serves=serves,structural=structural,goals=goals,subcomponents=len(subnames),
             subcomponent_names=subnames)
    if phase not in seen_phase:
        add_node(phase,'phase',arc=arc); seen_phase.add(phase)
        edges.append({'from':phase,'to':f'Arc:{arc}','rel':'in_arc'})
    for s in skill.split('/'):
        if not any(n['id']==f'SKILL:{s}' for n in nodes):
            add_node(f'SKILL:{s}','skill',label=SKILL.get(s,s))
        edges.append({'from':tid,'to':f'SKILL:{s}','rel':'has_skill'})
    for g in goals:
        if not any(n['id']==g for n in nodes):
            add_node(g,'goal')
        edges.append({'from':tid,'to':g,'rel':'serves'})
    edges += [
      {'from':tid,'to':phase,'rel':'in_phase'},
      {'from':tid,'to':f'WS{ws}','rel':'in_ws'},
      {'from':tid,'to':f'Q:{quad}','rel':'in_quadrant'}]
    edges += [{'from':tid,'to':f'R{r}','rel':'serves'} for r in serves]
    edges += [{'from':tid,'to':a,'rel':'adjacent'} for a in adj]
    atoms+=1

nodes.sort(key=lambda n:(n['kind'],n['id']))
edges.sort(key=lambda e:(e['from'],e['rel'],e['to']))
from collections import Counter
qc=Counter(n['quadrant'] for n in nodes if n['kind']=='atom')
kg={'meta':{'generated_from':'sources/fete-atom-decomposition.md',
            'atoms':atoms,'node_count':len(nodes),'edge_count':len(edges),
            'quadrant_counts':dict(qc)},
    'nodes':nodes,'edges':edges}
json.dump(kg, open(os.path.join(BASE,'fete-graph.json'),'w'), indent=2, sort_keys=True)
print(f"atoms={atoms} nodes={len(nodes)} edges={len(edges)}")
print("quadrants:", dict(qc))
print("atoms missing serves+not structural:",
      [n['id'] for n in nodes if n['kind']=='atom' and not n['serves'] and not n['structural']] or "none")
