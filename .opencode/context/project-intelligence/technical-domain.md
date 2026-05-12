<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.6 | Updated: 2026-05-12 -->

# Technical Domain

**Purpose**: Canonical technical patterns for this NixOS flake repository.  
**Last Updated**: 2026-05-12

## Quick Reference

- **Update Triggers**: Flake input changes, module boundary changes, naming convention changes
- **Audience**: Developers and AI agents working on this repository
- **Scope**: Flake composition, module patterns, naming, standards, and security

## Core Concept

This repository uses a flake-based, dendritic module architecture where scoped module prefixes define boundaries and import flow. Home Manager is embedded as a flake module, and features/profiles/hosts/users are composed declaratively through flake-parts and import-tree.

## Key Points

- Use Flake + flake-parts as the composition backbone and keep module graph explicit.
- Preserve strict naming/scope prefixes (`host-`, `profile-`, `user-<username>-`, `homeManager.<username>-`).
- Keep functionality isolated: features first, helpers in `lib/`, custom packages in `packages/`.
- Avoid cross-module coupling unless strictly necessary (especially user ↔ host/feature leakage).
- Follow the dendritic pattern guide as the primary structural reference.

## Primary Stack

| Layer | Technology | Notes |
|------|------------|------|
| System Config | NixOS Modules | Declarative machine configuration |
| Composition | Nix Flakes + flake-parts | Flake outputs and module graph |
| Module Discovery | import-tree | Module import ergonomics |
| User Config | Home Manager (flake module) | Embedded under NixOS configs |
| Packaging | `packages/` + overlays | Local package definitions and overrides |

## Pattern: NixOS Feature Module (Minimal)

```nix
{ ... }:
{
  flake.modules.nixos.qemu-host = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ qemu quickemu dnsmasq ];
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
```

## Pattern: Home Manager Module (Minimal)

```nix
{ ... }:
{
  flake.modules.homeManager.yuri-firefox = { pkgs, ... }: {
    programs.firefox.enable = true;
    programs.firefox.package = pkgs.firefox-devedition;
    programs.firefoxpwa.enable = true;
  };
}
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case feature/software naming | `qemu-share-fs.nix` |
| Host Modules | `flake.modules.nixos.host-<hostname>` | `host-Yuri-Lemonade` |
| System Profiles | `flake.modules.nixos.profile-<name>` | `profile-desktop` |
| User Profiles | `flake.modules.nixos.user-<username>-<profile>` | `user-yuri-base` |
| HM Modules | `flake.modules.homeManager.<username>-<module>` | `yuri-firefox` |
| Helpers | descriptive snake_case | `build_exec` (pattern) |

## Code Standards

- Separate functionality into focused feature modules.
- Add system-global features only when truly necessary.
- Put helper functions in `lib/`.
- External flake dependencies belong in `flake.nix`; custom packages belong in `packages/`.
- Place overlays in `overlays/`.
- Keep input-specific overrides in dedicated overlay files (for example `overlays/pwndbg.nix`), not in shared catch-all overlays.
- Avoid cross-referencing dependencies across unrelated module layers unless required.
- Make each Nix file relatively small and modular.
- For temporary upstream workarounds, add `# FIX: <description with issue URL>` immediately above the workaround block.
- During optimization/cleaning/refactoring, verify each `# FIX:` URL; if upstream has merged the fix, remove the workaround code.
- During building and verification, avoid accessing files outside this repository whenever the needed truth can be derived from the tracked Nix files here.
- If generated Nix outputs must be inspected, prefer `/nix/store` before requesting approval to read other external paths.
- AI agents must not run `nixos-rebuild` commands.
- AI agents must not run `nh` utilities.
- AI agents must never activate Nix system configuration.
- For sensitive or full-system build operations, AI agents must show the exact command and request explicit approval immediately before execution.
- Follow: https://github.com/mightyiam/dendritic

## Security Requirements

- Minimize local privilege escalation risk.
- Regularly update flake inputs.
- Require human approval gates for privileged or system-impacting operations.
- Prefer read/eval-oriented checks unless explicitly approved for broader build actions.

## 📂 Codebase References

**Implementation**:
- `flake.nix` - flake inputs, outputs, overlays, and host wiring
- `hosts/lemonade.nix` - host composition and imports
- `hosts/qemu-aarch64.nix` - aarch64 host assembly pattern
- `features/niri.nix` - NixOS feature module structure
- `features/qemuhost.nix` - reusable virtualization feature pattern
- `users/yuri/home/firefox.nix` - Home Manager module naming pattern
- `lib/withPrefix.nix` - prefix helpers for module wiring

**Packages / Build**:
- `packages/monaspace/package.nix` - local package pattern
- `packages/windows11-fonts/package.nix` - custom package organization

## Reference Links

- Dendritic pattern: https://github.com/mightyiam/dendritic
- Nix flakes: https://nixos.wiki/wiki/Flakes
- Home Manager: https://nix-community.github.io/home-manager/
