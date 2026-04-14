# ICNNA Roadmap — v1.4.1-beta → v2.0.0

This roadmap defines the planned evolution of ICNNA from the current
v1.4.1-beta to the v2.0.0 endpoint. It is the public-facing companion of
the Phase 3 minute (`claude/minutes/Phase3_minute.pdf`), which records the
rationale in full.

**Scope.** Bounded modernisation of ICNNA in MATLAB, running in parallel
with the clean-sheet successor project Cantor (C++23). ICNNA is not
scheduled to die; v2.0.0 marks the end of this *modernisation plan*, not
the end of ICNNA's journey.

**Size.** ≈28 sub-releases across four arcs, ≈60–89 work sessions at
research pace over ≈2–3 years.

**Conventions.** Sub-releases are scoped to 1–3 sessions each and each
leaves the codebase usable (principle P3). Modernised classes ship
with tests (P2). Legacy classes survive deprecated alongside modern
counterparts (soft cut, Rule 1). Bridging goes through `+icnna.compat/`
(Rule 5).

---

## Arcs at a glance

| Arc | Versions | Sessions | Theme |
|-----|----------|---------:|-------|
| A. Readiness | v1.4.2, v1.4.3.1–.3 | 6–8 | Code infrastructure + disclosure + conventions + docs scaffolding |
| B. Spine + experimental design | v1.4.4 → v1.4.8 | 12–17 | Core-class modernisation + `experiment` generalisation |
| C. Peripheral + behaviour | v1.4.9 → v1.7.0 | 27–39 | rawData, spatial, registration, QC, analysis, signal processing, synthetic, BIDS |
| D. Endpoint | v1.8.0 → v2.0.0 | 15–25 | `oo/` removal, handover, unified GUI, User Guide polish |

## Cross-cutting threads

1. **User Guide (LaTeX migration)** — skeleton at v1.4.3.3; chapter landings at v1.4.8, v1.5.5, v1.6.4; polish at v2.0.0.
2. **UML refresh** — `m2uml` for class diagrams, PlantUML for hand-authored. Refresh snapshots at v1.4.3.3, v1.4.8, v1.5.5, v2.0.0. ArgoUML retired.
3. **Compat ledger drain** — every release; explicit sweeps at v1.4.8 and v1.8.0; final deletion at v2.0.0.
4. **`.mat` load-compat adapters** — every legacy class modernised in Arc B ships `+icnna.compat.load<ClassName>.m`; retained past `oo/` removal; deleted at v2.0.0.
5. **Performance benchmark harness** — baseline at v1.4.7b; re-run each Arc B release; human-read; pass-by-value ceiling acknowledged as intended.
6. **Examples gallery / cookbook** — grows organically from v1.4.2 seed.
7. **Bug-tracking discipline** — GitHub Issues with labels from v1.4.3.2; durable known limitations mirrored into User Guide appendix.
8. **Fixture provenance** — source, license, IP owner declared whenever a new test fixture lands; feeds `doc/ip_ledger.tex`.

---

## Version-by-version summary

Per entry: **goals / tasks highlights / session estimate / primary risk**. Full enumeration in `claude/minutes/Phase3_minute.pdf`.

### Arc A — Readiness

- **v1.4.2 — "Modernisation Mode Begins"** *(1–2 sessions)*
  Test infrastructure (`matlab.unittest`); `+icnna.compat.toModernTimeline` + γ-site migration; GUI deprecation; R2021a enforcement in `icnna_startup.m`; one CLI worked example. *Risk:* concentrated breakage.

- **v1.4.3.1 — Disclosure artefacts** *(2 sessions)*
  `CHANGELOG.md` seeded from `doc/ICNNA-Version.log`; `doc/ip_ledger.tex` (collaborative); `CITATION.cff` using DOI `10.1117/1.NPh.5.1.011011`; retire standalone `ICNNA_Limitations.doc`. *Risk:* IP ledger blocked on consultation.

