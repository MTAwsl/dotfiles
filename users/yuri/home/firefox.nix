{ ... }:
{
  flake.modules.homeManager.yuri-firefox =
    { pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-devedition;
        policies.preferences = {
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
