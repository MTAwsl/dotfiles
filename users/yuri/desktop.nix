{ self, ... }:
{
  flake.modules.nixos.user-yuri-desktop =
    {
      lib,
      pkgs,
      ...
    }:
    {
      home-manager.users.yuri = {
        imports = with self.lib.withPrefix "yuri" self.modules.homeManager; [
          niri
        ];

        programs = {
          firefox = {
            enable = true;
            package = pkgs.firefox-devedition;
          };

          vscode.enable = true;
          mpv.enable = true;
          obs-studio.enable = true;
        };
      };
    };
}