- **v1.4.3.2 — Conventions & tooling** *(2 sessions)*
  Deprecation-warning convention; `+icnna.compat` Doxygen header template; MATLAB-version support statement; `doc/conventions/errorIds.tex`; `doc/conventions/toolboxDeps.tex` (Statistics accepted; Signal Processing avoided where feasible); hybrid CI via GitHub Actions; bug-tracking discipline + `CONTRIBUTING.md`; commit `ROADMAP.md`. *Risk:* CI first-green friction.

- **v1.4.3.3 — Documentation scaffolding** *(1–2 sessions)*
  Retire ArgoUML to `doc/UML/historical/`; adopt PlantUML; first `m2uml` snapshot of dual state; User Guide LaTeX skeleton with chapter stubs including Known Limitations and Migration appendices. *Risk:* LaTeX migration scope.

### Arc B — Data-model spine + experimental-design generalisation

- **v1.4.4 — `signal` + `structuredData` + `neuroimage` + `nirs_neuroimage`** *(3–4 sessions)*
  Lowest spine layer; flat-architecture redesign (P5); `.mat` load-compat adapters per class. *Risk:* analysis-pipeline coupling.

- **v1.4.5 — `dataSource` + `dataSourceDefinition`; retire `@rawData_Snirf`** *(2–3 sessions)*
  Mid-spine; resolves D.16. *Risk:* pipelines assuming old `dataSource` shape.

- **v1.4.6 — `session` + `sessionDefinition`** *(2 sessions)*
  Flat-architecture session (holds `dataSource` by ID). *Risk:* resist folding experimental-design generalisation here.

- **v1.4.7a — Experimental-design & experiment-container memo** *(1–2 sessions; design only)*
  Memo with UML + scenario mapping. **Requires FOE input**: Cantor-era design notes. *Risk:* gated on material.

- **v1.4.7b — `experiment` redesign implementation + benchmark baseline** *(3–4 sessions)*
  Modern `experiment`; full design-scenario tests; `tests/performance/` baseline. *Risk:* largest single redesign; may split.

- **v1.4.8 — Spine cleanup + UML refresh + User Guide data-model chapter** *(1–2 sessions)*
  Compat drain; caller sweep (D.1 threshold confirmed here); UML refresh; first User Guide chapter lands; benchmark re-run. *Risk:* low.

### Arc C — Peripheral modernisation + behaviour

- **v1.4.9 — `rawData` base audit & close** *(1 session)*

- **v1.5.0 — rawData subtype family** *(3–4 sessions, may split)*
  `rawData_ETG4000`, `_NIRScout`, `_Shimadzu`, `_UCLWireless`, `_LSL`, `_BioHarnessECG`.

- **v1.5.1 — Spatial/ROI layer** *(3 sessions)*
  `channelLocationMap`, `cluster`, `imagePartition`, `roi`, grids.

- **v1.5.2 — Registration I: standards mapping** *(2–3 sessions)*
  `+icnna.op.registration.*` for 10/20 / 10/10 / 10/5 family; mesh, distances, projections.

- **v1.5.3 — Registration II: atlas alignment + research absorption** *(2–3 sessions, may split)*
  **Requires FOE input**: research material on atlas alignment. *Risk:* scope uncertainty.

- **v1.5.4 — QC behaviour (survival tier)** *(2–3 sessions)*
  Concrete criteria for all legacy ICNNA checks: saturation, mirroring, channel integrity, etc.

- **v1.5.5 — `analysis` + `experimentSpace` + `integrityStatus` + `ecg`; UML refresh; User Guide analysis chapter** *(3 sessions)*

- **v1.6.0 — Signal processing I: survival-tier core ops** *(3 sessions)*
  Bandpass/high/low filters (native MATLAB where feasible); detrending; MBLL audit and relocation; DC removal.

- **v1.6.1 — Signal processing II: motion correction beyond TDDR** *(2–3 sessions)*
  Survey then implement top 2–3 methods; unified interface.

- **v1.6.2 — Signal processing III: physiological regression (SPA-like)** *(2–3 sessions)*
  Short-channel regression; SPA; adaptive/ICA approaches.

- **v1.6.3 — Synthetic data generation + reproducibility policy** *(2–3 sessions)*
  HRF + noise generators; physiological contamination; motion-artefact injection; random-seed policy document.

