{ self, ... }:
{
  flake.modules.nixos.profile-base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        file
        vim
        fzf
        git
        wget
        prettier
        helix
        htop

        # System monitor
        iw
        pciutils
        usbutils
      ];

      environment.sessionVariables = {
        SSH_AUTH_SOCK = "~/.ssh-agent.socket";
      };

      security.polkit.enable = true;

      users.groups.plugdev = { };
      systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
      systemd.user.extraConfig = ''
        DefaultTimeoutStopSec=10s
      '';

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
