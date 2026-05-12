# AGENTS.md

## Repository Summary (Project Intelligence Snapshot)
- This repository is a Nix flake for machine/user configuration composition, centered on `flake.nix` as the entrypoint.
- Active machine outputs are `nixosConfigurations.Yuri-Lemonade` and `nixosConfigurations.Yuri-NixOS-QEMU-AARCH64`.
- Architecture is modular and dendritic: hosts assemble profiles/features/users; Home Manager is embedded via NixOS user wiring.
- Project intelligence context lives in `.opencode/context/project-intelligence/` and should be treated as the canonical onboarding map for business + technical intent.
- Key intelligence files: `technical-domain.md`, `business-domain.md`, `business-tech-bridge.md`, `decisions-log.md`, `living-notes.md`, and `navigation.md`.
- Context authoring rules live in `.opencode/context/project-intelligence/context-authoring.md`; follow them when creating or updating project intelligence files.

## Repo Shape
- This repo is a Nix flake assembled from code. The root `README.md` is a human overview; this file remains the agent execution guide.
- `flake.nix` is the real entrypoint. It imports `lib/`, `features/`, `profiles/`, `hosts/`, and `users/` via `import-tree`.
- The only machine entrypoints are `nixosConfigurations.Yuri-Lemonade` and `nixosConfigurations.Yuri-NixOS-QEMU-AARCH64`.
- Home Manager is embedded through `home-manager.users.yuri` inside those NixOS configs; there is no standalone Home Manager flake output.

## Module Boundaries
- `hosts/*.nix`: assemble whole machines and hold hardware / host-specific settings.
- `profiles/*.nix`: shared NixOS profiles such as `base` and `desktop`.
- `features/*.nix`: reusable NixOS feature modules such as `docker`, `niri`, `stylix`, and `network`.
- `users/yuri/*.nix`: NixOS-side user profile modules for the `yuri` account.
- `users/yuri/home/*.nix`: Home Manager modules imported by the `yuri` user profiles.

## Naming Convention Is Wiring
- Hosts export `flake.modules.nixos."host-<hostname>"`.
- Shared profiles export `flake.modules.nixos.profile-<name>`.
- User profiles export `flake.modules.nixos.user-yuri-<name>`.
- Home Manager modules export `flake.modules.homeManager.yuri-<name>`.
- `lib/withPrefix.nix` strips those prefixes so host files can import short names like `base`, `desktop`, and `git`. If you add a module and break this prefix scheme, the import helpers will not see it.

## Local Packages
- Repo-local packages live in `packages/<name>/package.nix` and are consumed inside modules as `pkgs.local.<name>` because the overlay sets `local = config.packages`.
- Desktop styling/fonts depend on local packages: `features/stylix.nix` uses `pkgs.local.monaspace`, and `features/fonts.nix` uses both `pkgs.local.monaspace` and `pkgs.local.windows11-fonts`.
- Flake package outputs are only generated for `aarch64-linux` because `systems = [ "aarch64-linux" ]`, even though `Yuri-Lemonade` is an `x86_64-linux` host. `nix flake show` exposing only `packages.aarch64-linux.*` is expected here.

## Verification
- Start with `nix flake show` to confirm available outputs.
- For a quick host eval, use `nix eval --raw .#nixosConfigurations.Yuri-Lemonade.config.networking.hostName` or `nix eval --raw .#nixosConfigurations.Yuri-NixOS-QEMU-AARCH64.config.networking.hostName`.
- For real host verification, build the affected system directly: `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- For Home Manager changes, verify through the owning NixOS host build; this repo does not expose a separate HM build target.
- For local packages, build the exact flake package attr, e.g. `nix build .#packages.aarch64-linux.monaspace`.
- `nix flake check --no-build` evaluates every host, so it is broader than a focused host/package check.
- During building and verification, avoid accessing files outside this repository when the answer can be derived from tracked Nix files here.
- If generated Nix outputs must be inspected, prefer `/nix/store` before asking for approval to access other external paths.

## Agent Guardrails (Non-Negotiable)
- Never run `nixos-rebuild` commands in this repository.
- Never run `nh` utilities in this repository.
- Never attempt to activate system configuration (no switch/test/boot-style activation flows).
- If a full-system or otherwise sensitive build command is needed, present the exact command and request fresh explicit user approval immediately before execution.

## Context Authoring Guardrails
- Keep project-intelligence files repo-local under `.opencode/context/project-intelligence/` unless the user explicitly asks for a global context target.
- Preserve HTML frontmatter with context, priority, version, and updated date on every context file.
- Keep context files MVI-sized: under 200 lines, quickly scannable, and focused on a single job.
- Every context file must include a `## 📂 Codebase References` section tied to real repository files.
- Update `.opencode/context/project-intelligence/navigation.md` whenever project-intelligence files are added or materially changed.

## Known Quirk
- `hosts/qemu-aarch64.nix` forces `programs.niri.package = lib.mkForce pkgs.niri` because the `niri` flake input only provides `x86_64` builds; do not switch that host back to the overlay package without checking architecture support.
