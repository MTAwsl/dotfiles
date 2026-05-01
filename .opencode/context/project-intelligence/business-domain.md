<!-- Context: project-intelligence/business | Priority: high | Version: 1.2 | Updated: 2026-04-27 -->

# Business Domain

**Purpose**: Capture why this repository exists and what outcomes it must deliver for its maintainer.  
**Last Updated**: 2026-04-27

## Quick Reference

- **Update Triggers**: Repo purpose changes, user/host target changes, success metric changes
- **Audience**: Maintainers and agents aligning changes to project outcomes
- **Scope**: Business goals, constraints, and success signals

## Core Concept

This repository is the single source of truth for reproducible NixOS + Home Manager environments across multiple hosts. The business value is fast recovery, low configuration drift, and safe iteration on system/user features.

## Key Points

- Reproducibility is the primary value: hosts should be rebuilt from flake state, not manual tweaks.
- Consistency matters: naming and module boundaries reduce maintenance overhead.
- Security is a product requirement: avoid privilege escalation paths and keep dependencies updated.
- Multi-host support is expected (`Yuri-Lemonade` and `Yuri-NixOS-QEMU-AARCH64`).
- Config changes should remain reviewable and traceable in Git.

## Project Identity

| Item | Value |
|---|---|
| Project | Personal NixOS configuration mono-repo |
| Tagline | Declarative, reproducible, host-aware system config |
| Primary Problem | Manual setup is slow, error-prone, and hard to audit |
| Solution | Flake-composed NixOS + Home Manager modules with strict naming/scope |

## Target Users

| Segment | Who | Need |
|---|---|---|
| Primary | Repo owner (`yuri`) | Fast, safe, repeatable system changes |
| Secondary | Future maintainer/agent | Clear architecture and low-friction onboarding |

## Minimal Example (Business Intent → Deliverable)

```text
Need: Secure login and unlock flow
Constraint: Keep system-wide blast radius low
Implementation: Isolate into dedicated feature module
Validation: Host builds still evaluate and boot
Outcome: Security improvement without cross-module regressions
```

## Value Proposition

- Reliable rebuild path for full machine setup.
- Lower cognitive load through deterministic module organization.
- Faster feature delivery by reusing scoped profiles/features.

## Success Signals

| Signal | Good State |
|---|---|
| Drift | Minimal manual post-install changes |
| Recovery Time | New/reinstalled host reaches working state quickly |
| Change Safety | Most edits are isolated to intended module scopes |
| Security Hygiene | Flake inputs refreshed regularly |

## Constraints

- Keep global features minimal unless truly system-wide.
- Avoid cross-referencing dependencies across unrelated module layers.
- Respect architecture-specific quirks (e.g., niri package differences on aarch64).

## 📂 Codebase References

**Core Business Outcomes in Code**:
- `flake.nix` - central reproducibility anchor (inputs/outputs/composition)
- `hosts/lemonade.nix` - main physical host definition
- `hosts/qemu-aarch64.nix` - virtual/aarch64 host definition
- `profiles/base.nix` - shared baseline user/system experience
- `features/yubikey.nix` - security-focused feature boundary example

## Reference Links

- NixOS: https://nixos.org/manual/nixos/stable/
- Nix flakes overview: https://nixos.wiki/wiki/Flakes

## Related Files

- `technical-domain.md` - technical implementation patterns
- `business-tech-bridge.md` - requirement-to-module mapping
- `decisions-log.md` - architectural rationale over time