- **v1.6.4 — QC behaviour (enhancement tier) + User Guide QC chapter** *(2 sessions)*
  SCI, CV, additional criteria from thesis literature.

- **v1.7.0 — BIDS compatibility** *(2–3 sessions)*
  BIDS-fNIRS export (survival); round-trip (enhancement); pinned dated spec. *Risk:* R.FM4 spec drift.

### Arc D — Endpoint

- **v1.8.0 — `oo/` removal sweep** *(1–2 sessions)*
  Legacy `oo/` deleted; `+icnna.compat/load*` adapters retained for user archives.

- **v1.8.1 — Handover preparation** *(2 sessions)*
  Feature-parity checklist (D.5); migration guide (D.6); handover announcement draft (D.9) — may stay open.

- **v1.9.0 — Unified GUI design memo** *(1–2 sessions; design only)*
  Single entry point, view-based architecture, MVC/MVP decision.

- **v1.9.1 — GUI I: shell + core editing** *(3–4 sessions)*

- **v1.9.2 — GUI II: analysis + visualisation views** *(3–4 sessions)*

- **v1.9.3 — GUI III: registration + QC + integrity views** *(3 sessions)*
  Registration subsumed into unified GUI (no separate entry point).

- **v2.0.0 — Release** *(3–4 sessions)*
  `+icnna.compat/` deleted; final UML refresh; User Guide LaTeX polish replaces `.docx` lineage; release notes; stable zip.

---

## Deferred-decision slotting

| ID | Version | ID | Version |
|----|---------|----|---------|
| D.1 | v1.4.8 | D.9 | v1.8.1 draft / deferred |
| D.2 | v1.4.3.2 | D.10 | v2.0.0 or handover release |
| D.3 | v1.4.3.2 | D.11 | v1.4.3.1 |
| D.4 | v1.4.8 (tentative) | D.12 | v1.4.2 seed + cross-cutting |
| D.5 | v1.8.1 | D.13 | v1.9.0 |
| D.6 | v1.8.1 | D.14 | v1.7.0 |
| D.7 | v1.4.3.1 | D.15 | v1.4.2 |
| D.8 | v1.4.3.2 | D.16 | v1.4.5 |

---

## Key risks and mitigations

| Risk | Versions | Mitigation |
|------|----------|-----------|
| Stuck-in-the-middle (FM1) | Arc B, esp. v1.4.7 | P3; v1.4.8 catch-up; v1.4.7a/b split |
| Dual-architecture friction (HC2) | Arc A–C | `+icnna.compat`; drains progressively |
| Research interrupts (HC5) | All | Mixed granularity; memo-first; 1–3 session budget |
| Research drift registration | v1.5.2, v1.5.3 | Memo-first; splittable |
| Research drift signal processing | v1.6.1–v1.6.3 | Synthetic data (v1.6.3) as validation floor |
| User `.mat` archive breakage | v1.8.0 | Load-compat adapters retained until v2.0.0 |
| Performance regression | v1.4.7b+ | Benchmark harness; re-run each Arc B release |
| GUI design weight | v1.9.0 | Design-only memo release before implementation |
| BIDS spec drift | v1.7.0 | Pin to dated spec |
| IP ledger consultation | v1.4.3.1 | Placeholder, advance, revisit |

---

## Critical path

`v1.4.2 → v1.4.3.* → Arc B spine (v1.4.4 → v1.4.7b) → v1.4.8 cleanup → v1.8.0 oo/ removal → v2.0.0`

Arc C releases can reorder under research interrupt without violating the critical path. Arc D handover artefacts (v1.8.1) gate on Cantor progress for D.5/D.6 but not for the critical path to v2.0.0.

---

## References

- Full rationale: `claude/minutes/Phase3_minute.pdf`
- Phase 2 closing: `claude/minutes/Phase2d_minute.pdf`
- Design principles P1–P9: `claude/minutes/Phase2c_minute.pdf`
- Historical version log: `doc/ICNNA-Version.log` (migrated to `CHANGELOG.md` at v1.4.3.1)
- ICNNA paper: Orihuela-Espina et al., DOI `10.1117/1.NPh.5.1.011011`
