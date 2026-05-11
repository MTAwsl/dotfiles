{ inputs, ... }:
{
  flake.modules.homeManager.yuri-stylix =
    { pkgs, ... }:
    {
      stylix = {
        base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/monokai.yaml";
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
          opencode.enable = false;
          dank-material-shell.enable = false;
        };
        fonts.sizes = {
          terminal = 12;
          applications = 10;
          desktop = 10;
        };
      };
    };
}
