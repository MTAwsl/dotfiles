_: {
  flake.modules.users.yuri.home.qtgtk =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        papirus-icon-theme
      ];

      gtk = {
        enable = true;
        iconTheme = {
          package = lib.mkForce pkgs.papirus-icon-theme;
          name = lib.mkForce "Papirus-Dark";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = lib.mkForce "gtk3";
      };
    };
}
