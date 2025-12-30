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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree = {
      url = "github:vic/import-tree";
    };
    
  };

  outputs = inputs@{ flake-parts, home-manager, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
    systems = [
      "aarch64-linux"
    ];

    perSystem = { system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.foo.overlays.default ];
        config = {
          allowUnfree = true;
        };
      };
    };

    imports = [
      inputs.flake-parts.flakeModules.modules
      (import-tree ./features)
      (import-tree ./profiles)
      (import-tree ./hosts)
      (import-tree ./users)
    ];
  });
}
