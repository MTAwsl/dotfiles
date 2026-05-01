# nix-config

Nix flake repository for composing hosts, features, and user environments.

## Screenshots

*(It won't be necessary, probably, yeah.)*

## Structure

- `hosts/` — complete machine assemblies
- `profiles/` — shared system profiles
- `features/` — reusable system capabilities
- `users/` — user-level NixOS and Home Manager modules
- `packages/` — local package definitions
- `lib/` — composition and naming helpers
- `.opencode/` — Configs and Contexts for AI

## Use of AI

This repo is compatible with [OpenAgentsControl](https://github.com/darrenhinde/OpenAgentsControl) framework.

- `AGENTS.md` is the agent execution guide.
- `.opencode/context/project-intelligence/` is the project knowledge layer that keeps agent output aligned with this repository’s architecture, decisions, and intent.
