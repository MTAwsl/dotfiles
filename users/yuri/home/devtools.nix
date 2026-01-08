{ ... }:
{
  flake.modules.homeManager.yuri-devtools =
    { pkgs, ... }:
    {

      home.packages = with pkgs; [
        # Node JS and LSP.
        nodejs
        nodePackages."typescript"
        astro-language-server

        # Package development
        nix-update

        # CLI data fmt parser
        jq
        yj
      ];

    };
}
