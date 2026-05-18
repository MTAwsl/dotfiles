<!-- Context: project-intelligence/notes | Priority: high | Version: 1.9 | Updated: 2026-05-18 -->

# Living Notes

**Purpose**: Track active risks, debt, and open follow-ups for this repository.  
**Last Updated**: 2026-05-18

## Quick Reference

- **Update Triggers**: New debt, resolved debt, workaround changes, open-question updates
- **Audience**: Maintainers and agents assessing implementation risk
- **Scope**: Active issues, debt queue, and near-term follow-ups

## Core Concept

This file captures short-lived operational context that should influence current changes but not permanently bloat standards files. Resolved items should move to decision history or be removed once closed.

## Key Points

- Keep entries actionable: owner, impact, and next step.
- Treat temporary workarounds as debt with explicit cleanup trigger.
- Prefer links to code and issue references over long prose.
- Ensure temporary workaround code is annotated with `# FIX: <description with issue URL>`.
- During optimization/cleaning/refactoring, re-check `# FIX:` URLs and remove workaround code if upstream is merged.
- Review before large refactors or dependency updates.

## Minimal Example (Issue Entry)

```text
Issue: temporary package workaround
Impact: increases maintenance burden
Next step: remove after upstream fix lands
Owner: repo maintainer
Reference: exact file path + issue URL
```

## Active Technical Debt

| Item | Impact | Priority | Next Step |
|---|---|---|---|
| Inline overlay workarounds in `flake.nix` | Harder to reason about overlays lifecycle | High | Remove once upstream issue is fixed |
| Very large `users/yuri/home/niri.nix` | Higher review risk and coupling | Medium | Split into focused submodules over time |
| Hardcoded host UID/GID mapping in qemu share helper | Portability constraints across host setups | Medium | Parameterize or document override path |

## Known Issues

| Issue | Severity | Current Workaround | Status |
|---|---|---|---|
| `niri-flake` arch mismatch for qemu aarch64 path | Medium | Force `pkgs.niri` in qemu host | Open |
| openldap-related failures impacting lutris/bottles env | Medium | Override attrs in `flake.nix` | Open |
| DMS greeter YubiKey compatibility gap | Low | Use `regreet` path currently | Open |

## Open Questions

| Question | Why It Matters | Next Action |
|---|---|---|
| Move overlay logic into dedicated `overlays/` tree now or later? | Aligns implementation with declared standard | Decide after next dependency cleanup cycle |
| Should large HM modules be split immediately or incrementally? | Impacts change safety and review speed | Start with highest-churn modules first |

## What Works Well

- Real nested `flake.modules` namespace wiring keeps imports understandable without old prefixes or string-key namespace paths.
- `getHostUsers` keeps host user selection explicit, supports multi-user hosts, and leaves lower-level `getUsers` available for generic namespace selection while `lib/moduleNamespaces.nix` owns raw namespace declarations and `lib/lib.nix` stays generic.
- Explicit Kanshi layout selection avoids hidden dependence on `networking.hostName`.
- Host/profile/user boundaries are mostly clear and reusable.
- Local package strategy under `packages/` is predictable.

## 📂 Codebase References

**Debt/Issue Anchors**:
- `flake.nix` - temporary openldap workaround and overlay composition
- `lib/moduleNamespaces.nix` - namespace declaration and user selection helper boundary
- `lib/lib.nix` - generic `flake.lib` option boundary
- `hosts/qemu-aarch64.nix` - niri package force for architecture mismatch
- `users/yuri/home/niri.nix` - large high-churn HM module
- `features/qemu-share-fs.nix` - qemu share helper and UID/GID assumptions
- `profiles/desktop.nix` - current greeter selection comments/context

## Reference Links

- NixOS options search: https://search.nixos.org/options
- Home Manager options: https://nix-community.github.io/home-manager/options.xhtml

## Related Files

- `decisions-log.md` - promote stable rationale from these notes
- `technical-domain.md` - canonical standards and patterns
- `business-tech-bridge.md` - impact of technical debt on business goals
