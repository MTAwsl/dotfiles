_: {
  flake.modules.profiles.server = {
    zramSwap.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=256M
      RuntimeMaxUse=128M
      MaxRetentionSec=7day
    '';

    documentation.nixos.enable = false;
  };
}
