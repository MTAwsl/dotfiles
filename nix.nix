{ ... }:
{
  flake.modules.nixos.nix =
    { ... }:
    {
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];

        optimise.automatic = true;
        gc = {
          automatic = true;
          persistent = true;
          dates = "monthly";
          randomizedDelaySec = "45min";
          options = "--delete-older-than 30d";
        };
      };
    };
}
