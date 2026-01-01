{ self, lib, ... }:
{
  flake.lib.withPrefix =
    prefix: attrs:
    lib.mapAttrs' (n: v: lib.nameValuePair (lib.removePrefix (prefix + "-") n) v) (
      lib.filterAttrs (p: v: (lib.hasPrefix (prefix + "-") p)) attrs
    );

  flake.lib.withUserProfile =
    name: (self.lib.withPrefix "user" self.modules.nixos) |> (self.lib.withPrefix name);
}
