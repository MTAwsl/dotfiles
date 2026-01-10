{ self, ... }:
{
  flake.modules.nixos.profile-desktop =
    { ... }:
    {
      imports = with self.modules.nixos; [
        niri
        dms-shell
        plymouth
      ];
    };
}
