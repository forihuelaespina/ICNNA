# `claude/` — Portable project context for ICNNA

This folder is the **canonical store** for all portable project context
associated with Claude Code sessions on the ICNNA project. Per global
CLAUDE.md §8, project-local context is the source of truth; device-local
auto-memory (under `~/.claude/projects/.../memory/`) is a convenience
mirror that does *not* sync across FOE's devices.

## Layout

```
claude/
  README.md              # this file
  .gitignore             # excludes TeX build artefacts

  memory/                # PORTABLE PROJECT MEMORY (canonical)
    MEMORY.md            # index
    user_*.md
    project_*.md
    feedback_*.md
    reference_*.md

  minutes/               # SESSION MINUTES (.tex + .pdf)
    Phase1_minute.*
    Phase2a_minute.*
    Phase2b_minute.*
    Phase2c_minute.*
    Phase2d_minute.*

  prompts/               # SESSION INPUT PROMPTS
    Phase1_context_prompt.txt
    Phase2a_context_prompt.txt
    Phase2b_context_prompt.txt
    Phase2c_context_prompt.txt
    Phase3_context_prompt.txt    # draft; FOE-prepared prompt takes precedence
    legacy/                      # early exploratory prompts (historical)

  state/                 # INTERIM PER-STEP STATE NOTES (primary-source records)
    Phase2d_E1_state.md
    Phase2d_E2_state.md
    Phase2d_E3_state.md
    Phase2d_E4_state.md
    Phase2d_F_state.md

  media/                 # IMAGES / BIBLIOGRAPHY ASSETS (future use)
```

## Conventions

- **`memory/` is canonical.** New memory entries are written here first
  and mirrored to device-local auto-memory as a convenience cache.
  If the two ever conflict, `memory/` wins.
- **`state/` is never overwritten.** Interim per-step state notes are
  retained as primary-source records of the reasoning progression, even
  after the consolidated minute is produced. This honours the
  "never overwrite" principle (global CLAUDE.md §7.3, project memory).
- **Citations to minutes** use stable human-readable titles plus section
  anchors (e.g. *"see Phase 2d minute, §E.1"*) rather than file paths
  or permalinks. This survives folder reorganisations and repo
  relocations. Permalinks are permitted as supplementary, not primary.
- **Minute PDFs are committed** alongside `.tex` sources so that readers
  without a TeX installation can still access the record (consistent
  with full-disclosure, global CLAUDE.md §9).
- **Flat-within-category.** No per-phase subfolders (e.g.
  `minutes/Phase1/`); file names encode the phase. Revisit only when
  any subfolder exceeds ~20 items.

## Lifecycle

| Subfolder    | Grows with           | Pruning policy                       |
|--------------|----------------------|--------------------------------------|
| `memory/`    | New durable facts    | Update/remove stale entries in place |
| `minutes/`   | One entry per phase  | Never pruned                         |
| `prompts/`   | One per session start| Never pruned                         |
| `state/`     | Interim session work | Never pruned; folded into minutes    |
| `media/`     | Figures, `.bib` files| Case-by-case                         |

## See also

- Global `CLAUDE.md` §8 (Context and Memory Portability)
- Global `CLAUDE.md` §9 (Transparency and Disclosure)
- Project `CLAUDE.md`
- `minutes/Phase2d_minute.pdf` §G (the reorganisation decision record)
