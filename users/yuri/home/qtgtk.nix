{ ... }:
{
  flake.modules.homeManager.yuri-qtgtk =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        papirus-icon-theme
      ];

      gtk = {
        enable = true;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
        style = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
      };
    };
}
