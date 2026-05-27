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
- `flake.nix` host assembly flows through `mkHost`, which takes `hostKey`, `hostname`, and `system`.
- The only machine entrypoints are `nixosConfigurations.Yuri-Lemonade` and `nixosConfigurations.Yuri-NixOS-QEMU-AARCH64`.
- Home Manager is embedded through `home-manager.users.yuri` inside those NixOS configs; there is no standalone Home Manager flake output.
- flake-parts is still used for `mkFlake`, `easyOverlay`, and `pkgs-by-name`, but not for the `flakeModules.modules` helper because its two-level class model does not fit this repo's nested namespaces cleanly.

## Module Boundaries
- `hosts/*.nix`: assemble whole machines and hold hardware / host-specific settings.
- `profiles/*.nix`: shared NixOS profiles such as `base` and `desktop`.
- `features/*.nix`: reusable NixOS feature modules such as `docker`, `niri`, `stylix`, and `network`.
- `users/yuri/*.nix`: NixOS-side user profile modules for the `yuri` account.
- `users/yuri/home/*.nix`: Home Manager modules imported by the `yuri` user profiles.

## Module Namespacing Is Wiring
- Use real nested namespaces under `flake.modules`.
- NixOS feature modules export `flake.modules.features.<name>`.
- Shared profiles export `flake.modules.profiles.<name>`.
- Hosts export shorthand keys under `flake.modules.hosts.<hostKey>`; keep these separate from `networking.hostName`.
- Current host key ↔ hostname pairs include `lemonade` ↔ `Yuri-Lemonade`, `qemu-aarch64` ↔ `Yuri-NixOS-QEMU-AARCH64`, and `sherbet` ↔ `Yuri-Sherbet`.
- `flake.modules.users` is generic; do not hard-code usernames in lib option declarations.
- User-specific names belong only in `users/<username>/...` files and call sites that intentionally choose a user.
- User NixOS profiles export `flake.modules.users.<username>.profiles.<profile>`.
- Home Manager user modules export `flake.modules.users.<username>.home.<module>`.
- Host-specific Kanshi layouts export `flake.modules.users.<username>.home.kanshiLayouts.<layoutName>`.
- New `flake.modules` namespace option declarations belong in `lib/moduleNamespaces.nix` and should use raw values so module functions are not called during option merging.
- Do not reintroduce prefix-based names like `host-*`, `profile-*`, `user-yuri-*`, or `yuri-*`.

## Namespace Declaration Notes
- Declare new `flake.modules` namespace options in `lib/moduleNamespaces.nix`.
- Keep `lib/lib.nix` limited to the existing generic `flake.lib` option; namespace options and user-selection helpers live in `lib/moduleNamespaces.nix`.
- Use raw option values there so module functions are preserved during option merging.
- For host modules, prefer `self.lib.getHostUsers self.modules.users [ ... ]` so the host declares which users belong to it once, then bind them by name, for example:

  ```nix
  let
    users = self.lib.getHostUsers self.modules.users [ "yuri" ];
    inherit (users) yuri;
  in {
    imports = ...
      ++ (with yuri.profiles; [ base desktop ])
      ++ (with yuri.kanshiLayouts; [ lemonade ]);
  }
  ```

- Multi-user host example:

  ```nix
  let
    users = self.lib.getHostUsers self.modules.users [ "yuri" "alice" ];
    inherit (users) yuri alice;
  in {
    imports = ...
      ++ (with yuri.profiles; [ base ])
      ++ (with alice.profiles; [ base ]);
  }
  ```

- `self.lib.getUsers self.modules.users` still exists as the lower-level helper for generic namespace selection outside the host-specific pattern.

- For host-level extra Home Manager modules, extend `imports` with wrapper modules, for example:

  ```nix
  imports = ... ++ (with yuri.homeModules; [ ai-tools devtools ]);
  ```

- This host pattern avoids writing `home-manager.users.<name>` directly in host modules.
- User profile modules may still define `username` once and set `home-manager.users.${username}` internally.
- Kanshi layout selection remains explicit through `user.kanshiLayouts`; do not derive it from `config.networking.hostName`.
- `lib/moduleNamespace.nix` was removed.
- `lib/withPrefix.nix` remains removed as part of the prefix-removal refactor.

## Local Packages
- Repo-local packages live in `packages/<name>/package.nix` and are consumed inside modules as `pkgs.local.<name>` because the overlay sets `local = config.packages`.
- Desktop styling/fonts depend on local packages: `features/stylix.nix` and `features/fonts.nix` are using `pkgs.local.monaspace`.
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
