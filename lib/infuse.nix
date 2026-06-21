{ lib, ... }:
{
  flake.lib.infuse = (import ../packages/infuse-nix/infuse.nix { inherit lib; }).v1.infuse;
}
