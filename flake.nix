{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:denful/import-tree/v0.2.0";
    };

    uniclip = {
      url = "github:yurinek0/uniclip-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # FIX: Remove once nixpkgs carries Flameshot v14 with https://github.com/flameshot-org/flameshot/pull/4664.
    flameshot = {
      url = "github:flameshot-org/flameshot"; # Nightly
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
      url = "github:drupol/pkgs-by-name-for-flake-parts/7ba1cd4a9a72c9c6c272018a63f090f2c912a171";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme/2f782f4b68ce1c00cef3fde6970d7b4241bb97d4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
    };

    nix-yazi-plugins = {
      url = "github:yurinek0/nix-yazi-plugins/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bloodhound-cli = {
      url = "github:yurinek0/nix-bloodhound-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-bin = {
      url = "github:YuriNek0/nix-opencode-bin";
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

    argononed = {
      url = "github:yurinek0/argononed";
      flake = false;
    };

    oac-flake = {
      url = "github:YuriNek0/oac-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # binaryninja = {
    #   url = "github:jchv/nix-binary-ninja";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nix-librepods-bin = {
    #   url = "github:YuriNek0/nix-librepods-bin";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # nix-yazi-plugins = {
    #   url = "github:lordkekz/nix-yazi-plugins";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        withSystem,
        ...
      }:
      let
        mkHost = hostKey: hostname: system: {
          flake.nixosConfigurations."${hostname}" = withSystem system (
            {
              system,
              pkgs,
              inputs',
              ...
            }:
            inputs.nixpkgs.lib.nixosSystem {
              inherit pkgs system;
              specialArgs = {
                inherit inputs inputs';
              };
              modules = [
                inputs.self.modules.features.nix
                inputs.self.modules.hosts.${hostKey}
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
            system,
            ...
          }:
          {
            pkgsDirectory = ./packages;
            pkgsNameSeparator = "-";
            _module.args = {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  # Plymouth theme
                  inputs.mac-style-plymouth.overlays.default

                  # Binary Ninja
                  # inputs.binaryninja.overlays.default

                  # Local package overrides.
                  top.config.flake.overlays.default
                ];
                config = {
                  allowUnfree = true;

                  # FIX: Remove this after https://github.com/bitwarden/clients/pull/20448 is merged, and
                  # https://github.com/nixos/nixpkgs/issues/526914 is closed.
                  permittedInsecurePackages = [ "electron-39.8.10" ];
                };
              };
            };

          };

        imports = [
          # Import necessary modules.
          ./nix.nix
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.pkgs-by-name-for-flake-parts.flakeModule
          inputs.home-manager.flakeModules.home-manager
          (import-tree ./lib)
          (import-tree ./features)
          (import-tree ./overlays)
          (import-tree ./profiles)
          (import-tree ./hosts)
          (import-tree ./users)

          # Standalone Home Manager config for CLI workflows
          ./home-manager.nix

          # Make hosts here.
          (mkHost "qemu-aarch64" "Yuri-NixOS-QEMU-AARCH64" "aarch64-linux")
          (mkHost "sherbet" "Yuri-Sherbet" "aarch64-linux")
          (mkHost "lemonade" "Yuri-Lemonade" "x86_64-linux")
        ];
      }
    );
}
