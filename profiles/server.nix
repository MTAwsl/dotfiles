{ self, ... }:
{
  flake.modules.profiles.server = {
    imports = with self.modules.features; [
      zram
    ];

    services.journald.extraConfig = ''
      SystemMaxUse=256M
      RuntimeMaxUse=128M
      MaxRetentionSec=7day
    '';

    documentation.nixos.enable = false;
  };
}
