<!-- Context: project-intelligence/decisions | Priority: high | Version: 1.4 | Updated: 2026-04-27 -->

# Decisions Log

**Purpose**: Record high-impact architecture decisions and why they were made.  
**Last Updated**: 2026-04-27

## Quick Reference

- **Update Triggers**: New architecture decisions, temporary workaround lifecycle changes
- **Audience**: Maintainers and agents preparing refactors or broad module edits
- **Scope**: Rationale, trade-offs, and cleanup triggers for major decisions

## Core Concept

This file preserves decision rationale so future edits do not undo intentional architecture boundaries. It is optimized for fast scanning before refactors.

## Key Points

- Document decisions that change structure, security posture, or portability.
- Prefer concise rationale + concrete code references.
- Mark temporary workarounds clearly with removal trigger.
- Require workaround blocks to use `# FIX: <description with issue URL>` in code.
- During optimization/cleaning/refactoring, check each `# FIX:` URL and remove workaround code once upstream is merged.
- Use this before proposing broad module reorganization.

## Minimal Example (How to Log)

```text
Date: YYYY-MM-DD
Decision: what changed
Why: primary rationale
Trade-off: cost accepted
References: file paths and issue links
```

## Active Decisions

| Date | Decision | Status | Rationale |
|---|---|---|---|
| 2026-04-27 | Use flake-parts + import-tree dendritic composition | Decided | Keeps module discovery and boundaries predictable |
| 2026-04-27 | Keep Home Manager embedded in NixOS flake outputs | Decided | Single host build path and tighter host-user cohesion |
| 2026-04-27 | Force `pkgs.niri` on qemu aarch64 host | Temporary | niri flake package availability mismatch across architectures |
| 2026-04-27 | Apply openldap test-disable workaround for lutris/bottles | Temporary | Upstream nixpkgs issue blocks clean build path |

## Decision Notes

### D1: Dendritic module composition
- **Context**: Repository has multiple module layers (hosts/profiles/features/users/home).
- **Decision**: Prefix-scoped module exports + helper-based prefix stripping.
- **Impact**: Clear import graph and lower accidental coupling.
- **Trade-off**: Naming discipline is mandatory.

### D2: Embedded Home Manager strategy
- **Context**: Need host-specific HM behavior without split build flows.
- **Decision**: Use `home-manager.users.yuri` inside NixOS host composition.
- **Impact**: One primary build path per host.
- **Trade-off**: Less separation than standalone HM output.

### D3: Temporary architecture/build workarounds
- **Context**: Upstream package constraints for niri/openldap-related consumers.
- **Decision**: Keep explicit temporary overrides with issue references.
- **Impact**: Maintains functionality now.
- **Trade-off**: Requires periodic cleanup review.

## 📂 Codebase References

**Decision Anchors**:
- `flake.nix` - flake-parts/import-tree composition and overlay workarounds
- `hosts/qemu-aarch64.nix` - forced niri package override on aarch64 host
- `features/home-manager.nix` - Home Manager module integration approach
- `lib/withPrefix.nix` - prefix-based module wiring helper

**Issue Links in Code Comments**:
- `flake.nix` - nixpkgs openldap workaround TODO references
- `hosts/qemu-aarch64.nix` - niri package availability note

## Reference Links

- niri flake tracking: https://github.com/sodiboo/niri-flake
- nixpkgs openldap issue: https://github.com/nixos/nixpkgs/issues/513245

## Related Files

- `technical-domain.md` - current implementation conventions
- `business-tech-bridge.md` - why these decisions map to business needs
- `living-notes.md` - pending cleanup and active follow-ups
