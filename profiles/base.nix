{ self, ... }:
{
  flake.modules.nixos.profile-base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        file
        vim
        wget
        prettier
        helix
        git
        htop
        fzf

        # System monitor
        iw
        pciutils
        usbutils
      ];

      users.groups.plugdev = { };

      programs = {
        git = {
          enable = true;
        };

        yazi = {
          enable = true;
        };

        nix-ld.enable = true;
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
