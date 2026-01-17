{ ... }:
{
  flake.modules.homeManager.yuri-qtgtk =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        papirus-icon-theme
        kdePackages.breeze-icons
      ];

      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus";
        };
      };
    };
}
