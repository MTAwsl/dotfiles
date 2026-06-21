{ inputs, ... }:
{
  flake.modules.features.stylix =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      # FIX: Remove once Stylix targets services.kmscon.extraConfig on NixOS 26.05+.
      # Older Stylix still declares services.kmscon.config even when its target is disabled.
      options = {
        services.kmscon.config = lib.mkOption {
          type = with lib.types; attrsOf anything;
          default = { };
          internal = true;
        };
      };

      config = {
        stylix = {
          enable = true;
          polarity = "dark";
          base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/catppuccin-mocha.yaml";

          targets = {
            kmscon.enable = false;
            plymouth.enable = false;
          };

          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 20;
          };

          fonts = {
            serif = {
              package = pkgs.noto-fonts;
              name = "Noto Serif";
            };
            sansSerif = {
              package = pkgs.geist-font;
              name = "Geist";
            };
            monospace = {
              package = pkgs.local.monaspace;
              name = "Monaspace Neon NF";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };
            sizes = {
              applications = 10;
            };
          };
        };
      };

    };
}
