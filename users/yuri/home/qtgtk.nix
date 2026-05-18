_: {
  flake.modules.users.yuri.home.qtgtk =
    { config, pkgs, ... }:
    {
      home.packages = with pkgs; [
        papirus-icon-theme
      ];

      gtk = {
        enable = true;
        gtk4.theme = config.gtk.theme;
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
        style = {
          name = "Fusion";
        };
      };
    };
}
