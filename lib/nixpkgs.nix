{ inputs, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options.flake.lib = {
    nixpkgs = mkOption {
      default = rec {
        nixpkgs = inputs.nixpkgs;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };

      type = types.lazyAttrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              nixpkgs = mkOption {
                type = types.raw;
                default = inputs.nixpkgs;
              };

              nixosSystem = mkOption {
                type = types.functionTo types.raw;
                default = inputs.nixpkgs.lib.nixosSystem;
              };
            };
          }
        )
      );
    };
  };
}
