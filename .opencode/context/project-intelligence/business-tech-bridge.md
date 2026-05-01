<!-- Context: project-intelligence/bridge | Priority: high | Version: 1.2 | Updated: 2026-04-27 -->

# Business ↔ Tech Bridge

**Purpose**: Show how repository goals map to concrete Nix module decisions.  
**Last Updated**: 2026-04-27

## Quick Reference

- **Update Triggers**: New requirements, changed constraints, architecture shifts
- **Audience**: Maintainers and agents planning implementation work
- **Scope**: Business need → module mapping and trade-off framing

## Core Concept

Each business requirement in this repo (reproducibility, security, maintainability, portability) is implemented through explicit module boundaries and flake wiring. This file keeps that mapping explicit so changes remain intentional.

## Key Points

- Business asks for reliability; tech answers with declarative host/profile/user modules.
- Business asks for maintainability; tech answers with strict prefix naming and scoped modules.
- Business asks for security; tech answers with dedicated security features and conservative defaults.
- Business asks for portability; tech answers with multi-host configs and architecture-specific overrides.
- Business asks for lower risk; tech answers with minimal cross-module coupling.

## Core Mapping

| Business Need | Technical Solution | Why This Mapping | Business Value |
|---|---|---|---|
| Rebuild any machine quickly | Flake-based host entries in `hosts/*.nix` | Host config stays declarative and reviewable | Lower recovery time |
| Keep user env consistent | Home Manager modules under `users/yuri/home/*.nix` | User config is modular and reusable | Predictable developer UX |
| Enforce boundaries | Prefix-based module naming + `lib/withPrefix.nix` | Scope is encoded in names and imports | Lower maintenance cost |
| Keep security practical | Feature modules (`features/yubikey.nix`, firewall/auth choices) | Security changes are isolated and auditable | Lower operational risk |

## Minimal Example (Requirement → Module)

```text
Requirement: support QEMU host workflows
Module: features/qemuhost.nix
Host wiring: hosts/lemonade.nix imports qemu-host
Outcome: virtualization tools available without polluting unrelated modules
```

## Trade-off Patterns

| Situation | Chosen Bias | Rationale |
|---|---|---|
| Shared logic placement | Prefer profiles/features over host duplication | Avoid drift while keeping host-specific overrides possible |
| Security feature rollout | Add only when necessary | Minimize global blast radius |
| Cross-layer references | Avoid unless mandatory | Preserve dendritic boundaries |

## 📂 Codebase References

**Mapping Anchors**:
- `flake.nix` - top-level module composition and overlays
- `lib/withPrefix.nix` - naming-prefix based import ergonomics
- `hosts/lemonade.nix` - host-level business intent realization
- `profiles/desktop.nix` - shared desktop experience mapping
- `users/yuri/desktop.nix` - user profile mapping to feature set
- `features/qemuhost.nix` - concrete business-need implementation example

## Reference Links

- Dendritic pattern: https://github.com/mightyiam/dendritic
- NixOS modules: https://nixos.org/manual/nixos/stable/#sec-writing-modules

## Related Files

- `business-domain.md` - goals and constraints
- `technical-domain.md` - implementation conventions
- `decisions-log.md` - rationale for major choices
- `living-notes.md` - active gaps and pending improvements
