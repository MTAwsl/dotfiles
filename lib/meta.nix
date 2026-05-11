{ lib, ... }:
{
  options = {
    flake.lib.meta = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
