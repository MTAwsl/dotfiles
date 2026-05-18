_: {
  flake.modules.users.yuri.home.firefox =
    { config, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-devedition;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        policies.preferences = {
          "spellchecker.dictionary" = "English (Australia)";
          "browser.sessionstore.max_resumed_crashes" = -1;
        };
        profiles = {
          dev-edition-default = {
            name = "dev-edition-default";
            id = 1;
            isDefault = true;
            settings = { };
            extensions.force = true;
          };

          default.extensions.force = true;
          default.isDefault = false;
        };
      };

      programs.firefoxpwa.enable = true;
    };
}
