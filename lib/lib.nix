{ lib, ... }:
{
  options = {
    flake.lib = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.anything;
      };
      default = { };
    };
  };
}
