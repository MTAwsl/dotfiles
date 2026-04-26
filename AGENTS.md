# AGENTS.md

## Repo Shape
- This repo is a Nix flake assembled from code, not docs: there is no `README`, CI workflow, task runner, `devShell`, or existing agent-instruction file to lean on.
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

## Known Quirk
- `hosts/qemu-aarch64.nix` forces `programs.niri.package = lib.mkForce pkgs.niri` because the `niri` flake input only provides `x86_64` builds; do not switch that host back to the overlay package without checking architecture support.
