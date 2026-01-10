{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    uniclip = {
      url = "github:yurinek0/uniclip-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:vic/import-tree";
    };

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      let
        mkHost = hostname: system: {
          flake.nixosConfigurations."${hostname}" = withSystem system (
            { pkgs, system, ... }:
            inputs.nixpkgs.lib.nixosSystem {
              inherit pkgs system;
              modules = [
                inputs.self.modules.nixos.nix
                inputs.self.modules.nixos."host-${hostname}"
              ];
            }
          );
        };
      in
      {
        systems = [
          "aarch64-linux"
        ];

        perSystem =
          {
            system,
            inputs',
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                # Add overlays here.
                (final: prev: {
                  uniclip = inputs'.uniclip.packages.uniclip;

                  # FIX: Remove this after wl-clipboard released a new update. (Current date: 08/01/2026)
                  wl-clipboard = prev.wl-clipboard.overrideAttrs (old: {
                    version = "25.11.25.0"; # YY.MM.DD.rev
                    src = prev.fetchFromGitHub {
                      owner = "bugaevc";
                      repo = "wl-clipboard";
                      rev = "e8082035dafe0241739d7f7d16f7ecfd2ce06172";
                      hash = "sha256-sR/P+urw3LwAxwjckJP3tFeUfg5Axni+Z+F3mcEqznw=";
                    };
                  });
                })

                # Plymouth theme
                inputs.mac-style-plymouth.overlays.default;
              ];
              config = {
                allowUnfree = true;
              };
            };
          };

        imports = [
          # Import necessary modules.
          ./nix.nix
          inputs.flake-parts.flakeModules.modules
          (import-tree ./lib)
          (import-tree ./features)
          (import-tree ./profiles)
          (import-tree ./hosts)
          (import-tree ./users)

          # Make hosts here.
          (mkHost "qemu-aarch64" "aarch64-linux")
          (mkHost "lemonade" "x86_64-linux")
        ];
      }
    );
}
