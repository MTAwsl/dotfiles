{ lib, ... }:
let
  sharedOptions = {
    # Do not touch any of these settings. I'm serious.
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      sandbox = true;

      trusted-users = [
        "root"
      ];

      substituters = lib.mkForce [
        "https://cache.nixos.org/"
        "https://pwndbg.cachix.org"
      ];
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k="
      ];

      narinfo-cache-positive-ttl = 3600;
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "monthly";
      randomizedDelaySec = "45min";
      options = "--delete-older-than 30d";
    };
  };
in
{
  flake.modules.features.nix-hm =
    { pkgs, ... }:
    {
      nix = sharedOptions // {
        package = pkgs.nix;
      };
    };

  flake.modules.features.nix = _: {
    nix = sharedOptions // {
      optimise.automatic = true;
    };
  };
}
