{ ... }:
{
  flake.modules.homeManager.yuri-stylix =
    { pkgs, ... }:
    {
      stylix = {
        base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";
        polarity = "dark";
        opacity.terminal = 0.9;
        targets = {
          firefox = {
            profileNames = [
              "dev-edition-default"
            ];
            fonts.enable = false;
          };
          vscode.enable = false;
          qt.enable = false;
          fzf.enable = false;
        };
        fonts.sizes = {
          terminal = 12;
          applications = 10;
          desktop = 10;
        };
      };
    };
}
