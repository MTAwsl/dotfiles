{ ... }:
{
  flake.modules.homeManager.yuri-yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        plugins = with pkgs.yaziPlugins; {
          inherit
            chmod
            smart-enter
            vcs-files
            git
            full-border
            ;
        };
      };
    };
}
