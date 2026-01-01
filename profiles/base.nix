{ self, ... }:
{
  flake.modules.nixos.profile-base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vim
        wget
        prettier
        helix
        git
        htop
        fzf
      ];

      programs = {
        git = {
          enable = true;
        };

        yazi = {
          enable = true;
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

        bat.enable = true;
        zsh = {
          enable = true;
          ohMyZsh = {
            enable = true;
            preLoaded = ''
              zstyle ':omz:update' mode disabled
            '';
          };

          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
            cat = "bat";
          };
        };
      };
    };
}
