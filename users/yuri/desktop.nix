{ ... }:
{
  flake.modules.nixos.user-yuri-desktop = { config, lib, pkgs, ... }:
  {
    home-manager.users.yuri = {
      programs = {
        firefox = {
          enable = true;
          package = pkgs.firefox-devedition;
        };

        niri.settings = {
          spawn-at-startup = [
            { sh = "regreet; niri msg action quit --skip-confirmation"; }
          ];

          hotkey-overlay.skip-at-startup = true;
          cursor.theme = "catppuccin-mocha-red-cursors";
        };


        ghostty = {
          enable = true;
          settings = {
            # font-family = "Monaspace Neon NF"; # handled by stylix
            font-style = "Light";
            font-feature = "calt, ss01, ss02, ss03, ss04, ss05, ss06, ss07, ss08, ss09, ss10, liga";
            shell-integration = "zsh";
            shell-integration-features = "sudo, title, ssh-env";
          };
        };

        vscode.enable = true;
        mpv.enable = true;
        obs-studio.enable = true;
      };
    };
  };
}

