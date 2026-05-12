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

    import-tree = {
      url = "github:vic/import-tree";
    };

    uniclip = {
      url = "github:yurinek0/uniclip-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pkgs-by-name-for-flake-parts = {
      url = "github:drupol/pkgs-by-name-for-flake-parts";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    infuse = {
      url = "git+https://codeberg.org/amjoseph/infuse.nix";
      flake = false;
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    # binaryninja = {
    #   url = "github:jchv/nix-binary-ninja";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
    };

    nix-yazi-plugins = {
      url = "github:lordkekz/nix-yazi-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-librepods-bin = {
      url = "github:YuriNek0/nix-librepods-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bloodhound-cli = {
      url = "github:yurinek0/nix-bloodhound-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    msgraph-health-sentinel = {
      url = "github:YuriNek0/msgraph-health-sentinel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anthropic-readings = {
      url = "github:YuriNek0/Anthropic-Readlist-Tracker";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    onedrive-vercel-index = {
      url = "github:spencerwooo/onedrive-vercel-index";
      flake = false;
    };

    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oac-flake = {
      url = "github:YuriNek0/oac-flake";
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
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          {
            config,
            system,
            pkgs,
            inputs',
            ...
          }:
          {
            pkgsDirectory = ./packages;
            pkgsNameSeparator = "-";
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                # Add overlays here.
                (import ./overlays/common-inputs.nix {
                  inherit inputs' config;
                })
                (import ./overlays/openldap-workarounds.nix {
                  inherit pkgs;
                })

                # Niri-Flake's overlay.
                inputs.niri.overlays.niri

                # Plymouth theme
                inputs.mac-style-plymouth.overlays.default

                # CachyOS Kernel
                inputs.nix-cachyos-kernel.overlays.pinned

                # Binary Ninja
                # inputs.binaryninja.overlays.default
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
          inputs.pkgs-by-name-for-flake-parts.flakeModule
          (import-tree ./lib)
          (import-tree ./features)
          (import-tree ./profiles)
          (import-tree ./hosts)
          (import-tree ./users)

          # Make hosts here.
          (mkHost "Yuri-NixOS-QEMU-AARCH64" "aarch64-linux")
          (mkHost "Yuri-Sherbet" "aarch64-linux")
          (mkHost "Yuri-Lemonade" "x86_64-linux")
        ];
      }
    );
}
