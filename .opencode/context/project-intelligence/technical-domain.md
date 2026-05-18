<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.11 | Updated: 2026-05-18 -->

# Technical Domain

**Purpose**: Canonical technical patterns for this NixOS flake repository.  
**Last Updated**: 2026-05-18

## Quick Reference

- **Update Triggers**: Flake input changes, module boundary changes, naming convention changes
- **Audience**: Developers and AI agents working on this repository
- **Scope**: Flake composition, module patterns, naming, standards, and security

## Core Concept

This repository uses a flake-based, dendritic module architecture with real nested namespaces under `flake.modules`. Home Manager is embedded through NixOS host/user wiring, and features/profiles/hosts/users are composed declaratively through flake-parts and import-tree.

## Key Points

- Use Flake + flake-parts as the composition backbone and keep module graph explicit.
- Export modules through real nested `flake.modules` namespaces: `features`, `profiles`, `hosts`, and generic `users.<username>.*`.
- Do not reintroduce old prefix names (`host-*`, `profile-*`, `user-yuri-*`, `yuri-*`) or removed namespace helpers.
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

## Namespace Model

| Module Scope | Namespace |
|---|---|
| NixOS features | `flake.modules.features.<name>` |
| Shared profiles | `flake.modules.profiles.<name>` |
| Hosts | `flake.modules.hosts.<hostKey>`; shorthand key is separate from `networking.hostName` |
| User NixOS profiles | `flake.modules.users.<username>.profiles.<profile>` |
| Home Manager modules | `flake.modules.users.<username>.home.<module>` |
| Host-specific Kanshi layouts | `flake.modules.users.<username>.home.kanshiLayouts.<layoutName>` |

`flake-parts` is still used for `mkFlake`, `easyOverlay`, and `pkgs-by-name`, but not `flakeModules.modules`; its two-level class model does not fit this repo's nested namespaces cleanly. `lib/moduleNamespaces.nix` declares nested namespace options with raw values so module functions are not invoked during option merging, and it owns `getHostUsers` plus lower-level `getUsers`. `lib/lib.nix` remains limited to the existing generic `flake.lib` option. User-specific names belong in `users/<username>/...` files and explicit call sites, not in lib option declarations.

## Host and User Helper Model

- `flake.nix` assembles hosts through `mkHost { hostKey; hostname; system; }`.
- Current host key mappings: `lemonade` → `Yuri-Lemonade`, `qemu-aarch64` → `Yuri-NixOS-QEMU-AARCH64`, and `sherbet` → `Yuri-Sherbet`.
- Host modules should select only their users with `users = self.lib.getHostUsers self.modules.users [ "yuri" ]; inherit (users) yuri;` and import grouped modules directly, e.g. `(with yuri.profiles; [ base desktop ])`, `(with yuri.homeModules; [ ai-tools devtools ])`, and `(with yuri.kanshiLayouts; [ lemonade ])`.
- Multi-user hosts use one username list and keyed bindings: `users = self.lib.getHostUsers self.modules.users [ "yuri" "alice" ]; inherit (users) yuri alice;` then import from each user's `profiles`, `homeModules`, or `kanshiLayouts`.
- `self.lib.getUsers self.modules.users` still exists as the lower-level helper for generic namespace selection outside host-specific composition.
- Host-level extra Home Manager modules should be imported through wrapper modules from `user.homeModules`/`yuri.homeModules`; avoid writing `home-manager.users.<name>` in host modules.
- User profile modules may define `username` once and set `home-manager.users.${username}` internally.
- Kanshi layout selection must be explicit through `user.kanshiLayouts`; do not derive layouts from `config.networking.hostName`.

## Pattern: NixOS Feature Module (Minimal)

```nix
{ ... }:
{
  flake.modules.features.qemu-host = { pkgs, ... }: {
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
  flake.modules.users.yuri.home.firefox = { pkgs, ... }: {
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
| Host Modules | `flake.modules.hosts.<hostKey>` | `flake.modules.hosts.lemonade` |
| NixOS Features | `flake.modules.features.<name>` | `flake.modules.features.niri` |
| System Profiles | `flake.modules.profiles.<name>` | `flake.modules.profiles.desktop` |
| User Profiles | `flake.modules.users.<username>.profiles.<profile>` | `flake.modules.users.yuri.profiles.base` |
| HM Modules | `flake.modules.users.<username>.home.<module>` | `flake.modules.users.yuri.home.firefox` |
| Helpers | namespace selection helpers | `getHostUsers`, `getUsers` |

## Code Standards

- Separate functionality into focused feature modules.
- Add system-global features only when truly necessary.
- Put helper functions in `lib/`.
- External flake dependencies belong in `flake.nix`; custom packages belong in `packages/`.
- Place overlays in `overlays/`.
- Keep input-specific overrides in dedicated overlay files (for example `overlays/pwndbg.nix`), not in shared catch-all overlays.
- In hosts, import grouped user modules through `self.lib.getHostUsers self.modules.users [ ... ]`, declaring usernames once and binding selected users by name.
- Use `self.lib.getUsers self.modules.users` only for generic namespace selection outside host-specific composition.
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
- `hosts/sherbet.nix` - shorthand host key with separate hostname pattern
- `features/niri.nix` - NixOS feature module structure
- `features/qemuhost.nix` - reusable virtualization feature pattern
- `users/yuri/base.nix` - user profile and Home Manager import namespace example
- `users/yuri/home/firefox.nix` - Home Manager module naming pattern
- `lib/moduleNamespaces.nix` - raw nested namespace option declarations and user selection helpers
- `lib/lib.nix` - existing generic `flake.lib` option boundary

**Packages / Build**:
- `packages/monaspace/package.nix` - local package pattern
- `packages/windows11-fonts/package.nix` - custom package organization

## Reference Links

- Dendritic pattern: https://github.com/mightyiam/dendritic
- Nix flakes: https://nixos.wiki/wiki/Flakes
- Home Manager: https://nix-community.github.io/home-manager/
