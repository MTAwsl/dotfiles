<!-- Context: project-intelligence/nav | Priority: high | Version: 1.13 | Updated: 2026-05-18 -->

# Project Intelligence

**Purpose**: Quick entry points for business + technical project context.
**Last Updated**: 2026-05-18

## Quick Reference

- **Update Triggers**: New/renamed intelligence files, priority changes, onboarding flow changes
- **Audience**: Developers and AI agents selecting which context to load first
- **Scope**: Entry-point map, priority guidance, and repository anchors

## Quick Routes

| What You Need | File | Description |
|---|---|---|
| Technical architecture and coding patterns | `technical-domain.md` | Flake stack, real nested `flake.modules` namespaces, `getHostUsers` host user selection, host key/hostname separation, standards, and AI safety guardrails |
| Context authoring workflow | `context-authoring.md` | `/add-context` style rules, frontmatter/MVI expectations, navigation upkeep, and `.tmp/` handling |
| Business context | `business-domain.md` | Repo goals, constraints, and outcomes |
| Business-to-technical mapping | `business-tech-bridge.md` | Requirement-to-module mapping |
| Decision history | `decisions-log.md` | Architectural rationale and temporary overrides |
| Current open issues | `living-notes.md` | Active debt, known issues, open questions |

## Deep Dives

| File | Priority | When to Load |
|---|---|---|
| `technical-domain.md` | critical | Any implementation or refactor in this repo |
| `context-authoring.md` | high | Any project-intelligence or slash-command context update |
| `business-domain.md` | high | Product or intent alignment |
| `business-tech-bridge.md` | high | Feature planning and scoping |
| `decisions-log.md` | high | Architecture change analysis |
| `living-notes.md` | high | Current-state checks |

## 📂 Codebase References

**Project Context Files**:
- `.opencode/context/project-intelligence/technical-domain.md` - technical source of truth
- `.opencode/context/project-intelligence/context-authoring.md` - context creation and maintenance rules
- `.opencode/context/project-intelligence/business-domain.md` - business context
- `.opencode/context/project-intelligence/business-tech-bridge.md` - bridge mapping
- `.opencode/context/project-intelligence/decisions-log.md` - decision history
- `.opencode/context/project-intelligence/living-notes.md` - active issues and notes

**Technical Anchors in Repository**:
- `flake.nix` - central flake wiring and module imports
- `lib/moduleNamespaces.nix` - raw namespace declarations plus `getHostUsers`/`getUsers` user selection
- `lib/lib.nix` - generic `flake.lib` option boundary
- `hosts/lemonade.nix` - host composition example
- `features/niri.nix` - feature module pattern
- `users/yuri/home/firefox.nix` - Home Manager module pattern

## Reference Links

- Project intelligence standard: `.opencode/context/core/standards/project-intelligence.md`
- PI management guide: `.opencode/context/core/standards/project-intelligence-management.md`
