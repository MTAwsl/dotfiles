<!-- Context: project-intelligence/decisions | Priority: high | Version: 1.9 | Updated: 2026-05-18 -->

# Decisions Log

**Purpose**: Record high-impact architecture decisions and why they were made.  
**Last Updated**: 2026-05-18

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
| 2026-05-18 | Replace prefix-based module names with real nested namespaces | Decided | Keeps readable scope boundaries without overloaded prefixes or string-key namespace paths |
| 2026-05-18 | Add `getHostUsers` host user selection over generic `getUsers` | Decided | Lets hosts support one or many users while declaring usernames once and keeping generic selection available outside hosts |

## Decision Notes

### D1: Dendritic module composition
- **Context**: Repository has multiple module layers (hosts/profiles/features/users/home).
- **Decision**: Export modules through real nested `flake.modules` namespaces such as `features.niri`, `profiles.desktop`, `hosts.lemonade`, `users.yuri.profiles.base`, and `users.yuri.home.firefox`.
- **Impact**: Clear import graph, lower accidental coupling, and no overloaded `host-`/`profile-`/`user-*` prefixes.
- **Trade-off**: The repo declares its own nested namespace options rather than using `flake-parts` `flakeModules.modules`, whose two-level class model does not fit this structure cleanly.

### D1a: Raw namespace option declarations
- **Context**: Nested `flake.modules` namespaces must preserve module functions during option merging.
- **Decision**: Declare the relevant namespace options in `lib/moduleNamespaces.nix` using raw values, and keep `lib/lib.nix` limited to the existing generic `flake.lib` option.
- **Impact**: Import call sites can consume grouped attrsets such as `self.modules.features`, while host user selections go through `self.lib.getHostUsers self.modules.users [ ... ]` without hard-coded usernames in lib option declarations.
- **Trade-off**: New namespaces need explicit option declarations in `lib/`.

### D1b: `getHostUsers` helper and explicit host identity
- **Context**: User and host module references need stable namespace keys without coupling lib declarations to a specific user or tying host-specific layouts to machine hostnames.
- **Decision**: Keep `flake.modules.users` generic in `lib/moduleNamespaces.nix`; hosts bind `users = self.lib.getHostUsers self.modules.users [ "yuri" ]; inherit (users) yuri;` or multi-user lists such as `[ "yuri" "alice" ]`, then import from each user's `profiles`, `homeModules`, and `kanshiLayouts`. Host modules use shorthand keys (`lemonade`, `qemu-aarch64`, `sherbet`) while `mkHost` receives the separate `hostname` value.
- **Impact**: User-specific naming stays in `users/<username>/...` and explicit calls; host modules declare usernames once, support multi-user composition, and avoid direct `home-manager.users.<name>`, while user profile modules may define `username` once and set `home-manager.users.${username}` internally. `getUsers` remains available for lower-level generic namespace selection.
- **Validation**: `nix flake show` plus hostname evals for `Yuri-Lemonade` and `Yuri-NixOS-QEMU-AARCH64` passed.

### D2: Embedded Home Manager strategy
- **Context**: Need host-specific HM behavior without split build flows.
- **Decision**: Keep Home Manager embedded in NixOS composition through user profile modules; hosts import user wrappers rather than writing `home-manager.users.<name>` directly.
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
- `lib/moduleNamespaces.nix` - raw nested namespace option declarations and user selection helpers
- `lib/lib.nix` - generic `flake.lib` option boundary
- `hosts/qemu-aarch64.nix` - forced niri package override on aarch64 host
- `features/home-manager.nix` - Home Manager module integration approach

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
