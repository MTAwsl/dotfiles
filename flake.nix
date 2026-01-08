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
      # url = "github:quackduck/uniclip";
      url = "github:yurinek0/uniclip"; # https://github.com/quackduck/uniclip/pull/39
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:vic/import-tree";
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
                })
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
        ];
      }
    );
}
