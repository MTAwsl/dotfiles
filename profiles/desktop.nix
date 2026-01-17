{ self, ... }:
{
  flake.modules.nixos.profile-desktop =
    { pkgs, ... }:
    {
      imports = with self.modules.nixos; [
        niri
        dms-shell
        plymouth
        stylix
        fonts

        # Switch back to dms-greeter once it supports YubiKey.
        # dms-greeter
        # tuigreet
        regreet
        hyprlock # Choose hyprlock as lock screen cmd in DMS Settings
      ];

      environment.systemPackages = with pkgs; [ ];
    };
}
