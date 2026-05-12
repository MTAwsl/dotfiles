<!-- Context: project-intelligence/authoring | Priority: high | Version: 1.0 | Updated: 2026-05-12 -->

# Context Authoring

**Purpose**: Canonical rules for creating or updating project intelligence in this repository.  
**Last Updated**: 2026-05-12

## Quick Reference

- **Update Triggers**: New intelligence files, `/add-context` flow changes, frontmatter/MVI standard changes
- **Audience**: Developers and AI agents maintaining `.opencode/context/project-intelligence/`
- **Scope**: Local context storage, review workflow, MVI limits, navigation upkeep, temporary `.tmp/` context handling

## Core Concept

Project intelligence should stay repo-local, compact, and directly tied to code in this repository. Any context-authoring workflow should preserve user patterns with a reviewable wizard flow while enforcing frontmatter, versioning, navigation updates, and codebase references.

## Key Points

- Default project context lives in `.opencode/context/project-intelligence/`; treat global context as optional fallback, not the primary path for this repo.
- Every project-intelligence file must start with HTML frontmatter and include priority, version, and update date metadata.
- Keep files MVI-compliant: under 200 lines, scannable in under 30 seconds, and focused on one job.
- Always include a `## 📂 Codebase References` section and update `navigation.md` whenever files are added or materially changed.
- External or harvested notes may stage in `.tmp/`, but durable patterns belong in project-intelligence files after review.

## Wizard Contract

1. Check `.tmp/` for external context before editing permanent files.
2. Detect existing project intelligence and offer review, additive update, replace, or cancel.
3. Capture six pattern groups: stack, API, component, naming, standards, and security.
4. Preview the generated `technical-domain.md` and `navigation.md` changes before writing.
5. Apply versioning rules: new file `1.0`, content update minor bump, structure change major bump.
6. Validate frontmatter, MVI size, codebase references, and navigation coverage before completion.

## Example Pattern Block

```md
<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.0 | Updated: 2026-05-12 -->

# Technical Domain

## Primary Stack
| Layer | Technology | Notes |
|---|---|---|
| Framework | Next.js | App Router conventions |
```

## 📂 Codebase References

- `.opencode/context/project-intelligence/navigation.md` - index for project context routes and priorities
- `.opencode/context/project-intelligence/technical-domain.md` - canonical technical patterns and agent guardrails
- `AGENTS.md` - runtime instructions that should mirror critical context authoring constraints
- `README.md` - top-level project overview that authored context should stay consistent with

## Reference Links

- `technical-domain.md` - repo-specific implementation and safety rules
- `navigation.md` - required update target whenever context changes
